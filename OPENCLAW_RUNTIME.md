# OpenClaw Runtime

## Important Directories

- Work root: `/home/mxrcmunoz/Desktop`
- OpenClaw state home: `/home/mxrcmunoz/Desktop/openclaw-home`
- OpenClaw package prefix: `/home/mxrcmunoz/Desktop/openclaw-prefix`
- Bundled Node runtime: `/home/mxrcmunoz/Desktop/tools/node-v24.15.0-linux-arm64`

## Working Entry Points

- `/home/mxrcmunoz/Desktop/bin/openclaw`
- `/home/mxrcmunoz/Desktop/bin/octui`
- `/home/mxrcmunoz/Desktop/bin/ocgw-lan`
- `/home/mxrcmunoz/Desktop/bin/openclaw-bluebubbles-gateway`

## Why The Wrapper Matters

The raw package binary at:

```text
/home/mxrcmunoz/Desktop/openclaw-prefix/bin/openclaw
```

failed in audit with:

```text
/usr/bin/env: ‘node’: No such file or directory
```

The wrapper script fixes this by:

- prepending the bundled ARM Node runtime to `PATH`
- exporting `OPENCLAW_HOME`
- exporting `OPENCLAW_TMPDIR`
- optionally loading `/home/mxrcmunoz/Desktop/openclaw-home/.config/openai.env`

## Observed OpenClaw Version

- `OpenClaw 2026.5.2`

## Observed OpenClaw Workspace Layout

Under `/home/mxrcmunoz/Desktop/openclaw-home/.openclaw/`:

- `workspace/`
- `identity/`
- `agents/`
- `tasks/`
- `logs/`
- `devices/`
- `memory/`

Agents should treat this as live state and avoid bulk edits without a specific reason.

## Safe Operational Guidance

- Use `openclaw --help` first, not undocumented internal files.
- Prefer `openclaw status`, `openclaw health`, `openclaw logs`, and `openclaw doctor` before manual surgery.
- Do not publish `.openclaw` contents.
- Do not assume any `.env` file is safe to read into public output.
