#!/usr/bin/env bash
# scaffold.sh — generate a new module under terraform-demo-modules following
# the canonical layout documented in /CLAUDE.md.
#
# Invoked by the new-module skill, but also runnable on its own.
#
# Path layout (yes, it differs by section — this is real and intentional):
#
#   ai/<name>/<platform>             e.g. ai/milvus/k8s
#   apps/<name>/<platform>           e.g. apps/whoami/ec2
#   compute/<cloud>/<name>           e.g. compute/aws/eks    (cloud first!)
#   observability/<name>/<platform>  e.g. observability/grafana/k8s
#   security/<name>                  e.g. security/cognito              (cloud-native IdPs)
#   security/<name>/<platform>       e.g. security/keycloak/k8s         (k8s-installed)
#   tools/<name>/<platform>          e.g. tools/argocd/k8s
#   traefik/<platform>               e.g. traefik/k8s       (no name layer)
#
# Examples:
#   scaffold.sh --section tools --platform k8s --name vault --purpose "..."
#       -> tools/vault/k8s/
#   scaffold.sh --section compute --platform aws --name lambda --purpose "..."
#       -> compute/aws/lambda/
#   scaffold.sh --section traefik --platform fly --purpose "..."
#       -> traefik/fly/      (note: --name not used for traefik)
#   scaffold.sh --section security --name auth0 --purpose "..."
#       -> security/auth0/   (no platform = cloud-native IdP)
#
# Exit codes:
#   0   ok
#   2   bad args
#   3   target path already exists
#   4   template not found
#   5   terraform validate failed

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/../../.." && pwd)"
TEMPLATES_DIR="${SCRIPT_DIR}/templates"

# ----- arg parsing -----
SECTION=""
PLATFORM=""
NAME=""
PURPOSE=""
TEMPLATE=""

usage() {
    cat >&2 <<'USAGE'
Usage:
  scaffold.sh --section <s> [--platform <p>] [--name <n>] --purpose "<line>" [--template <t>]

Sections:  ai apps compute observability security tools traefik

Per-section requirements:
  ai             --name --platform (k8s|runpod)
  apps           --name --platform (k8s|ec2|ecs|nutanix|cloud-init)
  compute        --platform=<cloud> --name=<service> (e.g. --platform aws --name lambda)
  observability  --name --platform (k8s)
  security       --name [--platform k8s for keycloak-style]
  tools          --name --platform (k8s usually)
  traefik        --platform=<platform>   (no --name; the platform is the module)

Templates (auto-picked; override with --template):
  base k8s-helm cluster iaas traefik-platform runpod idp
USAGE
    exit 2
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --section)  SECTION="$2"; shift 2 ;;
        --platform) PLATFORM="$2"; shift 2 ;;
        --name)     NAME="$2"; shift 2 ;;
        --purpose)  PURPOSE="$2"; shift 2 ;;
        --template) TEMPLATE="$2"; shift 2 ;;
        -h|--help)  usage ;;
        *) echo "unknown arg: $1" >&2; usage ;;
    esac
done

[[ -z "$SECTION" || -z "$PURPOSE" ]] && usage

# ----- validate section -----
case "$SECTION" in
    ai|apps|compute|observability|security|tools|traefik) ;;
    *) echo "error: section must be one of ai/apps/compute/observability/security/tools/traefik (got '$SECTION')" >&2; exit 2 ;;
esac

# ----- refuse traefik/shared and traefik/cloud-init -----
if [[ "$SECTION" == "traefik" && ( "$PLATFORM" == "shared" || "$PLATFORM" == "cloud-init" ) ]]; then
    echo "error: traefik/shared and traefik/cloud-init are library modules; extend them in place rather than scaffolding a new one." >&2
    exit 2
fi

# ----- compute target path per section -----
#
# This is the only piece of logic that varies by section. The path layout
# is what it is — see the comment block at the top of this file.

case "$SECTION" in
    traefik)
        # traefik/<platform>   — no name layer
        [[ -z "$PLATFORM" ]] && { echo "error: --platform required for traefik" >&2; exit 2; }
        [[ -n "$NAME" ]] && echo "warn: --name ignored for traefik (path is traefik/<platform>)" >&2
        TARGET="${REPO_ROOT}/terraform/${SECTION}/${PLATFORM}"
        DISPLAY_PATH="terraform/${SECTION}/${PLATFORM}"
        NAME="${PLATFORM}" # used for substitution in templates
        ;;
    compute)
        # compute/<cloud>/<name>   — cloud first
        [[ -z "$PLATFORM" || -z "$NAME" ]] && { echo "error: --platform (cloud) and --name (service) required for compute" >&2; exit 2; }
        TARGET="${REPO_ROOT}/terraform/${SECTION}/${PLATFORM}/${NAME}"
        DISPLAY_PATH="terraform/${SECTION}/${PLATFORM}/${NAME}"
        ;;
    security)
        # security/<name>           — cloud-native (cognito-style)
        # security/<name>/<platform> — k8s-installed (keycloak-style)
        [[ -z "$NAME" ]] && { echo "error: --name required for security" >&2; exit 2; }
        if [[ -n "$PLATFORM" ]]; then
            TARGET="${REPO_ROOT}/terraform/${SECTION}/${NAME}/${PLATFORM}"
            DISPLAY_PATH="terraform/${SECTION}/${NAME}/${PLATFORM}"
        else
            TARGET="${REPO_ROOT}/terraform/${SECTION}/${NAME}"
            DISPLAY_PATH="terraform/${SECTION}/${NAME}"
        fi
        ;;
    *)
        # ai / apps / observability / tools : <section>/<name>/<platform>
        [[ -z "$PLATFORM" || -z "$NAME" ]] && { echo "error: --platform and --name required for $SECTION" >&2; exit 2; }
        TARGET="${REPO_ROOT}/terraform/${SECTION}/${NAME}/${PLATFORM}"
        DISPLAY_PATH="terraform/${SECTION}/${NAME}/${PLATFORM}"
        ;;
