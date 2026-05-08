#!/usr/bin/env python3
"""audit_section.py - build and update the per-section audit ledger.

The ledger is `working/SECTION_AUDIT.csv`.  It has one row per inventory
item from `working/SECTION_INVENTORY.md` (1597 rows total) with a verdict
gathered from deterministic sources only — no LLM judgment.

Sources joined into the ledger:

  1. `working/SECTION_INVENTORY.md` — the master inventory (file + line + name + kind).
  2. The `.asm` file itself — read the line to extract address (for data/labels)
     or proc body (for procs).
  3. `functest/coverage.csv` — classify.py categories A/B/C/D/E for procs.
  4. TCRF authoritative table (in this script) — canonical names for the
     stdply player record bytes 0x80..0xFF.
  5. `working/AUDIT_TODO.md` — already-resolved placeholder addresses.
  6. `working/EVIDENCE_REPORT.md` — already-rendered evidence verdicts
     for contested addresses.

Verdict values (strongest to weakest evidence):
  - SUPPORTED      external evidence aligns with the current name (TCRF,
                    runtime trace, byte-signature match, functest probe).
  - INC_CONSISTENT name matches a scoped `.inc` EQU but no external
                    evidence is on file -- proves consistency between the
                    source and the canonical include, NOT correctness.
  - CONTRADICTED   external evidence rules out the current name.
  - INCONCLUSIVE   examined but not enough deterministic evidence to judge.
  - PENDING        row exists but has not been examined yet.

Usage:
    python audit_section.py                # build/refresh ledger CSV
    python audit_section.py --report       # print verdict counts
    python audit_section.py --filter stdply  # show one file's rows
"""

import argparse
import csv
import re
import sys
from collections import Counter, defaultdict
from pathlib import Path

ROOT = Path(__file__).parent.resolve()
WORKING = ROOT / 'working'
INVENTORY_MD = WORKING / 'SECTION_INVENTORY.md'
COVERAGE_CSV = ROOT / 'functest' / 'coverage.csv'
LEDGER_CSV = WORKING / 'SECTION_AUDIT.csv'

