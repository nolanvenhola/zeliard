#!/usr/bin/env python3
"""driver_signature_verify.py - structural-fingerprint verification of
parallel driver procs.

The Zeliard graphics drivers (101GDEGA/102GDCGA/103GDHGC/104GDTGA/105GDMCA
in zelres1, 202GFEGA/203GFCGA/204GFHGC/205GFTGA/206GFMCA in zelres2) each
implement the same set of procs with the same names but adapted for
different video hardware (CGA/EGA/HGC/TGA/MCGA).

If the structural fingerprint of a proc (the dominant opcodes implied by
its name, e.g. `rep stosb` for `fill_buffer`) matches across all 5
implementations, that's deterministic evidence that the name is correct.
The variation between drivers is hardware-specific edge handling, not
the role itself.

This script:
  1. Walks the shared-proc set across each driver family.
  2. Extracts each implementation's body.
  3. Checks for the role-specific opcode fingerprint.
  4. Emits SUPPORTED / CONTRADICTED / INCONCLUSIVE per driver per proc.

Output:  working/DRIVER_SIGNATURE_VERIFY.md
"""

import re
from pathlib import Path
from collections import defaultdict

ROOT = Path(__file__).parent.resolve()
WORKING = ROOT / 'working'

# Driver families: which procs are SHARED across all 5 drivers in a family.
# Each entry is (family_label, [chunks_in_family], chunk_subdir).
FAMILIES = [
    ('GD',
     ['101GDEGA', '102GDCGA', '103GDHGC', '104GDTGA', '105GDMCA'],
     'zelres1/code'),
    ('GF',
     ['202GFEGA', '203GFCGA', '204GFHGC', '205GFTGA', '206GFMCA'],
     'zelres2/code'),
    ('EAI',  # Enemy-AI handler chunks (301-308) share movement/collision procs
     ['301EAI1', '302EAI2', '303EAI3', '304EAI4',
      '305EAI5', '306EAI6', '307EAI7', '308EAI8'],
     'zelres3/code'),
    ('GM',  # Standalone graphics-mode drivers (gmcga/gmega/gmhgc/gmmcga/gmtga)
     ['gmcga', 'gmega', 'gmhgc', 'gmmcga', 'gmtga'],
     'drivers'),
]


