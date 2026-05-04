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

- NVIDIA device nodes exist under `/dev/nvidia*`
- `nvidia-smi` is not visible on `PATH`
- `docker` is not visible on `PATH`
- `nvidia-ctk` is not visible on `PATH`
- CUDA-aware Python packages can install on `aarch64`
- runtime still fails with `cudaErrorInsufficientDriver`
- NVML fails to load

Implication:

- the hardware likely exists and the kernel-side NVIDIA stack is at least partially present
- but user-space runtime exposure does not currently match the supported DGX Spark software baseline for this agent environment

## What Needs To Be True

For agents to rely on local CUDA execution, at least one of these supported paths must work.

### Path A: Native Host Userland

- `nvidia-smi` runs successfully
- `libcuda.so.1` and `libnvidia-ml.so.1` are loadable
- CuPy or PyTorch can enumerate devices

### Path B: NVIDIA Container Runtime

- `docker` runs
- `docker run --gpus=all ... nvidia-smi` succeeds
- agents can do GPU work inside containers even if the bare shell is minimal

## Recommended Remediation Order

1. Validate whether the issue is only this constrained execution context.
2. From a real SSH session on the box, run:

```bash
which docker
which nvidia-smi
which nvidia-ctk
docker run -it --gpus=all nvcr.io/nvidia/cuda:13.0.1-devel-ubuntu24.04 nvidia-smi
```

3. If Docker is present but the command fails, follow the DGX Spark container runtime troubleshooting path in the official docs.
4. If Docker is absent from the host, reconcile that with the official DGX Spark software baseline before trying ad hoc CUDA installs.
5. Only after Docker or native `nvidia-smi` works should agents rely on local CUDA execution.

## Policy For Agents

- Prefer the NVIDIA-supported container path if available.
- Treat successful CuPy installation alone as insufficient.
- Treat `cudaErrorInsufficientDriver` as a host-runtime problem, not a Python packaging problem.