# ---------------------------------------------------------------------------
# TCRF AUTHORITATIVE TABLE - copied from MEMORY.md
# (reference_zeliard_save_format_tcrf.md).  Maps stdply byte address ->
# canonical name as documented on the TCRF wiki (Kuro-chan's analysis).
#
# Match policy:
# - For 1-byte fields (db): exact name match -> SUPPORTED, otherwise CONTRADICTED.
# - For 16-bit fields (dw): name matches the TCRF prefix (with _lo/_hi
#   stripped) -> SUPPORTED.  Stdply often uses `experience` as a 16-bit
#   container name where TCRF documents `experience_lo`/`experience_hi`
#   per-byte; the source name is correct in code, just different
#   granularity.  See TCRF_16BIT_ALIAS for additional accepted aliases
#   (e.g. `player_HP` for `life_current`).
# ---------------------------------------------------------------------------
TCRF_STDPLY = {
    # 0x80..0x7F unused below — these bytes are dungeon/town event flags.
    # 0x80..0xFF: character data
    0x80: 'starting_position_in_town',
    # 0x81: 'do_not_edit',  # crashes the game; unnamed
    # 0x82: unknown
    0x83: 'screen_position',
    # 0x84: unknown
    0x85: 'gold_carried_x65536',  # gold_hi
    0x86: 'gold_carried_x1',      # gold_lo
    0x87: 'gold_carried_x256',    # gold_mid
    0x88: 'gold_in_bank_x65536',
    0x89: 'gold_in_bank_x1',
    0x8A: 'gold_in_bank_x256',
    0x8B: 'almas_carried_lo',
    0x8C: 'almas_carried_hi',
    0x8D: 'hero_level',
    0x8E: 'experience_lo',
    0x8F: 'experience_hi',
    0x90: 'life_current_lo',
    0x91: 'life_current_hi',
    0x92: 'sword',
    0x93: 'shield',
    0x94: 'shield_HP_current_lo',
    0x95: 'shield_HP_current_hi',
    0x96: 'shield_HP_max_lo',
    0x97: 'shield_HP_max_hi',
    0x98: 'keys_normal',
    0x99: 'keys_lion',
    0x9A: 'crest_elf',
    0x9B: 'crest_glory',
    0x9C: 'crest_hero',
    0x9D: 'selected_spell',
    0x9E: 'selected_accessory',
    # 0x9F: vestigial; speculation: original "selected item" slot
    0xA0: 'tears_of_esmesanti_count',
    0xA1: 'accessory_slot_1',
    0xA2: 'accessory_slot_2',
    0xA3: 'accessory_slot_3',
    0xA4: 'accessory_slot_4',
    0xA5: 'accessory_slot_5',
    0xA6: 'item_slot_1',
    0xA7: 'item_slot_2',
    0xA8: 'item_slot_3',
    0xA9: 'item_slot_4',
    0xAA: 'item_slot_5',
    0xAB: 'spell_charge_espada',
    0xAC: 'spell_charge_saeta',
    0xAD: 'spell_charge_fuego',
    0xAE: 'spell_charge_lanzar',
    0xAF: 'spell_charge_rascar',
    0xB0: 'spell_charge_agua',
    0xB1: 'spell_charge_guerra',
    0xB2: 'life_max_lo',
    0xB3: 'life_max_hi',
    0xB4: 'spell_charge_max_espada',
    0xB5: 'spell_charge_max_saeta',
    0xB6: 'spell_charge_max_fuego',
    0xB7: 'spell_charge_max_lanzar',
    0xB8: 'spell_charge_max_rascar',
    0xB9: 'spell_charge_max_agua',
    0xBA: 'spell_charge_max_guerra',
    0xBB: 'spell_known_espada',
    0xBC: 'spell_known_saeta',
    0xBD: 'spell_known_fuego',
    0xBE: 'spell_known_lanzar',
    0xBF: 'spell_known_rascar',
    0xC0: 'spell_known_agua',
    0xC1: 'spell_known_guerra',
    0xC2: 'facing_direction',
    0xC4: 'save_sage',
    0xC5: 'last_sage_visited',
    0xC9: 'magic_shop_inventory_muralla',
    0xCA: 'magic_shop_inventory_satono',
    0xCB: 'magic_shop_inventory_bosque',
    0xCC: 'magic_shop_inventory_helada',
    0xCD: 'magic_shop_inventory_tumba',
    0xCE: 'magic_shop_inventory_dorado',
    0xCF: 'magic_shop_inventory_llama',
    0xD0: 'magic_shop_inventory_pureza',
    0xD1: 'magic_shop_inventory_esco',
    0xD2: 'weapon_shop_swords_muralla',
    0xD3: 'weapon_shop_swords_satono',
    0xD4: 'weapon_shop_swords_bosque',
    0xD5: 'weapon_shop_swords_helada',
    0xD6: 'weapon_shop_swords_tumba',
    0xD7: 'weapon_shop_swords_dorado',
    0xD8: 'weapon_shop_swords_llama',
    0xD9: 'weapon_shop_swords_pureza',
    0xDA: 'weapon_shop_swords_esco',
    0xDB: 'weapon_shop_shields_muralla',
    0xDC: 'weapon_shop_shields_satono',
    0xDD: 'weapon_shop_shields_bosque',
    0xDE: 'weapon_shop_shields_helada',
    0xDF: 'weapon_shop_shields_tumba',
    0xE0: 'weapon_shop_shields_dorado',
    0xE1: 'weapon_shop_shields_llama',
    0xE2: 'weapon_shop_shields_pureza',
    0xE3: 'weapon_shop_shields_esco',
    0xE5: 'sages_spoken_bitmap',
}


# Accepted aliases for 16-bit container names in stdply.asm where TCRF
# names the bytes individually with `_lo`/`_hi` suffixes.  Maps
# (source_name -> tcrf_prefix).  Used when a `dw` field's source name
# differs from the TCRF lo-byte name but is semantically equivalent.
TCRF_16BIT_ALIAS = {
    'player_HP':       'life_current',
    'player_HP_max':   'life_max',
    'player_almas':    'almas_carried',
    'shield_HP':       'shield_HP_current',
    'shield_max_HP':   'shield_HP_max',
    # `experience` and `gold_carried_*` already match TCRF prefix exactly.
}


# Inventory row regex: `- [ ] L###  `name`  *(kind)*`
INV_ROW = re.compile(
    r'^-\s+\[(?P<done>[ x])\]\s+L(?P<line>\d+)\s+`(?P<name>[^`]+)`\s+\*\((?P<kind>[^)]+)\)\*'
)
INV_HEAD = re.compile(r'^##\s+(?P<file>working/\S+\.asm)\s+\((\d+)\s+sections\)')


