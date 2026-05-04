# About.marc.dgx

Sanitized operator package for AI agents connecting to Marc's DGX-class Linux host over SSH from macOS or other machines.

This package is not a backup and does not include secrets. It documents the machine shape, the local runtime wrappers, and the constraints an agent must respect to use the host effectively.

## What This Covers

- Host audit summary captured on 2026-05-03
- SSH operator guidance for macOS-based agents
- Linux-vs-macOS differences that matter in practice
- OpenClaw and Codex entrypoints that actually work on this host
- Known traps, especially around Snap-packaged Git and namespaced `$HOME`

## Reference Resources

- NVIDIA DGX Spark User Guide: <https://docs.nvidia.com/dgx/dgx-spark/>
- NVIDIA Build on Spark portal: <https://build.nvidia.com/spark>
- NVIDIA Blueprints catalog: <https://build.nvidia.com/blueprints>
- NVIDIA NeMo Data Designer: <https://build.nvidia.com/nemo/data-designer>
- NVIDIA Brev H100 environment launcher: <https://brev.nvidia.com/environment/new?gpu=H100>

Use the DGX Spark User Guide for system behavior, first boot, DGX OS, update, recovery, container runtime, and support guidance. Use Build on Spark for workload playbooks, remote-access quickstarts, and framework-specific examples. Use Blueprints when an agent needs a supported application architecture or workflow pattern. Use NeMo Data Designer when the task involves synthetic data generation or hosted NeMo microservices workflows. Use the Brev H100 launcher when the local DGX is not the right fit and a cloud H100 environment is acceptable.

## What This Does Not Include

- SSH private keys
- API tokens
- `openai.env`, `bluebubbles.env`, or any live credentials
- Full copies of private state under `.openclaw/`

## Package Contents

- `START_HERE_FOR_AGENTS.md` - single-entrypoint guide for agents landing on this device
- `MACHINE_AUDIT.md` - observed host capabilities and constraints
- `CUDA_USERLAND_ACCESS.md` - how agents should gain and verify CUDA userland access
- `DGX_HOST_REMEDIATION.md` - the gap between the official DGX Spark baseline and the live host state, plus remediation order
- `PYTHON_CUDA_FRAMEWORKS.md` - how agents should create a local Python CUDA environment and validate frameworks
- `SSH_OPERATOR_GUIDE.md` - how a remote agent should behave after SSH login
- `OPENCLAW_RUNTIME.md` - the local OpenClaw layout and working entrypoints
- `KNOWN_ISSUES.md` - failures, caveats, and mitigations
- `scripts/refresh-audit.sh` - rerun a native host audit and emit fresh markdown plus raw artifacts
- `scripts/bootstrap-agent-session.sh` - one sourceable bootstrap for PATH, Git, OpenClaw, and CUDA-related env
- `scripts/bootstrap-cuda-userland.sh` - export likely CUDA ARM paths and probe runtime visibility
- `scripts/bootstrap-python-cuda-env.sh` - create or activate a local Python venv for CUDA-aware frameworks
- `scripts/probe-cuda.sh` - future-safe CUDA reachability probe for remote agents
- `scripts/probe-docker-gpu.sh` - official-style Docker GPU validation command for DGX Spark
- `scripts/validate-python-cuda-frameworks.sh` - validate PyTorch/CuPy CUDA readiness in the agent environment
- `examples/ssh_config.example` - SSH client template for a Mac operator
- `examples/bootstrap-session.sh` - safe shell bootstrap for remote sessions
- `examples/remote-agent-launch.sh` - Mac-side helper that SSHes in and bootstraps the DGX session automatically

## Quick Start

1. SSH in using your normal key flow.
2. Land in the real Linux home, not the Snap-shadowed one used by Codex sessions.
3. Export the compatibility variables in `examples/bootstrap-session.sh`.
4. Prefer wrapper commands from `/home/mxrcmunoz/Desktop/bin/`.
5. Treat this host as Linux ARM with a Snap-heavy userspace, not as macOS and not as a generic x86 Ubuntu box.

## Refreshing The Audit

From a native SSH shell on the DGX host:

```bash
cd /path/to/About.marc.dgx
./scripts/refresh-audit.sh
```

This creates:

- `generated/MACHINE_AUDIT_<timestamp>.md`
- `generated/raw-<timestamp>/...`

The script is designed to degrade gracefully. If a shell cannot prove GPU SKU or CUDA userland, it records the uncertainty instead of inventing facts.

## Remote Agent Bootstrap

For future agents connecting from a Mac, use:

```bash
./examples/remote-agent-launch.sh marc-dgx /home/mxrcmunoz/Desktop/About.marc.dgx/scripts/probe-cuda.sh
```

Or to open an interactive bootstrapped shell:

```bash
./examples/remote-agent-launch.sh marc-dgx
```

For Python framework setup after login:

```bash
/home/mxrcmunoz/Desktop/About.marc.dgx/scripts/bootstrap-python-cuda-env.sh
/home/mxrcmunoz/Desktop/About.marc.dgx/scripts/validate-python-cuda-frameworks.sh
```

For official follow-up after a refresh:

- compare system behavior and configuration assumptions against the DGX Spark User Guide
- use Build on Spark playbooks when an agent needs a supported way to stand up a workload on this platform
