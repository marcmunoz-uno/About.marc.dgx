#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/bootstrap-agent-session.sh" >/dev/null

VENV_DIR="${VENV_DIR:-${DGX_WORK_ROOT}/.venvs/agent-cuda}"
PYTHON_BIN="${PYTHON_BIN:-python3}"

if ! command -v "${PYTHON_BIN}" >/dev/null 2>&1; then
  echo "Missing Python interpreter: ${PYTHON_BIN}" >&2
  exit 1
fi

if [ ! -d "${VENV_DIR}" ]; then
  "${PYTHON_BIN}" -m venv "${VENV_DIR}"
fi

# shellcheck disable=SC1090
source "${VENV_DIR}/bin/activate"

python -m ensurepip --upgrade >/dev/null 2>&1 || true
python -m pip install --upgrade pip setuptools wheel

printf 'Python CUDA env ready\n'
printf 'VENV_DIR=%s\n' "${VENV_DIR}"
printf 'python=%s\n' "$(command -v python)"
printf 'pip=%s\n' "$(command -v pip)"

cat <<'EOF'

Next steps:
  1. Install frameworks as needed, for example:
       pip install cupy-cuda12x
       pip install torch
  2. Validate with:
       /home/mxrcmunoz/Desktop/About.marc.dgx/scripts/validate-python-cuda-frameworks.sh
EOF
