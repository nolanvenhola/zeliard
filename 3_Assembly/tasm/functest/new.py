#!/usr/bin/env python3
"""new.py — stamp a fresh proc_equivalence test from the template.

Usage:
  python new.py <chunk> <hex_addr> [--name <short>] [--hyp '<one liner>']

Example:
  python new.py fight 0x91E5 --name move_monster_E_probe \
      --hyp "function reads [SI+3] and branches on <34"

Looks up the chunk's load_base from fixtures.BIN_PATHS, finds the
proc-equivalence dir, and stamps a new test file under it.  The new
file is editable — the template provides scaffolding, you fill in the
probes.
"""
import argparse
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
from fixtures import BIN_PATHS  # noqa: E402

TEMPLATE = HERE / '_template_proc_equivalence.py.tmpl'


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument('chunk', help='chunk key (one of: ' + ', '.join(BIN_PATHS) + ')')
    ap.add_argument('addr',  help='function entry address, e.g. 0x91E5')
    ap.add_argument('--name', default=None,
                    help='short name suffix (default: derived from addr)')
    ap.add_argument('--hyp',  default='(no static hypothesis yet)',
                    help='one-line hypothesis (IDA-derived or other)')
    ap.add_argument('--cat', default='proc_equivalence',
                    choices=('placeholder_id', 'proc_equivalence', 'regression'),
                    help='which category dir to drop the test into')
    args = ap.parse_args()

    if args.chunk not in BIN_PATHS:
        print(f'unknown chunk {args.chunk!r}; known: {list(BIN_PATHS)}')
        return 1
    addr = int(args.addr, 16)
    short = args.name or f'{addr:04X}'
    short = short.lstrip('_').replace('-', '_')
    fname = f'test_{args.chunk}_{short}.py'
    out = HERE / args.cat / fname
    if out.exists():
        print(f'exists: {out}')
        return 1

    tmpl = TEMPLATE.read_text(encoding='utf8')
    body = (tmpl
            .replace('{TEST_FILENAME}', fname)
            .replace('{ONE_LINE_PURPOSE}',
                     f'Probe of {args.chunk}.bin function at 0x{addr:04X}')
            .replace('{HYPOTHESIS}', args.hyp)
            .replace('{PROBE_A_DESCRIPTION}', 'TODO — describe probe A')
            .replace('{PROBE_B_DESCRIPTION}', 'TODO — describe probe B')
            .replace('{PROBE_C_DESCRIPTION}', 'TODO — describe probe C')
            .replace('{CHUNK_KEY}', args.chunk)
            .replace('{FUNC_ADDR:04X}', f'{addr:04X}'))
    out.write_text(body, encoding='utf8')
    print(f'created: {out.relative_to(HERE.parent)}')
    print('next: edit the probes and run via `python run.py --filter ' + fname + '`')
    return 0


if __name__ == '__main__':
    sys.exit(main())