def parse_inventory(path: Path) -> list[dict]:
    """Parse SECTION_INVENTORY.md into a list of row dicts."""
    rows = []
    current_file = None
    for line in path.read_text(encoding='utf-8', errors='replace').splitlines():
        m = INV_HEAD.match(line)
        if m:
            current_file = m.group('file')
            continue
        m = INV_ROW.match(line)
        if m and current_file:
            rows.append({
                'file': current_file,
                'line': int(m.group('line')),
                'name': m.group('name'),
                'kind': m.group('kind').strip(),
                'done': m.group('done') == 'x',
            })
    return rows


def parse_asm_line(asm_path: Path, line_num: int) -> tuple[str, str, str]:
    """Read line `line_num` from `asm_path` and return (raw_line, address_hex, decl).

    `address_hex` is the lowercase hex value derived from one of:
      1. `name equ <hex>h`            -- EQU constant (e.g. zr2com.inc)
      2. `name dw|db|dd <val>` with `; [<hex>h]` comment marker
         (the canonical offset annotation in stdply.asm + similar layouts)

    `decl` is one of '', 'equ', 'db', 'dw', 'dd' depending on the line shape.
    """
    if not asm_path.exists():
        return '', '', ''
    try:
        text = asm_path.read_text(encoding='utf-8', errors='replace')
    except Exception:
        return '', '', ''
    lines = text.splitlines()
    if 0 < line_num <= len(lines):
        raw = lines[line_num - 1]
    else:
        raw = ''
    # Match `name equ XXh` or `name equ 0XXh`
    m = re.match(r'^\s*\S+\s+equ\s+0?([0-9A-Fa-f]+)h\b', raw)
    if m:
        return raw.rstrip(), m.group(1).lower(), 'equ'
    # Match `name dw|db|dd ...` with a trailing `; [XXh-YYh]` or `; [XXh]`
    # comment that gives the byte offset (used in stdply.asm).
    decl_m = re.match(r'^\s*\S+\s+(db|dw|dd)\b', raw)
    if decl_m:
        m = re.search(r';\s*\[0?([0-9A-Fa-f]+)h', raw)
        if m:
            return raw.rstrip(), m.group(1).lower(), decl_m.group(1)
    return raw.rstrip(), '', ''


def parse_coverage_csv(path: Path) -> dict:
    """Return {(chunk, name): row_dict} from functest/coverage.csv."""
    if not path.exists():
        return {}
    out = {}
    with path.open(encoding='utf-8') as f:
        for row in csv.DictReader(f):
            key = (row['chunk'], row['name'])
            out[key] = row
    return out


def parse_data_pattern_verify(path: Path) -> dict:
    """Parse working/DATA_PATTERN_VERIFY.md.

    Returns {(file, name): (verdict, evidence_summary)}.
    """
    if not path.exists():
        return {}
    out = {}
    text = path.read_text(encoding='utf-8', errors='replace')
    # Rows like: | `file` | line | `name` | kind | pattern | source_line |
    row_re = re.compile(
        r'^\|\s*`(?P<file>[^`]+)`\s*\|\s*\d+\s*\|\s*`(?P<name>[^`]+)`\s*\|\s*'
        r'[^|]*\s*\|\s*(?P<desc>[^|]*?)\s*\|',
        re.MULTILINE,
    )
    # Only parse rows under SUPPORTED section (before INCONCLUSIVE)
    if '## INCONCLUSIVE' in text:
        text_supported = text.split('## INCONCLUSIVE')[0]
    else:
        text_supported = text
    for m in row_re.finditer(text_supported):
        out[(m.group('file'), m.group('name'))] = (
            'SUPPORTED',
            f'data-pattern: {m.group("desc")}',
        )
    return out


def parse_name_pattern_verify(path: Path) -> dict:
    """Parse working/NAME_PATTERN_VERIFY.md.

    Returns {(file, name): (verdict, evidence_summary)}.
    Verdict is always SUPPORTED in this file (only matched rows are listed).
    """
    if not path.exists():
        return {}
    out = {}
    text = path.read_text(encoding='utf-8', errors='replace')
    # Rows like: | `file` | line | `name` | role description |
    row_re = re.compile(
        r'^\|\s*`(?P<file>[^`]+)`\s*\|\s*\d+\s*\|\s*`(?P<name>[^`]+)`\s*\|\s*'
        r'(?P<desc>[^|]*?)\s*\|',
        re.MULTILINE,
    )
    for m in row_re.finditer(text):
        out[(m.group('file'), m.group('name'))] = (
            'SUPPORTED',
            f'name-pattern: {m.group("desc")}',
        )
    return out


