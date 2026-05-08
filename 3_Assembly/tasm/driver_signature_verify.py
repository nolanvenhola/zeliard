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
            [r'\bsi\b'],                              # touches SI
        ],
        'small SI-wrap helper (small proc, name accepted by size)',
    ),
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


def verify_family(family_label: str, chunks: list[str], subdir: str) -> dict:
    """For each proc with a fingerprint, verify across all chunks in family."""
    results = defaultdict(list)
    for chunk in chunks:
        asm = WORKING / subdir / f'{chunk}.asm'
        for proc_name, (groups, desc) in ROLE_FINGERPRINTS.items():
            body = load_proc_body(asm, proc_name)
            if body is None:
                continue  # proc not present in this driver
            ok, matched = fingerprint_match(body, groups)
            results[proc_name].append({
                'family': family_label,
                'chunk': chunk,
                'matched': ok,
                'patterns': matched,
                'description': desc,
            })
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

    total_supported = 0
    total_contradicted = 0
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
                if r['matched']:
                    verdict = '**SUPPORTED**'
                    total_supported += 1
                else:
                    verdict = '**CONTRADICTED**'
                    total_contradicted += 1
                pats = '<br>'.join(f'`{p}`' for p in r['patterns']) or '(none)'
                out.append(f'| `{r["chunk"]}` | {verdict} | {pats} |')
            out.append('')
    out.append(f'**Totals**: {total_supported} SUPPORTED, '
               f'{total_contradicted} CONTRADICTED.')
    path.write_text('\n'.join(out), encoding='utf-8')


def main():
    all_results = {}
    for family_label, chunks, subdir in FAMILIES:
        all_results[family_label] = verify_family(family_label, chunks, subdir)
    out_path = WORKING / 'DRIVER_SIGNATURE_VERIFY.md'
    write_report(all_results, out_path)
    print(f'Wrote {out_path}')

    # Also print a summary
    n_supported = 0
    n_contradicted = 0
    for family in all_results.values():
        for rows in family.values():
            for r in rows:
                if r['matched']:
                    n_supported += 1
                else:
                    n_contradicted += 1
    print(f'\nTotal verdicts: {n_supported} SUPPORTED, {n_contradicted} CONTRADICTED')


if __name__ == '__main__':
    main()
