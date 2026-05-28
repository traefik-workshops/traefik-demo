# demos/ai-gateway-openai — Traefik AI Gateway over an OpenAI-compatible API.
#
#   make up         # k3d + Hub AI gateway + Presidio + Redis + guard chain
#   make scenarios  # curl the guard scenarios (pass without a real key)
#   make down       # tear down
#
# Prereqs: terraform, k3d, kubectl. A Traefik Hub token is required (AI gateway
# is licensed). An OpenAI key is optional — only the happy-path scenario uses it.

.DEFAULT_GOAL := help

.PHONY: help
help: ## Show this help.
	@grep -E '^[a-zA-Z0-9_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'

.PHONY: up
up: ## Stand up the cluster + gateway.
	terraform init
	terraform apply

.PHONY: scenarios
scenarios: ## Run the content-guard scenarios.
	./scenarios.sh

.PHONY: fmt
fmt: ## terraform fmt.
	terraform fmt -recursive

.PHONY: validate
validate: ## terraform validate (offline — modules are local relative paths).
	terraform init -backend=false
	terraform validate

.PHONY: down
down: ## Destroy the cluster.
	terraform destroy -auto-approve
