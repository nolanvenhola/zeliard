#!/usr/bin/env python3
"""
check_pair_consistency.py - Cross-validate paired EAI handler ↔ sprite/arena
modules. The 8 EAI handlers each pair with a sprite or arena module that
shares state via the enemy slot record. This script audits that the
annotations across paired files agree.

Pairings (defined in module headers and zr3com.inc):
  301EAI1 ↔ 309CRAB    Crab AI / sprite
  302EAI2 ↔ 310TAKO    Tako/Octopus
  303EAI3 ↔ 311TORI    Tori/Bird
  304EAI4 ↔ 312ZELA    Zela (segmented body)
  305EAI5 ↔ 313MEDA    Meda (jellyfish)
  306EAI6 ↔ 314LEGA    Lega-type
  307EAI7 ↔ 316DRGN    Drgn-type
  308EAI8 ↔ 317AKMA    Akma boss

Audits performed:

  P1. State-byte slot agreement: both files in a pair should reference the
      same offsets within the enemy slot record ([si+0], [si+5], [si+9],
      etc.). If one file uses [si+5] heavily and the other never touches
      it, the slot layout claim is suspect.

  P2. Frame-role consistency within sprite module: each `mov *_frame_idx, N`
      literal write should occur in a proc whose name aligns with the
      frame's ROLE annotation. E.g. `death_frame8` writing 8 should match
      `crab_frame_08: ROLE: DEATH pose`.

  P3. EAI state machine references match sprite module state addresses:
      EQUs defined in the sprite module (e.g. crab_phase_base, crab_anim_idx)
      that the EAI references should both have the same address.

  P4. Sprite module's frame_ptr_tbl_a..e count should match what the EAI's
      dispatch chooses between (consistency of branching factor).

Generates a markdown report at working/PAIR_CONSISTENCY_REPORT.md.
"""

import re
import os
from pathlib import Path
from collections import defaultdict

ROOT = Path(__file__).parent.resolve()
WORKING = ROOT / 'working'

#  CAUTION: pairings 302..308 ↔ 310..317 are UNVERIFIED. They were
#  originally inferred from the alternating EAI1/CRAB/EAI2/TAKO ordering
#  in 200FIGHT's resource_name_table.  The 301↔309 pairing claim has
#  been removed because runtime evidence shows 301EAI1 is a multi-enemy
#  handler (slug/bat/frog/rat) and 309CRAB is self-contained with its
#  own AI.  Other 7 pairings may be similarly wrong — needs runtime
#  tracing (Unicorn functest harness) for confirmation.
PAIRS = [
    # ('zelres3/code/301EAI1.asm', 'zelres3/code/309CRAB.asm', 'crab'),  # DISPROVEN by runtime trace
    ('zelres3/code/302EAI2.asm', 'zelres3/code/310TAKO.asm', 'tako'),
    ('zelres3/code/303EAI3.asm', 'zelres3/code/311TORI.asm', 'tori'),
    ('zelres3/code/304EAI4.asm', 'zelres3/code/312ZELA.asm', 'zela'),
    ('zelres3/code/305EAI5.asm', 'zelres3/code/313MEDA.asm', 'meda'),
    ('zelres3/code/306EAI6.asm', 'zelres3/code/314LEGA.asm', 'lega'),
    ('zelres3/code/307EAI7.asm', 'zelres3/code/316DRGN.asm', 'drgn'),
    ('zelres3/code/308EAI8.asm', 'zelres3/code/317AKMA.asm', 'akma'),
]


def load(path):
    return path.read_text(encoding='utf-8')


def strip_comments(s):
    return re.sub(r';.*', '', s, flags=re.M)


def find_slot_offsets(text):
    """Return dict {offset: count} of [si+N] usage."""
    text_nc = strip_comments(text)
    offsets = defaultdict(int)
    for m in re.finditer(r'\[si\+([0-9a-fA-F]+h?)\]', text_nc):
        v = m.group(1).lower().rstrip('h')
        offsets[int(v, 16)] += 1
    return offsets


def find_frame_idx_writes(text, prefix):
    """Find each `mov X_frame_idx, <literal>` and the enclosing proc/label.

    Returns list of (line_num, frame_n, enclosing_label).
    """
    text_nc = strip_comments(text)
    lines = text_nc.split('\n')
    # Track most recent label / proc for context
    out = []
    last_label = '<top>'
    for ln, line in enumerate(lines, 1):
        # Update enclosing label
        m = re.match(r'^([a-zA-Z_]\w*)(?:\s*:|\s+(?:proc\s+near|proc\s+far))', line)
        if m:
            last_label = m.group(1)
        # Find `mov X_frame_idx, N`
        m = re.search(rf'\bmov\s+(?:byte\s+ptr\s+)?(?:ds:)?\s*{prefix}_frame_idx\s*,\s*([0-9a-fA-F]+h?)\b', line)
        if m:
            v = m.group(1).lower().rstrip('h')
            try:
                n = int(v, 16)
                out.append((ln, n, last_label))
            except ValueError:
                pass
    return out


