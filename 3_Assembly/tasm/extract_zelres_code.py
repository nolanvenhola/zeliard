#!/usr/bin/env python3
"""
extract_zelres_code.py — Extract code chunks from zelres SAR archives as raw .bin files.

Usage:
  python extract_zelres_code.py [--dry-run]

Places extracted .bin files in:
  3_Assembly/tasm/working/zelresN/code/
  3_Assembly/tasm/bin/zelresN/

Naming convention: {archive_num}{chunk_0idx:02d}{NAME}.bin
  where NAME is from the known_names table or 'UNKN' if unidentified.

Code chunks are stored RAW in the SAR (no decompression needed, AL=3 loader).
Data chunks (sprites, maps, tiles) are skipped — they are not executable programs.
"""

import sys, os, struct, shutil
from pathlib import Path

ROOT = Path(__file__).parent
SAR_DIR = ROOT.parent.parent / '1_OriginalGame'
WORKING = ROOT / 'working'
BIN_DIR = ROOT / 'bin'

sys.path.insert(0, str(ROOT.parent.parent / '2_SAR/Tools'))
from decompress_sar import read_sar_offsets, read_sar_chunk

DRY_RUN = '--dry-run' in sys.argv

# ---- Known names (0-indexed chunk -> stem suffix) ----
# zelres1: chunks 0-11 already extracted; 12+ are DATA (not code)
ZELRES1_NAMES = {
    0: 'OPDMO',   # 100OPDMO - opening demo
    1: 'GDEGA',   # 101GDEGA - image controller EGA
    2: 'GDCGA',   # 102GDCGA - image controller CGA
    3: 'GDHGC',   # 103GDHGC - image controller HGC
    4: 'GDTGA',   # 104GDTGA - image controller TGA
    5: 'GDMCA',   # 105GDMCA - image controller MCGA
    6: 'TOWNB',   # 106TOWNB - town main module
    7: 'GTEGA',   # 107GTEGA - town tiles EGA
    8: 'GTCGA',   # 108GTCGA - town tiles CGA
    9: 'GTHGC',   # 109GTHGC - town tiles HGC
    10: 'GTTGA',  # 110GTTGA - town tiles TGA
    11: 'GTMCA',  # 111GTMCA - town tiles MCGA (SMALL_IMAGE_RENDERER)
    24: 'UTILA',  # 124UTILA - utility module A
    30: 'UTILB',  # 130UTILB - utility module B
}
ZELRES1_CODE_CHUNKS = set(ZELRES1_NAMES.keys())  # only these are code; rest are data

# zelres2: chunks 0-17 are code programs; 18+ are DATA
ZELRES2_NAMES = {
    0: 'FIGHT',   # 200FIGHT - main game fight/loop
    1: 'SELCT',   # 201SELCT - character select
    2: 'GFEGA',   # 202GFEGA - graphics fill EGA
    3: 'GFCGA',   # 203GFCGA - graphics fill CGA
    4: 'GFHGC',   # 204GFHGC - graphics fill HGC
    5: 'GFTGA',   # 205GFTGA - graphics fill TGA
    6: 'GFMCA',   # 206GFMCA - graphics fill MCGA
    7: 'MOLEB',   # 207MOLEB - enemy AI (molebear)
    8: 'SATNO',   # 208SATNO - enemy AI (satyr)
    9: 'BOSQE',   # 209BOSQE - boss encounter
    10: 'HELDA',  # 210HELDA - KINGPRO.BIN (king dialog/palace)
    11: 'OMOYP',  # 211OMOYP - OMOYPRO.BIN (Omoy shop)
    12: 'TUMBA',  # 212TUMBA - ARMRPRO.BIN (armorer shop)
    13: 'DORDO',  # 213DORDO - BANKPRO.BIN (bank)
    14: 'LLAMA',  # 214LLAMA - CHURPRO.BIN (church/healer)
    15: 'PUREZ',  # 215PUREZ - DRUGPRO.BIN (apothecary)
    16: 'CNGJO',  # 216CNGJO - INNAPRO.BIN (inn)
    17: 'PULPO',  # 217PULPO - KENJPRO.BIN (sword shop)
}
ZELRES2_CODE_CHUNKS = set(ZELRES2_NAMES.keys())

