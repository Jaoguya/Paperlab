# Milestone 8: infrastructure as code.
# Goal: `terraform apply` creates the kind cluster and installs MinIO + monitoring.
#
# Suggested providers (look up current versions and pin them):
#   - tehcyx/kind        -> kind_cluster resource
#   - hashicorp/helm     -> helm_release for MinIO and kube-prometheus-stack
#
# Start with only the cluster, apply it, then add one helm_release at a time.

terraform {
  required_providers {
    # TODO: kind = { source = "tehcyx/kind", version = "..." }
    # TODO: helm = { source = "hashicorp/helm", version = "..." }
  }
}

# TODO: resource "kind_cluster" "paperlab" { ... }   (reuse cluster/kind-config.yaml settings)
# TODO: resource "helm_release" "minio" { values = [file("../helm/minio-values.yaml")] }
# TODO: resource "helm_release" "monitoring" { values = [file("../helm/monitoring-values.yaml")] }