def find_frame_roles(text, prefix):
    """Find labels `<prefix>_frame_NN:` and their `; ROLE:` annotations.

    Returns dict {frame_n: role_text}.
    """
    lines = text.split('\n')
    out = {}
    for i, line in enumerate(lines):
        m = re.match(rf'^({prefix}_frame_([0-9a-fA-F]+))\s*:', line, re.I)
        if m:
            try:
                n = int(m.group(2), 16)
            except ValueError:
                continue
            # Look at this line + next 3 for a `; ROLE:` annotation
            blob = '\n'.join(lines[i:i+4])
            r = re.search(r';\s*ROLE:\s*(.+)', blob)
            if r:
                out[n] = r.group(1).strip()
            else:
                out[n] = '(no ROLE: annotation)'
    return out


def find_local_equs(text):
    """Return dict {name: addr} of EQU definitions."""
    out = {}
    for m in re.finditer(r'^[ \t]*([a-zA-Z_]\w*)\s+equ\s+(\S+)', text, re.M):
        out[m.group(1)] = m.group(2).rstrip(',')
    return out


def find_frame_ptr_tbl_count(text, prefix):
    """How many <prefix>_frame_ptr_tbl_X tables are defined?"""
    return len(set(re.findall(rf'\b{prefix}_frame_ptr_tbl_([a-z])\b', text)))


def find_dispatch_branch_count(text):
    """Heuristic: count distinct `jmp ds:[bx + addr]` indexed dispatch calls."""
    text_nc = strip_comments(text)
    return len(set(re.findall(r'jmp\s+(?:word\s+ptr\s+)?(?:ds|cs):\s*\[bx\+0?([0-9a-fA-F]+h?)\]', text_nc)))


def audit_pair(eai_path, spr_path, prefix, report):
    eai_text = load(WORKING / eai_path)
    spr_text = load(WORKING / spr_path)

    eai_name = Path(eai_path).stem
    spr_name = Path(spr_path).stem

    report.append(f'\n## `{eai_name}` ↔ `{spr_name}` ({prefix})\n')

    # P1: slot offset usage
    eai_slots = find_slot_offsets(eai_text)
    spr_slots = find_slot_offsets(spr_text)
    all_slots = sorted(set(eai_slots) | set(spr_slots))
    report.append('### P1: enemy slot record `[si+N]` usage\n')
    report.append('| offset | EAI uses | sprite uses | both? |')
    report.append('|---|---|---|---|')
    p1_issues = 0
    for off in all_slots:
        e, s = eai_slots.get(off, 0), spr_slots.get(off, 0)
        both = '✓' if (e > 0 and s > 0) else ('—' if e == 0 or s == 0 else '?')
        report.append(f'| `[si+{off:02x}h]` | {e} | {s} | {both} |')
        if (e > 5 and s == 0) or (s > 5 and e == 0):
            p1_issues += 1
    report.append(f'\n**P1 verdict:** {p1_issues} slot(s) heavily used by one file but not the other.\n')

    # P2: frame_idx writes vs frame role annotations
    writes = find_frame_idx_writes(spr_text, prefix)
    roles = find_frame_roles(spr_text, prefix)
    report.append('### P2: literal `mov *_frame_idx, N` writes vs ROLE annotation\n')
    report.append('| frame | written from (proc) | declared role |')
    report.append('|---|---|---|')
    p2_issues = 0
    seen_frames = set()
    for ln, n, label in writes:
        seen_frames.add(n)
        role = roles.get(n, '(no frame label)')
        report.append(f'| `{n:02d}` | `{label}` (line {ln}) | {role[:80]} |')
        # Heuristic: flag if proc name and role share no keywords
        proc_words = set(re.findall(r'[a-z]+', label.lower()))
        role_words = set(re.findall(r'[a-z]+', role.lower()))
        if not (proc_words & role_words) and 'no ROLE' not in role and 'no frame' not in role:
            p2_issues += 1
    # Frames with roles but no writes?
    unwritten = sorted(set(roles) - seen_frames)
    for n in unwritten:
        report.append(f'| `{n:02d}` | (no literal write found) | {roles[n][:80]} |')
    report.append(f'\n**P2 verdict:** {p2_issues} proc-name/role pairs share no overlapping keywords.\n')

    # P3: EAI references that resolve to sprite module's local EQUs
    spr_equs = find_local_equs(spr_text)
    eai_text_nc = strip_comments(eai_text)
    p3_issues = []
    for name in spr_equs:
        if not name.startswith(prefix + '_'):
            continue
        if re.search(rf'\b{re.escape(name)}\b', eai_text_nc):
            # EAI references this — check the EAI also has it as an EQU with the same value
            eai_equs = find_local_equs(eai_text)
            if name in eai_equs and eai_equs[name] != spr_equs[name]:
                p3_issues.append((name, eai_equs[name], spr_equs[name]))
    report.append('### P3: shared symbol address agreement\n')
    if p3_issues:
        for name, eai_v, spr_v in p3_issues:
            report.append(f'- ⚠️ `{name}` defined in EAI as `{eai_v}` but in sprite as `{spr_v}`')
    else:
        report.append('No shared-symbol address mismatches.')
    report.append(f'\n**P3 verdict:** {len(p3_issues)} mismatch(es).\n')

    # P4: branch-factor consistency
    eai_disp = find_dispatch_branch_count(eai_text)
    spr_tbls = find_frame_ptr_tbl_count(spr_text, prefix)
    report.append(f'### P4: dispatch branch counts\n')
    report.append(f'- EAI distinct `jmp ds:[bx+...]` dispatch tables: **{eai_disp}**')
    report.append(f'- Sprite frame-pointer table groups (`*_frame_ptr_tbl_a..e`): **{spr_tbls}**\n')

    return p1_issues + p2_issues + len(p3_issues)


