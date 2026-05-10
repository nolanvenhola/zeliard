#!/usr/bin/env python3
"""name_clarity_audit.py - surface proc names that don't communicate purpose.

**Rule**: every proc name MUST contain at least one VERB and one NOUN, where
neither is a generic placeholder.  `init_palette` passes (init=verb,
palette=noun).  `vga_operation` fails (operation is a noun, not an action;
no verb).  `player_multiply` fails (multiply alone doesn't say WHAT is
multiplied).  `copy_buffer` is borderline (verb+noun, but buffer is too
generic; flagged as `weak_object`).

The audit reports four classes:

1. **missing_verb** -- no recognisable action token in the name.
   E.g. `vga_operation`, `town_state`, `image_data`.

2. **missing_object** -- a verb with no concrete noun.
   E.g. `multiply`, `init`, `copy`, `player_multiply` (player is scope
   not object), `pal_multiply`.

3. **numbered_duplicate** -- `name`, `name_2`, `name_3`, ... where the
   number is the only distinguisher.  E.g. `copy_buffer` /
   `copy_buffer_2` / `copy_buffer_3`.

4. **weak_object** -- has verb+noun, but the noun is a generic container
   ("buffer", "data", "thing", "state") that doesn't say WHICH one.
   Lowest priority -- often acceptable for chunk-scoped helpers.

Usage:
    python name_clarity_audit.py [--out PATH]
    python name_clarity_audit.py --filter 200FIGHT
    python name_clarity_audit.py --counts
    python name_clarity_audit.py --class missing_verb
"""
from __future__ import annotations

import argparse
import re
import sys
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).parent.resolve()
WORKING = ROOT / 'working'
DEFAULT_OUT = WORKING / 'NAME_CLARITY_AUDIT.md'

# ---------------------------------------------------------------------------
# Token vocabularies
# ---------------------------------------------------------------------------
# VERBS = tokens that constitute a real action.  Roughly imperative-mood
# verbs you might find in API design.  Includes domain verbs like blit,
# scroll, dispatch, tick.
# Real verb tokens.  Includes:
#   - imperative verbs (load, save, draw, ...)
#   - predicate prefixes (is, has, can, should) -- these mark return-bool
#     procs and ARE verbs in the predicate sense
#   - compound/agent forms derived from verbs (dispatcher, handler,
#     scanner) -- "dispatcher" implicitly carries the action "dispatch"
VERBS = frozenset("""
    load save copy fill clear draw render init setup reset start stop run
    update refresh compute calculate calc get set find scan check test verify
    parse format convert encode decode compress decompress send receive
    read write push pop allocate alloc free lock unlock wait sleep dispatch
    invoke call return jump advance retreat swap sort merge split append
    prepend insert delete remove add subtract multiply divide increment
    decrement toggle enable disable mask unmask mark unmark validate
    emit consume produce transfer blit scroll animate tick step
    play pause resume mute fade flip rotate transform map lookup
    detect match schedule register unregister attach detach sync flush
    process handle measure count restore stamp pack pump gate wrap
    rebuild build destroy create open close show hide display drain
    enter exit apply commit rollback abort retry cancel
    enqueue dequeue peek poke wipe erase fetch store
    move slide shift bump nudge spawn kill fire trigger forward
    skip seek rewind tally accumulate aggregate reduce expand contract
    inflate deflate pad align tag untag
    bind unbind link unlink mount unmount dealloc reserve release
    yield probe sample observe poll
    clamp ensure assume invalidate
    reload tune calibrate dim brighten saturate
    desaturate posterize quantize dither rasterize tessellate clip stencil
    composite alpha overlay remap recolor
    try place paint select pick choose decide drop
    chain prepare prep ready arm disarm purge
    is has can should was were did does
    dispatcher handler scanner finder loader saver renderer
    parser formatter converter encoder decoder validator
    inc dec mov xchg cmp
    prompt confirm acknowledge ack reject accept submit
    advance retreat chunk_ flush_
    cycle iterate enumerate traverse walk_ stride
    interpret unpack zoom recompute reapply
    blend tint shade light darken brighten_
    extract index seed plant deposit gather collect aggregate_
    forward_ backward_ wait_for run_
    program configure provision install instruct command order
    sample_ poll_ probe_ inspect snoop watch monitor
    noop nop_ idle_ stall pause_ defer postpone
    plot graph chart paint_ stroke draw_ display_ unmap
    double triple quadruple half quarter expand_ shrink_ scale
    log put record_ archive store_ recall remember forget
""".split())

# Tokens that LOOK like verbs but are too generic — using them alone is not
# enough; need an object.
WEAK_VERBS = frozenset("""
    func sub fn helper util do exec routine method op proc handler thing
""".split())

