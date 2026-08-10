#!/usr/bin/env python3
"""classify.py — feature-extract every `proc near` in the cleaned tree
and emit functest/coverage.csv with category labels.

Reads:    working/{core,drivers,zelres*/code}/*.asm  +  matching *.LST
Writes:   functest/coverage.csv

Categories (Plan §1.2):
  D  untestable in isolation  (int / port_io / >=3 far calls / >=8 near calls)
  C  needs deep stubbing      (>=3 near calls AND not D)
  B  placeholder identity     (game_func_N / sub_N name AND not C/D)
  A  trivial regression       (size<=64 AND <=3 mem writes AND not B/C/D)
  E  pure thunk               (size<=8 AND no mem writes AND <=1 call AND not B)
"""
import csv
import json
import re
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / 'working'
OUT  = Path(__file__).parent / 'coverage.csv'
PROCEDURE_EVIDENCE = Path(__file__).parent / 'procedure_oracle_evidence.json'
PROJECT_ROOT = Path(__file__).resolve().parents[3]
WEB_TESTS = PROJECT_ROOT / '6_WebPort' / 'tests'

LST_PROC_RE = re.compile(
    r'^\s*([0-9A-Fa-f]{1,4})\s+.*?\b(\w+)\s+proc\s+(near|far)\b',
    re.IGNORECASE,
)
LST_ENDP_RE = re.compile(
    r'^\s*([0-9A-Fa-f]{1,4})\s+.*?\b(\w+)\s+endp\b',
    re.IGNORECASE,
)


def parse_lst_offsets(path: Path) -> dict[str, tuple[int, int]]:
    """Return {proc_name: (start_offset, end_offset)} from the LST."""
    starts: dict[str, int] = {}
    out: dict[str, tuple[int, int]] = {}
    for line in path.read_text(encoding='latin-1').splitlines():
        m = LST_PROC_RE.match(line)
        if m:
            off, name, _kind = m.groups()
            starts[name] = int(off, 16)
            continue
        m = LST_ENDP_RE.match(line)
        if m:
            off, name = m.groups()
            if name in starts:
                out[name] = (starts[name], int(off, 16))
                del starts[name]
    return out


def load_committed_lst_offsets() -> dict[tuple[str, str], tuple[int, int]]:
    """Use checked-in MASM offsets when local, ignored LST files are absent.

    The reconstructed `.LST` files are available in the MASM worktree but are
    intentionally not shipped in Git.  Keeping their last generated offsets in
    coverage.csv makes regeneration deterministic in a clean Linux checkout.
    """
    out: dict[tuple[str, str], tuple[int, int]] = {}
    if not OUT.exists():
        return out
    with OUT.open(encoding='utf8', newline='') as fp:
        for row in csv.DictReader(fp):
            if row.get('size_source') != 'lst' or not row.get('entry_addr'):
                continue
            start = int(row['entry_addr'], 16)
            out[(row['chunk'], row['name'])] = (
                start, start + int(row['size_bytes'])
            )
    return out


def body_features(body_lines: list[str]) -> dict:
    text = '\n'.join(body_lines)
    near_calls = re.findall(
        r'\bcall\s+(?!word\b)(?!dword\b)(\w+)', text, re.IGNORECASE
    )
    far_calls = re.findall(
        r'\bcall\s+(?:word|dword)\s+ptr\s+cs:', text, re.IGNORECASE
    )
    int_count = len(re.findall(r'\bint\s+\d+h?\b', text, re.IGNORECASE))
    port_io = len(re.findall(r'\b(?:in|out)\s+(?:al|ax|dx)\b', text, re.IGNORECASE))
    mem_writes = set()
    mem_writes.update(re.findall(
        r'mov\s+(?:byte|word|dword)?\s*ptr\s*(?:ds|cs|es|ss):?\s*\[([^\]]+)\]\s*,',
        text, re.IGNORECASE,
    ))
    mem_writes.update(re.findall(
        r'mov\s+(?:ds|cs|es|ss):(\w+)\s*,', text, re.IGNORECASE
    ))
    loops = len(re.findall(
        r'\b(?:loop|rep|repe|repne|repz|repnz)\b', text, re.IGNORECASE
    ))
    return dict(
        n_calls_out=len(near_calls),
        far_calls=len(far_calls),
        int_count=int_count,
        port_io=port_io,
        mem_writes=len(mem_writes),
        loops=loops,
        near_call_targets=near_calls,
        _body_lines=sum(1 for ln in body_lines if ln.strip()),
    )


