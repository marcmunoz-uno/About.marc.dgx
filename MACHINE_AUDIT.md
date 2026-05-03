# Machine Audit

Observed on 2026-05-03 from a local Codex session.

## Identity

- Hostname: `spark-ce3d`
- Kernel: `Linux 6.17.0-1014-nvidia`
- OS: `Ubuntu Core 24`
- Architecture: `aarch64`
- Shell: `/bin/bash`
- Primary user: `mxrcmunoz`

## CPU And Memory

- Logical CPUs observed: `20`
- RAM observed: `121 GiB`
- Swap observed: `15 GiB`
- CPU features indicate modern ARMv8 with SVE/SVE2, BF16, and related vector extensions.

Inference:
- This appears to be a Grace-era ARM NVIDIA system, consistent with the surrounding DGX Spark naming, but this package avoids claiming a more specific SKU than the audit directly proved.

## Storage

- `/home`: about `3.7T`, lightly used at audit time
- `/tmp`: same backing volume as `/home`
- `/`: separate smaller root volume, about `61G`

## GPU Surface

Direct observations:

- NVIDIA device nodes exist:
  - `/dev/nvidia0`
  - `/dev/nvidiactl`
  - `/dev/nvidia-uvm`
  - `/dev/nvidia-modeset`
  - `/dev/nvidia-fs0` through `/dev/nvidia-fs15`

Implications:

- The host has an NVIDIA driver stack active.
- GPUDirect Storage style device nodes are present.
- A remote agent should assume GPU capability exists, but should verify exact model, CUDA version, and runtime health from a native SSH shell because `nvidia-smi` was not available in the audited Codex sandbox.

## Tooling Surface Actually Observed

Available:

- `git` at `/snap/codex/35/usr/bin/git`
- `python3` at `/usr/bin/python3`
- `jq` at `/snap/codex/35/usr/bin/jq`
- `codex` at `/snap/codex/35/bin/codex`
- bundled Node runtime at `/home/mxrcmunoz/Desktop/tools/node-v24.15.0-linux-arm64/bin/node`
- OpenClaw wrapper scripts under `/home/mxrcmunoz/Desktop/bin/`

Missing from default audited PATH:

- `node`
- `npm`
- `docker`
- `podman`
- common build tools like `gcc`, `g++`, `make`, `cmake`, `go`, `cargo`

Important:

- Do not assume a normal developer workstation toolchain is installed globally.
- Prefer project-local wrappers and bundled runtimes.

## Privilege Shape

Observed groups for `mxrcmunoz`:

- `adm`
- `sudo`
- `audio`
- `dip`
- `plugdev`
- `users`
- `lpadmin`

Implication:

- The user likely has escalation ability in a normal SSH shell, but agents should not assume passwordless root unless explicitly confirmed in-session.

## Path Semantics

The Codex session reported:

- `HOME=/home/mxrcmunoz/snap/codex/35`

But real machine-specific assets live under:

- `/home/mxrcmunoz/Desktop`
- `/home/mxrcmunoz/Desktop/openclaw-home`
- `/home/mxrcmunoz/Desktop/openclaw-prefix`

Implication:

- Snap-launched tools may see a namespaced `$HOME`.
- A remote SSH shell may land in the real home and not reproduce the same path behavior.
- Agents must distinguish between the Snap home used by Codex and the real user home.
