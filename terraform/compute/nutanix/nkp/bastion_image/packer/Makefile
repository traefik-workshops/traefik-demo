.PHONY: build-binaries packer-build-arm64 packer-build-amd64 all clean

BIN_DIR := bin

# Architecture definitions for Go and Packer
# We map simple arch names to Go/Packer conventions
#   amd64 -> GOARCH=amd64, PACKER_VAR_arch=amd64
#   arm64 -> GOARCH=arm64, PACKER_VAR_arch=arm64

build-binaries:
	mkdir -p $(BIN_DIR)/amd64 $(BIN_DIR)/arm64
	@echo "Please ensure nkp binaries are placed in $(BIN_DIR)/amd64/nkp and $(BIN_DIR)/arm64/nkp"

packer-build-arm64: build-binaries
	packer init .
	packer build -var 'arch=arm64' .

packer-build-amd64: build-binaries
	packer init .
	packer build -var 'arch=amd64' .

all: packer-build-arm64 packer-build-amd64

clean:
	rm -rf $(BIN_DIR) images
