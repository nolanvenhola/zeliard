#!/usr/bin/env python3
"""
Reorder EQU declarations in zelres3 ASM files into 7 stable sections.

Sections:
  1. Includes (already there)
  2. Module-local exports
  3. Game-segment globals (gvar_*) NOT in zr3com.inc
  4. Shared dispatch slot file-local overrides
  5. File-internal data table addresses (0xA000-0xEFFF range, table-ish)
  6. File-internal state variables (0xA000-0xEFFF range, state-ish)
  7. Constants (numeric literals, small values)
"""
import re
import sys
from pathlib import Path

CODE_DIR = Path(r"c:/Projects/Zeliard/3_Assembly/tasm/working/zelres3/code")

EQU_RE = re.compile(r'^(\S+)\s+equ\s+(.+?)(?:\s*;.*)?$', re.IGNORECASE)


def extract_zr3com_names():
    names = set()
    with (CODE_DIR / "zr3com.inc").open() as f:
        for line in f:
            line = line.strip()
            if line.startswith(';') or not line:
                continue
            m = re.match(r'(\S+)\s+equ\s+', line, re.IGNORECASE)
            if m:
                names.add(m.group(1).lower())
    return names


def parse_value(value):
    """Try to parse the value as int. Return (addr_or_None, is_symbolic)."""
    val = value.strip()
    # Strip simple expressions
    m = re.match(r'^([0-9A-Fa-f]+)h$', val)
    if m:
        return int(m.group(1), 16), False
    m = re.match(r'^([0-9]+)$', val)
    if m:
        return int(m.group(1)), False
    m = re.match(r'^0x([0-9A-Fa-f]+)$', val)
    if m:
        return int(m.group(1), 16), False
    return None, True  # symbolic expression


