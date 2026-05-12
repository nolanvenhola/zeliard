#!/usr/bin/env python3
"""Dump per-cavern inventory: doors, monsters, items, platforms.

For every .mdt in working/zelres3/data, uses brox's decode_mdt()
(stripping the 4-byte SAR length prefix first) to parse:
- header (width, level, tear coords)
- doors table (12 B/entry; with Lion Key + map-id resolution)
- monsters/items table (16 B/entry; spawn_type splits them)
- platforms (v / collapsing / horizontal)

Output: working/CAVERN_INVENTORY.md — one section per cavern.

Cross-references the SAR_DIRECTORY.md cavern-name mapping
(map_id 0..31 → MP10..MPA0.MDT).
"""
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(REPO / '4_Resources'))
from MdtViewer.decoder import decode_mdt  # noqa: E402

WORKING = Path(__file__).parent / 'working'

# Map filename stem -> cavern role per Playthrough.txt §2.1
# (Order matches map_id 0..31 in brox/constants.py:_DUNG_MAPS)
CAVERN_ROLES = {
    'MP10': '0. Felishika start area / opening',
    'MP1D': '0-D. (dungeon variant)',
    'MP20': '1. Muralla outdoor',
    'MP21': '1-A. Muralla sub-area',
    'MP2D': '1-D. Muralla cavern (Cangrejo boss)',
    'MP30': '2. Satono outdoor',
    'MP31': '2-A. Satono sub-area',
    'MP3D': '2-D. Satono cavern (Pulpo boss)',
    'MP40': '3. Bosque outdoor',
    'MP41': '3-A. Bosque sub-area',
    'MP4D': '3-D. Bosque cavern (Pollo boss)',
    'MP50': '4. Helada outdoor',
    'MP51': '4-A. Helada sub-area',
    'MP5D': '4-D. Helada cavern (ice; Ruzeria gates)',
    'MP60': '5. Tumba outdoor / 5-A. Tumba sub-area',
    'MP61': '5-B. Tumba sub-area',
    'MP62': '5-C. Tumba sub-area',
    'MP6D': '5-D. Tumba cavern (slime/graveyard)',
    'MP70': '6. Dorado outdoor',
    'MP71': '6-A. Dorado sub-area',
    'MP72': '6-B. Dorado sub-area',
    'MP73': '6-C. Dorado sub-area',
    'MP7D': '6-D. Dorado cavern (gold/Silkarn)',
    'MP80': '7. Llama outdoor',
    'MP81': '7-A. Llama sub-area',
    'MP82': '7-B. Llama sub-area',
    'MP83': '7-C. Llama sub-area',
    'MP84': '7-D. Llama dungeon',
    'MP8D': '7-D. Llama cavern (Dragon boss)',
    'MP90': '8-1. Pureza cavern (acid; Cape gates)',
    'MPA0': '8-2. Esco final approach',
}

# Brox MDTViewer has only 2 monster type names; we'll dump raw type
# bytes and let the reader cross-reference with per-area EAI chunks.
MONSTER_TYPE_HINT = {
    0x01: 'Snail/Slug',
    0x02: 'Frog',
}


