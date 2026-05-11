"""
SAR Chunk Decompressor for Zeliard (PC-98/VGA version)
Reverse engineered from Spice86 CPU trace of zeliad.exe + cross-
referenced against the brox repo (zeliard-brox/tools/MDTViewer/decoder.py).

SAR Chunk Format:
  [0-3]: LE uint32 = chunk_data_size (= total_file_size - 4)
  [4]:   flag (0=simple, non-0=multi-section VGA/NEC variant split)
  For flag==0: fill_buffer input = chunk_data[5 : 5 + chunk_data_size - 1]
  For flag!=0: bytes [5-6]=skip_count (LE), [7-8]=read_count (LE);
               fill_buffer input = chunk_data[9 + skip_count : 9 + skip_count + read_count]

fill_buffer Dispatch (041F:0DAD in game segment):
  First byte bits [2:0] = opcode (8 methods, all decoded):
    0  -> copy all remaining bytes verbatim
    1  -> lo-nibble-keyed table RLE (table terminator 0xFF)
    2  -> marker-byte RLE (hi-nibble match, count+3)
    3  -> hi-nibble-keyed table RLE (table terminator 0xFF)
    4  -> marker-byte alt RLE (lo-nibble match, count+3)
    5  -> byte-by-byte same-byte-pair RLE (count+2)
    6  -> 2-byte table RLE (terminator 0xFFFF, count+2)
    7  -> escape-byte RLE (escape+value+count → value × (count+3))

Chunk Loader Call:
  call [CS:0x010C] with:
    AL = 2: load from SAR + fill_buffer decode -> ES:DI  (most image/data chunks)
    AL = 3: load raw SAR bytes -> ES:DI  (code chunks 0-11, no decompression)
  SI = pointer to [archive_idx_byte, chunk_1indexed_byte]
       archive 0=zelres1, 1=zelres2, 2=zelres3
  DI = destination offset in game segment (0x041F)
"""

import struct
from pathlib import Path


def read_sar_offsets(sar_path: str) -> list:
    """Read all chunk offsets from a SAR archive."""
    file_size = Path(sar_path).stat().st_size
    offsets = []
    with open(sar_path, 'rb') as f:
        while True:
            data = f.read(4)
            if len(data) < 4:
                break
            val = struct.unpack('<I', data)[0]
            # Stop if offset is beyond file or goes backwards (end of table)
            if val >= file_size or (offsets and val < offsets[-1]):
                break
            offsets.append(val)
    return offsets


def read_sar_chunk(sar_path: str, chunk_index_0based: int) -> bytes:
    """Read raw chunk bytes from a SAR archive (0-based index)."""
    offsets = read_sar_offsets(sar_path)
    file_size = Path(sar_path).stat().st_size
    start = offsets[chunk_index_0based]
    end = offsets[chunk_index_0based + 1] if chunk_index_0based + 1 < len(offsets) else file_size
    with open(sar_path, 'rb') as f:
        f.seek(start)
        return f.read(end - start)


def decompress_sar_chunk(chunk_data: bytes) -> bytearray:
    """
    Decompress a SAR chunk using fill_buffer + format 5/6/7 handlers.
    Verified against Spice86 CPU trace: chunk 22 = 5786/5786 bytes match.
    """
    if len(chunk_data) < 5:
        return bytearray(chunk_data)

    size_word = struct.unpack_from('<I', chunk_data, 0)[0]
    flag = chunk_data[4]

    if flag == 0:
        # Simple: read (size_word - 1) bytes starting at offset 5
        buf = chunk_data[5:5 + size_word - 1]
    else:
        # Multi-section (VGA/NEC split): skip NEC data, read VGA data
        if len(chunk_data) < 9:
            return bytearray()
        skip_count = struct.unpack_from('<H', chunk_data, 5)[0]
        read_count = struct.unpack_from('<H', chunk_data, 7)[0]
        start = 9 + skip_count
        buf = chunk_data[start:start + read_count]

    return _fill_buffer(bytes(buf))


