"""
Investigate 'EMPTY' chunks more carefully.

Key insight: For AL=3 (raw) chunks, the ENTIRE chunk file is loaded verbatim
including the 4-byte size header. The fill_buffer decompressor is NOT called.
So flag!=0 for these chunks just means the 5th byte is non-zero (it's raw code/data).

The skip/read interpretation was wrong for AL=3 chunks.
Let's look at these chunks as raw data and see what they contain.

Also: zelres3 chunk_43 and chunk_44 have flag!=0 but valid VGA data (flag=0xB7/0xC8),
and they DID decompress properly (22346 and 7233 bytes). These are genuine multi-section.

For music chunks (MSD files): they are likely loaded with AL=3 as raw data.
The MSD format needs to be identified.

For zelres2/zelres3 chunks 40-50 (mostly flag!=0 with garbage skip/read):
These appear to be raw-loaded (AL=3) code/data modules.
"""
import struct
from pathlib import Path

BASE = Path('c:/Projects/Zeliard/2_SAR/ExtractedChunks')

def extract_ascii(data: bytes, min_len=3, max_bytes=256) -> list:
    results = []
    current = []
    for b in data[:max_bytes]:
        if 0x20 <= b <= 0x7E:
            current.append(chr(b))
        else:
            if len(current) >= min_len:
                results.append(''.join(current))
            current = []
    if len(current) >= min_len:
        results.append(''.join(current))
    return results

def decode_msd_raw(data: bytes, label: str):
    """Try to decode raw MSD music data."""
    print(f"\n{'-'*60}")
    print(f"RAW DECODE: {label}  ({len(data)} bytes)")
    print(f"  Bytes [0:4] = size_field: {struct.unpack_from('<I', data, 0)[0]}")
    print(f"  Byte  [4]   = flag:       0x{data[4]:02X}")
    print(f"  First 64 bytes (hex):")
    for i in range(0, min(64, len(data)), 16):
        hexs = ' '.join(f'{b:02x}' for b in data[i:i+16])
        print(f"    {i:3d}: {hexs}")
    ascii_strs = extract_ascii(data, min_len=3, max_bytes=512)
    if ascii_strs:
        print(f"  ASCII strings: {ascii_strs[:10]}")

    # For raw AL=3 chunks: data[0:4] is not a size field, it's loaded verbatim.
    # So data[0] is the first byte of the actual content.
    # MSD format check: look for known Zeliard MSD patterns
    # From 200MGAME.asm, MSD music data has note sequences with timing bytes
    # Let's check common byte values
    from collections import Counter
    ctr = Counter(data[:200])
    top10 = ctr.most_common(10)
    print(f"  Top 10 byte values: {[(hex(k), v) for k,v in top10]}")

    # Check for null-terminated or length-prefixed structure
    # Zeliard MSD: typically has small timing values + pitch bytes
    small_bytes = sum(1 for b in data[:100] if b < 32)
    print(f"  Bytes < 0x20 in first 100: {small_bytes}")

# Check music chunks (known MSD)
print("=== MUSIC CHUNKS (known MSD filenames) ===")
for archive, chunks, names in [
    ('zelres2', [46, 47, 48, 49], ['MGT1.MSD', 'MGT2.MSD', 'UGM1.MSD', 'UGM2.MSD']),
    ('zelres3', [85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95],
                ['MUS1', 'MUS2', 'MUS3', 'MUS4', 'MUS5', 'MUS6', 'MUS7', 'MUS8', 'MBOS', 'MFAN', 'MMAO']),
]:
    d = BASE / f'{archive}_extracted'
    for cn, nm in zip(chunks, names):
        fpath = d / f'chunk_{cn:02d}.bin'
        if fpath.exists():
            decode_msd_raw(fpath.read_bytes(), f'{archive} chunk_{cn:02d} = {nm}')

print("\n\n=== UNKNOWN zelres2 chunks 40-45 (raw content) ===")
d2 = BASE / 'zelres2_extracted'
for cn in range(40, 46):
    fpath = d2 / f'chunk_{cn:02d}.bin'
    if fpath.exists():
        decode_msd_raw(fpath.read_bytes(), f'zelres2 chunk_{cn:02d}')

