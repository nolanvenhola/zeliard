"""
Investigate the 'EMPTY' multi-section chunks (flag != 0) and other anomalous chunks.

For flag!=0 chunks: bytes[5-6]=skip_count, bytes[7-8]=read_count
The VGA section is at offset 9+skip_count with read_count bytes.
These decompress to 0 because the read_count is small or 0.

For the EMPTY ones: the flag IS the first data byte of raw loaded data (AL=3 code chunks
or data loaded differently). Let's look at the actual bytes to understand.
"""
import struct
from pathlib import Path

BASE = Path('c:/Projects/Zeliard/2_SAR/ExtractedChunks')

def analyze_chunk(data: bytes, chunk_num: int, archive: str):
    if len(data) < 5:
        return
    size_word = struct.unpack_from('<I', data, 0)[0]
    flag = data[4]

    print(f"\n{'='*70}")
    print(f"{archive} chunk_{chunk_num:02d}  total_bytes={len(data)}  size_field={size_word}  flag=0x{flag:02X}")

    if flag == 0:
        buf = data[5:5 + size_word - 1]
        opcode = buf[0] & 7 if buf else -1
        print(f"  flag=0 (standard): fill_buffer opcode={opcode}, buf_len={len(buf)}")
        print(f"  first16 of buf: {buf[:16].hex()}")
    else:
        # Multi-section
        if len(data) >= 9:
            skip_count = struct.unpack_from('<H', data, 5)[0]
            read_count = struct.unpack_from('<H', data, 7)[0]
            print(f"  flag!=0 (multi-section): skip={skip_count}, read={read_count}")
            print(f"  bytes[5:9]: {data[5:9].hex()} (skip_count_LE={skip_count}, read_count_LE={read_count})")
            nec_end = 9 + skip_count
            vga_end = 9 + skip_count + read_count
            print(f"  NEC data: bytes[9..{nec_end}] = {skip_count} bytes")
            print(f"  VGA data: bytes[{nec_end}..{vga_end}] = {read_count} bytes")
            if skip_count > 0 and len(data) > 9:
                nec_data = data[9:min(9+skip_count, len(data))]
                print(f"  NEC first16: {nec_data[:16].hex()}")
                opcode = nec_data[0] & 7 if nec_data else -1
                print(f"  NEC fill_buffer opcode: {opcode}")
            if read_count > 0:
                vga_start = 9 + skip_count
                vga_data = data[vga_start:min(vga_start+read_count, len(data))]
                print(f"  VGA first16: {vga_data[:16].hex()}")
                opcode = vga_data[0] & 7 if vga_data else -1
                print(f"  VGA fill_buffer opcode: {opcode}")
            else:
                print(f"  VGA read_count=0 -> no VGA data -> that's why decompressor returns empty!")
                print(f"  This chunk is NEC-ONLY (PC-98 exclusive content, no VGA equivalent)")

        # Also check: is this chunk raw (loaded with AL=3 not AL=2)?
        # Raw chunks for AL=3: entire data including 4-byte header is loaded as-is
        print(f"  Raw first32 (if AL=3 code/data): {data[:32].hex()}")
        # Look for patterns indicating music data
        if len(data) > 10:
            # MSD music files: check for MIDI-like structure
            # Zeliard MSD: timing bytes + note events
            printable = sum(1 for b in data[4:min(50,len(data))] if 0x20 <= b <= 0x7E)
            print(f"  Printable chars in first 50 after header: {printable}")


# Check all the EMPTY/multi-section chunks
EMPTY_CHUNKS = {
    'zelres2': [40, 41, 42, 43, 44, 45, 46, 47, 48, 49],
    'zelres3': [40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95],
}

# Also check anomalous ones
ANOMALOUS = {
    'zelres2': [53, 54, 55, 56],  # unknown names + odd opcodes
    'zelres3': [51, 52, 54, 55, 84, 93],
}

print("=== MULTI-SECTION / EMPTY CHUNKS ===")
for archive, chunks in EMPTY_CHUNKS.items():
    d = BASE / f'{archive}_extracted'
    for cn in chunks[:6]:  # limit to first 6 per archive
        fpath = d / f'chunk_{cn:02d}.bin'
        if fpath.exists():
            analyze_chunk(fpath.read_bytes(), cn, archive)

print("\n\n=== ANOMALOUS CHUNKS ===")
for archive, chunks in ANOMALOUS.items():
    d = BASE / f'{archive}_extracted'
    for cn in chunks:
        fpath = d / f'chunk_{cn:02d}.bin'
        if fpath.exists():
            analyze_chunk(fpath.read_bytes(), cn, archive)
