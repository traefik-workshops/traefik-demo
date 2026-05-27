#!/bin/bash
set -e

# Configuration
BUNDLE_PATH="/opt/nkp/nkp-bundle.tar.gz"
REGISTRY_PORT="5000"
REGISTRY_DIR="/var/lib/registry"
MARKER_FILE="/var/lib/registry_populated"
LOG_FILE="/var/log/nkp_registry_setup.log"

exec > >(tee -a ${LOG_FILE}) 2>&1

echo "Starting NKP Registry Runtime Setup..."

# Check if already populated
if [ -f "$MARKER_FILE" ]; then
    echo "Registry already populated."
    exit 0
fi

# Ensure bundle exists
if [ ! -f "$BUNDLE_PATH" ]; then
    echo "ERROR: Bundle not found at $BUNDLE_PATH"
    exit 1
fi

BUNDLE_TAR="/opt/nkp/nkp-bundle.tar"

echo "Decompressing bundle..."
if command -v unpigz > /dev/null; then
    unpigz -c "$BUNDLE_PATH" > "$BUNDLE_TAR"
else
    gunzip -c "$BUNDLE_PATH" > "$BUNDLE_TAR"
fi

# Extract to temp directory
EXTRACT_DIR="/tmp/nkp-images-$$"
mkdir -p "$EXTRACT_DIR"
tar -xf "$BUNDLE_TAR" -C "$EXTRACT_DIR"

# Create registry directory if it doesn't exist
sudo mkdir -p "$REGISTRY_DIR"

echo "Populating registry storage from image bundles..."

# Stop registry container if running to prevent concurrent modification issues
if docker ps --format '{{.Names}}' | grep -q "^nkp-registry$"; then
    echo "Stopping registry container..."
    docker stop nkp-registry
fi

# Find all .tar files in the extracted bundle and merge them into the registry directory
find "$EXTRACT_DIR" -name "*.tar" -type f | while read img_tar; do
    # Check if this tar contains registry format data (docker/ directory)
    if tar -tf "$img_tar" 2>/dev/null | grep -q "^docker/"; then
        echo "Extracting registry data: $(basename "$img_tar")"
        # Extract the full docker/ directory structure into registry storage
        sudo tar -xf "$img_tar" -C "$REGISTRY_DIR" docker/
    fi
done

# Fix permissions (ensure the user inside the container can read/write)
# Standard registry image runs as root or 'registry' user. We'll ensure root owns it as per our docker run.
sudo chown -R root:root "$REGISTRY_DIR"

# Ensure Docker Registry is running
if ! docker ps --format '{{.Names}}' | grep -q "^nkp-registry$"; then
    # Check if container exists but stopped
    if docker ps -a --format '{{.Names}}' | grep -q "^nkp-registry$"; then
        echo "Starting existing registry container..."
        docker start nkp-registry
    else
        echo "Creating and starting local Docker registry container..."

        docker run -d \
            --name nkp-registry \
            --restart always \
            --pull never \
            -p ${REGISTRY_PORT}:5000 \
            -v ${REGISTRY_DIR}:/var/lib/registry \
            registry:2
    fi
fi

# Wait for registry to be healthy
echo "Waiting for registry to be ready..."
for i in {1..30}; do
    if curl -s http://localhost:${REGISTRY_PORT}/v2/ >/dev/null; then
        echo "Registry is ready!"
        break
    fi
    sleep 2
done

# Second pass: Load and push standard Docker images
find "$EXTRACT_DIR" -name "*.tar" -type f | while read img_tar; do
    # Skip if it was already processed as registry format
    if tar -tf "$img_tar" 2>/dev/null | grep -q "^docker/"; then
        continue
    else
        echo "Loading standard Docker image: $(basename "$img_tar")"
        # Load the image
        LOAD_OUTPUT=$(docker load -i "$img_tar")
        echo "$LOAD_OUTPUT"
        
        # Parse image name from output and push to local registry
        # Output format is typically: "Loaded image: repository:tag"
        echo "$LOAD_OUTPUT" | grep "Loaded image:" | cut -d' ' -f3 | while read loaded_image; do
            # Tag for local registry
            local_image="localhost:${REGISTRY_PORT}/${loaded_image}"
            echo "Pushing $loaded_image -> $local_image"
            docker tag "$loaded_image" "$local_image"
            docker push "$local_image"
        done
    fi
done

# Verify catalog is populated
CATALOG=$(curl -s http://localhost:${REGISTRY_PORT}/v2/_catalog)
echo "Registry catalog: $CATALOG"

# Mark complete
touch "$MARKER_FILE"
echo "Registry population complete."

# Cleanup temporary extraction directory
echo "Cleaning up temporary files in $EXTRACT_DIR..."
rm -rf "$EXTRACT_DIR"

exit 0
