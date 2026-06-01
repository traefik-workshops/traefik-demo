# demos/k3d-unified-ingress — multicluster Traefik Hub on k3d (transit + app).
#
#   make up         # stand up both k3d clusters (needs a Hub token)
#   make scenarios  # curl whoami through the transit cluster (cross-cluster route)
#   make down       # tear down both clusters
#
# Prereqs: terraform, k3d, kubectl + a Traefik Hub token (offline JWT).

.DEFAULT_GOAL := help

.PHONY: help
help: ## Show this help.
	@grep -E '^[a-zA-Z0-9_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'

.PHONY: up
up: ## Stand up both clusters + Hub (parent + child) + whoami.
	terraform init
	terraform apply

.PHONY: scenarios
scenarios: ## Curl whoami through the transit parent (proves cross-cluster routing).
	./scenarios.sh

.PHONY: fmt
fmt: ## terraform fmt.
	terraform fmt -recursive

.PHONY: validate
validate: ## terraform validate (offline — modules are local relative paths).
	terraform init -backend=false
	terraform validate

.PHONY: down
down: ## Destroy both clusters.
	terraform destroy -auto-approve
