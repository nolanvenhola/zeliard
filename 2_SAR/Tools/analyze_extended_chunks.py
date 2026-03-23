"""
Analyze extended SAR chunks for Zeliard:
  zelres2: chunks 40-57 (skip 50)
  zelres3: chunks 40-95 (skip 56)

For each chunk: decompress, report size, opcode, first bytes, ASCII strings,
and make a best-guess at content type.

Known filename table from 200MGAME.asm (leading byte is chunk index as char/hex):
  zelres2 (archive 2, prefix char):
    '4'(0x34=52)  FMAN.GRP
    '5'(0x35=53)  ROKA.GRP
    '6'(0x36=54)  ... (not listed — missing)
    '7'(0x37=55)  DCHR.GRP
    '8'(0x38=56)  ENCNT.GRP
    '9'(0x39=57)  ENP1.GRP
    'A'(0x41=65)  CRAB.GRP  <- wait, these are 1-indexed in SAR

  Actually: the leading byte in the filename table encodes the 1-indexed chunk
  reference. Looking at known zelres2 sprite chunks (18-35 = 0x12-0x23 = 0-indexed),
  the SAR reference is 1-indexed, so chunk_34 = SAR ref 0x23 = 35.

  From 250GMENG filename table (these are 1-indexed SAR chunk numbers stored as chars):
    '!'(0x21=33) -> waku.grp  -> zelres2 chunk 32 (0-based)
    sei.grp                   -> chunk 28 (0x1C from hex in data)
    '&'(0x26=38) -> yuup.grp  -> chunk 37 (0-based)
    0x1D         -> seip.grp  -> chunk 28 (0-based)? No...

  Actually re-reading: after '!waku.grp', the bytes are 0x00 0x00 0x1C...
  The string format appears to be:
    [archive_byte] [chunk_1indexed_byte] [name_string] [0x00]
  Where archive: 0=zelres1, 1=zelres2, 2=zelres3... wait, looking at the CMAN.GRP entry:
    db 00h, 01h, 1Fh
    db 'CMAN.GRP'
  That's: 00=separator, 01=?, 1Fh=31=zelres2 chunk 30 (0-based), then string.

  Actually from 200MGAME.asm at 7522-7661, pattern is:
    [0xFF or 0x00] [len or unused] [archive:1=zelres1,2=zelres2] [chunk_1indexed?]
    then string

  Better approach: decode from what I can see:
    '4FMAN.GRP'   + ', 0, 2' after = archive 2, that leading '4'=0x34 must be chunk ref
    '8ENCNT.GRP'  + ', 0, 2'
    '5ROKA.GRP'   + ', 0, 1' = archive 1
    ':ROKA.GRP'   + ', 0, 2'
    '7DCHR.GRP'   + ', 0, 2'

  Wait - the pattern at 7522-7523 is:
    db 0FFh, 02h       <- possibly: 0xFF terminator for prior record, then 0x02=archive?
    db '4FMAN.GRP'     <- '4'=0x34=52 decimal = chunk index? No, SAR has only 40 chunks max per archive
    db 0, 2            <- 0x00 separator, 0x02 = archive zelres2?

  Hmm, '4'=0x34=52 is too large for a 40-chunk SAR. Maybe the leading char is the
  chunk 1-indexed number (1-40), represented as ASCII with an offset?

  Comparing with 250GMENG sprite table where '!'=0x21=33 maps to waku.grp:
  waku.grp is zelres2 chunk 32 (0-indexed) = chunk 33 (1-indexed) = 0x21 = '!' YES!

  So the scheme is: leading byte = 1-indexed chunk number stored as a raw byte (NOT ASCII decimal).
  '!'=0x21=33 decimal -> chunk 33 (1-indexed) = chunk 32 (0-based) = waku.grp in zelres2 ✓
  '&'=0x26=38 decimal -> chunk 38 (1-indexed) = chunk 37 (0-based) = yuup.grp ✓ (chunk_37)
  '4'=0x34=52 decimal -> chunk 52 (1-indexed) = chunk 51 (0-based) = FMAN.GRP in zelres2 ✓
  '5'=0x35=53 decimal -> chunk 53 (1-indexed) = chunk 52 (0-based) = ROKA.GRP zelres1?

  From 200MGAME at 7522-7661 (archive indicator after string = the 0, 1 or 0, 2):
    db 0FFh, 02h      <- 0xFF record separator, then archive prefix embedded?
    db '4FMAN.GRP'    -> chunk 52 (1-indexed) = zelres2 chunk 51 (0-based) = FMAN.GRP, arch=zelres2
    db 0, 2           <- 0x00, archive_idx=2
    db '8ENCNT.GRP'   -> chunk 56 (1-indexed) = zelres2 chunk 55 (0-based), arch=zelres2 (after 0,2)
    db 0, 2
    db '5ROKA.GRP'    -> chunk 53 (1-indexed) = chunk 52 (0-based), arch=1=zelres1?? But ROKA is in zelres2 too
    db 0, 1           <- archive 1? Strange...

  Hmm let me just look at the actual data: after FMAN+0,2 and ENCNT+0,2, then ROKA+0,1.
  archive 1=zelres2, 2=zelres3 (offset by 1 since zelres1=0)?
  No: from memory.md: archive 0=zelres1, 1=zelres2, 2=zelres3.

  Then db '5ROKA.GRP' + db 0, 1: chunk 53 (1-indexed), archive zelres2 (idx=1)
       = zelres2 chunk 52 (0-based) = ROKA.GRP  ✓ that makes sense!

  So corrected mapping (1-indexed chunk numbers = raw byte value of leading char):
    zelres2 (archive=1 in game loader):
      '4'=0x34=52 -> chunk 51 (0-based): FMAN.GRP  (= zelres2 chunk_51)
      '5'=0x35=53 -> chunk 52 (0-based): ROKA.GRP (one instance)
      '6'=...     -> ?
      '7'=0x37=55 -> chunk 54 (0-based): DCHR.GRP
      '8'=0x38=56 -> chunk 55 (0-based): ENCNT.GRP
      ':'=0x3A=58 -> chunk 57 (0-based): ROKA.GRP (zelres2, second instance)
      '9'=0x39=57 -> chunk 56 (0-based): NOTE - chunk_56 listed as code in prompt!
        '9ENP1.GRP' + 0,2: 0x39=57, arch=2=zelres3? Chunk 56 (0-based) in zelres3!

  Wait - the entries at 7598+ have archive=2 (zelres3):
      '9ENP1.GRP' 0,2  -> zelres3 chunk 56 (0-based)... but that's listed as code!

  Hmm, re-reading: chunk_56 of zelres3 is code. The 1-indexed = 57 = 0x39.
  '9'=0x39=57 (1-indexed) = chunk 56 (0-based) in zelres3 = code. So ENP1.GRP is
  stored as a code chunk? That seems odd for a .GRP image.

  More likely: archive index 1=zelres2, 2=zelres3, and the relationship is correct.
  Let me just build the name map from the raw decoded data and focus on actual chunk analysis.
"""

