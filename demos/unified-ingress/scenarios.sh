#!/usr/bin/env bash
# Smoke scenarios for demos/unified-ingress.
#
# whoami runs on the app-workload child cluster; the transit parent discovers it
# via the multicluster provider and serves it on the transit entrypoint (host
# :443). So this curl only succeeds if cross-cluster discovery is working —
# that's the point of the demo. Multicluster discovery polls, so retry a bit.
set -uo pipefail

DOMAIN="${DOMAIN:-unified-ingress.localhost}"

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

# Curl through the TRANSIT cluster (binds host :443).
curl_code() { curl -sk -o /dev/null -w '%{http_code}' --resolve "$1:443:127.0.0.1" "https://$1$2"; }

# Poll a host for up to ~90s (multicluster discovery + Hub boot take a moment).
wait_200() {
  for _ in $(seq 1 30); do
    [ "$(curl_code "$1" "$2")" = "200" ] && return 0
    sleep 3
  done
  return 1
}

echo "== unified-ingress scenarios (domain=$DOMAIN) =="

if wait_200 "whoami.$DOMAIN" "/"; then
  ok "whoami via transit (cross-cluster) -> 200"
else
  bad "whoami via transit -> $(curl_code "whoami.$DOMAIN" "/") (want 200; check multicluster discovery)"
fi

echo "== $pass passed, $fail failed =="
[ "$fail" -eq 0 ]
