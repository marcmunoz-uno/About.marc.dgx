#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/bootstrap-agent-session.sh" >/dev/null

VENV_DIR="${VENV_DIR:-${DGX_WORK_ROOT}/.venvs/agent-cuda}"
if [ -d "${VENV_DIR}" ]; then
  # shellcheck disable=SC1090
  source "${VENV_DIR}/bin/activate"
fi

python3 - <<'PY'
import importlib
import json

report = {"torch": None, "cupy": None}

try:
    torch = importlib.import_module("torch")
    entry = {
        "installed": True,
        "version": getattr(torch, "__version__", None),
        "cuda_built": getattr(getattr(torch, "version", None), "cuda", None),
    }
    try:
        entry["cuda_available"] = torch.cuda.is_available()
        entry["device_count"] = torch.cuda.device_count()
        entry["devices"] = [torch.cuda.get_device_name(i) for i in range(torch.cuda.device_count())]
    except Exception as exc:
        entry["runtime_error"] = str(exc)
    report["torch"] = entry
except Exception as exc:
    report["torch"] = {"installed": False, "error": str(exc)}

try:
    cupy = importlib.import_module("cupy")
    entry = {
        "installed": True,
        "version": getattr(cupy, "__version__", None),
    }
    try:
        count = cupy.cuda.runtime.getDeviceCount()
        entry["device_count"] = count
        entry["devices"] = []
        for i in range(count):
            props = cupy.cuda.runtime.getDeviceProperties(i)
            name = props.get("name")
            if isinstance(name, bytes):
                name = name.decode("utf-8", "ignore")
            entry["devices"].append(name)
    except Exception as exc:
        entry["runtime_error"] = str(exc)
    report["cupy"] = entry
except Exception as exc:
    report["cupy"] = {"installed": False, "error": str(exc)}

print(json.dumps(report, indent=2))
PY
