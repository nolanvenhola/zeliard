# MASM Oracle Policy

MASM is the active assembly tree for behavior oracles and web-port parity work.

Use these paths by default:

- Active assembly source and build output: `3_Assembly/masm`
- Behavior tests: `3_Assembly/masm/functest`
- Official behavior gate: `scripts/test-oracles.ps1`

The `3_Assembly/tasm` tree remains useful as archival/reference material and as
the legacy bit-perfect comparison target where build scripts still need it. Do
not add new behavior tests under `3_Assembly/tasm`; add them under the MASM
tree and run them against MASM-built bytes.

Some historical helper names still say `Tasm`, especially `TasmHarness`. Treat
those as compatibility names for the Unicorn flat-binary harness, not as a
signal that new oracles should be TASM-backed.
