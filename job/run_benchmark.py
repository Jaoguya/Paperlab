"""Sample benchmark job.

Milestone 1: runs a small CPU benchmark and writes result.json.
Milestone 4: upload result.json to MinIO before exiting (see TODO below).
"""

import json
import os
import platform
import time


def benchmark(n: int) -> float:
    """Time a simple CPU-bound loop. Replace with a real workload later."""
    start = time.perf_counter()
    total = 0
    for i in range(n):
        total += i * i
    return time.perf_counter() - start


def main() -> None:
    n = int(os.environ.get("BENCH_SIZE", "5000000"))
    run_id = os.environ.get("RUN_ID", "local")

    result = {
        "run_id": run_id,
        "size": n,
        "seconds": benchmark(n),
        "host": platform.node(),
    }

    with open("result.json", "w") as f:
        json.dump(result, f, indent=2)
    print(json.dumps(result))

    # TODO (milestone 4): upload result.json to the MinIO bucket named in
    # the RESULTS_BUCKET env var, then verify the object exists.
    # If the upload fails, exit non-zero so Kubernetes marks the Job failed.


if __name__ == "__main__":
    main()
