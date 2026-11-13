# Milestone 1: package the benchmark as a container image.
FROM python:3.12-slim

WORKDIR /app
COPY run_benchmark.py .

# Run as an unprivileged user so a bug in the job cannot change the image or the node.
RUN useradd --uid 10001 --no-create-home --shell /usr/sbin/nologin bench
USER 10001

CMD ["python", "run_benchmark.py"]