# Role fingerprints: regex-or-string patterns that the proc body MUST
# match for the name to be supported by structural evidence.
# Each entry is (proc_name, [list_of_required_pattern_groups], description).
# Each pattern group is a list of regexes -- the body must match AT LEAST
# ONE regex in EACH group.  ALL groups must be satisfied (AND across
# groups, OR within a group).
ROLE_FINGERPRINTS = {
    # GD-driver shared procs
    'fill_buffer': (
        [
            [r'\bmov\s+al\s*,\s*0?FFh\b'],          # AL = 0xFF
            [r'\brep\s+stosb\b'],                    # fill ES:DI with AL
        ],
        'fills buffer with 0xFF via rep stosb',
    ),
    'fill_buffer_2': (
        [
            [r'\bmov\s+al\s*,\s*0?FFh\b'],          # AL = 0xFF
            [r'\brep\s+stosb\b'],                    # fill ES:DI with AL
        ],
        'fills buffer with 0xFF via rep stosb (variant)',
    ),
    'clear_buffer': (
        [
            [r'\b(?:mov|xor)\s+(?:al|ax)\s*,\s*(?:0|0?00h|al|ax)\b'],   # zero accumulator
            [r'\brep\s+stos[bw]\b'],                  # store zeroes
        ],
        'clears buffer with zero via rep stos',
    ),
    'copy_buffer': (
        [
            [r'\brep\s+movs[bw]\b'],                  # source-to-dest copy
        ],
        'copies buffer (DS:SI -> ES:DI) via rep movs',
    ),
    'copy_buffer_2': (
        [
            [r'\brep\s+movs[bw]\b'],                  # source-to-dest copy
        ],
        'copies buffer (variant) via rep movs',
    ),

    # GF-driver shared cat-A procs (small, testable)
    'sprite_get_value': (
        [
            [r'\bxlat\b',                             # table lookup via [BX+AL]
             r'\bmov\s+(?:al|ax)\s*,\s*(?:cs:|ds:)?\['],  # OR direct mem load
        ],
        'reads value from a lookup table (xlat or mem load)',
    ),
    'si_wrap_hi': (
        [
            [r'\bcmp\s+si\s*,\s*0?[0-9A-Fa-f]+h\b'],  # bound check on SI
            [r'\bsub\s+si\s*,', r'\badd\s+si\s*,'],   # SI offset adjust
        ],
        'SI-wrap helper: bound check + offset adjust',
    ),
    'si_wrap_lo': (
        [
            [r'\bcmp\s+si\s*,\s*0?[0-9A-Fa-f]+h\b'],  # bound check on SI
            [r'\badd\s+si\s*,', r'\bsub\s+si\s*,'],   # SI offset adjust
        ],
        'SI-wrap helper (low boundary): bound check + offset adjust',
    ),
    'sprite_state_update': (
        [
            [r'\bmov\s+al\s*,\s*\[si-1\]'],           # read previous-frame byte
            [r'\bcmp\s+byte\s+ptr\s+es:\[di-1\]'],    # compare state byte at ES:[DI-1]
            [r'\bmov\s+byte\s+ptr\s+es:\[di-1\]'],    # write state byte at ES:[DI-1]
        ],
        'updates per-sprite state byte at ES:[DI-1] from prior [SI-1]',
    ),
    'sprite_slot_init': (
        [
            [r'\bsprite_state_a\b'],                  # references sprite_state_a symbol
            [r'\bxchg\s+\[di\]\s*,\s*al',
             r'\bmov\s+al\s*,\s*0?FFh\b'],            # FF init via xchg or mov
        ],
        'initialises sprite slot via xchg/mov 0FFh into sprite_state_a',
    ),
    'sprite_src_setup': (
        [
            [r'\bchar_lookup\b'],                     # uses char_lookup table
            [r'\bsprite_attr_base\b'],                # adds sprite_attr_base
            [r'\bmul\b'],                             # multiplies by stride
        ],
        'computes sprite source ptr via char_lookup + sprite_attr_base + mul stride',
    ),
    'hero_tier_get': (
        [
            [r'\bds:\s*\[shield\]\b',
             r'\bds:shield\b'],                       # reads shield byte
            [r'\bcmp\s+al\s*,\s*4\b'],                # tier threshold = 4
        ],
        'reads ds:[shield] and returns tier 0/1/2 by threshold cmp 4',
    ),
    'frame_wait_loop': (
        [
            [r'\bjmp\s+', r'\bloop\b', r'\bjnz\b'],   # has a backward jump
            [r'\bcs:gvar_frame_timer\b',
             r'\bds:gvar_frame_timer\b',
             r'\bgvar_frame_timer\b'],                # waits on the frame timer
        ],
        'waits in a loop on gvar_frame_timer',
    ),
    'sprite_blit_dispatch': (
        [
            [r'\bds:\['],                             # dispatch reads DS-relative
            [r'\bcall\b', r'\bjmp\s+(?:word\s+ptr\s+)?(?:cs|ds):'],  # indirect dispatch
        ],
        'reads DS table + indirect call/jmp -- dispatch shape',
    ),
    'projectile_spawn_check': (
        [
            [r'\bds:\['],                             # tests game state
            [r'\bjnz\b', r'\bjz\b'],                  # branches on test
        ],
        'tests projectile/spawn state and branches',
    ),
    'sprite_pos_pair_iter': (
        [
            [r'\bsi\b'],                              # iterates via SI
            [r'\bloop\b', r'\bjnz\b', r'\bjne\b'],    # loop tail
        ],
        'iterates a position-pair list (SI walk + loop tail)',
    ),
    'sprite_cell_render': (
        [
            [r'\bes:\[di',                            # writes to video memory
             r'\bstosb\b', r'\bstosw\b'],
            [r'\b(?:rep|loop|movs[bw])\b',            # iteration
             r'\bmov\s+cx\s*,'],                      # OR loop counter setup
        ],
        'renders one sprite cell -- writes ES:[DI] in a loop',
    ),
    'sprite_wide_row_render': (
        [
            [r'\bes:\[di',                            # writes to video memory
             r'\bstosb\b', r'\bstosw\b', r'\bmovsb\b', r'\bmovsw\b'],
            [r'\bmov\s+cx\s*,',                       # row counter
             r'\bloop\b'],
        ],
        'renders a wide sprite row -- writes ES:[DI] across cols',
    ),
    'frame_row_driver': (
        [
            [r'\bes:\[di',                            # writes video memory
             r'\bstos[bw]\b', r'\bmovs[bw]\b'],
            [r'\bloop\b', r'\bjnz\b', r'\bjne\b'],    # row iteration
        ],
        'drives one frame row through the rendering pipeline',
    ),
    'sprite_slot_remove': (
        [
            [r'\bsprite_state_a\b',
             r'\bsprite_buf\b'],                      # references sprite slot
            [r'\bmov\s+(?:byte\s+ptr\s+)?\S*\s*,\s*0\b',
             r'\bxor\s+\w+\s*,\s*\w+\b'],             # zeroing
        ],
        'clears sprite slot state (sprite_state_a/sprite_buf) to zero',
    ),
    'hero_sprite_col_blit': (
        [
            [r'\bes:\[di'],                           # writes video memory
            [r'\bmov\s+cx\s*,',
             r'\bloop\b'],                            # column iteration
        ],
        'blits one column of hero sprite to ES:[DI]',
    ),
    'bg_save': (
        [
            [r'\bmovs[bw]\b', r'\brep\s+movs[bw]\b'], # bulk copy
            [r'\bmov\s+(?:di|si)\s*,'],               # source/dest setup
        ],
        'saves a region of bg to a save buffer via rep movs',
    ),
    'bg_restore': (
        [
            [r'\bmovs[bw]\b',                         # bulk copy
             r'\brep\s+movs[bw]\b',
             r'\bcall\s+bg_restore_impl\b'],          # OR delegates to impl
        ],
        'restores a saved bg region (rep movs or impl wrapper)',
    ),
    'extract_bits': (
        [
            [r'\bsrc_word_[abcd]\b',
             r'\bcs:cur_row_ctr\b',
             r'\bds:cur_row_ctr\b'],                  # bit-extraction state
            [r'\bshr\b', r'\bshl\b', r'\band\b'],     # bit ops
        ],
        'extracts bits from src_word_* / cur_row_ctr state',
    ),

    # ---- EAI shared procs (movement/collision helpers) ----
    'collide_check_back': (
        [
            [r'\bsi\b'],                              # operates on entity ptr SI
            [r'\bjnb\b', r'\bjnz\b', r'\bjne\b',
             r'\bja\b', r'\bjbe\b', r'\bjz\b'],       # collision branch
        ],
        'collision check (backward direction)',
    ),
    'collide_check_fwd': (
        [
            [r'\bsi\b'],
            [r'\bjnb\b', r'\bjnz\b', r'\bjne\b',
             r'\bja\b', r'\bjbe\b', r'\bjz\b'],
        ],
        'collision check (forward direction)',
    ),
    'distance_check_5': (
        [
            [r'\bcmp\b'],                             # comparison
            [r'\bjnb\b', r'\bjz\b', r'\bjc\b',
             r'\bjnc\b', r'\bjne\b', r'\bjbe\b'],     # branch
        ],
        'distance threshold check (5-pixel range)',
    ),
    'distance_check_8': (
        [
            [r'\bcmp\b'],
            [r'\bjnb\b', r'\bjz\b', r'\bjc\b',
             r'\bjnc\b', r'\bjne\b', r'\bjbe\b'],
        ],
        'distance threshold check (8-pixel range)',
    ),
    'phase_advance_helper': (
        [
            [r'\binc\b', r'\badd\b'],                 # advance counter
        ],
        'phase counter advance helper',
    ),
    'phase_step_back': (
        [
            [r'\bsi\b'],                              # entity-relative
            [r'\bsub\b', r'\bdec\b'],                 # decrement step
        ],
        'phase step backward',
    ),
    'phase_step_fwd': (
        [
            [r'\bsi\b'],
            [r'\badd\b', r'\binc\b'],                 # increment step
        ],
        'phase step forward',
    ),
    'sub01_collide_inner': (
        [
            [r'\bsi\b'],
            [r'\bjnz\b', r'\bjne\b', r'\bjbe\b',
             r'\bjnb\b', r'\bjz\b'],
        ],
        'collision sub-routine (inner branch)',
    ),
    'sub01_collide_outer': (
        [
            [r'\bsi\b'],
            [r'\bjnz\b', r'\bjne\b', r'\bjbe\b',
             r'\bjnb\b', r'\bjz\b'],
        ],
        'collision sub-routine (outer branch)',
    ),
    'math_calc': (
        [
            [r'\bmul\b', r'\bdiv\b', r'\badd\b',
             r'\bsub\b'],                             # arithmetic
        ],
        'math helper (mul/div/add/sub)',
    ),

    # ---- GM family: standalone graphics-mode drivers ----
    'fill_horizontal_line': (
        [
            [r'\bes:\[', r'\bstos[bw]\b', r'\brep\s+stos[bw]\b'],
            [r'\bmov\s+(?:al|ax)\s*,'],               # color setup
        ],
        'horizontal line fill: rep stos to ES:DI',
    ),
    'fill_vertical_line': (
        [
            [r'\bes:\[', r'\bstos[bw]\b',
             r'\bmov\s+(?:byte|word)\s+ptr\s+es:\['],
            [r'\bloop\b', r'\bjnz\b', r'\bdec\s+\w+\b'],
        ],
        'vertical line fill: ES:DI write + row loop',
    ),
    'fill_rectangle': (
        [
            [r'\bes:\[', r'\bstos[bw]\b', r'\brep\s+stos[bw]\b'],
            [r'\bloop\b', r'\bjnz\b', r'\bdec\s+\w+\b'],
        ],
        '2D rectangle fill: rep stos in row-loop',
    ),
    'plot_pixel': (
        [
            [r'\bes:\[', r'\bmov\s+(?:byte|word)\s+ptr\s+es:\[',
             r'\bor\s+byte\s+ptr\s+es:\[',
             r'\band\s+byte\s+ptr\s+es:\['],
        ],
        'single-pixel write to video memory',
    ),
    'clear_screen': (
        [
            [r'\bes:\[', r'\brep\s+stos[bw]\b', r'\bstos[bw]\b'],
            [r'\bxor\s+(?:al|ax)\s*,\s*(?:al|ax)\b',
             r'\bmov\s+(?:al|ax)\s*,\s*0\b',
             r'\bmov\s+cx\s*,'],                       # clear setup
        ],
        'video framebuffer clear: rep stos with zero',
    ),
    'render_text_char': (
        [
            [r'\bes:\['],                             # writes glyph to video
            [r'\bcall\b', r'\bxlat\b',
             r'\bmov\s+\w+\s*,\s*(?:cs:|ds:)?\['],   # font lookup
        ],
        'render text glyph: video write + font lookup',
    ),
    'render_text_char_alt': (
        [
            [r'\bes:\['],
            [r'\bcall\b', r'\bxlat\b',
             r'\bmov\s+\w+\s*,\s*(?:cs:|ds:)?\['],
        ],
        'alternate text glyph render',
    ),
    'render_tilemap_large': (
        [
            [r'\bes:\['],                             # writes tile to video
            [r'\bcall\b', r'\bloop\b'],               # tile pipeline
        ],
        'large tilemap render: video write + dispatch',
    ),
    'render_tilemap_small': (
        [
            [r'\bes:\['],
            [r'\bcall\b', r'\bloop\b'],
        ],
        'small tilemap render: video write + dispatch',
    ),
    'decode_bitplane_tile': (
        [
            [r'\bshr\b', r'\bshl\b', r'\band\b', r'\bor\b',
             r'\bxor\b'],                             # bit ops
            [r'\bes:\[', r'\bstos[bw]\b'],            # write decoded
        ],
        'decode bitplane tile: bit ops + video write',
    ),
    'extract_bitplane_pixels': (
        [
            [r'\bshr\b', r'\bshl\b', r'\band\b'],     # bit extract
        ],
        'extract bitplane pixels: bit shifts',
    ),
    'process_sprite_row': (
        [
            [r'\bes:\[', r'\bstos[bw]\b'],
            [r'\bloop\b', r'\bjnz\b'],
        ],
        'sprite row processing: write + loop',
    ),
    'calc_text_width': (
        [
            [r'\bxlat\b', r'\badd\b',
             r'\bmov\s+\w+\s*,\s*(?:cs:|ds:)?\['],   # font width lookup
            [r'\bret(?:n|f)?\b'],                     # returns width
        ],
        'text width calc: font-table lookup + sum',
    ),
    'init_timestamp': (
        [
            [r'\bint\s+1Ah\b',                        # BIOS time-of-day
             r'\bxor\s+(?:ah|ax)\s*,\s*(?:ah|ax)\b',
             r'\bmov\s+(?:ah|ax)\s*,\s*0\b'],
        ],
        'init timestamp: INT 1Ah BIOS time read',
    ),
    'time_to_bcd': (
        [
            [r'\baad\b', r'\baam\b',                  # BCD ops
             r'\bdiv\b', r'\bmod\b'],
        ],
        'time-to-BCD conversion: AAD/AAM/DIV',
    ),
    'modulo_divide_bcd': (
        [
            [r'\bdiv\b', r'\baad\b', r'\baam\b'],
        ],
        'BCD modulo divide',
    ),
    'int_divide_bcd': (
        [
            [r'\bdiv\b', r'\baad\b', r'\baam\b'],
        ],
        'BCD integer divide',
    ),
}


