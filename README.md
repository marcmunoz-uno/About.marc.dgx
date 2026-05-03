# About.marc.dgx

Sanitized operator package for AI agents connecting to Marc's DGX-class Linux host over SSH from macOS or other machines.

This package is not a backup and does not include secrets. It documents the machine shape, the local runtime wrappers, and the constraints an agent must respect to use the host effectively.

## What This Covers

- Host audit summary captured on 2026-05-03
- SSH operator guidance for macOS-based agents
- Linux-vs-macOS differences that matter in practice
- OpenClaw and Codex entrypoints that actually work on this host
- Known traps, especially around Snap-packaged Git and namespaced `$HOME`

## What This Does Not Include

- SSH private keys
- API tokens
- `openai.env`, `bluebubbles.env`, or any live credentials
- Full copies of private state under `.openclaw/`

## Package Contents

- `MACHINE_AUDIT.md` - observed host capabilities and constraints
- `SSH_OPERATOR_GUIDE.md` - how a remote agent should behave after SSH login
- `OPENCLAW_RUNTIME.md` - the local OpenClaw layout and working entrypoints
- `KNOWN_ISSUES.md` - failures, caveats, and mitigations
- `examples/ssh_config.example` - SSH client template for a Mac operator
- `examples/bootstrap-session.sh` - safe shell bootstrap for remote sessions

## Quick Start

1. SSH in using your normal key flow.
2. Land in the real Linux home, not the Snap-shadowed one used by Codex sessions.
3. Export the compatibility variables in `examples/bootstrap-session.sh`.
4. Prefer wrapper commands from `/home/mxrcmunoz/Desktop/bin/`.
5. Treat this host as Linux ARM with a Snap-heavy userspace, not as macOS and not as a generic x86 Ubuntu box.
