# PaperLab

A small platform that runs research benchmarks on Kubernetes so results are kept, failed jobs are noticed, and every change is tested automatically.

## The problem

During my research projects I ran long benchmarks by hand on cloud servers. Three things went wrong:

- A `git reset` on a server **overwrote finished experiment results**.
- A watchdog bug **left a server running overnight**, wasting money.
- I **could not tell whether a long run had failed** without logging in to each machine.

PaperLab is the setup I wish I had: experiments run as Kubernetes Jobs on a local kind cluster, each job saves its result to a persistent volume, Prometheus and Grafana show what is running, and an alert fires when a job fails. No cloud account needed.

## Architecture

```
 git push ──► GitHub Actions ──► build job image ──► kind cluster in CI ──► run test Job

 Local kind cluster (1 control plane + 2 workers)
 ┌─────────────────────────────────────────────────────────────┐
 │  Job: benchmark ──► writes result.json ──► persistent volume │
 │        │                                                     │
 │        └── job status ──► Prometheus ──► Grafana dashboard   │
 │                                 └──► alert: job failed       │
 └─────────────────────────────────────────────────────────────┘
```

## Milestones

Tick each box only when you can explain it without notes.

- [ ] **1. Container** — `job/run_benchmark.py` runs locally; `job/Dockerfile` builds it and runs it as a non-root user.
- [ ] **2. Cluster** — `scripts/up.sh` creates a kind cluster from `cluster/kind-config.yaml`.
- [ ] **3. Job** — `k8s/benchmark-job.yaml` runs the image as a Kubernetes Job.
- [ ] **4. Safe results** — the job writes `result.json` to a persistent volume that outlives the pod.
- [ ] **5. Monitoring** — kube-prometheus-stack installed with Helm; Grafana shows job and node status.
- [ ] **6. Alert** — `monitoring/alerts.yaml` fires when a benchmark job fails.
- [ ] **7. CI/CD** — `.github/workflows/ci.yml` builds the image and runs a test Job in kind on every push.
- [ ] **8. Failure demo** — kill a job and show the alert, the dashboard, and that saved results survive (`docs/failure-demo.md`).

## Next steps

Not built yet:

- Terraform to create the cluster and install everything (`terraform/` holds the plan).
- MinIO object storage instead of a volume (`helm/minio-values.yaml`).
- Alerts for idle nodes and for jobs that hang.
- OpenTelemetry traces in the job.

## Prerequisites (macOS)

```sh
brew install kind helm hashicorp/tap/terraform
# Docker Desktop must be running; kubectl must be installed
```

## Run

```sh
./scripts/up.sh                       # create the cluster, install Prometheus, Grafana and the alert (~5 min first time)
./scripts/run-job.sh                  # run one benchmark job; lists saved results
BENCH_SIZE=oops ./scripts/run-job.sh  # a job that fails on purpose, to see the alert
./scripts/down.sh                     # delete everything, including saved results
```

See the dashboard and alerts:

```sh
kubectl -n monitoring port-forward svc/monitoring-grafana 3000:80                 # Grafana: http://localhost:3000, dashboard "PaperLab"
kubectl -n monitoring port-forward svc/monitoring-kube-prometheus-prometheus 9090  # alerts: http://localhost:9090/alerts
kubectl -n monitoring get secret grafana-admin -o jsonpath='{.data.admin-password}' | base64 -d; echo  # Grafana password (user: admin)
```

## Demo

Failure tests and what happened: [`docs/failure-demo.md`](docs/failure-demo.md).

_TODO: add a Grafana screenshot and an alert screenshot._

## What I learned

_TODO: one line per milestone._