print("\n\n=== UNKNOWN zelres3 chunks 40-55 (raw content) ===")
d3 = BASE / 'zelres3_extracted'
for cn in list(range(40, 56)):
    fpath = d3 / f'chunk_{cn:02d}.bin'
    if fpath.exists():
        decode_msd_raw(fpath.read_bytes(), f'zelres3 chunk_{cn:02d}')

print("\n\n=== ANOMALOUS: zelres2 chunk_55 (opcode 5 = unknown) ===")
fpath = d2 / 'chunk_55.bin'
if fpath.exists():
    data = fpath.read_bytes()
    print(f"raw size={len(data)}, first 64 bytes:")
    for i in range(0, 64, 16):
        hexs = ' '.join(f'{b:02x}' for b in data[i:i+16])
        print(f"  {i:3d}: {hexs}")

print("\n\n=== zelres3 chunk_55 and chunk_84 (opcode 1 = unknown) ===")
for cn in [55, 84]:
    fpath = d3 / f'chunk_{cn:02d}.bin'
    if fpath.exists():
        data = fpath.read_bytes()
        sz = struct.unpack_from('<I', data, 0)[0]
        flag = data[4]
        buf = data[5:5 + sz - 1]
        opcode = buf[0] & 7 if buf else -1
        print(f"zelres3 chunk_{cn:02d}: raw={len(data)}, flag=0x{flag:02x}, opcode={opcode}")
        print(f"  buf first32: {buf[:32].hex()}")
        # opcode 1 = unknown; the remaining bytes after opcode byte are the data
        payload = buf[1:]
        print(f"  payload size={len(payload)}")
        print(f"  payload first32: {payload[:32].hex()}")
        ascii_s = extract_ascii(payload, min_len=3, max_bytes=256)
        print(f"  ASCII: {ascii_s[:6]}")

print("\n\n=== zelres3 chunk_51 - tile index table? ===")
fpath = d3 / 'chunk_51.bin'
if fpath.exists():
    import sys
    sys.path.insert(0, str(Path('c:/Projects/Zeliard/2_SAR/Tools')))
    from decompress_sar import decompress_sar_chunk
    data = fpath.read_bytes()
    decomp = decompress_sar_chunk(data)
    print(f"zelres3 chunk_51: raw={len(data)}, decomp={len(decomp)}")
    # The decompressed data starts with sequential indices 00,01,02,...
    # This looks like a tile lookup/index table
    print(f"  first 64 bytes: {bytes(decomp[:64]).hex()}")
    # Count unique values
    unique = len(set(decomp[:256]))
    print(f"  Unique byte values in first 256: {unique}")
    # Check if it's 48-byte rows (sprite format)
    if len(decomp) % 48 == 0:
        rows = len(decomp) // 48
        print(f"  Divides into {rows} rows of 48 bytes")
    # Could be a tile map or sprite index table
    # Looking at bytes: 00 01 02 03 00 04 05 06 00 07 00 08 09 00 0a 0b...
    # Alternating 00 separators suggest a structured list

print("\n\n=== zelres3 chunk_43 and chunk_44 (genuine multi-section, large decomp) ===")
from decompress_sar import decompress_sar_chunk
for cn in [43, 44]:
    fpath = d3 / f'chunk_{cn:02d}.bin'
    if fpath.exists():
        data = fpath.read_bytes()
        decomp = decompress_sar_chunk(data)
        print(f"zelres3 chunk_{cn:02d}: raw={len(data)}, decomp={len(decomp)}")
        print(f"  first 32 decomp bytes: {bytes(decomp[:32]).hex()}")
        # Check VGA section manually
        skip_count = struct.unpack_from('<H', data, 5)[0]
        read_count = struct.unpack_from('<H', data, 7)[0]
        vga_data = data[9+skip_count:9+skip_count+read_count]
        print(f"  VGA section: skip={skip_count}, read={read_count}, actual_vga_bytes={len(vga_data)}")
        print(f"  VGA first 16: {vga_data[:16].hex()}")
        unique = len(set(decomp))
        print(f"  Unique byte values in decomp: {unique}")
        ascii_s = extract_ascii(bytes(decomp), min_len=4, max_bytes=512)
        print(f"  ASCII: {ascii_s[:8]}")

        # Check row alignment
        for rsize in [48, 96, 192, 240, 320, 384, 480, 960]:
            if len(decomp) % rsize == 0:
                print(f"  Divisible by {rsize} -> {len(decomp)//rsize} rows")
