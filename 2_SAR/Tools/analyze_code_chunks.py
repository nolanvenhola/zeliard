"""
Final analysis: zelres2/zelres3 chunks 40-55 appear to be raw-loaded code chunks (AL=3).
Looking at their structure:

Pattern in zelres3 chunks 40-50:
  bytes[0:4] = LE uint32 (looks like a real size)
  bytes[4] = non-zero (would be fill_buffer flag if data, but it's code)
  bytes[8+] = many C4/C7/C8/C9 bytes = these look like 80186 machine code!
    C4 = LES  reg, [mem]
    C7 = MOV  [mem], imm
    C8 = ENTER n, 0
    etc.
  Pattern: 0xFF 0xFF 0x0A 0x00 0x00 appears in several = likely jump table or sentinel

zelres2 chunks 40-45:
  Similar pattern with 0xC6/0xC7/0xC8/0xC9 bytes
  Large blocks of 0x00
  Pattern at offset 59: 0x89 0x8D 0x82 = MOV [xxx], CX instructions?
  Very high zero density -> might be sparse sprite data or tables

zelres2 chunk_41 - this one DID decompress to 167 bytes of English text.
But wait - it had flag=0x8B (multi-section) and the VGA section had:
  "cess and swift r..." which is part of "You use your speed and swift reflexes"?
Actually the first analysis showed the decompressed text was:
  "Isn\t that the Crest of Glory? Please take it quickly to the owner of the weapons store."
That's NPC dialogue! But the VGA section data starts with "cess and swift r..."
Let me re-check.

Actually - looking at the output again:
zelres2 chunk_41:
  NEC section: 3784 bytes, opcode 0 (verbatim copy)
  VGA section: 36865 bytes (way beyond file size), actually only 4082-9-3784 = 289 bytes
  The decompressor returned 167 bytes from VGA section
  The decompressed content = "Isn't that the Crest of Glory?..."  <- English dialogue
  So the VGA section = English text, NEC section = Japanese text (for PC-98)

This means: zelres2 chunks 41-45 are NPC/NPC dialogue data in a 2-language format:
  NEC section = Japanese/PC-98 version of dialogue
  VGA section = English/IBM PC version of dialogue
"""
import struct
from pathlib import Path
import sys
sys.path.insert(0, 'c:/Projects/Zeliard/2_SAR/Tools')
from decompress_sar import _fill_buffer

BASE = Path('c:/Projects/Zeliard/2_SAR/ExtractedChunks')

def extract_ascii(data: bytes, min_len=3) -> list:
    results = []
    current = []
    for b in data[:2048]:
        if 0x20 <= b <= 0x7E:
            current.append(chr(b))
        else:
            if len(current) >= min_len:
                results.append(''.join(current))
            current = []
    if len(current) >= min_len:
        results.append(''.join(current))
    return results

def decompress_section(buf: bytes) -> bytes:
    return bytes(_fill_buffer(buf))

print("=== zelres2 chunk_41 DETAILED (bilingual dialogue) ===")
fpath = BASE / 'zelres2_extracted/chunk_41.bin'
data = fpath.read_bytes()
size_word = struct.unpack_from('<I', data, 0)[0]
flag = data[4]
skip_count = struct.unpack_from('<H', data, 5)[0]
read_count = struct.unpack_from('<H', data, 7)[0]
print(f"  size_field={size_word}, flag=0x{flag:02X}")
print(f"  skip_count={skip_count}, read_count={read_count}")
nec_data = data[9:9+min(skip_count, len(data)-9)]
vga_start = 9 + skip_count
vga_data = data[vga_start:vga_start+min(read_count, len(data)-vga_start)]
print(f"  Actual NEC bytes: {len(nec_data)}")
print(f"  Actual VGA bytes: {len(vga_data)}")
if nec_data:
    nec_decomp = decompress_section(nec_data)
    print(f"  NEC decompressed: {len(nec_decomp)} bytes")
    nec_ascii = extract_ascii(nec_decomp, min_len=3)
    print(f"  NEC ASCII: {nec_ascii[:5]}")
if vga_data:
    vga_decomp = decompress_section(vga_data)
    print(f"  VGA decompressed: {len(vga_decomp)} bytes")
    vga_ascii = extract_ascii(vga_decomp, min_len=3)
    print(f"  VGA text: {vga_ascii}")