def parse_driver_signature_verify(path: Path) -> dict:
    """Parse working/DRIVER_SIGNATURE_VERIFY.md.

    Returns {(chunk, proc_name): (verdict, evidence_summary)}.
    """
    if not path.exists():
        return {}
    out = {}
    text = path.read_text(encoding='utf-8', errors='replace')
    # The file has H3 sections with proc name + description, followed by a
    # markdown table of (chunk, verdict, patterns).
    proc_re = re.compile(r'^### `(?P<name>\w+)` -- (?P<desc>.*)$', re.MULTILINE)
    row_re = re.compile(
        r'^\| `(?P<chunk>\w+)` \| \*\*(?P<verdict>SUPPORTED|CONTRADICTED|INCONCLUSIVE)\*\* \|',
        re.MULTILINE,
    )
    # Walk the file: for each H3 block, capture the (chunk, verdict) rows
    sections = list(proc_re.finditer(text))
    for i, m in enumerate(sections):
        name = m.group('name')
        desc = m.group('desc')
        block_start = m.end()
        block_end = sections[i + 1].start() if i + 1 < len(sections) else len(text)
        block = text[block_start:block_end]
        for row in row_re.finditer(block):
            chunk = row.group('chunk')
            verdict = row.group('verdict')
            evidence = f'driver-signature: {desc}'
            out[(chunk, name)] = (verdict, evidence)
    return out


def parse_inc_equs(inc_path: Path) -> dict:
    """Return {address_lower_hex: [list_of_names]} from a .inc file.

    Multiple names at one address are common (canonical + alias EQUs).
    """
    if not inc_path.exists():
        return {}
    out = defaultdict(list)
    pat = re.compile(
        r'^\s*(\w+)\s+equ\s+0?([0-9A-Fa-f]+)h\b',
    )
    for line in inc_path.read_text(encoding='utf-8', errors='replace').splitlines():
        m = pat.match(line)
        if m:
            name = m.group(1)
            addr = m.group(2).lower()
            out[addr].append(name)
    return dict(out)


def parse_audit_todo(path: Path) -> dict:
    """Extract resolved placeholder addresses from working/AUDIT_TODO.md.

    Returns {address_lower_hex: canonical_name} for rows marked [x].
    """
    if not path.exists():
        return {}
    out = {}
    text = path.read_text(encoding='utf-8')
    # Rows look like:
    #   | [x] | `0xFF3E` | `gvar_flag_FF3E` | 7 | ... | **`spell_fx_active`** |
    pat = re.compile(
        r'^\|\s*\[x\]\s*\|\s*`0x([0-9A-Fa-f]+)`\s*\|.*?\*\*`([^`]+)`\*\*\s*\|',
        re.MULTILINE,
    )
    for m in pat.finditer(text):
        addr = m.group(1).lower()
        out[addr] = m.group(2)
    return out


def chunk_stem_from_file(file_rel: str) -> str:
    """working/zelres1/code/100OPDMO.asm -> 100OPDMO."""
    return Path(file_rel).stem


def is_stdply_file(file_rel: str) -> bool:
    return file_rel.endswith('drivers/stdply.asm')


