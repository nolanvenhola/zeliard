"""
export_c_arrays.py - Export all Zeliard chunk binaries as C uint16_t arrays

Output: cutter/working/<module>.c
Each file contains a uint16_t array of the raw binary data.

Usage:
  python export_c_arrays.py              # All chunks
  python export_c_arrays.py main_game_loop  # Single module
  python export_c_arrays.py --force      # Re-export existing
"""

import os
import sys

CHUNKS_BASE = r"C:\Projects\Zeliard\2_SAR\ExtractedChunks"
WORKING_BASE = r"C:\Projects\Zeliard\3_Assembly\cutter\working"

CODE_CHUNKS = [
    ("zelres1/code/opening_scene",        "zelres1_extracted/chunk_00.bin"),
    ("zelres1/code/image_controller",     "zelres1_extracted/chunk_01.bin"),
    ("zelres1/code/equipment",            "zelres1_extracted/chunk_02.bin"),
    ("zelres1/code/image_decode",         "zelres1_extracted/chunk_03.bin"),
    ("zelres1/code/player_stats",         "zelres1_extracted/chunk_04.bin"),
    ("zelres1/code/palette_graphics",     "zelres1_extracted/chunk_05.bin"),
    ("zelres1/code/player_advanced",      "zelres1_extracted/chunk_06.bin"),
    ("zelres1/code/vga_decompressor",     "zelres1_extracted/chunk_07.bin"),
    ("zelres1/code/image_decoder_a",      "zelres1_extracted/chunk_08.bin"),
    ("zelres1/code/image_decoder_b",      "zelres1_extracted/chunk_09.bin"),
    ("zelres1/code/large_image_renderer", "zelres1_extracted/chunk_10.bin"),
    ("zelres1/code/small_image_renderer", "zelres1_extracted/chunk_11.bin"),
    ("zelres1/code/utilities_a",          "zelres1_extracted/chunk_24.bin"),
    ("zelres1/code/utilities_b",          "zelres1_extracted/chunk_30.bin"),
    ("zelres2/code/main_game_loop",       "zelres2_extracted/chunk_00.bin"),
    ("zelres2/code/combat_ui",            "zelres2_extracted/chunk_01.bin"),
    ("zelres2/code/sprite_renderer",      "zelres2_extracted/chunk_02.bin"),
    ("zelres2/code/physics_subsystems",   "zelres2_extracted/chunk_03.bin"),
    ("zelres2/code/physics_engine",       "zelres2_extracted/chunk_04.bin"),
    ("zelres2/code/animation_system",     "zelres2_extracted/chunk_05.bin"),
    ("zelres2/code/enemy_ai",             "zelres2_extracted/chunk_06.bin"),
    ("zelres2/code/enemy_slime",          "zelres2_extracted/chunk_07.bin"),
    ("zelres2/code/enemy_bat",            "zelres2_extracted/chunk_08.bin"),
    ("zelres2/code/enemy_spider",         "zelres2_extracted/chunk_09.bin"),
    ("zelres2/code/enemy_skeleton",       "zelres2_extracted/chunk_10.bin"),
    ("zelres2/code/enemy_ghost",          "zelres2_extracted/chunk_12.bin"),
    ("zelres2/code/enemy_goblin",         "zelres2_extracted/chunk_13.bin"),
    ("zelres2/code/enemy_orc",            "zelres2_extracted/chunk_14.bin"),
    ("zelres2/code/enemy_wizard",         "zelres2_extracted/chunk_15.bin"),
    ("zelres2/code/boss_behaviors",       "zelres2_extracted/chunk_16.bin"),
    ("zelres2/code/enemy_special",        "zelres2_extracted/chunk_17.bin"),
    ("zelres2/code/utility_a",            "zelres2_extracted/chunk_36.bin"),
    ("zelres2/code/utility_b",            "zelres2_extracted/chunk_38.bin"),
    ("zelres3/code/level_loader",         "zelres3_extracted/chunk_00.bin"),
    ("zelres3/code/level_renderer",       "zelres3_extracted/chunk_14.bin"),
    ("zelres3/code/tile_collision",       "zelres3_extracted/chunk_16.bin"),
    ("zelres3/code/town_npc",             "zelres3_extracted/chunk_20.bin"),
    ("zelres3/code/enemy_behavior",       "zelres3_extracted/chunk_22.bin"),
    ("zelres3/code/npc_interaction",      "zelres3_extracted/chunk_26.bin"),
    ("zelres3/code/trigger_events",       "zelres3_extracted/chunk_31.bin"),
    ("zelres3/code/enemy_manager",        "zelres3_extracted/chunk_32.bin"),
    ("zelres3/code/utility_small",        "zelres3_extracted/chunk_33.bin"),
    ("zelres3/code/boss_ai",              "zelres3_extracted/chunk_34.bin"),
    ("zelres3/code/boss_patterns",        "zelres3_extracted/chunk_35.bin"),
    ("zelres3/code/utility_tiny",         "zelres3_extracted/chunk_37.bin"),
    ("core/zeliad",                       None),  # zeliad.exe
]


