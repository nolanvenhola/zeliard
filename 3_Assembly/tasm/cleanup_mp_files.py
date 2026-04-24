#!/usr/bin/env python3
"""Generate clean .asm for each MP (map data) file from its .bin.

These files are MAP DATA mis-decoded by Sourcer as x86 code. We re-emit
them as pure `db` data with proper section labels for:
  - header (size word + pointer table)
  - tilemap (tile grid)
  - NPC/event records
  - dialog strings (terminated by 0xFF)
  - script trailer (event trigger script)
"""
import os
import sys

# Map file names -> human description
MAP_DESCRIPTIONS = {
    "336MP62": ("MP62", "Level 6 Floor 2", "labyrinth/cavern"),
    "337MP6D": ("MP6D", "Level 6 Floor D (town/checkpoint)", "town"),
    "338MP70": ("MP70", "Level 7 Floor 0", "labyrinth/cavern"),
    "339MP71": ("MP71", "Level 7 Floor 1", "labyrinth/cavern"),
    "340MP72": ("MP72", "Level 7 Floor 2", "labyrinth/cavern"),
    "341MP73": ("MP73", "Level 7 Floor 3", "labyrinth/cavern"),
    "342MP7D": ("MP7D", "Level 7 Floor D (town/checkpoint)", "town"),
    "343MP80": ("MP80", "Level 8 Floor 0", "labyrinth/cavern"),
    "344MP81": ("MP81", "Level 8 Floor 1", "labyrinth/cavern"),
    "345MP82": ("MP82", "Level 8 Floor 2", "labyrinth/cavern"),
    "346MP83": ("MP83", "Level 8 Floor 3", "labyrinth/cavern"),
    "347MP84": ("MP84", "Level 8 Floor 4", "labyrinth/cavern"),
    "348MP8D": ("MP8D", "Level 8 Floor D (town/checkpoint)", "town"),
    "349MP90": ("MP90", "Level 9 Floor 0", "labyrinth/cavern"),
    "350MPA0": ("MPA0", "Level 10 (A) Floor 0 (final area)", "labyrinth/cavern"),
}


def parse_header(data):
    """Parse the 16-byte header.

    Layout observed (mirrors CMAP / earlier MP files):
      +0x00  WORD  total_size_minus_1  (= filesize - 1)
      +0x02  WORD  reserved / zero
      +0x04  WORD  ptr into file (runtime addr, subtract base_seg*0x10)
      +0x06  WORD  short descriptor/count
      +0x08  WORD  ptr into file
      +0x0A  WORD  ptr into file
      +0x0C  WORD  ptr into file
      +0x0E  WORD  ptr into file
    """
    if len(data) < 16:
        return None
    sz = data[0] | (data[1] << 8)
    return {
        "size_field": sz,
        "raw_header": data[:16],
    }


def find_sections(data):
    """Given the file bytes, try to identify the layout boundaries using pointers."""
    # Extract pointer candidates from the header area
    ptrs = []
    for off in (4, 8, 10, 12, 14):
        if off + 1 >= len(data):
            continue
        v = data[off] | (data[off+1] << 8)
        ptrs.append((off, v))
    return ptrs


def find_ascii_runs(data, min_len=6):
    """Find runs of printable ASCII bytes (candidate dialog strings)."""
    runs = []
    i = 0
    n = len(data)
    while i < n:
        if 0x20 <= data[i] <= 0x7E:
            j = i
            while j < n and 0x20 <= data[j] <= 0x7E:
                j += 1
            if j - i >= min_len:
                runs.append((i, j))
            i = j
        else:
            i += 1
    return runs


def hex_byte(b):
    """Format a byte as TASM hex literal (leading 0 for >=A0)."""
    if b >= 0xA0:
        return f"0{b:02X}h"
    return f"{b:02X}h"


def emit_db_block(data, start, end, indent="\t\t", per_line=12):
    """Emit a block of bytes as `db` lines."""
    out = []
    i = start
    while i < end:
        chunk = data[i:min(i + per_line, end)]
        parts = [hex_byte(b) for b in chunk]
        out.append(f"{indent}db\t{', '.join(parts)}")
        i += per_line
    return out


def emit_ascii_run(data, start, end, indent="\t\t"):
    """Emit a run of ASCII as db 'string' lines, handling backslash/quote."""
    out = []
    i = start
    while i < end:
        # wrap lines at ~64 chars
        chunk_end = min(i + 48, end)
        s = data[i:chunk_end].decode("latin-1")
        # TASM uses single-quoted literals. Only apostrophe is an issue -- split
        # the string at each apostrophe and emit the apostrophe as a separate
        # db 27h byte. Backslash is literal in TASM.
        if "'" in s:
            # Emit char-by-char to handle apostrophes
            parts = []
            buf = ""
            for ch in s:
                if ch == "'":
                    if buf:
                        parts.append(f"'{buf}'")
                        buf = ""
                    parts.append("27h")
                else:
                    buf += ch
            if buf:
                parts.append(f"'{buf}'")
            out.append(f"{indent}db\t{', '.join(parts)}")
        else:
            out.append(f"{indent}db\t'{s}'")
        i = chunk_end
    return out


