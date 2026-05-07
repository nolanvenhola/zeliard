#!/usr/bin/env python3
"""
pack_tasm_sar.py — Pack Zeliard SAR archives from the tasm bin/ folder.

Strict source policy: each chunk slot is sourced from EXACTLY ONE file in
bin/zelresN/, named X##NAME.{bin,mdt,grp,msd,...} where:
  - X is the archive digit (1, 2, or 3)
  - ## is the 2-digit chunk index (00..99)
  - NAME is a 1-5 char purpose suffix

build_all.py populates bin/zelresN/ from two sources:
  (1) Compiled outputs from working/zelresN/code/<X##NAME>.asm via
      TasmRunner (Stage 1: compile_one).
  (2) Binary passthrough from working/zelresN/data/<X##NAME>.<ext>
      (Stage 2: copy_data_files).

This tool does not look at:
  - 1_OriginalGame/zelresN.sar (the original game's archive)
  - 2_SAR/ExtractedChunks/zelresN_extracted/* (one-time extraction
    artifacts; these are reference material, not build inputs)
  - bin/zelresN/chunk_NN.bin (legacy extraction-named files; the
    legacy pack_sar.py used them as silent fallbacks for months and
    masked real build regressions).  This tool refuses them outright.

Usage:
    python pack_tasm_sar.py [--out-dir bin]

SAR file format (matches the original):
    0x00–0x9F : Primary offset table — 40 × 4-byte LE offsets (chunks 0-39)
    0xA0–...  : Extended offset table — additional 4-byte LE offsets (40+)
    chunk data follows; each chunk is [4-byte LE size_field][size_field bytes]
"""

import argparse, os, re, struct
from pathlib import Path

ROOT     = Path(__file__).parent.resolve()
BIN      = ROOT / 'bin'

ARCHIVES = ['zelres1', 'zelres2', 'zelres3']

# X##NAME stem: archive digit + 2-digit chunk index + 1-5 char purpose suffix
NEW_NAME_RE = re.compile(r'^([123])(\d{2})\w{1,5}$')
LEGACY_RE   = re.compile(r'^chunk_(\d+)$')


def _scan_bin(name):
    """Scan bin/<name>/.  Return {chunk_idx: (filename, full_path)}.
    Refuses legacy chunk_NN.bin files."""
    archive_digit = name[-1]      # zelres1 -> '1'
    bin_dir       = BIN / name

    out = {}
    if not bin_dir.exists():
        raise SystemExit(f'\nERROR: {bin_dir} does not exist.\n')

    for path in sorted(bin_dir.iterdir()):
        if not path.is_file():
            continue
        stem = path.stem
        if LEGACY_RE.match(stem):
            raise SystemExit(
                f'\nERROR: legacy {path.name!r} found in {bin_dir}.\n'
                f'  Legacy chunk_NN.bin files are extraction artifacts and must not\n'
                f'  feed back into the SAR build (they have masked build regressions\n'
                f'  in the past).  Delete it; the build output / data passthrough\n'
                f'  with X##NAME naming is the authoritative source.\n'
            )
        m = NEW_NAME_RE.match(stem)
        if not m:
            # Things like .sar, .lst, etc. — silently skip
            continue
        if m.group(1) != archive_digit:
            # Misplaced (e.g. zelres2 file in bin/zelres1/) — flag it
            raise SystemExit(
                f'\nERROR: {path.name!r} in bin/{name}/ has wrong archive digit '
                f'(expected {archive_digit}, got {m.group(1)}).\n'
            )
        idx = int(m.group(2))
        if idx in out:
            raise SystemExit(
                f'\nERROR: duplicate chunk {idx} in bin/{name}/: '
                f'{out[idx][0]!r} and {path.name!r} both map to slot {idx}.\n'
            )
        out[idx] = (path.name, path)
    return out


def _gather_archive(name):
    """Return list of (chunk_idx, filename, bytes), sorted by chunk index."""
    chunks = _scan_bin(name)
    if not chunks:
        raise SystemExit(f'\nERROR: no chunk files found for {name}.\n')

    out = []
    for idx in sorted(chunks):
        fname, path = chunks[idx]
        with open(path, 'rb') as f:
            out.append((idx, fname, f.read()))
    return out


def _pack(chunks, output_sar):
    """Write the SAR file from the chunk list (sorted by index)."""
    # Pack indices must be contiguous from 0
    indices = [c[0] for c in chunks]
    expected = list(range(len(indices)))
    if indices != expected:
        gaps = [i for i in expected if i not in indices]
        raise SystemExit(
            f'\nERROR: non-contiguous chunk indices in {output_sar}.\n'
            f'  Expected 0..{len(indices)-1}, got: {indices}\n'
            f'  Missing: {gaps}\n'
        )

    n_total    = len(chunks)
    n_primary  = min(n_total, 40)
    n_extended = n_total - n_primary

    primary  = [c[2] for c in chunks[:40]]
    extended = [c[2] for c in chunks[40:]]

    while len(primary) < 40:
        primary.append(b'')

    first_chunk_offset = 0xA0 + n_extended * 4

    primary_offsets = []
    pos = first_chunk_offset
    for data in primary:
        primary_offsets.append(pos)
        pos += len(data)

    ext_offsets = []
    for data in extended:
        ext_offsets.append(pos)
        pos += len(data)

    total = pos
    extra = (f'  [ext_hdr={n_extended*4}B  '
             f'ext_data={sum(len(d) for d in extended):,}B]') if extended else ''
    print(f'  Primary chunks : {n_primary}')
    if n_extended:
        print(f'  Extended chunks: {n_extended}  (chunk_40 … chunk_{n_total-1})')
    print(f'  Total          : {n_total}')
    print(f'  Total SAR size : {total:,d} bytes ({total/1024:.1f} KB){extra}')

    with open(output_sar, 'wb') as f:
        for off in primary_offsets:
            f.write(struct.pack('<I', off))
        assert f.tell() == 0xA0
        for off in ext_offsets:
            f.write(struct.pack('<I', off))
        assert f.tell() == first_chunk_offset
        for data in primary:
            f.write(data)
        for data in extended:
            f.write(data)
    print(f'  Created: {output_sar}')


def main():
    p = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument('--out-dir', default=str(BIN),
                   help=f'Output directory for .sar files (default: {BIN})')
    args = p.parse_args()

    out_dir = Path(args.out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    print('=== SAR Packer (tasm bin/ only — no fallbacks) ===\n')
    for name in ARCHIVES:
        print(f'Packing {name}...')
        chunks = _gather_archive(name)
        _pack(chunks, out_dir / f'{name}.sar')
        print()


if __name__ == '__main__':
    main()
