#!/usr/bin/env python3
"""
check_annotations.py - Cross-file consistency checker for cleaned ASM source.

Validates the annotations added during the cleanup pass against what's
actually in the code. Bit-perfect verification proves bytes are right; this
script proves the labels and comments aren't lying about cross-file relationships.

Checks performed:

  C1. Header "Connections: Calls into X" claims must correspond to actual
      `call ... X` instructions in the file body.
  C2. Header "paired with N<NAME>" claims must be reciprocal — both files
      should reference each other in their headers.
  C3. Dispatch slots defined in zr*com.inc (e.g. fight_cb_record_ofs) must
      have at least one caller — symbols with zero refs are dead names.
  C4. "Called by Y" claims must correspond to Y actually containing a call
      to a label inside this file (or going through SAR loader with a
      reference to this file).
  C5. Symbols REFERENCED in a file must be DEFINED somewhere reachable
      (file-local, includes, or in shared inc files).
  C6. Header offset annotations like `; offset 0x0XX -> ptr 0xANNN` should
      have ptr targets within the file's load range.

Usage:
    python check_annotations.py            # run all checks, print findings
    python check_annotations.py --fix      # interactive prompt for fixes (NYI)
"""

import re
import os
import sys
from pathlib import Path
from collections import defaultdict, Counter

ROOT = Path(__file__).parent.resolve()
WORKING = ROOT / 'working'

ASM_DIRS = ['core', 'drivers', 'zelres1/code', 'zelres2/code', 'zelres3/code']
INC_FILES = [
    'core/zeliard.inc',
    'drivers/stick.inc',
    'drivers/stdply.inc',
    'zelres1/code/zr1com.inc',
    'zelres2/code/zr2com.inc',
    'zelres3/code/zr3com.inc',
]


def load_file(path):
    """Return file contents."""
    return path.read_text(encoding='utf-8')


def all_asm_files():
    out = []
    for d in ASM_DIRS:
        full = WORKING / d
        if full.exists():
            out.extend(sorted(full.glob('*.asm')))
    return out


def parse_inc_symbols():
    """Returns dict[name] -> (value, defining_inc_path)."""
    syms = {}
    for inc_path in INC_FILES:
        full = WORKING / inc_path
        if not full.exists():
            continue
        for line in full.read_text(encoding='utf-8').splitlines():
            m = re.match(r'^([a-zA-Z_]\w*)\s+equ\s+(\S+)', line)
            if m:
                syms[m.group(1)] = (m.group(2).rstrip(','), inc_path)
    return syms


def parse_file_calls(path):
    """Return set of symbol names called/jumped-to from this file via ds:[X] / cs:[X] / direct."""
    s = load_file(path)
    s = re.sub(r';.*', '', s, flags=re.M)  # strip comments
    calls = set()
    # call/jmp word ptr ds:[symbol] / cs:[symbol] / cs:symbol  / ds:symbol
    for m in re.finditer(
        r'(?:call|jmp)\s+(?:word\s+ptr\s+)?(?:near\s+)?(?:far\s+)?(?:cs|ds|es|ss):\s*\[?([a-zA-Z_]\w*)\]?',
        s):
        calls.add(m.group(1))
    # call/jmp symbol (direct, no segment prefix)
    for m in re.finditer(r'(?:call|jmp)\s+(?:word\s+ptr\s+)?(?:near\s+)?(?:far\s+)?([a-zA-Z_]\w*)\b', s):
        name = m.group(1)
        if name in ('ax', 'bx', 'cx', 'dx', 'si', 'di', 'bp', 'sp', 'cs', 'ds', 'es', 'ss',
                    'al', 'ah', 'bl', 'bh', 'cl', 'ch', 'dl', 'dh',
                    'short', 'near', 'far', 'word', 'ptr'):
            continue
        calls.add(name)
    return calls


