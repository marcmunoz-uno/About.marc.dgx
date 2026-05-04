#!/usr/bin/env bash
set -euo pipefail

IMAGE="${1:-nvcr.io/nvidia/cuda:13.0.1-devel-ubuntu24.04}"

if ! command -v docker >/dev/null 2>&1; then
  echo "docker not found on PATH" >&2
  exit 1
fi

echo "Running Docker GPU probe with image: ${IMAGE}"
exec docker run --rm -it --gpus=all "${IMAGE}" nvidia-smi
