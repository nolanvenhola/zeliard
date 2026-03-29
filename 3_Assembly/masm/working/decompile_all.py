"""
decompile_all.py - Batch decompile all Zeliard code chunks using Cutter's rizin + rz-ghidra

For each code chunk binary:
  1. Loads with 16-bit x86 settings
  2. Runs full analysis (aaa)
  3. Decompiles every function with rz-ghidra (pdg)
  4. Saves output as <module_name>.c alongside the .asm file

Usage:
  python decompile_all.py              # All chunks
  python decompile_all.py main_game_loop  # Single module
"""

import subprocess
import os
import sys
import re

RIZIN = r"C:\Projects\Zeliard\3_Assembly\cutter\tool\rizin.exe"
CHUNKS_BASE = r"C:\Projects\Zeliard\2_SAR\ExtractedChunks"
WORKING_BASE = r"C:\Projects\Zeliard\3_Assembly\cutter\working"

# Map: (asm_name, chunk_binary_path)
CODE_CHUNKS = [
    # zelres1 code chunks
    ("zelres1/code/opening_scene",       "zelres1_extracted/chunk_00.bin"),
    ("zelres1/code/image_controller",    "zelres1_extracted/chunk_01.bin"),
    ("zelres1/code/equipment",           "zelres1_extracted/chunk_02.bin"),
    ("zelres1/code/image_decode",        "zelres1_extracted/chunk_03.bin"),
    ("zelres1/code/player_stats",        "zelres1_extracted/chunk_04.bin"),
    ("zelres1/code/palette_graphics",    "zelres1_extracted/chunk_05.bin"),
    ("zelres1/code/player_advanced",     "zelres1_extracted/chunk_06.bin"),
    ("zelres1/code/vga_decompressor",    "zelres1_extracted/chunk_07.bin"),
    ("zelres1/code/image_decoder_a",     "zelres1_extracted/chunk_08.bin"),
    ("zelres1/code/image_decoder_b",     "zelres1_extracted/chunk_09.bin"),
    ("zelres1/code/large_image_renderer","zelres1_extracted/chunk_10.bin"),
    ("zelres1/code/small_image_renderer","zelres1_extracted/chunk_11.bin"),
    ("zelres1/code/utilities_a",         "zelres1_extracted/chunk_24.bin"),
    ("zelres1/code/utilities_b",         "zelres1_extracted/chunk_30.bin"),

    # zelres2 code chunks
    ("zelres2/code/main_game_loop",      "zelres2_extracted/chunk_00.bin"),
    ("zelres2/code/combat_ui",           "zelres2_extracted/chunk_01.bin"),
    ("zelres2/code/sprite_renderer",     "zelres2_extracted/chunk_02.bin"),
    ("zelres2/code/physics_subsystems",  "zelres2_extracted/chunk_03.bin"),
    ("zelres2/code/physics_engine",      "zelres2_extracted/chunk_04.bin"),
    ("zelres2/code/animation_system",    "zelres2_extracted/chunk_05.bin"),
    ("zelres2/code/enemy_ai",            "zelres2_extracted/chunk_06.bin"),
    ("zelres2/code/enemy_slime",         "zelres2_extracted/chunk_07.bin"),
    ("zelres2/code/enemy_bat",           "zelres2_extracted/chunk_08.bin"),
    ("zelres2/code/enemy_spider",        "zelres2_extracted/chunk_09.bin"),
    ("zelres2/code/enemy_skeleton",      "zelres2_extracted/chunk_10.bin"),
    ("zelres2/code/enemy_ghost",         "zelres2_extracted/chunk_12.bin"),
    ("zelres2/code/enemy_goblin",        "zelres2_extracted/chunk_13.bin"),
    ("zelres2/code/enemy_orc",           "zelres2_extracted/chunk_14.bin"),
    ("zelres2/code/enemy_wizard",        "zelres2_extracted/chunk_15.bin"),
    ("zelres2/code/boss_behaviors",      "zelres2_extracted/chunk_16.bin"),
    ("zelres2/code/enemy_special",       "zelres2_extracted/chunk_17.bin"),
    ("zelres2/code/utility_a",           "zelres2_extracted/chunk_36.bin"),
    ("zelres2/code/utility_b",           "zelres2_extracted/chunk_38.bin"),

    # zelres3 code chunks
    ("zelres3/code/level_loader",        "zelres3_extracted/chunk_00.bin"),
    ("zelres3/code/level_renderer",      "zelres3_extracted/chunk_14.bin"),
    ("zelres3/code/tile_collision",      "zelres3_extracted/chunk_16.bin"),
    ("zelres3/code/town_npc",            "zelres3_extracted/chunk_20.bin"),
    ("zelres3/code/enemy_behavior",      "zelres3_extracted/chunk_22.bin"),
    ("zelres3/code/npc_interaction",     "zelres3_extracted/chunk_26.bin"),
    ("zelres3/code/trigger_events",      "zelres3_extracted/chunk_31.bin"),
    ("zelres3/code/enemy_manager",       "zelres3_extracted/chunk_32.bin"),
    ("zelres3/code/utility_small",       "zelres3_extracted/chunk_33.bin"),
    ("zelres3/code/boss_ai",             "zelres3_extracted/chunk_34.bin"),
    ("zelres3/code/boss_patterns",       "zelres3_extracted/chunk_35.bin"),
    ("zelres3/code/utility_tiny",        "zelres3_extracted/chunk_37.bin"),

    # core executables
    ("core/zeliad",                      None),  # use zeliad.exe directly
    ("drivers/gmmcga",                   None),  # no binary - skip
]