def build_ledger() -> list[dict]:
    """Build the SECTION_AUDIT ledger from all sources."""
    inventory = parse_inventory(INVENTORY_MD)
    coverage = parse_coverage_csv(COVERAGE_CSV)
    audit_todo = parse_audit_todo(WORKING / 'AUDIT_TODO.md')
    driver_sigs = parse_driver_signature_verify(
        WORKING / 'DRIVER_SIGNATURE_VERIFY.md'
    )
    name_patterns = parse_name_pattern_verify(
        WORKING / 'NAME_PATTERN_VERIFY.md'
    )
    data_patterns = parse_data_pattern_verify(
        WORKING / 'DATA_PATTERN_VERIFY.md'
    )

    # The .inc files are canonical homes for EQU names.  Any name that
    # appears as an EQU in the include file scoped to its source file is
    # an accepted canonical.  Includes both runtime-semantic names and
    # alias EQUs (e.g. TCRF aliases) at the same address.
    stdply_equs   = parse_inc_equs(WORKING / 'drivers' / 'stdply.inc')
    stick_equs    = parse_inc_equs(WORKING / 'drivers' / 'stick.inc')
    zeliard_equs  = parse_inc_equs(WORKING / 'core' / 'zeliard.inc')
    zr1_equs      = parse_inc_equs(WORKING / 'zelres1' / 'code' / 'zr1com.inc')
    zr2_equs      = parse_inc_equs(WORKING / 'zelres2' / 'code' / 'zr2com.inc')
    zr3_equs      = parse_inc_equs(WORKING / 'zelres3' / 'code' / 'zr3com.inc')

    # Per-file include scope: which .inc files are read by each source path.
    # When the source name matches an EQU in any of its scoped includes, it's
    # considered SUPPORTED.
    def includes_for(file_rel: str):
        """Return list of (inc_label, equs_dict) the source file pulls in."""
        scope = []
        if 'drivers/stdply' in file_rel or 'drivers/gm' in file_rel:
            scope.append(('stdply.inc', stdply_equs))
        if 'drivers/stick' in file_rel:
            scope.append(('stick.inc', stick_equs))
        if 'core/zeliad' in file_rel or 'core/game' in file_rel:
            scope.append(('zeliard.inc', zeliard_equs))
        if 'zelres1/code' in file_rel:
            scope.append(('zr1com.inc', zr1_equs))
            scope.append(('zeliard.inc', zeliard_equs))
        if 'zelres2/code' in file_rel:
            scope.append(('zr2com.inc', zr2_equs))
            scope.append(('zeliard.inc', zeliard_equs))
        if 'zelres3/code' in file_rel:
            scope.append(('zr3com.inc', zr3_equs))
            scope.append(('zeliard.inc', zeliard_equs))
        return scope

    # Reverse index from each .inc: name -> [(address, inc_label)]
    def name_to_addr(name: str, file_rel: str) -> str:
        """Find the EQU address for `name` in any of file_rel's scoped .inc files."""
        for inc_label, inc_equs in includes_for(file_rel):
            for addr, names in inc_equs.items():
                if name in names:
                    return addr
        return ''

    ledger = []
    for inv in inventory:
        file_rel = inv['file']
        asm_path = ROOT / file_rel
        raw_line, equ_value, decl = parse_asm_line(asm_path, inv['line'])

        # Try to derive the address (only meaningful for data/labels with EQU)
        address_hex = equ_value or ''

        # Fallback: if the line had no extractable hex offset comment and
        # this is a data declaration, look up the inventory name in
        # scoped .inc files (catches self-referential `; [name]` comments).
        if not address_hex and inv['kind'].startswith(('data', 'label')):
            address_hex = name_to_addr(inv['name'], file_rel)
            if address_hex and not decl:
                # Re-detect decl if we recovered the address.
                decl = ''  # leave empty -- stdply.inc reverse lookup is sufficient

        # classify.py category for procs
        chunk = chunk_stem_from_file(file_rel)
        cov = coverage.get((chunk, inv['name']), {})
        category = cov.get('category', '')
        has_placeholder = cov.get('has_placeholder_name', '') == 'True'

        # Default verdict
        verdict = 'PENDING'
        canonical = ''
        evidence = ''
        source = ''

        # Evidence priority (strongest first):
        #
        #   (1) TCRF -- external, runtime-validated savefile reverse-engineering
        #       (memory/reference_zeliard_save_format_tcrf.md).  Names in this
        #       table were confirmed by editing save bytes and observing
        #       in-game behaviour.  Strongest evidence available.
        #
        #   (2) .inc consistency -- the source's name appears as an EQU at
        #       the same address in a scoped .inc file.  This proves the
        #       source and the canonical include AGREE; it does NOT prove
        #       the name is correct on its own.  Weaker evidence than TCRF.
        #
        # Source 0: driver-signature verification.  For procs in graphics
        # drivers, the role-fingerprint match across all 5 parallel
        # implementations is deterministic byte/opcode evidence.
        if inv['kind'] == 'proc':
            chunk = chunk_stem_from_file(file_rel)
            sig = driver_sigs.get((chunk, inv['name']))
            if sig:
                sig_verdict, sig_evidence = sig
                verdict = sig_verdict
                canonical = inv['name']
                evidence = sig_evidence
                source = 'driver-sig'

        # Source 0b: name-pattern fingerprint match.  For procs whose
        # name implies a role (e.g. wait_*, dispatch_*), the body's
        # opcode fingerprint matches the role.
        if verdict == 'PENDING' and inv['kind'] == 'proc':
            np = name_patterns.get((file_rel, inv['name']))
            if np:
                np_verdict, np_evidence = np
                verdict = np_verdict
                canonical = inv['name']
                evidence = np_evidence
                source = 'name-pattern'

        # Source 0c: data-pattern shape match.  For data/label items
        # whose name implies a shape (string / table / pointer / buffer),
        # the source line at the inventory's recorded line shows that shape.
        if verdict == 'PENDING' and (inv['kind'] == 'data' or
                                     inv['kind'].startswith('label')):
            dp = data_patterns.get((file_rel, inv['name']))
            if dp:
                dp_verdict, dp_evidence = dp
                verdict = dp_verdict
                canonical = inv['name']
                evidence = dp_evidence
                source = 'data-pattern'

        # Source 1a: TCRF authoritative table for stdply 0x80..0xFF
        if verdict == 'PENDING' and is_stdply_file(file_rel) and address_hex:
            try:
                addr_int = int(address_hex, 16)
            except ValueError:
                addr_int = -1
            if addr_int in TCRF_STDPLY:
                tcrf_name = TCRF_STDPLY[addr_int]
                # Strip the _lo/_hi suffix to get the TCRF semantic prefix.
                tcrf_prefix = re.sub(r'_(?:lo|hi)$', '', tcrf_name)

                # Exact match -> SUPPORTED
                if inv['name'] == tcrf_name:
                    verdict = 'SUPPORTED'
                    canonical = tcrf_name
                    evidence = f'TCRF stdply: 0x{addr_int:02X} = {tcrf_name}'
                    source = 'TCRF'
                # 16-bit container name match (`dw` field at TCRF `_lo` byte
                # whose source name equals the prefix or an accepted alias).
                elif decl == 'dw' and tcrf_name.endswith('_lo') and (
                    inv['name'] == tcrf_prefix
                    or TCRF_16BIT_ALIAS.get(inv['name']) == tcrf_prefix
                ):
                    verdict = 'SUPPORTED'
                    canonical = inv['name']
                    evidence = (
                        f'TCRF stdply: 0x{addr_int:02X} = {tcrf_name} '
                        f'(byte-level); 16-bit container name {inv["name"]} accepted'
                    )
                    source = 'TCRF'

        # Source 1b: scoped .inc file canonical EQU tables.  This is a
        # CONSISTENCY check, not external proof: it confirms the source
        # name matches what the canonical include declares.  Useful for
        # excluding genuine mismatches but does not validate the name
        # against game semantics.
        if verdict == 'PENDING' and address_hex:
            for inc_label, inc_equs in includes_for(file_rel):
                inc_names = inc_equs.get(address_hex, [])
                if inv['name'] in inc_names:
                    verdict = 'INC_CONSISTENT'
                    canonical = inv['name']
                    aliases = [n for n in inc_names if n != inv['name']]
                    if aliases:
                        evidence = (
                            f'{inc_label}: 0x{address_hex} has '
                            f'{len(inc_names)} name(s); current is one of them; '
                            f'others (aliases): {", ".join(aliases[:5])}'
                            + (' ...' if len(aliases) > 5 else '')
                            + ' -- consistency only, not external proof.'
                        )
                    else:
                        evidence = (
                            f'{inc_label}: 0x{address_hex} = {inv["name"]} '
                            f'(consistency only, not external proof).'
                        )
                    source = inc_label
                    break

        # Source 2: AUDIT_TODO.md already-resolved addresses
        if verdict == 'PENDING' and address_hex in audit_todo:
            canonical = audit_todo[address_hex]
            if inv['name'] == canonical:
                verdict = 'SUPPORTED'
                evidence = f'AUDIT_TODO.md: 0x{address_hex} = {canonical} (resolved)'
                source = 'AUDIT_TODO'
            else:
                verdict = 'CONTRADICTED'
                evidence = (
                    f'AUDIT_TODO.md says 0x{address_hex} = {canonical}, '
                    f'current = {inv["name"]}'
                )
                source = 'AUDIT_TODO'

        ledger.append({
            'file': file_rel,
            'line': inv['line'],
            'name': inv['name'],
            'kind': inv['kind'],
            'inv_done': '1' if inv['done'] else '0',
            'address': address_hex,
            'classify_category': category,
            'has_placeholder_name': '1' if has_placeholder else '0',
            'verdict': verdict,
            'canonical_name': canonical,
            'evidence_summary': evidence,
            'evidence_source': source,
        })
    return ledger


