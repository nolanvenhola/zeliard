#!/usr/bin/env python3
"""
survey_full_address_space.py

Wide-net audit of every memory access in the cleaned source.  For each
segment group (game_seg / enemy_seg / town_npc_seg), scans every .asm/.inc
file, counts genuine memory accesses (filtered by segment-aware rules from
analyze_stat_layout.py), and produces a bucketed report:

  - Per 256-byte page: total ref count, distinct addrs accessed, top 5 hot
    addresses, count of MISSING-EQU addresses (raw-hex with no symbolic name)
  - Top 30 hot addresses overall (by ref count)
  - Top 30 unnamed hot addresses (no EQU defined)

This is the wide-angle counterpart to analyze_stat_layout.py's per-byte view.
"""

import os, re, sys
from collections import defaultdict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from analyze_stat_layout import (
    SEGMENTS, ADDR_RE, NAME_RE, _file_segment, build_equ_map,
    classify_line,
)

ROOT = Path(__file__).parent / 'working'


def scan(segment):
    """Return (addr -> total_ref_count, addr -> first_sample_line) for the
    given segment group, applying the same CS-vs-DS rules as
    analyze_stat_layout.py.  Names are resolved via the EQU map."""
    equ_map = build_equ_map()
    counts = defaultdict(int)
    samples = {}

    for p in ROOT.rglob('*'):
        if p.suffix.lower() not in ('.asm', '.inc'):
            continue
        file_seg = _file_segment(str(p))
        try:
            txt = p.read_text(encoding='utf-8', errors='replace')
        except OSError:
            continue
        for ln, line in enumerate(txt.splitlines(), 1):
            no_c = re.sub(r';.*', '', line)
            stripped = no_c.strip().lower()
            if stripped.startswith(('db ', 'dw ', 'dd ', 'db\t', 'dw\t', 'dd\t')):
                continue

            # Resolve to address via literal hex first, then EQU symbol
            addr = None
            m = ADDR_RE.search(no_c)
            if m:
                ah = m.group('addr1') or m.group('addr2') or m.group('addr3')
                try:
                    addr = int(ah, 16)
                except (ValueError, TypeError):
                    addr = None
            if addr is None:
                m_name = NAME_RE.search(no_c)
                if m_name:
                    nm = m_name.group('name1') or m_name.group('name2')
                    if nm.lower() in (
                        'ax','bx','cx','dx','si','di','bp','sp',
                        'al','ah','bl','bh','cl','ch','dl','dh',
                        'es','cs','ds','ss','fs','gs',
                        'word','byte','dword','ptr',
                        'far','near','offset','seg','short',
                    ):
                        pass
                    elif nm in equ_map:
                        cands = sorted(equ_map[nm])
                        if cands:
                            addr = cands[0]
            if addr is None:
                continue

            # Segment-aware filtering: cs:/es:/ss: refs are scoped to the
            # file's own segment; ds: refs are shared across all chunks.
            is_ds_ref = bool(re.search(r'\bds:', no_c, re.I))
            if not is_ds_ref and file_seg != segment:
                continue
            counts[addr] += 1
            if addr not in samples:
                samples[addr] = (p.name, ln, line.strip()[:100])
    return counts, samples


def name_of(addr, equ_map_addr):
    """Return a list of EQU names for `addr`, or [] if unnamed."""
    names = sorted(equ_map_addr.get(addr, set()))
    return names


def main():
    print('Building EQU address map ...')
    equ_map = build_equ_map()
    addr_to_names = defaultdict(set)
    for nm, addrs in equ_map.items():
        for a in addrs:
            addr_to_names[a].add(nm)
    print(f'  resolved {len(equ_map)} symbol(s) at {len(addr_to_names)} '
          f'distinct address(es).')
    print()

    for segment in ['game_seg', 'enemy_seg', 'town_npc_seg']:
        print('=' * 78)
        print(f'SEGMENT: {segment}')
        print('=' * 78)
        counts, samples = scan(segment)
        if not counts:
            print('  (no refs)\n')
            continue

        total_refs = sum(counts.values())
        named = sum(1 for a in counts if a in addr_to_names)
        unnamed = len(counts) - named
        print(f'  Distinct addresses: {len(counts)}  (named={named}, '
              f'unnamed={unnamed})')
        print(f'  Total memory references: {total_refs}\n')

        # Bucketed by 256-byte page
        print(f'  Per-page summary:')
        print(f'  {"page":<8s}  {"addrs":>5s}  {"refs":>5s}  {"missing":>7s}  '
              f'top hits')
        page_data = defaultdict(lambda: {'addrs': 0, 'refs': 0,
                                          'missing': 0, 'hot': []})
        for addr, n in counts.items():
            page = addr & 0xFFFFFF00
            d = page_data[page]
            d['addrs'] += 1
            d['refs'] += n
            if addr not in addr_to_names:
                d['missing'] += 1
            d['hot'].append((n, addr))
        for page in sorted(page_data):
            d = page_data[page]
            top3 = sorted(d['hot'], reverse=True)[:3]
            top3_str = ', '.join(f'0x{a:04X}({n})' for n, a in top3)
            print(f'  0x{page:04X}    {d["addrs"]:5d}  {d["refs"]:5d}  '
                  f'{d["missing"]:7d}  {top3_str}')

        # Top hot addresses overall
        print(f'\n  TOP 20 hot addresses (any segment):')
        sorted_hot = sorted(counts.items(), key=lambda kv: -kv[1])[:20]
        for addr, n in sorted_hot:
            names = sorted(addr_to_names.get(addr, set()))
            name_str = ', '.join(names[:2]) + ('+' if len(names) > 2 else '')
            if not names:
                name_str = '(unnamed)'
            print(f'    0x{addr:04X}  {n:>4d} refs  {name_str[:50]:<50s}')

        # Top unnamed hot addresses
        print(f'\n  TOP 15 UNNAMED hot addresses (potential renames):')
        unnamed_hot = sorted(
            ((addr, n) for addr, n in counts.items()
             if addr not in addr_to_names),
            key=lambda kv: -kv[1]
        )[:15]
        for addr, n in unnamed_hot:
            fn, ln, line = samples[addr]
            print(f'    0x{addr:04X}  {n:>4d} refs  {fn}:{ln}  '
                  f'{line[:60]}')
        print()


if __name__ == '__main__':
    main()
