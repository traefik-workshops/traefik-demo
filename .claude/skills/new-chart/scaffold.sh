#!/usr/bin/env bash
# scaffold.sh — generate a new Helm chart under helm/<name>/ following
# the canonical layout documented in /helm/AGENTS.md.
#
# Usage:
#   scaffold.sh --name <name> --purpose "<line>" --kind <kind> --app-version <X.Y.Z>
#
# kinds: app | app-with-ingress | library | wrapper
#
# Exit codes:
#   0 ok | 2 bad args | 3 target exists | 4 template missing | 5 helm lint failed

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/../../.." && pwd)"
TEMPLATES_DIR="${SCRIPT_DIR}/templates"

NAME=""
PURPOSE=""
KIND="app"
APP_VERSION=""

usage() {
    cat >&2 <<'USAGE'
Usage: scaffold.sh --name <name> --purpose "<line>" --kind <kind> --app-version <X.Y.Z>

Required:
  --name          kebab-case chart name (e.g. my-tool)
  --purpose       one-line description
  --app-version   upstream app version (X.Y.Z or vX.Y.Z)

Optional:
  --kind          app | app-with-ingress | library | wrapper   (default: app)
USAGE
    exit 2
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --name)        NAME="$2"; shift 2 ;;
        --purpose)     PURPOSE="$2"; shift 2 ;;
        --kind)        KIND="$2"; shift 2 ;;
        --app-version) APP_VERSION="$2"; shift 2 ;;
        -h|--help)     usage ;;
        *) echo "unknown arg: $1" >&2; usage ;;
    esac
done

[[ -z "$NAME" || -z "$PURPOSE" || -z "$APP_VERSION" ]] && usage

if [[ ! "$NAME" =~ ^[a-z][a-z0-9-]*$ ]]; then
    echo "error: name must be kebab-case lowercase (got '$NAME')" >&2
    exit 2
fi

case "$KIND" in
    app|app-with-ingress|library|wrapper) ;;
    *) echo "error: kind must be app|app-with-ingress|library|wrapper (got '$KIND')" >&2; exit 2 ;;
esac

TEMPLATE_DIR="${TEMPLATES_DIR}/${KIND}"
if [[ ! -d "$TEMPLATE_DIR" ]]; then
    echo "error: template '$KIND' not found at $TEMPLATE_DIR" >&2
    exit 4
fi

TARGET="${REPO_ROOT}/helm/${NAME}"
if [[ -e "$TARGET" ]]; then
    echo "error: target already exists: $TARGET" >&2
    exit 3
fi

# Current repo version (Chart.yaml version: gets pinned to this)
CURRENT_TAG=$(cd "$REPO_ROOT" && git tag --list 'v*' | sort -V | tail -n1 2>/dev/null)
[[ -z "$CURRENT_TAG" ]] && CURRENT_TAG="v0.0.0"
REPO_VERSION="${CURRENT_TAG#v}"

echo "==> scaffold helm/$NAME"
echo "    kind:         $KIND"
echo "    purpose:      $PURPOSE"
echo "    app version:  $APP_VERSION"
echo "    chart version (repo tag): $REPO_VERSION"

mkdir -p "$TARGET"
mkdir -p "$TARGET/templates"

NAME_HUMAN="$(echo "$NAME" | tr '_-' '  ' | awk '{for(i=1;i<=NF;i++)$i=toupper(substr($i,1,1))substr($i,2)}1')"

# Walk template dir, preserve subdirectories, substitute placeholders
( cd "$TEMPLATE_DIR" && find . -type f -name '*.tmpl' ) | while read -r rel; do
    out_rel="${rel#./}"
    out_rel="${out_rel%.tmpl}"
    out_path="$TARGET/$out_rel"
    mkdir -p "$(dirname "$out_path")"
    sed \
        -e "s|{{NAME}}|${NAME}|g" \
        -e "s|{{NAME_HUMAN}}|${NAME_HUMAN}|g" \
        -e "s|{{PURPOSE}}|${PURPOSE}|g" \
        -e "s|{{APP_VERSION}}|${APP_VERSION}|g" \
        -e "s|{{REPO_VERSION}}|${REPO_VERSION}|g" \
        "${TEMPLATE_DIR}/${rel}" > "$out_path"
done

# Generate starter values.schema.json from the templated values.yaml
if [[ -f "$TARGET/values.yaml" ]] && command -v python3 >/dev/null 2>&1; then
    python3 - <<PYEOF
import json, sys
try:
    import yaml
except ImportError:
    sys.exit(0)

with open("$TARGET/values.yaml") as f:
    values = yaml.safe_load(f) or {}

def infer(v, depth=0):
    if v is None: return {}
    if isinstance(v, bool): return {"type": "boolean", "default": v}
    if isinstance(v, int): return {"type": "integer", "default": v}
    if isinstance(v, float): return {"type": "number", "default": v}
    if isinstance(v, str): return {"type": "string", "default": v}
    if isinstance(v, list):
        return {"type": "array", "items": infer(v[0], depth+1) if v else {}}
    if isinstance(v, dict):
        props = {k: infer(val, depth+1) for k, val in v.items()}
        s = {"type": "object", "properties": props}
        if depth == 0: s["additionalProperties"] = False
        return s
    return {}

schema = {
    "\$schema": "https://json-schema.org/draft-07/schema#",
    "title": "$NAME chart values",
    **infer(values),
}
with open("$TARGET/values.schema.json", "w") as f:
    json.dump(schema, f, indent=2)
    f.write("\n")
print("  wrote values.schema.json (hand-edit to add descriptions)")
PYEOF
fi

# helm lint to confirm parses
if command -v helm >/dev/null 2>&1; then
    if ! ( cd "$TARGET" && helm lint --strict . >/dev/null 2>&1 ); then
        echo "warn: helm lint --strict failed in $TARGET — fix and re-run." >&2
        ( cd "$TARGET" && helm lint --strict . ) || true
        exit 5
    fi
    echo "  helm lint --strict: ok"
else
    echo "warn: helm not on PATH — skipping lint. Run \`helm lint --strict $TARGET\` manually." >&2
fi

cat <<EOM

==> scaffold complete: helm/${NAME}

next steps:
  1. Fill in # TODO(new-chart): markers in values.yaml, templates/*.yaml.
  2. Hand-edit values.schema.json — add descriptions, mark required fields.
  3. Replace the generic NOTES.txt with real URLs and credentials.
  4. Add a row to helm/README.md's charts table:
       | [\`${NAME}\`](./${NAME}) | ${PURPOSE} | ${APP_VERSION} |
  5. Pick a test tier from /TESTING.md#helm (default: Install).
  6. Run \`make check\` from the repo root.
  7. When merging: this is a release-feature (minor) bump — see /CONTRIBUTING.md.
EOM
