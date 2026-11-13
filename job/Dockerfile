# Milestone 1: package the benchmark as a container image.
FROM python:3.12-slim

WORKDIR /app
COPY run_benchmark.py .

# TODO (milestone 4): install the MinIO client library you choose,
# e.g. add a requirements.txt and `pip install -r requirements.txt`.

# TODO: run as a non-root user.

CMD ["python", "run_benchmark.py"]
