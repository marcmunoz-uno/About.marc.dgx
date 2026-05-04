# SSH Operator Guide

This document is for agents connecting from a Mac to this Linux ARM host over SSH.

Keep these official resources nearby:

- DGX Spark User Guide: <https://docs.nvidia.com/dgx/dgx-spark/>
- Build on Spark: <https://build.nvidia.com/spark>
- NVIDIA Blueprints: <https://build.nvidia.com/blueprints>
- NeMo Data Designer: <https://build.nvidia.com/nemo/data-designer>
- NVIDIA Brev H100 launcher: <https://brev.nvidia.com/environment/new?gpu=H100>

## First Principles

- This is Linux, not macOS.
- This is ARM64, not x86_64.
- This environment uses Snap-packaged tooling in some paths.
- Some wrappers on this machine are required for commands to work correctly.

## Session Bootstrap

After SSH login, establish the real machine context first.

Recommended assumptions:

- Real user home: `/home/mxrcmunoz`
- Work root: `/home/mxrcmunoz/Desktop`
- OpenClaw wrapper dir: `/home/mxrcmunoz/Desktop/bin`
- Bundled Node: `/home/mxrcmunoz/Desktop/tools/node-v24.15.0-linux-arm64/bin`

Recommended bootstrap:

```bash
source /home/mxrcmunoz/Desktop/About.marc.dgx/scripts/bootstrap-agent-session.sh
```

If that package is not checked out on the host, manually export:

```bash
export PATH="/home/mxrcmunoz/Desktop/bin:/home/mxrcmunoz/Desktop/tools/node-v24.15.0-linux-arm64/bin:$PATH"
export OPENCLAW_HOME="/home/mxrcmunoz/Desktop/openclaw-home"
export OPENCLAW_TMPDIR="/home/mxrcmunoz/Desktop/openclaw-home/.tmp"
export GIT_EXEC_PATH="${GIT_EXEC_PATH:-/snap/codex/35/usr/lib/git-core}"
export GIT_TEMPLATE_DIR="${GIT_TEMPLATE_DIR:-/snap/codex/35/usr/share/git-core/templates}"
```

## Command Rules

Prefer:

- `openclaw` via `/home/mxrcmunoz/Desktop/bin/openclaw`
- `octui` via `/home/mxrcmunoz/Desktop/bin/octui`
- `ocgw-lan` via `/home/mxrcmunoz/Desktop/bin/ocgw-lan`

Avoid:

- raw OpenClaw binary from `openclaw-prefix/bin/openclaw` unless `node` is already on `PATH`
- assuming `brew`, `launchctl`, or macOS filesystem conventions
- assuming `/usr/local/cuda` exists

## Git Rule

In Snap-backed shells, Git remote HTTPS can fail with:

```text
git: 'remote-https' is not a git command
```

Mitigation:

```bash
export GIT_EXEC_PATH=/snap/codex/35/usr/lib/git-core
export GIT_TEMPLATE_DIR=/snap/codex/35/usr/share/git-core/templates
```

If GitHub auth is needed and `gh` is available in `/home/mxrcmunoz/Desktop/bin/gh`, use:

```bash
/home/mxrcmunoz/Desktop/bin/gh auth setup-git
```

## macOS To Linux Translation

Map these instincts correctly:

- `open` on macOS -> usually no direct equivalent; use CLI tools or browser manually
- `launchctl` -> likely irrelevant here; prefer Linux services, cron, or OpenClaw-managed daemons
- `/Users/...` -> `/home/...`
- `brew install` -> do not assume Homebrew; inspect Snap, project-local bundles, or system package policy first
- `pbcopy/pbpaste` -> use files or shell pipes instead

## Verification Checklist

Before doing real work, validate:

```bash
uname -a
printf 'HOME=%s\nPATH=%s\n' "$HOME" "$PATH"
python3 --version
/home/mxrcmunoz/Desktop/tools/node-v24.15.0-linux-arm64/bin/node --version
/home/mxrcmunoz/Desktop/bin/openclaw --help
git --version
```

If GPU work matters, verify from the native SSH shell:

```bash
command -v nvidia-smi && nvidia-smi
ls -la /dev/nvidia*
```

For system setup and remote access, the official docs are the baseline:

- the DGX Spark User Guide covers hardware overview, first boot, DGX OS, updates, recovery, Docker container runtime, and support
- Build on Spark includes a "Connect from Another Computer" section and workload playbooks for common Spark tasks
- Blueprints provides workflow and code-sample patterns for building AI applications
- NeMo Data Designer provides a hosted synthetic-data workflow with SDK-based setup

If that still fails, do not improvise a GPU model. Instead:

```bash
./scripts/refresh-audit.sh
```

Then use the strongest proof actually captured:

- `nvidia-smi` or torch CUDA enumeration: exact GPU claims are safe
- only `/dev/nvidia*`: NVIDIA presence is safe, exact GPU claims are not
- only `cuda` directories: CUDA may be installed, but userland is not proven

When choosing how to implement a workload after login:

- start with Build on Spark if the goal is Spark-specific enablement
- check Blueprints if the goal is an end-to-end AI application pattern
- check NeMo Data Designer if the goal is synthetic dataset generation or data flywheel preparation
- use the Brev H100 launcher if the workload requires a known cloud H100 target instead of this local ARM DGX host
- use `CUDA_USERLAND_ACCESS.md` and `scripts/bootstrap-cuda-userland.sh` if the workload needs local CUDA libraries
- use `PYTHON_CUDA_FRAMEWORKS.md` if the workload needs PyTorch or CuPy from the agent environment

For agents launched from a Mac, prefer:

```bash
./examples/remote-agent-launch.sh marc-dgx
./examples/remote-agent-launch.sh marc-dgx /home/mxrcmunoz/Desktop/About.marc.dgx/scripts/probe-cuda.sh
```
