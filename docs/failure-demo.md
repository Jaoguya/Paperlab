# Failure demo (milestone 8)

Three tests run on the local kind cluster on 14 Nov 2026. Each one: what I did, what I expected, what happened.

## 1. Job with bad input

- **Did:** `BENCH_SIZE=oops ./scripts/run-job.sh`
- **Expected:** the program crashes, Kubernetes retries once (`backoffLimit: 1`), then marks the Job failed and the alert fires.
- **Saw:** two pods in `Error` (first try + one retry), Job `Failed`, log `ValueError: invalid literal for int()`. `BenchmarkJobFailed` was **firing** in Prometheus about 45 seconds later. The script exited with code 1.
- **Results lost?** No. Every earlier result file was still on the volume.

## 2. Kill a job mid-run

- **Did:** started a long run (`RUN_ID=killtest3 BENCH_SIZE=300000000`), then `kubectl delete pod` on its pod after 5 seconds.
- **Expected:** Kubernetes counts one failure and starts a new pod, which finishes.
- **Saw:** Job status `failed=1 succeeded=1`, result `killtest3-…json` saved by the replacement pod. No alert, because the Job succeeded in the end.
- **Results lost?** No. The killed pod never wrote a half file: the result is written only at the end.

## 3. Job that never finishes

- **Did:** `RUN_ID=hangtest BENCH_SIZE=100000000000 ./scripts/run-job.sh` (would run for hours).
- **Expected:** `activeDeadlineSeconds: 120` stops it, the Job is marked failed and the alert fires. This is the "server left running overnight" problem.
- **Saw:** Job `Failed` with reason `DeadlineExceeded` after two minutes; the alert fired. No result file, which is correct.

## Lesson from a failed attempt

My first kill test used a job that ran too long: the retry was still running when the two-minute deadline hit, so the whole Job failed with `DeadlineExceeded`. The deadline covers **all tries together**, not each try, so it must leave room for a retry.

## What I would change next

- Send the alert somewhere (Slack or email) through Alertmanager instead of only showing it in Prometheus.
- Copy results to object storage (MinIO or S3), because deleting the cluster still deletes the volume.
- Test losing a worker node (`docker stop paperlab-worker2`).
