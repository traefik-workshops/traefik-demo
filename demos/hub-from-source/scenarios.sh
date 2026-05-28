#!/usr/bin/env bash
# Smoke scenarios for demos/hub-from-source.
#
# Asserts whoami is reachable through Traefik Hub and — the point of this demo —
# that the *running* Hub image is the one we expect. Override EXPECT_DEV=true
# after `make up-dev` to require the from-source build.
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
curl_code() { curl -sk -o /dev/null -w '%{http_code}' --resolve "$1:443:127.0.0.1" "https://$1$2"; }
wait_200() {
  for _ in $(seq 1 20); do
    [ "$(curl_code "$1" "$2")" = "200" ] && return 0
    sleep 3
  done
  return 1
}

echo "== hub-from-source scenarios (domain=$DOMAIN, expect_dev=$EXPECT_DEV) =="

# 1. whoami reachable through Traefik Hub.
if wait_200 "whoami.$DOMAIN" "/"; then
  ok "whoami via Hub -> 200"
else
  bad "whoami via Hub -> $(curl_code "whoami.$DOMAIN" "/") (want 200)"
fi

# 2. Which Hub image is actually running?
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
