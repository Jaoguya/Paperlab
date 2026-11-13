#!/usr/bin/env bash
# Milestone 3: build the image, load it into kind, run the Job, show its logs.
set -euo pipefail
cd "$(dirname "$0")/.."

docker build -t paperlab-job:dev job/
kind load docker-image paperlab-job:dev --name paperlab

kubectl apply -f k8s/results-pvc.yaml
kubectl delete job benchmark --ignore-not-found
kubectl apply -f k8s/benchmark-job.yaml
kubectl wait --for=condition=complete job/benchmark --timeout=300s
kubectl logs job/benchmark


# Milestone 4: list every saved result on the volume, using a throwaway pod.
kubectl delete pod results-reader --ignore-not-found
kubectl run results-reader --image=busybox:1.36 --restart=Never \
  --overrides='{"spec":{"containers":[{"name":"r","image":"busybox:1.36","command":["ls","-l","/results"],"volumeMounts":[{"name":"results","mountPath":"/results"}]}],"volumes":[{"name":"results","persistentVolumeClaim":{"claimName":"results"}}]}}'
kubectl wait --for=jsonpath='{.status.phase}'=Succeeded pod/results-reader --timeout=120s
echo "--- saved results ---"
kubectl logs results-reader
kubectl delete pod results-reader
