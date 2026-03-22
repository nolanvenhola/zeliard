#!/usr/bin/env python3
"""
Pack chunks into Zeliard SAR archive files.
SAR format:
  - First 0xA0 bytes: primary offset table (40 x 4-byte LE offsets)
  - Optional extended offset table between 0xA0 and first chunk
    (zelres2 has 72 extra bytes, zelres3 has 224 extra bytes — these are
     additional offsets pointing into the trailing sprite/image data)
  - Chunk data sections at each offset
  - Optional trailing data (sprite/image blocks) after the last chunk
"""

import struct
import os
import sys


def pack_sar(chunk_dir, output_sar, ref_sar=None):
    """Pack all chunks from a directory into a SAR file.

    ref_sar: path to the original SAR file.  When provided:
      - The extended offset table (any bytes between the 40-entry primary
        table at 0xA0 and the first chunk) is copied verbatim.
      - The trailing data (after the last chunk) is copied verbatim.
      - Chunk start offsets are calculated to match ref_sar's layout.
    Without ref_sar, chunks start immediately at 0xA0 (suitable for
    zelres1 which has no extended header or trailing data).
    """

    print(f"Packing {chunk_dir} -> {output_sar}...")

    # Collect all chunk files
    chunks = []
    for i in range(40):
        chunk_file = os.path.join(chunk_dir, f"chunk_{i:02d}.bin")
        if os.path.exists(chunk_file):
            with open(chunk_file, 'rb') as f:
                data = f.read()
            chunks.append((i, data))
        else:
            chunks.append((i, b''))
            print(f"  Chunk {i:02d}: EMPTY (missing file)")

    if len(chunks) != 40:
        print(f"Error: Expected 40 chunks, found {len(chunks)}")
        return False

    # Read reference SAR for extended header and trailing data
    gap_bytes    = b''
    trailing     = b''
    first_offset = 0xA0  # default: chunks start right after primary table

    if ref_sar and os.path.exists(ref_sar):
        with open(ref_sar, 'rb') as f:
            ref_data = f.read()

        first_offset = struct.unpack('<I', ref_data[0:4])[0]
        gap_bytes    = ref_data[0xA0:first_offset]

        # Find where the last chunk ends to locate trailing data
        ref_offsets = [struct.unpack('<I', ref_data[i*4:(i+1)*4])[0] for i in range(40)]
        valid = [(o, struct.unpack('<I', ref_data[o:o+4])[0])
                 for o in ref_offsets if 0 < o < len(ref_data) - 4]
        if valid:
            last_off, last_sf = max(valid, key=lambda x: x[0])
            trail_start = last_off + 4 + last_sf
            trailing    = ref_data[trail_start:]

    # Build primary offset table
    offset_table   = []
    current_offset = first_offset
    for i, chunk_data in chunks:
        offset_table.append(current_offset)
        current_offset += len(chunk_data)

    total = current_offset + len(trailing)
    extra = (f"  [extended_hdr={len(gap_bytes)}B  trailing={len(trailing):,}B]"
             if gap_bytes or trailing else "")
    print(f"  Total SAR size: {total:,d} bytes ({total/1024:.1f} KB){extra}")

    # Write SAR
    with open(output_sar, 'wb') as f:
        for offset in offset_table:
            f.write(struct.pack('<I', offset))
        assert f.tell() == 0xA0, f"Primary table should be 0xA0 bytes, got {f.tell()}"
        f.write(gap_bytes)
        for i, chunk_data in chunks:
            f.write(chunk_data)
        f.write(trailing)

    print(f"  Created: {output_sar}")
    return True


def main():
    import argparse
    parser = argparse.ArgumentParser(description="Pack Zeliard SAR archives from chunk directories")
    parser.add_argument("chunk_dir",  nargs="?", help="Directory of chunk_XX.bin files")
    parser.add_argument("output_sar", nargs="?", help="Output .sar file")
    parser.add_argument("--ref-sar",  help="Original .sar for extended header / trailing data")
    parser.add_argument("--sar-dir",  default=".", help="Directory of original .sar files (auto mode)")
    parser.add_argument("--out-dir",  default=None, help="Output directory (auto mode)")
    args = parser.parse_args()

    if args.chunk_dir:
        # Manual mode
        out = args.output_sar or args.chunk_dir.replace("_extracted", ".sar")
        pack_sar(args.chunk_dir, out, ref_sar=args.ref_sar)
    else:
        # Auto mode
        print("=== SAR Packer ===\n")
        out_base = args.out_dir or "."
        for name in ["zelres1", "zelres2", "zelres3"]:
            chunk_dir  = os.path.join(out_base, name) if args.out_dir else f"{name}_extracted"
            output_sar = os.path.join(out_base, f"{name}.sar") if args.out_dir else f"{name}.sar"
            ref        = os.path.join(args.sar_dir, f"{name}.sar")
            if os.path.isdir(chunk_dir):
                pack_sar(chunk_dir, output_sar, ref_sar=ref if os.path.exists(ref) else None)
                print()
            else:
                print(f"Warning: {chunk_dir} not found\n")


if __name__ == "__main__":
    main()
