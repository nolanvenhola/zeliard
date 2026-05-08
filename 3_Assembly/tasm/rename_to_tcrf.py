#!/usr/bin/env python3
"""rename_to_tcrf.py - rename the 58 INC_CONSISTENT stdply names to their
TCRF canonical names.

The renames come from the SECTION_AUDIT.csv ledger: every INC_CONSISTENT
row whose address has a TCRF entry.  Old names are demoted to deprecated
alias EQUs in stdply.inc so we have a paper trail and so leftover refs
elsewhere don't silently break.

Files touched:
  - working/drivers/stdply.asm    (data declarations)
  - working/drivers/stdply.inc    (canonical EQUs + alias section)
  - working/core/zeliard.inc       (rare; if any of these names migrate)
  - working/zelres{1,2,3}/code/zr{1,2,3}com.inc  (mirrored EQUs)
  - working/zelres{1,2,3}/code/*.asm              (use sites)
  - working/drivers/*.asm                         (driver use sites)
  - working/core/*.asm                            (executable use sites)

After renaming, run `python build_all.py --verify` -- all 3 SARs must be
BIT-PERFECT.  If any chunk fails to compile, the rename missed a use site
or broke an include scope; the alias EQUs in stdply.inc give a fallback.
"""

import re
import sys
import argparse
from pathlib import Path

ROOT = Path(__file__).parent.resolve()
WORKING = ROOT / 'working'

# (old_name, new_name) pairs.  Address column for cross-reference only.
RENAMES = [
    # 0x80, 0x83 -- runtime/savefile lifecycle bytes
    ('map_scroll_col',     'starting_position_in_town'),  # 0x80
    ('town_player_col',    'screen_position'),            # 0x83

    # 0x85..0x8A -- 24-bit gold (carried + bank)
    ('player_gold_hi',     'gold_carried_x65536'),         # 0x85
    ('player_gold_lo',     'gold_carried_x1'),             # 0x86
    ('player_gold_mid',    'gold_carried_x256'),           # 0x87
    ('player_bank_hi',     'gold_in_bank_x65536'),         # 0x88
    ('player_bank_lo',     'gold_in_bank_x1'),             # 0x89

    # 0x92, 0x93 -- equipment
    ('equipped_weapon',    'sword'),                       # 0x92
    ('shield_type',        'shield'),                      # 0x93

    # 0x9E, 0xA1..0xA5 -- accessory slots
    ('selected_wearable',  'selected_accessory'),          # 0x9E
    ('wear_1',             'accessory_slot_1'),            # 0xA1
    ('wear_2',             'accessory_slot_2'),            # 0xA2
    ('wear_3',             'accessory_slot_3'),            # 0xA3
    ('wear_4',             'accessory_slot_4'),            # 0xA4
    ('wear_5',             'accessory_slot_5'),            # 0xA5

    # 0xAB..0xB1 -- spell charges (current)
    ('charges_espada',     'spell_charge_espada'),         # 0xAB
    ('charges_saeta',      'spell_charge_saeta'),          # 0xAC
    ('charges_fuego',      'spell_charge_fuego'),          # 0xAD
    ('charges_lanzar',     'spell_charge_lanzar'),         # 0xAE
    ('charges_rascar',     'spell_charge_rascar'),         # 0xAF
    ('charges_agua',       'spell_charge_agua'),           # 0xB0
    ('charges_guerra',     'spell_charge_guerra'),         # 0xB1

    # 0xB4..0xBA -- spell charges (max)
    # IMPORTANT: rename _max_ variants BEFORE the bare ones to avoid
    # accidental collision (`charges_espada` substring of `charges_max_espada`).
    ('charges_max_espada', 'spell_charge_max_espada'),     # 0xB4
    ('charges_max_saeta',  'spell_charge_max_saeta'),      # 0xB5
    ('charges_max_fuego',  'spell_charge_max_fuego'),      # 0xB6
    ('charges_max_lanzar', 'spell_charge_max_lanzar'),     # 0xB7
    ('charges_max_rascar', 'spell_charge_max_rascar'),     # 0xB8
    ('charges_max_agua',   'spell_charge_max_agua'),       # 0xB9
    ('charges_max_guerra', 'spell_charge_max_guerra'),     # 0xBA

    # 0xC2 -- player facing
    ('player_facing',      'facing_direction'),            # 0xC2

    # 0xC9..0xD1 -- magic shop inventory per town
    ('shop_magic_muralla', 'magic_shop_inventory_muralla'),  # 0xC9
    ('shop_magic_satono',  'magic_shop_inventory_satono'),   # 0xCA
    ('shop_magic_bosque',  'magic_shop_inventory_bosque'),   # 0xCB
    ('shop_magic_helada',  'magic_shop_inventory_helada'),   # 0xCC
    ('shop_magic_tumba',   'magic_shop_inventory_tumba'),    # 0xCD
    ('shop_magic_dorado',  'magic_shop_inventory_dorado'),   # 0xCE
    ('shop_magic_llama',   'magic_shop_inventory_llama'),    # 0xCF
    ('shop_magic_pureza',  'magic_shop_inventory_pureza'),   # 0xD0
    ('shop_magic_esco',    'magic_shop_inventory_esco'),     # 0xD1

    # 0xD2..0xDA -- weapon shop swords per town
    ('shop_sword_muralla', 'weapon_shop_swords_muralla'),  # 0xD2
    ('shop_sword_satono',  'weapon_shop_swords_satono'),   # 0xD3
    ('shop_sword_bosque',  'weapon_shop_swords_bosque'),   # 0xD4
    ('shop_sword_helada',  'weapon_shop_swords_helada'),   # 0xD5
    ('shop_sword_tumba',   'weapon_shop_swords_tumba'),    # 0xD6
    ('shop_sword_dorado',  'weapon_shop_swords_dorado'),   # 0xD7
    ('shop_sword_llama',   'weapon_shop_swords_llama'),    # 0xD8
    ('shop_sword_pureza',  'weapon_shop_swords_pureza'),   # 0xD9
    ('shop_sword_esco',    'weapon_shop_swords_esco'),     # 0xDA

    # 0xDB..0xE3 -- weapon shop shields per town
    ('shop_shield_muralla', 'weapon_shop_shields_muralla'),  # 0xDB
    ('shop_shield_satono',  'weapon_shop_shields_satono'),   # 0xDC
    ('shop_shield_bosque',  'weapon_shop_shields_bosque'),   # 0xDD
    ('shop_shield_helada',  'weapon_shop_shields_helada'),   # 0xDE
    ('shop_shield_tumba',   'weapon_shop_shields_tumba'),    # 0xDF
    ('shop_shield_dorado',  'weapon_shop_shields_dorado'),   # 0xE0
    ('shop_shield_llama',   'weapon_shop_shields_llama'),    # 0xE1
    ('shop_shield_pureza',  'weapon_shop_shields_pureza'),   # 0xE2
    ('shop_shield_esco',    'weapon_shop_shields_esco'),     # 0xE3

    # 0xE5 -- sages-spoken bitmap
    ('sages_spoken',       'sages_spoken_bitmap'),          # 0xE5
]


