#!/usr/bin/env python3
"""
Pack chunks into Zeliard SAR archive files.

SAR format:
  - 0x00–0x9F : Primary offset table — 40 x 4-byte LE offsets (chunks 0-39)
  - 0xA0–(first_chunk-1) : Extended offset table — additional 4-byte LE offsets
                           pointing to extended chunks (40+)
  - All chunk data at each offset: [4-byte LE size_field][size_field bytes]
"""

import struct
import os


def _discover_chunks(chunk_dir):
    """Return list of (chunk_index, data) sorted by chunk index.

    Supports two naming schemes:
      - Legacy:  chunk_00.bin, chunk_01.bin, …
      - New 8.3: X##PPPPP.ext  (e.g. 112FONTS.bin, 301MAPCA.mdt, 385MUS1S.msd)
    Any file extension is accepted as long as the stem matches.
    """
    import re
    entries = {}  # chunk_index -> bytes

    for fname in os.listdir(chunk_dir):
        stem, ext = os.path.splitext(fname)
        if not ext:
            continue

        # New naming: X##PPPPP  (8 chars stem: 1 zelres digit + 2 chunk digits + 5 purpose)
        m = re.match(r'^[123](\d{2})\w{5}$', stem)
        if m:
            idx = int(m.group(1))
            with open(os.path.join(chunk_dir, fname), 'rb') as f:
                entries[idx] = f.read()
            continue

        # Legacy naming: chunk_NN
        m = re.match(r'^chunk_(\d+)$', stem)
        if m:
            idx = int(m.group(1))
            with open(os.path.join(chunk_dir, fname), 'rb') as f:
                entries[idx] = f.read()

    return [entries[i] for i in sorted(entries)]


def pack_sar(chunk_dir, output_sar):
    """Pack all chunks from a directory into a SAR file.

    Reads chunk files from chunk_dir using either legacy (chunk_NN.bin)
    or new 8.3 (X##PPPPP.bin) naming.  Files are ordered by chunk index.
    The first 40 become the primary offset table; extras become extended.
    """

    print(f"Packing {chunk_dir} -> {output_sar}...")

    all_chunks = _discover_chunks(chunk_dir)

    n_total    = len(all_chunks)
    n_primary  = min(n_total, 40)
    n_extended = n_total - n_primary

    print(f"  Primary chunks : {n_primary}")
    if n_extended:
        print(f"  Extended chunks: {n_extended}  (chunk_40 … chunk_{n_total-1})")
    print(f"  Total          : {n_total}")

    primary  = all_chunks[:40]
    extended = all_chunks[40:]

    # Pad primary table to 40 entries if fewer files exist
    while len(primary) < 40:
        primary.append(b'')

    # Calculate where primary chunks start:
    # primary table = 0xA0 bytes
    # extended table = n_extended * 4 bytes
    first_chunk_offset = 0xA0 + n_extended * 4

    # Build primary offset table
    primary_offsets = []
    pos = first_chunk_offset
    for data in primary:
        primary_offsets.append(pos)
        pos += len(data)

    # Extended chunk data follows primary chunks
    extended_start = pos

    # Build extended offset table
    ext_offsets = []
    for data in extended:
        ext_offsets.append(pos)
        pos += len(data)

    total = pos
    extra = f"  [ext_hdr={n_extended*4}B  ext_data={sum(len(d) for d in extended):,}B]" if extended else ""
    print(f"  Total SAR size : {total:,d} bytes ({total/1024:.1f} KB){extra}")

    with open(output_sar, 'wb') as f:
        # Primary offset table (40 × 4 bytes = 0xA0)
        for off in primary_offsets:
            f.write(struct.pack('<I', off))
        assert f.tell() == 0xA0

        # Extended offset table (n_extended × 4 bytes)
        for off in ext_offsets:
            f.write(struct.pack('<I', off))

        assert f.tell() == first_chunk_offset

        # Primary chunk data
        for data in primary:
            f.write(data)

        # Extended chunk data
        for data in extended:
            f.write(data)

    print(f"  Created: {output_sar}")
    return True


def main():
    import argparse
    parser = argparse.ArgumentParser(description="Pack Zeliard SAR archives from chunk directories")
    parser.add_argument("chunk_dir",  nargs="?", help="Directory of chunk_XX.bin files")
    parser.add_argument("output_sar", nargs="?", help="Output .sar file")
    parser.add_argument("--sar-dir",  default=".", help="Directory of original .sar files (auto mode)")
    parser.add_argument("--out-dir",  default=None, help="Output directory (auto mode)")
    args = parser.parse_args()

    if args.chunk_dir:
        out = args.output_sar or args.chunk_dir.replace("_extracted", ".sar")
        pack_sar(args.chunk_dir, out)
    else:
        print("=== SAR Packer ===\n")
        out_base = args.out_dir or "."
        for name in ["zelres1", "zelres2", "zelres3"]:
            chunk_dir  = os.path.join(out_base, name) if args.out_dir else f"{name}_extracted"
            output_sar = os.path.join(out_base, f"{name}.sar") if args.out_dir else f"{name}.sar"
            if os.path.isdir(chunk_dir):
                pack_sar(chunk_dir, output_sar)
                print()
            else:
                print(f"Warning: {chunk_dir} not found\n")


if __name__ == "__main__":
    main()
