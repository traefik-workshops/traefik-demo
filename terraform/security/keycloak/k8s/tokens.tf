locals {
  # Normalize simple users (email strings) into full user objects
  simple_users = [
    for email in var.users : {
      username = email
      email    = email
      password = "password"
      groups   = []
      claims   = {}
    }
  ]

  # Combine simple users and advanced users into a single list
  all_users = concat(local.simple_users, var.advanced_users)

  # Extract username/password pairs for token generation
  token_users = [
    for user in local.all_users : {
      username = user.username
      password = user.password
    }
  ]
}

# Ensure Keycloak is deployed before attempting to fetch tokens
resource "null_resource" "validate_keycloak_deployment" {
  triggers = {
    release_id = helm_release.keycloak.id
  }
}

# Fetch tokens using a Kubernetes Job - runs in-cluster and outputs JSON to logs
resource "kubernetes_job_v1" "fetch_tokens" {
  depends_on = [null_resource.validate_keycloak_deployment]

  metadata {
    name      = "fetch-keycloak-tokens"
    namespace = var.namespace
  }

  spec {
    template {
      metadata {
        labels = {
          app = "token-fetcher"
        }
      }
      spec {
        container {
          name    = "fetcher"
          image   = "badouralix/curl-jq"
          command = ["/bin/sh", "-c"]
          args = [
            <<-EOT
            set -e
            # Wait for internal DNS to resolve
            until getent hosts keycloak-service; do echo "waiting for dns..."; sleep 2; done
            
            USERS_JSON='${jsonencode(local.token_users)}'
            
            # Use jq to iterate and fetch tokens
            echo "$USERS_JSON" | jq -c '.[]' | while read -r user; do
              USERNAME=$(echo "$user" | jq -r '.username')
              PASSWORD=$(echo "$user" | jq -r '.password')
              
              TOKEN=$(curl -sk -X POST "http://keycloak-service:8080/realms/traefik/protocol/openid-connect/token" \
                -H "Content-Type: application/x-www-form-urlencoded" \
                -d "client_id=traefik" \
                -d "grant_type=password" \
                -d "client_secret=NoTgoLZpbrr5QvbNDIRIvmZOhe9wI0r0" \
                -d "scope=openid" \
                -d "username=$USERNAME" \
                -d "password=$PASSWORD" | jq -r '.access_token')
                
              if [ "$TOKEN" != "null" ] && [ -n "$TOKEN" ]; then
                # Safe JSON construction
                echo "{\"key\": \"$USERNAME\", \"value\": \"$TOKEN\"}"
              fi
            done | jq -n -c 'reduce inputs as $i ({}; .[$i.key] = $i.value)'
 EOT
          ]
        }
        restart_policy = "Never"
      }
    }
    backoff_limit = 4
  }

  lifecycle {
    replace_triggered_by = [
      null_resource.validate_keycloak_deployment
    ]
  }
}

# Capture tokens from Job logs
data "external" "capture_tokens" {
  depends_on = [kubernetes_job_v1.fetch_tokens]

  program = ["bash", "-c", <<-EOT
    set -e
    
    # Configure isolated kubectl context
    if [ -n "${var.host}" ]; then
      KUBECONFIG_FILE=$(mktemp)
      CERT_FILE=$(mktemp)
      KEY_FILE=$(mktemp)
      
      echo "${var.client_certificate}" > "$CERT_FILE"
      echo "${var.client_key}" > "$KEY_FILE"
      
      export KUBECONFIG="$KUBECONFIG_FILE"
      kubectl config set-cluster remote --server="${var.host}" --insecure-skip-tls-verify=true >/dev/null
      kubectl config set-credentials admin --client-certificate="$CERT_FILE" --client-key="$KEY_FILE" >/dev/null
      kubectl config set-context remote --cluster=remote --user=admin >/dev/null
      kubectl config use-context remote >/dev/null
      
      # Ensure cleanup on exit
      trap 'rm -f "$KUBECONFIG_FILE" "$CERT_FILE" "$KEY_FILE"' EXIT
    fi

    # Wait for job completion
    kubectl wait --for=condition=complete job/fetch-keycloak-tokens -n "${var.namespace}" --timeout=120s >&2
    
    # Fetch logs (find the line starting with { and ending with })
    kubectl logs job/fetch-keycloak-tokens -n "${var.namespace}" | grep '^{.*}$' | tail -n 1
  EOT
  ]
}

resource "kubernetes_secret_v1" "user_tokens" {
  metadata {
    name      = "traefik-user-tokens"
    namespace = var.namespace
  }

  data = data.external.capture_tokens.result

  type = "Opaque"

  lifecycle {
    ignore_changes = [data]
  }
}
