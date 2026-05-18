#!/usr/bin/env python3
"""Patch 200FIGHT.asm: add labels to all 52 dead code markers.
Labels produce no bytes - bit-perfect output is preserved.
"""

import re

asm_file = "C:/Projects/Zeliard/3_Assembly/tasm/working/zelres2/code/200FIGHT.asm"

with open(asm_file, 'r', errors='replace') as f:
    lines = f.readlines()

# Map from 1-indexed ASM line number to (label, comment_suffix)
# Each dead code marker line gets a label inserted before it,
# and the comment is updated.
# label is inserted as a new line BEFORE the marker line.
# The marker comment line itself is replaced with updated comment.

STANDARD_COMMENT = "\t\t\t                        ; Dead code ?-- no direct callers (dispatch table target or fall-through).\n"
FIRST_COMMENT = "\t\t\t                        ; Dead code ?-- no callers found.\n"
DEEP_COMMENT = "\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t                        ; Dead code ?-- no direct callers (dispatch table target or fall-through).\n"

# Each entry: (line_1indexed, label_text, new_comment_line)
patches = [
    (1449, "c2_clear_bit1:\n",
     "\t\t\t                        ; Dead code -- confirmed unreachable (after jmp scroll_retreat)\n"),

    (1817, "scroll_init_data_a:\n",
     "\t\t\t                        ; Scroll init data block A (dispatch table target or alignment padding)\n"),

    (1851, "scroll_init_data_b:\n",
     "\t\t\t                        ; Scroll init data block B (dispatch table target or alignment padding)\n"),

    (1921, "scroll_op_a_0:\n",
     "\t\t\t                        ; scroll_dispatch_a target: entry 0 (indirect via scroll_dispatch_a table)\n"),

    (1942, "scroll_op_b_0:\n",
     "\t\t\t                        ; scroll_dispatch_b target: entry 0 (indirect via scroll_dispatch_b table)\n"),

    (2972, "entity_dispatch_fn_0:\n",
     "\t\t\t                        ; entity_dispatch_tbl target: entity fn 0\n"),

    (3134, "entity_dispatch_fn_1:\n",
     "\t\t\t                        ; entity_dispatch_tbl target: entity fn 1\n"),

    (3233, "entity_dispatch_fn_2:\n",
     "\t\t\t                        ; entity_dispatch_tbl target: entity fn 2\n"),

    (3247, "entity_dispatch_fn_3:\n",
     "\t\t\t                        ; entity_dispatch_tbl target: entity fn 3\n"),

    (3250, "entity_dispatch_fn_4:\n",
     "\t\t\t                        ; entity_dispatch_tbl target: entity fn 4\n"),

    (4554, "entity_fn_a_0:\n",
     "\t\t\t                        ; entity_fn_tbl_a target: handler fn 0\n"),

    (4564, "entity_fn_a_1:\n",
     "\t\t\t                        ; entity_fn_tbl_a target: handler fn 1 (bit-clear and direction update)\n"),

    (4803, "entity_fn_tbl_b_data:\n",
     "\t\t\t                        ; Padding/data block (dispatch table alignment)\n"),

    (5044, "entity_fn_b_0:\n",
     "\t\t\t                        ; entity_fn_tbl_b target: handler fn 0\n"),

    (5055, "entity_fn_b_1:\n",
     "\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t                        ; entity_fn_tbl_b target: handler fn 1 (stc; retn)\n"),

    (5058, "entity_fn_b_2:\n",
     "\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t                        ; entity_fn_tbl_b target: handler fn 2 (dec al, mask)\n"),

    (5063, "entity_fn_b_3:\n",
     "\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t                        ; entity_fn_tbl_b target: handler fn 3 (inc al, mask)\n"),

    (5089, "entity_fn_c_0:\n",
     "\t\t\t                        ; entity_fn_tbl_c target: handler fn 0 (rotate/dispatch block)\n"),

    (5135, "entity_fn_c_1:\n",
     "\t\t\t                        ; entity_fn_tbl_c target: handler fn 1 (state byte 9F1F check)\n"),

    (5368, "entity_fn_d_data:\n",
     "\t\t\t                        ; Data block after game_func_106 (dispatch table alignment)\n"),

    (5449, "entity_fn_d_0:\n",
     "\t\t\t                        ; entity_fn_tbl_d target: handler fn 0 (fire slot init)\n"),

    (5538, "boss_scroll_init:\n",
     "\t\t\t                        ; Boss scroll init handler (resets anim counters, dispatch target)\n"),

    (5761, "entity_fn_d_1:\n",
     "\t\t\t                        ; entity_fn_tbl_d target: handler fn 1 (dispatch via [8AC6h][bx])\n"),

    (5768, "entity_fn_d_1_data:\n",
     "\t\t\t                        ; Data: dispatch table for [8AC6h] (6 targets in game seg)\n"),

    (5793, "boss_ctr_0a_handler:\n",
     "\t\t\t                        ; Boss behavior handler: increment counter, check 0Ah threshold\n"),

    (5802, "boss_ctr_0c_handler:\n",
     "\t\t\t                        ; Boss behavior handler: increment counter, check 0Ch threshold\n"),

    (5839, "boss_fire4_handler:\n",
     "\t\t\t                        ; Boss fire behavior handler: move 4 projectiles per step\n"),

    (5855, "boss_fire3_handler:\n",
     "\t\t\t                        ; Boss fire behavior handler: move 3 projectiles per step\n"),

    (6126, "anim_dispatch_stub:\n",
     "\t\t\t                        ; Animation dispatch stub via [8E14h][bx]\n"),

    (6129, "anim_dispatch_data:\n",
     "\t\t\t                        ; Data: animation dispatch table entries (game seg targets)\n"),

    (6184, "entity_fn_e_0:\n",
     "\t\t\t                        ; entity_fn_tbl_e target: handler fn 0 (flag_0a and column match)\n"),

    (6232, "entity_fn_e_1:\n",
     "\t\t\t                        ; entity_fn_tbl_e target: handler fn 1 (anim counter 3-step)\n"),

    (6240, "entity_fn_e_2:\n",
     "\t\t\t                        ; entity_fn_tbl_e target: handler fn 2 (game_scan_loop_10 gated)\n"),

    (6269, "entity_fn_e_tbl_data:\n",
     "\t\t\t                        ; Data: entity_fn_tbl_e dispatch entries (7 targets in game seg)\n"),

    (6341, "entity_fn_e_3:\n",
     "\t\t\t                        ; entity_fn_tbl_e target: handler fn 3 (enemy trigger at 9A72h)\n"),

    (6413, "entity_fn_e_4:\n",
     "\t\t\t                        ; entity_fn_tbl_e target: handler fn 4 (enemy trigger at 9AF3h)\n"),

    (6422, "entity_fn_e_5:\n",
     "\t\t\t                        ; entity_fn_tbl_e target: handler fn 5 (enemy trigger at 9B63h)\n"),

    (6431, "entity_fn_e_6:\n",
     "\t\t\t                        ; entity_fn_tbl_e target: handler fn 6 (area-based boss encounter)\n"),

    (6460, "entity_fn_tbl_e_stub:\n",
     "\t\t\t                        ; Stub data between slot_found and game_func_118\n"),

    (6549, "game_func_119_body:\n",
     "\t\t\t                        ; game_func_119 body: score update dispatch (via cs:[2016h])\n"),

    (6642, "game_func_122_b:\n",
     "\t\t\t                        ; game_func_122 variant B: check col 22h, dec_row\n"),

    (6679, "game_func_123_b:\n",
     "\t\t\t                        ; game_func_123 variant B: check col >= 2, dec_row\n"),

    (6707, "game_func_124_b:\n",
     "\t\t\t                        ; game_func_124 variant B: check col >= 2c, inc_row\n"),

    (6741, "game_func_125_b:\n",
     "\t\t\t                        ; game_func_125 variant B: check col 22h, inc_row\n"),

    (7434, "entity_fn_f_dispatch:\n",
     "\t\t\t                        ; entity_fn_tbl_f dispatch stub (al & 7, jmp via entity_fn_tbl_f[bx])\n"),

    (7440, "entity_fn_tbl_f_data:\n",
     "\t\t\t                        ; Data block after entity_fn_tbl_f dispatch\n"),

    (7489, "boss_fn_0:\n",
     "\t\t\t                        ; boss_fn_tbl target: boss fn 0 (call far, col 22h check)\n"),

    (7495, "boss_fn_1:\n",
     "\t\t\t                        ; boss_fn_tbl target: boss fn 1 (game_func_124, check_col_2b)\n"),

    (7498, "boss_fn_2:\n",
     "\t\t\t                        ; boss_fn_tbl target: boss fn 2 (game_func_123, check_al_zero)\n"),

    (7501, "boss_fn_3:\n",
     "\t\t\t                        ; boss_fn_tbl target: boss fn 3 (position lookup, atk_slot_check)\n"),

    (7507, "boss_fn_4:\n",
     "\t\t\t                        ; boss_fn_tbl target: boss fn 4 (apply damage)\n"),

    (7646, "boss_fn_tbl_data:\n",
     "\t\t\t                        ; Data block after game_multiply_5 (table alignment bytes)\n"),
]

# Build a set of target lines (0-indexed)
patch_map = {}
for line_1idx, label, new_comment in patches:
    patch_map[line_1idx - 1] = (label, new_comment)  # convert to 0-indexed

# Apply patches: for each target line, insert label line before it and replace comment
new_lines = []
for i, line in enumerate(lines):
    if i in patch_map:
        label, new_comment = patch_map[i]
        new_lines.append(label)       # insert label (produces no bytes)
        new_lines.append(new_comment) # replace comment
    else:
        new_lines.append(line)

with open(asm_file, 'w', newline='') as f:
    f.writelines(new_lines)

print(f"Patched {len(patches)} dead code markers.")
print(f"Original line count: {len(lines)}")
print(f"New line count:      {len(new_lines)}")
print(f"Added lines:         {len(new_lines) - len(lines)} (one label per marker)")