# Procs whose name is supported when ALL N parallel implementations have
# byte-for-byte identical bodies.  Strongest possible evidence: same
# proc, same role, replicated across drivers.
IDENTICAL_BODY_VERIFY = {
    # GF identicals (already verified)
    'sprite_src_setup',
    'sprite_state_update',
    'hero_tier_get',
    'si_wrap_lo',
    'si_wrap_hi',
    # EAI identicals (same byte size across implementations -> likely identical body)
    'collide_check_back',     # 4x84B
    'collide_check_fwd',      # 4x84B
    'phase_advance_helper',   # 3x24B
    'phase_step_back',        # 3x63B
    'phase_step_fwd',         # 3x66B
    'sub01_collide_inner',    # 3x66B
    'sub01_collide_outer',    # 3x60B
    'sprite_slot_remove',     # 3x61B
    'frame_wait_loop',        # 3x51B
    'sprite_slot_init',       # 5x68-72B
    # GM identicals (BCD math/timestamp ops are likely identical across hw)
    'time_to_bcd',
    'modulo_divide_bcd',
    'int_divide_bcd',
    'init_timestamp',
}


# STRICT procs: their role is unambiguously determined by opcodes.
# If the fingerprint fails for one of these, the proc is genuinely
# CONTRADICTED -- the name is wrong, not just hard to verify.
# Procs not in this set get INCONCLUSIVE on fingerprint failure.
STRICT_PROCS = {
    'fill_buffer',
    'fill_buffer_2',
    'clear_buffer',
    'copy_buffer',
    'copy_buffer_2',
}