def parse_asm_features(path: Path) -> dict[str, dict]:
    """Walk the .asm and return {proc_name: features} for every proc."""
    out: dict[str, dict] = {}
    # Sourcer occasionally emits a named PROC inside another named PROC.  Both
    # labels are callable release entry points (OPDMO's interrupt helpers are
    # the clearest example), so a single ``cur_name`` silently dropped the
    # inner procedure.  Keep every open procedure and feed each its complete
    # lexical body until the matching ENDP.
    active: list[tuple[str, list[str]]] = []
    for line in path.read_text(encoding='latin-1').splitlines():
        code = line.split(';', 1)[0]
        start = re.match(
            r'\s*(\w+)\s+proc\s+(near|far)\b', code, re.IGNORECASE
        )
        if start:
            for _name, body in active:
                body.append(code)
            active.append((start.group(1), []))
            continue

        end = re.match(r'\s*(\w+)\s+endp\b', code, re.IGNORECASE)
        if end:
            match_index = next(
                (index for index in range(len(active) - 1, -1, -1)
                 if active[index][0].lower() == end.group(1).lower()),
                None,
            )
            if match_index is not None:
                for index, (_name, body) in enumerate(active):
                    if index != match_index:
                        body.append(code)
                name, body = active.pop(match_index)
                out[name] = body_features(body)
            continue
        for _name, body in active:
            body.append(code)
    return out


def is_placeholder(name: str) -> bool:
    return bool(re.match(r'^(game_func_|sub_)\d+', name))


def categorize(r: dict) -> tuple[str, str]:
    if (r['int_count'] > 0 or r['port_io'] > 0
            or r['far_calls'] >= 3 or r['n_calls_out'] >= 8):
        return 'D', 'driver_or_dos'
    if r['n_calls_out'] >= 3:
        return 'C', 'deep_stubbing'
    if r['has_placeholder_name']:
        return 'B', 'placeholder_identity'
    if r['size_bytes'] <= 64 and r['mem_writes'] <= 3:
        return 'A', 'trivial_regression'
    if (r['size_bytes'] <= 8 and r['mem_writes'] == 0
            and r['n_calls_out'] <= 1):
        return 'E', 'pure_thunk'
    return 'C', 'mid_complex'


ORACLE_ROW_OVERRIDES = {
    # Opening/title integration oracles from opening_oracle_manifest.json.
    ('100OPDMO', 'run_opening_demo_main'): 'partial',
    ('100OPDMO', 'play_sprite_anim_script'): 'yes',
    ('100OPDMO', 'char_render_proc'): 'partial',
    ('100OPDMO', 'run_script_interpreter'): 'partial',
    ('100OPDMO', 'decompress_image'): 'yes',
    ('100OPDMO', 'decode_rle_to_es_di'): 'yes',
    ('100OPDMO', 'blit_rect_to_sprite_cache'): 'yes',
    ('100OPDMO', 'palette_lookup'): 'partial',
    ('100OPDMO', 'cycle_palette_colors'): 'partial',

    # Renamed 200FIGHT rows whose oracle manifests use semantic names.
    ('200FIGHT', 'hero_HP_subtract'): 'yes',
    ('200FIGHT', 'lookup_move_slot_family'): 'yes',
    ('200FIGHT', 'world_x_to_inner_screen_x'): 'yes',
    ('200FIGHT', 'world_x_to_screen_x'): 'yes',
    ('200FIGHT', 'world_x_to_screen_x_w25'): 'yes',
    ('200FIGHT', 'world_x_to_screen_x_w27'): 'yes',
    ('200FIGHT', 'inc_map_pos_helper'): 'yes',
    ('200FIGHT', 'dec_map_pos_helper'): 'yes',
    ('200FIGHT', 'check_north_movement'): 'partial',
    ('200FIGHT', 'check_south_movement'): 'partial',
    ('200FIGHT', 'is_entity_known_type_alt'): 'yes',

    # 106TOWN still has generic proc labels in coverage.csv; current town
    # oracles cover branch labels/subpaths within player_copy_buf plus helpers
    # reached by dispatch slots.
    ('106TOWN', 'player_copy_buf'): 'partial',
    ('106TOWN', 'player_process_loop'): 'partial',
    ('106TOWN', 'player_process_loop_2'): 'partial',
    ('106TOWN', 'run_town_main_loop'): 'partial',
    ('106TOWN', 'try_take_facing_item'): 'partial',
    ('106TOWN', 'render_dialog_text'): 'partial',
    ('106TOWN', 'draw_dialog_typewriter'): 'partial',
    ('106TOWN', 'wait_for_text_continue'): 'partial',
    ('106TOWN', 'try_talk_to_facing_npc'): 'partial',
    ('106TOWN', 'player_scan_loop'): 'yes',
    ('106TOWN', 'find_npc_at_bx_with_flag40'): 'partial',
    ('106TOWN', 'tick_npcs_then_pump'): 'partial',
    ('106TOWN', 'draw_and_pump_input'): 'partial',
    ('106TOWN', 'run_town_input_frame'): 'partial',
    ('106TOWN', 'mark_player_col_in_cursor_buf'): 'yes',
    ('106TOWN', 'render_town_actors'): 'yes',
    ('106TOWN', 'process_town_event_table'): 'yes',
    ('106TOWN', 'tick_npcs_dispatch'): 'yes',
    ('106TOWN', 'stamp_npcs_save_tiles'): 'yes',
    ('106TOWN', 'restore_tiles_under_npcs'): 'yes',
    ('106TOWN', 'try_door_transition'): 'partial',
    ('106TOWN', 'player_func_17'): 'partial',
    ('106TOWN', 'player_func_18'): 'partial',
    ('106TOWN', 'player_func_20'): 'partial',
    ('106TOWN', 'player_func_21'): 'partial',
    ('106TOWN', 'player_func_22'): 'partial',
    ('106TOWN', 'player_func_23'): 'partial',
    ('106TOWN', 'player_func_25'): 'partial',
    ('106TOWN', 'player_func_26'): 'partial',

    # 213BANKP arithmetic is covered through BANKPRO add/adc scenarios.
    ('213BANKP', 'bank_main'): 'partial',
}

