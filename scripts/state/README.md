# Canonical game-state fixtures

`zeliard_state.py` turns the MASM `stdply.inc` player-record layout into a
deterministic corpus of 256-byte `.USR` files. It intentionally resolves every
field offset from MASM at runtime. Semantic rules add widths, legal ranges, and
names for the persistent cavern bits; they do not redefine offsets.

Generate and verify the committed corpus:

```powershell
python scripts/state/zeliard_state.py generate
python -m unittest discover scripts/state/tests -v
```

Inspect or compare saves:

```powershell
python scripts/state/zeliard_state.py decode Muralla.USR
python scripts/state/zeliard_state.py diff expected.USR actual.USR
python scripts/state/zeliard_state.py validate Muralla.USR
```

Each semantic difference reports the save offset, bit mask, canonical name,
and expected/actual values. `fixtures/manifest.json` records SHA-256 checksums
and set/clear/round-trip coverage for every documented progression bit.

`valid/` fixtures are loadable game states. `malformed/` contains error-flow
inputs for issue #190 and must never be launched in DOSBox. Fixture basenames
are eight characters or fewer so both `ZELIAD BASE` and `ZELIAD BASE.USR`
command-line paths can be tested.

Checkpoint metadata can capture the owner/scene, RNG marker, and timers next
to any emitted record:

```powershell
python scripts/state/zeliard_state.py capture BASE.USR --output base.json `
  --scene town --owner town --rng 1234 --timers '{"frame": 7, "anim": 42}'
```

The browser fixture test additionally captures the full shared 64 KiB game
segment, framebuffer, palette, active scene owner, audio state, and transient
timers before and after each load. That makes state leakage and unintended
scene resets visible even when the persistent 256-byte record is unchanged.
