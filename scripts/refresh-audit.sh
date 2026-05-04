#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="${ROOT_DIR}/generated"
STAMP="$(date '+%Y-%m-%d_%H-%M-%S')"
RAW_DIR="${OUT_DIR}/raw-${STAMP}"
REPORT="${OUT_DIR}/MACHINE_AUDIT_${STAMP}.md"

mkdir -p "${OUT_DIR}" "${RAW_DIR}"

run_capture() {
  local name="$1"
  shift
  local out="${RAW_DIR}/${name}.txt"
  {
    printf '$'
    printf ' %q' "$@"
    printf '\n'
    "$@"
  } >"${out}" 2>&1 || true
}

have_cmd() {
  command -v "$1" >/dev/null 2>&1
}

first_line() {
  local file="$1"
  if [ -s "${file}" ]; then
    sed -n '2p' "${file}" 2>/dev/null || true
  fi
}

summarize_gpu() {
  if grep -q '^GPU ' "${RAW_DIR}/nvidia-smi-L.txt" 2>/dev/null; then
    sed -n '2,20p' "${RAW_DIR}/nvidia-smi-L.txt"
    return
  fi
  if [ -s "${RAW_DIR}/dev-nvidia.txt" ]; then
    printf 'NVIDIA device nodes present, but SKU unverified from this shell.\n'
    return
  fi
  printf 'No GPU proof captured.\n'
}

summarize_cuda() {
  if grep -q 'CUDA Version' "${RAW_DIR}/nvidia-smi.txt" 2>/dev/null; then
    grep 'CUDA Version' "${RAW_DIR}/nvidia-smi.txt" | head -1
    return
  fi
  if tail -n +2 "${RAW_DIR}/nvcc-version.txt" 2>/dev/null | grep -q .; then
    sed -n '2,8p' "${RAW_DIR}/nvcc-version.txt"
    return
  fi
  if tail -n +2 "${RAW_DIR}/cuda-paths.txt" 2>/dev/null | grep -q .; then
    printf 'CUDA paths found on disk; exact userland version unverified.\n'
    return
  fi
  printf 'No CUDA userland proof captured.\n'
}

run_capture uname uname -a
run_capture os-release cat /etc/os-release
run_capture hostname hostname
run_capture whoami whoami
run_capture id id
run_capture groups groups
run_capture home-env bash -lc 'printf "HOME=%s\nPATH=%s\nSHELL=%s\n" "$HOME" "$PATH" "$SHELL"'
run_capture nproc nproc
run_capture free free -h
run_capture df df -h /
run_capture df-home df -h /home
run_capture lscpu bash -lc 'command -v lscpu >/dev/null 2>&1 && lscpu || sed -n "1,120p" /proc/cpuinfo'
run_capture cpuinfo sed -n '1,120p' /proc/cpuinfo
run_capture git-version bash -lc 'command -v git >/dev/null 2>&1 && { git --version; which git; git --exec-path; }'
run_capture python-version bash -lc 'command -v python3 >/dev/null 2>&1 && { python3 --version; which python3; }'
run_capture node-version bash -lc 'command -v node >/dev/null 2>&1 && { node --version; which node; }'
run_capture ssh-version bash -lc 'command -v ssh >/dev/null 2>&1 && ssh -V'
run_capture dev-nvidia bash -lc 'ls -la /dev/nvidia* 2>/dev/null || true'
run_capture proc-nvidia-version bash -lc 'cat /proc/driver/nvidia/version 2>/dev/null || true'
run_capture nvidia-smi-L bash -lc 'command -v nvidia-smi >/dev/null 2>&1 && nvidia-smi -L'
run_capture nvidia-smi bash -lc 'command -v nvidia-smi >/dev/null 2>&1 && nvidia-smi'
run_capture nvcc-version bash -lc 'command -v nvcc >/dev/null 2>&1 && nvcc --version'
run_capture cuda-paths bash -lc 'ls -ld /usr/local/cuda* /opt/cuda* 2>/dev/null || true'
run_capture snap-list bash -lc 'command -v snap >/dev/null 2>&1 && snap list'
run_capture docker-version bash -lc 'command -v docker >/dev/null 2>&1 && docker --version'
run_capture podman-version bash -lc 'command -v podman >/dev/null 2>&1 && podman --version'
run_capture python-torch bash -lc 'python3 - <<'"'"'PY'"'"'
import json
try:
    import torch
    data = {
        "torch": getattr(torch, "__version__", None),
        "cuda_available": torch.cuda.is_available(),
        "device_count": torch.cuda.device_count(),
        "devices": [torch.cuda.get_device_name(i) for i in range(torch.cuda.device_count())],
        "torch_cuda": getattr(torch.version, "cuda", None),
    }
    print(json.dumps(data, indent=2))
except Exception as exc:
    print(f"torch probe failed: {exc}")
PY'

HOSTNAME_VALUE="$(first_line "${RAW_DIR}/hostname.txt")"
UNAME_VALUE="$(first_line "${RAW_DIR}/uname.txt")"
HOME_VALUE="$(grep '^HOME=' "${RAW_DIR}/home-env.txt" 2>/dev/null | head -1 | cut -d= -f2-)"
LOGICAL_CPUS="$(first_line "${RAW_DIR}/nproc.txt")"
PYTHON_VALUE="$(first_line "${RAW_DIR}/python-version.txt")"
GIT_VALUE="$(first_line "${RAW_DIR}/git-version.txt")"
NODE_VALUE="$(first_line "${RAW_DIR}/node-version.txt")"

{
  printf '# Machine Audit Refresh\n\n'
  printf 'Generated: `%s`\n\n' "$(date '+%Y-%m-%d %H:%M:%S %Z')"
  printf '## Identity\n\n'
  printf -- '- Hostname: `%s`\n' "${HOSTNAME_VALUE:-unknown}"
  printf -- '- Kernel: `%s`\n' "${UNAME_VALUE:-unknown}"
  printf -- '- Effective HOME in this shell: `%s`\n' "${HOME_VALUE:-unknown}"
  printf -- '- Logical CPUs: `%s`\n' "${LOGICAL_CPUS:-unknown}"
  printf -- '- Python: `%s`\n' "${PYTHON_VALUE:-unavailable}"
  printf -- '- Git: `%s`\n' "${GIT_VALUE:-unavailable}"
  printf -- '- Node: `%s`\n' "${NODE_VALUE:-unavailable}"
  printf '\n## GPU Proof\n\n```\n'
  summarize_gpu
  printf '```\n\n## CUDA Proof\n\n```\n'
  summarize_cuda
  printf '```\n\n## Confidence Rules\n\n'
  printf -- '- If `nvidia-smi -L` or torch device enumeration succeeds, GPU SKU is proven.\n'
  printf -- '- If only `/dev/nvidia*` exists, NVIDIA presence is proven but SKU is not.\n'
  printf -- '- If `nvcc --version`, `nvidia-smi`, or torch CUDA metadata succeed, CUDA userland is proven.\n'
  printf -- '- If only `cuda` directories exist on disk, CUDA presence is suggestive but unproven.\n'
  printf '\n## Raw Artifacts\n\n'
  printf 'Raw command outputs live in `%s`.\n' "${RAW_DIR}"
} >"${REPORT}"

printf 'Wrote %s\n' "${REPORT}"
printf 'Raw artifacts: %s\n' "${RAW_DIR}"
