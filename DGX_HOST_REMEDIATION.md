# DGX Host Remediation

This document captures the gap between the official NVIDIA DGX Spark baseline and the live host behavior observed on 2026-05-03.

## Official Baseline

According to the NVIDIA DGX Spark User Guide:

- DGX Spark ships with Docker support
- NVIDIA Container Runtime is preinstalled and configured
- GPU validation should work with a container command such as:

```bash
docker run -it --gpus=all nvcr.io/nvidia/cuda:13.0.1-devel-ubuntu24.04 nvidia-smi
```

Official sources:

- DGX Spark User Guide: <https://docs.nvidia.com/dgx/dgx-spark/>
- NVIDIA Container Runtime for Docker: <https://docs.nvidia.com/dgx/dgx-spark/nvidia-container-runtime-for-docker.html>

## Live Host Findings

Observed from the current agent execution context:

- a native SSH shell proves:
  - `nvidia-smi -L` works
  - the GPU is `NVIDIA GB10`
  - `libcuda.so.1`, `libcudart.so.13`, and `libcublas.so.13` load successfully
  - PyTorch and CuPy both enumerate the GPU successfully
- Docker GPU validation reached the Docker socket but failed with a permission error for `mxrcmunoz`

Implication:

- native host-side CUDA userland is working
- the remaining supported-path gap is Docker access for the user account

## Current State

### Path A: Native Host Userland

This path is now proven working.

### Path B: NVIDIA Container Runtime

This path is probably present but still blocked for `mxrcmunoz` by Docker socket permissions.

## Recommended Remediation Order

1. Fix Docker access for the user:

```bash
sudo usermod -aG docker $USER
newgrp docker
docker run -it --gpus=all nvcr.io/nvidia/cuda:13.0.1-devel-ubuntu24.04 nvidia-smi
```

2. If the container probe still fails after Docker group access is fixed, follow the DGX Spark container runtime troubleshooting path in the official docs.
3. Agents can already rely on native host-side CUDA execution even before the Docker path is fixed.

## Policy For Agents

- Prefer the NVIDIA-supported container path if available.
- Treat successful CuPy installation alone as insufficient.
- Treat `cudaErrorInsufficientDriver` as a host-runtime problem, not a Python packaging problem.