# Tokens that are nouns (object names).  This is a small whitelist of
# domain-specific nouns; missing nouns are still allowed but flagged
# differently.  We mostly look for "anything that ISN'T in WEAK_NOUNS or
# the chunk-scope prefix list."
WEAK_NOUNS = frozenset("""
    buffer data value state thing
    stuff node element member field
""".split())
# Note: `chunk`, `record`, `slot`, `entry`, `item`, `block`, `segment`,
# `arena`, `pool` removed -- these are domain-concrete in this codebase
# (SAR chunk, player record, NPC slot, save entry, inventory item, ...).
# `buffer` and `data` and `value` and `state` and `thing` stay weak.

# Auto-namer chunk-scope prefixes -- when these appear as the FIRST token,
# they are scope indicators inserted by an earlier auto-naming pass, not
# object descriptors.  E.g. `player_multiply`: "player" is scope (=this
# is in player code), so "multiply" alone must carry the verb+noun load.
# Keep this list tight -- only known auto-namer prefixes; real game-domain
# nouns (town, combat, palette, sprite, ...) stay OUT of this list because
# they DO contribute object meaning.
SCOPE_PREFIXES = frozenset("""
    player pal vga vgadec imgctl imgdec equip stats wizard simg limg
    decb game zr1 zr2 zr3 pf gf gd gt
""".split())

# Tokens that LOOK like nouns but are too generic — `vga_operation` has
# `operation` as a noun, but "operation" doesn't say what operation, so
# it's a NON-noun (placeholder).  These also disqualify a name.
GENERIC_NOUNS = frozenset("""
    operation function routine method handler thing helper util
    feature item entry record stuff state status flag data
""".split())

PROC_RE = re.compile(
    r'^(?P<name>\w+)\s+proc\s+(near|far)\b', re.IGNORECASE,
)
# Data labels: `data_42 db 1`, `data_42 dw ...`, `data_42 dd ...`,
# also `name equ 0xNNh` (named constants).  Skip pure code labels
# (`label:`) -- those are local jump targets where ambiguity is OK.
DATA_RE = re.compile(
    r'^(?P<name>\w+)\s+(?P<kind>db|dw|dd|equ)\b', re.IGNORECASE,
)
NUMBERED_RE = re.compile(r'^(?P<base>.+?)_(?P<num>\d+)$')

# Names that LOOK like data but are domain-meaningful enough to skip:
# all-uppercase short labels (e.g. RET_SENTINEL), single-token names
# that are real domain words (`palette`, `font`, etc.).  The audit
# already filters by token analysis, so this isn't strictly needed;
# kept here as documentation.


# ---------------------------------------------------------------------------
def tokens_of(name: str) -> list[str]:
    """Split snake_case name into lowercase tokens, dropping trailing _N."""
    m = NUMBERED_RE.match(name)
    if m:
        name = m.group('base')
    return [t for t in name.lower().split('_') if t]


def has_verb(toks: list[str]) -> bool:
    """True if any token is a real verb (not weak)."""
    return any(t in VERBS for t in toks)


def has_concrete_noun(toks: list[str]) -> bool:
    """True if any token is a concrete noun (not scope prefix, not generic,
    not in the weak/verb lists, length >= 3 chars)."""
    for t in toks:
        if t in VERBS or t in WEAK_VERBS:
            continue
        if t in SCOPE_PREFIXES:
            continue
        if t in GENERIC_NOUNS:
            continue
        if t in WEAK_NOUNS:
            continue
        if len(t) < 3:
            continue
        return True
    return False


# Words that are domain-meaningful nouns even when short (2 chars).
# These pass the "concrete noun" check for data labels even though they'd
# normally fail the length filter.  A `_fn` suffix means "function pointer",
# `hp` is hit-points, `cr` is carriage-return, `lf` is line-feed, etc.
DOMAIN_SHORTS = frozenset("""
    fn hp mp xp dx dy si di bp bx ax cx
    cr lf nl bs ht ff
    op fg bg ui id ip pc sp
    up dn lo hi
""".split())


def has_domain_token(name: str) -> bool:
    """True if the name has any token suggesting concrete domain meaning,
    even short tokens like `fn` or `hp`.  Used for data labels which are
    often `<scope>_<role>_<type>` where `_type` is a 2-letter shorthand
    (e.g. `_fn` = function pointer, `_hp` = hit points).

    Also accepts any token >= 4 chars not in WEAK_NOUNS / GENERIC_NOUNS
    (more lenient than has_concrete_noun)."""
    toks = name.lower().split('_')
    for t in toks:
        if t in DOMAIN_SHORTS:
            return True
        if len(t) >= 4 and t not in WEAK_NOUNS and t not in GENERIC_NOUNS:
            # 4+ chars and not generic = treat as domain
            return True
        # Short alphabetic tokens that aren't placeholders also count
        if len(t) >= 3 and t.isalpha() and t not in WEAK_NOUNS \
                and t not in GENERIC_NOUNS and t not in WEAK_VERBS:
            return True
    return False