esac

# ----- validate name -----
if [[ ! "$NAME" =~ ^[a-z][a-z0-9_-]*$ ]]; then
    echo "error: name must be snake_case or kebab-case (lowercase, start with a letter): got '$NAME'" >&2
    exit 2
fi

# ----- pick template (if not overridden) -----
if [[ -z "$TEMPLATE" ]]; then
    case "$SECTION/$PLATFORM" in
        ai/k8s|apps/k8s|observability/k8s|security/k8s|tools/k8s)
            TEMPLATE="k8s-helm" ;;
        ai/runpod|compute/runpod)
            TEMPLATE="runpod" ;;
        apps/cloud-init)
            TEMPLATE="base" ;;
        apps/ec2|apps/ecs|apps/nutanix)
            TEMPLATE="iaas" ;;
        compute/*)
            case "$NAME" in
                *ks|*oke|*gke|*aks|*eks|*doks|*lke|*nkp|*k3d)
                    TEMPLATE="cluster" ;;
                *)
                    TEMPLATE="iaas" ;;
            esac ;;
        security/*)
            # k8s-installed security goes through k8s-helm above; everything
            # else here is an IdP.
            TEMPLATE="idp" ;;
        tools/*)
            TEMPLATE="base" ;;
        traefik/*)
            TEMPLATE="traefik-platform" ;;
        *)
            TEMPLATE="base" ;;
    esac
fi

TEMPLATE_DIR="${TEMPLATES_DIR}/${TEMPLATE}"
if [[ ! -d "$TEMPLATE_DIR" ]]; then
    echo "error: template '$TEMPLATE' not found at $TEMPLATE_DIR" >&2
    exit 4
fi

if [[ -e "$TARGET" ]]; then
    echo "error: target already exists: $TARGET" >&2
    exit 3
fi

echo "==> scaffold: ${DISPLAY_PATH}"
echo "    template: ${TEMPLATE}"
echo "    purpose:  ${PURPOSE}"

mkdir -p "$TARGET"

# ----- substitute and copy -----
NAME_LC="${NAME}"
NAME_HUMAN="$(echo "$NAME" | tr '_-' '  ' | awk '{for(i=1;i<=NF;i++)$i=toupper(substr($i,1,1))substr($i,2)}1')"

for tmpl in "$TEMPLATE_DIR"/*.tmpl; do
    [[ -f "$tmpl" ]] || continue
    out_name="$(basename "$tmpl" .tmpl)"
    sed \
        -e "s|{{NAME}}|${NAME_LC}|g" \
        -e "s|{{NAME_HUMAN}}|${NAME_HUMAN}|g" \
        -e "s|{{PURPOSE}}|${PURPOSE}|g" \
        -e "s|{{SECTION}}|${SECTION}|g" \
        -e "s|{{PLATFORM}}|${PLATFORM:-${NAME}}|g" \
        "$tmpl" > "$TARGET/$out_name"
done

# ----- fmt + validate -----
if command -v terraform >/dev/null 2>&1; then
    ( cd "$TARGET" && terraform fmt > /dev/null )
    if ( cd "$TARGET" && terraform init -backend=false -input=false -no-color > /dev/null 2>&1 ); then
        if ! ( cd "$TARGET" && terraform validate -no-color ); then
            echo "warn: terraform validate failed in $TARGET. Files are in place; fix and re-run validate." >&2
            exit 5
        fi
        rm -rf "$TARGET/.terraform" "$TARGET/.terraform.lock.hcl"
    else
        echo "warn: terraform init failed (provider may be unreachable). Skipping validate." >&2
    fi
else
    echo "warn: terraform not on PATH. Skipping fmt+validate. Run them manually before committing." >&2
fi

# ----- next-steps checklist -----
cat <<EOF

==> scaffold complete: ${DISPLAY_PATH}

next steps:
  1. Fill in the # TODO(new-module): markers in main.tf, variables.tf, outputs.tf.
  2. Add a row to terraform/${SECTION}/README.md's module table:
       | [\`${DISPLAY_PATH#terraform/${SECTION}/}\`](./${DISPLAY_PATH#terraform/${SECTION}/}) | ${PURPOSE} |
  3. Pick a test tier from /TESTING.md (default: Static).
  4. Run \`make check\` from the repo root.
  5. When merging: this is a release-feature (minor) bump — see /CONTRIBUTING.md.
EOF
