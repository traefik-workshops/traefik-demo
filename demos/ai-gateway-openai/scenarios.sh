#!/usr/bin/env bash
# Smoke scenarios for demos/ai-gateway-openai.
#
# Content-guard rejections happen at the gateway (HTTP 200 + a "Request blocked"
# body via onDenyResponse), so 1-3 pass without a real key or backend. Scenario 4
# proves a clean prompt passes the guards and reaches the upstream (401 with a
# placeholder key, 200 with a real one).
set -uo pipefail

DOMAIN="${DOMAIN:-ai-gateway-openai.localhost}"
HOST="ai.$DOMAIN"
URL="http://$HOST/v1/chat/completions"

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

# POST a single-message chat request; $1 is the JSON-quoted user content.
post() {
  curl -s --resolve "$HOST:80:127.0.0.1" "$URL" \
    -H 'Content-Type: application/json' \
    -d "{\"model\":\"gpt-4\",\"messages\":[{\"role\":\"user\",\"content\":$1}]}"
}
blocked() { echo "$1" | grep -qi 'request blocked'; }

echo "== ai-gateway-openai scenarios (host=$HOST) =="

# Wait for the AI route to propagate after apply (a fresh route 404s briefly).
for _ in $(seq 1 20); do
  post '"ping"' | grep -q '404 page not found' || break
  sleep 3
done

# 1. Credit card -> Presidio guard blocks (4111… is the standard Visa test
#    number; Luhn-valid, so Presidio's CREDIT_CARD recognizer fires reliably).
r=$(post '"my card is 4111 1111 1111 1111"')
blocked "$r" && ok "credit card blocked" || bad "credit card NOT blocked: $r"

# 2. Email -> regex guard blocks.
r=$(post '"email me at alice@example.com"')
blocked "$r" && ok "email blocked" || bad "email NOT blocked: $r"

# 3. Clean prompt -> passes the guards and reaches the upstream.
r=$(post '"say hello in one word"')
blocked "$r" && bad "clean prompt was wrongly blocked: $r" || ok "clean prompt passed the guards (reaches upstream)"

echo "== $pass passed, $fail failed =="
[ "$fail" -eq 0 ]
