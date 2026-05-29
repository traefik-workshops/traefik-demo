#!/usr/bin/env bash
#
# reference.sh — on-demand bridge to traefik/reference, the versioned,
# machine-readable reference of Traefik + Hub config and CRDs.
#
# That repo is PRIVATE, so nothing from it is vendored into this PUBLIC repo.
# Everything here fetches on demand via `gh` and degrades gracefully when the
# caller is not authenticated: print how to authenticate, then continue without
# the reference rather than blocking the task.
#
# Subcommands:
#   page <id>     Print a reference Markdown page to stdout (id e.g. hub/crd/api,
#                 oss/middlewares/ratelimit, or INDEX). For humans and agents.
#   schemas       Populate the JSON-Schema cache used to validate CRDs.
#   validate      helm template every chart | kubeconform, validating Traefik +
#                 Hub custom resources against the real schemas.
#
# Pin a different upstream snapshot with REFERENCE_REF (a commit SHA or branch).
set -euo pipefail

REFERENCE_REPO="${REFERENCE_REPO:-traefik/reference}"
REFERENCE_REF="${REFERENCE_REF:-main}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CACHE_DIR="${REFERENCE_CACHE:-${REPO_ROOT}/.reference}"
SCHEMA_DIR="${CACHE_DIR}/schemas"

c_red=$'\033[31m'; c_yellow=$'\033[33m'; c_green=$'\033[32m'; c_dim=$'\033[2m'; c_reset=$'\033[0m'
[ -t 2 ] || { c_red=; c_yellow=; c_green=; c_dim=; c_reset=; }
note() { printf '%s\n' "$*" >&2; }

# Is the reference reachable? gh installed + authenticated. On failure, print
# one-time guidance and return non-zero so callers can degrade.
_auth_warned=
reference_available() {
  if ! command -v gh >/dev/null 2>&1; then
    [ -n "$_auth_warned" ] || note "${c_yellow}reference:${c_reset} gh CLI not found — continuing without the Traefik/Hub reference. Install: https://cli.github.com"
    _auth_warned=1
    return 1
  fi
  if ! gh auth status >/dev/null 2>&1; then
    [ -n "$_auth_warned" ] || note "${c_yellow}reference:${c_reset} not authenticated to GitHub — run ${c_dim}gh auth login${c_reset} (needs access to ${REFERENCE_REPO}) to enable the reference. Continuing without it."
    _auth_warned=1
    return 1
  fi
  return 0
}

# Fetch one file from the reference repo to stdout (raw bytes).
fetch_raw() {
  gh api -H "Accept: application/vnd.github.raw" \
    "repos/${REFERENCE_REPO}/contents/$1?ref=${REFERENCE_REF}" 2>/dev/null
}

