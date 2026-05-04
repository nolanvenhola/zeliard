#!/usr/bin/env python3
"""
save_diff.py — empirical byte-level analysis across all .USR save files.

Loads every save file in 3_Assembly/tasm/bin/*.usr, then reports:
  1. Which byte offsets are CONSTANT across all saves (header/padding/checksum).
  2. Which byte offsets VARY (game state — candidates for naming).
  3. For each varying offset: list of (value, save_name) so patterns are visible
     (monotonic = level/cavern index; sparse 0/FFh = boolean; etc.).
  4. Optional: pairwise diff between two named saves.

Usage:
  python save_diff.py                 # full report
  python save_diff.py --varying       # show only varying offsets
  python save_diff.py --pair A B      # byte diff between two saves
"""
import sys
import argparse
from pathlib import Path
from collections import defaultdict


SAVE_DIR = Path(__file__).parent / "bin"


def load_saves():
    """Returns dict: name -> bytes (256 bytes each)."""
    saves = {}
    for p in sorted(SAVE_DIR.glob("*.[Uu][Ss][Rr]")):
        data = p.read_bytes()
        saves[p.stem] = data
    return saves


def constant_vs_varying(saves):
    """For each byte offset 0..255, compute the set of distinct values seen.
    Returns dict: offset -> sorted list of (value, [save_names])."""
    if not saves:
        return {}
    n = max(len(d) for d in saves.values())
    per_offset = {}
    for offset in range(n):
        buckets = defaultdict(list)
        for name, data in saves.items():
            if offset < len(data):
                buckets[data[offset]].append(name)
        per_offset[offset] = sorted(buckets.items())
    return per_offset


def report(saves, per_offset, only_varying=False):
    constant = []
    varying = []
    for offset, buckets in sorted(per_offset.items()):
        if len(buckets) == 1:
            (val, _names), = buckets
            constant.append((offset, val))
        else:
            varying.append((offset, buckets))

    print(f"=== {len(saves)} saves loaded ===")
    print(f"Constant offsets : {len(constant)} / 256")
    print(f"Varying offsets  : {len(varying)} / 256")
    print()

    if not only_varying:
        print("=== CONSTANT BYTES (same in all saves) ===")
        # Group consecutive equal-value runs for compactness
        i = 0
        while i < len(constant):
            j = i
            val = constant[i][1]
            while j + 1 < len(constant) and constant[j + 1][0] == constant[j][0] + 1 and constant[j + 1][1] == val:
                j += 1
            if j > i:
                print(f"  0x{constant[i][0]:02X}..0x{constant[j][0]:02X}  =  0x{val:02X}  ({j - i + 1} bytes)")
            else:
                print(f"  0x{constant[i][0]:02X}              =  0x{val:02X}")
            i = j + 1
        print()

    print("=== VARYING BYTES (state — candidates for naming) ===")
    for offset, buckets in varying:
        # Format: 0xNN: count distinct values, list each value with up to 4 save names
        n_vals = len(buckets)
        print(f"  0x{offset:02X}  ({n_vals} distinct value{'s' if n_vals > 1 else ''}):")
        for val, names in buckets:
            preview = ", ".join(sorted(names)[:6])
            extra = f" +{len(names) - 6} more" if len(names) > 6 else ""
            print(f"      0x{val:02X}  ({len(names):2d}x)  {preview}{extra}")
    print()


def pair_diff(saves, name_a, name_b):
    if name_a not in saves:
        print(f"ERROR: save '{name_a}' not found. Available: {', '.join(saves.keys())}")
        return
    if name_b not in saves:
        print(f"ERROR: save '{name_b}' not found. Available: {', '.join(saves.keys())}")
        return
    a = saves[name_a]
    b = saves[name_b]
    n = min(len(a), len(b))
    print(f"=== {name_a} vs {name_b} ===")
    diffs = 0
    for offset in range(n):
        if a[offset] != b[offset]:
            print(f"  0x{offset:02X}:  0x{a[offset]:02X}  ->  0x{b[offset]:02X}    "
                  f"(decimal {a[offset]:3d} -> {b[offset]:3d})")
            diffs += 1
    print(f"\nTotal: {diffs} differing bytes out of {n}")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--varying", action="store_true", help="show only varying offsets")
    ap.add_argument("--pair", nargs=2, metavar=("A", "B"), help="diff two named saves")
    args = ap.parse_args()

    saves = load_saves()
    if not saves:
        print(f"No save files found in {SAVE_DIR}")
        return 1

    if args.pair:
        pair_diff(saves, args.pair[0], args.pair[1])
        return 0

    per_offset = constant_vs_varying(saves)
    report(saves, per_offset, only_varying=args.varying)
    return 0


if __name__ == "__main__":
    sys.exit(main())
