"""Sample benchmark job.

Milestone 1: runs a small CPU benchmark and writes result.json.
Milestone 4: writes the result to RESULTS_DIR (a persistent volume in Kubernetes).
Each run gets its own file and an existing file is never overwritten.
"""

import json
import os
import platform
import sys
import time
from datetime import datetime, timezone


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

    results_dir = os.environ.get("RESULTS_DIR", ".")
    stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    path = os.path.join(results_dir, f"{run_id}-{stamp}.json")

    try:
        # "x" mode fails if the file already exists, so old results are never overwritten.
        with open(path, "x") as f:
            json.dump(result, f, indent=2)
    except OSError as err:
        print(f"could not save result to {path}: {err}", file=sys.stderr)
        sys.exit(1)  # non-zero exit makes Kubernetes mark the Job failed

    print(json.dumps(result))
    print(f"saved {path}")

if __name__ == "__main__":
    main()
