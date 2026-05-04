# Start Here For Agents

This repo explains what the DGX is and how to use it correctly.

## Read This Repo When

- you just landed on the DGX and need machine context
- you need to know whether CUDA, Docker, Python frameworks, or OpenClaw are available
- you are unsure whether a path is native-host, snap-shadowed, or wrapper-based

## What Is Already Proven

- GPU: `NVIDIA GB10`
- Native CUDA userland: working
- PyTorch CUDA: working
- CuPy CUDA: working
- Docker GPU runtime: working

## Read In This Order

1. `MACHINE_AUDIT.md`
2. `SSH_OPERATOR_GUIDE.md`
3. `CUDA_USERLAND_ACCESS.md`
4. `PYTHON_CUDA_FRAMEWORKS.md`
5. `OPENCLAW_RUNTIME.md`

## Most Useful Commands

Bootstrap host session:

```bash
source /home/mxrcmunoz/Desktop/About.marc.dgx/scripts/bootstrap-agent-session.sh
```

Probe native CUDA:

```bash
/home/mxrcmunoz/Desktop/About.marc.dgx/scripts/probe-cuda.sh
```

Validate Docker GPU runtime:

```bash
/home/mxrcmunoz/Desktop/About.marc.dgx/scripts/probe-docker-gpu.sh
```

Validate Python CUDA frameworks:

```bash
/home/mxrcmunoz/Desktop/About.marc.dgx/scripts/validate-python-cuda-frameworks.sh
```

## When To Switch Repos

Once you understand the machine, move to:

```text
/home/mxrcmunoz/Desktop/GPU-Factory-Instructions
```

Use that repo when the task should go through the safer GPU control plane instead of direct host commands.
