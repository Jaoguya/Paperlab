#!/usr/bin/env bash
# Delete everything, including saved results on the volume.
set -euo pipefail
kind delete cluster --name paperlab