# ---------------------------------------------------------------------------
cmd_page() {
  local id="${1:-INDEX}"
  [ -n "$id" ] || id="INDEX"
  local path
  case "$id" in
    INDEX|index) path="reference/INDEX.md" ;;
    reference/*) path="${id%.md}.md" ;;
    *)           path="reference/${id%.md}.md" ;;
  esac
  if ! reference_available; then return 3; fi
  if ! fetch_raw "$path"; then
    note "${c_red}reference:${c_reset} could not fetch ${path} at ${REFERENCE_REF} (does it exist / do you have access?)."
    return 3
  fi
}

# ---------------------------------------------------------------------------
# Lay schemas out datreeio-style: <group>/<kind-lowercase>_<version>.json, the
# convention kubeconform's -schema-location template consumes.
cmd_schemas() {
  if ! reference_available; then return 3; fi

  local tmp count=0
  tmp="$(mktemp -d)"

  if ! fetch_raw schemas/INDEX.json > "${tmp}/INDEX.json" || [ ! -s "${tmp}/INDEX.json" ]; then
    note "${c_red}reference:${c_reset} could not fetch schemas/INDEX.json — skipping CRD schemas."
    rm -rf "$tmp"; return 3
  fi

  local version
  version="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1])).get("version",""))' "${tmp}/INDEX.json" 2>/dev/null || true)"

  # Every CRD-scoped schema path (OSS + Hub + Gateway API). INDEX's api_versions
  # field is unreliable for Hub CRDs, so we derive the kubeconform filename from
  # each schema's own kind/apiVersion below — INDEX is used only to discover paths.
  local paths
  paths="$(python3 - "${tmp}/INDEX.json" <<'PY'
import json, sys
idx = json.load(open(sys.argv[1]))
crd = {"kubernetes-crd", "traefik-hub-crd"}
for s in idx.get("schemas", []):
    if s.get("scope") in crd:
        print(s["path"])
PY
)"
  if [ -z "$paths" ]; then
    note "${c_red}reference:${c_reset} INDEX.json had no CRD schemas — skipping."
    rm -rf "$tmp"; return 3
  fi

  rm -rf "$SCHEMA_DIR"
  mkdir -p "$SCHEMA_DIR"
  local path srccache dests
  while IFS= read -r path; do
    [ -n "$path" ] || continue
    srccache="${tmp}/$(echo "$path" | tr / _)"
    if ! fetch_raw "schemas/${path}" > "$srccache" || [ ! -s "$srccache" ]; then
      note "${c_yellow}reference:${c_reset} failed to fetch schemas/${path} — skipping."
      continue
    fi
    # Authoritative dest filename(s) from the schema's own kind const + apiVersion enum.
    dests="$(python3 - "$srccache" <<'PY'
import json, sys
p = json.load(open(sys.argv[1])).get("properties", {})
k = p.get("kind", {})
kinds = [k["const"]] if "const" in k else k.get("enum", [])
a = p.get("apiVersion", {})
avs = [a["const"]] if "const" in a else a.get("enum", [])
for kind in kinds:
    for av in avs:
        group, _, ver = av.rpartition("/")
        print(f"{group or 'core'}/{kind.lower()}_{ver}.json")
PY
)"
    while IFS= read -r dest; do
      [ -n "$dest" ] || continue
      mkdir -p "${SCHEMA_DIR}/$(dirname "$dest")"
      cp "$srccache" "${SCHEMA_DIR}/${dest}"
      count=$((count + 1))
    done <<< "$dests"
  done <<< "$paths"

  rm -rf "$tmp"
  printf '%s\t%s\n' "$REFERENCE_REF" "$version" > "${CACHE_DIR}/.stamp"
  note "${c_green}reference:${c_reset} cached ${count} CRD schema(s) (${REFERENCE_REPO}@${REFERENCE_REF}${version:+, ${version}}) -> ${SCHEMA_DIR#${REPO_ROOT}/}"
}

# ---------------------------------------------------------------------------
cmd_validate() {
  if ! command -v helm >/dev/null 2>&1; then note "${c_red}error:${c_reset} helm not installed."; exit 1; fi
  if ! command -v kubeconform >/dev/null 2>&1; then
    note "${c_yellow}warn:${c_reset} kubeconform not installed — skipping manifest validation."
    exit 0
  fi

  # Refresh the schema cache (best effort). Degrades when unauthenticated/offline.
  local fresh=1
  cmd_schemas || fresh=0

  # Reference CRD schemas first (so Traefik/Hub CRs resolve locally), then the
  # upstream default location for core Kubernetes kinds. Without `default`,
  # passing -schema-location would stop core kinds (Service, ConfigMap, ...)
  # from being validated at all.
  local loc=(-schema-location default) mode
  if [ -d "$SCHEMA_DIR" ] && [ -n "$(ls -A "$SCHEMA_DIR" 2>/dev/null)" ]; then
    loc=(-schema-location "${SCHEMA_DIR}/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json"
         -schema-location default)
    if [ "$fresh" -eq 1 ]; then
      mode="${c_green}validating Traefik + Hub CRDs against ${REFERENCE_REPO}@${REFERENCE_REF}${c_reset}"
    else
      mode="${c_yellow}validating against cached reference schemas (could not refresh)${c_reset}"
    fi
  else
    mode="${c_yellow}reference schemas unavailable — CRDs left unvalidated (run 'gh auth login' to enable)${c_reset}"
  fi
  note "reference: ${mode}"

  local fail=0 chart
  for chart in "${REPO_ROOT}"/helm/*/; do
    [ -f "${chart}Chart.yaml" ] || continue
    # Charts with dependencies can't render without them; build best-effort.
    if grep -q '^dependencies:' "${chart}Chart.yaml" 2>/dev/null; then
      if ! helm dependency build "$chart" >/dev/null 2>&1; then
        note "${c_yellow}skip:${c_reset} $(basename "$chart") — could not build chart dependencies locally."
        continue
      fi
    fi
    note "${c_dim}template $(basename "$chart")${c_reset}"
    if ! helm template release-name "$chart" 2>/dev/null \
        | kubeconform -strict -summary -ignore-missing-schemas \
            -skip CustomResourceDefinition "${loc[@]}"; then
      fail=1
    fi
  done
  if [ "$fail" -eq 0 ]; then
    note "${c_green}reference: validate ok${c_reset}"
  else
    note "${c_red}reference: validate failed${c_reset}"
    exit 1
  fi
}

# ---------------------------------------------------------------------------
case "${1:-}" in
  page)     shift; cmd_page "$@" ;;
  schemas)  cmd_schemas ;;
  validate) cmd_validate ;;
  *)
    note "usage: $(basename "$0") {page <id>|schemas|validate}"
    note ""
    note "  page <id>   print a reference page (e.g. hub/crd/api, oss/middlewares/jwt, INDEX)"
    note "  schemas     cache Traefik + Hub CRD JSON schemas for kubeconform"
    note "  validate    helm template | kubeconform, validating CRDs against real schemas"
    exit 2
    ;;
esac
