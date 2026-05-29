#!/usr/bin/env bash
# Smoke scenarios for demos/aks-demo.
#
# Cloud demo (AKS + Keycloak + real DNS), so CI does NOT run it — run by hand
# against a real deploy. Domain + a developer JWT are read from terraform
# outputs; override DOMAIN / TOKEN to point elsewhere. Hostnames resolve via
# real DNS (dns-traefiker), certs via Let's Encrypt — we still pass -k to
# tolerate the brief window while a per-host cert is being issued.
#
# The point of proof: the whoami API is gated by a default Hub JWT APIAuth — no
# token is rejected, a Keycloak-issued token is accepted.
set -uo pipefail

DOMAIN="${DOMAIN:-$(terraform output -raw domain 2>/dev/null || true)}"
: "${DOMAIN:?set DOMAIN=<your domain> (or run from the demo dir after apply so it can read the terraform output)}"
TOKEN="${TOKEN:-$(terraform output -raw developer_jwt 2>/dev/null || true)}"

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
curl_code_auth() { curl -sk -o /dev/null -w '%{http_code}' -H "Authorization: Bearer $TOKEN" "https://$1$2"; }
# Retry briefly while DNS propagates / certs are issued / routes settle.
wait_reachable() {
  for _ in $(seq 1 40); do
    case "$(curl_code "$1" "$2")" in
    000 | 404 | 502 | 503) sleep 5 ;;
    *) return 0 ;;
    esac
  done
  return 1
}

echo "== aks-demo scenarios (domain=$DOMAIN) =="

# 1+2. whoami is a managed API behind the default JWT APIAuth.
wait_reachable "whoami.$DOMAIN" "/" || true
code=$(curl_code "whoami.$DOMAIN" "/")
case "$code" in
401 | 403) ok "whoami without JWT -> $code (rejected)" ;;
*) bad "whoami without JWT -> $code (want 401/403)" ;;
esac

if [ -n "$TOKEN" ]; then
  code=$(curl_code_auth "whoami.$DOMAIN" "/")
  [ "$code" = "200" ] && ok "whoami with Keycloak JWT -> 200" || bad "whoami with Keycloak JWT -> $code (want 200)"
else
  bad "whoami with Keycloak JWT -> no TOKEN (set TOKEN=... or check 'terraform output developer_jwt')"
fi

# 3. API Portal — unauthenticated lands on the page or redirects to Keycloak.
code=$(curl_code "portal.$DOMAIN" "/")
case "$code" in
200 | 301 | 302) ok "portal -> $code (served / OIDC gate)" ;;
*) bad "portal -> $code (want 200/302)" ;;
esac

# 4. Keycloak UI reachable.
code=$(curl_code "keycloak.$DOMAIN" "/realms/traefik/.well-known/openid-configuration")
[ "$code" = "200" ] && ok "keycloak OIDC discovery -> 200" || bad "keycloak OIDC discovery -> $code (want 200)"

# 5. Grafana reachable (metrics + access logs via OTel).
code=$(curl_code "grafana.$DOMAIN" "/")
case "$code" in
200 | 301 | 302) ok "grafana -> $code" ;;
*) bad "grafana -> $code (want 200/302)" ;;
esac

# 6. Langfuse reachable (traces via OTel).
code=$(curl_code "langfuse.$DOMAIN" "/")
case "$code" in
200 | 301 | 302 | 307) ok "langfuse -> $code" ;;
*) bad "langfuse -> $code (want 200/302)" ;;
esac

echo "== $pass passed, $fail failed =="
[ "$fail" -eq 0 ]