def categorize(name, value, zr3com_names):
    """Return (section, sort_key)."""
    name_l = name.lower()
    addr, symbolic = parse_value(value)

    # If references undefined names (symbolic), put in section 5 (data table refs)
    if symbolic:
        return 5, 0xFFFFFF  # symbolic expressions sort last in their section

    # gvar_* = section 3 (game-segment globals not in zr3com)
    # (Some are at 0xFFxx, some at low 0x00xx offsets in game_seg)
    # Also accept _gvar_ in any position (e.g. mao2_gvar_state_a)
    if name_l.startswith('gvar_') or '_gvar_' in name_l:
        return 3, addr

    # Names at 0xFFxx that start with module-prefix and look like state
    # (e.g. mao2_gvar_phase_byte=FF75, mao1_gvar_state_byte=FF75)
    if addr >= 0xFF00 and addr <= 0xFFFF:
        return 3, addr

    # Section 7: small numeric constants
    if addr < 0x100:
        return 7, addr

    # Section 2: module-local exports / driver dispatch table addresses
    # These are in 0x1000-0x9FFF range (CS-relative dispatch slots)
    if 0x1000 <= addr < 0xA000:
        return 2, addr

    # 0xA000-0xEFFF range = section 5 or 6 (data tables vs state vars)
    if 0xA000 <= addr <= 0xEFFF:
        # Heuristics
        # Strong "state" prefix patterns (checked first - these override table matches)
        state_prefix = ['cur_', 'bres_']
        for pfx in state_prefix:
            if name_l.startswith(pfx):
                return 6, addr

        # Definite tables (need to avoid prefix-collisions with state names)
        tbl_keywords = ['_tbl', '_table', 'tbl_', '_base', '_list',
                        '_data', 'dispatch', '_pat_',
                        '_fn_ptr', '_src', '_dst', '_record',
                        '_ptr', 'pose_y_', 'pose_vec_', 'pose_tile',
                        'tile_pose', 'frame_ptr', '_buf',
                        '_rotate_', 'rotate_', '_pattern',
                        '_seq', '_path_', '_glide_', '_anim_dx',
                        '_anim_dy', '_phase_xlat', '_tile_src',
                        '_phase_si_', '_phase_di_', '_phase_bp_',
                        '_anim_xlat',
                        '_speech_dx_', '_dlg_state',
                        '_col_hi', '_col_lo', '_tile_hi', '_tile_lo',
                        '_spawn_tile', '_spawn_col', '_spawn_cell',
                        '_aim_delta', '_init_record',
                        '_dialog_di_', '_dialog_bp_', '_dialog_lo_',
                        '_di_tbl', '_bp_tbl', '_si_tbl',
                        '_phase_handler_tbl', '_handler_step_tbl',
                        '_xlat_tbl', '_phase_ofs_tbl']
        # Definite state
        state_keywords = ['_phase', '_state', '_flag', '_idx',
                          '_cnt', '_counter', '_timer', '_dir',
                          '_pos', '_step', '_pal', '_aux',
                          'cur_', 'bres_', '_speed', '_limit',
                          '_hp', 'walk', '_attack', '_death',
                          '_anim_idx', '_anim_frame', '_anim_timer',
                          '_anim_byte', '_anim_state', '_sign',
                          '_dy', '_dx', '_error', '_started',
                          '_active', '_subflag', '_subcnt',
                          '_done', '_field', '_sub_',
                          '_byte', '_cycle', '_swoop', '_turn',
                          '_glide', '_attr', '_render', '_dive',
                          '_altitude', '_tmp', '_idle', '_locked',
                          '_delay', '_npc_', '_attack_', '_max',
                          '_substep', '_lock_ttl', '_init_render',
                          '_xlat_idx', '_xlat_done', '_render_mode',
                          '_target_idx', '_anim_step',
                          '_high_nib', '_finished', '_handler_step',
                          '_drv_', '_anim_handler_idx',
                          '_anim_subcounter', '_phase_byte',
                          '_attack_done', '_attack_flag',
                          '_phase_count', '_phase_limit',
                          '_phase_subflag', '_phase_substate',
                          '_phase_active', '_phase_locked',
                          '_phase_started', '_phase_step',
                          '_npc_idx', '_npc_ai_byte',
                          '_death_timer', '_death_step',
                          '_scroll_x', '_scroll_y',
                          '_scroll_phase', '_scroll_x_max',
                          '_scroll_max', '_render_buf',
                          '_render_attr', '_render_row',
                          '_render_col', '_attr_tmp',
                          '_attr_byte', '_attr_high_nib',
                          '_alt_state', '_alt_buf', '_alt_phase',
                          '_walk_state', '_init_field',
                          '_tile_phase', '_tile_field',
                          '_tile_buf', '_tile_param',
                          '_anim2_', '_anim_seg', '_anim_dispatch',
                          '_dlg_', '_dialog_', '_speech_',
                          '_clear_buf', '_extra_attr',
                          '_text_dst', '_handler_tbl',
                          '_handler_step_tbl', '_phase_handler',
                          '_anim_countdown', '_anim_finished',
                          '_pattern_idx', '_handler_idx',
                          '_attr_ptr_save', '_pos_word',
                          '_rng_bit', '_unk_a6c8', '_unk_c0b']
        # Special override: if it has both _tbl and _step, it's likely a table
        for kw in tbl_keywords:
            if kw in name_l:
                # but watch for things like '_phase_step_tbl' which is table
                return 5, addr
        for kw in state_keywords:
            if kw in name_l:
                return 6, addr
        # Final fallback heuristics by name pattern
        if name_l.endswith('_tbl') or name_l.endswith('_table') or '_tbl_' in name_l:
            return 5, addr
        # Default: state
        return 6, addr

    # Anything else → section 5 (high address tables not in known ranges)
    return 5, addr


def topo_sort_within_section(equs):
    """Sort EQUs within a section by address (then name)."""
    # Stable sort: items already sorted by (sort_key, original_index)
    return sorted(equs, key=lambda e: (e['sort_key'], e['name']))


def topo_sort_with_deps(equs, all_names):
    """Toposort; if EQU value references another local name, place after it."""
    # Build dependency graph
    name_to_eq = {e['name']: e for e in equs}
    deps = {e['name']: set() for e in equs}
    for e in equs:
        # Find references inside the value expression
        for token in re.findall(r'[A-Za-z_][A-Za-z0-9_]*', e['value']):
            if token in name_to_eq and token != e['name']:
                deps[e['name']].add(token)
    # Now do stable topo sort with key = (sort_key, name)
    sorted_eqs = topo_sort_within_section(equs)
    # If a dep is violated, swap. Use simple approach: iterate until stable.
    for _ in range(20):
        changed = False
        for i, e in enumerate(sorted_eqs):
            for dep_name in deps[e['name']]:
                # Find dep position
                for j, e2 in enumerate(sorted_eqs):
                    if e2['name'] == dep_name and j > i:
                        # Move e after dep
                        sorted_eqs.pop(i)
                        sorted_eqs.insert(j, e)
                        changed = True
                        break
                if changed:
                    break
            if changed:
                break
        if not changed:
            break
    return sorted_eqs


def build_section_block(section_num, section_name, equs):
    """Format the section's banner and EQUs."""
    if not equs:
        return ''
    out = []
    out.append('; ----------------------------------------------------------------------')
    out.append(f'; Section {section_num}: {section_name}')
    out.append('; ----------------------------------------------------------------------')
    for e in equs:
        out.append(e['line'])
    out.append('')
    return '\n'.join(out) + '\n'