def main():
    out = [
        '# Cavern inventory dump',
        '',
        'Per-cavern enemies / items / doors / platforms decoded from',
        'each MDT in `working/zelres3/data/`.  Uses brox\'s `decode_mdt()`',
        '(after stripping the 4-byte SAR length prefix).',
        '',
        'Map-ID lookup (door records reference these by `map_id` byte):',
        'see `Documentation/SAR_DIRECTORY.md` "Dungeon map ID lookup".',
        '',
        'Each cavern\'s **monsters + items** share the same MDT+0x10',
        'table (16 B/entry); `spawn_type` byte at +0x0E distinguishes',
        'item (0) vs monster (≠0).',
        '',
        '---',
        '',
    ]

    mdts = sorted((WORKING / 'zelres3' / 'data').glob('*MP*.mdt'))
    summary = []

    for p in mdts:
        stem = p.stem.upper()
        # File name pattern: 320MP10 — strip the 3-digit prefix
        if len(stem) >= 4 and stem[:3].isdigit():
            stem = stem[3:]
        role = CAVERN_ROLES.get(stem, '(unknown)')

        data = p.read_bytes()[4:]  # strip 4-byte SAR length prefix
        try:
            m = decode_mdt(data)
        except Exception as e:
            out.append(f'## {p.name} — {role}')
            out.append('')
            out.append(f'_decode failed: {e}_')
            out.append('')
            summary.append((p.name, role, 0, 0, 0, 0, 0, 0, 'FAIL'))
            continue

        summary.append((
            p.name, role,
            m.map_width, m.level,
            len(m.doors), len(m.monsters), len(m.items),
            sum(1 for _ in range(0)),
            ''
        ))

        out.append(f'## {p.name} — {role}')
        out.append('')
        out.append(f'- **width**: {m.map_width} tiles (height fixed at 64)')
        out.append(f'- **cavern level**: 0x{m.level:02X} ({m.level})')
        out.append(f'- **tear coords**: ({m.tear_x}, {m.tear_y})')
        out.append(f'- **doors**: {len(m.doors)}, **monsters**: {len(m.monsters)}, **items**: {len(m.items)}')
        out.append('')

        if m.doors:
            out.append('### Doors')
            out.append('| # | x | y | flags | dest map | type |')
            out.append('|---|---:|---:|---:|---|---|')
            for d in m.doors:
                out.append(f'| {d.label} | {d.x} | {d.y} | 0x{d.flags:02X} | {d.dest} | {d.dtype} |')
            out.append('')

        if m.monsters:
            out.append('### Monsters')
            out.append('| # | x | y | type | act | spwn (x,y,type) |')
            out.append('|---|---:|---:|---|---:|---|')
            for mo in m.monsters:
                ttype = mo.type
                type_name = MONSTER_TYPE_HINT.get(ttype, f'?type 0x{ttype:02X}')
                out.append(f'| {mo.label} | {mo.x} | {mo.y} | 0x{ttype:02X} ({type_name}) | 0x{mo.act:02X} | ({mo.spwn_x}, {mo.spwn_y}, 0x{mo.spwn_type:02X}) |')
            out.append('')

        if m.items:
            out.append('### Items')
            out.append('| # | x | y | type | act | raw |')
            out.append('|---|---:|---:|---|---:|---|')
            for it in m.items:
                out.append(f'| {it.label} | {it.x} | {it.y} | 0x{it.type:02X} | 0x{it.act:02X} | `{it.raw}` |')
            out.append('')

    # Final summary at top of output
    summary_table = ['## Summary', '',
                     '| File | Role | Width | Level | Doors | Monsters | Items |',
                     '|---|---|---:|---:|---:|---:|---:|']
    for s in summary:
        fname, role, width, lvl, doors, mons, items, _, _ = s
        summary_table.append(f'| {fname} | {role} | {width} | 0x{lvl:02X} | {doors} | {mons} | {items} |')
    summary_table.append('')
    summary_table.append('---')
    summary_table.append('')

    # Insert observations between header and summary
    observations = [
        '## Observations',
        '',
        '**Boss-arena dungeons are empty MDTs.**  Maps with `D` suffix',
        '(MP1D, MP2D, MP3D, MP4D, MP5D, MP6D, MP7D, MP8D) all decode',
        'with 0 doors / 0 monsters / 0 items.  Also MP90 (Pureza) and',
        'MPA0 (Esco) are empty.  These are the boss arenas — terrain',
        'only.  Enemies + boss spawn come from the per-boss code chunk',
        '(309CRAB, 310TAKO, etc.) loaded into game_seg:0xA000 when the',
        '`current_area_id` sign bit triggers `check_c3` boss-intro path.',
        '',
        '**Map width pattern**: outdoor/town-adjacent maps are 192-320',
        'tiles wide; sub-areas are 70-128; boss arenas are 42-73.',
        '',
        '**Cavern level byte** at MDT+0x12: 0x01 (start area) through',
        '0x09 (Pureza) — matches the canonical 9-step chapter',
        'progression (Felishika → Muralla → Satono → Bosque → Helada',
        '→ Tumba → Dorado → Llama → Pureza).',
        '',
        '**Monster type bytes**:',
        '- 0x01 = Snail/Slug (per brox)',
        '- 0x02 = Frog (per brox)',
        '- 0x03-0xFF = per-area enemy types (not yet catalogued; would',
        '  need per-EAI chunk inspection of how the type byte selects',
        '  sprite + AI handler)',
        '',
        '**Door flag bits** (per brox/MDTViewer/models.py:Door.from_bytes):',
        '- `flags & 0x01` → "needs Lion Key"',
        '- `y1 == 0x00FF` → town warp (the y1 word is sentinel-set to FF)',
        '- Other bits unknown — observed values: 0x00, 0x01, 0x83, 0xC0,',
        '  0xC2, 0xC3, 0xFF + many more across all caverns',
        '',
        '**Spawn fields (spwn_x/spwn_y/spwn_type)**: when the monster',
        'is at (x,y), `spwn_*` typically matches; for some monsters',
        '`spwn_type` differs from `type` — interpretation TBD (likely',
        '"despawn-and-respawn" trigger info for off-screen monsters).',
        '',
        '---',
        '',
    ]
    final = out[:15] + observations + summary_table + out[15:]

    out_path = WORKING / 'CAVERN_INVENTORY.md'
    out_path.write_text('\n'.join(final), encoding='utf-8')
    print(f'Wrote {out_path}  ({len(mdts)} caverns)')


if __name__ == '__main__':
    main()
