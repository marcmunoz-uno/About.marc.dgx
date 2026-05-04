#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <ssh-host> [remote command...]" >&2
  echo "Example: $0 marc-dgx '/home/mxrcmunoz/Desktop/About.marc.dgx/scripts/probe-cuda.sh'" >&2
  exit 1
fi

SSH_HOST="$1"
shift

REMOTE_BOOTSTRAP='source /home/mxrcmunoz/Desktop/About.marc.dgx/scripts/bootstrap-agent-session.sh'

if [ $# -eq 0 ]; then
  exec ssh -t "${SSH_HOST}" "bash -lc '${REMOTE_BOOTSTRAP}; exec bash -li'"
fi

REMOTE_CMD="$*"
exec ssh -t "${SSH_HOST}" "bash -lc '${REMOTE_BOOTSTRAP}; ${REMOTE_CMD}'"
