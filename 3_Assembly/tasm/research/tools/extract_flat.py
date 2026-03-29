#!/usr/bin/env python3
"""
extract_flat.py  —  Extract all SAR chunks to a flat directory tree.

Output: research/flatfiles/ZELRES1/, ZELRES2/, ZELRES3/
Files are stored pre-decompressed and ready to load directly.

Reuses decompress_sar_chunk() from 2_SAR/Tools/decompress_sar.py.
"""

import sys
import struct
from pathlib import Path

# Reuse the existing decompressor
TOOLS = Path(__file__).parent.parent.parent.parent.parent / '2_SAR' / 'Tools'
sys.path.insert(0, str(TOOLS))
from decompress_sar import decompress_sar_chunk

# ── Canonical filename map: (archive_0idx, chunk_0idx) → filename ──────────
# Source: game.bin virtual filesystem table (confirmed present in binary)

FILENAMES = {
    # zelres1 (archive 0) — chunks 00-39
    (0, 0):  'opdemo.bin',   (0, 1):  'gdega.bin',   (0, 2):  'gdcga.bin',
    (0, 3):  'gdhgc.bin',    (0, 4):  'gdtga.bin',   (0, 5):  'gdmcga.bin',
    (0, 6):  'town.bin',     (0, 7):  'gtega.bin',   (0, 8):  'gtcga.bin',
    (0, 9):  'gthgc.bin',    (0,10):  'gttga.bin',   (0,11):  'gtmcga.bin',
    (0,12):  'font.grp',     (0,13):  'ame.grp',     (0,14):  'dmaou.grp',
    (0,15):  'hime.grp',     (0,16):  'himp.grp',    (0,17):  'hou.grp',
    (0,18):  'isi.grp',      (0,19):  'maop.grp',    (0,20):  'ne80.grp',
    (0,21):  'ne81.grp',     (0,22):  'nec.grp',     (0,23):  'new1.grp',
    (0,24):  'new2.grp',     (0,25):  'oui.grp',     (0,26):  'oup.grp',
    (0,27):  'sei.grp',      (0,28):  'seip.grp',    (0,29):  'ttl1.grp',
    (0,30):  'ttl2.grp',     (0,31):  'ttl3.grp',    (0,32):  'waku.grp',
    (0,33):  'yuu1.grp',     (0,34):  'yuu2.grp',    (0,35):  'yuu3.grp',
    (0,36):  'yuu4.grp',     (0,37):  'yuup.grp',    (0,38):  'zend.msd',
    (0,39):  'zopn.msd',

    # zelres2 (archive 1) — chunks 00-57
    (1, 0):  'fight.bin',    (1, 1):  'select.bin',  (1, 2):  'gfega.bin',
    (1, 3):  'gfcga.bin',    (1, 4):  'gfhgc.bin',   (1, 5):  'gftga.bin',
    (1, 6):  'gfmcga.bin',   (1, 7):  'mole.bin',    (1, 8):  'YMPD.BIN',
    (1, 9):  'CKPD.BIN',     (1,10):  'KINGPRO.BIN', (1,11):  'OMOYPRO.BIN',
    (1,12):  'ARMRPRO.BIN',  (1,13):  'BANKPRO.BIN', (1,14):  'CHURPRO.BIN',
    (1,15):  'DRUGPRO.BIN',  (1,16):  'INNAPRO.BIN', (1,17):  'KENJPRO.BIN',
    (1,18):  'KING.GRP',     (1,19):  'OMOYA.GRP',   (1,20):  'ARMOR.GRP',
    (1,21):  'BANK.GRP',     (1,22):  'CHURCH.GRP',  (1,23):  'DRUG.GRP',
    (1,24):  'INN.GRP',      (1,25):  'KENJYA.GRP',  (1,26):  'sword.grp',
    (1,27):  'itemp.grp',    (1,28):  'magic.grp',   (1,29):  'MMAN.GRP',
    (1,30):  'CMAN.GRP',     (1,31):  'TMAN.GRP',    (1,32):  'INNA.GRP',
    (1,33):  'CPAT.GRP',     (1,34):  'MPAT.GRP',    (1,35):  'DPAT.GRP',
    (1,36):  'CMAP.MDT',     (1,37):  'MRMP.MDT',    (1,38):  'STMP.MDT',
    (1,39):  'BSMP.MDT',     (1,40):  'HLMP.MDT',    (1,41):  'TMMP.MDT',
    (1,42):  'DRMP.MDT',     (1,43):  'LLMP.MDT',    (1,44):  'PRMP.MDT',
    (1,45):  'ESMP.MDT',     (1,46):  'MGT1.MSD',    (1,47):  'MGT2.MSD',
    (1,48):  'UGM1.MSD',     (1,49):  'UGM2.MSD',    (1,50):  'enddemo.bin',
    (1,51):  'en72.grp',     (1,52):  'end4.grp',    (1,53):  'end5.grp',
    (1,54):  'end6.grp',     (1,55):  'end7.grp',    (1,56):  'fin.grp',
    (1,57):  'ROKA.GRP',

    # zelres3 (archive 2) — chunks 00-95
    (2, 0):  'ROKADEMO.BIN', (2, 1):  'EAI1.BIN',    (2, 2):  'EAI2.BIN',
    (2, 3):  'EAI3.BIN',     (2, 4):  'EAI4.BIN',    (2, 5):  'EAI5.BIN',
    (2, 6):  'EAI6.BIN',     (2, 7):  'EAI7.BIN',    (2, 8):  'EAI8.BIN',
    (2, 9):  'CRAB.BIN',     (2,10):  'TAKO.BIN',    (2,11):  'TORI.BIN',
    (2,12):  'ZELA.BIN',     (2,13):  'MEDA.BIN',    (2,14):  'LEGA.BIN',
    (2,15):  'ZEL2.BIN',     (2,16):  'DRGN.BIN',    (2,17):  'AKMA.BIN',
    (2,18):  'MAO1.BIN',     (2,19):  'MAO2.BIN',    (2,20):  'MP10.MDT',
    (2,21):  'MP1D.MDT',     (2,22):  'MP20.MDT',    (2,23):  'MP21.MDT',
    (2,24):  'MP2D.MDT',     (2,25):  'MP30.MDT',    (2,26):  'MP31.MDT',
    (2,27):  'MP3D.MDT',     (2,28):  'MP40.MDT',    (2,29):  'MP41.MDT',
    (2,30):  'MP4D.MDT',     (2,31):  'MP50.MDT',    (2,32):  'MP51.MDT',
    (2,33):  'MP5D.MDT',     (2,34):  'MP60.MDT',    (2,35):  'MP61.MDT',
    (2,36):  'MP62.MDT',     (2,37):  'MP6D.MDT',    (2,38):  'MP70.MDT',
    (2,39):  'MP71.MDT',     (2,40):  'MP72.MDT',    (2,41):  'MP73.MDT',
    (2,42):  'MP7D.MDT',     (2,43):  'MP80.MDT',    (2,44):  'MP81.MDT',
    (2,45):  'MP82.MDT',     (2,46):  'MP83.MDT',    (2,47):  'MP84.MDT',
    (2,48):  'MP8D.MDT',     (2,49):  'MP90.MDT',    (2,50):  'MPA0.MDT',
    (2,51):  'FMAN.GRP',     (2,52):  'ROKA.GRP',    (2,53):  'DMAN.GRP',
    (2,54):  'DCHR.GRP',     (2,55):  'ENCNT.GRP',   (2,56):  'ENP1.GRP',
    (2,57):  'ENP2.GRP',     (2,58):  'ENP3.GRP',    (2,59):  'ENP4.GRP',
    (2,60):  'ENP5.GRP',     (2,61):  'ENP6.GRP',    (2,62):  'ENP7.GRP',
    (2,63):  'ENP8.GRP',     (2,64):  'CRAB.GRP',    (2,65):  'TAKO.GRP',
    (2,66):  'TORI.GRP',     (2,67):  'ZELA.GRP',    (2,68):  'MEDA.GRP',
    (2,69):  'LEGA.GRP',     (2,70):  'DRGN.GRP',    (2,71):  'AKMA.GRP',
    (2,72):  'MAO1.GRP',     (2,73):  'MAO2.GRP',    (2,74):  'MPP1.GRP',
    (2,75):  'MPP2.GRP',     (2,76):  'MPP3.GRP',    (2,77):  'MPP4.GRP',
    (2,78):  'MPP5.GRP',     (2,79):  'MPP6.GRP',    (2,80):  'MPP7.GRP',
    (2,81):  'MPP8.GRP',     (2,82):  'MPP9.GRP',    (2,83):  'MPPA.GRP',
    (2,84):  'MPPB.GRP',     (2,85):  'MUS1.MSD',    (2,86):  'MUS2.MSD',
    (2,87):  'MUS3.MSD',     (2,88):  'MUS4.MSD',    (2,89):  'MUS5.MSD',
    (2,90):  'MUS6.MSD',     (2,91):  'MUS7.MSD',    (2,92):  'MUS8.MSD',
    (2,93):  'MBOS.MSD',     (2,94):  'MFAN.MSD',    (2,95):  'MMAO.MSD',
}