def reorder_file(stem, dry_run=False):
    file_path = CODE_DIR / f"{stem}.asm"
    text = file_path.read_text()
    lines = text.splitlines()

    # Find anchors: target line, include zr3com.inc line, seg_a line
    target_idx = -1
    last_include_idx = -1
    seg_a_idx = -1
    for i, line in enumerate(lines):
        s = line.strip()
        if re.match(r"^target\s+EQU\s+'T2'", s, re.IGNORECASE):
            target_idx = i
        if re.match(r"^include\s+(srmacros\.inc|zr3com\.inc)", s, re.IGNORECASE):
            last_include_idx = i
        if re.match(r'^seg_a\s+segment', s, re.IGNORECASE):
            seg_a_idx = i
            break

    if target_idx < 0 or seg_a_idx < 0:
        print(f"{stem}: SKIP (anchors not found)")
        return None

    # Block to replace: from line after last include (or after target) up to (not including) seg_a
    block_start = max(last_include_idx, target_idx) + 1
    block_end = seg_a_idx  # exclusive

    # Extract EQU lines from block (with continuation comment lines)
    zr3com_names = extract_zr3com_names()
    equs = []
    i = block_start
    while i < block_end:
        line = lines[i]
        stripped = line.strip()
        m = EQU_RE.match(stripped)
        if m:
            name = m.group(1)
            value = m.group(2).strip()
            if name.lower() == 'target':
                i += 1
                continue
            # Capture continuation comment lines (indented ;-prefixed lines following)
            collected = [line]
            j = i + 1
            while j < block_end:
                cl = lines[j]
                cstrip = cl.strip()
                # Continuation comment: starts with ; AND has leading whitespace
                # AND is not a banner/section comment (no consecutive ; or ----)
                if (cl.startswith((' ', '\t')) and cstrip.startswith(';')
                    and '----' not in cstrip and '====' not in cstrip):
                    collected.append(cl)
                    j += 1
                else:
                    break
            section, sort_key = categorize(name, value, zr3com_names)
            equs.append({
                'name': name,
                'value': value,
                'line': '\n'.join(collected),
                'section': section,
                'sort_key': sort_key,
            })
            i = j
        else:
            i += 1

    if not equs:
        print(f"{stem}: no EQUs to reorder")
        return None

    # Build name set for dependency check
    all_names = {e['name'] for e in equs}

    # Group by section
    sections = {1: [], 2: [], 3: [], 4: [], 5: [], 6: [], 7: []}
    for e in equs:
        sections[e['section']].append(e)

    # Sort within each section (with dependency awareness)
    for sec in [2, 3, 4, 5, 6, 7]:
        sections[sec] = topo_sort_with_deps(sections[sec], all_names)

    # Build new block
    section_names = {
        1: 'Includes',
        2: 'Module-local exports',
        3: 'Game-segment globals (gvar_* not in zr3com.inc)',
        4: 'Shared dispatch slot file-local overrides',
        5: 'File-internal data table addresses',
        6: 'File-internal state variables',
        7: 'Constants',
    }

    new_block = []
    new_block.append('')  # blank line after include
    for sec in [2, 3, 4, 5, 6, 7]:
        if sections[sec]:
            block = build_section_block(sec, section_names[sec], sections[sec])
            new_block.append(block)

    new_block_text = '\n'.join(new_block)
    # Trim trailing empty lines so we can leave one blank line before seg_a
    while new_block_text.endswith('\n\n\n'):
        new_block_text = new_block_text[:-1]

    # Reassemble file
    new_lines = lines[:block_start] + new_block_text.split('\n') + lines[block_end:]
    # Avoid blank-line bloat: strip extra trailing blanks before seg_a
    # Find seg_a in new_lines
    new_text = '\n'.join(new_lines)
    # Collapse multiple consecutive blank lines into one (in our reordered region only)
    # Simplest: just write text and let result be reasonable

    section_summary = {sec: len(sections[sec]) for sec in [2,3,4,5,6,7] if sections[sec]}
    print(f"{stem}: total={len(equs)}, sections={section_summary}")

    if not dry_run:
        file_path.write_text(new_text)

    return new_text


def main():
    if len(sys.argv) < 2:
        print('Usage: reorder_zr3_equs.py <stem> [dry|wet]')
        sys.exit(1)
    stem = sys.argv[1]
    dry = (len(sys.argv) > 2 and sys.argv[2] == 'dry')
    reorder_file(stem, dry_run=dry)


if __name__ == '__main__':
    main()
