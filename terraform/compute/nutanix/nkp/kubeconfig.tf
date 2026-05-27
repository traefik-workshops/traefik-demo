# Fetch kubeconfig content directly into memory using external provider
data "external" "kubeconfig" {
  program = ["bash", "-c", <<EOT
    set -e

    validate_json() {
        python3 -c "import sys, json; print(json.dumps({'content': sys.stdin.read()}))"
    }

    # First, regenerate/update the kubeconfig on the bastion
    if ! sshpass -p '${var.bastion_vm_password}' ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
      -o ConnectTimeout=10 \
      ${var.bastion_vm_username}@${local.bastion_vm_ip} "nkp get kubeconfig --cluster-name ${var.cluster_name} > ~/${var.cluster_name}.conf" 2>/dev/null; then
       echo "Error: Failed to regenerate kubeconfig on bastion" >&2
       exit 1
    fi

    # Fetch kubeconfig content
    # Capture stderr to avoid polluting stdout which external provider expects to be JSON
    if ! raw_content=$(sshpass -p '${var.bastion_vm_password}' ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
      -o ConnectTimeout=10 \
      ${var.bastion_vm_username}@${local.bastion_vm_ip} "cat ~/${var.cluster_name}.conf" 2>/dev/null); then
      echo "Error: Failed to fetch kubeconfig via SSH" >&2
      exit 1
    fi

    if [ -z "$raw_content" ]; then
      echo "Error: Fetched kubeconfig is empty" >&2
      exit 1
    fi

    # Fetch Kommander Credentials
    pass=""
    user=""
    for i in {1..30}; do
      if raw_creds=$(sshpass -p '${var.bastion_vm_password}' ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
        -o ConnectTimeout=10 \
        ${var.bastion_vm_username}@${local.bastion_vm_ip} \
        "export KUBECONFIG=~/${var.cluster_name}.conf; kubectl get secret -n kommander dkp-credentials -o jsonpath='{.data.username} {.data.password}' 2>/dev/null" 2>/dev/null); then
        
        if [ -n "$raw_creds" ]; then
             raw_user=$(echo "$raw_creds" | awk '{print $1}')
             raw_pass=$(echo "$raw_creds" | awk '{print $2}')
             
             if [ -n "$raw_user" ] && [ -n "$raw_pass" ]; then
                user=$(echo "$raw_user" | base64 -d)
                pass=$(echo "$raw_pass" | base64 -d)
                break
             fi
        fi
      fi
      sleep 10
    done

    # Replace VIP with FIP and set insecure-skip-tls-verify
    # We use python for safer JSON encoding of the multiline string
    python3 -c '
import sys, json, re

raw = sys.argv[1]
password = sys.argv[2]
username = sys.argv[3]
control_plane_vip = "${var.control_plane_vip}"
control_plane_fip = "${local.control_plane_fip}"

# Replace VIP
if control_plane_vip and control_plane_fip:
    content = raw.replace(control_plane_vip, control_plane_fip)
else:
    content = raw

# Replace CA data with insecure skip
content = re.sub(r"certificate-authority-data:.*", "insecure-skip-tls-verify: true", content)

print(json.dumps({"content": content, "password": password, "username": username}))
' "$raw_content" "$pass" "$user"
  EOT
  ]

  depends_on = [null_resource.nkp_create_cluster]
}

# Update local kubeconfig with cluster context
resource "null_resource" "update_kubeconfig" {
  count = var.update_kubeconfig ? 1 : 0

  triggers = {
    # Trigger update if content changes or if cluster is recreated
    kubeconfig_hash = sha256(data.external.kubeconfig.result["content"])
    cluster_id      = null_resource.nkp_create_cluster.id
    # Run every time as requested
    run_always = timestamp()
  }

  provisioner "local-exec" {
    command = <<EOT
      set -e
      
      LOCKFILE="/tmp/kubeconfig.lock"
      TEMP_KUBECONFIG="/tmp/${var.cluster_name}.conf"
      MERGED_KUBECONFIG="/tmp/${var.cluster_name}_merged.yaml"
      
      # Atomic Lock using mkdir
      count=0
      while ! mkdir "$LOCKFILE" 2>/dev/null; do
        if [ $count -ge 30 ]; then
            echo "Timeout waiting for lock $LOCKFILE" >&2
            exit 1
        fi
        echo "Waiting for kubeconfig lock..."
        sleep 1
        count=$((count+1))
      done

      # Trap to ensure lock is released even on failure
      cleanup() {
        rm -f "$TEMP_KUBECONFIG" "$MERGED_KUBECONFIG"
        rmdir "$LOCKFILE" 2>/dev/null || true
      }
      trap cleanup EXIT

      echo '${data.external.kubeconfig.result["content"]}' > "$TEMP_KUBECONFIG"
      
      # Validate the generated kubeconfig
      if ! kubectl --kubeconfig="$TEMP_KUBECONFIG" config view >/dev/null 2>&1; then
          echo "Error: Generated kubeconfig is invalid" >&2
          exit 1
      fi

      # Get the Original Context Name from the temp file
      ORIG_CONTEXT=$(kubectl --kubeconfig="$TEMP_KUBECONFIG" config current-context)
      
      # Get the User Name associated with the context
      ORIG_USER=$(kubectl --kubeconfig="$TEMP_KUBECONFIG" config view -o jsonpath="{.contexts[?(@.name==\"$ORIG_CONTEXT\")].context.user}")

      if [ -z "$ORIG_CONTEXT" ]; then
          echo "Error: Could not determine current context from kubeconfig" >&2
          exit 1
      fi

      # Rename context in the temp file to desired name
      kubectl --kubeconfig="$TEMP_KUBECONFIG" config rename-context \
        "$ORIG_CONTEXT" \
        "${var.cluster_name}"

      # Aggressive cleanup of BOTH target name and original source name from local config
      # We ignore errors here in case they don't exist
      kubectl config delete-context "${var.cluster_name}" 2>/dev/null || true
      kubectl config delete-context "$ORIG_CONTEXT" 2>/dev/null || true
      
      kubectl config delete-cluster "${var.cluster_name}" 2>/dev/null || true
      
      # Delete the user if we found one
      if [ -n "$ORIG_USER" ]; then
          kubectl config delete-user "$ORIG_USER" 2>/dev/null || true
      fi
      # Also delete generic user name just in case
      kubectl config delete-user "${var.cluster_name}" 2>/dev/null || true
      
      # Merge - PUT NEW CONFIG FIRST so it takes precedence for conflicts
      export KUBECONFIG="$TEMP_KUBECONFIG":~/.kube/config
      kubectl config view --flatten > "$MERGED_KUBECONFIG"
      mv "$MERGED_KUBECONFIG" ~/.kube/config
      chmod 600 ~/.kube/config

      echo "Kubeconfig updated for ${var.cluster_name}."
    EOT
  }
}