def _fill_buffer(buf: bytes) -> bytearray:
    """Stage-2 fill_buffer decoder (game function at 041F:0DAD)."""
    if not buf:
        return bytearray()

    opcode = buf[0] & 7
    si = 1

    if opcode == 0:
        # Copy all remaining bytes verbatim
        return bytearray(buf[si:])

    elif opcode == 1:
        # Method 1: lo-nibble-keyed table RLE (table terminator = 0xFF).
        # Walk to 0xFF, then for each byte: lo nibble = key, hi = count-2.
        # Cross-referenced from brox/MDTViewer/decoder.py.
        bp = si
        while si < len(buf) and buf[si] != 0xFF:
            si += 1
        if si < len(buf): si += 1  # skip the 0xFF
        out = bytearray()
        while si < len(buf):
            al = buf[si]; si += 1
            ah = al & 0xF0
            cx = 1
            tbp = bp
            while tbp < len(buf):
                entry_key = buf[tbp]
                if (entry_key & 0x0F) != 0:
                    break
                if ah == entry_key:
                    cx = (al & 0x0F) + 2
                    al = buf[tbp + 1]
                    break
                tbp += 2
            out.extend([al] * cx)
        return out

    elif opcode == 2:
        # Method 2: marker-byte simple RLE.  First byte = marker;
        # then bytes where (byte & 0xF0) == marker high-nibble are
        # run-length triggers (lo-nibble = count-3, next byte = value).
        if si >= len(buf):
            return bytearray()
        marker = buf[si]; si += 1
        ah = marker
        out = bytearray()
        while si < len(buf):
            al = buf[si]; si += 1
            cx = 1
            if (al & 0xF0) == ah:
                if si >= len(buf): break
                cx = (al & 0x0F) + 3
                al = buf[si]; si += 1
            out.extend([al] * cx)
        return out

    elif opcode == 3:
        # Method 3: hi-nibble-keyed table RLE (mirror of method 1).
        # Table terminator = 0xFF; lo nibble of stream byte = table key,
        # hi nibble = count-2.
        bp = si
        while si < len(buf) and buf[si] != 0xFF:
            si += 1
        if si < len(buf): si += 1
        out = bytearray()
        while si < len(buf):
            al = buf[si]; si += 1
            ah = al & 0x0F
            cx = 1
            tbp = bp
            while tbp < len(buf):
                entry_key = buf[tbp]
                if (entry_key & 0xF0) != 0:
                    break
                if ah == entry_key:
                    cx = (al >> 4) + 2
                    al = buf[tbp + 1]
                    break
                tbp += 2
            out.extend([al] * cx)
        return out

    elif opcode == 4:
        # Method 4: marker-byte alt — like method 2 but using low-nibble
        # marker check (al & 0x0F == ah).
        if si >= len(buf):
            return bytearray()
        marker = buf[si]; si += 1
        ah = marker
        out = bytearray()
        while si < len(buf):
            al = buf[si]; si += 1
            cx = 1
            if (al & 0x0F) == ah:
                if si >= len(buf): break
                cx = (al >> 4) + 3
                al = buf[si]; si += 1
            out.extend([al] * cx)
        return out

    elif opcode == 5:
        # Method 5: byte-by-byte with same-byte-followed-by-count RLE.
        # If next byte equals current, treat as run: (next_next + 2) copies.
        out = bytearray()
        while si < len(buf):
            al = buf[si]
            cx = 1
            if si + 1 < len(buf) and buf[si + 1] == al:
                if si + 2 < len(buf):
                    cx = buf[si + 2] + 2
                    si += 2
                else:
                    si += 1
            si += 1
            out.extend([al] * cx)
        return out

    elif opcode == 6:
        # Format 6: 2-byte table RLE (K=2)
        # Table: [key, val] pairs until 0xFF 0xFF terminator
        # When key byte seen in stream: read count byte, output val x (count+2)
        bp = si
        while si < len(buf) - 1:
            k, v = buf[si], buf[si + 1]; si += 2
            if k == 0xFF and v == 0xFF:
                break
        table = {}
        ti = bp
        while ti < si - 2:
            table[buf[ti]] = buf[ti + 1]; ti += 2
        out = bytearray()
        while si < len(buf):
            b = buf[si]; si += 1
            if b in table:
                count = buf[si]; si += 1
                out.extend([table[b]] * ((count & 0xFF) + 2))
            else:
                out.append(b)
        return out

    elif opcode == 7:
        # Format 7: escape-byte RLE (K=3)
        # First byte = escape marker; [escape][value][count] -> value x (count+3)
        if si >= len(buf):
            return bytearray()
        escape = buf[si]; si += 1
        out = bytearray()
        while si < len(buf):
            b = buf[si]; si += 1
            if b == escape:
                if si + 1 >= len(buf):
                    break
                value = buf[si]; si += 1
                count = buf[si]; si += 1
                out.extend([value] * ((count & 0xFF) + 3))
            else:
                out.append(b)
        return out

    else:
        print(f'WARNING: unknown fill_buffer opcode {opcode}, returning raw')
        return bytearray(buf[si:])


# ---------------------------------------------------------------------------
# CLI usage
# ---------------------------------------------------------------------------
if __name__ == '__main__':
    import sys, os

    SAR_FILES = {
        'zelres1': 'c:/Projects/Zeliard/1_OriginalGame/zelres1.sar',
        'zelres2': 'c:/Projects/Zeliard/1_OriginalGame/zelres2.sar',
        'zelres3': 'c:/Projects/Zeliard/1_OriginalGame/zelres3.sar',
    }

    if len(sys.argv) < 3:
        print('Usage: decompress_sar.py <archive> <chunk_index_0based> [output.bin]')
        print('  archive: zelres1|zelres2|zelres3')
        print('  Example: decompress_sar.py zelres1 14 nec_grp.bin')
        sys.exit(1)

    archive = sys.argv[1]
    chunk_idx = int(sys.argv[2])
    output_path = sys.argv[3] if len(sys.argv) > 3 else f'chunk_{chunk_idx:02d}_decomp.bin'

    sar_path = SAR_FILES.get(archive)
    if not sar_path or not os.path.exists(sar_path):
        print(f'SAR file not found: {sar_path}')
        sys.exit(1)

    chunk_data = read_sar_chunk(sar_path, chunk_idx)
    result = decompress_sar_chunk(chunk_data)

    with open(output_path, 'wb') as f:
        f.write(result)

    print(f'chunk {chunk_idx} from {archive}: input={len(chunk_data)}, output={len(result)} -> {output_path}')