def has_weak_noun_only(toks: list[str]) -> bool:
    """True if the only noun-position token is a weak noun (buffer, data...)."""
    weak_seen = False
    concrete_seen = False
    for t in toks:
        if t in VERBS or t in WEAK_VERBS or t in SCOPE_PREFIXES:
            continue
        if t in GENERIC_NOUNS:
            continue
        if t in WEAK_NOUNS:
            weak_seen = True
        elif len(t) >= 3:
            concrete_seen = True
    return weak_seen and not concrete_seen


def family_size(name: str, all_names_in_file: set[str]) -> int:
    """Count how many `<base>_<N>` siblings + `<base>` exist in the file."""
    m = NUMBERED_RE.match(name)
    if m:
        base = m.group('base')
    else:
        base = name
    count = 1 if base in all_names_in_file else 0
    for n in all_names_in_file:
        if n == name:
            continue
        m2 = NUMBERED_RE.match(n)
        if m2 and m2.group('base') == base:
            count += 1
    return count


def classify(name: str, all_names_in_file: set[str],
             kind: str = 'proc') -> tuple[str, str] | None:
    """Return (class, reason) if name is ambiguous, else None.

    For procs (kind='proc'): require verb + concrete noun.
    For data labels (kind in {'db','dw','dd','equ'}): require concrete
    noun -- data labels don't need a verb since they describe state,
    not action.

    A numbered name like `anim_ptr_0` is flagged as numbered_duplicate
    ONLY when the base (`anim_ptr`) is itself ambiguous.  A concrete-
    base + numeric-index pattern (e.g. `bitplane_0..2` for the 3 EGA
    planes, `anim_ptr_0..6` for 7 animation frames) is meaningful --
    the number IS the index into a real structure, not just an
    auto-namer counter.

    Order of checks (first match wins):
      1. Numbered duplicate WITH ambiguous base -> numbered_duplicate
      2. No verb at all (PROCS only)            -> missing_verb
      3. No concrete noun                       -> missing_object
      4. Only weak noun                         -> weak_object
    """
    toks = tokens_of(name)
    is_data = kind in ('db', 'dw', 'dd', 'equ')

    # 1. Numbered duplicate -- only flag if the base is itself ambiguous.
    # `anim_ptr_0..6` is OK (anim_ptr is concrete); `data_42` is not.
    fam = family_size(name, all_names_in_file)
    if fam >= 2:
        m = NUMBERED_RE.match(name)
        if m:
            base = m.group('base')
            base_toks = base.lower().split('_')
            base_concrete = any(
                t and t not in WEAK_NOUNS and t not in GENERIC_NOUNS
                and t not in SCOPE_PREFIXES and t not in WEAK_VERBS
                and len(t) >= 3
                for t in base_toks
            )
            # Also accept short single-token bases that are real domain
            # words (3+ chars and not in any blacklist) -- e.g. `tile_3`
            # has base `tile` which has 4 chars and is concrete.
            if not base_concrete:
                return ('numbered_duplicate',
                        f'family `{base}` has {fam} siblings -- base '
                        f'is generic, number is the only distinguisher')

    # 2. Missing verb (procs only -- data labels are nouns by nature)
    if not is_data and not has_verb(toks):
        return ('missing_verb',
                f'no action token in `{"_".join(toks)}` -- name is '
                f'noun-only or generic')

    # 3. Missing concrete noun
    if is_data:
        # Data labels: lenient check -- accept any domain-meaningful
        # token (including short shorthands like `_fn`, `_hp`).
        if not has_domain_token(name):
            return ('missing_object',
                    f'data label -- all tokens are generic placeholders '
                    f'(`data_N`, `unk_N`, `tmp_N` style)')
    else:
        # Procs: strict -- need verb + concrete noun.
        if not has_concrete_noun(toks):
            return ('missing_object',
                    f'has verb(s) but no concrete object -- says HOW '
                    f'not WHAT')

    # 4. Verb + only-weak-noun (procs) or weak-noun-only (data)
    if has_weak_noun_only(toks):
        return ('weak_object',
                f'object is a generic container -- which one?')

    return None