ARCHIVE_NAMES = ['ZELRES1', 'ZELRES2', 'ZELRES3']
SAR_FILES     = ['zelres1.sar', 'zelres2.sar', 'zelres3.sar']

# Code chunks are stored raw (AL=3); data chunks use fill_buffer (AL=2).
# Raw chunks: zelres1 00-11, zelres2 00-07 + 08-17 (town programs) + 50
RAW_CHUNKS = {
    0: set(range(12)),           # zelres1: display drivers + opdemo + town
    1: set(range(18)) | {50},    # zelres2: fight/select/gf*/mole + town programs + enddemo
    2: set(range(20)),           # zelres3: ROKADEMO + EAI* + boss code
}


def _parse_sar_offsets(data: bytes):
    """Return list of all chunk (offset, size) pairs from SAR data."""
    primary = [struct.unpack_from('<I', data, i*4)[0] for i in range(40)]
    first   = primary[0]
    gap     = data[0xA0:first]
    ext     = [struct.unpack_from('<I', gap, i*4)[0] for i in range(len(gap)//4)]
    all_off = primary + ext
    result  = []
    for off in all_off:
        sz = struct.unpack_from('<I', data, off)[0]
        result.append((off, sz))
    return result


def extract_flat(sar_dir: Path, out_dir: Path):
    total_written = 0
    for arc_idx, (sar_name, arc_name) in enumerate(zip(SAR_FILES, ARCHIVE_NAMES)):
        sar_path = sar_dir / sar_name
        arc_out  = out_dir / arc_name
        arc_out.mkdir(parents=True, exist_ok=True)

        data    = sar_path.read_bytes()
        chunks  = _parse_sar_offsets(data)
        raw_set = RAW_CHUNKS.get(arc_idx, set())

        print(f'\n{sar_name}  ->  {arc_out}')
        for chunk_0idx, (off, sz) in enumerate(chunks):
            chunk_data = data[off : off + 4 + sz]
            fname      = FILENAMES.get((arc_idx, chunk_0idx),
                                       f'chunk_{chunk_0idx:02d}.bin')
            out_path   = arc_out / fname

            if chunk_0idx in raw_set:
                # Known raw chunk (code/programs): strip 4-byte size header, keep rest
                payload = chunk_data[4:]
            else:
                # Data chunk: decompress; fall back to raw if decompress yields nothing
                payload = bytes(decompress_sar_chunk(chunk_data))
                if len(payload) == 0 and sz > 0:
                    payload = chunk_data[4:]  # raw fallback (e.g. music .msd files)

            out_path.write_bytes(payload)
            print(f'  chunk_{chunk_0idx:02d}  {fname:<20}  {len(payload):,} bytes')
            total_written += 1

    print(f'\nDone — {total_written} files written to {out_dir}')


if __name__ == '__main__':
    root    = Path(__file__).parent.parent.parent.parent.parent  # repo root
    sar_dir = root / '1_OriginalGame'
    out_dir = Path(__file__).parent.parent / 'flatfiles'
    extract_flat(sar_dir, out_dir)