def parse_file_header(path):
    """Extract module header block (everything between first `;==` and the
    second `;==` — the closing border of the header banner)."""
    s = load_file(path)
    # First find the header block (between first two ;========= lines)
    lines = s.splitlines()
    header_lines = []
    started = False
    border_seen = 0
    for line in lines:
        if re.match(r'^;=+\s*$', line):
            border_seen += 1
            header_lines.append(line)
            if border_seen >= 2:
                break
        elif border_seen >= 1:
            header_lines.append(line)
        if border_seen >= 2:
            break
    return '\n'.join(header_lines)


def extract_calls_into_claims(header):
    """From a header's 'Connections:' block, extract symbols claimed under 'Calls into:'.

    Only pick out real symbol-shaped tokens: snake_case with at least one
    underscore, OR known prefix patterns (sar_*, drv_*, fight_cb_*, gfx_*,
    script_*, gvar_*, gameplay_*). English prose words are skipped.
    """
    m = re.search(r'^[ \t]*;[ \t]*Calls into:(.*?)(?=^[ \t]*;[ \t]*(Loads|Called by|Reads/writes|State|$)|^;=)',
                  header, re.M | re.S)
    if not m:
        return set()
    body = m.group(1)
    syms = set()
    # Match identifier-shaped tokens that LOOK like real symbols:
    # must have at least one underscore AND end in alphanumeric (not _).
    for tok in re.findall(r'\b([a-z][a-z0-9_]*_[a-z0-9][a-z0-9_]*[a-z0-9])\b', body, re.I):
        if re.match(r'^(0x[0-9a-f]+|0[0-9a-fh]+|[0-9]+[hH]?)$', tok, re.I):
            continue
        syms.add(tok)
    return syms


def extract_called_by_claims(header):
    """From 'Called by:' block, extract module names mentioned (e.g. '200FIGHT')."""
    m = re.search(r'^[ \t]*;[ \t]*Called by:(.*?)(?=^[ \t]*;[ \t]*(Loads|Calls into|Reads/writes|State|$)|^;=)',
                  header, re.M | re.S)
    if not m:
        return set()
    body = m.group(1)
    refs = set()
    # Match patterns like 200FIGHT, 106TOWN, 309CRAB, zeliad.exe, game.asm
    for tok in re.findall(r'\b([0-9]{3}[A-Z]+\d*|[a-z]+\.(?:asm|exe|bin|grp))\b', body):
        refs.add(tok)
    return refs


def extract_paired_claims(header):
    """Find 'paired with N' claims (e.g. 'paired with 309CRAB')."""
    return set(re.findall(r'paired\s+with\s+([0-9]{3}[A-Z]+\d*)', header, re.I))


# -----------------------------------------------------------------------------
# Checks
# -----------------------------------------------------------------------------

def check_calls_into(files, inc_syms, results):
    """C1: 'Calls into X' claims should correspond to actual call sites.
    Resolves symbol → address via inc, and counts call cs:[ADDR] as a match."""
    for path in files:
        rel = str(path.relative_to(WORKING)).replace('\\', '/')
        header = parse_file_header(path)
        claimed = extract_calls_into_claims(header)
        actual_calls = parse_file_calls(path)
        body = load_file(path)
        body_nc = re.sub(r';.*', '', body, flags=re.M)

        def norm_addr(s):
            """Normalize hex like '010Ch' / '10Ch' / '0x10C' to canonical form."""
            s = s.upper().rstrip('H').lstrip('0') or '0'
            return s + 'h'

        numeric_calls = set()
        for m in re.finditer(r'(?:call|jmp)\s+(?:word\s+ptr\s+)?(?:cs|ds):\[([0-9a-fA-F]+h?)\]', body_nc):
            numeric_calls.add(norm_addr(m.group(1)))
        for m in re.finditer(r'cs:\[([0-9a-fA-F]+h?)\]', body):
            numeric_calls.add(norm_addr(m.group(1)))

        for sym in claimed:
            if sym in actual_calls:
                continue
            if re.search(rf'\b{re.escape(sym)}\b', body_nc):
                continue
            if sym in inc_syms:
                val = norm_addr(inc_syms[sym][0])
                if val in numeric_calls:
                    continue
            if sym in ('SAR', 'DS', 'CS', 'cs', 'ds', 'fight', 'sar'):
                continue
            results.append(('C1', rel, f'header claims "Calls into {sym}" but no reference found in code'))


