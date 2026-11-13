#!/usr/bin/env bash
# Delete everything. Milestone 8: switch to `terraform -chdir=terraform destroy`.
set -euo pipefail
kind delete cluster --name paperlab
