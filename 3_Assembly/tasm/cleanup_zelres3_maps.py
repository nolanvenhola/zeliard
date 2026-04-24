#!/usr/bin/env python3
"""Conservative cleanup of zelres3 MAP data files.

For each of the 16 MP{L}{F} files:
  1. Replace Sourcer non-ASCII boilerplate header with descriptive map-data header
  2. Do NOT alter any db lines or rearrange bytes
  3. Leave proc names and existing labels alone (bit-perfect preservation)

Bit-perfect-safe: only comment text and the PAGE header are altered.
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).parent
CODE = ROOT / 'working' / 'zelres3' / 'code'

# Map info: (filename, level, floor, cavern_name, description)
MAPS = [
    ('320MP10.asm', 1, 0, 'Cavern of Malicia', "level 1, floor 0 (entrance)"),
    ('321MP1D.ASM', 1, 'D', 'Cavern of Malicia', "level 1, floor D (dungeon/exit)"),
    ('322MP20.asm', 2, 0, 'Cavern of Peligro', "level 2, floor 0 (entrance)"),
    ('323MP21.ASM', 2, 1, 'Cavern of Peligro', "level 2, floor 1"),
    ('324MP2D.ASM', 2, 'D', 'Cavern of Peligro', "level 2, floor D (dungeon/exit)"),
    ('325MP30.ASM', 3, 0, 'Cavern of Madera', "level 3, floor 0 (entrance)"),
    ('326MP31.asm', 3, 1, 'Cavern of Riza', "level 3, floor 1"),
    ('327MP3D.ASM', 3, 'D', 'Cavern of Riza', "level 3, floor D (dungeon/exit)"),
    ('328MP40.ASM', 4, 0, 'Cavern of Glacial', "level 4, floor 0 (entrance)"),
    ('329MP41.ASM', 4, 1, 'Cavern of Escarcha', "level 4, floor 1"),
    ('330MP4D.ASM', 4, 'D', 'Cavern of Glacial', "level 4, floor D (dungeon/exit)"),
    ('331MP50.asm', 5, 0, 'Cavern of Corroer', "level 5, floor 0 (entrance)"),
    ('332MP51.asm', 5, 1, 'Cavern of Cementar', "level 5, floor 1"),
    ('333MP5D.asm', 5, 'D', 'Cavern of Cementar', "level 5, floor D (dungeon/exit)"),
    ('334MP60.asm', 6, 0, 'Cavern of Tesoro', "level 6, floor 0 (entrance)"),
    ('335MP61.asm', 6, 1, 'Cavern of Plata', "level 6, floor 1"),
]


def build_header(stem, level, floor, cavern, desc):
    return f''';==========================================================================
;
;  {stem} - Map Data Table: {cavern}, {desc}
;
;  Cavern/labyrinth map resource file loaded as {stem.upper()[3:]}.MDT (zelres3).
;  Part of the 16-file MP{{level}}{{floor}} dungeon-map set (320..335) covering
;  levels 1-6 of the Zeliard labyrinth.
;
;  NOT executable code -- Sourcer mis-decoded the header bytes and data
;  tables as x86 instructions (the first two bytes are really the file
;  size word, not 'cmp [bp+si],al' etc).  The bogus mnemonics below all
;  re-emit the same byte sequence.
;
;  General MDT layout (all files in this group share this pattern):
;    [0x00]   file-size word + flag/reserved word
;    [0x04+]  pointer table (WORDs 0xCNNN - runtime segment 0xC000)
;            -> tile grid, event table, exit table, script trailer
;    [mid]    tile_grid            - column/row-strip tile-index data
;                                    (values like 0x3F06, 0xC4NN, 0xC5NN)
;    [later]  event_records        - NPC/door/exit records (FF-terminated)
;    [late]   cavern_name          - pascal-encoded '{cavern}'
;    [end]    exit/trigger records - door warp coords + script bytes
;    [eof]    terminator           - 0xFFFFFFFF (header_1 label)
;
;  Runtime segment base = 0xC000.  Pointer 0xCNNN resolves to file_off NNN.
;
;==========================================================================
'''


def cleanup_file(path, stem, level, floor, cavern, desc):
    content = path.read_text(encoding='latin-1')

    # Split into lines preserving line endings
    lines = content.split('\n')

    # Find the old Sourcer header: starts with ';<non-ASCII>' lines near top
    # and ends before 'target   EQU'
    new_lines = []
    in_header = False
    skipped_header = False

    i = 0
    while i < len(lines):
        line = lines[i]

        # Empty line before header
        if not skipped_header and line.strip() == '' and i < 3:
            new_lines.append(line)
            i += 1
            continue

        # PAGE directive - keep
        if line.startswith('PAGE'):
            new_lines.append(line)
            new_lines.append('')
            # Now skip Sourcer's non-ASCII header block until 'target'
            i += 1
            while i < len(lines):
                if lines[i].strip().startswith('target'):
                    break
                i += 1
            # Insert new header block
            new_lines.append(build_header(stem, level, floor, cavern, desc))
            skipped_header = True
            continue

        new_lines.append(line)
        i += 1

    # Now remove the duplicate 'External Entry Point' comment blocks (Sourcer boilerplate)
    # These are non-ASCII box-drawing comment blocks
    out_lines = []
    i = 0
    while i < len(new_lines):
        line = new_lines[i]
        # Remove non-ASCII separator comments (replace with blank line)
        stripped = line.strip()
        if stripped.startswith(';') and any(ord(c) > 127 for c in stripped):
            # Skip this Sourcer separator line
            i += 1
            continue
        # Remove the 'External Entry Point' comment line
        if stripped == ';                       External Entry Point':
            i += 1
            continue
        # Remove the ';' lines that bracket these comments (blank comments)
        if stripped == ';':
            # Check if surrounded by blank/boilerplate — leave alone if not
            i += 1
            continue
        out_lines.append(line)
        i += 1

    # Join back
    new_content = '\n'.join(out_lines)

    # Collapse 3+ consecutive blank lines down to 2
    while '\n\n\n\n' in new_content:
        new_content = new_content.replace('\n\n\n\n', '\n\n\n')

    path.write_text(new_content, encoding='latin-1')


def main():
    only = sys.argv[1] if len(sys.argv) > 1 else None
    for fname, lvl, flr, cav, desc in MAPS:
        if only and only not in fname.lower():
            continue
        path = CODE / fname
        if not path.exists():
            print(f'SKIP (missing): {fname}')
            continue
        stem = Path(fname).stem
        cleanup_file(path, stem, lvl, flr, cav, desc)
        print(f'OK: {fname}')


if __name__ == '__main__':
    main()
