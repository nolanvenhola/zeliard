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


def pack_sar(chunk_dir, output_sar):
    """Pack all chunks from a directory into a SAR file.

    Reads chunk_00.bin … chunk_NN.bin from chunk_dir.
    The first 40 files become the primary offset table (0x00–0x9F).
    Any additional files (chunk_40.bin, chunk_41.bin, …) become the
    extended offset table and are appended after all primary chunk data.
    """

    print(f"Packing {chunk_dir} -> {output_sar}...")

    # Discover all chunk files
    all_chunks = []
    i = 0
    while True:
        path = os.path.join(chunk_dir, f"chunk_{i:02d}.bin")
        if not os.path.exists(path):
            break
        with open(path, 'rb') as f:
            all_chunks.append(f.read())
        i += 1

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
