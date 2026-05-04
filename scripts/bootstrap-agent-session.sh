#!/usr/bin/env bash
set -euo pipefail

DGX_REAL_HOME="${DGX_REAL_HOME:-/home/mxrcmunoz}"
DGX_WORK_ROOT="${DGX_WORK_ROOT:-${DGX_REAL_HOME}/Desktop}"

export DGX_REAL_HOME
export DGX_WORK_ROOT
export OPENCLAW_HOME="${OPENCLAW_HOME:-${DGX_WORK_ROOT}/openclaw-home}"
export OPENCLAW_TMPDIR="${OPENCLAW_TMPDIR:-${OPENCLAW_HOME}/.tmp}"
export CUDA_ROOT="${CUDA_ROOT:-/usr/local/cuda}"
export CUDA_HOME="${CUDA_HOME:-${CUDA_ROOT}}"
export CUDA_PATH="${CUDA_PATH:-${CUDA_ROOT}}"

PATH_PREFIXES=(
  "${DGX_WORK_ROOT}/bin"
  "${DGX_WORK_ROOT}/tools/node-v24.15.0-linux-arm64/bin"
  "${CUDA_ROOT}/bin"
)

for prefix in "${PATH_PREFIXES[@]}"; do
  if [ -d "${prefix}" ]; then
    export PATH="${prefix}:${PATH}"
  fi
done

CUDA_SBSA_LIB="${CUDA_ROOT}/targets/sbsa-linux/lib"
CUDA_SBSA_INCLUDE="${CUDA_ROOT}/targets/sbsa-linux/include"

if [ -d "${CUDA_SBSA_LIB}" ]; then
  export LD_LIBRARY_PATH="${CUDA_SBSA_LIB}${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
fi

if [ -d "${CUDA_SBSA_INCLUDE}" ]; then
  export CPATH="${CUDA_SBSA_INCLUDE}${CPATH:+:${CPATH}}"
fi

if [ -d /snap/codex/35/usr/lib/git-core ]; then
  export GIT_EXEC_PATH="${GIT_EXEC_PATH:-/snap/codex/35/usr/lib/git-core}"
fi

if [ -d /snap/codex/35/usr/share/git-core/templates ]; then
  export GIT_TEMPLATE_DIR="${GIT_TEMPLATE_DIR:-/snap/codex/35/usr/share/git-core/templates}"
fi

mkdir -p "${OPENCLAW_TMPDIR}"
chmod 700 "${OPENCLAW_TMPDIR}" 2>/dev/null || true

if [ -f "${OPENCLAW_HOME}/.config/openai.env" ]; then
  set -a
  # shellcheck disable=SC1090
  source "${OPENCLAW_HOME}/.config/openai.env"
  set +a
fi

printf 'DGX agent session bootstrap loaded\n'
printf 'DGX_WORK_ROOT=%s\n' "${DGX_WORK_ROOT}"
printf 'OPENCLAW_HOME=%s\n' "${OPENCLAW_HOME}"
printf 'CUDA_ROOT=%s\n' "${CUDA_ROOT}"
printf 'PATH=%s\n' "${PATH}"
printf 'LD_LIBRARY_PATH=%s\n' "${LD_LIBRARY_PATH:-}"
command -v python3 >/dev/null 2>&1 && printf 'python3=%s\n' "$(command -v python3)"
command -v git >/dev/null 2>&1 && printf 'git=%s\n' "$(command -v git)"
command -v node >/dev/null 2>&1 && printf 'node=%s\n' "$(command -v node)"
command -v openclaw >/dev/null 2>&1 && printf 'openclaw=%s\n' "$(command -v openclaw)"
