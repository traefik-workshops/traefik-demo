output "namespace" {
  description = "Namespace Knative Serving was installed into."
  value       = var.namespace
}

output "operator_namespace" {
  description = "Namespace where the Knative Operator lives."
  value       = "knative-operator"
}
