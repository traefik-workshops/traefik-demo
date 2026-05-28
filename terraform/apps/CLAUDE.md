# Agent guide — `terraform/apps/`

Inherits from [`../../CLAUDE.md`](../../CLAUDE.md).

## Scope

Sample workloads for demos. Not real applications.

## Modules in this section

Live-derived; regenerate with `make discover | jq '.modules[] | select(.path | startswith("terraform/apps/"))'`.

| Module | Purpose |
|---|---|
| [`httpbin/k8s`](./httpbin/k8s) | Minimal `httpbin` Deployment + Service in the `apps` namespace. |
| [`whoami/cloud-init`](./whoami/cloud-init) | Cloud-init template that installs and starts the `whoami` binary (no resources — output-only). |
| [`whoami/ec2`](./whoami/ec2) | `whoami` instances on AWS EC2, wraps `compute/aws/ec2` + the `whoami/cloud-init` template. |
| [`whoami/ecs`](./whoami/ecs) | `whoami` services across one or more ECS clusters, wraps `compute/aws/ecs`. |
| [`whoami/k8s`](./whoami/k8s) | `whoami` on Kubernetes: Deployment + Service + optional Traefik `IngressRoute`, `Middleware`, and Hub `Uplink`. |
| [`whoami/nutanix`](./whoami/nutanix) | `whoami` VM on Nutanix AHV via `compute/nutanix/vm`, with cloud-init and category-based discovery. |
| [`whoami/nutanix/image_builder`](./whoami/nutanix/image_builder) | Builds the `whoami` qcow2 with Packer (via `local-exec`) and uploads to Nutanix. |

## Sub-conventions

- One workload, multiple platforms: `<app>/<platform>/`. Don't create a new top-level for a new platform of the same app.
- The k8s variant is the canonical one. Other platforms (ec2, ecs, nutanix) should expose **the same variable surface** for the app's behavior — only the platform-specific parts differ.
- `whoami/cloud-init` and similar template-only modules are unusual; document them as such in the module README and don't propagate the pattern.

## Don't

- Don't add an `terraform/apps/<something-complex>/`. If it needs a Dockerfile, it shouldn't be here.
- Don't add platform variants without a clear demo need. `terraform/apps/whoami/<every-cloud>` is not the goal.
