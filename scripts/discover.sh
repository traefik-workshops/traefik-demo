#!/usr/bin/env bash
# Emit a JSON inventory of every leaf Terraform module + Helm chart in this repo.
#
# Shape:
#   {
#     "modules": [
#       { "path": "terraform/...", "required_inputs": [...], "sensitive_outputs": [...] },
#       ...
#     ],
#     "charts": [
#       { "path": "helm/<name>", "required_values": [...], "dependencies": [...] },
#       ...
#     ]
#   }
#
# Live-derived, never committed. Run via `make discover` from the repo root.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

exec python3 "$ROOT/scripts/discover.py"
