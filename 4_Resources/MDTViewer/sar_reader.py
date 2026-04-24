"""
Zeliard SAR Archive Reader  — corrected format from extractor.py analysis.

SAR file format:
  The file begins with a directory of DWORD (4-byte LE) offsets.
  Entry i (1-based file_id) lives at:
      info_offset = (file_id - 1) * 4
  The DWORD at info_offset is data_offset.
  At data_offset in the SAR file:
      DWORD  file_length   (4 bytes LE)
      BYTES  file_content  (file_length bytes, uncompressed)

File-id to filename mapping is provided via a "directory.txt" side-car
file (archive_idx, file_id, filename) or can be auto-detected from the
bundled DIRECTORY constant below.
"""

import struct
import os
from dataclasses import dataclass, field
from typing import List, Optional, Dict


# ── Built-in directory (archive_idx 0-2, file_id 1-based) ─────────────────
# Source: directory.txt
_BUILTIN_DIR: Dict[int, Dict[int, str]] = {
    # zelres1.sar  (archive_idx=0, archive_num=1)
    1: {
        0x01:'opdemo.bin', 0x02:'gdega.bin',  0x03:'gdcga.bin',  0x04:'gdhgc.bin',
        0x05:'gdtga.bin',  0x06:'gdmcga.bin', 0x07:'town.bin',   0x08:'gtega.bin',
        0x09:'gtcga.bin',  0x0a:'gthgc.bin',  0x0b:'gttga.bin',  0x0c:'gtmcga.bin',
        0x0d:'font.grp',   0x0e:'ame.grp',    0x0f:'dmaou.grp',  0x10:'hime.grp',
        0x11:'himp.grp',   0x12:'hou.grp',    0x13:'isi.grp',    0x14:'maop.grp',
        0x15:'ne80.grp',   0x16:'ne81.grp',   0x17:'nec.grp',    0x18:'new1.grp',
        0x19:'new2.grp',   0x1a:'oui.grp',    0x1b:'oup.grp',    0x1c:'sei.grp',
        0x1d:'seip.grp',   0x1e:'ttl1.grp',   0x1f:'ttl2.grp',   0x20:'ttl3.grp',
        0x21:'waku.grp',   0x22:'yuu1.grp',   0x23:'yuu2.grp',   0x24:'yuu3.grp',
        0x25:'yuu4.grp',   0x26:'yuup.grp',   0x27:'zend.msd',   0x28:'zopn.msd',
    },
    # zelres2.sar  (archive_idx=1, archive_num=2)
    2: {
        0x01:'fight.bin',  0x02:'select.bin', 0x03:'gfega.bin',  0x04:'gfcga.bin',
        0x05:'gfhgc.bin',  0x06:'gftga.bin',  0x07:'gfmcga.bin', 0x08:'mole.bin',
        0x09:'ympd.bin',   0x0a:'ckpd.bin',   0x0b:'kingpro.bin',0x0c:'omoypro.bin',
        0x0d:'armrpro.bin',0x0e:'bankpro.bin',0x0f:'churpro.bin',0x10:'drugpro.bin',
        0x11:'innapro.bin',0x12:'kenjpro.bin', 0x13:'king.grp',   0x14:'omoya.grp',
        0x15:'armor.grp',  0x16:'bank.grp',   0x17:'church.grp', 0x18:'drug.grp',
        0x1a:'kenjya.grp', 0x1b:'sword.grp',  0x1c:'itemp.grp',  0x1d:'magic.grp',
        0x1e:'mman.grp',   0x1f:'cman.grp',   0x20:'tman.grp',   0x22:'cpat.grp',
        0x23:'mpat.grp',   0x24:'dpat.grp',
        0x25:'cmap.mdt',   0x26:'mrmp.mdt',   0x27:'stmp.mdt',   0x28:'bsmp.mdt',
        0x29:'hlmp.mdt',   0x2a:'tmmp.mdt',   0x2b:'drmp.mdt',   0x2c:'llmp.mdt',
        0x2d:'prmp.mdt',   0x2e:'esmp.mdt',
        0x2f:'mgt1.msd',   0x30:'mgt2.msd',   0x31:'ugm1.msd',   0x32:'ugm2.msd',
        0x33:'enddemo.bin',0x34:'en72.grp',   0x35:'end4.grp',   0x36:'end5.grp',
        0x37:'end6.grp',   0x38:'end7.grp',   0x39:'fin.grp',    0x3a:'roka.grp',
    },
    # zelres3.sar  (archive_idx=2, archive_num=3)
    3: {
        0x01:'rokademo.bin',0x02:'eai1.bin', 0x03:'eai2.bin',  0x04:'eai3.bin',
        0x05:'eai4.bin',   0x06:'eai5.bin',  0x07:'eai6.bin',  0x08:'eai7.bin',
        0x09:'eai8.bin',   0x0a:'crab.bin',  0x0b:'tako.bin',  0x0c:'tori.bin',
        0x0d:'zela.bin',   0x0e:'meda.bin',  0x0f:'lega.bin',  0x10:'zel2.bin',
        0x11:'drgn.bin',   0x12:'akma.bin',  0x13:'mao1.bin',  0x14:'mao2.bin',
        0x15:'mp10.mdt',   0x16:'mp1d.mdt',  0x17:'mp20.mdt',  0x18:'mp21.mdt',
        0x19:'mp2d.mdt',   0x1a:'mp30.mdt',  0x1b:'mp31.mdt',  0x1c:'mp3d.mdt',
        0x1d:'mp40.mdt',   0x1e:'mp41.mdt',  0x1f:'mp4d.mdt',  0x20:'mp50.mdt',
        0x21:'mp51.mdt',   0x22:'mp5d.mdt',  0x23:'mp60.mdt',  0x24:'mp61.mdt',
        0x25:'mp62.mdt',   0x26:'mp6d.mdt',  0x27:'mp70.mdt',  0x28:'mp71.mdt',
        0x29:'mp72.mdt',   0x2a:'mp73.mdt',  0x2b:'mp7d.mdt',  0x2c:'mp80.mdt',
        0x2d:'mp81.mdt',   0x2e:'mp82.mdt',  0x2f:'mp83.mdt',  0x30:'mp84.mdt',
        0x31:'mp8d.mdt',   0x32:'mp90.mdt',  0x33:'mpa0.mdt',
        0x34:'fman.grp',   0x35:'roka.grp',  0x36:'dman.grp',  0x37:'dchr.grp',
        0x38:'encnt.grp',  0x39:'enp1.grp',  0x3a:'enp2.grp',  0x3b:'enp3.grp',
        0x3c:'enp4.grp',   0x3d:'enp5.grp',  0x3e:'enp6.grp',  0x3f:'enp7.grp',
        0x40:'enp8.grp',   0x41:'crab.grp',  0x42:'tako.grp',  0x43:'tori.grp',
        0x44:'zela.grp',   0x45:'meda.grp',  0x46:'lega.grp',  0x47:'drgn.grp',
        0x48:'akma.grp',   0x49:'mao1.grp',  0x4a:'mao2.grp',
        0x4b:'mpp1.grp',   0x4c:'mpp2.grp',  0x4d:'mpp3.grp',  0x4e:'mpp4.grp',
        0x4f:'mpp5.grp',   0x50:'mpp6.grp',  0x51:'mpp7.grp',  0x52:'mpp8.grp',
        0x53:'mpp9.grp',   0x54:'mppa.grp',  0x55:'mppb.grp',
        0x56:'mus1.msd',   0x57:'mus2.msd',  0x58:'mus3.msd',  0x59:'mus4.msd',
        0x5a:'mus5.msd',   0x5b:'mus6.msd',  0x5c:'mus7.msd',  0x5d:'mus8.msd',
        0x5e:'mbos.msd',   0x5f:'mfan.msd',  0x60:'mmao.msd',
    },
}