def emit_data_with_strings(data, start, end, indent="\t\t"):
    """Emit a mixed block: find ASCII runs >= 6 chars, emit those as quoted strings,
    emit other bytes as hex db lines."""
    out = []
    i = start
    n_end = end
    while i < n_end:
        # scan ahead for an ASCII run
        run_start = None
        run_end = None
        j = i
        while j < n_end:
            if 0x20 <= data[j] <= 0x7E:
                k = j
                while k < n_end and 0x20 <= data[k] <= 0x7E:
                    k += 1
                if k - j >= 6:
                    run_start = j
                    run_end = k
                    break
                j = k
            else:
                j += 1
        if run_start is None:
            # emit remaining as hex
            out.extend(emit_db_block(data, i, n_end, indent))
            break
        # emit bytes before run as hex
        if run_start > i:
            out.extend(emit_db_block(data, i, run_start, indent))
        # emit ASCII run as quoted string
        out.extend(emit_ascii_run(data, run_start, run_end, indent))
        i = run_end
    return out


def generate_asm(bin_path, stem, desc_short, desc_full, kind):
    """Generate a clean ASM file for the given binary."""
    with open(bin_path, "rb") as f:
        data = f.read()

    sz = len(data)
    hdr = parse_header(data)

    # Pointers from header that reference into the file
    # Each pointer's file offset = ptr_value - base_seg*0x10; we detect base by finding a
    # pointer near end-of-file that references within-file.
    # For mapping, we use the most common high byte: typical values 0xC___ (base 0xC000).
    # We just emit them as-is and annotate.

    out = []
    out.append("")
    out.append("PAGE  59,132")
    out.append("")
    out.append(";==========================================================================")
    out.append(";")
    out.append(f";  {stem}.BIN - {desc_full}")
    out.append(";")
    out.append(f";  Zeliard dungeon map data file ({desc_short}). Loaded by stick.bin as an")
    out.append(f";  MDT (map data table). This is {kind} map data -- not executable code.")
    out.append(";")
    out.append(";  Sourcer mis-decoded the bytes as x86 instructions; this file re-emits")
    out.append(";  them as labeled `db` data blocks matching the original binary exactly.")
    out.append(";")
    out.append(";  Layout (16-byte header + pointer table, then tilemap/NPC/dialog/script):")
    out.append(";")
    out.append(f";    +0x00  size_word         - total size field ({hdr['size_field']:#06x} = {hdr['size_field']})")
    out.append(";    +0x02  reserved          - zero pad")
    out.append(";    +0x04..+0x0F  ptr table - runtime addresses (subtract map base seg for file offset)")
    out.append(";    +0x10  map_data          - tile grid + NPC/door cells")
    out.append(";    ...    dialog_strings    - 0xFF-terminated NPC dialog text")
    out.append(";    ...    script_trailer    - event trigger bytes (FFFF terminated)")
    out.append(";")
    out.append(";  Runtime load base varies per map; pointer high-byte indicates the segment.")
    out.append(";")
    out.append(";==========================================================================")
    out.append("")
    out.append("target\t\tEQU   'T2'                      ; Target assembler: TASM-2.X")
    out.append("")
    out.append("include  srmacros.inc")
    out.append("")
    out.append("seg_a\t\tsegment\tbyte public")
    out.append("\t\tassume\tcs:seg_a, ds:seg_a")
    out.append("")
    out.append("\t\torg\t0")
    out.append("")

    proc_name = f"map_{desc_short.lower()}"
    out.append(f"{proc_name}\tproc\tfar")
    out.append("")
    out.append("start:")
    out.append("")
    out.append("; ------------------------------------------------------------------")
    out.append("; Header: 16-byte map descriptor")
    out.append(";   +0x00 WORD  total_size_field (= map_size - 1 or similar)")
    out.append(";   +0x02 WORD  reserved (zero)")
    out.append(";   +0x04..+0x0F  runtime pointer table into this file")
    out.append("; ------------------------------------------------------------------")
    out.append("")
    out.append("map_header\tlabel\tword")
    def tasm_hex_word(v):
        # TASM requires leading 0 if first hex digit is >= A
        s = f"{v:04X}h"
        if s[0].isalpha():
            s = "0" + s
        return s
    # size word
    szw = data[0] | (data[1] << 8)
    out.append(f"\t\tdw\t{tasm_hex_word(szw)}\t\t; total_size field")
    # reserved
    rv = data[2] | (data[3] << 8)
    out.append(f"\t\tdw\t{tasm_hex_word(rv)}\t\t; reserved / zero")
    # 6 pointer words (remaining 12 bytes)
    for p_idx, off in enumerate((4, 6, 8, 10, 12, 14)):
        v = data[off] | (data[off+1] << 8)
        out.append(f"\t\tdw\t{tasm_hex_word(v)}\t\t; hdr ptr[{p_idx}] (runtime addr)")
    out.append("")

    # ---- Map body ----
    # Find last 0xFFFF terminator near EOF -> script trailer boundary
    # Find ASCII runs to mark dialog region
    body_start = 16

    ascii_runs = find_ascii_runs(data, min_len=8)
    # filter: only within body
    ascii_runs = [(a, b) for (a, b) in ascii_runs if a >= body_start]

    if ascii_runs:
        first_ascii = ascii_runs[0][0]
        last_ascii = ascii_runs[-1][1]
    else:
        first_ascii = sz
        last_ascii = sz

    # Find trailer: scan backward from end for run of 0xFF bytes before script data
    # The last few bytes are always terminator-ish. We simply split body into:
    #   map_data: 0x10 .. first_ascii (if any) else 0x10 .. trailer_start
    #   dialog_strings: first_ascii .. last_ascii
    #   script_trailer: last_ascii .. EOF
    # If no ascii runs, split body into map_data and script_trailer at some heuristic.

    # Script trailer typically starts with small bytes (0x18, 0x28, 0x2D, etc.) after
    # the last 0xFF dialog terminator. Find last 0xFF before last_ascii as end of dialog.
    if ascii_runs:
        # extend last_ascii forward through a 0xFF terminator if adjacent
        p = last_ascii
        while p < sz and data[p] == 0xFF:
            p += 1
        # include the single trailing 0xFF as part of dialog
        if last_ascii < sz and data[last_ascii] == 0xFF:
            last_ascii += 1

    map_data_start = body_start
    map_data_end = first_ascii if ascii_runs else sz
    dialog_start = first_ascii if ascii_runs else sz
    dialog_end = last_ascii if ascii_runs else sz
    trailer_start = last_ascii if ascii_runs else sz

    # Emit map_data
    if map_data_end > map_data_start:
        out.append("; ------------------------------------------------------------------")
        out.append("; map_data -- tile-grid / NPC records / door cells / event entries")
        out.append(";")
        out.append("; Tile indices, cell coordinates, and interactive-object records for")
        out.append("; this floor. Exact sub-structure depends on map variant; Sourcer")
        out.append("; mis-decoded these bytes as x86 mnemonics. Bytes are 1:1 with binary.")
        out.append("; ------------------------------------------------------------------")
        out.append("")
        out.append("map_data:")
        out.extend(emit_data_with_strings(data, map_data_start, map_data_end))
        out.append("")

    # Emit dialog_strings block
    if dialog_end > dialog_start:
        out.append("; ------------------------------------------------------------------")
        out.append("; dialog_strings -- NPC / sign / event text. Each string is")
        out.append("; terminated by 0xFF. Embedded bytes < 0x20 are control codes")
        out.append("; (color, speaker, animation) processed by the script interpreter.")
        out.append("; ------------------------------------------------------------------")
        out.append("")
        out.append("dialog_strings:")
        out.extend(emit_data_with_strings(data, dialog_start, dialog_end))
        out.append("")

    # Emit script_trailer (event script bytes)
    if sz > trailer_start:
        out.append("; ------------------------------------------------------------------")
        out.append("; script_trailer -- event / exit-trigger script bytes.")
        out.append("; Processed by the map-event interpreter when the player steps on")
        out.append("; a trigger cell. Variable-length records terminated by 0xFFFF.")
        out.append("; ------------------------------------------------------------------")
        out.append("")
        out.append("script_trailer:")
        out.extend(emit_data_with_strings(data, trailer_start, sz))
        out.append("")

    out.append(f"{proc_name}\tendp")
    out.append("")
    out.append("seg_a\t\tends")
    out.append("")
    out.append("\t\tend\tstart")
    out.append("")

    return "\n".join(out)


def main():
    code_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                            "working", "zelres3", "code")

    targets = [
        ("336MP62", "ASM"),
        ("337MP6D", "asm"),
        ("338MP70", "ASM"),
        ("339MP71", "ASM"),
        ("340MP72", "ASM"),
        ("341MP73", "ASM"),
        ("342MP7D", "ASM"),
        ("343MP80", "ASM"),
        ("344MP81", "ASM"),
        ("345MP82", "ASM"),
        ("346MP83", "ASM"),
        ("347MP84", "ASM"),
        ("348MP8D", "ASM"),
        ("349MP90", "ASM"),
        ("350MPA0", "ASM"),
    ]

    if len(sys.argv) > 1:
        targets = [(t[0], t[1]) for t in targets if t[0] in sys.argv[1:]]

    for stem, ext in targets:
        bin_path = os.path.join(code_dir, stem + ".bin")
        asm_path = os.path.join(code_dir, stem + "." + ext)
        short, full, kind = MAP_DESCRIPTIONS[stem]
        print(f"Generating {asm_path} ({full})...")
        text = generate_asm(bin_path, stem, short, full, kind)
        with open(asm_path, "w", newline="\n") as f:
            f.write(text)


if __name__ == "__main__":
    main()
