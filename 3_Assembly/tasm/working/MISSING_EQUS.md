# Missing-EQU Report

Scanned 0 raw-hex memory operands across the cleaned source.
Range: 0x0000..0xFFFF.  Min refs to flag MISSING: 2.

- **MISSING (no EQU exists)**: 0 addresses
- **UNUSED (EQU exists, raw hex used anyway)**: 0 addresses

## MISSING EQU symbols

Each address below has at least 2 raw-hex memory references but no `equ` definition anywhere in the cleaned source.

| Address | Refs | Sample call site |
|---|---|---|

## UNUSED EQU symbols (raw hex used despite name existing)

These addresses have a symbolic name in the EQU map but at least one reference site still uses the raw hex literal.  Replacing the literal with the symbol makes the source self-consistent.

| Address | EQU name(s) | Raw-hex sites | Sample |
|---|---|---|---|
