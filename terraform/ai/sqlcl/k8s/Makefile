.PHONY: build push all clean setup

IMAGE_NAME := zalbiraw/sqlcl
TAG := latest
FULL_IMAGE := $(IMAGE_NAME):$(TAG)
PLATFORMS := linux/amd64,linux/arm64

all: setup push

setup:
	@echo "Setting up buildx builder..."
	@docker buildx create --name multiarch --use --driver docker-container 2>/dev/null || docker buildx use multiarch

build: setup
	@echo "Building Docker image for multiple platforms: $(FULL_IMAGE)"
	docker buildx build --platform $(PLATFORMS) -t $(FULL_IMAGE) --load .

push: setup
	@echo "Building and pushing Docker image for multiple platforms: $(FULL_IMAGE)"
	docker buildx build --platform $(PLATFORMS) -t $(FULL_IMAGE) --push .

clean:
	@echo "Removing local Docker image: $(FULL_IMAGE)"
	docker rmi $(FULL_IMAGE) || true
	@echo "Removing buildx builder..."
	docker buildx rm multiarch || true

help:
	@echo "Available targets:"
	@echo "  setup  - Set up buildx builder for multi-arch builds"
	@echo "  build  - Build the Docker image for multiple platforms (amd64, arm64)"
	@echo "  push   - Build and push the Docker image for multiple platforms"
	@echo "  all    - Setup and push (default)"
	@echo "  clean  - Remove local Docker image and buildx builder"
	@echo "  help   - Show this help message"
