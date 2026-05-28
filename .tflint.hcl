# tflint configuration for traefik-demo
#
# Enforces conventions documented in CLAUDE.md and CONTRIBUTING.md.
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
# when you add a new provider — see CLAUDE.md.

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

# Variable + output description is required (CLAUDE.md: "every variable has type + description").
rule "terraform_documented_variables" { enabled = true }
rule "terraform_documented_outputs"   { enabled = true }

# Every variable must declare a type (no implicit `any`).
rule "terraform_typed_variables" { enabled = true }

# Pinned provider versions (no missing `version = ...`).
rule "terraform_required_providers" { enabled = true }
rule "terraform_required_version"   { enabled = true }

# Catch dead code.
rule "terraform_unused_declarations"       { enabled = true }
rule "terraform_unused_required_providers" { enabled = true }

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

# snake_case for variables, outputs, resources, data sources, modules, locals.
# This is the canonical rule (a previous version of this file declared
# `terraform_naming_convention` twice; only one block can be live).
rule "terraform_naming_convention" {
  enabled = true

  variable      { format = "snake_case" }
  output        { format = "snake_case" }
  resource      { format = "snake_case" }
  data          { format = "snake_case" }
  module        { format = "snake_case" }
  locals        { format = "snake_case" }

  # Provider and `*_v1`/`*_v2` resource type names come from upstream — don't lint.
}

# Standard module structure: prefer `main.tf` / `variables.tf` / `outputs.tf` /
# `versions.tf`. Surfaces drift from the canonical shape documented in CLAUDE.md.
rule "terraform_standard_module_structure" {
  enabled = true
}

# Workspace remote state isn't used in this repo (consumers manage their own
# backend). Surfacing accidental usage early.
rule "terraform_workspace_remote" {
  enabled = true
}