import struct
from pathlib import Path
import sys

# ──────────────────────────────────────────────────────────────────────────────
# Decompressor (from decompress_sar.py)
# ──────────────────────────────────────────────────────────────────────────────

def _fill_buffer(buf: bytes) -> bytearray:
    if not buf:
        return bytearray()
    opcode = buf[0] & 7
    si = 1
    if opcode == 0:
        return bytearray(buf[si:])
    elif opcode == 3:
        bp = si
        while si < len(buf):
            b = buf[si]; si += 1
            if b == 0xFF: break
            si += 1
        out = bytearray()
        while si < len(buf):
            b = buf[si]; si += 1
            lo = b & 0x0F
            cx = 1
            tp = bp
            while tp < len(buf):
                te = buf[tp]
                if te & 0xF0: break
                if (te & 0x0F) == lo:
                    cx = ((b >> 4) & 0x0F) + 2
                    b = buf[tp + 1]
                    break
                tp += 2
            out.extend([b] * cx)
        return out
    elif opcode == 6:
        bp = si
        while si < len(buf) - 1:
            k, v = buf[si], buf[si+1]; si += 2
            if k == 0xFF and v == 0xFF: break
        table = {}
        ti = bp
        while ti < si - 2:
            table[buf[ti]] = buf[ti+1]; ti += 2
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
        if si >= len(buf): return bytearray()
        escape = buf[si]; si += 1
        out = bytearray()
        while si < len(buf):
            b = buf[si]; si += 1
            if b == escape:
                if si + 1 >= len(buf): break
                value = buf[si]; si += 1
                count = buf[si]; si += 1
                out.extend([value] * ((count & 0xFF) + 3))
            else:
                out.append(b)
        return out
    else:
        return bytearray(buf[si:])


