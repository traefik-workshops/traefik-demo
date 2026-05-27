resource "helm_release" "knative_operator" {
  name       = var.name
  namespace  = var.namespace
  repository = "https://knative.github.io/operator"
  chart      = "knative-operator"
  version    = "v1.19.0"
  timeout    = 900
  atomic     = true
}

resource "kubernetes_namespace_v1" "knative_serving" {
  metadata {
    name = "knative-serving"
  }
}

resource "kubectl_manifest" "knative_serving" {
  depends_on = [kubernetes_namespace_v1.knative_serving, helm_release.knative_operator]

  yaml_body = <<YAML
apiVersion: operator.knative.dev/v1beta1
kind: KnativeServing
metadata:
  name: knative-serving
  namespace: knative-serving
spec:
  config:
    network:
      ingress-class: "traefik.ingress.networking.knative.dev"
YAML
}

resource "kubectl_manifest" "knative_serving_domain" {
  depends_on = [kubernetes_namespace_v1.knative_serving, helm_release.knative_operator]

  yaml_body = <<YAML
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-domain
  namespace: knative-serving
data:
  ${var.ingress_domain}: |

  ################################
  #                              #
  #    EXAMPLE CONFIGURATION     #
  #                              #
  ################################

  # This block is not actually functional configuration,
  # but serves to illustrate the available configuration
  # options and document them in a way that is accessible
  # to users that `kubectl edit` this config map.
  #
  # These sample configuration options may be copied out of
  # this example block and unindented to be in the data block
  # to actually change the configuration.

  # Default value for domain.
  # Routes having the cluster domain suffix (by default 'svc.cluster.local')
  # will not be exposed through Ingress. You can define your own label
  # selector to assign that domain suffix to your Route here, or you can set
  # the label
  #    "networking.knative.dev/visibility=cluster-local"
  # to achieve the same effect.  This shows how to make routes having
  # the label app=secret only exposed to the local cluster.

  # svc.cluster.local: |
  #   selector:
  #     app: secret

  # These are example settings of domain.
  # example.com will be used for all routes, but it is the least-specific rule so it
  # will only be used if no other domain matches.

  # example.com: |

  # example.org will be used for routes having app=nonprofit.

  # example.org: |
  #   selector:
  #     app: nonprofit
YAML
}
