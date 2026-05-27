#!/bin/bash
set -euo pipefail

# Read input JSON from stdin
input=$(cat -)

# Parse JSON input
action=$(echo "$input" | jq -r '.action')
name=$(echo "$input" | jq -r '.name')
username=$(echo "$input" | jq -r '.username')
password=$(echo "$input" | jq -r '.password')
runpod_api_key=$(echo "$input" | jq -r '.runpod_api_key')

# Base URL for RunPod API
RUNPOD_API="https://rest.runpod.io/v1/containerregistryauth"

# Function to make API requests with error handling
runpod_api_request() {
  local method=$1
  local endpoint=$2
  local data=${3:-}
  
  local curl_cmd=(
    "curl" "-sS" "-X" "$method"
    "-H" "Authorization: Bearer $runpod_api_key"
    "-H" "Content-Type: application/json"
    "${RUNPOD_API}${endpoint}"
  )
  
  if [ -n "$data" ]; then
    curl_cmd+=("-d" "$data")
  fi
  
  # Execute the command and capture response and status
  local response
  response=$("${curl_cmd[@]}" 2>/dev/null || echo '{"error":"Failed to connect to RunPod API"}')
  local status=$?
  
  # Check for curl errors
  if [ $status -ne 0 ]; then
    echo "Error: Failed to connect to RunPod API" >&2
    exit 1
  fi
  
  # Check for API errors in response
  if echo "$response" | jq -e '.error' >/dev/null 2>&1; then
    local error_msg=$(echo "$response" | jq -r '.error')
    echo "API Error: $error_msg" >&2
    exit 1
  fi
  
  echo "$response"
  return 0
}

case "$action" in
  "create")
    # Initialize AUTH_ID
    AUTH_ID=""
    
    # Check if registry auth exists
    echo "Checking if registry auth '$name' exists..." >&2
    
    # First, try to list all registry auths
    AUTH_RESPONSE=$(runpod_api_request "GET" "")
    
    # Check if we got a valid response
    if [ -n "$AUTH_RESPONSE" ]; then
      # Check if the response is an array (expected format for list)
      if echo "$AUTH_RESPONSE" | jq -e 'if type=="array" then true else false end' >/dev/null 2>&1; then
        # Extract auth ID if exists
        AUTH_ID=$(echo "$AUTH_RESPONSE" | jq -r --arg n "$name" '.[] | select(.name==$n) | .id // empty' 2>/dev/null || true)
        
        if [ -n "$AUTH_ID" ]; then
          echo "Found existing registry auth with ID: $AUTH_ID" >&2
          action="found"
        fi
      fi
    else
      echo "Warning: Empty response from API" >&2
    fi
    
    # If auth doesn't exist, create it
    if [ -z "$AUTH_ID" ]; then
      # Create new registry auth
      echo "Creating new registry auth..." >&2
      create_data=$(jq -n --arg name "$name" --arg username "$username" --arg password "$password" \
        '{"name": $name, "username": $username, "password": $password}')
      
      echo "Sending create request with data: $create_data" >&2
      RESPONSE=$(runpod_api_request "POST" "" "$create_data")
      
      # Extract the ID from the response
      AUTH_ID=$(echo "$RESPONSE" | jq -r '.id // empty')
      
      if [ -z "$AUTH_ID" ] || [ "$AUTH_ID" = "null" ]; then
        echo "Failed to create registry auth: $RESPONSE" >&2
        exit 1
      fi
      
      echo "Created registry auth with ID: $AUTH_ID" >&2
      action="created"
    fi
    ;;

  "delete")
    # Find and delete registry auth by name
    echo "Deleting registry auth '$name'..." >&2
    
    # First, try to find the auth by name
    AUTH_RESPONSE=$(runpod_api_request "GET" "")
    
    # Check if we got a valid response
    if [ -n "$AUTH_RESPONSE" ]; then
      # Check if the response is an array (expected format for list)
      if echo "$AUTH_RESPONSE" | jq -e 'if type=="array" then true else false end' >/dev/null 2>&1; then
        # Extract auth ID if exists
        AUTH_ID=$(echo "$AUTH_RESPONSE" | jq -r --arg n "$name" '.[] | select(.name==$n) | .id // empty' 2>/dev/null || true)
        
        if [ -n "$AUTH_ID" ]; then
          echo "Found registry auth with ID: $AUTH_ID, deleting..." >&2
          DELETE_RESPONSE=$(runpod_api_request "DELETE" "/$AUTH_ID")
          echo "Delete Response: $DELETE_RESPONSE" >&2
        else
          echo "No registry auth found with name: $name" >&2
        fi
      else
        echo "Unexpected response format when listing registry auths: $AUTH_RESPONSE" >&2
      fi
    else
      echo "Warning: Empty response from API when trying to list registry auths" >&2
    fi
    
    AUTH_ID=""
    action="deleted"
    ;;

  *)
    echo "Unknown action: $action" >&2
    exit 1
    ;;
esac

# Output the result as JSON
jq -n --arg id "$AUTH_ID" --arg action "$action" '{"id":$id, "action":$action}'
