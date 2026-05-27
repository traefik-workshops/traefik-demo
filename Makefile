VERSION := $(shell git tag --list 'v*' | sort -V | tail -n1 2>/dev/null || echo "v0.0.0")

.PHONY: bump_major bump_minor bump_patch release preflight fmt-check fmt validate lint

##
## Validation
##

# Fast format check across all modules — no init needed
fmt-check:
	@echo "==> terraform fmt check"
	@terraform fmt -check -recursive . && echo "✅ All files formatted" || (echo "❌ Run 'make fmt' to fix" && exit 1)

# Auto-fix formatting
fmt:
	@echo "==> terraform fmt (auto-fix)"
	@terraform fmt -recursive .
	@echo "✅ Done"

# Deep validate a single module. Usage: make validate MODULE=compute/azure/aks
validate:
ifndef MODULE
	$(error MODULE is required. Usage: make validate MODULE=compute/azure/aks)
endif
	@echo "==> terraform validate: $(MODULE)"
	@cd $(MODULE) && \
		terraform init -backend=false -input=false -upgrade=false > /dev/null && \
		terraform validate && \
		echo "✅ $(MODULE): valid" || \
		(echo "❌ $(MODULE): FAILED" && exit 1)

# Lint all modules with tflint (catches invalid cloud values, deprecated args)
# Requires tflint: https://github.com/terraform-linters/tflint
lint:
	@echo "==> tflint"
	@tflint --recursive && echo "✅ tflint passed" || (echo "❌ tflint found issues" && exit 1)

# Tier 1 preflight: format check + lint (fast, no cloud creds needed)
# For deep validate, run: make validate MODULE=<path>
preflight: fmt-check lint
	@echo ""
	@echo "Tier 1 complete. To validate a specific module:"
	@echo "  make validate MODULE=compute/azure/aks"

# Helper to bump version
# Usage: make bump_part PART=major|minor|patch
bump_part:
	@current_tag=$$(git tag --list 'v*' | sort -V | tail -n1 2>/dev/null || echo "v0.0.0"); \
	version_num=$${current_tag#v}; \
	IFS='.' read -r major minor patch <<< "$$version_num"; \
	if [ "$(PART)" = "major" ]; then \
		major=$$((major + 1)); minor=0; patch=0; \
	elif [ "$(PART)" = "minor" ]; then \
		minor=$$((minor + 1)); patch=0; \
	elif [ "$(PART)" = "patch" ]; then \
		patch=$$((patch + 1)); \
	fi; \
	new_tag="v$$major.$$minor.$$patch"; \
	echo "Bumping $$current_tag -> $$new_tag"; \
	git tag $$new_tag; \
	echo "Tag $$new_tag created. Run 'make release' to push."

bump_major:
	$(MAKE) bump_part PART=major

bump_minor:
	$(MAKE) bump_part PART=minor

bump_patch:
	$(MAKE) bump_part PART=patch

release:
	@echo "Pushing git tags..."
	git push origin --tags