def export_c_array(module_path, binary_path, force=False):
    out_c = os.path.join(WORKING_BASE, module_path + ".c")

    if not force and os.path.exists(out_c):
        print(f"  SKIP: {os.path.basename(module_path)}.c")
        return True

    if not os.path.exists(binary_path):
        print(f"  SKIP (no binary): {os.path.basename(binary_path)}")
        return False

    data = open(binary_path, "rb").read()

    # Pad to even length for uint16_t
    if len(data) % 2:
        data += b'\x00'

    module_name = os.path.basename(module_path)
    array_name = module_name.replace("-", "_")
    n_words = len(data) // 2
    size_kb = len(data) / 1024

    lines = []
    lines.append(f"/* {module_name.upper()} - Zeliard 16-bit DOS chunk */")
    lines.append(f"/* Source: {os.path.basename(binary_path)} ({size_kb:.1f} KB, {n_words} words) */")
    lines.append(f"/* 16-bit x86 real mode. Load at CS:0x0000. */")
    lines.append(f"")
    lines.append(f"#include <stdint.h>")
    lines.append(f"")
    lines.append(f"#define {array_name.upper()}_SIZE {n_words}")
    lines.append(f"")
    lines.append(f"const uint16_t {array_name}[{array_name.upper()}_SIZE] = {{")

    # 8 words per line
    for i in range(0, n_words, 8):
        chunk = data[i*2 : (i+8)*2]
        words = [f"0x{chunk[j*2+1]:02X}{chunk[j*2]:02X}" for j in range(len(chunk)//2)]
        lines.append("    " + ", ".join(words) + ",")

    lines.append("};")

    os.makedirs(os.path.dirname(out_c), exist_ok=True)
    with open(out_c, "w") as f:
        f.write("\n".join(lines))

    print(f"  {module_name}: {n_words} uint16_t words -> {os.path.getsize(out_c) // 1024}KB")
    return True


def main():
    filter_name = sys.argv[1].lower() if len(sys.argv) > 1 and not sys.argv[1].startswith("--") else None
    force = "--force" in sys.argv

    print("Zeliard C Array Exporter")
    print(f"Output: {WORKING_BASE}")
    print()

    done = skipped = failed = 0

    for module_path, chunk_rel in CODE_CHUNKS:
        name = os.path.basename(module_path)

        if filter_name and filter_name not in name:
            continue

        if chunk_rel is None:
            binary = r"C:\Projects\Zeliard\1_OriginalGame\zeliad.exe"
        else:
            binary = os.path.join(CHUNKS_BASE, chunk_rel)

        if export_c_array(module_path, binary, force=force):
            done += 1
        else:
            failed += 1

    print()
    print(f"Done: {done} exported, {failed} failed")


if __name__ == "__main__":
    main()
