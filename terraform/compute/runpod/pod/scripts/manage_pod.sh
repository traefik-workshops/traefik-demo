#!/bin/bash
set -euo pipefail

# Function to output a valid JSON response
json_response() {
    local status=$1
    local message=$2
    local data=${3:-{}}
    
    if [ "$status" = "error" ]; then
        jq -n --arg error "$message" '{error: $error}'
        exit 1
    else
        # Ensure all values are strings and create a simple key-value map
        jq -n --arg message "$message" --arg data "$data" '
        {
            "status": "success",
            "message": $message,
            "data": $data | fromjson
        }'
        exit 0
    fi
}

# Read input JSON from stdin
input=$(cat -)

echo "Input JSON: $input" >&2

# Parse JSON input
action=$(echo "$input" | jq -r '.action // "create"')
NAME=$(echo "$input" | jq -r '.name // empty')
IMAGE=$(echo "$input" | jq -r '.image // empty')
TAG=$(echo "$input" | jq -r '.tag // empty')
RUNPOD_API_KEY=$(echo "$input" | jq -r '.runpod_api_key // empty')
NGC_TOKEN=$(echo "$input" | jq -r '.ngc_token // empty')
POD_TYPE=$(echo "$input" | jq -r '.pod_type // empty')
REGISTRY_AUTH_ID=$(echo "$input" | jq -r '.registry_auth_id // empty')
COMMAND=$(echo "$input" | jq -r '.command // empty')
HF_TOKEN=$(echo "$input" | jq -r '.hugging_face_api_key // empty')

echo "Starting pod management script" >&2

# Verify required parameters
if [ -z "$NAME" ] || [ -z "$IMAGE" ] || [ -z "$TAG" ] || [ -z "$RUNPOD_API_KEY" ] || [ -z "$POD_TYPE" ]; then
    json_response "error" "Missing required parameters. Required: name, image, tag, runpod_api_key, pod_type"
fi

# Function to check if pod exists and get its info
check_existing_pod() {
    local pod_name="$1"
    echo "Checking for existing pod: $pod_name" >&2
    
    # Get all pods and filter by name
    if ! runpodctl_output=$(runpodctl get pod 2>/dev/null); then
        echo "Error running 'runpodctl get pod': $runpodctl_output" >&2
        return 1
    fi
    
    local pod_line
    pod_line=$(echo "$runpodctl_output" | awk -v name="$pod_name" '$2 == name' | head -n 1)
    
    if [ -n "$pod_line" ]; then
        echo "Found existing pod: $pod_line" >&2
        # Extract pod ID from the line (first column)
        local pod_id=$(echo "$pod_line" | awk '{print $1}')
        echo "Extracted pod ID: $pod_id" >&2
        
        # Create a simple pod info object
        jq -n --arg id "$pod_id" --arg name "$pod_name" --arg host "https://${pod_id}-8000.proxy.runpod.net/" '
        {
            "id": $id,
            "name": $name,
            "host": $host
        }'
        return 0
    else
        echo "No existing pod found with name: $pod_name" >&2
        return 1
    fi
}

# Check if pod already exists
echo "Checking if pod '$NAME' already exists..." >&2
existing_pod=""
if existing_pod=$(check_existing_pod "$NAME"); then
    echo "Pod '$NAME' already exists, using existing pod" >&2
    pod_info="$existing_pod"
else
    echo "No existing pod found, creating a new one..." >&2
    # Create new pod
    QUERY=$(cat <<EOF
    {
      "query": "mutation { podFindAndDeployOnDemand(input: { cloudType: ALL name: \"$NAME\" containerDiskInGb: 40 volumeInGb: 0 gpuCount: 1 gpuTypeId: \"$POD_TYPE\" imageName: \"$IMAGE:$TAG\" ports: \"8000/http\" containerRegistryAuthId: \"$REGISTRY_AUTH_ID\" env: [ { key: \"NGC_API_KEY\", value: \"$NGC_TOKEN\" }, { key: \"HF_TOKEN\", value: \"$HF_TOKEN\" } ] dockerArgs: \"$COMMAND\" }) { id name } }"
    }
EOF
    )

    echo "Creating pod '$NAME'..." >&2
    RESPONSE=$(curl -sS -X POST \
      -H "Content-Type: application/json" \
      -d "$QUERY" \
      "https://api.runpod.io/graphql?api_key=$RUNPOD_API_KEY")

    # Report the API response
    echo "Pod creation API response: $RESPONSE" >&2
    echo "Fetching pod info from runpodctl..." >&2
    
    # Wait a moment for the pod to be registered
    sleep 2
    
    # Fetch the actual pod info from runpodctl
    max_retries=5
    retry_count=0
    pod_info=""
    
    while [ $retry_count -lt $max_retries ]; do
        if pod_info=$(check_existing_pod "$NAME"); then
            echo "Successfully fetched pod info from runpodctl" >&2
            break
        fi
        
        retry_count=$((retry_count + 1))
        if [ $retry_count -lt $max_retries ]; then
            echo "Pod not yet visible in runpodctl, retrying in 2 seconds... (attempt $retry_count/$max_retries)" >&2
            sleep 2
        fi
    done
    
    if [ -z "$pod_info" ]; then
        echo "Failed to fetch pod info from runpodctl after $max_retries attempts" >&2
        json_response "error" "Pod created but failed to fetch info from runpodctl"
    fi
fi

# Output the pod info directly for Terraform external data source
jq -n --arg name "$NAME" --argjson pod_info "$pod_info" '
{
    "id": $pod_info.id,
    "name": $pod_info.name,
    "host": $pod_info.host
}'

exit 0
