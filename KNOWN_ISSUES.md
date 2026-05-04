# Known Issues

## 1. Snap Git Remote HTTPS Can Be Broken

Symptom:

```text
git: 'remote-https' is not a git command
```

Cause:

- Snap-packaged `git` is on `PATH`
- helper binaries are not found automatically in some shells

Fix:

```bash
export GIT_EXEC_PATH=/snap/codex/35/usr/lib/git-core
export GIT_TEMPLATE_DIR=/snap/codex/35/usr/share/git-core/templates
```

## 2. `$HOME` May Be Snap-Namespaced

Symptom:

- commands launched from Codex may see `HOME=/home/mxrcmunoz/snap/codex/35`

Impact:

- config lookups can hit the wrong home directory
- shell scripts that assume the real Linux home may break

Mitigation:

- use absolute paths for machine-local assets
- prefer `/home/mxrcmunoz/Desktop/...` for this host package

## 3. Global Node Is Not Installed

Symptom:

- raw `openclaw-prefix/bin/openclaw` fails because `node` is not on `PATH`

Mitigation:

- use `/home/mxrcmunoz/Desktop/bin/openclaw`
- or prepend `/home/mxrcmunoz/Desktop/tools/node-v24.15.0-linux-arm64/bin` to `PATH`

## 4. Standard Dev Toolchain Is Sparse

Observed missing from default audited PATH:

- `node`
- `npm`
- `docker`
- `podman`
- `gcc`
- `g++`
- `make`
- `cmake`
- `go`
- `cargo`

Mitigation:

- inspect before assuming
- prefer bundled or workspace-local tooling

## 5. Audit Visibility Was Partially Constrained

During the 2026-05-03 audit:

- some host binaries were blocked in the Codex sandbox
- `nvidia-smi` was not available in that session

Implication:

- exact GPU SKU and some package-manager details should be rechecked from a native SSH login before making hardware-specific promises

Recommended response when proof is still unavailable:

- state the uncertainty explicitly
- preserve raw command outputs
- downgrade the claim to `present-but-unverified`
- avoid model-specific or CUDA-version-specific instructions until native proof exists

When blocked, prefer official NVIDIA material over guesswork:

- use the DGX Spark User Guide for host-management and platform-behavior questions
- use Build on Spark for supported workload examples and remote-access-oriented getting-started flows
- use Blueprints for reference architectures and workflow patterns
- use NeMo Data Designer for supported synthetic-data generation flows
- use the Brev H100 launcher when the local machine is the wrong execution target and a cloud GPU environment is acceptable

## 6. Local Python CUDA Frameworks Can Install Before The Host Is Actually Ready

Earlier on 2026-05-03, constrained sessions produced misleading failures.

Final host-side validation showed:

- `virtualenv.pyz` could create an `aarch64` venv successfully
- `cupy-cuda12x` installed successfully
- `torch==2.11.0+cu130` installed successfully
- both CuPy and PyTorch enumerated `NVIDIA GB10`

Implication:

- package install success alone is not proof of usable CUDA
- but framework-level runtime probes now confirm this host is ready for native CUDA execution

## 7. Docker GPU Access May Be Blocked By User Permissions

Observed on 2026-05-03:

- Docker GPU validation hit `/var/run/docker.sock`
- access failed due to user permission, not missing CUDA runtime

Mitigation:

```bash
sudo usermod -aG docker $USER
newgrp docker
```
