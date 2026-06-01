#!/usr/bin/env bash
# Smoke scenarios for demos/unified-ingress (multi-cloud Traefik Hub mesh).
#
# Cloud demo — CI does NOT run this; run by hand against a real deploy. Domain +
# a developer JWT are read from terraform outputs; override DOMAIN / TOKEN to
# point elsewhere. Hostnames resolve via real DNS (dns-traefiker), certs via
# Let's Encrypt — we pass -k to tolerate the brief per-host cert-issuing window.
#
# Each scenario maps to a row in the README "Expected results" table.
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
post_ai() { # POST a chat-completion prompt; echo the response body
  curl -sk -X POST "https://ai.$DOMAIN/v1/chat/completions" \
    -H 'Content-Type: application/json' \
    -d "{\"model\":\"gpt-4o-mini\",\"messages\":[{\"role\":\"user\",\"content\":\"$1\"}]}"
}
wait_reachable() {
  for _ in $(seq 1 40); do
    case "$(curl_code "$1" "$2")" in
    000 | 404 | 502 | 503) sleep 5 ;;
    *) return 0 ;;
    esac
  done
  return 1
}

echo "== unified-ingress scenarios (domain=$DOMAIN) =="

# UC1 — EKS hub + NGINX migration --------------------------------------------
# whoami on the hub is a managed API behind the default JWT APIAuth.
wait_reachable "whoami.$DOMAIN" "/" || true
code=$(curl_code "whoami.$DOMAIN" "/")
case "$code" in
401 | 403) ok "hub whoami without JWT -> $code (rejected)" ;;
*) bad "hub whoami without JWT -> $code (want 401/403)" ;;
esac
if [ -n "$TOKEN" ]; then
  code=$(curl_code_auth "whoami.$DOMAIN" "/")
  [ "$code" = "200" ] && ok "hub whoami with Keycloak JWT -> 200" || bad "hub whoami with JWT -> $code (want 200)"
else
  bad "hub whoami with JWT -> no TOKEN (set TOKEN=... or check 'terraform output developer_jwt')"
fi

code=$(curl_code "legacy.$DOMAIN" "/")
[ "$code" = "200" ] && ok "nginx-provider migration (legacy Ingress via Traefik) -> 200" || bad "legacy nginx Ingress -> $code (want 200)"

# UC2 — spokes through the unified ingress -----------------------------------
for spoke in aks ec2 ecs; do
  wait_reachable "$spoke.$DOMAIN" "/" || true
  code=$(curl_code "$spoke.$DOMAIN" "/")
  [ "$code" = "200" ] && ok "$spoke spoke via uplink -> 200" || bad "$spoke spoke ($spoke.$DOMAIN) -> $code (want 200)"
done

# UC2 — WAF, mirroring, failover ---------------------------------------------
code=$(curl_code "waf.$DOMAIN" "/?id=1%27%20OR%20%271%27=%271")
[ "$code" = "403" ] && ok "WAF blocks SQLi -> 403" || bad "WAF SQLi -> $code (want 403)"
code=$(curl_code "waf.$DOMAIN" "/")
[ "$code" = "200" ] && ok "WAF allows benign -> 200" || bad "WAF benign -> $code (want 200)"

code=$(curl_code "mirror.$DOMAIN" "/")
[ "$code" = "200" ] && ok "mirrored route -> 200 (shadow receipt: check the shadow whoami access log)" || bad "mirror -> $code (want 200)"

code=$(curl_code "failover.$DOMAIN" "/")
[ "$code" = "200" ] && ok "failover route -> 200 (force failover: scale the AKS leg to 0, expect still 200)" || bad "failover -> $code (want 200)"

# UC2 — APIM portal -----------------------------------------------------------
code=$(curl_code "portal.$DOMAIN" "/")
case "$code" in
200 | 301 | 302) ok "API portal -> $code (served / OIDC gate)" ;;
*) bad "portal -> $code (want 200/302)" ;;
esac
code=$(curl_code "keycloak.$DOMAIN" "/realms/traefik/.well-known/openid-configuration")
[ "$code" = "200" ] && ok "keycloak OIDC discovery -> 200" || bad "keycloak OIDC discovery -> $code (want 200)"

# UC3 — AI + MCP gateway (on AKS) --------------------------------------------
wait_reachable "ai.$DOMAIN" "/v1/chat/completions" || true
if post_ai "my card is 4111 1111 1111 1111" | grep -qi "blocked"; then
  ok "AI guardrail blocks a credit card (Presidio) -> request blocked"
else
  bad "AI guardrail credit card -> not blocked (want 'Request blocked')"
fi
if post_ai "email me at jane@example.com" | grep -qi "blocked"; then
  ok "AI guardrail blocks an email (regex) -> request blocked"
else
  bad "AI guardrail email -> not blocked (want 'Request blocked')"
fi

code=$(curl_code "mcp.$DOMAIN" "/")
case "$code" in
200 | 301 | 302) ok "MCP inspector -> $code" ;;
*) bad "mcp -> $code (want 200/302)" ;;
esac

# UC5 — observability ---------------------------------------------------------
for host in grafana langfuse; do
  code=$(curl_code "$host.$DOMAIN" "/")
  case "$code" in
  200 | 301 | 302 | 307) ok "$host -> $code" ;;
  *) bad "$host -> $code (want 200/302)" ;;
  esac
done

echo "== $pass passed, $fail failed =="
[ "$fail" -eq 0 ]
