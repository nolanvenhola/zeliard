#!/usr/bin/env python3
"""
Extract chunks from Zeliard SAR archive files.
SAR format:
  - First 0xA0 bytes: table of 40 32-bit little-endian offsets
  - Data sections at each offset
"""

import struct
import os
import sys

def extract_sar(sar_filename, output_dir):
    """Extract all chunks from a SAR file."""
    print(f"Processing {sar_filename}...")

    # Create output directory
    os.makedirs(output_dir, exist_ok=True)

    with open(sar_filename, 'rb') as f:
        # Read entire file
        data = f.read()
        file_size = len(data)

        # Read offset table (40 entries of 4 bytes each = 160 bytes = 0xA0)
        offsets = []
        for i in range(40):
            offset_bytes = data[i*4:(i+1)*4]
            offset = struct.unpack('<I', offset_bytes)[0]
            offsets.append(offset)

        print(f"  Found {len(offsets)} offsets")

        # Extract each chunk
        for i in range(len(offsets)):
            start = offsets[i]

            if start == 0 or start >= file_size:
                print(f"  Chunk {i:02d}: Invalid (offset=0x{start:08x})")
                continue

            # Read size_field from the first 4 bytes of the chunk header
            if start + 4 > file_size:
                print(f"  Chunk {i:02d}: Too short to read size_field")
                continue

            size_field = struct.unpack('<I', data[start:start+4])[0]
            end = start + 4 + size_field  # header(4) + data(size_field)

            if end > file_size:
                print(f"  Chunk {i:02d}: size_field extends beyond file, clamping")
                end = file_size

            chunk_size = end - start

            # Extract chunk: header(4) + data(size_field) — exact bytes, no padding
            chunk_data = data[start:end]

            output_filename = os.path.join(output_dir, f"chunk_{i:02d}.bin")
            with open(output_filename, 'wb') as out:
                out.write(chunk_data)

            print(f"  Chunk {i:02d}: offset=0x{start:08x}, size_field={size_field:6d}, total={chunk_size:6d} bytes -> {output_filename}")

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="Extract chunks from Zeliard SAR archives")
    parser.add_argument("--sar-dir",  default=".", help="Directory containing zelres*.sar files (default: .)")
    parser.add_argument("--out-dir",  default=None, help="Base output directory (default: same as --sar-dir)")
    args = parser.parse_args()

    out_base = args.out_dir or args.sar_dir

    for sar_name in ["zelres1.sar", "zelres2.sar", "zelres3.sar"]:
        sar_path = os.path.join(args.sar_dir, sar_name)
        if os.path.exists(sar_path):
            base_name = os.path.splitext(sar_name)[0]
            output_dir = os.path.join(out_base, f"{base_name}_extracted")
            extract_sar(sar_path, output_dir)
            print()
        else:
            print(f"Warning: {sar_path} not found")
