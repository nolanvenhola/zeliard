#!/usr/bin/env python3
"""Dump per-town NPC names + dialog text from each town MDT.

Uses 4_Resources/MdtViewer/decoder.py's decode_town_mdt() to parse
each town MDT (stripping the 4-byte SAR length header first).

Output: working/TOWN_NPCS_DUMP.md — one section per town with
NPC roster + per-NPC dialog string.
"""
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(REPO / '4_Resources'))
from MdtViewer.decoder import decode_town_mdt  # noqa: E402

WORKING = Path(__file__).parent / 'working'


def main():
    towns = sorted((WORKING / 'zelres2' / 'data').glob('*M*P.mdt'))
    out = [
        '# Town NPC roster + dialog dump',
        '',
        'For each town MDT: town name, door count, NPC positions + their',
        'dialog text strings.  Generated via',
        '`python dump_town_npcs.py` (uses `4_Resources/MdtViewer/decoder.py`).',
        '',
        'Per-town MDT layout (after 4B SAR header strip):',
        '- +0x02: map width WORD (height fixed at 8)',
        '- +0x04: ptr to town name (pascal string at +3)',
        '- +0x09: ptr to doors array (3B each, FFFF-term)',
        '- +0x0D: ptr to NPC texts array (2B/entry, points to FF-term ASCII)',
        '- +0x0F: ptr to NPC array (8B each, FFFF-term)',
        '- +0x17: unpacked tile grid (map_width × 8, column-major)',
        '',
        '---',
        '',
    ]

    for p in towns:
        data = p.read_bytes()[4:]  # strip 4B SAR length header
        try:
            t = decode_town_mdt(data)
        except Exception as e:
            out.append(f'## {p.name}\n\n_decode failed: {e}_\n')
            continue

        out.append(f'## {p.name} — "{t.town_name}"')
        out.append('')
        out.append(f'- map width: {t.map_width} tiles (height fixed at 8)')
        out.append(f'- doors: {len(t.town_doors)}')
        out.append(f'- NPCs: {len(t.npcs)}')
        out.append(f'- NPC text strings: {len(t.npc_texts)}')
        out.append('')

        if t.town_doors:
            out.append('### Doors')
            out.append('| # | x | type | meaning |')
            out.append('|---|---:|---:|---|')
            for d in t.town_doors:
                meaning = {
                    0xFF: 'cavern entry (special)',
                    0x00: 'plain door',
                }.get(d.door_type, f'shop/building (type {d.door_type})')
                # types 0..7 = building program; 8+ = pf30 (boss-area door)
                if 0 < d.door_type < 8:
                    meaning = f'shop/NPC building #{d.door_type}'
                elif d.door_type >= 8 and d.door_type != 0xFF:
                    meaning = f'boss-area door (type {d.door_type})'
                out.append(f'| {d.label} | {d.x} | 0x{d.door_type:02X} | {meaning} |')
            out.append('')

        if t.npcs:
            out.append('### NPCs + dialog')
            out.append('| NPC | x | id | dialog |')
            out.append('|---|---:|---:|---|')
            for npc in t.npcs:
                tx = t.npc_texts.get(npc.npc_id, '<no text>')
                # Sanitize for markdown table: replace newlines with /, escape pipes
                tx = tx.replace('\r', '').replace('\n', ' / ').replace('|', '\\|')
                tx = tx.strip()
                if len(tx) > 160:
                    tx = tx[:160] + '...'
                out.append(f'| {npc.label} | {npc.x} | {npc.npc_id} | {tx!r} |')
            out.append('')

        # Any NPC text indexes not referenced by an NPC? List separately.
        referenced = {npc.npc_id for npc in t.npcs}
        extra = sorted(idx for idx in t.npc_texts if idx not in referenced)
        if extra:
            out.append('### Unreferenced text strings')
            out.append('(These exist in the text-pointer array but no NPC '
                       'record points to them — likely sign/cinematic text '
                       'or unused.)')
            out.append('')
            out.append('| idx | text |')
            out.append('|---:|---|')
            for idx in extra:
                tx = t.npc_texts[idx].replace('\r', '').replace('\n', ' / ').replace('|', '\\|').strip()
                if len(tx) > 160:
                    tx = tx[:160] + '...'
                out.append(f'| {idx} | {tx!r} |')
            out.append('')

    out_path = WORKING / 'TOWN_NPCS_DUMP.md'
    out_path.write_text('\n'.join(out), encoding='utf-8')
    print(f'Wrote {out_path}  ({len(towns)} towns)')


if __name__ == '__main__':
    main()
