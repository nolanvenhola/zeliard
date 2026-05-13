#!/usr/bin/env python3
"""
Parity test: title logo renderer (ttl3.grp).

Validates the GRP decode pipeline by running the canonical Python
reference (2_SAR/Tools/grp_view2.py) and comparing its byte-level
output against the DOSBox-captured golden framebuffer at
3_Assembly/dumps/zeliard_title_image.BIN.

The C port at 6_WebPort/engine/load/grp.c is a transliteration of the
Python pipeline; if the Python output matches the golden, the C output
should match too (verified separately by browser inspection of the
WASM build).

Failure modes this catches:
  - decode_6de1 emits wrong byte counts (RLE bug)
  - interleave_4plane scrambles pixel bits
  - render_8pass_blit uses wrong mask table or wrong call_size/blit_calls
  - placement offset wrong (col != 28 or row != 15)

Usage:
  python tests/parity_title_image.py
"""
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(REPO / '2_SAR' / 'Tools'))
from grp_view2 import _detect_and_strip_header, decode_6de1, interleave_4plane  # noqa: E402

GRP_PATH    = REPO / '3_Assembly' / 'tasm' / 'working' / 'zelres1' / 'data' / '131TTL3G.grp'
GOLDEN_PATH = REPO / '3_Assembly' / 'dumps' / 'zeliard_title_image.BIN'

W, H = 320, 200
TTL3_ROWS, TTL3_CL = 65, 112
PLACEMENT_X, PLACEMENT_Y = 28, 15


def render_via_python(grp_bytes: bytes) -> tuple[bytes, int, int]:
    """Return the rendered 260x112 paletted byte image."""
    payload = _detect_and_strip_header(grp_bytes)
    decoded = decode_6de1(payload)
    interleaved = interleave_4plane(decoded, TTL3_ROWS, TTL3_CL)

    mask1 = [0x80, 0x20, 0x08, 0x02, 0x40, 0x10, 0x04, 0x01]
    mask2 = [0x01, 0x04, 0x10, 0x40, 0x02, 0x08, 0x20, 0x80]

    def _wp(M):
        bl = M
        for s in range(8):
            cf = (bl >> 7) & 1
            bl = ((bl << 1) & 0xFF) | cf
            if cf:
                return s
        return -1

    call_size = TTL3_ROWS * 4   # 260
    blit_calls = TTL3_CL        # 112
    m1p = [_wp(mask1[k]) for k in range(8)]
    m2p = [_wp(mask2[k]) for k in range(8)]

    vga = bytearray(call_size * blit_calls)
    for start_k in range(8):
        k = start_k
        for n in range(blit_calls):
            wp = m1p[k % 8] if n % 2 == 0 else m2p[k % 8]
            for i in range(call_size):
                if i % 8 == wp:
                    src_idx = n * call_size + i
                    if src_idx < len(interleaved):
                        vga[src_idx] |= interleaved[src_idx]
            k += 1
    return bytes(vga), call_size, blit_calls


def place_in_framebuffer(image: bytes, w: int, h: int) -> bytes:
    fb = bytearray(W * H)
    for y in range(h):
        if PLACEMENT_Y + y >= H:
            break
        for x in range(w):
            if PLACEMENT_X + x >= W:
                break
            fb[(PLACEMENT_Y + y) * W + (PLACEMENT_X + x)] = image[y * w + x]
    return bytes(fb)


def bbox_diff(a: bytes, b: bytes, x: int, y: int, w: int, h: int) -> dict:
    """Diff only the rectangle (x,y,w,h) — used to constrain the parity test
    to the title-logo region, since ttl3.grp only owns that bbox.  Credits
    text below the logo is rendered separately by credits_scroll_display
    (100OPDMO.asm:692) and isn't part of this GRP."""
    diffs = 0
    samples: list = []
    total = w * h
    for yy in range(h):
        for xx in range(w):
            i = (y + yy) * W + (x + xx)
            if a[i] != b[i]:
                diffs += 1
                if len(samples) < 5:
                    samples.append((i, y + yy, x + xx, a[i], b[i]))
    return {
        'total': total,
        'matches': total - diffs,
        'diffs': diffs,
        'pct_match': (total - diffs) / total * 100 if total else 100.0,
        'samples': samples,
    }


def main():
    if not GRP_PATH.exists():
        print(f'FAIL: missing {GRP_PATH}')
        return 1
    if not GOLDEN_PATH.exists():
        print(f'FAIL: missing {GOLDEN_PATH}')
        return 1

    grp = GRP_PATH.read_bytes()
    golden = GOLDEN_PATH.read_bytes()
    print(f'grp:    {len(grp)} bytes  ({GRP_PATH.relative_to(REPO)})')
    print(f'golden: {len(golden)} bytes  ({GOLDEN_PATH.relative_to(REPO)})')

    img, w, h = render_via_python(grp)
    print(f'rendered image: {w}x{h} = {len(img)} bytes')

    rendered_fb = place_in_framebuffer(img, w, h)
    # Scope the parity check to the title-logo bbox (260x112 at (28, 15)).
    # The full framebuffer also contains credits/menu text rendered by
    # other procs which aren't part of ttl3.grp.
    summary = bbox_diff(rendered_fb, golden, PLACEMENT_X, PLACEMENT_Y, w, h)

    print(f'\nlogo-bbox parity: {summary["matches"]}/{summary["total"]} matching ({summary["pct_match"]:.2f}%)')
    print(f'                  {summary["diffs"]} differing bytes')
    if summary['diffs'] > 0:
        print('\nfirst 5 differences:')
        for offset, row, col, got, want in summary['samples']:
            print(f'  fb[{offset:5d}] row={row:3d} col={col:3d}: got=0x{got:02X} want=0x{want:02X}')
        return 1
    print('\nPASS — title-logo decode is byte-perfect vs DOSBox capture')
    return 0


if __name__ == '__main__':
    sys.exit(main())
