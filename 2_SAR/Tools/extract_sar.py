#!/usr/bin/env python3
"""
Extract chunks from Zeliard SAR archive files.

SAR format:
  - 0x00–0x9F : Primary offset table — 40 x 4-byte LE offsets (chunks 0-39)
  - 0xA0–(first_chunk-1) : Extended offset table — additional 4-byte LE offsets
                           (zelres2 has 18 extras = chunks 40-57,
                            zelres3 has 56 extras = chunks 40-95)
  - Chunk data at each offset: [4-byte LE size_field][size_field bytes of data]
  - All chunks (primary and extended) use the same 4-byte header format.
"""

import struct
import os


def extract_sar(sar_filename, output_dir):
    """Extract all chunks from a SAR file, including extended chunks."""
    print(f"Processing {sar_filename}...")

    os.makedirs(output_dir, exist_ok=True)

    with open(sar_filename, 'rb') as f:
        data = f.read()
    file_size = len(data)

    # --- Primary offset table (40 entries, always at 0x00–0x9F) ---
    primary_offsets = [
        struct.unpack('<I', data[i*4:(i+1)*4])[0]
        for i in range(40)
    ]

    # --- Extended offset table (between 0xA0 and first primary chunk) ---
    first_chunk_offset = primary_offsets[0]   # where chunk_00 lives
    gap_bytes = data[0xA0:first_chunk_offset]
    ext_count = len(gap_bytes) // 4
    ext_offsets = [
        struct.unpack('<I', gap_bytes[i*4:(i+1)*4])[0]
        for i in range(ext_count)
    ]

    all_offsets = primary_offsets + ext_offsets
    total = len(all_offsets)
    print(f"  Primary chunks : 40")
    if ext_count:
        print(f"  Extended chunks: {ext_count}  (chunk_40 … chunk_{39+ext_count})")
    print(f"  Total          : {total}")

    # --- Extract every chunk ---
    extracted = 0
    for i, start in enumerate(all_offsets):
        if start == 0 or start >= file_size:
            print(f"  Chunk {i:02d}: Invalid offset 0x{start:08x}, skipping")
            continue

        if start + 4 > file_size:
            print(f"  Chunk {i:02d}: Too short to read size_field, skipping")
            continue

        size_field = struct.unpack('<I', data[start:start+4])[0]
        end = start + 4 + size_field

        if end > file_size:
            print(f"  Chunk {i:02d}: size_field extends beyond file, clamping")
            end = file_size

        chunk_data = data[start:end]
        out_path   = os.path.join(output_dir, f"chunk_{i:02d}.bin")

        with open(out_path, 'wb') as out:
            out.write(chunk_data)

        label = "(extended)" if i >= 40 else ""
        print(f"  Chunk {i:02d}: offset=0x{start:06x}  size={len(chunk_data):7,d} bytes {label}")
        extracted += 1

    print(f"  Extracted {extracted}/{total} chunks -> {output_dir}")


if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="Extract chunks from Zeliard SAR archives")
    parser.add_argument("--sar-dir", default=".", help="Directory containing zelres*.sar files")
    parser.add_argument("--out-dir", default=None,  help="Base output directory (default: same as --sar-dir)")
    args = parser.parse_args()

    out_base = args.out_dir or args.sar_dir

    for sar_name in ["zelres1.sar", "zelres2.sar", "zelres3.sar"]:
        sar_path = os.path.join(args.sar_dir, sar_name)
        if os.path.exists(sar_path):
            base_name  = os.path.splitext(sar_name)[0]
            output_dir = os.path.join(out_base, f"{base_name}_extracted")
            extract_sar(sar_path, output_dir)
            print()
        else:
            print(f"Warning: {sar_path} not found")