@dataclass
class SarEntry:
    name:   str
    file_id: int
    offset: int    # data_offset inside SAR file
    size:   int    # uncompressed file length


class SarArchive:
    """
    Read a Zeliard SAR archive.

    Format per extractor.py:
      info_offset = (file_id - 1) * 4
      data_offset = DWORD at info_offset
      file_length = DWORD at data_offset
      file_bytes  = data_offset + 4  ..  data_offset + 4 + file_length
    """

    def __init__(self, path: str):
        self.path = path
        self.name = os.path.basename(path)
        with open(path, 'rb') as f:
            self._data = f.read()

        # Auto-detect archive number from filename (zelres1→1, zelres2→2, ...)
        stem = os.path.splitext(self.name)[0].lower()   # "zelres1"
        self._archive_num: int = 0
        for digit in '123':
            if stem.endswith(digit):
                self._archive_num = int(digit)
                break

        # Build entry list from built-in directory
        fid_map = _BUILTIN_DIR.get(self._archive_num, {})
        self.entries: List[SarEntry] = []
        self._index:  Dict[str, SarEntry] = {}

        for file_id, fname in sorted(fid_map.items()):
            info_offset = (file_id - 1) * 4
            if info_offset + 4 > len(self._data):
                continue
            data_offset = struct.unpack_from('<I', self._data, info_offset)[0]
            if data_offset + 4 > len(self._data):
                continue
            file_length = struct.unpack_from('<I', self._data, data_offset)[0]
            entry = SarEntry(
                name=fname, file_id=file_id,
                offset=data_offset, size=file_length)
            self.entries.append(entry)
            self._index[fname.upper()] = entry

    def list_files(self, ext_filter: Optional[str] = None) -> List[str]:
        names = [e.name for e in self.entries]
        if ext_filter:
            ef = ext_filter.upper()
            names = [n for n in names if n.upper().endswith(ef)]
        return names

    def read(self, name: str) -> bytes:
        entry = self._index.get(name.upper())
        if entry is None:
            raise KeyError(f'{name!r} not found in {self.name}')
        off = entry.offset + 4   # skip length DWORD
        raw = self._data[off: off + entry.size]
        if len(raw) < entry.size:
            raise ValueError(
                f'{name}: truncated (expected {entry.size}, got {len(raw)})')
        return raw

    def contains(self, name: str) -> bool:
        return name.upper() in self._index
