# demos/aks-demo — Traefik Hub APIM on AKS: Keycloak JWT + SSO portal, Grafana
# (via OTel) + Langfuse.
#
#   make up         # stand it up (needs az login + a Hub token + a CF token)
#   make scenarios  # curl the whoami JWT gate + portal/keycloak/grafana/langfuse
#   make down       # tear down
#
# Prereqs: terraform, az (logged in), kubectl, a Traefik Hub token (offline JWT),
# and a Cloudflare API token for the demo domain's zone. This is a CLOUD demo —
# CI only `terraform validate`s it; apply + scenarios are run by hand.

.DEFAULT_GOAL := help

.PHONY: help
help: ## Show this help.
	@grep -E '^[a-zA-Z0-9_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'

.PHONY: up
up: ## Stand up AKS + Hub + Keycloak + observability + the whoami API.
	terraform init
	terraform apply

.PHONY: scenarios
scenarios: ## Curl the deployed routes (whoami JWT gate, portal, keycloak, grafana, langfuse).
	./scenarios.sh

.PHONY: fmt
fmt: ## terraform fmt.
	terraform fmt -recursive

.PHONY: validate
validate: ## terraform validate (offline — modules are local relative paths).
	terraform init -backend=false
	terraform validate

.PHONY: down
down: ## Destroy the cluster + resource group.
	terraform destroy -auto-approve