def render_report(results: dict) -> str:
    out = []
    out.append('# Name Clarity Audit')
    out.append('')
    out.append("Auto-generated by `name_clarity_audit.py`. Surfaces proc")
    out.append("names that don't communicate purpose.")
    out.append('')
    out.append('**Rule**: every proc name must have at least one VERB and')
    out.append('one CONCRETE NOUN; neither may be a generic placeholder.')
    out.append('')
    out.append('Class meanings:')
    out.append('- `numbered_duplicate` -- `name`, `name_2`, `name_3`, ... '
               'siblings in the same file')
    out.append('- `missing_verb` -- name has no action token '
               '(`vga_operation`, `town_state`)')
    out.append('- `missing_object` -- verb but no concrete noun '
               '(`multiply`, `player_multiply`, `pal_multiply`)')
    out.append('- `weak_object` -- verb + only generic-container noun '
               '(`copy_buffer`, `fill_data`)')
    out.append('')

    total = sum(len(v) for v in results.values())
    by_class: dict[str, int] = defaultdict(int)
    for procs in results.values():
        for _, _, klass, _, _ in procs:
            by_class[klass] += 1

    out.append(f'Total ambiguous procs: **{total}**')
    out.append('')
    out.append('| Class | Count |')
    out.append('|---|---:|')
    for klass in ('numbered_duplicate', 'missing_verb',
                  'missing_object', 'weak_object'):
        out.append(f'| `{klass}` | {by_class[klass]} |')
    out.append('')
    out.append('---')
    out.append('')

    for path in sorted(results.keys()):
        procs = results[path]
        if not procs:
            continue
        rel = path.relative_to(ROOT).as_posix()
        out.append(f'## {rel}  ({len(procs)} ambiguous)')
        out.append('')
        out.append('| Done | Line | Kind | Current name | Class | Reason | '
                   'Proposed name |')
        out.append('|:---:|---:|---|---|---|---|---|')
        # Order within file: numbered_duplicate first, then by line
        order = {'numbered_duplicate': 0, 'missing_verb': 1,
                 'missing_object': 2, 'weak_object': 3}
        sorted_procs = sorted(procs, key=lambda p: (order[p[2]], p[0]))
        for line, name, klass, reason, kind in sorted_procs:
            out.append(f'| [ ] | {line} | `{kind}` | `{name}` | '
                       f'`{klass}` | {reason} | |')
        out.append('')
    return '\n'.join(out)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument('--out', type=Path, default=DEFAULT_OUT)
    ap.add_argument('--filter', default=None,
                    help='only files whose path contains this substring')
    ap.add_argument('--counts', action='store_true',
                    help='print summary only, do not write report')
    ap.add_argument('--class', dest='kclass', default=None,
                    help='filter to one class '
                         '(numbered_duplicate, missing_verb, missing_object, '
                         'weak_object)')
    ap.add_argument('--scope', default='all',
                    choices=('all', 'procs', 'data'),
                    help='which kinds of names to audit '
                         '(default: all = procs + data labels)')
    args = ap.parse_args()

    asm_files = sorted(WORKING.rglob('*.asm'))
    if args.filter:
        asm_files = [f for f in asm_files if args.filter in str(f)]

    results: dict[Path, list] = {}
    want_procs = args.scope in ('all', 'procs')
    want_data = args.scope in ('all', 'data')
    for f in asm_files:
        try:
            text = f.read_text(encoding='utf-8', errors='replace')
        except OSError:
            continue
        items: list[tuple[int, str, str]] = []  # (line, name, kind)
        for ln, line in enumerate(text.splitlines(), start=1):
            if want_procs:
                m = PROC_RE.match(line)
                if m:
                    items.append((ln, m.group('name'), 'proc'))
                    continue
            if want_data:
                m = DATA_RE.match(line)
                if m:
                    name = m.group('name')
                    # Skip the kind keywords themselves (rarely appear at start).
                    if name.lower() in ('db', 'dw', 'dd', 'equ'):
                        continue
                    items.append((ln, name, m.group('kind').lower()))
        names = {n for _, n, _ in items}
        ambig = []
        for line, name, kind in items:
            verdict = classify(name, names, kind)
            if verdict:
                klass, reason = verdict
                if args.kclass and klass != args.kclass:
                    continue
                ambig.append((line, name, klass, reason, kind))
        if ambig:
            results[f] = ambig

    if args.counts:
        total = sum(len(v) for v in results.values())
        by_class: dict[str, int] = defaultdict(int)
        for procs in results.values():
            for _, _, klass, _, _ in procs:
                by_class[klass] += 1
        print(f'Total ambiguous procs: {total}')
        print(f'Files with ambiguous names: {len(results)}')
        for k in ('numbered_duplicate', 'missing_verb',
                  'missing_object', 'weak_object'):
            print(f'  {k}: {by_class[k]}')
        return 0

    md = render_report(results)
    args.out.write_text(md, encoding='utf-8')
    print(f'Wrote {args.out}')
    print(f'Files: {len(results)}, ambiguous procs: '
          f'{sum(len(v) for v in results.values())}')
    return 0


if __name__ == '__main__':
    sys.exit(main())
