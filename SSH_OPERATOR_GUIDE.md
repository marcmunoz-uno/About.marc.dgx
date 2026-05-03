# SSH Operator Guide

This document is for agents connecting from a Mac to this Linux ARM host over SSH.

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
source /home/mxrcmunoz/Desktop/About.marc.dgx/examples/bootstrap-session.sh
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

If that still fails, do not improvise a GPU model. Instead:

```bash
./scripts/refresh-audit.sh
```

Then use the strongest proof actually captured:

- `nvidia-smi` or torch CUDA enumeration: exact GPU claims are safe
- only `/dev/nvidia*`: NVIDIA presence is safe, exact GPU claims are not
- only `cuda` directories: CUDA may be installed, but userland is not proven