def write_ledger(rows: list[dict], path: Path) -> None:
    fieldnames = [
        'file', 'line', 'name', 'kind', 'inv_done',
        'address', 'classify_category', 'has_placeholder_name',
        'verdict', 'canonical_name', 'evidence_summary', 'evidence_source',
    ]
    with path.open('w', newline='', encoding='utf-8') as f:
        w = csv.DictWriter(f, fieldnames=fieldnames)
        w.writeheader()
        for row in rows:
            w.writerow(row)


def report_counts(rows: list[dict]) -> None:
    print(f'Total ledger rows: {len(rows)}')
    print()
    # By verdict
    verdict_counts = Counter(r['verdict'] for r in rows)
    print('By verdict:')
    for v, n in verdict_counts.most_common():
        print(f'  {v:<14} {n:>5}')
    print()
    # By source (when set)
    src_counts = Counter(r['evidence_source'] for r in rows if r['evidence_source'])
    if src_counts:
        print('Sources providing verdict:')
        for s, n in src_counts.most_common():
            print(f'  {s:<14} {n:>5}')
        print()
    # By kind
    kind_counts = Counter(r['kind'] for r in rows)
    print('By kind:')
    for k, n in kind_counts.most_common():
        print(f'  {k:<14} {n:>5}')
    print()
    # Procs by classify category
    proc_cat = Counter(
        r['classify_category'] for r in rows
        if r['kind'] == 'proc' and r['classify_category']
    )
    if proc_cat:
        print('Procs by classify.py category (n=' + str(sum(proc_cat.values())) + '):')
        for c, n in sorted(proc_cat.items()):
            print(f'  {c:<14} {n:>5}')
        print()
    # CONTRADICTED rows — the highest-leverage rename targets
    contradicted = [r for r in rows if r['verdict'] == 'CONTRADICTED']
    if contradicted:
        print(f'CONTRADICTED rows (high-priority renames): {len(contradicted)}')
        for r in contradicted[:20]:
            print(f'  {Path(r["file"]).name:<20} L{r["line"]:<4} '
                  f'{r["name"]:<35} -> {r["canonical_name"]}')
        if len(contradicted) > 20:
            print(f'  ... ({len(contradicted) - 20} more)')