# zelres3: ALL chunks are code programs (raw, AL=3)
# Known names:
ZELRES3_NAMES = {
    0:  'LVLLD',  # 300LVLLD - level load
    14: 'LVLRD',  # 314LVLRD - level road/data
    16: 'TILCL',  # 316TILCL - tile clear
    31: 'MP50',   # 331MP50  - map 50 (cave area)
    32: 'MP51',   # 332MP51  - map 51 (cave area)
    56: 'LVGRP',  # 356LVGRP - level group
}


def get_chunk_count(sar_path):
    offsets = read_sar_offsets(sar_path)
    return len(offsets)


def extract_chunk(archive_num, chunk_idx, name_suffix):
    sar_path = SAR_DIR / f'zelres{archive_num}.sar'
    raw = read_sar_chunk(str(sar_path), chunk_idx)

    stem = f'{archive_num}{chunk_idx:02d}{name_suffix}'
    bin_name = f'{stem}.bin'

    working_dir = WORKING / f'zelres{archive_num}' / 'code'
    ref_dir = BIN_DIR / f'zelres{archive_num}'

    working_path = working_dir / bin_name
    ref_path = ref_dir / bin_name

    # If a reference .bin already exists in bin/ dir, it's already set up — skip
    if ref_path.exists():
        return stem, 'already_exists'

    if DRY_RUN:
        return stem, f'would_extract ({len(raw)}B)'

    working_dir.mkdir(parents=True, exist_ok=True)
    ref_dir.mkdir(parents=True, exist_ok=True)

    with open(working_path, 'wb') as f:
        f.write(raw)
    with open(ref_path, 'wb') as f:
        f.write(raw)

    return stem, f'extracted ({len(raw)}B)'


def main():
    print('=== Zeliard SAR Code Chunk Extractor ===')
    if DRY_RUN:
        print('DRY RUN — no files written\n')

    stats = {'extracted': 0, 'already_exists': 0, 'skipped_data': 0}

    # zelres1: only known code chunks
    print('--- zelres1 ---')
    sar1_count = get_chunk_count(str(SAR_DIR / 'zelres1.sar'))
    for c in range(sar1_count):
        if c in ZELRES1_CODE_CHUNKS:
            name = ZELRES1_NAMES[c]
            stem, status = extract_chunk(1, c, name)
            print(f'  chunk {c:2d} ({stem}): {status}')
            if 'extracted' in status: stats['extracted'] += 1
            elif 'already' in status: stats['already_exists'] += 1
        else:
            stats['skipped_data'] += 1

    # zelres2: only known code chunks
    print('--- zelres2 ---')
    sar2_count = get_chunk_count(str(SAR_DIR / 'zelres2.sar'))
    for c in range(sar2_count):
        if c in ZELRES2_CODE_CHUNKS:
            name = ZELRES2_NAMES[c]
            stem, status = extract_chunk(2, c, name)
            print(f'  chunk {c:2d} ({stem}): {status}')
            if 'extracted' in status: stats['extracted'] += 1
            elif 'already' in status: stats['already_exists'] += 1
        else:
            stats['skipped_data'] += 1

    # zelres3: ALL chunks are code
    print('--- zelres3 ---')
    sar3_count = get_chunk_count(str(SAR_DIR / 'zelres3.sar'))
    for c in range(sar3_count):
        name = ZELRES3_NAMES.get(c, 'UNKN')
        stem, status = extract_chunk(3, c, name)
        if 'already' not in status:
            print(f'  chunk {c:2d} ({stem}): {status}')
        if 'extracted' in status: stats['extracted'] += 1
        elif 'already' in status: stats['already_exists'] += 1

    print(f'\nDone: {stats["extracted"]} extracted, {stats["already_exists"]} already up-to-date, {stats["skipped_data"]} data chunks skipped')


if __name__ == '__main__':
    main()