ANSI = re.compile(r'(\x1b\[[0-9;]*[mGKHFJ]|\[s\[999;999H[^\[]*\[u|\[s\[999;999H[^\n]*\[u)')

def rz(binary_path, cmds, timeout=60):
    """Run rizin commands and return clean stdout."""
    result = subprocess.run(
        [RIZIN, "-b", "16", "-q", "-c", cmds, binary_path],
        capture_output=True, timeout=timeout,
        env={**os.environ, "PATH": os.path.dirname(RIZIN) + ";" + os.environ.get("PATH", "")}
    )
    # Decode with errors='replace' to handle non-UTF8 bytes in rizin output
    stdout = result.stdout.decode('utf-8', errors='replace') if result.stdout else ''
    return ANSI.sub('', stdout)


def analyze_chunk(module_path, binary_path, force=False):
    """Analyze a chunk: function list, disassembly, xrefs, strings."""

    out_md = os.path.join(WORKING_BASE, module_path + ".md")
    out_rz = os.path.join(WORKING_BASE, module_path + ".rz")

    if not force and os.path.exists(out_md):
        print(f"  SKIP (exists): {os.path.basename(module_path)}.md")
        return True

    if not os.path.exists(binary_path):
        print(f"  SKIP (no binary): {os.path.basename(binary_path)}")
        return False

    size_kb = os.path.getsize(binary_path) / 1024
    module_name = os.path.basename(module_path)
    print(f"  Analyzing: {module_name} ({size_kb:.1f} KB)...", end="", flush=True)

    # Get function list
    func_list = rz(binary_path, "aaa; afl")
    func_addrs = re.findall(r'(0x[0-9a-f]+)', func_list)
    if not func_addrs:
        print(" no functions found")
        return False

    # Get strings
    strings = rz(binary_path, "aaa; iz")

    # Get disassembly for each function
    disasm_parts = []
    for addr in func_addrs[:50]:  # cap at 50 to avoid very long runs
        fn_disasm = rz(binary_path, f"aaa; s {addr}; pdf")
        disasm_parts.append(fn_disasm.strip())

    # Get xrefs summary
    xref_parts = []
    for addr in func_addrs[:20]:
        xrefs = rz(binary_path, f"aaa; s {addr}; axtj")
        if xrefs.strip() and xrefs.strip() != '[]':
            xref_parts.append(f"  {addr}:\n{xrefs.strip()}")

    # Write markdown output
    lines = []
    lines.append(f"# {module_name.upper()} - Analysis")
    lines.append(f"")
    lines.append(f"**Source:** `{os.path.basename(binary_path)}`  ")
    lines.append(f"**Size:** {size_kb:.1f} KB  ")
    lines.append(f"**Functions:** {len(func_addrs)}  ")
    lines.append(f"**Note:** 16-bit x86 real mode. `CS:0x10C` = chunk loader, `0xFF00+` = game state globals.")
    lines.append(f"")
    lines.append(f"> For Ghidra decompilation, open in Cutter: Architecture=x86, Bits=16, OS=dos")
    lines.append(f"")

    lines.append(f"## Function List")
    lines.append(f"```")
    lines.append(func_list.strip())
    lines.append(f"```")
    lines.append(f"")

    if strings.strip():
        lines.append(f"## Strings")
        lines.append(f"```")
        lines.append(strings.strip())
        lines.append(f"```")
        lines.append(f"")

    lines.append(f"## Function Disassembly")
    lines.append(f"")
    for i, (addr, disasm) in enumerate(zip(func_addrs, disasm_parts)):
        lines.append(f"### Function {addr}")
        lines.append(f"```asm")
        lines.append(disasm)
        lines.append(f"```")
        lines.append(f"")

    if xref_parts:
        lines.append(f"## Cross-References (callers)")
        lines.append(f"```json")
        lines.append('\n'.join(xref_parts))
        lines.append(f"```")

    with open(out_md, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines))

    # Save rizin load script
    with open(out_rz, 'w', encoding='utf-8') as f:
        f.write(f"# Rizin analysis script for {module_name}\n")
        f.write(f"# Usage: rizin -b 16 -i {module_name}.rz {os.path.basename(binary_path)}\n")
        f.write("e asm.bits=16\naaa\n")

    file_size = os.path.getsize(out_md)
    print(f" {len(func_addrs)} functions -> {file_size // 1024}KB")
    return True


def main():
    filter_name = sys.argv[1].lower() if len(sys.argv) > 1 else None
    force = "--force" in sys.argv

    print(f"Zeliard Batch Analyzer (rizin pdf + xrefs + strings)")
    print(f"Using: {RIZIN}")
    print(f"Output: {WORKING_BASE}")
    print()

    done = 0
    skipped = 0
    failed = 0

    for module_path, chunk_rel in CODE_CHUNKS:
        name = os.path.basename(module_path)

        # Filter to specific module if requested
        if filter_name and filter_name not in name:
            continue

        # Resolve binary path
        if chunk_rel is None:
            if "zeliad" in module_path:
                binary = r"C:\Projects\Zeliard\1_OriginalGame\zeliad.exe"
            else:
                skipped += 1
                continue
        else:
            binary = os.path.join(CHUNKS_BASE, chunk_rel)

        result = analyze_chunk(module_path, binary, force=force)
        if result:
            done += 1
        else:
            failed += 1

    print()
    print(f"Done: {done} decompiled, {skipped} skipped, {failed} failed")
    print(f"Output files in: {WORKING_BASE}")


if __name__ == "__main__":
    main()
