#!/usr/bin/env bash
# Run one benchmark Job and report whether it succeeded.
#   ./scripts/run-job.sh                     normal run
#   BENCH_SIZE=oops ./scripts/run-job.sh     a run that fails (bad input)
# Exit code: 0 if the Job completed, 1 if it failed.
set -euo pipefail
cd "$(dirname "$0")/.."

export RUN_ID="${RUN_ID:-manual}"
export BENCH_SIZE="${BENCH_SIZE:-5000000}"
CLUSTER="${CLUSTER:-paperlab}"

docker build -q -t paperlab-job:dev job/
kind load docker-image paperlab-job:dev --name "$CLUSTER"

kubectl apply -f k8s/results-pvc.yaml
kubectl delete job benchmark --ignore-not-found --wait
envsubst '$RUN_ID $BENCH_SIZE' < k8s/benchmark-job.yaml | kubectl apply -f -

# Wait until the Job either completes or fails (kubectl wait can only watch one).
status=""
for _ in $(seq 1 150); do
  status=$(kubectl get job benchmark -o jsonpath='{range .status.conditions[?(@.status=="True")]}{.type} {end}')
  case "$status" in *Complete*|*Failed*) break ;; esac
  sleep 2
done
echo "job status: ${status:-unknown}"
kubectl logs job/benchmark --all-containers || true

# Milestone 4: list every saved result on the volume, using a throwaway pod.
kubectl delete pod results-reader --ignore-not-found
kubectl run results-reader --image=busybox:1.36 --restart=Never \
  --overrides='{"spec":{"containers":[{"name":"r","image":"busybox:1.36","command":["ls","-l","/results"],"volumeMounts":[{"name":"results","mountPath":"/results"}]}],"volumes":[{"name":"results","persistentVolumeClaim":{"claimName":"results"}}]}}'
kubectl wait --for=jsonpath='{.status.phase}'=Succeeded pod/results-reader --timeout=120s
echo "--- saved results ---"
kubectl logs results-reader
kubectl delete pod results-reader

[[ "$status" == *Complete* ]]
