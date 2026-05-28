#!/usr/bin/env bash
# Smoke scenarios for demos/single-cluster: whoami is reachable through Traefik
# Hub, and the dashboard responds. k3d maps :443 to localhost (self-signed -> -k).
set -uo pipefail

DOMAIN="${DOMAIN:-single-cluster.localhost}"

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

echo "== single-cluster scenarios (domain=$DOMAIN) =="

code=$(curl_code "whoami.$DOMAIN" "/")
[ "$code" = "200" ] && ok "whoami via Hub -> 200" || bad "whoami via Hub -> $code (want 200)"

code=$(curl_code "dashboard.$DOMAIN" "/")
case "$code" in
200 | 302) ok "dashboard -> $code" ;;
*) bad "dashboard -> $code (want 200/302)" ;;
esac

echo "== $pass passed, $fail failed =="
[ "$fail" -eq 0 ]
