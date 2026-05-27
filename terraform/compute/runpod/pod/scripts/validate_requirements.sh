#!/bin/bash
set -euo pipefail

# Function to output JSON response
json_response() {
    local status=$1
    local message=$2
    
    if [ "$status" = "error" ]; then
        jq -n --arg error "$message" '{error: $error}'
        exit 1
    else
        jq -n --arg message "$message" '{status: "success", message: $message}'
        exit 0
    fi
}

# Check for jq
if ! command -v jq &> /dev/null; then
    json_response "error" "jq is not installed. Please install jq: brew install jq"
fi

# Check for envsubst
if ! command -v envsubst &> /dev/null; then
    json_response "error" "envsubst is not installed. Please install gettext: brew install gettext"
fi

# Check for runpodctl
if ! command -v runpodctl &> /dev/null; then
    json_response "error" "runpodctl is not installed. Please install runpodctl: https://github.com/runpod/runpodctl"
fi

# Check if runpodctl is authorized by attempting to get pods
if ! runpodctl get pod &> /dev/null; then
    json_response "error" "runpodctl is not authorized. Please run: runpodctl config --apiKey YOUR_API_KEY"
fi

# All checks passed
json_response "success" "All required tools are installed and configured"
