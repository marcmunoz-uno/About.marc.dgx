# CUDA Userland Access

This host appears to have at least some CUDA runtime libraries registered with the linker cache, but constrained shells may still fail to load them. That means "CUDA exists somewhere on the box" and "this agent can actually use CUDA right now" are not the same thing.

## What An Agent Needs

For practical CUDA userland access, the agent needs all of these:

1. The libraries must exist in the execution environment.
2. The execution environment must be able to read them.
3. The dynamic linker must be able to resolve them.
4. The process must also be able to access the NVIDIA device nodes if it needs actual GPU execution.

## Best Case

A native SSH shell on the host should be your baseline. From there:

```bash
source /home/mxrcmunoz/Desktop/About.marc.dgx/scripts/bootstrap-cuda-userland.sh
```

If CUDA is installed in the standard DGX-style location for this ARM host, that will export:

- `CUDA_HOME=/usr/local/cuda`
- `PATH=/usr/local/cuda/bin:$PATH`
- `LD_LIBRARY_PATH=/usr/local/cuda/targets/sbsa-linux/lib:$LD_LIBRARY_PATH`
- `CPATH=/usr/local/cuda/targets/sbsa-linux/include:$CPATH`

## If Your Agents Are In A Sandboxed Tool

If the agent runs inside Codex, another snap, a container, or any constrained runner, the host may have CUDA while the agent still cannot see it.

In that case, you have three real options:

1. Run the agent from a native SSH shell instead of the constrained tool host.
2. Bind-mount or expose the CUDA paths and `/dev/nvidia*` into the container or sandbox.
3. Use a different execution target entirely, such as a cloud H100 environment, when the local sandbox cannot be fixed cleanly.

## Minimal Verification

From the shell where the agent will actually run:

```bash
source /home/mxrcmunoz/Desktop/About.marc.dgx/scripts/bootstrap-cuda-userland.sh
python3 - <<'PY'
import ctypes
ctypes.CDLL("libcuda.so.1")
ctypes.CDLL("libcudart.so.13")
print("CUDA userland reachable")
PY
```

If that fails, the agent does not have CUDA userland access in that environment, even if the host itself does.

## Framework-Level Verification

If you install a framework in the same environment:

```bash
python3 - <<'PY'
import torch
print(torch.cuda.is_available())
print(torch.cuda.device_count())
if torch.cuda.device_count():
    print(torch.cuda.get_device_name(0))
PY
```

That is stronger proof than just finding `.so` files.

## Why This Broke In The Audit

During the 2026-05-03 audit:

- `ldconfig -p` reported `libcuda.so.1`, `libcudart.so.13`, and `libcublas.so.13`
- but the constrained Codex shell could not read `/usr/local/cuda` or `dlopen` those libraries

That usually means the execution environment is namespaced or restricted, not necessarily that CUDA is missing from the underlying host.

## Recommended Policy For Agents

- Treat `ctypes.CDLL(...)` success as proof of CUDA userland access.
- Treat `torch.cuda.is_available()` or equivalent as proof of usable GPU access.
- Treat `ldconfig` entries alone as suggestive, not sufficient.
- If the shell cannot prove access, downgrade the claim and do not issue CUDA-version-specific instructions until a native shell or properly configured container confirms it.