# Coverage is intentionally tiered.  A row is only "direct" when a procedure
# oracle names it.  Loading a release overlay in the production VM is strong
# executable evidence, but is not mislabeled as a direct procedure proof.
RELEASE_VM_CHUNKS = {
    '200FIGHT', '201SELCT', '206GFMCA', '209CKPD',
    '210KINGP', '211OMOYP', '212ARMRP',
    '213BANKP', '214CHURP', '215DRUGP', '216INNAP', '217KENJP',
    '250ENDMO', '300ROKAD', '301EAI1', '302EAI2', '303EAI3',
    '304EAI4', '305EAI5', '306EAI6', '307EAI7', '308EAI8',
    '309CRAB', '310TAKO', '311TORI', '312ZELA', '313MEDA',
    '314LEGA', '315ZEL2', '316DRGN', '317AKMA', '318MAO1',
    '319MAO2',
}
INTEGRATION_CHUNKS = {
    '100OPDMO', '105GDMCA', '106TOWN', '111GTMCA',
    '207MOLE', '208YMPD', 'game', 'zeliad', 'gmmcga', 'stdply', 'stick',
}
BROWSER_SMOKE_CHUNKS = RELEASE_VM_CHUNKS | INTEGRATION_CHUNKS
NON_MCGA_CHUNKS = {
    '101GDEGA', '102GDCGA', '103GDHGC', '104GDTGA',
    '107GTEGA', '108GTCGA', '109GTHGC', '110GTTGA',
    '202GFEGA', '203GFCGA', '204GFHGC', '205GFTGA',
    'gmcga', 'gmega', 'gmhgc', 'gmtga',
}
DATA_ONLY_CHUNKS = {'stdply'}

EXACT_ORACLE_SOURCE = (
    '3_Assembly/masm/functest/proc_equivalence/'
    'test_mole_ympd_mcga_frame_oracle.py'
)
EXACT_ORACLE_PROCS = {
    '207MOLE': {
        'module_init', 'dispatch_decode_table_a', 'vga_pixel_unpack',
        'dispatch_decode_table_b', 'decode_5col_blit_loop',
        'decode_4bit_unpack',
    },
    '208YMPD': {
        'run_satono_bg_main', 'rle_decode_mountain_88x56',
        'render_mountains', 'pixel_expand_mcga',
        'rle_decode_ground_28', 'render_ground',
    },
    '209CKPD': {
        'bos_render_main', 'bos_frame_dispatch', 'vga_row_copy',
        'nibble_expand_8', 'decode_nibble_pair', 'sprite_rle_decode',
        'render_dispatch_layer2', 'nibble_expand_8_b',
        'decode_nibble_pair_alt',
    },
}
MODE_EXCLUDED_PROCS = {
    '207MOLE': {
        'mcga_pixel_unpack', 'mono_scan_loop', 'extract_bits',
        'write_dma_port_then_pad',
    },
    '208YMPD': {
        'ega_mtn_blit_88_rows', 'pixel_expand_cga', 'copy_28b_ega',
        'pixel_expand_cgaalt',
    },
}
GAP_TICKETS = {
    '100OPDMO': 184, '105GDMCA': 184,
    '106TOWN': 183, '111GTMCA': 183,
    'zeliad': 190, 'stick': 190,
}
PROCEDURE_GAP_TICKETS = {
    ('stick', name): 188 for name in {
        'decode_joystick_bits', 'poll_joystick_buttons',
        'calibrate_joystick', 'calc_joystick_deadzone',
    }
}


