# demos/hub-from-source — run Traefik Hub from local source on k3d.
#
#   make up         # released Hub image (needs a Hub token in terraform.tfvars)
#   make up-dev     # build Hub from source -> push to local registry -> apply
#   make scenarios  # assert ingress works AND the running image is the one expected
#   make down       # tear everything down
#
# Prereqs: terraform, k3d, kubectl, docker. For `up-dev` also a traefik-hub
# source checkout (TRAEFIK_HUB_SRC) — that source is private and NOT bundled here.

CLUSTER            ?= hub-from-source
REGISTRY_NAME      ?= hub-from-source-registry          # container becomes k3d-$(REGISTRY_NAME)
REGISTRY_PORT      ?= 5001
TRAEFIK_HUB_SRC    ?= ../../../traefik-hub               # your local Hub checkout
HUB_BUILD_TARGET   ?= dev-image                          # image target in the Hub repo's Makefile
HUB_BUILD_REGISTRY ?= localhost:$(REGISTRY_PORT)/traefik # DOCKER_REGISTRY passed to the Hub build
HUB_IMAGE          ?= localhost:$(REGISTRY_PORT)/traefik/traefik-hub:dev

.DEFAULT_GOAL := help

.PHONY: help
help: ## Show this help.
	@grep -E '^[a-zA-Z0-9_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

.PHONY: up
up: ## Apply with the released Hub image (no source build needed).
	terraform init
	terraform apply

.PHONY: registry
registry: ## Create the local k3d registry (idempotent).
	@if docker ps -a --format '{{.Names}}' | grep -qx "k3d-$(REGISTRY_NAME)"; then \
		echo "registry k3d-$(REGISTRY_NAME) already exists"; \
	else \
		k3d registry create $(REGISTRY_NAME) --port 0.0.0.0:$(REGISTRY_PORT); \
	fi

.PHONY: build-hub
build-hub: registry ## Build Hub from TRAEFIK_HUB_SRC and push to the local registry as :dev.
	@test -d "$(TRAEFIK_HUB_SRC)" || { echo "TRAEFIK_HUB_SRC=$(TRAEFIK_HUB_SRC) not found — point it at your traefik-hub checkout"; exit 1; }
	$(MAKE) -C $(TRAEFIK_HUB_SRC) $(HUB_BUILD_TARGET) DOCKER_REGISTRY=$(HUB_BUILD_REGISTRY)
	docker push $(HUB_IMAGE)

.PHONY: up-dev
up-dev: registry build-hub ## Build Hub from source, then apply with the :dev image.
	terraform init
	terraform apply -var=local_traefik_hub=true

.PHONY: scenarios
scenarios: ## Run the smoke scenarios (curl + running-image assertion).
	./scenarios.sh

.PHONY: fmt
fmt: ## terraform fmt.
	terraform fmt -recursive

.PHONY: validate
validate: ## terraform validate (offline — modules are local relative paths).
	terraform init -backend=false
	terraform validate

.PHONY: down
down: ## Destroy the cluster and delete the local registry.
	-terraform destroy -auto-approve
	-k3d registry delete k3d-$(REGISTRY_NAME)