print()
print("=== zelres2 chunks 40-45: check which have actual VGA data ===")
for cn in range(40, 46):
    fpath = BASE / f'zelres2_extracted/chunk_{cn:02d}.bin'
    data = fpath.read_bytes()
    size_word = struct.unpack_from('<I', data, 0)[0]
    flag = data[4]
    if flag != 0:
        skip_count = struct.unpack_from('<H', data, 5)[0]
        read_count = struct.unpack_from('<H', data, 7)[0]
        vga_start = 9 + skip_count
        vga_avail = max(0, len(data) - vga_start)
        nec_avail = min(skip_count, len(data) - 9)
        print(f"  chunk_{cn:02d}: flag=0x{flag:02X} skip={skip_count} read={read_count} "
              f"nec_avail={nec_avail} vga_avail={vga_avail}")
        if vga_avail > 0:
            vga_data = data[vga_start:vga_start+vga_avail]
            try:
                vga_decomp = decompress_section(vga_data)
                vga_ascii = extract_ascii(vga_decomp, min_len=4)
                print(f"    VGA decomp={len(vga_decomp)} ASCII: {vga_ascii[:4]}")
            except Exception as e:
                print(f"    VGA decomp error: {e}")
        if nec_avail > 0:
            nec_data = data[9:9+nec_avail]
            nec_ascii = extract_ascii(nec_data, min_len=4)
            print(f"    NEC raw ASCII: {nec_ascii[:3]}")

print()
print("=== zelres3 chunks 40-50 raw code analysis ===")
# These have 0xFF 0xFF pattern at offset 22 in all cases (jump table sentinel)
for cn in range(40, 51):
    fpath = BASE / f'zelres3_extracted/chunk_{cn:02d}.bin'
    if not fpath.exists(): continue
    data = fpath.read_bytes()
    flag = data[4]
    # Check for 0xFF 0xFF 0x0A 0x00 0x00 pattern (seen in chunks 40,41,45,48)
    has_sentinel = b'\xff\xff\x0a\x00\x00' in data[:40]
    has_sentinel2 = b'\xff\xff\x0d\x00\x00' in data[:40]
    has_sentinel3 = b'\xff\xff\x0c\x00\x00' in data[:40]
    # ASCII strings
    ascii_s = extract_ascii(data, min_len=4)
    print(f"  chunk_{cn:02d}: flag=0x{flag:02X} size={len(data)} sentinel={has_sentinel or has_sentinel2 or has_sentinel3}")
    if ascii_s:
        print(f"    ASCII: {ascii_s[:5]}")
    # Show bytes 8-28 which often contain the jump table
    print(f"    bytes[8:32]: {data[8:32].hex()}")

print()
print("=== zelres2 chunks 53-56 structure (near-miss GRPs + unknown opcode 5) ===")
for cn in [53, 54, 55, 56]:
    fpath = BASE / f'zelres2_extracted/chunk_{cn:02d}.bin'
    data = fpath.read_bytes()
    size_word = struct.unpack_from('<I', data, 0)[0]
    buf = data[5:5 + size_word - 1]
    opcode = buf[0] & 7 if buf else -1
    print(f"  chunk_{cn:02d}: raw={len(data)} buf_opcode={opcode}")
    if opcode in (0, 6, 7):
        from decompress_sar import decompress_sar_chunk
        decomp = decompress_sar_chunk(data)
        print(f"    decomp={len(decomp)}")
        # Check row alignment
        for rsize in [48, 96, 192, 240, 320]:
            if len(decomp) % rsize == 0:
                print(f"    rows: {len(decomp)//rsize} x {rsize} bytes")
        # Check if it's dual-plane GRP
        for ch in range(8, 200):
            for cl in range(8, 200):
                if ch * cl * 2 == len(decomp):
                    print(f"    GRP fit: CH={ch} CL={cl} -> {cl*8}px wide x {ch}px tall")
                    if ch * cl * 2 == len(decomp):
                        break
    elif opcode == 5:
        # opcode 5 = unknown - just show raw structure
        print(f"    opcode 5 (unknown format), buf first 32: {buf[:32].hex()}")

print()
print("=== zelres3 chunk_51 (tile index / animation table) structure ===")
fpath = BASE / 'zelres3_extracted/chunk_51.bin'
from decompress_sar import decompress_sar_chunk
data = fpath.read_bytes()
decomp = bytes(decompress_sar_chunk(data))
print(f"  decomp size: {len(decomp)}")
# The decompressed data contains sequential indices 00 01 02...
# with 0x00 separators/nulls, and the table from 200MGAME row analysis showed
# indices like 0x0B, 0x1C, etc. This might be the tile mapping table.
# Format: groups of tile indices separated by 0x00?
# Try to find structure
groups = []
current = []
for b in decomp[:512]:
    if b == 0:
        if current:
            groups.append(current)
        current = []
    else:
        current.append(b)
if current:
    groups.append(current)
print(f"  Groups delimited by 0x00 (first 512 bytes): {len(groups)} groups")
print(f"  Group lengths: {[len(g) for g in groups[:20]]}")
print(f"  First groups: {[g for g in groups[:8]]}")

# Also check if it's a 2D tile lookup table (rows = number of animation states,
# cols = number of directions)
print(f"  Row analysis:")
for rsize in [8, 9, 12, 16, 18, 24, 32, 48, 64, 96]:
    if len(decomp) % rsize == 0:
        print(f"    {len(decomp)//rsize} rows x {rsize} bytes")