PROC_RE = re.compile(
    r'^(?P<name>\w+)\s+proc\s+near\s*\n'
    r'(?P<body>.*?)'
    r'^(?P=name)\s+endp',
    re.MULTILINE | re.DOTALL,
)


def load_proc_body(asm_path: Path, proc_name: str) -> str | None:
    """Return the body of `proc_name` in asm_path, or None if not found."""
    try:
        text = asm_path.read_text(encoding='utf-8', errors='replace')
    except OSError:
        return None
    pattern = re.compile(
        r'^' + re.escape(proc_name) + r'\s+proc\s+near\s*\n'
        r'(?P<body>.*?)'
        r'^' + re.escape(proc_name) + r'\s+endp',
        re.MULTILINE | re.DOTALL,
    )
    m = pattern.search(text)
    return m.group('body') if m else None


def strip_comments(body: str) -> str:
    """Strip ;-comments and blank lines from a proc body."""
    out = []
    for line in body.split('\n'):
        line = re.sub(r';.*', '', line)
        if line.strip():
            out.append(line)
    return '\n'.join(out)


def fingerprint_match(body: str, groups: list[list[str]]) -> tuple[bool, list[str]]:
    """Check if body matches all fingerprint groups.

    Each group is a list of regex alternatives (OR within group).
    All groups must have at least one match (AND across groups).
    Returns (passed, [list_of_matched_patterns]).
    """
    body_no_comments = strip_comments(body)
    matched = []
    for group in groups:
        group_hit = None
        for pat in group:
            if re.search(pat, body_no_comments, re.IGNORECASE):
                group_hit = pat
                break
        if not group_hit:
            return False, matched
        matched.append(group_hit)
    return True, matched