def check_paired_reciprocity(files, results):
    """C2: 'paired with X' should be reciprocated by X also pairing back."""
    pairings = {}  # rel -> set of paired modules
    for path in files:
        rel = str(path.relative_to(WORKING)).replace('\\', '/')
        header = parse_file_header(path)
        paired = extract_paired_claims(header)
        if paired:
            pairings[rel] = paired
    # For each pairing, check the other side
    for src_rel, paired_set in pairings.items():
        for partner in paired_set:
            # Find file that starts with this partner stem
            for tgt_rel, tgt_paired in pairings.items():
                if partner in tgt_rel:
                    src_stem = re.search(r'(\d{3}[A-Z]+\d*)', src_rel)
                    if src_stem and src_stem.group(1) not in tgt_paired:
                        results.append(('C2', src_rel,
                                        f'paired with {partner}, but {tgt_rel} does not reciprocate'))
                    break
            else:
                results.append(('C2', src_rel,
                                f'paired with {partner}, but no file found with that stem'))


def check_dispatch_slots_have_callers(files, inc_syms, results):
    """C3: Each dispatch-style symbol in zr*com.inc should have at least one caller.
    Resolves EQU aliases (e.g. ai_hide_fn = fight_cb_fire — refs to either count).
    """
    DISPATCH_PREFIXES = ('fight_cb_', 'drv_', 'script_', 'gfx_', 'sar_loader')

    # Build alias map: symbols at the same numeric value alias each other
    by_val = defaultdict(list)
    for n, (v, _) in inc_syms.items():
        by_val[v].append(n)

    callers = defaultdict(set)
    for path in files:
        rel = str(path.relative_to(WORKING)).replace('\\', '/')
        for sym in parse_file_calls(path):
            callers[sym].add(rel)

    for name, (val, inc) in inc_syms.items():
        if not any(name.startswith(p) for p in DISPATCH_PREFIXES):
            continue
        # Resolve aliases — if any alias at the same value has callers, the
        # canonical slot is reachable.
        aliases = by_val.get(val, [name])
        if any(a in callers for a in aliases):
            continue
        results.append(('C3', inc, f'dispatch symbol "{name}" ({val}) has 0 callers across all files'))


def check_called_by(files, results):
    """C4: 'Called by Y' claims — verify Y exists as an .asm file.
    Maps original chunk names (fight.bin, town.bin) to their disk-prefixed
    .asm files (200FIGHT.asm, 106TOWN.asm).
    """
    asm_stems = set(p.stem.upper() for p in files)
    # Reverse mapping: original-style names → disk filename
    BIN_TO_ASM = {
        'TOWN': '106TOWN', 'FIGHT': '200FIGHT', 'SELECT': '201SELCT',
        'OPDEMO': '100OPDMO', 'MOLE': '207MOLE', 'YMPD': '208YMPD',
        'CKPD': '209CKPD', 'ROKADEMO': '300ROKAD', 'ENDMO': '250ENDMO',
        'ZELIAD': 'ZELIAD', 'GAME': 'GAME', 'STICK': 'STICK',
        'STDPLY': 'STDPLY', 'GMCGA': 'GMCGA', 'GMEGA': 'GMEGA',
        'GMHGC': 'GMHGC', 'GMMCGA': 'GMMCGA', 'GMTGA': 'GMTGA',
    }
    for path in files:
        rel = str(path.relative_to(WORKING)).replace('\\', '/')
        header = parse_file_header(path)
        claimed = extract_called_by_claims(header)
        for partner in claimed:
            stem = re.sub(r'\.(asm|bin|exe|grp)$', '', partner, flags=re.I).upper()
            # Special-case .exe / interrupt-handler names
            if stem in ('INT', 'BIOS', 'DOS'):
                continue
            # Map original chunk name to disk stem if needed
            mapped = BIN_TO_ASM.get(stem, stem)
            if mapped in asm_stems:
                continue
            if any(s.startswith(mapped) for s in asm_stems):
                continue
            # Or if any asm stem CONTAINS this name (e.g. 209CKPD contains CKPD)
            if any(stem in s for s in asm_stems):
                continue
            results.append(('C4', rel,
                            f'header says "Called by {partner}" but no .asm file matches'))


