# Zeliard DOSBox-X runner

This is the supported automation entry point for running the original release or
the bit-perfect MASM build in a pinned DOSBox-X environment. It does not use the
legacy `6_DOSBoxMCP` OCR/debugger automation.

## Commands

Provision and verify the approved portable emulator:

```powershell
pwsh -File scripts/dosboxx/Invoke-ZeliardDosboxX.ps1 -Action Provision
```

Run the original-game smoke scenario:

```powershell
pwsh -File scripts/dosboxx/Invoke-ZeliardDosboxX.ps1 -Action Smoke -Source original
```

On an unattended desktop (such as CI), require DOSBox-X's indexed raw capture:

```powershell
pwsh -File scripts/dosboxx/Invoke-ZeliardDosboxX.ps1 -Action Smoke -Source original -CaptureRawVisual
```

This switch briefly focuses DOSBox-X because its SDL mapper only accepts the
raw-capture shortcut from the foreground window. It is opt-in and is never
needed for local builds.

Run the same scenario against a freshly built MASM tree:

```powershell
python 3_Assembly/masm/build_masm.py --verify
pwsh -File scripts/dosboxx/Invoke-ZeliardDosboxX.ps1 -Action Smoke -Source masm
```

Windows PowerShell 5.1 can be used by replacing `pwsh` with `powershell`.

## Outputs

Every smoke run creates a unique directory under `artifacts/dosboxx-runs/` with:

- an isolated writable copy of the selected game tree;
- the exact generated DOSBox-X configuration;
- `events.jsonl`, containing timestamped lifecycle events;
- a PNG captured at the named checkpoint;
- `result.json`, containing lifecycle status, hashes, host metadata, and artifact paths.

The smoke PNG is captured from the launched DOSBox-X window's client device context.
Restricted sessions fall back to a labeled screen capture that serializes capture
and raises the target window first, so parallel runs retain isolated evidence.
With `-CaptureRawVisual`, DOSBox-X's own F11+Ctrl+P `raw1.png` is normalized by
`scripts/visual/parity_artifact.py`. Exact guest-time input and stable
post-present checkpoints are provided by
[`scripts/replay`](../replay/README.md). The smoke runner remains a startup and
capture diagnostic; deterministic parity scenarios use `run_replay.py`.

The lifecycle status distinguishes `startup-failure`, `premature-exit`, `hang`,
and `normal-completion`. A smoke run stops only the DOSBox-X process it launched.

## Pin policy

`dosboxx-pin.json` is the allow-list. Both the downloaded archive and selected
executable must match its SHA-256 values. A local `-DosboxPath` override is useful
for diagnostics, but it is accepted only when its executable hash matches the pin.

Updating DOSBox-X requires an explicit review of the release tag, download URL,
archive hash, executable hash, local smoke artifacts, and CI pin-verification run.
