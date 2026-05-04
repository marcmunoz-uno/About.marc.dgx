# Python CUDA Frameworks

This package now includes a minimal Python environment flow for remote agents that may need CUDA-aware frameworks in the future.

## Goal

Move from:

- "the host probably has CUDA libraries"

to:

- "the agent environment can import a CUDA framework and enumerate devices"

## Recommended Flow

1. Bootstrap the host session:

```bash
source /home/mxrcmunoz/Desktop/About.marc.dgx/scripts/bootstrap-agent-session.sh
```

2. Create or activate the local agent venv:

```bash
/home/mxrcmunoz/Desktop/About.marc.dgx/scripts/bootstrap-python-cuda-env.sh
```

Default venv location:

```text
/home/mxrcmunoz/Desktop/.venvs/agent-cuda
```

If `python3 -m venv` is unavailable on this host, the script falls back to the official `virtualenv.pyz` bootstrap automatically.

3. Install the framework you actually need in that venv.

Examples:

```bash
source /home/mxrcmunoz/Desktop/.venvs/agent-cuda/bin/activate
pip install cupy-cuda12x
pip install torch
```

Notes:

- Do not blindly install every framework.
- Prefer the smallest dependency set that solves the current task.
- Use PyTorch if the workload expects it.
- Use CuPy if the workload mostly needs NumPy-like CUDA arrays and runtime validation.

4. Validate framework-level CUDA access:

```bash
/home/mxrcmunoz/Desktop/About.marc.dgx/scripts/validate-python-cuda-frameworks.sh
```

## What Counts As Success

- `torch.cuda.is_available() == True`
- or CuPy can enumerate GPU devices successfully

That is stronger than:

- linker cache entries
- `.so` file presence
- `/dev/nvidia*` visibility alone

## Network And Packaging Reality

This script prepares the environment but does not force package installation. Actual `pip install` may depend on:

- network access
- Python wheel availability for `aarch64`
- CUDA compatibility between the host runtime and the framework wheel

If an installation fails, preserve the exact error and do not improvise a package recommendation without checking the framework's current ARM/CUDA support.

## Live Validation On 2026-05-03

From the host-side agent environment:

- a local venv was created successfully using `virtualenv.pyz`
- `cupy-cuda12x` installed successfully on `aarch64`
- CuPy runtime probe failed with:

```text
cudaErrorInsufficientDriver: CUDA driver version is insufficient for CUDA runtime version
```

- NVML probe failed with:

```text
NVMLError_LibraryNotFound
```

Implication:

- Python framework packaging is now workable for agents on this host
- but the host's NVIDIA driver and CUDA userland exposure still need correction before agents can rely on local GPU execution