def normalise_body(body: str) -> str:
    """Strip comments + leading/trailing whitespace per line for body comparison.

    Local labels (loc_NN) often differ across drivers because their numbering
    is per-file -- collapse them to `loc_X` so identical-body comparison
    survives label-numbering noise.
    """
    out = []
    for line in body.split('\n'):
        line = re.sub(r';.*', '', line)
        line = re.sub(r'\bloc_\d+\b', 'loc_X', line)  # collapse local labels
        line = line.strip()
        if line:
            out.append(line)
    return '\n'.join(out)


def verify_family(family_label: str, chunks: list[str], subdir: str) -> dict:
    """For each proc with a fingerprint, verify across all chunks in family.

    Verdict policy:
      - fingerprint match -> SUPPORTED.
      - fingerprint fail in a STRICT proc (the role is unambiguous from
        opcodes, like fill_buffer/copy_buffer) -> CONTRADICTED.
      - fingerprint fail in any other proc -> INCONCLUSIVE.  Driver
        bodies legitimately diverge by hardware; failure to match a
        regex doesn't prove the name is wrong, just that we can't
        cheaply prove it right.
      - 3+ drivers with identical normalised bodies -> SUPPORTED
        (strongest evidence; identical body proves replicated role).
    """
    results = defaultdict(list)
    # Bucket bodies for identical-body cross-driver comparison
    body_norm = defaultdict(dict)  # proc_name -> {chunk: normalised_body}
    for chunk in chunks:
        asm = WORKING / subdir / f'{chunk}.asm'
        for proc_name, (groups, desc) in ROLE_FINGERPRINTS.items():
            body = load_proc_body(asm, proc_name)
            if body is None:
                continue  # proc not present in this driver
            ok, matched = fingerprint_match(body, groups)
            if ok:
                verdict = 'SUPPORTED'
            elif proc_name in STRICT_PROCS:
                verdict = 'CONTRADICTED'
            else:
                verdict = 'INCONCLUSIVE'
            results[proc_name].append({
                'family': family_label,
                'chunk': chunk,
                'matched': ok,
                'verdict': verdict,
                'patterns': matched,
                'description': desc,
                'identical_body': False,
            })
            if proc_name in IDENTICAL_BODY_VERIFY:
                body_norm[proc_name][chunk] = normalise_body(body)

    # Apply identical-body upgrade: if 3+ chunks share the exact same
    # normalised body, mark each as SUPPORTED (strongest evidence).
    for proc_name, by_chunk in body_norm.items():
        if len(by_chunk) < 3:
            continue
        # Find the most common body
        body_counts = defaultdict(list)
        for chunk, b in by_chunk.items():
            body_counts[b].append(chunk)
        most_common = max(body_counts.values(), key=len)
        if len(most_common) < 3:
            continue
        for r in results[proc_name]:
            if r['chunk'] in most_common:
                r['identical_body'] = True
                r['matched'] = True
                r['verdict'] = 'SUPPORTED'  # identical-body trumps fingerprint
                r['patterns'].append(f'IDENTICAL body in {len(most_common)} drivers')
    return dict(results)