def decompress_chunk(data: bytes):
    """Returns (decompressed_bytes, opcode, flag, raw_size)"""
    if len(data) < 5:
        return bytearray(data), -1, data[4] if len(data) > 4 else -1, len(data)
    size_word = struct.unpack_from('<I', data, 0)[0]
    flag = data[4]
    raw_size = len(data)
    if flag == 0:
        buf = data[5:5 + size_word - 1]
    else:
        if len(data) < 9:
            return bytearray(), -1, flag, raw_size
        skip_count = struct.unpack_from('<H', data, 5)[0]
        read_count = struct.unpack_from('<H', data, 7)[0]
        start = 9 + skip_count
        buf = data[start:start + read_count]
    opcode = buf[0] & 7 if buf else -1
    result = _fill_buffer(bytes(buf))
    return result, opcode, flag, raw_size


# ──────────────────────────────────────────────────────────────────────────────
# Content classifier
# ──────────────────────────────────────────────────────────────────────────────

# GRP image sizes known from reverse engineering:
# 2-plane 1bpp: size = 2 * CH * CL where CL = width//8
# Known: title logo CH=65, CL=112 -> 14560 bytes (2*7280)
# 320x200 VGA framebuffer = 64000 bytes
# Map tile: typically rows of 48 or 96 bytes
# MSD music data: typically starts with timing/sequence data

