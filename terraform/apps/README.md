# apps/

Sample workloads used to demonstrate infrastructure. These are deliberately trivial — they exist so an SA can point at *something* running after `terraform apply`.

If you're tempted to put real application logic here, stop. Real apps live in their own repos.

## Modules

| Path | Platform | Purpose |
|---|---|---|
| [`httpbin/k8s`](./httpbin/k8s) | k8s | httpbin in-cluster — useful for testing ingress, headers, redirects |
| [`whoami/cloud-init`](./whoami/cloud-init) | template | Cloud-init script that runs terraform/traefik/whoami on a VM |
| [`whoami/ec2`](./whoami/ec2) | AWS | whoami on EC2 (uses `whoami/cloud-init`) |
| [`whoami/ecs`](./whoami/ecs) | AWS | whoami on ECS Fargate |
| [`whoami/k8s`](./whoami/k8s) | k8s | whoami in-cluster, with optional Traefik IngressRoute |
| [`whoami/nutanix`](./whoami/nutanix) | Nutanix | whoami on a Nutanix VM |
| [`whoami/nutanix/image_builder`](./whoami/nutanix/image_builder) | Nutanix | Builds a Nutanix image baked with whoami |

## When to add an app

Almost never. The bar is: "is there a *demo concept* that whoami and httpbin can't carry?" If yes, add it. If no, use what's here.

The most common request is "an app that does X behavior" (slow response, error injection, large payload). Prefer adding a flag to `whoami/k8s` if possible.
