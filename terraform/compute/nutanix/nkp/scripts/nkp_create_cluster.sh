#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

source ~/variables.sh

echo "Creating NKP cluster ${CLUSTER_NAME}. This can take about 45 minutes depending on Internet connectivity"

# Construct flags
ARGS=(
    create cluster nutanix -c "$CLUSTER_NAME"
    --endpoint "https://$NUTANIX_ENDPOINT:$NUTANIX_PORT"
    --insecure
    --vm-image "$NUTANIX_MACHINE_TEMPLATE_IMAGE_NAME"
    --kubernetes-service-load-balancer-ip-range "$LB_IP_RANGE"
    --control-plane-endpoint-ip "$CONTROL_PLANE_ENDPOINT_IP"
    --control-plane-prism-element-cluster "$NUTANIX_PRISM_ELEMENT_CLUSTER_NAME"
    --control-plane-subnets "$NUTANIX_SUBNETS"
    --control-plane-replicas "$CP_REPLICAS"
    --worker-prism-element-cluster "$NUTANIX_PRISM_ELEMENT_CLUSTER_NAME"
    --worker-subnets "$NUTANIX_SUBNETS"
    --worker-replicas "$WORKER_REPLICAS"
    --csi-storage-container "$NUTANIX_STORAGE_CONTAINER_NAME"
    --self-managed
    --control-plane-memory "$((CP_MEM / 1024))"
    --control-plane-vcpus "$CP_CPU"
    --worker-memory "$((WORKER_MEM / 1024))"
    --worker-vcpus "$WORKER_CPU"
    --timeout 60m
)

if [ -n "${REGISTRY_MIRROR_URL:-}" ]; then
    CLEAN_MIRROR_URL="${REGISTRY_MIRROR_URL#http://}"
    CLEAN_MIRROR_URL="${CLEAN_MIRROR_URL#https://}"
    
    # Use the central registry mirror for the bootstrap image
    BOOTSTRAP_IMAGE="$CLEAN_MIRROR_URL/mesosphere/konvoy-bootstrap:v$NKP_VERSION"
    
    ARGS+=(--bootstrap-cluster-image "$BOOTSTRAP_IMAGE")
    ARGS+=(--registry-mirror-url "$REGISTRY_MIRROR_URL")
    ARGS+=(--skip-preflight-checks "Registry,NutanixCredentials")
fi

if [ -n "${KUBERNETES_VERSION:-}" ]; then
    ARGS+=(--kubernetes-version "$KUBERNETES_VERSION")
fi

if [ -n "${CLUSTER_HOSTNAMES:-}" ]; then
    IFS=',' read -ra HOSTNAMES <<< "$CLUSTER_HOSTNAMES"
    for hostname in "${HOSTNAMES[@]}"; do
        ARGS+=(--cluster-hostname "$hostname")
    done
fi

nkp "${ARGS[@]}"

# Make new cluster KUBECONFIG default
mkdir -p ~/.kube
cp "${CLUSTER_NAME}.conf" ~/.kube/config
chmod 600 ~/.kube/config