def load_procedure_evidence() -> dict[tuple[str, str], tuple[str, str]]:
    """Load reviewed procedure-to-fixture claims from the evidence manifest."""
    if not PROCEDURE_EVIDENCE.exists():
        return {}
    data = json.loads(PROCEDURE_EVIDENCE.read_text(encoding='utf8'))
    evidence: dict[tuple[str, str], tuple[str, str]] = {}
    for group in data.get('groups', []):
        chunk = group['chunk']
        source = group['source']
        scope = group.get('scope', 'procedure')
        for name in group['procedures']:
            key = (chunk, name)
            if key in evidence:
                raise ValueError(f'duplicate procedure evidence: {chunk}:{name}')
            evidence[key] = (source, scope)
    return evidence


def load_oracle_proc_labels() -> set[str]:
    labels: set[str] = set()
    if not WEB_TESTS.exists():
        return labels
    for manifest in WEB_TESTS.glob('*oracle_manifest.json'):
        try:
            data = json.loads(manifest.read_text(encoding='utf8'))
        except Exception:
            continue
        for scenario in data.get('scenarios', []):
            for key in ('proc', 'source', 'pipeline', 'name'):
                value = scenario.get(key)
                if isinstance(value, str):
                    labels.add(value)
    return labels


def oracle_coverage_for(row: dict, oracle_labels: set[str]) -> str:
    override = ORACLE_ROW_OVERRIDES.get((row['chunk'], row['name']))
    if override:
        return override
    if row['name'] in oracle_labels:
        return 'yes'
    return 'no'


def evidence_for(row: dict, procedure_evidence: dict) -> tuple[str, str, str, str]:
    reviewed = procedure_evidence.get((row['chunk'], row['name']))
    if reviewed:
        source, scope = reviewed
        return ('release-byte-procedure-oracle', scope, source, '')
    direct = row['covered_by_oracle']
    if direct == 'yes':
        return ('direct-procedure-oracle', 'procedure',
                '3_Assembly/masm/functest/INDEX.md', '')
    if row['name'] in EXACT_ORACLE_PROCS.get(row['chunk'], set()):
        source = (EXACT_ORACLE_SOURCE if row['chunk'] != '209CKPD' else
                  '3_Assembly/masm/functest/proc_equivalence/'
                  'test_ckpd_mcga_background_oracle.py')
        return ('exact-release-byte-oracle', 'procedure', source, '')
    if row['name'] in MODE_EXCLUDED_PROCS.get(row['chunk'], set()):
        return ('out-of-scope-non-mcga', 'target-scope',
                '3_Assembly/masm/functest/proc_equivalence/'
                'test_mole_ympd_mcga_frame_oracle.py', '')
    if row['chunk'] in DATA_ONLY_CHUNKS:
        return ('out-of-scope-data-only', 'target-scope',
                '3_Assembly/masm/working/drivers/stdply.asm', '')
    if row['chunk'] in RELEASE_VM_CHUNKS:
        return ('exact-release-byte-vm', 'chunk/integration',
                '6_WebPort/shell/test_continuous_playthrough_browser.mjs', '')
    if direct == 'partial' or row['chunk'] in INTEGRATION_CHUNKS:
        ticket = PROCEDURE_GAP_TICKETS.get(
            (row['chunk'], row['name']), GAP_TICKETS.get(row['chunk'], 182)
        )
        return ('integration-only', 'chunk/integration',
                '6_WebPort/engine/game/GAMEPLAY_ORACLE_COVERAGE.md',
                f'https://github.com/nolanvenhola/zeliard/issues/{ticket}')
    if row['chunk'] in NON_MCGA_CHUNKS:
        return ('out-of-scope-non-mcga', 'target-scope',
                '6_WebPort/README.md', '')
    return ('uncovered', 'procedure', '',
            'https://github.com/nolanvenhola/zeliard/issues/182')


