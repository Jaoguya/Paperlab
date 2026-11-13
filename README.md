# PaperLab

A small platform that runs benchmark experiments on Kubernetes so results are never lost, stuck jobs are noticed, and nothing sits idle unseen.

## The problem

During my research projects I ran long benchmarks by hand on cloud servers. Three things went wrong:

- A `git reset` on a server **overwrote finished experiment results**.
- A watchdog bug **left a server running overnight**, wasting money.
- I **could not tell whether a long run was stuck** without logging in to each machine.

PaperLab is the setup I wish I had: experiments run as Kubernetes Jobs, every job saves its results to object storage before it exits, and Prometheus alerts when a job hangs or a node sits idle. Everything runs locally on a kind cluster — no cloud account needed.

## Architecture

```
 git push ──► GitHub Actions ──► build job image ──► push to GHCR
                    │
                    └──► spin up kind in CI ──► run sample Job ──► check result in MinIO

 Local kind cluster
 ┌──────────────────────────────────────────────────────────┐
 │  Job: benchmark ──► writes result.json ──► MinIO bucket   │
 │        │                                                  │
 │        └── metrics ──► Prometheus ──► Grafana dashboard   │
 │                              └──► alerts: stuck / idle    │
 └──────────────────────────────────────────────────────────┘
 Terraform creates the cluster and installs MinIO + monitoring.
```

## Milestones

Work top to bottom. Tick each box only when you can explain it without notes.

- [ ] **1. Container** — `job/run_benchmark.py` runs locally; `job/Dockerfile` builds and runs it.
- [ ] **2. Cluster** — `scripts/up.sh` creates a kind cluster from `cluster/kind-config.yaml`.
- [ ] **3. Job** — `k8s/benchmark-job.yaml` runs the image as a Kubernetes Job.
- [ ] **4. Safe results** — the job uploads `result.json` to MinIO *before* it exits; a failed upload fails the job.
- [ ] **5. Monitoring** — kube-prometheus-stack installed; a Grafana dashboard shows running, succeeded and failed jobs.
- [ ] **6. Alerts** — `monitoring/alerts.yaml` fires on a stuck job and on an idle node.
- [ ] **7. CI/CD** — `.github/workflows/ci.yml` builds the image, runs a sample job in kind, and checks the result exists.
- [ ] **8. Infrastructure as code** — `terraform/` creates the cluster and installs MinIO and monitoring; `scripts/up.sh` just calls Terraform.
- [ ] **9. Failure demo** — kill a job mid-run and delete a node; record what the alerts and dashboard show and that no result was lost (`docs/failure-demo.md`).

Stretch: add OpenTelemetry traces to the job.

## Prerequisites (macOS)

```sh
brew install kind helm terraform
# Docker Desktop must be running; kubectl is already installed
```

## Run

```sh
./scripts/up.sh      # create cluster + install everything
./scripts/run-job.sh # run one benchmark job
./scripts/down.sh    # delete everything
```

## Demo

_TODO after milestone 9: Grafana screenshot, alert screenshot, and a short write-up of the failure test._

## What I learned

_TODO: fill in as you go — one line per milestone._
