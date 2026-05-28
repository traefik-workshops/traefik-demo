# demos/single-cluster — one k3d cluster + Traefik Hub + whoami.
#
#   make up         # stand it up (needs a Hub token in terraform.tfvars)
#   make scenarios  # curl the whoami route through Traefik
#   make down       # tear down
#
# Prereqs: terraform, k3d, kubectl + a Traefik Hub token (offline JWT).

.DEFAULT_GOAL := help

.PHONY: help
help: ## Show this help.
	@grep -E '^[a-zA-Z0-9_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'

.PHONY: up
up: ## Stand up the cluster + Hub + whoami.
	terraform init
	terraform apply

.PHONY: scenarios
scenarios: ## Curl the deployed route(s).
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