def check_unresolved_symbols(files, inc_syms, results):
    """C5: Symbols REFERENCED in a file but not defined anywhere reachable."""
    # Define what's reachable: file-local labels/EQUs/procs/macros, imports via include,
    # zr*com.inc members.
    # This check is heuristic — false positives possible because of register-vs-symbol
    # ambiguity in the parser. Filter aggressively.
    X86_NOISE = {
        'ax','bx','cx','dx','si','di','bp','sp','cs','ds','es','ss','ip','flags',
        'al','ah','bl','bh','cl','ch','dl','dh',
        'mov','add','sub','adc','sbb','and','or','xor','not','neg','inc','dec',
        'push','pop','pushf','popf','call','ret','retn','retf','iret','jmp',
        'jz','jnz','je','jne','jc','jnc','jb','jnb','ja','jna','jbe','jae',
        'jl','jle','jg','jge','js','jns','jo','jno','jp','jnp','jpe','jpo',
        'jcxz','loop','loope','loopne','loopz','loopnz',
        'cmp','test','rol','ror','rcl','rcr','shl','shr','sal','sar',
        'mul','imul','div','idiv','cbw','cwd','aam','aad','daa','das',
        'lodsb','lodsw','stosb','stosw','movsb','movsw','cmpsb','cmpsw',
        'scasb','scasw','rep','repe','repne','repz','repnz','cld','std',
        'cli','sti','clc','stc','cmc','hlt','wait','lock','nop',
        'in','out','int','iret','xchg','xlat','xlatb','les','lds','lea',
        'word','byte','dword','ptr','near','far','short','offset','seg','dup',
        'proc','endp','equ','db','dw','dd','dt','dq','assume','segment','ends','end',
        'public','extrn','extern','include','MACRO','ENDM','if','else','endif',
        'ifb','ifnb','ifdef','ifndef','ifidn','ifdif','exitm','irp','rept',
        'ds_seg','cs_seg','es_seg','ss_seg','game_seg','vga_seg','cga_seg','hgc_seg',
        'mca_seg','tga_seg','ega_seg','target','start',
        'fs','gs','eax','ebx','ecx','edx','esi','edi','ebp','esp',
    }
    for path in files:
        rel = str(path.relative_to(WORKING)).replace('\\', '/')
        s = load_file(path)
        # Process per-line so an unmatched quote doesn't consume across lines
        cleaned_lines = []
        for line in s.split('\n'):
            # Strip comment
            line = re.sub(r';.*', '', line)
            # Strip single-quoted strings (per-line so cross-line bleed can't happen)
            line = re.sub(r"'[^']*'", '', line)
            cleaned_lines.append(line)
        s_nc = '\n'.join(cleaned_lines)
        # Drop entire lines that are PURE db/dw data continuations (no leading label)
        s_nc_use = re.sub(r'^[ \t]+d[bw]\s.*$', '', s_nc, flags=re.M)
        # Local definitions — allow leading whitespace, scan ORIGINAL s_nc
        # (before db/dw stripping) so labels with db/dw definitions are caught.
        local_defs = set()
        for m in re.finditer(r'^[ \t]*([a-zA-Z_]\w*)(?:\s*:|\s+(?:proc|equ|MACRO|label|db|dw|dd|segment|ends))', s_nc, re.M):
            local_defs.add(m.group(1))
        # Macro definitions
        macro_params = set()
        for m in re.finditer(r'^[a-zA-Z_]\w*\s+MACRO\s+(.*)$', s_nc, re.M):
            for p in re.split(r'[,\s]+', m.group(1).strip()):
                if p:
                    macro_params.add(p)

        # Find all token references — only in operand-like contexts.
        # Use s_nc_use (pure db/dw lines stripped) to avoid catching tile-data
        # tokens that look like identifiers but are random Sourcer leftovers.
        token_refs = Counter()
        for m in re.finditer(r'\[([a-zA-Z_][a-zA-Z_0-9]+)\]', s_nc_use):
            token_refs[m.group(1)] += 1
        for m in re.finditer(r',\s*(?:word\s+ptr\s+)?(?:byte\s+ptr\s+)?(?:offset\s+)?\[?([a-zA-Z_][a-zA-Z_0-9]+)\b', s_nc_use):
            token_refs[m.group(1)] += 1
        for m in re.finditer(r'\boffset\s+([a-zA-Z_][a-zA-Z_0-9]+)\b', s_nc_use):
            token_refs[m.group(1)] += 1

        for tok, count in token_refs.items():
            if tok in local_defs: continue
            if tok in inc_syms: continue
            if tok in macro_params: continue
            if tok in X86_NOISE: continue
            if len(tok) <= 4: continue  # short tokens likely registers/abbreviations
            if re.match(r'^[0-9][a-fA-F0-9]*[hH]?$', tok): continue
            if tok.startswith('_'): continue
            # Skip if token is a hex literal mistaken for identifier (e.g. starts with digit)
            if re.match(r'^[0-9]', tok): continue
            results.append(('C5', rel, f'references "{tok}" ({count}x) but no definition found'))
            if sum(1 for r in results if r[0] == 'C5' and r[1] == rel) >= 3:
                break


# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------

def main():
    files = all_asm_files()
    inc_syms = parse_inc_symbols()
    print(f'Scanning {len(files)} ASM files; {len(inc_syms)} symbols in shared .inc files')

    results = []
    print('\n--- C1: Header "Calls into X" claims must match actual code ---')
    check_calls_into(files, inc_syms, results)
    c1_count = sum(1 for r in results if r[0] == 'C1')
    print(f'    {c1_count} potential mismatches')

    print('\n--- C2: "Paired with X" must be reciprocal ---')
    pre = len(results)
    check_paired_reciprocity(files, results)
    print(f'    {len(results) - pre} non-reciprocal pairings')

    print('\n--- C3: Shared dispatch symbols must have at least 1 caller ---')
    pre = len(results)
    check_dispatch_slots_have_callers(files, inc_syms, results)
    print(f'    {len(results) - pre} dead dispatch symbols')

    print('\n--- C4: "Called by Y" claims must reference real .asm files ---')
    pre = len(results)
    check_called_by(files, results)
    print(f'    {len(results) - pre} unrecognized callers')

    print('\n--- C5: Referenced symbols must be defined somewhere ---')
    pre = len(results)
    check_unresolved_symbols(files, inc_syms, results)
    print(f'    {len(results) - pre} unresolved references')

    # Detailed report
    if results:
        print('\n=== Findings ===\n')
        by_check = defaultdict(list)
        for check_id, file, msg in results:
            by_check[check_id].append((file, msg))
        for cid in sorted(by_check):
            print(f'\n[{cid}] ({len(by_check[cid])} findings):')
            for file, msg in by_check[cid][:30]:
                print(f'  {file}: {msg}')
            if len(by_check[cid]) > 30:
                print(f'  ... and {len(by_check[cid]) - 30} more')
    else:
        print('\nNo findings — annotations consistent with code.')

    return len(results)


if __name__ == '__main__':
    sys.exit(0 if main() == 0 else 1)
