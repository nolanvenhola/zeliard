# Deterministic guest-time replay

`run_replay.py` feeds the same versioned scenario to the original/MASM game in
the pinned DOSBox-X build and to the WASM engine. Scenario timing is expressed
only in Zeliard's `0x13B1`-divisor PIT ticks (or an explicitly named frame or
MASM breakpoint); host sleeps are not part of the contract.

```powershell
python scripts/replay/run_replay.py `
  scripts/replay/scenarios/smoke-title-menu.json `
  --runtime both --repeat 10 --url http://127.0.0.1:5179/
```

The DOS adapter copies the selected game tree, appends a test-only hook below
`CS:2000` in that private copy of `stick.bin`, and replaces the timer's graphics
present call with a trampoline. At each stable post-present boundary the hook
passes real XT set-1 make/break codes to the release `process_scancode`
procedure. Release files under `1_OriginalGame` and `3_Assembly/masm/bin` are
never modified. DOSBox-X runs with dummy SDL video/audio drivers, so replay is
headless and does not take desktop focus.

At a checkpoint the guest writes `REPLAY.OUT` containing the tick, accepted and
missed event sequence numbers, and CRC-16 values for the complete game segment,
MCGA framebuffer, and DAC palette. WASM records FNV-1a hashes for the equivalent
state. Hash algorithms intentionally differ between runtimes; differential
normalization belongs to #204. Within a runtime, repeated runs must have an
identical ordered checkpoint sequence and identical hashes.

## Scenario format

The format identifier is `zeliard-replay-v1`. Events support:

- `wait` with a positive relative `ticks` count;
- `key_down` / `key_up` for arrows, Space, Enter, Alt, Escape, F1/F2/F7/F9;
- `text_key` and complete `joystick` direction/button masks;
- `assert` with named runtime state fields;
- `checkpoint` with a unique name and optional expected state;
- `when: { clock, value }` using `pit_tick`, `frame`, or `breakpoint`.

The validator rejects backward time, duplicate makes, unmatched breaks, stuck
keys, duplicate checkpoints, invalid masks, and any host-time clock. Adapters
fail explicitly when a scenario requests a clock or device they cannot yet
resolve; they never silently approximate it with wall time.

## Evidence and failures

Runs are written under `artifacts/replay-runs/` unless `--output` is supplied.
`result.json` includes the scenario hash and per-runtime reports. Guest-detected
misses include the last accepted input and first missed sequence. A timeout or
premature emulator exit identifies the first missing checkpoint and last input
scheduled before it.

Run contract tests with:

```powershell
python -m unittest discover scripts/replay/tests -v
```
