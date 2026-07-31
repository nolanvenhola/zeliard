#!/usr/bin/env python3
"""classify.py — feature-extract every `proc near` in the cleaned tree
and emit functest/coverage.csv with category labels.

Reads:    working/zelres{1,2,3}/code/*.asm  +  matching *.LST
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
PROJECT_ROOT = Path(__file__).resolve().parents[3]
WEB_TESTS = PROJECT_ROOT / '6_WebPort' / 'tests'

LST_PROC_RE = re.compile(
    r'^\s*\d+\s+([0-9A-Fa-f]{1,4})\s+.*?\b(\w+)\s+proc\s+(near|far)\b',
    re.IGNORECASE,
)
LST_ENDP_RE = re.compile(
    r'^\s*\d+\s+([0-9A-Fa-f]{1,4})\s+.*?\b(\w+)\s+endp\b',
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
    cur_name: str | None = None
    cur_body: list[str] = []
    for line in path.read_text(encoding='latin-1').splitlines():
        code = line.split(';', 1)[0]
        if cur_name is None:
            m = re.match(r'\s*(\w+)\s+proc\s+(near|far)\b', code, re.IGNORECASE)
            if m:
                cur_name = m.group(1)
                cur_body = []
            continue
        m = re.match(r'\s*(\w+)\s+endp\b', code, re.IGNORECASE)
        if m and cur_name == m.group(1):
            out[cur_name] = body_features(cur_body)
            cur_name = None
            cur_body = []
            continue
        cur_body.append(code)
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


def main() -> None:
    asm_files = sorted(ROOT.rglob('zelres*/code/*.asm'))
    print(f'Scanning {len(asm_files)} asm files...')
    oracle_labels = load_oracle_proc_labels()

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
            rows.append(row)

    cols = [
        'name', 'chunk', 'entry_addr', 'size_bytes', 'size_source',
        'n_calls_in', 'n_calls_out', 'far_calls',
        'int_count', 'port_io', 'mem_writes', 'loops',
        'has_placeholder_name', 'category', 'skip_reason',
        'covered_by_oracle',
    ]
    OUT.parent.mkdir(parents=True, exist_ok=True)
    with OUT.open('w', newline='', encoding='utf8') as fp:
        w = csv.DictWriter(fp, fieldnames=cols)
        w.writeheader()
        for r in rows:
            w.writerow({k: r.get(k, '') for k in cols})

    print(f'Wrote {len(rows)} rows to {OUT}')
    cats = defaultdict(int)
    oracle_counts = defaultdict(int)
    placeholder_by_cat = defaultdict(int)
    for r in rows:
        cats[r['category']] += 1
        oracle_counts[r['covered_by_oracle']] += 1
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
    if no_lst:
        print(f'\nNo LST for {len(no_lst)} asm files (skipped):')
        for n in no_lst[:5]:
            print(f'  {n}')
        if len(no_lst) > 5:
            print(f'  ... and {len(no_lst) - 5} more')


if __name__ == '__main__':
    main()