# Files to scan + rename (any file in working/ that is .asm, .inc, .py, .md).
# EXCLUDE: this script itself + audit ledger (the old names appear there
# as data, not as use sites; renaming them would corrupt the documentation).
EXCLUDE_BASENAMES = {
    'rename_to_tcrf.py',
    'SECTION_AUDIT.csv',
    'SECTION_AUDIT_SUMMARY.md',
    'AUDIT_TODO.md',  # already-resolved-row history; don't rewrite
    'EVIDENCE_REPORT.md',  # historical evidence rows
}


def file_iter():
    """Yield every .asm / .inc / .py / .md under working/ + tools/."""
    for ext in ('*.asm', '*.inc', '*.md'):
        for p in WORKING.rglob(ext):
            if p.name not in EXCLUDE_BASENAMES:
                yield p
    # Top-level Python tools + functest that may reference these names
    for ext in ('*.py', '*.md'):
        for p in ROOT.glob(ext):
            if p.name not in EXCLUDE_BASENAMES:
                yield p
        for p in (ROOT / 'functest').glob(ext):
            if p.name not in EXCLUDE_BASENAMES:
                yield p


def rename_in_text(text: str, renames: list[tuple[str, str]]) -> tuple[str, int]:
    """Apply word-boundary renames; return (new_text, total_replacement_count).

    Order matters when one old_name is a substring of another; longest-first
    avoids accidental partial matches.
    """
    # Sort longest-first so `charges_max_espada` is matched before `charges_espada`.
    ordered = sorted(renames, key=lambda p: -len(p[0]))
    total = 0
    for old, new in ordered:
        # \bWORD\b -- word boundary so `shield` doesn't match `shield_HP`.
        pat = re.compile(r'\b' + re.escape(old) + r'\b')
        text, n = pat.subn(new, text)
        total += n
    return text, total


def main():
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument('--dry-run', action='store_true',
                   help='Show what would change without writing files.')
    args = p.parse_args()

    by_file = {}
    grand_total = 0
    for path in file_iter():
        try:
            text = path.read_text(encoding='utf-8', errors='replace')
        except (OSError, UnicodeDecodeError):
            continue
        new_text, n = rename_in_text(text, RENAMES)
        if n == 0:
            continue
        by_file[path] = (text, new_text, n)
        grand_total += n

    print(f'{len(by_file)} files have renames; {grand_total} total replacements.')
    if args.dry_run:
        print('\nDRY RUN -- no files written.')
        for path, (_, _, n) in sorted(by_file.items(), key=lambda kv: -kv[1][2]):
            rel = path.relative_to(ROOT)
            print(f'  {n:>4}  {rel}')
        return

    # Write files
    for path, (_, new_text, _) in by_file.items():
        path.write_text(new_text, encoding='utf-8')

    print(f'\nWrote {len(by_file)} files.')
    print('\nNext steps:')
    print('  1. Add deprecated alias EQUs in stdply.inc for the old names')
    print('     so leftover use sites still resolve (one-line `equ` per old name).')
    print('  2. Run `python build_all.py --verify` -- all 3 SARs must be BIT-PERFECT.')
    print('  3. Re-run `python audit_section.py --update-inventory --write-summary`')
    print('     -- the 58 renamed rows should flip from INC_CONSISTENT to SUPPORTED.')


if __name__ == '__main__':
    main()
