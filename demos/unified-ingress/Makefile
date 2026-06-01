# demos/unified-ingress — multi-cloud Traefik Hub mesh: EKS hub + EC2/ECS/AKS
# spokes joined over SPIFFE-mTLS Hub uplinks.
#
#   make up         # stand it up (needs AWS + Azure creds, a Hub token, a CF token)
#   make scenarios  # curl the deployed routes
#   make down       # tear down
#
# Prereqs: terraform, aws (configured), az (logged in), kubectl, a Traefik Hub
# token (offline JWT), and a Cloudflare API token for the demo domain's zone.
# CLOUD demo — CI only `terraform validate`s it; apply + scenarios run by hand.

.DEFAULT_GOAL := help

.PHONY: help
help: ## Show this help.
	@grep -E '^[a-zA-Z0-9_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

.PHONY: up
up: ## Stand up the EKS hub + spokes + the full mesh.
	terraform init
	terraform apply

.PHONY: scenarios
scenarios: ## Curl the deployed routes (see scenarios.sh).
	./scenarios.sh

.PHONY: fmt
fmt: ## terraform fmt.
	terraform fmt -recursive

.PHONY: validate
validate: ## terraform validate (offline — modules are local relative paths).
	terraform init -backend=false
	terraform validate

.PHONY: down
down: ## Destroy everything.
	terraform destroy -auto-approve