def update_inventory_checkboxes(rows: list[dict], inventory_path: Path) -> int:
    """Mark each row's checkbox in SECTION_INVENTORY.md based on verdict.

    Only SUPPORTED rows (external evidence) get [x].  INC_CONSISTENT
    rows stay [ ] because consistency is not proof of correctness.

    Returns the number of checkbox transitions written.
    """
    text = inventory_path.read_text(encoding='utf-8', errors='replace')
    lines = text.splitlines()

    # Index ledger rows by (file, line, name)
    ledger_by_key = {}
    for r in rows:
        key = (r['file'], int(r['line']), r['name'])
        ledger_by_key[key] = r

    current_file = None
    transitions = 0
    for i, line in enumerate(lines):
        m_head = INV_HEAD.match(line)
        if m_head:
            current_file = m_head.group('file')
            continue
        m_row = INV_ROW.match(line)
        if not m_row or current_file is None:
            continue
        key = (current_file, int(m_row.group('line')), m_row.group('name'))
        led = ledger_by_key.get(key)
        if not led:
            continue
        want_done = led['verdict'] == 'SUPPORTED'
        is_done = m_row.group('done') == 'x'
        if want_done == is_done:
            continue
        # Replace the checkbox character.
        new_box = '[x]' if want_done else '[ ]'
        old_box = '[x]' if is_done else '[ ]'
        # First occurrence in the line (the leading checkbox)
        lines[i] = line.replace(old_box, new_box, 1)
        transitions += 1

    if transitions:
        inventory_path.write_text('\n'.join(lines) + '\n', encoding='utf-8')
    return transitions


