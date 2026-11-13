#!/usr/bin/env bash
# Milestone 2: create the local cluster.
# Milestone 8: replace the kind command with `terraform -chdir=terraform apply`.
set -euo pipefail
cd "$(dirname "$0")/.."

kind create cluster --config cluster/kind-config.yaml
kubectl get nodes

# TODO (milestone 4): helm install MinIO with helm/minio-values.yaml
# TODO (milestone 5): helm install kube-prometheus-stack with helm/monitoring-values.yaml
# TODO (milestone 6): kubectl apply -f monitoring/alerts.yaml
