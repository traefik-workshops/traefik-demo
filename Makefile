# Master Makefile — traefik-demo.
#
# Single Makefile for both halves of the repo (Terraform modules + Helm charts).
# Run `make help` for the full target list.
#
# Three groups of targets:
#   1. Quality:  terraform fmt/validate/lint/security + helm lint/template + ct lint
#   2. Helm:     dep-update, package, push, helm-test (ct install on kind)
#   3. Release:  release-bug, release-feature, release-major
#                  - sweep helm/*/Chart.yaml `version:` (and in-repo `file://` dep versions)
#                  - sweep terraform leaf README `?ref=v...` example lines
#                  - run `helm dep update` on every chart with deps (regenerates Chart.lock)
#                  - commit the sweep, tag, push
#                CI picks up the tag and publishes every chart to OCI.

SHELL := /bin/bash
.ONESHELL:
.DEFAULT_GOAL := help

# Last semver tag in the repo (or v0.0.0 if none exists).
CURRENT_TAG := $(shell git tag --list 'v*' | sort -V | tail -n1 2>/dev/null)
ifeq ($(CURRENT_TAG),)
CURRENT_TAG := v0.0.0
endif

# Branch name. Release targets require this to be `main`.
BRANCH := $(shell git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")

# Find every leaf Terraform module (directory containing .tf files directly).
# Scoped to terraform/ — the rest of the tree (helm/, .claude/) has no .tf files.
LEAF_MODULES := $(shell find terraform -name '*.tf' -not -path '*/.terraform/*' -exec dirname {} \; 2>/dev/null | sort -u)

# Find every leaf Helm chart (directory containing Chart.yaml directly under helm/).
HELM_CHARTS := $(shell find helm -name Chart.yaml -maxdepth 2 2>/dev/null | xargs -n1 dirname | sort -u)

# OCI registry for chart publishing.
OCI_REGISTRY ?= oci://ghcr.io/traefik-workshops

# Color helpers (no-op if stdout isn't a tty).
ifneq ($(shell test -t 1 && echo tty),)
BOLD := $(shell tput bold 2>/dev/null)
DIM := $(shell tput dim 2>/dev/null)
RED := $(shell tput setaf 1 2>/dev/null)
GREEN := $(shell tput setaf 2 2>/dev/null)
YELLOW := $(shell tput setaf 3 2>/dev/null)
RESET := $(shell tput sgr0 2>/dev/null)
endif

.PHONY: help
help: ## Show this help.
	@echo "$(BOLD)traefik-demo$(RESET) — current tag: $(YELLOW)$(CURRENT_TAG)$(RESET)"
	@echo
	@echo "$(BOLD)Terraform quality:$(RESET)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-z][a-zA-Z_-]+:.*?## TF: / {printf "  $(GREEN)%-22s$(RESET) %s\n", $$1, substr($$2, 5)}' $(MAKEFILE_LIST)
	@echo
	@echo "$(BOLD)Helm quality + publish:$(RESET)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-z][a-zA-Z_-]+:.*?## H: / {printf "  $(GREEN)%-22s$(RESET) %s\n", $$1, substr($$2, 4)}' $(MAKEFILE_LIST)
	@echo
	@echo "$(BOLD)Cross-cutting:$(RESET)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-z][a-zA-Z_-]+:.*?## X: / {printf "  $(GREEN)%-22s$(RESET) %s\n", $$1, substr($$2, 4)}' $(MAKEFILE_LIST)
	@echo
	@echo "$(BOLD)Release:$(RESET)"
	@awk 'BEGIN {FS = ":.*?## "} /^release[a-z-]+:.*?## / {printf "  $(GREEN)%-22s$(RESET) %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo

# ============================================================================
# 1. Terraform quality targets
# ============================================================================

.PHONY: tf-fmt
tf-fmt: ## TF: Format all .tf files (terraform fmt -recursive).
	@echo "$(BOLD)terraform fmt -recursive$(RESET)"
	@terraform fmt -recursive

.PHONY: tf-fmt-check
tf-fmt-check: ## TF: Check formatting (CI mode).
	@echo "$(BOLD)terraform fmt -check$(RESET)"
	@terraform fmt -recursive -check -diff

.PHONY: tf-validate
tf-validate: ## TF: terraform validate every leaf module (or one via MODULE=<path>).
	@set -euo pipefail
	@if [ -n "$(MODULE)" ]; then mods="$(MODULE)"; else mods="$(LEAF_MODULES)"; fi; \
	fail=0; \
	for d in $$mods; do \
		echo "$(DIM)validate $$d$(RESET)"; \
		( cd "$$d" && terraform init -backend=false -input=false -no-color > /dev/null && terraform validate -no-color ) || fail=1; \
	done; \
	if [ "$$fail" -eq 0 ]; then echo "$(GREEN)tf-validate: ok$(RESET)"; else echo "$(RED)tf-validate: failed$(RESET)"; exit 1; fi

.PHONY: tf-lint
tf-lint: ## TF: tflint --recursive across the repo.
	@echo "$(BOLD)tflint --recursive$(RESET)"
	@if ! command -v tflint > /dev/null; then echo "$(RED)tflint not installed.$(RESET) See https://github.com/terraform-linters/tflint#installation"; exit 1; fi
	@tflint --init > /dev/null
	@tflint --recursive --config "$$PWD/.tflint.hcl"

.PHONY: tf-security
tf-security: ## TF: tfsec security scan.
	@echo "$(BOLD)tfsec$(RESET)"
	@if ! command -v tfsec > /dev/null; then echo "$(RED)tfsec not installed.$(RESET) See https://github.com/aquasecurity/tfsec#installation"; exit 1; fi
	@tfsec --config-file .tfsec.yml .

# ============================================================================
# 2. Helm quality + publish targets
# ============================================================================

.PHONY: helm-lint
helm-lint: ## H: helm lint --strict every chart (uses values.schema.json).
	@set -euo pipefail
	@fail=0
	@for c in $(HELM_CHARTS); do \
		echo "$(DIM)helm lint $$c$(RESET)"; \
		helm lint --strict "$$c" || fail=1; \
	done
	@if [ "$$fail" -eq 0 ]; then echo "$(GREEN)helm-lint: ok$(RESET)"; else echo "$(RED)helm-lint: failed$(RESET)"; exit 1; fi

.PHONY: helm-template
helm-template: ## H: helm template every chart, pipe to kubeconform.
	@set -euo pipefail
	@if ! command -v kubeconform > /dev/null; then echo "$(YELLOW)warn:$(RESET) kubeconform not installed — skipping manifest validation"; exit 0; fi
	@fail=0
	@for c in $(HELM_CHARTS); do \
		echo "$(DIM)template $$c$(RESET)"; \
		helm template release-name "$$c" 2>/dev/null | kubeconform -strict -summary -skip CustomResourceDefinition,IngressRoute,Middleware,ServersTransport,Keycloak,KeycloakRealmImport || fail=1; \
	done
	@if [ "$$fail" -eq 0 ]; then echo "$(GREEN)helm-template: ok$(RESET)"; else echo "$(RED)helm-template: failed$(RESET)"; exit 1; fi

.PHONY: helm-test
helm-test: ## H: ct lint --all (chart-testing).
	@if ! command -v ct > /dev/null; then echo "$(RED)ct not installed.$(RESET) See https://github.com/helm/chart-testing"; exit 1; fi
	@ct lint --config helm/ct.yaml --all

.PHONY: helm-deps
helm-deps: ## H: helm dep update on every chart with dependencies (regenerates Chart.lock).
	@set -euo pipefail
	@for c in $(HELM_CHARTS); do \
		if grep -q '^dependencies:' "$$c/Chart.yaml" 2>/dev/null; then \
			echo "$(DIM)helm dep update $$c$(RESET)"; \
			helm dep update "$$c" > /dev/null; \
		fi; \
	done
	@echo "$(GREEN)helm-deps: ok$(RESET)"

.PHONY: helm-package
helm-package: helm-deps ## H: helm package every chart at the current repo version into dist/.
	@set -euo pipefail
	@version="$${CURRENT_TAG#v}"
	@if [ -z "$$version" ] || [ "$$version" = "v0.0.0" ]; then echo "$(RED)error:$(RESET) no tag yet — cut a release first"; exit 1; fi
	@mkdir -p dist
	@rm -f dist/*.tgz
	@for c in $(HELM_CHARTS); do \
		echo "$(DIM)package $$c at $$version$(RESET)"; \
		helm package "$$c" --version "$$version" --destination dist > /dev/null; \
	done
	@echo "$(GREEN)helm-package: ok$(RESET)  (artifacts in dist/)"
	@ls dist/

.PHONY: helm-push
helm-push: ## H: push every dist/*.tgz to $(OCI_REGISTRY). Requires `helm registry login`.
	@set -euo pipefail
	@if [ ! -d dist ] || [ -z "$$(ls dist/*.tgz 2>/dev/null)" ]; then echo "$(RED)error:$(RESET) no packages in dist/ — run \`make helm-package\` first"; exit 1; fi
	@for pkg in dist/*.tgz; do \
		echo "$(DIM)push $$pkg -> $(OCI_REGISTRY)$(RESET)"; \
		helm push "$$pkg" "$(OCI_REGISTRY)"; \
	done
	@echo "$(GREEN)helm-push: ok$(RESET)"

# ============================================================================
# 3. Cross-cutting (everything)
# ============================================================================

.PHONY: check
check: tf-fmt-check tf-validate tf-lint tf-security helm-lint helm-template helm-test ## X: Run every quality check (CI).

.PHONY: fmt
fmt: tf-fmt ## X: Run all formatters.

.PHONY: discover
discover: ## X: Emit JSON inventory of every leaf TF module + Helm chart (stdout). Agent's first read.
	@scripts/discover.sh

# ============================================================================
# 4. Release machinery
# ============================================================================

.PHONY: release-bug
release-bug: ## Tag and release a patch (non-breaking fix in module OR chart).
	@$(MAKE) _release PART=patch LABEL=bug

.PHONY: release-feature
release-feature: ## Tag and release a minor (new module / chart / value with default).
	@$(MAKE) _release PART=minor LABEL=feature

.PHONY: release-major
release-major: ## Tag and release a major (breaking change in module OR chart).
	@$(MAKE) _release PART=major LABEL=major

.PHONY: release-preview
release-preview: ## Print what the next release tag would be (for each kind).
	@current="$(CURRENT_TAG)"
	@num="$${current#v}"
	@IFS='.' read -r major minor patch <<< "$$num"
	@echo "current: $(YELLOW)$$current$(RESET)"
	@echo "  release-bug      -> v$$major.$$minor.$$((patch + 1))"
	@echo "  release-feature  -> v$$major.$$((minor + 1)).0"
	@echo "  release-major    -> v$$((major + 1)).0.0"

# Internal: the full release flow.
#
#   1. Refuse if branch != main or working tree dirty (override FORCE=1).
#   2. Pull, recompute current tag.
#   3. Compute new tag.
#   4. Sweep helm/<chart>/Chart.yaml `version:` to the new version.
#   5. Sweep in-repo `file://` dep versions inside each Chart.yaml.
#   6. Sweep terraform README `?ref=vX.Y.Z` example lines.
#   7. helm dep update every chart with deps (regenerates Chart.lock).
#   8. Commit the sweep + lock as "release(<label>): vX.Y.Z".
#   9. Tag annotated, push branch + tag.
#  10. CI picks up the tag and publishes every chart to OCI.
.PHONY: _release
_release:
	@set -euo pipefail
	@if [ -z "$(PART)" ] || [ -z "$(LABEL)" ]; then \
		echo "$(RED)error:$(RESET) call release-bug / release-feature / release-major, not _release"; exit 1; \
	fi
	@if [ "$(BRANCH)" != "main" ] && [ "$(FORCE)" != "1" ]; then \
		echo "$(RED)error:$(RESET) releases must be cut from main (currently $(BRANCH)). Override with FORCE=1."; exit 1; \
	fi
	@if [ -n "$$(git status --porcelain)" ] && [ "$(FORCE)" != "1" ]; then \
		echo "$(RED)error:$(RESET) working tree dirty. Commit or stash, or pass FORCE=1."; \
		git status --short; \
		exit 1; \
	fi
	@echo "$(BOLD)Fetching latest from origin...$(RESET)"
	@git fetch --tags origin
	@if [ "$(BRANCH)" = "main" ] && [ "$(FORCE)" != "1" ]; then \
		git pull --ff-only origin main; \
	fi

	@# Compute new tag
	@current=$$(git tag --list 'v*' | sort -V | tail -n1 2>/dev/null)
	@if [ -z "$$current" ]; then current="v0.0.0"; fi
	@num=$${current#v}
	@IFS='.' read -r major minor patch <<< "$$num"
	@case "$(PART)" in \
		major) major=$$((major + 1)); minor=0; patch=0 ;; \
		minor) minor=$$((minor + 1)); patch=0 ;; \
		patch) patch=$$((patch + 1)) ;; \
		*) echo "$(RED)bad PART=$(PART)$(RESET)"; exit 1 ;; \
	esac
	@new_tag="v$$major.$$minor.$$patch"
	@new_ver="$$major.$$minor.$$patch"

	@echo
	@echo "$(BOLD)Release: $(LABEL)$(RESET)"
	@echo "  current tag:  $(YELLOW)$$current$(RESET)"
	@echo "  new tag:      $(GREEN)$$new_tag$(RESET)"
	@echo "  branch:       $(BRANCH)"
	@echo
	@echo "$(BOLD)Commits since $$current:$(RESET)"
	@git log --oneline --no-merges "$$current..HEAD" 2>/dev/null | sed 's/^/  /' || echo "  (no commits — initial release)"
	@echo

	@# Confirmation
	@if [ "$(YES)" != "1" ]; then \
		read -p "Sweep, commit, tag, and push $$new_tag? [y/N] " ans; \
		case "$$ans" in y|Y|yes|YES) ;; *) echo "aborted."; exit 1 ;; esac; \
	fi

	@# 4 + 5: Sweep helm Chart.yaml `version:` and in-repo file:// dep versions
	@echo "$(BOLD)Sweeping helm/*/Chart.yaml versions to $$new_ver...$(RESET)"
	@for c in $(HELM_CHARTS); do \
		sed -i.bak -E "s|^version: .*|version: $$new_ver|" "$$c/Chart.yaml"; \
		rm -f "$$c/Chart.yaml.bak"; \
	done
	@# In-repo `file://` dep versions — rewrite the version line preceding any `file://` repository line
	@python3 - <<-PY
		import re, pathlib
		new_ver = "$$new_ver"
		for f in pathlib.Path("helm").glob("*/Chart.yaml"):
		    t = f.read_text()
		    n = re.sub(
		        r"(- name: [^\n]+\n(?:\s+alias: [^\n]+\n)?\s+)version: [\d.]+(\n\s+repository: \"file://)",
		        lambda m: m.group(1) + f"version: {new_ver}" + m.group(2),
		        t,
		    )
		    if n != t:
		        f.write_text(n)
		        print(f"  swept deps in {f}")
		PY

	@# 6: Sweep terraform leaf-module README `?ref=v...` example lines
	@echo "$(BOLD)Sweeping terraform README ?ref examples to $$new_tag...$(RESET)"
	@find terraform -name README.md -not -path '*/.terraform/*' 2>/dev/null | \
		xargs -I{} sed -i.bak -E "s|(\\?ref=v)[0-9]+\\.[0-9]+\\.[0-9]+|\1$$major.$$minor.$$patch|g" "{}" 2>/dev/null || true
	@find terraform -name 'README.md.bak' -delete 2>/dev/null || true

	@# 7: helm dep update every chart with deps
	@echo "$(BOLD)Refreshing Chart.lock files...$(RESET)"
	@for c in $(HELM_CHARTS); do \
		if grep -q '^dependencies:' "$$c/Chart.yaml" 2>/dev/null; then \
			echo "  helm dep update $$c"; \
			helm dep update "$$c" > /dev/null 2>&1 || echo "  $(YELLOW)warn:$(RESET) helm dep update failed for $$c (offline?)"; \
			rm -f "$$c/charts"/*.tgz 2>/dev/null || true; \
		fi; \
	done

	@# 8: Commit the sweep
	@if [ -n "$$(git status --porcelain)" ]; then \
		echo "$(BOLD)Committing sweep...$(RESET)"; \
		git add -A; \
		git commit -m "release($(LABEL)): $$new_tag - sweep chart versions + Chart.lock + tf README refs"; \
	else \
		echo "$(DIM)(no changes to commit — sweep was a no-op)$(RESET)"; \
	fi

	@# 9: Tag + push branch + tag
	@echo "$(BOLD)Tagging and pushing...$(RESET)"
	@git tag -a "$$new_tag" -m "$(LABEL) release: $$new_tag"
	@git push origin "$(BRANCH)"
	@git push origin "$$new_tag"
	@echo "$(GREEN)Released $$new_tag$(RESET) - CI will publish charts to $(OCI_REGISTRY)"

# ============================================================================
# 5. Back-compat aliases (kept so old muscle memory still works)
# ============================================================================

.PHONY: fmt-check validate lint security preflight
fmt-check: tf-fmt-check  ## (back-compat)
validate: tf-validate    ## (back-compat)
lint:     tf-lint        ## (back-compat)
security: tf-security    ## (back-compat)
preflight: tf-fmt-check tf-lint ## X: Fast pre-deploy check — fmt + lint (no cloud creds).

.PHONY: bump_major bump_minor bump_patch release
bump_major:  ; @echo "$(YELLOW)deprecated:$(RESET) use 'make release-major'"; $(MAKE) release-major
bump_minor:  ; @echo "$(YELLOW)deprecated:$(RESET) use 'make release-feature'"; $(MAKE) release-feature
bump_patch:  ; @echo "$(YELLOW)deprecated:$(RESET) use 'make release-bug'"; $(MAKE) release-bug
release:     ; @echo "$(YELLOW)deprecated:$(RESET) use release-bug / release-feature / release-major (they tag+push in one step)"; exit 1
