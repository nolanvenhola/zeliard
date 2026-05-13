"""Find repeated 3+ instruction sequences inside each .asm — candidates for macro factoring.

Reports per-file top-5 candidates by (occurrences * length).  Comments are
stripped.  Operands kept verbatim (no canonicalization), so identical
sequences match exactly.
"""
from __future__ import annotations
import re
import sys
from collections import Counter, defaultdict
from pathlib import Path

ROOT = Path(__file__).parent / "working"
DIRS = ["core", "drivers", "zelres1/code", "zelres2/code", "zelres3/code"]

INSTR_RE = re.compile(r"^\s+([a-z][a-z0-9]*)(\s+([^;]*?))?(\s*;.*)?$", re.IGNORECASE)
LABEL_RE = re.compile(r"^[A-Za-z_][\w]*\s*:")
DATA_RE = re.compile(r"^\s+(d[bwd]|equ|label|proc|endp|segment|ends|target|include|page|assume|public|extrn|macro|endm|ifdef|endif|else|else_if|seg_a)\b", re.IGNORECASE)


def extract_instr_stream(path: Path) -> list[tuple[int, str]]:
    """Returns list of (line_no, normalized_instruction) keeping only mnemonic+operands."""
    out = []
    for n, raw in enumerate(path.read_text(encoding="utf-8", errors="replace").splitlines(), 1):
        line = raw.rstrip()
        if not line or line.lstrip().startswith(";"):
            continue
        if LABEL_RE.match(line.lstrip()):
            continue
        if DATA_RE.match(line):
            continue
        m = INSTR_RE.match(line)
        if not m:
            continue
        mnemonic = m.group(1).lower()
        ops = (m.group(3) or "").strip().rstrip(",")
        # Normalize whitespace inside operands
        ops = re.sub(r"\s+", " ", ops)
        out.append((n, f"{mnemonic} {ops}".strip()))
    return out


def find_repeats(stream: list[tuple[int, str]], window: int = 3, min_count: int = 3) -> list[tuple[tuple[str, ...], int, list[int]]]:
    """Find sequences of `window` instructions repeated >= min_count times."""
    seqs: dict[tuple[str, ...], list[int]] = defaultdict(list)
    for i in range(len(stream) - window + 1):
        seq = tuple(stream[i + j][1] for j in range(window))
        seqs[seq].append(stream[i][0])
    results = [(seq, len(lines), lines) for seq, lines in seqs.items() if len(lines) >= min_count]
    results.sort(key=lambda r: r[1], reverse=True)
    return results


def main():
    overall: list[tuple[Path, list]] = []
    for d in DIRS:
        for asm in sorted((ROOT / d).glob("*.asm")):
            stream = extract_instr_stream(asm)
            if len(stream) < 30:
                continue
            for win in (5, 4, 3):
                hits = find_repeats(stream, window=win, min_count=4)
                if hits:
                    overall.append((asm, win, hits[:3]))
                    break

    overall.sort(key=lambda r: r[2][0][1] * r[1], reverse=True)
    print(f"{'File':<40} {'Win':>3} {'Count':>5} {'Score':>5}  Sample sequence")
    print("-" * 110)
    for asm, win, hits in overall[:30]:
        seq, count, lines = hits[0]
        score = count * win
        sample = " ; ".join(seq)
        if len(sample) > 60:
            sample = sample[:57] + "..."
        rel = str(asm.relative_to(ROOT))
        print(f"{rel:<40} {win:>3} {count:>5} {score:>5}  {sample}")
    print(f"\n{len(overall)} files have a repeating window-N sequence with count >= 4")


if __name__ == "__main__":
    main()
