#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/bootstrap-agent-session.sh" >/dev/null

printf 'CUDA probe starting\n'

if command -v nvidia-smi >/dev/null 2>&1; then
  printf '\n== nvidia-smi -L ==\n'
  nvidia-smi -L || true
else
  printf '\n== nvidia-smi ==\nnot available on PATH\n'
fi

printf '\n== device nodes ==\n'
ls -la /dev/nvidia* 2>/dev/null || true

printf '\n== library probe ==\n'
python3 - <<'PY'
import ctypes
for lib in ["libcuda.so.1", "libcudart.so.13", "libcublas.so.13"]:
    try:
        ctypes.CDLL(lib)
        print(f"{lib}: OK")
    except Exception as exc:
        print(f"{lib}: FAIL ({exc})")
PY

printf '\n== torch probe ==\n'
python3 - <<'PY'
try:
    import torch
    print("torch:", torch.__version__)
    print("cuda_available:", torch.cuda.is_available())
    print("device_count:", torch.cuda.device_count())
    if torch.cuda.device_count():
        for i in range(torch.cuda.device_count()):
            print(f"device[{i}]:", torch.cuda.get_device_name(i))
except Exception as exc:
    print("torch probe failed:", exc)
PY
