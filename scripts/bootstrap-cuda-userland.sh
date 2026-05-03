#!/usr/bin/env bash
set -euo pipefail

# Bootstrap CUDA userland visibility for remote agents.
# This script does not install CUDA; it only exposes common paths and verifies access.

CUDA_ROOT="${CUDA_ROOT:-/usr/local/cuda}"
SBSA_LIB="${CUDA_ROOT}/targets/sbsa-linux/lib"
SBSA_INCLUDE="${CUDA_ROOT}/targets/sbsa-linux/include"
CUDA_BIN="${CUDA_ROOT}/bin"

if [ -d "${CUDA_BIN}" ]; then
  export PATH="${CUDA_BIN}:${PATH}"
fi

if [ -d "${SBSA_LIB}" ]; then
  export LD_LIBRARY_PATH="${SBSA_LIB}${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
fi

if [ -d "${SBSA_INCLUDE}" ]; then
  export CPATH="${SBSA_INCLUDE}${CPATH:+:${CPATH}}"
fi

export CUDA_HOME="${CUDA_ROOT}"
export CUDA_PATH="${CUDA_ROOT}"

printf 'CUDA bootstrap loaded\n'
printf 'CUDA_ROOT=%s\n' "${CUDA_ROOT}"
printf 'PATH=%s\n' "${PATH}"
printf 'LD_LIBRARY_PATH=%s\n' "${LD_LIBRARY_PATH:-}"

python3 - <<'PY'
import ctypes, ctypes.util, os

print("\nProbe results:")
for lib in ["cuda", "cudart", "cublas", "cudnn"]:
    print(f"{lib}: find_library -> {ctypes.util.find_library(lib)}")

for lib in ["libcuda.so.1", "libcudart.so.13", "libcublas.so.13"]:
    try:
        ctypes.CDLL(lib)
        print(f"{lib}: dlopen OK")
    except Exception as exc:
        print(f"{lib}: dlopen FAIL ({exc})")
PY
