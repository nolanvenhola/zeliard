# Raw visual parity artifacts

Ticket #201 uses a host-independent capture contract. Every named checkpoint
contains the authoritative palette-index framebuffer (`framebuffer.bin`), the
complete 256-entry RGB DAC (`palette.rgb`), a native 320x200 PNG, and a manifest
with independent index/palette hashes. An optional `render-trace.jsonl` records
ordered graphics operations or per-present dirty rectangles.

`parity_artifact.py capture` accepts a 64 KiB `A000:0000` debugger dump from
DOSBox-X in MCGA mode. The first 64,000 bytes are the visible 320x200 page. Use
`--dac6` when the 768-byte palette file contains raw VGA 0..63 DAC components.
It also accepts DOSBox-X's built-in 8-bit `*.raw1.png` capture with mode
`dosboxx-indexed-png`; integer scan doubling is removed only when every
duplicate pixel has the same palette index, and the embedded PLTE is retained
as the complete active palette. Filtered or arbitrarily scaled captures fail.
DOSBox-X debugger acquisition and named-breakpoint scheduling are driven by
ticket #202; the artifact is deliberately independent of debugger UI or host
window dimensions.

Planar normalization is explicitly defined for EGA-family captures: four
sequential 8,000-byte, MSB-first 1bpp planes, plane zero supplying the least
significant index bit. Padded planes can call `normalize_planar` with an
explicit stride. CGA, Hercules, and Tandy memory organizations must be decoded
to this same canonical indexed surface before comparison; they must not be
treated as MCGA bytes.

Compare two captures with:

```text
python scripts/visual/parity_artifact.py compare artifacts/dos artifacts/wasm --output artifacts/diff
```

Normalize a DOSBox-X raw indexed screenshot with:

```text
python scripts/visual/parity_artifact.py capture --mode dosboxx-indexed-png --memory zeliad_000.raw1.png --checkpoint opening-title --runtime dosboxx-masm --output artifacts/dos
```

The result separates index and palette failures and writes reference,
candidate, magenta diff, changed-pixel bounds, palette-entry differences, and
the owning checkpoint. Ordered trace comparison catches a wrong draw sequence
even when a later redraw repairs the final framebuffer.

The browser enables per-present tracing only with the `codex_capture` query
parameter, so production play does not pay for framebuffer copies and hashes.
