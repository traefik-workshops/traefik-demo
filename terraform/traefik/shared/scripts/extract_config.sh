#!/bin/bash
# =============================================================================
# extract_config.sh - Extract configuration from Helm template output
# =============================================================================
# Renders the Traefik Helm chart and extracts container config for VM deployments
# Receives values_yaml directly via stdin (from Terraform external data source)
# =============================================================================

set -euo pipefail

# Read input from stdin (Terraform external data source format)
INPUT=$(cat)

VALUES_YAML=$(echo "$INPUT" | jq -r '.values_yaml')
CHART_VERSION=$(echo "$INPUT" | jq -r '.chart_version' | sed 's/^v//')

# Ensure helm repo is added (suppress output)
helm repo add traefik https://traefik.github.io/charts >/dev/null 2>&1 || true
helm repo update traefik >/dev/null 2>&1 || true

# Create temp files
VALUES_FILE=$(mktemp)
RENDERED_FILE=$(mktemp)
trap "rm -f $VALUES_FILE $RENDERED_FILE" EXIT

# Write values to temp file
echo "$VALUES_YAML" > "$VALUES_FILE"

# Render the chart (redirect stderr to avoid plugin warnings in output)
helm template traefik traefik/traefik \
  --version "$CHART_VERSION" \
  --devel \
  -f "$VALUES_FILE" 2>/dev/null > "$RENDERED_FILE"

# Use yq with eval-all to handle multi-document YAML
# Extract container args from Deployment
CLI_ARGS=$(cat "$RENDERED_FILE" | yq eval-all -o=json '
  select(.kind == "Deployment" and .metadata.name == "traefik") |
  .spec.template.spec.containers[] |
  select(.name == "traefik") |
  .args // []
' 2>/dev/null | jq -c 'if type == "array" then . else [] end' 2>/dev/null || echo '[]')

# Extract container env from Deployment  
ENV_VARS=$(cat "$RENDERED_FILE" | yq eval-all -o=json '
  select(.kind == "Deployment" and .metadata.name == "traefik") |
  .spec.template.spec.containers[] |
  select(.name == "traefik") |
  .env // []
' 2>/dev/null | jq -c 'if type == "array" then . else [] end' 2>/dev/null || echo '[]')

# Extract volume mounts from Deployment
VOLUME_MOUNTS=$(cat "$RENDERED_FILE" | yq eval-all -o=json '
  select(.kind == "Deployment" and .metadata.name == "traefik") |
  .spec.template.spec.containers[] |
  select(.name == "traefik") |
  .volumeMounts // []
' 2>/dev/null | jq -c 'if type == "array" then . else [] end' 2>/dev/null || echo '[]')

# Extract volumes from Deployment
VOLUMES=$(cat "$RENDERED_FILE" | yq eval-all -o=json '
  select(.kind == "Deployment" and .metadata.name == "traefik") |
  .spec.template.spec.volumes // []
' 2>/dev/null | jq -c 'if type == "array" then . else [] end' 2>/dev/null || echo '[]')

# Extract static config from ConfigMap
STATIC_CONFIG=$(cat "$RENDERED_FILE" | yq eval-all '
  select(.kind == "ConfigMap" and .metadata.name == "traefik") |
  .data["traefik.yml"] // ""
' 2>/dev/null || echo "")

# Extract image from Deployment
IMAGE=$(cat "$RENDERED_FILE" | yq eval-all '
  select(.kind == "Deployment" and .metadata.name == "traefik") |
  .spec.template.spec.containers[] |
  select(.name == "traefik") |
  .image
' 2>/dev/null | head -1 || echo "traefik:latest")

# Output as JSON for Terraform external data source
# All values must be strings for external data source
jq -n \
  --arg cli_args "$CLI_ARGS" \
  --arg env_vars "$ENV_VARS" \
  --arg volume_mounts "$VOLUME_MOUNTS" \
  --arg volumes "$VOLUMES" \
  --arg static_config "$STATIC_CONFIG" \
  --arg image "$IMAGE" \
  '{
    cli_args: $cli_args,
    env_vars: $env_vars,
    volume_mounts: $volume_mounts,
    volumes: $volumes,
    static_config: $static_config,
    image: $image
  }'
