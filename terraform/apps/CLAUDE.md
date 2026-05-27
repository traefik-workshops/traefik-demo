# Agent guide — `terraform/apps/`

Inherits from [`../../CLAUDE.md`](../../CLAUDE.md).

## Scope

Sample workloads for demos. Not real applications.

## Sub-conventions

- One workload, multiple platforms: `<app>/<platform>/`. Don't create a new top-level for a new platform of the same app.
- The k8s variant is the canonical one. Other platforms (ec2, ecs, nutanix) should expose **the same variable surface** for the app's behavior — only the platform-specific parts differ.
- `whoami/cloud-init` and similar template-only modules are unusual; document them as such in the module README and don't propagate the pattern.

## Don't

- Don't add an `terraform/apps/<something-complex>/`. If it needs a Dockerfile, it shouldn't be here.
- Don't add platform variants without a clear demo need. `terraform/apps/whoami/<every-cloud>` is not the goal.
