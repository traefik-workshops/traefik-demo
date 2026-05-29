#!/usr/bin/env bash
# Smoke scenario for demos/single-cluster: whoami is reachable through Traefik
# Hub. k3d maps :443 to localhost (self-signed -> -k). Retry briefly to allow
# for route propagation after apply.
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
wait_200() {
  for _ in $(seq 1 20); do
    [ "$(curl_code "$1" "$2")" = "200" ] && return 0
    sleep 3
  done
  return 1
}

echo "== single-cluster scenarios (domain=$DOMAIN) =="

if wait_200 "whoami.$DOMAIN" "/"; then
  ok "whoami via Hub -> 200"
else
  bad "whoami via Hub -> $(curl_code "whoami.$DOMAIN" "/") (want 200)"
fi

echo "== $pass passed, $fail failed =="
[ "$fail" -eq 0 ]