KNOWN_IMAGE_DIMS = []
for w in range(8, 1024, 8):
    for h in [8, 16, 24, 32, 48, 56, 64, 65, 72, 80, 96, 100, 112, 128, 144, 160, 176, 192, 200, 208, 224, 240, 256]:
        size = 2 * h * (w // 8)
        if 1000 <= size <= 200000:
            KNOWN_IMAGE_DIMS.append((size, w, h))

SPRITE_ROW_SIZES = [48, 96, 192, 240, 384]  # known sprite sheet row widths
MAP_ROW_SIZES    = [40, 60, 80, 100, 120, 160, 240, 320]  # plausible map widths

def extract_ascii(data: bytes, min_len=4, max_bytes=512) -> list[str]:
    """Extract printable ASCII runs of at least min_len chars."""
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

def count_byte_distribution(data: bytes) -> dict:
    """Returns fraction of bytes that are: zero, low(0-31), printable, high(>127)"""
    if not data: return {}
    n = len(data)
    zeros   = sum(1 for b in data if b == 0)
    low     = sum(1 for b in data if 0 < b < 32)
    printable = sum(1 for b in data if 0x20 <= b <= 0x7E)
    high    = sum(1 for b in data if b > 127)
    return {
        'zeros':    zeros/n,
        'low':      low/n,
        'printable':printable/n,
        'high':     high/n,
    }

def detect_row_alignment(data: bytes, max_rows=10) -> list[tuple[int,int]]:
    """Find row sizes where bytes repeat perfectly: check if data[0:N] == data[N:2N]"""
    hits = []
    for rsize in range(24, min(len(data)//2, 1024), 2):
        if len(data) % rsize == 0:
            rows = len(data) // rsize
            if rows < 4: continue
            # Check if row 0 and row 1 start with same first 4 bytes (would indicate uniform fill)
            # Instead check if size divides cleanly and first few rows look structured
            hits.append((rsize, rows))
            if len(hits) >= max_rows:
                break
    return hits

def classify_content(data: bytes, raw_size: int, chunk_num: int) -> str:
    """Classify chunk content based on size and structure."""
    n = len(data)
    if n == 0:
        return 'EMPTY'

    dist = count_byte_distribution(data)
    ascii_strings = extract_ascii(data, min_len=4)

    # Check for text/dialogue content
    if dist['printable'] > 0.6:
        return 'TEXT/DIALOGUE'

    # Check for MSD music data - starts with specific patterns
    # MSD files in Zeliard typically have a specific header
    if len(data) > 4:
        # Check for music-like structure (many repetitive small values)
        pass

    # VGA framebuffer
    if n == 64000:
        return 'VGA_FRAMEBUFFER (320x200)'

    # Check exact GRP image sizes (2-plane 1bpp)
    matches = [(w, h) for (s, w, h) in KNOWN_IMAGE_DIMS if s == n]
    if matches:
        best = sorted(matches, key=lambda x: abs(x[0]*x[1] - 320*200))[:3]
        dims_str = ', '.join(f'{w}x{h}' for w,h in best)
        return f'GRP_IMAGE candidate: {dims_str} (2-plane 1bpp)'

    # Near-matches for GRP
    near = [(w, h) for (s, w, h) in KNOWN_IMAGE_DIMS if abs(s - n) <= 16]
    if near:
        best = sorted(near, key=lambda x: abs(x[0]*x[1] - 320*200))[:2]
        dims_str = ', '.join(f'{w}x{h}' for w,h in best)
        return f'GRP_IMAGE near-match: {dims_str}'

    # Check sprite sheet patterns (48-byte rows known from zelres2)
    for rsize in [48, 96, 192, 336, 384]:
        if n % rsize == 0:
            rows = n // rsize
            if 4 <= rows <= 512:
                return f'SPRITE_SHEET likely: {rsize}-byte rows x {rows} rows'

    # Check for map data (rectangular tile grid)
    for rsize in [40, 60, 80, 96, 100, 120, 160, 200, 240, 256, 320, 384]:
        if n % rsize == 0:
            rows = n // rsize
            if 8 <= rows <= 256:
                return f'MAP_DATA candidate: {rsize}-byte rows x {rows} rows'

    # Check for audio / MSD
    if n < 32000 and dist['zeros'] > 0.1 and dist['high'] < 0.3:
        # MSD music files tend to be moderate size with some zero bytes
        if 500 <= n <= 20000:
            return f'MUSIC_MSD candidate (size={n})'

    # Large chunks = likely level graphics data or another GRP
    if n > 30000:
        for rsize in [320, 256, 128, 192, 240]:
            if n % rsize == 0:
                rows = n // rsize
                return f'LARGE_GRAPHIC: {rsize}-byte rows x {rows} (possibly level tiles)'

    return f'UNKNOWN (size={n}, zeros={dist["zeros"]:.1%}, printable={dist["printable"]:.1%})'


# ──────────────────────────────────────────────────────────────────────────────
# Known filenames decoded from ASM filename tables
# Format: leading byte = 1-indexed chunk number; archive embedded as last byte(s)
#
# From 200MGAME.asm (zelres2 archive=1, zelres3 archive=2):
#   (These are 1-indexed chunk numbers; chunk_NN_bin = N-1)
#   zelres2 chunks (archive suffix 0,1 or 0,2):
#     chunk_51 = FMAN.GRP  (0x34='4')  arch=2? actually looking at context...
#
# Simplified: I'll build the map from what's definitively readable
# ──────────────────────────────────────────────────────────────────────────────

# From 250GMENG.asm sprite filename table:
# Format: [1indexed_chunk_raw_byte][name][0x00][0x00][archive_idx_byte]
# '!'=33 -> chunk 32 (0-based) waku.grp (zelres2, since 0x1C in the middle byte?)
# Actually looking at bytes: 00h 00h 1Ch = archive=0, something, chunk=0x1C=28?
# Let me use what's unambiguous from 200MGAME.asm

# From 200MGAME at lines 7522-7661, pattern after each filename:
#   db 0, N  where N=1 means zelres2 (archive index 1) and N=2 means zelres3 (archive 2)
# The leading byte of each string = 1-indexed chunk number (raw byte, not ASCII decimal)

# zelres2 (N=1 after 0x00 separator):
ZELRES2_NAMES = {
    # From 200MGAME.asm sprite table (archive=1=zelres2):
    # (0-based chunk index): name
    # From 250GMENG.asm:
    31: 'waku.grp',      # '!'=0x21=33(1-indexed) -> chunk 32(0-based)...
    # wait: '!'=0x21=33dec, 1-indexed=33, 0-based=32
    # But chunks 0-39 are in zelres2 (40 entries). Extended = 40-57.
    # So waku.grp at chunk 32 is in the 0-39 range, already known.

    # From 200MGAME (archive=1=zelres2, leading byte=1-indexed):
    51: 'FMAN.GRP',      # '4'=0x34=52(1-indexed)->chunk 51(0-based) -> zelres2 chunk_51 ✓
    52: 'ROKA.GRP',      # '5'=0x35=53->chunk 52
    54: 'DCHR.GRP',      # '7'=0x37=55->chunk 54
    55: 'ENCNT.GRP',     # '8'=0x38=56->chunk 55
    57: 'ROKA2.GRP',     # ':'=0x3A=58->chunk 57 (second ROKA.GRP entry)

    # From 200MGAME archive=2 entries labeled zelres2 (MMAN/CMAN with 0x1E/0x1F):
    # db 00h, 01h, 1Eh / db 'MMAN.GRP' -> archive=1, chunk=0x1E=30(1-indexed)->chunk 29(0-based)
    # db 00h, 01h, 1Fh / db 'CMAN.GRP' -> archive=1, chunk=0x1F=31->chunk 30(0-based)
    # These are in 0-39 range already.

    # Additional from other entries (archive suffix 0,2=zelres3):
    # Will be handled in zelres3 map below
}

# zelres3 (N=2 after 0x00 separator or archive byte = 2):
ZELRES3_NAMES = {
    # From 200MGAME.asm (archive=2=zelres3):
    # '9'=0x39=57(1-indexed)->chunk 56(0-based): ENP1.GRP  [listed as code in prompt!]
    # 'A'=0x41=65(1-indexed)->chunk 64(0-based): CRAB.GRP
    # etc.
    56: 'ENP1.GRP',     # '9'=0x39=57->chunk56(0-based), arch=zelres3
    # But prompt says chunk_56 is code in zelres3... will verify via flag byte

    # From 200MGAME pairs (archive=2):
    # 'A'(0x41=65)->chunk64: CRAB.GRP
    # ':'(0x3A=58)->ENP2.GRP
    # 'B'(0x42=66)->TAKO.GRP
    # ';'(0x3B=59)->ENP3.GRP
    # 'C'(0x43=67)->TORI.GRP
    # '<'(0x3C=60)->ENP4.GRP
    # 'D'(0x44=68)->ZELA.GRP
    # '='(0x3D=61)->ENP5.GRP
    # 'E'(0x45=69)->MEDA.GRP
    # '>'(0x3E=62)->ENP6.GRP
    # 'F'(0x46=70)->LEGA.GRP
    # '?'(0x3F=63)->ENP7.GRP
    # 'G'(0x47=71)->DRGN.GRP
    # '@'(0x40=64)->ENP8.GRP
    # 'H'(0x48=72)->AKMA.GRP
    # 'I'(0x49=73)->MAO1.GRP
    # 'J'(0x4A=74)->MAO2.GRP
    57: 'ENP2.GRP',     # ':'=0x3A=58->chunk57
    58: 'ENP3.GRP',     # ';'=0x3B=59->chunk58
    59: 'ENP4.GRP',     # '<'=0x3C=60->chunk59
    60: 'ENP5.GRP',     # '='=0x3D=61->chunk60
    61: 'ENP6.GRP',     # '>'=0x3E=62->chunk61
    62: 'ENP7.GRP',     # '?'=0x3F=63->chunk62
    63: 'ENP8.GRP',     # '@'=0x40=64->chunk63
    64: 'CRAB.GRP',     # 'A'=0x41=65->chunk64
    65: 'TAKO.GRP',     # 'B'=0x42=66->chunk65
    66: 'TORI.GRP',     # 'C'=0x43=67->chunk66
    67: 'ZELA.GRP',     # 'D'=0x44=68->chunk67
    68: 'MEDA.GRP',     # 'E'=0x45=69->chunk68
    69: 'LEGA.GRP',     # 'F'=0x46=70->chunk69
    70: 'DRGN.GRP',     # 'G'=0x47=71->chunk70
    71: 'AKMA.GRP',     # 'H'=0x48=72->chunk71
    72: 'MAO1.GRP',     # 'I'=0x49=73->chunk72
    73: 'MAO2.GRP',     # 'J'=0x4A=74->chunk73

    # MSD music chunks (from 200MGAME archive=1=zelres2 for music? No...):
    # '/MGT1.MSD' with 0,1 -> '/'=0x2F=47->chunk46(0-based), archive=zelres2
    # '1UGM1.MSD' -> '1'=0x31=49->chunk48, archive=zelres2
    # '0MGT2.MSD' -> '0'=0x30=48->chunk47, archive=zelres2
    # '2UGM2.MSD' -> '2'=0x32=50->chunk49, archive=zelres2
    # 'VMUS1.MSD' -> 'V'=0x56=86->chunk85, archive=zelres3? (after 0,2)
    # 'WMUS2.MSD'  -> 'W'=0x57=87->chunk86
    # etc.

    # From 300LVLLD.asm at line 594-596:
    # db '_MFAN.MSD' + db 0,2 -> '_'=0x5F=95->chunk94(0-based), arch=2=zelres3
    # db '6DMAN.GRP' + db 0,2 -> '6'=0x36=54->chunk53(0-based), arch=2=zelres3?
    # Wait, 54(1-indexed) = chunk53(0-based) for zelres3

    # Actually looking at 300LVLLD more carefully:
    # db 02h / db '_MFAN.MSD' / db 0, 2  = archive? and then:
    # db '6DMAN.GRP' -> '6'=0x36=54(1-indexed)->chunk53(0-based)
    # These are in zelres3 since the 300LVLLD is zelres3 code.
    53: 'DMAN.GRP',     # '6'=0x36=54->chunk53, zelres3 level character graphics
    94: 'MFAN.MSD',     # '_'=0x5F=95->chunk94, zelres3 music

    # ZEL2.BIN entries:
    # db 00h, 02h, 10h / db 'ZEL2.BIN' -> archive=2, chunk=0x10=16(1-indexed)->chunk15?
    # That's in 0-39 range.
}

# zelres2 MSD music chunks (from 200MGAME with archive=1):
ZELRES2_MUSIC = {
    46: 'MGT1.MSD',     # '/'=0x2F=47->chunk46
    47: 'MGT2.MSD',     # '0'=0x30=48->chunk47
    48: 'UGM1.MSD',     # '1'=0x31=49->chunk48
    49: 'UGM2.MSD',     # '2'=0x32=50->chunk49
}

# zelres3 MSD music chunks (from 200MGAME with archive=2):
ZELRES3_MUSIC = {
    # 'VMUS1.MSD' 0,2 -> 'V'=0x56=86(1-indexed)->chunk85(0-based), arch=zelres3
    # 'WMUS2.MSD'     -> 'W'=87->chunk86
    # 'XMUS3.MSD'     -> 'X'=88->chunk87
    # 'YMUS4.MSD'     -> 'Y'=89->chunk88
    # 'ZMUS5.MSD'     -> 'Z'=90->chunk89
    # '[MUS6.MSD'     -> '['=91->chunk90
    # '\MUS7.MSD'     -> '\'=92->chunk91
    # ']MUS8.MSD'     -> ']'=93->chunk92
    # '^MBOS.MSD'     -> '^'=94->chunk93
    # '`MMAO.MSD'     -> '`'=96->chunk95
    85: 'MUS1.MSD',
    86: 'MUS2.MSD',
    87: 'MUS3.MSD',
    88: 'MUS4.MSD',
    89: 'MUS5.MSD',
    90: 'MUS6.MSD',
    91: 'MUS7.MSD',
    92: 'MUS8.MSD',
    93: 'MBOS.MSD',
    95: 'MMAO.MSD',
    # chunk94 = MFAN.MSD from 300LVLLD
}

# zelres3 ZEL2 / MPPN map pages (from 200MGAME with various archives):
# 'KMPP1.GRP' + 0,2: 'K'=0x4B=75->chunk74(0-based), arch=zelres3
# 'LMPP2.GRP'       'L'=0x4C=76->chunk75
# 'MMPP3.GRP'       'M'=0x4D=77->chunk76
# 'NMPP4.GRP'       'N'=0x4E=78->chunk77
# 'OMPP5.GRP'       'O'=0x4F=79->chunk78
# 'PMPP6.GRP'       'P'=0x50=80->chunk79
# 'QMPP7.GRP'       'Q'=0x51=81->chunk80
# 'RMPP8.GRP'       'R'=0x52=82->chunk81
# 'SMPP9.GRP'       'S'=0x53=83->chunk82
# 'TMPPA.GRP'       'T'=0x54=84->chunk83
# 'UMPPB.GRP'       'U'=0x55=85->chunk84
ZELRES3_MAPS = {
    74: 'MPP1.GRP',   # map page 1
    75: 'MPP2.GRP',   # map page 2
    76: 'MPP3.GRP',   # map page 3
    77: 'MPP4.GRP',   # map page 4
    78: 'MPP5.GRP',   # map page 5
    79: 'MPP6.GRP',   # map page 6
    80: 'MPP7.GRP',   # map page 7
    81: 'MPP8.GRP',   # map page 8
    82: 'MPP9.GRP',   # map page 9
    83: 'MPPA.GRP',   # map page A
    84: 'MPPB.GRP',   # map page B
}

# zelres3 BIN encounter data (from 200MGAME):
# 'EAI1.BIN' + 0,2: 'E'=0x45=69->chunk68... wait that conflicts with MEDA
# Actually: 'EAI1.BIN' is followed by 0, 2, 2 (note: 3 bytes - archive=2, chunk=2?)
# Looking at the raw: db 'EAI1.BIN' / db 0, 2 / db 0Ah, 'CRAB.BIN' / db 0, 2, 3
# Hmm the pattern is messier. The '.BIN' entries map to animated enemy encounter data.
# 'EAI1.BIN' + 0,2,2 -> archive=2, something=2, or archive=2 chunk=2?
# More likely: EAI1 chunk=2+1=3 in zelres3? That's chunk02 which is code range.
# These BIN files might not be in SAR at all - maybe loaded from disk directly.
# Skip for now and focus on the GRP/MSD mapping which is clearer.


def get_known_name(archive: str, chunk_0based: int) -> str:
    """Return known filename for a chunk if we have it."""
    if archive == 'zelres2':
        n = ZELRES2_NAMES.get(chunk_0based, '')
        m = ZELRES2_MUSIC.get(chunk_0based, '')
        return n or m
    elif archive == 'zelres3':
        n = ZELRES3_NAMES.get(chunk_0based, '')
        m = ZELRES3_MUSIC.get(chunk_0based, '')
        p = ZELRES3_MAPS.get(chunk_0based, '')
        return n or m or p
    return ''


# ──────────────────────────────────────────────────────────────────────────────
# Main analysis
# ──────────────────────────────────────────────────────────────────────────────

BASE = Path('c:/Projects/Zeliard/2_SAR/ExtractedChunks')

TARGETS = {
    'zelres2': {
        'dir': BASE / 'zelres2_extracted',
        'chunks': list(range(40, 58)),  # 40..57
        'skip': {50},  # code chunk
    },
    'zelres3': {
        'dir': BASE / 'zelres3_extracted',
        'chunks': list(range(40, 96)),  # 40..95
        'skip': {56},  # code chunk
    },
}

OPCODE_NAMES = {0: 'verbatim', 3: 'nibble-RLE', 6: '2byte-RLE', 7: 'escape-RLE', -1: 'N/A'}

def analyze_all():
    print("=" * 110)
    print(f"{'ARCHIVE':<10} {'CHUNK':>5} {'KNOWN_NAME':<16} {'RAW_SZ':>8} {'DECOMP_SZ':>10} {'OPC':<12} {'FLAG':<5} {'CONTENT_TYPE'}")
    print("=" * 110)

    results = {}

    for archive, cfg in TARGETS.items():
        d = cfg['dir']
        skip = cfg['skip']
        results[archive] = []

        for chunk_num in cfg['chunks']:
            if chunk_num in skip:
                print(f"{archive:<10} {chunk_num:>5} {'(code-skip)':<16} {'':>8} {'':>10} {'':12} {'':5} [CODE CHUNK - SKIPPED]")
                continue

            fpath = d / f'chunk_{chunk_num:02d}.bin'
            if not fpath.exists():
                print(f"{archive:<10} {chunk_num:>5} {'':16} {'':>8} {'':>10} {'':12} {'':5} [FILE NOT FOUND]")
                continue

            raw = fpath.read_bytes()
            if len(raw) < 5:
                print(f"{archive:<10} {chunk_num:>5} {'':16} {len(raw):>8} {'':>10} {'':12} {'':5} [TOO SMALL]")
                continue

            decomp, opcode, flag, raw_size = decompress_chunk(raw)
            known = get_known_name(archive, chunk_num)
            opname = OPCODE_NAMES.get(opcode, f'opc{opcode}')
            content = classify_content(bytes(decomp), raw_size, chunk_num)

            print(f"{archive:<10} {chunk_num:>5} {known:<16} {raw_size:>8} {len(decomp):>10} {opname:<12} {flag:<5} {content}")

            results[archive].append({
                'chunk': chunk_num,
                'known': known,
                'raw_size': raw_size,
                'decomp_size': len(decomp),
                'opcode': opcode,
                'flag': flag,
                'content_type': content,
                'first32': decomp[:32].hex() if decomp else '',
                'ascii': extract_ascii(bytes(decomp), min_len=4),
            })

    print()
    print("=" * 110)
    print("DETAILED VIEW (first 32 bytes decomp + ASCII strings)")
    print("=" * 110)

    for archive, chunks in results.items():
        for r in chunks:
            print(f"\n{archive} chunk_{r['chunk']:02d}  known={r['known'] or 'UNKNOWN'}  "
                  f"raw={r['raw_size']}  decomp={r['decomp_size']}  "
                  f"opcode={OPCODE_NAMES.get(r['opcode'], r['opcode'])}  flag=0x{r['flag']:02X}")
            print(f"  First32: {r['first32']}")
            if r['ascii']:
                print(f"  ASCII:   {r['ascii'][:8]}")
            print(f"  Type:    {r['content_type']}")

    return results

if __name__ == '__main__':
    analyze_all()