def main() -> None:
    asm_files = sorted(
        list((ROOT / 'core').glob('*.asm')) +
        list((ROOT / 'drivers').glob('*.asm')) +
        list(ROOT.glob('zelres*/code/*.asm'))
    )
    print(f'Scanning {len(asm_files)} asm files...')
    oracle_labels = load_oracle_proc_labels()
    procedure_evidence = load_procedure_evidence()
    committed_offsets = load_committed_lst_offsets()

    asm_features: dict[Path, dict[str, dict]] = {}
    n_calls_in: dict[str, int] = defaultdict(int)
    for path in asm_files:
        feats = parse_asm_features(path)
        asm_features[path] = feats
        for f in feats.values():
            for tgt in f['near_call_targets']:
                n_calls_in[tgt] += 1

    rows: list[dict] = []
    no_lst: list[str] = []
    for path in asm_files:
        lst_path = path.with_suffix('.LST')
        offsets: dict[str, tuple[int, int]] = {}
        if lst_path.exists():
            offsets = parse_lst_offsets(lst_path)
        else:
            no_lst.append(path.name)
        feats = asm_features.get(path, {})
        for name, f in feats.items():
            if name not in offsets:
                cached = committed_offsets.get((path.stem, name))
                if cached:
                    offsets[name] = cached
            if name in offsets:
                start, end = offsets[name]
                size = end - start
                addr = f'0x{start:04X}'
                size_source = 'lst'
            else:
                size = 3 * max(1, f.get('_body_lines', 1))
                addr = ''
                size_source = 'estimated'
            row = {k: v for k, v in f.items()
                   if k not in ('near_call_targets', '_body_lines')}
            row.update(
                name=name,
                chunk=path.stem,
                entry_addr=addr,
                size_bytes=size,
                size_source=size_source,
                n_calls_in=n_calls_in.get(name, 0),
                has_placeholder_name=is_placeholder(name),
            )
            cat, reason = categorize(row)
            row['category'] = cat
            row['skip_reason'] = reason
            row['covered_by_oracle'] = oracle_coverage_for(row, oracle_labels)
            (row['evidence_tier'], row['evidence_scope'],
             row['evidence_source'], row['gap_ticket']) = evidence_for(
                 row, procedure_evidence
             )
            row['browser_smoke'] = (
                'yes' if row['chunk'] in BROWSER_SMOKE_CHUNKS else 'no'
            )
            rows.append(row)

    cols = [
        'name', 'chunk', 'entry_addr', 'size_bytes', 'size_source',
        'n_calls_in', 'n_calls_out', 'far_calls',
        'int_count', 'port_io', 'mem_writes', 'loops',
        'has_placeholder_name', 'category', 'skip_reason',
        'covered_by_oracle',
        'evidence_tier', 'evidence_scope', 'browser_smoke',
        'evidence_source', 'gap_ticket',
    ]
    OUT.parent.mkdir(parents=True, exist_ok=True)
    with OUT.open('w', newline='', encoding='utf8') as fp:
        w = csv.DictWriter(fp, fieldnames=cols, lineterminator='\n')
        w.writeheader()
        for r in rows:
            w.writerow({k: r.get(k, '') for k in cols})

    print(f'Wrote {len(rows)} rows to {OUT}')
    cats = defaultdict(int)
    oracle_counts = defaultdict(int)
    evidence_counts = defaultdict(int)
    placeholder_by_cat = defaultdict(int)
    for r in rows:
        cats[r['category']] += 1
        oracle_counts[r['covered_by_oracle']] += 1
        evidence_counts[r['evidence_tier']] += 1
        if r['has_placeholder_name']:
            placeholder_by_cat[r['category']] += 1
    print('Distribution:')
    for c in sorted(cats):
        marker = f'  ({placeholder_by_cat[c]} placeholders)' if placeholder_by_cat[c] else ''
        print(f'  {c}: {cats[c]:4d}{marker}')
    print('Oracle coverage:')
    for status in ('yes', 'partial', 'no'):
        if oracle_counts[status]:
            print(f'  {status}: {oracle_counts[status]:4d}')
    print('Evidence tiers:')
    for status in sorted(evidence_counts):
        print(f'  {status}: {evidence_counts[status]:4d}')
    if no_lst:
        print(f'\nNo LST for {len(no_lst)} asm files (skipped):')
        for n in no_lst[:5]:
            print(f'  {n}')
        if len(no_lst) > 5:
            print(f'  ... and {len(no_lst) - 5} more')


if __name__ == '__main__':
    main()