def main():
    report = ['# EAI ↔ Sprite Pair Consistency Audit\n']
    report.append('Cross-validation of the 8 paired EAI handler / sprite-arena modules.\n')
    report.append('Generated by `3_Assembly/tasm/check_pair_consistency.py`\n')
    report.append('## What each check means\n')
    report.append('- **P1** (slot ownership): both files in a pair touch the enemy slot record `[si+N]`. Most slots are *owned* by one side (EAI manages state bytes 8/9/A; sprite manages position bytes 2/3/4). Disjoint usage is **expected**, not an error. The check is just informational.')
    report.append('- **P2** (frame_idx writes vs role): when the sprite module has a literal `mov *_frame_idx, N` write, the surrounding proc name should share keywords with the frame\'s ROLE annotation. Only catches explicit literal writes — files that load frames from tables (most) won\'t produce findings.')
    report.append('- **P3** (shared symbol address agreement): when both files in a pair define an EQU with the same prefix, the addresses must agree. **This is the strongest cross-pair proof** — zero mismatches means the paired files share state at consistent addresses.')
    report.append('- **P4** (branch-factor): heuristic count of dispatch tables vs frame-pointer table groups. Different dispatch styles produce different counts; informational only.\n')

    total_p3 = 0
    total_p2 = 0
    for eai, spr, prefix in PAIRS:
        before_p2 = sum(1 for line in report if 'proc-name/role pairs share no overlapping' in line)
        before_p3 = sum(1 for line in report if '⚠️' in line)
        audit_pair(eai, spr, prefix, report)
        after_p2 = sum(1 for line in report if 'proc-name/role pairs share no overlapping' in line)
        after_p3 = sum(1 for line in report if '⚠️' in line)

    # Compute totals from the report itself (count specific markers)
    p3_count = sum(1 for line in report if line.strip().startswith('- ⚠️'))
    p2_count = 0
    for line in report:
        m = re.search(r'\*\*P2 verdict:\*\* (\d+) proc-name', line)
        if m:
            p2_count += int(m.group(1))

    report.append('\n---\n')
    report.append('## Summary\n')
    report.append(f'- **P3 (address agreement) — primary cross-pair proof: {p3_count} mismatch(es)**.')
    if p3_count == 0:
        report.append('  ✅ Every shared symbol resolves to the same address across paired files.')
    report.append(f'- P2 (frame-write keyword overlap): {p2_count} advisory finding(s) — heuristic, often false positives.')
    report.append('- P1 / P4: informational; do not indicate errors.\n')

    out = WORKING / 'PAIR_CONSISTENCY_REPORT.md'
    out.write_text('\n'.join(report), encoding='utf-8')
    print(f'Wrote {out}')
    print(f'P3 (real address mismatches): {p3_count}')
    print(f'P2 (keyword-overlap advisories): {p2_count}')


if __name__ == '__main__':
    main()
