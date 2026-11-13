#!/usr/bin/env bash
# Create the local cluster and install monitoring and alerts.
set -euo pipefail
cd "$(dirname "$0")/.."

# Milestone 2: cluster (skip if it already exists).
if ! kind get clusters | grep -qx paperlab; then
  kind create cluster --config cluster/kind-config.yaml
fi
kubectl get nodes

# Milestone 5: Prometheus + Grafana. The Grafana password lives in a Secret, not in Git.
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
if ! kubectl -n monitoring get secret grafana-admin >/dev/null 2>&1; then
  kubectl -n monitoring create secret generic grafana-admin \
    --from-literal=admin-user=admin \
    --from-literal=admin-password="$(openssl rand -base64 18)"
fi
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts >/dev/null 2>&1 || true
helm repo update prometheus-community >/dev/null
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  --version 93.3.0 --namespace monitoring -f helm/monitoring-values.yaml \
  --wait --timeout 10m

# Milestones 5 and 6: dashboard and alert rule.
kubectl apply -f monitoring/dashboard.yaml
kubectl apply -f monitoring/alerts.yaml

cat <<MSG

Ready. Open the UIs with port-forward (each in its own terminal):
  kubectl -n monitoring port-forward svc/monitoring-grafana 3000:80          # http://localhost:3000
  kubectl -n monitoring port-forward svc/monitoring-kube-prometheus-prometheus 9090  # http://localhost:9090/alerts
Grafana password:
  kubectl -n monitoring get secret grafana-admin -o jsonpath='{.data.admin-password}' | base64 -d; echo
MSG
