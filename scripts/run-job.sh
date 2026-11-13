#!/usr/bin/env bash
# Milestone 3: build the image, load it into kind, run the Job, show its logs.
set -euo pipefail
cd "$(dirname "$0")/.."

docker build -t paperlab-job:dev job/
kind load docker-image paperlab-job:dev --name paperlab

kubectl delete job benchmark --ignore-not-found
kubectl apply -f k8s/benchmark-job.yaml
kubectl wait --for=condition=complete job/benchmark --timeout=300s
kubectl logs job/benchmark

# TODO (milestone 4): check result.json exists in the MinIO bucket.
