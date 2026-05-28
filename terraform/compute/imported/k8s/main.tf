# Imported (bring-your-own) Kubernetes cluster.
#
# This module provisions nothing — it parses a kubeconfig passed in by the
# caller and re-exposes the same outputs that managed-k8s modules (EKS, AKS,
# DOKS, ...) expose. Lets downstream modules (observability, traefik, ai/...)
# consume an existing cluster with the same interface they use for clusters
# this repo provisions.
#
# Logic lives in outputs.tf since there are no resources.
