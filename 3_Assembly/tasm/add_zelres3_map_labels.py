#!/usr/bin/env python3
"""Second-pass: add in-line section comments to zelres3 MP*.asm files.

Inserts pure-comment annotations (zero-byte) above certain identifiable
lines such as:
  - The Sourcer-decoded header mnemonics (1st proc) -> mdt_header
  - The 'dec cx' / 'or dx' etc at start of strategy proc -> tile_grid
  - The 'Cavern of X' literal string -> cavern_name

Does NOT modify any existing db/dw/proc/label lines.  Bit-perfect safe.
"""
import re
from pathlib import Path

CODE = Path(__file__).parent / 'working' / 'zelres3' / 'code'

FILES = [
    '320MP10.asm', '321MP1D.ASM', '322MP20.asm', '323MP21.ASM',
    '324MP2D.ASM', '325MP30.ASM', '326MP31.asm', '327MP3D.ASM',
    '328MP40.ASM', '329MP41.ASM', '330MP4D.ASM', '331MP50.asm',
    '332MP51.asm', '333MP5D.asm', '334MP60.asm', '335MP61.asm',
]

HDR_COMMENT = """
; ------------------------------------------------------------------
; mdt_header -- file-size word, flag byte, and table of WORD pointers
; into the runtime 0xC000 segment.  Sourcer mis-decoded the leading
; bytes as instructions; they are actually: size word + flag word
; + attributes pointer + offset of 'strategy' (tile grid start) + ...
; ------------------------------------------------------------------
"""

TILE_COMMENT = """
; ------------------------------------------------------------------
; tile_grid -- main cavern/map tile-index data.  Encoded as column
; or row strips of 1-byte tile indices.  Common runs: 0x3F06 (wall
; boundary), 0x2C06 (column separator), plus palette-range values
; (0xC4-0xCC) that select tile rows in the tile bank.  Originally
; labeled 'strategy' by Sourcer because the header pointer landed
; on this offset.
; ------------------------------------------------------------------
"""

CAVERN_COMMENT_FMT = """
; ------------------------------------------------------------------
; cavern_name -- pascal-encoded cavern/area name '{}'.
; Preceded by small descriptor bytes; the length byte just before
; the quoted string matches the string length (0x11/0x0E/etc).
; ------------------------------------------------------------------
"""

EOF_COMMENT = """
; ------------------------------------------------------------------
; exit_records -- trailing event/exit/door records and script bytes
; triggered on cavern load.  Ends with 0xFFFFFFFF (header_1 label).
; ------------------------------------------------------------------
"""


def insert_comment_before(lines, pattern, comment, already_re=None):
    """Find first line matching `pattern`, insert `comment` above.
    If `already_re` is given and already present in the preceding 5 lines,
    skip (idempotent)."""
    out = []
    inserted = False
    for i, line in enumerate(lines):
        if not inserted and re.search(pattern, line):
            # Check idempotency
            prev_5 = '\n'.join(lines[max(0, i - 6):i])
            if already_re and re.search(already_re, prev_5):
                inserted = True  # already there
            else:
                out.append(comment.rstrip('\n'))
                inserted = True
        out.append(line)
    return out


def cleanup(path):
    content = path.read_text(encoding='latin-1')
    lines = content.split('\n')

    # Find the cavern name line - it's a quoted 'Cavern of X' db line
    cavern_name = None
    for line in lines:
        m = re.search(r"db\s+'(Cavern of [^']+)'", line)
        if m:
            cavern_name = m.group(1)
            break

    # 1) Insert mdt_header comment above FIRST 'attributes dw' OR above first
    # 'pointers dw' OR above 'start:' line.  Whichever occurs first anchors
    # the mdt_header section comment.
    # In files with "strategy_1 proc far" structure, insert just after that
    # proc opens or before its pointer-like lines.
    # In files with "zr3_NN proc far" single-proc structure, insert before
    # the 'start:' line or first mnemonic.
    lines = insert_comment_before(
        lines,
        r'^(attributes\s+dw|pointers\s+dw|start:\s*$)',
        HDR_COMMENT,
        already_re=r'mdt_header --',
    )

    # 2) Insert tile_grid comment above the 'dec cx' / 'or dx' / etc at top
    # of 'strategy' proc (the 2nd proc in files with split pattern), OR
    # in single-proc files, at a different anchor.  We'll look for the
    # FIRST mnemonic line AFTER `strategy\s+proc\s+far` OR the first mnemonic
    # AFTER the first proc body in single-proc files.
    # Simplest: anchor to the FIRST db line that starts with '0Dh' right
    # after the header (no great universal anchor), so use 'strategy proc far'.
    lines = insert_comment_before(
        lines,
        r'^strategy\s+proc\s+far\s*$',
        TILE_COMMENT,
        already_re=r'tile_grid --',
    )

    # For single-proc files (zr3_NN), insert tile_grid comment before 'start:'
    # but only if no 'strategy proc' exists.
    has_strategy = any(re.search(r'^strategy\s+proc\s+far', l) for l in lines)
    if not has_strategy:
        # Insert tile_grid above first db line following 'start:'
        out = []
        past_start = False
        inserted = False
        for line in lines:
            if not past_start and line.strip().startswith('start:'):
                past_start = True
            # After start:, first non-comment non-blank line gets comment above
            if (past_start and not inserted and
                re.match(r'\s*(db|dw)\s', line)):
                # Check no 'tile_grid --' in preceding 6 lines
                prev = '\n'.join(out[-6:])
                if 'tile_grid --' not in prev:
                    out.append(TILE_COMMENT.rstrip('\n'))
                inserted = True
            out.append(line)
        lines = out

    # 3) Insert cavern_name comment above the 'db 'Cavern of X'' line
    if cavern_name:
        cav_esc = re.escape(cavern_name)
        lines = insert_comment_before(
            lines,
            rf"db\s+'{cav_esc}'",
            CAVERN_COMMENT_FMT.format(cavern_name),
            already_re=r'cavern_name --',
        )

    # 4) Insert exit_records comment above 'header_1 dd' line
    lines = insert_comment_before(
        lines,
        r'^header_1\s+dd\s+0FFFFFFFFh',
        EOF_COMMENT,
        already_re=r'exit_records --',
    )

    # Write back
    path.write_text('\n'.join(lines), encoding='latin-1')


def main():
    import sys
    only = sys.argv[1].lower() if len(sys.argv) > 1 else None
    for fname in FILES:
        if only and only not in fname.lower():
            continue
        path = CODE / fname
        cleanup(path)
        print(f'OK: {fname}')


if __name__ == '__main__':
    main()
