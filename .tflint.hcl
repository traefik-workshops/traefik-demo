# tflint configuration for traefik-demo
#
# Enforces conventions documented in AGENTS.md and CONTRIBUTING.md.
# Run via:  make lint
# Or directly:  tflint --recursive --config=$PWD/.tflint.hcl

tflint {
  required_version = ">= 0.50"
}

config {
  # We scan every module subdirectory with --recursive.
  # Don't disable the default ruleset.
  disabled_by_default = false

  # Provider tooling lives elsewhere (.terraform.lock.hcl in consumer repos).
  call_module_type = "local"

  format = "compact"
}

# ----- Core ruleset (always on) -----

plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

# ----- Provider plugins (lazy: installed on `tflint --init`) -----
# Only the providers actually in use across the repo. Add to this list
# when you add a new provider — see AGENTS.md.

plugin "aws" {
  enabled = true
  version = "0.37.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

plugin "azurerm" {
  enabled = true
  version = "0.28.0"
  source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
}

plugin "google" {
  enabled = true
  version = "0.32.0"
  source  = "github.com/terraform-linters/tflint-ruleset-google"
}

# ----- Custom rule tuning -----

# Variable + output description is required (AGENTS.md: "every variable has type + description").
rule "terraform_documented_variables" { enabled = true }
rule "terraform_documented_outputs"   { enabled = true }

# Every variable must declare a type (no implicit `any`).
rule "terraform_typed_variables" { enabled = true }

# Pinned provider versions (no missing `version = ...`).
rule "terraform_required_providers" { enabled = true }
rule "terraform_required_version"   { enabled = true }

# Unused required_providers (a provider pinned but never used) is safe to flag —
# it's an internal declaration, not consumer-facing API.
rule "terraform_unused_required_providers" { enabled = true }

# Unused declarations — DISABLED deliberately.
#
# The rule flags a module's input `variable`s as "unused" when nothing inside
# that module references them — but sibling modules in this repo pass those
# inputs through (e.g. traefik/ec2 sets `vpc_id` on compute/aws/ec2, which
# declares but doesn't internally consume it). Auto-removing them breaks the
# consumer's `module {}` block. Variables are API surface, not dead code, so
# tflint's intra-module view produces false positives here. (It also flags
# unused locals/data, which would be safe to remove, but the rule can't be
# scoped to those alone.)
rule "terraform_unused_declarations" { enabled = false }

# Don't accept deprecated HCL syntax.
rule "terraform_deprecated_index"         { enabled = true }
rule "terraform_deprecated_interpolation" { enabled = true }

# Module sources should pin a ref. Sub-module calls inside this repo are local
# paths, so this catches accidental remote refs to untagged branches.
rule "terraform_module_pinned_source" {
  enabled          = true
  style            = "flexible"
  default_branches = ["main", "master"]
}

# Naming convention — DISABLED deliberately.
#
# Several modules use camelCase variable names on purpose: they mirror the
# upstream Helm chart's value keys 1:1 (e.g. `replicaCount`, `deploymentType`,
# `serviceType`) so demo authors can map values.yaml to module inputs without a
# translation table. Renaming them to snake_case would be a breaking change for
# every downstream demo that pins a tag and sets those inputs — and the snake_case
# win isn't worth a major version bump across the whole consumer base. A handful of
# resource/module labels are also hyphenated (`argocd-traefik`, `observability-prometheus`);
# renaming those churns state for no functional gain on throwaway demo infra.
#
# snake_case for *new* variables/outputs is still the documented convention
# (AGENTS.md) and the new-module scaffold emits it — this just stops the linter
# from failing the build on the intentional pre-existing exceptions.
rule "terraform_naming_convention" {
  enabled = false
}

# Standard module structure — DISABLED deliberately.
#
# The rule wants every variable/output/local in variables.tf/outputs.tf and an
# empty outputs.tf in every leaf. The traefik platform modules (k8s/ec2/ecs/nutanix)
# deliberately keep a `shared.tf` that carries config shared across platforms — that
# one pattern alone accounts for ~160 of the rule's findings, and splitting it would
# scatter tightly-coupled config across files for no readability gain. The canonical
# main.tf/variables.tf/outputs.tf/versions.tf shape is still documented in AGENTS.md
# and emitted by the new-module scaffold; this rule just fought the shared.tf design.
rule "terraform_standard_module_structure" {
  enabled = false
}

# Workspace remote state isn't used in this repo (consumers manage their own
# backend). Surfacing accidental usage early.
rule "terraform_workspace_remote" {
  enabled = true
}
