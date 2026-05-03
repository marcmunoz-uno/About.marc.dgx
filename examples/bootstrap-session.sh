#!/usr/bin/env bash
set -euo pipefail

export DGX_REAL_HOME="/home/mxrcmunoz"
export DGX_WORK_ROOT="/home/mxrcmunoz/Desktop"
export OPENCLAW_HOME="${DGX_WORK_ROOT}/openclaw-home"
export OPENCLAW_TMPDIR="${OPENCLAW_HOME}/.tmp"
export PATH="${DGX_WORK_ROOT}/bin:${DGX_WORK_ROOT}/tools/node-v24.15.0-linux-arm64/bin:${PATH}"

if [ -d /snap/codex/35/usr/lib/git-core ]; then
  export GIT_EXEC_PATH="${GIT_EXEC_PATH:-/snap/codex/35/usr/lib/git-core}"
fi

if [ -d /snap/codex/35/usr/share/git-core/templates ]; then
  export GIT_TEMPLATE_DIR="${GIT_TEMPLATE_DIR:-/snap/codex/35/usr/share/git-core/templates}"
fi

printf 'DGX bootstrap loaded\n'
printf 'HOME=%s\n' "${HOME}"
printf 'OPENCLAW_HOME=%s\n' "${OPENCLAW_HOME}"
command -v openclaw >/dev/null 2>&1 && printf 'openclaw=%s\n' "$(command -v openclaw)"
command -v node >/dev/null 2>&1 && printf 'node=%s\n' "$(command -v node)"
command -v git >/dev/null 2>&1 && printf 'git=%s\n' "$(command -v git)"
