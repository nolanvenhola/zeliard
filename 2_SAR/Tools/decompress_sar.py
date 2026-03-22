"""
SAR Chunk Decompressor for Zeliard (PC-98/VGA version)
Reverse engineered from Spice86 CPU trace of zeliad.exe

SAR Chunk Format:
  [0-3]: LE uint32 = chunk_data_size (= total_file_size - 4)
  [4]:   flag (0=simple, non-0=multi-section VGA/NEC variant split)
  For flag==0: fill_buffer input = chunk_data[5 : 5 + chunk_data_size - 1]
  For flag!=0: bytes [5-6]=skip_count (LE), [7-8]=read_count (LE);
               fill_buffer input = chunk_data[9 + skip_count : 9 + skip_count + read_count]

fill_buffer Dispatch (041F:0DAD in game segment):
  First byte bits [2:0] = opcode:
    0  -> copy all remaining bytes verbatim
    3  -> format 5 (nibble-table RLE, count+2)
    6  -> format 6 (2-byte table RLE, count+2)  [KEY: K=2]
    7  -> format 7 (escape-byte RLE, count+3)   [KEY: K=3]

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


def read_sar_chunk(sar_path: str, chunk_index_0based: int) -> bytes:
    """Read raw chunk bytes from a SAR archive (0-based index)."""
    with open(sar_path, 'rb') as f:
        offsets = struct.unpack('<40I', f.read(160))
    with open(sar_path, 'rb') as f:
        start = offsets[chunk_index_0based]
        end = offsets[chunk_index_0based + 1] if chunk_index_0based + 1 < 40 else Path(sar_path).stat().st_size
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

    elif opcode == 3:
        # Format 5: nibble-based table RLE (K=2)
        # Table: [lo_nibble_key, val_byte] pairs until 0xFF terminator
        bp = si
        while si < len(buf):
            b = buf[si]; si += 1
            if b == 0xFF:
                break
            si += 1  # skip value byte
        out = bytearray()
        while si < len(buf):
            b = buf[si]; si += 1
            lo = b & 0x0F  # low nibble = table key
            cx = 1
            tp = bp
            while tp < len(buf):
                te = buf[tp]
                if te & 0xF0:  # high nibble set -> end of table
                    break
                if (te & 0x0F) == lo:
                    cx = ((b >> 4) & 0x0F) + 2  # high nibble = count, +2
                    b = buf[tp + 1]              # value from table
                    break
                tp += 2
            out.extend([b] * cx)
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
