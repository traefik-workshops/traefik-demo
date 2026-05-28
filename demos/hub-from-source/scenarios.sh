#!/usr/bin/env bash
# Smoke scenarios for demos/hub-from-source.
#
# Asserts ingress works through Traefik Hub and — the point of this demo — that
# the *running* Hub image is the one we expect. Override EXPECT_DEV=true after
# `make up-dev` to require the from-source build.
set -uo pipefail

DOMAIN="${DOMAIN:-hub-from-source.localhost}"
NS="${NS:-traefik}"
CTX="${CTX:-k3d-hub-from-source}"
EXPECT_DEV="${EXPECT_DEV:-auto}" # auto | true | false

pass=0
fail=0
ok() {
  echo "  PASS $1"
  pass=$((pass + 1))
}
bad() {
  echo "  FAIL $1"
  fail=$((fail + 1))
}

# curl through the k3d load balancer on 443 (self-signed cert -> -k).
curl_code() { curl -sk -o /dev/null -w '%{http_code}' --resolve "$1:443:127.0.0.1" "https://$1$2"; }

echo "== hub-from-source scenarios (domain=$DOMAIN, expect_dev=$EXPECT_DEV) =="

# 1. whoami reachable through Traefik Hub.
code=$(curl_code "whoami.$DOMAIN" "/")
[ "$code" = "200" ] && ok "whoami via Hub -> 200" || bad "whoami via Hub -> $code (want 200)"

# 2. dashboard responds.
code=$(curl_code "dashboard.$DOMAIN" "/")
case "$code" in
200 | 302) ok "dashboard -> $code" ;;
*) bad "dashboard -> $code (want 200/302)" ;;
esac

# 3. Which Hub image is actually running?
img=$(kubectl --context "$CTX" -n "$NS" get pods -l app.kubernetes.io/name=traefik \
  -o jsonpath='{.items[0].spec.containers[0].image}' 2>/dev/null)
echo "  running image: ${img:-<none>}"
is_dev=false
case "$img" in *localhost:5001/traefik/traefik-hub:dev*) is_dev=true ;; esac

if [ -z "$img" ]; then
  bad "could not read the running Traefik image (is the cluster up?)"
else
  case "$EXPECT_DEV" in
  true) $is_dev && ok "running the from-source :dev image" || bad "expected the :dev image, got $img" ;;
  false) $is_dev && bad "expected a released image, got the :dev image" || ok "running a released image" ;;
  auto) $is_dev && ok "running the from-source :dev image" || ok "running a released image (run 'make up-dev' for the source build)" ;;
  esac
fi

echo "== $pass passed, $fail failed =="
[ "$fail" -eq 0 ]