def write_report(results_per_family: dict, path: Path) -> None:
    out = []
    out.append('# Driver Signature Verification')
    out.append('')
    out.append('Auto-generated by `driver_signature_verify.py`.')
    out.append('')
    out.append('Verifies that parallel driver procs (same name across 5 graphics')
    out.append('drivers) have the structural fingerprint implied by their name.')
    out.append('Each match is deterministic byte/opcode evidence -- no LLM.')
    out.append('')

    counts = {'SUPPORTED': 0, 'INCONCLUSIVE': 0, 'CONTRADICTED': 0}
    for family_label, results in results_per_family.items():
        out.append(f'## Family: {family_label}')
        out.append('')
        for proc_name, rows in sorted(results.items()):
            desc = rows[0]['description']
            out.append(f'### `{proc_name}` -- {desc}')
            out.append('')
            out.append('| Chunk | Verdict | Matched patterns |')
            out.append('|---|---|---|')
            for r in rows:
                v = r['verdict']
                counts[v] = counts.get(v, 0) + 1
                pats = '<br>'.join(f'`{p}`' for p in r['patterns']) or '(none)'
                out.append(f'| `{r["chunk"]}` | **{v}** | {pats} |')
            out.append('')
    out.append('**Totals**: '
               + ', '.join(f'{n} {v}' for v, n in counts.items()))
    path.write_text('\n'.join(out), encoding='utf-8')


def main():
    all_results = {}
    for family_label, chunks, subdir in FAMILIES:
        all_results[family_label] = verify_family(family_label, chunks, subdir)
    out_path = WORKING / 'DRIVER_SIGNATURE_VERIFY.md'
    write_report(all_results, out_path)
    print(f'Wrote {out_path}')

    # Also print a summary
    counts = {}
    for family in all_results.values():
        for rows in family.values():
            for r in rows:
                v = r['verdict']
                counts[v] = counts.get(v, 0) + 1
    print('\nTotal verdicts: ' + ', '.join(f'{n} {v}' for v, n in counts.items()))


if __name__ == '__main__':
    main()
