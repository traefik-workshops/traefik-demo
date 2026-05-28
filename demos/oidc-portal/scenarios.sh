#!/usr/bin/env bash
# Smoke scenarios for demos/oidc-portal.
#
# This demo is cloud-based (EKS + AWS Cognito), so CI does NOT run it — run this
# by hand against a real deploy. Set DOMAIN to the domain you deployed on (it
# resolves via real DNS, so no --resolve). The API Portal sits behind Cognito
# OIDC: an unauthenticated request is redirected to the IdP login.
set -uo pipefail

DOMAIN="${DOMAIN:?set DOMAIN to your deployed domain, e.g. DOMAIN=demo.example.com ./scenarios.sh}"

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
curl_code() { curl -sk -o /dev/null -w '%{http_code}' "https://$1$2"; }

echo "== oidc-portal scenarios (domain=$DOMAIN) =="

# whoami reachable through Traefik.
code=$(curl_code "whoami.$DOMAIN" "/")
[ "$code" = "200" ] && ok "whoami -> 200" || bad "whoami -> $code (want 200)"

# API Portal unauthenticated -> redirected to Cognito (302) or served (200).
code=$(curl_code "portal.$DOMAIN" "/")
case "$code" in
200 | 301 | 302) ok "portal -> $code (auth gate / served)" ;;
*) bad "portal -> $code (want 200/302)" ;;
esac

echo "== $pass passed, $fail failed =="
[ "$fail" -eq 0 ]