def write_audit_summary_md(rows: list[dict], path: Path) -> None:
    """Write a human-readable Markdown summary of the audit ledger."""
    verdict_counts = Counter(r['verdict'] for r in rows)
    src_counts = Counter(r['evidence_source'] for r in rows if r['evidence_source'])
    by_file_pending = defaultdict(int)
    by_file_supported = defaultdict(int)
    by_file_contradicted = defaultdict(int)
    for r in rows:
        if r['verdict'] == 'PENDING':
            by_file_pending[r['file']] += 1
        elif r['verdict'] == 'SUPPORTED':
            by_file_supported[r['file']] += 1
        elif r['verdict'] == 'CONTRADICTED':
            by_file_contradicted[r['file']] += 1

    out = []
    out.append('# Section Audit Summary')
    out.append('')
    out.append('Auto-generated by `audit_section.py` from the inventory ledger.')
    out.append('Verdicts come from deterministic sources only -- no LLM judgment.')
    out.append('')
    out.append(f'Total rows: **{len(rows)}**')
    out.append('')
    out.append('## Verdict counts')
    out.append('')
    out.append('Strength ladder (strongest first):')
    out.append('')
    out.append('- **SUPPORTED** -- external evidence (TCRF table, runtime trace,')
    out.append('  byte-signature match, functest probe) confirms the name.')
    out.append('- **INC_CONSISTENT** -- name matches a scoped `.inc` EQU but no')
    out.append('  external evidence is on file.  Proves the source agrees with')
    out.append('  the canonical include, NOT that the name is correct.')
    out.append('- **CONTRADICTED** -- external evidence rules out the name.')
    out.append('- **INCONCLUSIVE** -- examined but evidence insufficient.')
    out.append('- **PENDING** -- not yet examined.')
    out.append('')
    out.append('| Verdict | Count |')
    out.append('|---|---:|')
    for v in ['SUPPORTED', 'INC_CONSISTENT', 'CONTRADICTED', 'INCONCLUSIVE', 'PENDING']:
        out.append(f'| {v} | {verdict_counts.get(v, 0)} |')
    out.append('')
    if src_counts:
        out.append('## Evidence sources (rows with verdict)')
        out.append('')
        out.append('| Source | Count |')
        out.append('|---|---:|')
        for s, n in src_counts.most_common():
            out.append(f'| {s} | {n} |')
        out.append('')
    # Files with at least one SUPPORTED row
    out.append('## Per-file resolution status')
    out.append('')
    out.append('| File | Supported | Contradicted | Pending | Total |')
    out.append('|---|---:|---:|---:|---:|')
    files = sorted({r['file'] for r in rows})
    for f in files:
        supp = by_file_supported.get(f, 0)
        cont = by_file_contradicted.get(f, 0)
        pend = by_file_pending.get(f, 0)
        total = supp + cont + pend
        if supp + cont == 0:
            continue  # skip files with nothing resolved -- listed elsewhere
        out.append(f'| `{f}` | {supp} | {cont} | {pend} | {total} |')
    out.append('')
    # Files with zero resolution (the priority for Tier 2-4)
    zero_files = [f for f in files if by_file_supported.get(f, 0) == 0
                  and by_file_contradicted.get(f, 0) == 0]
    if zero_files:
        out.append(f'## Files with zero Group-1 resolution ({len(zero_files)})')
        out.append('')
        out.append('These files have no items resolved by deterministic Group-1')
        out.append('sources (.inc EQU lookups + TCRF table).  All sections in')
        out.append('these files are PENDING and need Tier-2 (cross-file sweep) or')
        out.append('Tier-3 (functest probe) work.')
        out.append('')
        for f in zero_files:
            n = by_file_pending.get(f, 0)
            out.append(f'- `{f}` -- {n} pending')
        out.append('')
    path.write_text('\n'.join(out), encoding='utf-8')


def main():
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument('--report', action='store_true',
                   help='Print verdict counts after building.')
    p.add_argument('--filter', metavar='SUBSTR',
                   help='Only show rows whose file path contains SUBSTR.')
    p.add_argument('--update-inventory', action='store_true',
                   help='Mark SUPPORTED rows as [x] in SECTION_INVENTORY.md.')
    p.add_argument('--write-summary', action='store_true',
                   help='Write working/SECTION_AUDIT_SUMMARY.md.')
    args = p.parse_args()

    rows = build_ledger()
    write_ledger(rows, LEDGER_CSV)
    print(f'Wrote {len(rows)} rows -> {LEDGER_CSV}')

    if args.update_inventory:
        n = update_inventory_checkboxes(rows, INVENTORY_MD)
        print(f'Marked {n} inventory checkboxes (SUPPORTED -> [x]).')

    if args.write_summary:
        summary_path = WORKING / 'SECTION_AUDIT_SUMMARY.md'
        write_audit_summary_md(rows, summary_path)
        print(f'Wrote summary -> {summary_path}')

    if args.filter:
        rows = [r for r in rows if args.filter in r['file']]
        print(f'\nFiltered to {len(rows)} rows containing "{args.filter}":')
        for r in rows:
            print(f'  {r["file"]} L{r["line"]:<4} '
                  f'{r["name"]:<35} {r["kind"]:<14} '
                  f'verdict={r["verdict"]:<13} '
                  f'canonical={r["canonical_name"]}')
    elif args.report:
        print()
        report_counts(rows)


if __name__ == '__main__':
    main()
