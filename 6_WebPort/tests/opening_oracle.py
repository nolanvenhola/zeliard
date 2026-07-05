#!/usr/bin/env python3
"""Opening/title oracle scenarios for the Zeliard web port."""

from __future__ import annotations

import hashlib
import json
from dataclasses import dataclass
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
ASSET_ROOT = REPO / "6_WebPort" / "engine" / "assets"
PALETTE_ROWS = REPO / "3_Assembly" / "dumps" / "palette_rows.json"
TITLE_FULL_CAPTURE = REPO / "3_Assembly" / "dumps" / "zeliard_title_image.BIN"
WIDTH, HEIGHT = 320, 200


@dataclass(frozen=True)
class ImageScenario:
    name: str
    source: str
    asset: str
    rows: int
    cl: int
    x: int
    y: int
    pipeline: str


IMAGE_SCENARIOS = [
    ImageScenario("ttl3_logo_bbox", "100OPDMO title logo draw", "ttl3.grp",
                  65, 112, 28, 15, "grp_abc"),
    ImageScenario("nec_scene_bbox", "100OPDMO NEC scene draw", "nec.grp",
                  44, 104, 72, 32, "img_open_gfx_draw"),
    ImageScenario("hou_overlay_bbox", "100OPDMO HOU overlay draw", "hou.grp",
                  16, 64, 128, 72, "img_open_gfx_draw"),
    ImageScenario("dmaou_scene_bbox", "100OPDMO DMAOU scene draw", "dmaou.grp",
                  34, 112, 92, 32, "img_open_gfx_draw"),
]


def sha256_hex(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def fnv1a64_hex(data: bytes) -> str:
    h = 0xCBF29CE484222325
    for b in data:
        h ^= b
        h = (h * 0x100000001B3) & 0xFFFFFFFFFFFFFFFF
    return f"{h:016x}"


def fill_buffer_decompress(file_data: bytes) -> bytes:
    if len(file_data) < 5:
        raise ValueError("fill_buffer input too small")
    chunk_size = int.from_bytes(file_data[:4], "little")
    flag = file_data[4]
    if flag == 0:
        avail = max(chunk_size - 1, 0)
        buf = file_data[5:5 + avail]
    else:
        if len(file_data) < 9:
            raise ValueError("multi-section fill_buffer input too small")
        skip = int.from_bytes(file_data[5:7], "little")
        read_size = int.from_bytes(file_data[7:9], "little")
        start = 9 + skip
        buf = file_data[start:start + read_size]
    if not buf:
        raise ValueError("empty fill_buffer payload")
    opcode = buf[0] & 7
    data = buf[1:]

    def method1(data: bytes) -> bytes:
        tbl_end = data.find(b"\xff")
        if tbl_end < 0:
            tbl_end = len(data)
        si = tbl_end + 1 if tbl_end < len(data) else tbl_end
        out = bytearray()
        while si < len(data):
            al = data[si]
            si += 1
            count, value = 1, al
            for p in range(0, tbl_end - 1, 2):
                key = data[p]
                if key & 0x0F:
                    break
                if (al & 0xF0) == key:
                    count, value = (al & 0x0F) + 2, data[p + 1]
                    break
            out.extend([value] * count)
        return bytes(out)

    def method2(data: bytes) -> bytes:
        marker, si, out = data[0], 1, bytearray()
        while si < len(data):
            al = data[si]
            si += 1
            count = 1
            if (al & 0xF0) == marker and si < len(data):
                count, al = (al & 0x0F) + 3, data[si]
                si += 1
            out.extend([al] * count)
        return bytes(out)

    def method3(data: bytes) -> bytes:
        tbl_end = data.find(b"\xff")
        if tbl_end < 0:
            tbl_end = len(data)
        si = tbl_end + 1 if tbl_end < len(data) else tbl_end
        out = bytearray()
        while si < len(data):
            al = data[si]
            si += 1
            count, value = 1, al
            for p in range(0, tbl_end - 1, 2):
                key = data[p]
                if key & 0xF0:
                    break
                if (al & 0x0F) == key:
                    count, value = (al >> 4) + 2, data[p + 1]
                    break
            out.extend([value] * count)
        return bytes(out)

    def method4(data: bytes) -> bytes:
        marker, si, out = data[0], 1, bytearray()
        while si < len(data):
            al = data[si]
            si += 1
            count = 1
            if (al & 0x0F) == marker and si < len(data):
                count, al = (al >> 4) + 3, data[si]
                si += 1
            out.extend([al] * count)
        return bytes(out)

    def method5(data: bytes) -> bytes:
        si, out = 0, bytearray()
        while si < len(data):
            al, count = data[si], 1
            if si + 1 < len(data) and data[si + 1] == al:
                if si + 2 < len(data):
                    count = data[si + 2] + 2
                    si += 2
                else:
                    si += 1
            si += 1
            out.extend([al] * count)
        return bytes(out)

    def method6(data: bytes) -> bytes:
        table, si = {}, 0
        while si + 1 < len(data):
            key, value = data[si], data[si + 1]
            si += 2
            if key == 0xFF and value == 0xFF:
                break
            table[key] = value
        out = bytearray()
        while si < len(data):
            b = data[si]
            si += 1
            if b in table and si < len(data):
                out.extend([table[b]] * (data[si] + 2))
                si += 1
            else:
                out.append(b)
        return bytes(out)

    def method7(data: bytes) -> bytes:
        escape, si, out = data[0], 1, bytearray()
        while si < len(data):
            b = data[si]
            si += 1
            if b == escape and si + 1 < len(data):
                value, count = data[si], data[si + 1] + 3
                si += 2
                out.extend([value] * count)
            else:
                out.append(b)
        return bytes(out)

    methods = [
        lambda d: d, method1, method2, method3,
        method4, method5, method6, method7,
    ]
    return methods[opcode](data)


def decode_6de1(src: bytes) -> bytes:
    out, i = bytearray(), 0
    while i < len(src):
        b = src[i]
        if b & 0x40:
            if i + 1 >= len(src):
                break
            word = (b << 8) | src[i + 1]
            i += 2
            if word == 0xFFFF:
                break
            count = word & 0x3FFF
            if word & 0x8000:
                if i < len(src):
                    out.extend([src[i]] * count)
                    i += 1
            else:
                out.extend(src[i:i + count])
                i += count
        else:
            count = b & 0x3F
            i += 1
            if b & 0x80:
                if i < len(src):
                    out.extend([src[i]] * count)
                    i += 1
            else:
                out.extend(src[i:i + count])
                i += count
    return bytes(out)


def decode_img_open_payload(src: bytes, rows: int, cl: int) -> bytes:
    ctrl_count = int.from_bytes(src[:2], "little")
    ctrl_i, lit_i, out = 2, 2 + ctrl_count, bytearray()
    for _ in range(ctrl_count):
        ctrl = src[ctrl_i]
        ctrl_i += 1
        for bit in range(7, -1, -1):
            if ctrl & (1 << bit):
                out.append(src[lit_i] if lit_i < len(src) else 0)
                lit_i += 1
            else:
                out.append(0)
    dh = 0
    for i, value in enumerate(out):
        decoded = 0
        for shift in (6, 4, 2, 0):
            pair = ((value >> shift) & 3) ^ dh
            dh = pair
            decoded |= pair << shift
        out[i] = decoded
    return bytes(out)


def _emit_interleave(planes: list[int]) -> bytes:
    out = bytearray()
    for _ in range(4):
        pw, acc = list(planes), 0
        for _ in range(2):
            for _ in range(2):
                for j in range(4):
                    msb = pw[j] >> 15
                    pw[j] = ((pw[j] << 1) & 0xFFFF) | msb
                    acc = ((acc << 1) | msb) & 0xFFFF
        planes = pw
        swapped = ((acc & 0xFF) << 8) | (acc >> 8)
        out.extend([swapped & 0xFF, swapped >> 8])
    return bytes(out)


def interleave_abc(src: bytes, rows: int, cl: int) -> bytes:
    bp, out = rows * cl, bytearray()
    if bp * 2 > len(src):
        raise ValueError("abc interleave source too small")
    for si in range(0, bp, 2):
        ax = (src[si] << 8) | src[si + 1]
        bi = bp + si
        bx = (src[bi] << 8) | src[bi + 1]
        dx = (~(bx & ax)) & 0xFFFF
        out.extend(_emit_interleave([(bx | ax) & 0xFFFF, bx & dx, ax & dx, 0]))
    return bytes(out)


def interleave_gfx_draw(src: bytes, rows: int, cl: int) -> bytes:
    bp, out = rows * cl, bytearray()
    if bp * 2 > len(src):
        raise ValueError("gfx interleave source too small")
    for si in range(0, bp, 2):
        ax = (src[si] << 8) | src[si + 1]
        bi = bp + si
        bx = (src[bi] << 8) | src[bi + 1]
        out.extend(_emit_interleave([bx, 0, 0, ax]))
    return bytes(out)


def render_8pass(interleaved: bytes, rows: int, cl: int) -> bytes:
    mask1 = [0x80, 0x20, 0x08, 0x02, 0x40, 0x10, 0x04, 0x01]
    mask2 = [0x01, 0x04, 0x10, 0x40, 0x02, 0x08, 0x20, 0x80]

    def wp(mask: int) -> int:
        bl = mask
        for s in range(8):
            cf = (bl >> 7) & 1
            bl = ((bl << 1) & 0xFF) | cf
            if cf:
                return s
        return -1

    width, height = rows * 4, cl
    out = bytearray(width * height)
    m1p, m2p = [wp(v) for v in mask1], [wp(v) for v in mask2]
    for start_k in range(8):
        k = start_k
        for n in range(height):
            pos = m2p[k & 7] if n & 1 else m1p[k & 7]
            row = n * width
            for i in range(width):
                if (i & 7) == pos:
                    idx = row + i
                    if idx < len(interleaved):
                        out[idx] |= interleaved[idx]
            k += 1
    return bytes(out)


def decode_image_scenario(scenario: ImageScenario) -> tuple[bytes, int, int]:
    raw = (ASSET_ROOT / scenario.asset).read_bytes()
    if scenario.pipeline == "grp_abc":
        planes = decode_6de1(fill_buffer_decompress(raw))
        interleaved = interleave_abc(planes, scenario.rows, scenario.cl)
    elif scenario.pipeline == "img_open_gfx_draw":
        payload = fill_buffer_decompress(raw)
        planes = decode_img_open_payload(payload, scenario.rows, scenario.cl)
        interleaved = interleave_gfx_draw(planes, scenario.rows, scenario.cl)
    else:
        raise ValueError(f"unknown pipeline {scenario.pipeline}")
    return render_8pass(interleaved, scenario.rows, scenario.cl), scenario.rows * 4, scenario.cl


def place_in_framebuffer(image: bytes, width: int, height: int, x: int, y: int) -> bytes:
    fb = bytearray(WIDTH * HEIGHT)
    for yy in range(height):
        dy = y + yy
        if dy >= HEIGHT:
            break
        for xx in range(width):
            dx = x + xx
            if dx >= WIDTH:
                break
            value = image[yy * width + xx]
            if value:
                fb[dy * WIDTH + dx] = value
    return bytes(fb)


def palette_bytes(name: str) -> bytes:
    rows = json.loads(PALETTE_ROWS.read_text(encoding="utf8"))
    return bytes(component for row in rows[name] for rgb in row for component in rgb)


def compute_manifest() -> dict:
    scenarios = []
    for scenario in IMAGE_SCENARIOS:
        image, width, height = decode_image_scenario(scenario)
        fb = place_in_framebuffer(image, width, height, scenario.x, scenario.y)
        scenarios.append({
            "name": scenario.name,
            "source": scenario.source,
            "asset": scenario.asset,
            "pipeline": scenario.pipeline,
            "rows": scenario.rows,
            "cl": scenario.cl,
            "x": scenario.x,
            "y": scenario.y,
            "width": width,
            "height": height,
            "image_sha256": sha256_hex(image),
            "image_fnv1a64": fnv1a64_hex(image),
            "framebuffer_sha256": sha256_hex(fb),
            "framebuffer_fnv1a64": fnv1a64_hex(fb),
        })

    nec = IMAGE_SCENARIOS[1]
    hou = IMAGE_SCENARIOS[2]
    nec_image, nec_w, nec_h = decode_image_scenario(nec)
    hou_image, hou_w, hou_h = decode_image_scenario(hou)
    composite = bytearray(place_in_framebuffer(nec_image, nec_w, nec_h, nec.x, nec.y))
    for y in range(hou_h):
        dy = hou.y + y
        if dy < 0 or dy >= 200:
            continue
        for x in range(hou_w):
            dx = hou.x + x
            if dx < 0 or dx >= 320:
                continue
            value = hou_image[y * hou_w + x]
            if value:
                composite[dy * 320 + dx] = value
    scenarios.append({
        "name": "opening_nec_hou_composite",
        "source": "100OPDMO NEC scene with HOU overlay before DMAOU",
        "base": "nec_scene_bbox",
        "overlay": "hou_overlay_bbox",
        "framebuffer_sha256": sha256_hex(bytes(composite)),
        "framebuffer_fnv1a64": fnv1a64_hex(bytes(composite)),
    })
    scene_sprite_c = [1, 1, 1, 2, 2, 1, 1, 2, 2, 3, 3, 5]
    scenarios.append({
        "name": "opening_scene_sprite_c_events",
        "source": "100OPDMO scene_sprite_loop over scene_sprite_c",
        "raw_bytes": scene_sprite_c + [0],
        "display_al": [value - 1 for value in scene_sprite_c],
        "bx": "1720",
        "delay_al": "14",
    })
    scenarios.append({
        "name": "opening_scene_sprite_b_summary",
        "source": "100OPDMO scene_after_anim through scene_sprite_b before Jashiin speech",
        "script_bytes_consumed": 136,
        "chapter2_call_count": 38,
        "glyph_count": 88,
        "chapter4_draw_call_count": 176,
        "script_wait_count": 91,
        "orchestrator_wait_al": ["F0", "F0", "0F", "F0"],
        "explicit_chapter2_al": [2, 3],
        "explicit_chapter2_bx": "1720",
        "final_si": "911E",
    })
    scenarios.append({
        "name": "opening_title_asset_reload",
        "source": "100OPDMO Jashiin speech and title asset reload block before int60",
        "jashiin_speech": {"al": 0, "bx": "0094", "cx": "501E"},
        "sar": [
            {"asset": "ttl1.grp", "al": 2, "di": "A000", "es_delta": "0000"},
            {"asset": "ttl2.grp", "al": 2, "di": "A000", "es_delta": "0000"},
            {"asset": "ttl3.grp", "al": 2, "di": "B000", "es_delta": "0000"},
            {"asset": "zopn.msd", "al": 5, "di": "3000", "es_delta": "0000"},
        ],
        "decode_rle_to_es_di": {"si": "A000", "di": "4000"},
        "gfx_mode": {"bx": "1720", "cx": "2270"},
        "palette_ax": 4,
    })
    scenarios.append({
        "name": "opening_title_display_handoff",
        "source": "100OPDMO title display handoff from int60 setup through scene_sprite_d dispatch",
        "int60_setup": {"ax": 0, "si": "3000", "ds_delta": "0000"},
        "driver_call_count": 1,
        "wait_al": ["F0", "F0", "F0"],
        "gfx_update": {
            "al": 0,
            "bx": "0B48",
            "cx": "3180",
            "di": "4000",
            "es_delta": "0000",
        },
        "decode_rle_to_es_di": [
            {"si": "B000", "di": "4000"},
            {"si": "A000", "di": "4000"},
        ],
        "disp_narr_chap3": {"bx": "070F", "cx": "4170", "di": "4000"},
        "disp_narr_open_si": "912B",
    })
    scenarios.append({
        "name": "opening_title_color_exit",
        "source": "100OPDMO color rotation loop and gfx-enabled exit poll before opening_next_scene",
        "iterations": 100,
        "disp_set_call_count": 200,
        "wait_count": 100,
        "wait_al": "50",
        "first_disp_set_al": ["C7", "00", "C5", "02", "C3", "04"],
        "final_disp_set_al": ["05", "C2", "03", "C4", "01", "C6"],
        "interrupt_cascade_count": 1,
        "stick_handler_call_count": 4,
        "exits_to_game": True,
    })
    scenarios.append({
        "name": "opening_next_scene",
        "source": "100OPDMO opening_next_scene through credits_scroll_display dispatch",
        "scene_mode": 8,
        "gfx_mode": {"al": "FF", "bx": "0000", "cx": "50C8"},
        "gfx_init_count": 1,
        "sar": {"asset": "zend.msd", "al": 5, "di": "3000", "es_delta": "0000"},
        "int60_setup": {"ax": 0, "si": "3000", "di": "3000", "ds_delta": "0000"},
        "clears_input": True,
        "palette_ax": 1,
        "credits_call_count": 1,
    })
    scenarios.append({
        "name": "opening_trans_exit",
        "source": "100OPDMO trans_exit handoff into post_title_story_scenes",
        "scene_mode": 8,
        "gfx_init_count": 1,
        "clears_input": True,
        "reaches_post_title_story": True,
    })
    scenarios.extend([
        {
            "name": "maop_reveal_step_00",
            "source": "100OPDMO wait_story_scene_timer_start first disp_load_setup frame",
            "frame": "OPENING_DEBUG_LATE_MAOP_REVEAL_STEP_00",
            "framebuffer_fnv1a64": "f367db99ee55cc05",
        },
        {
            "name": "maop_reveal_step_12",
            "source": "100OPDMO wait_story_scene_timer_start midpoint disp_load_setup frame",
            "frame": "OPENING_DEBUG_LATE_MAOP_REVEAL_STEP_12",
            "framebuffer_fnv1a64": "f367db99ee55cc05",
        },
        {
            "name": "split_return_reveal_step_12",
            "source": "100OPDMO gameplay_input_loop midpoint disp_load_setup frame",
            "frame": "OPENING_DEBUG_LATE_SPLIT_RETURN_STEP_12",
            "framebuffer_fnv1a64": "51ffa7473f81fefb",
        },
        {
            "name": "final_yuu3_yuu4_composite",
            "source": "100OPDMO yuu3/yuu4 merge_gfx_planes plus xor_mask_render final frame",
            "frame": "OPENING_DEBUG_LATE_FINAL_YUU3_YUU4",
            "framebuffer_fnv1a64": "92d8ad4d7c4c1f7f",
        },
    ])

    title_palette = palette_bytes("P2_Title")
    title_fb = TITLE_FULL_CAPTURE.read_bytes()
    if len(title_fb) != WIDTH * HEIGHT:
        raise ValueError(f"{TITLE_FULL_CAPTURE} is {len(title_fb)} bytes, expected {WIDTH * HEIGHT}")
    scenarios.append({
        "name": "title_palette_state",
        "source": "captured P2_Title DAC rows",
        "palette": "P2_Title",
        "bytes": len(title_palette),
        "palette_sha256": sha256_hex(title_palette),
        "palette_fnv1a64": fnv1a64_hex(title_palette),
    })
    scenarios.append({
        "name": "initial_title_screen",
        "source": "captured full title/copyright framebuffer",
        "expected_scene": "opening",
        "expected_phase": "copyright_title_card",
        "bytes": len(title_fb),
        "framebuffer_sha256": sha256_hex(title_fb),
        "framebuffer_fnv1a64": fnv1a64_hex(title_fb),
        "palette_sha256": sha256_hex(title_palette),
        "palette_fnv1a64": fnv1a64_hex(title_palette),
    })
    scenarios.append({
        "name": "copyright_input_ignored",
        "source": "copyright card receives ENTER/SPACE before the MASM input wait",
        "start_scene": "opening",
        "start_phase": "copyright_title_card",
        "input": "ENTER",
        "expected_scene": "opening",
        "expected_phase": "copyright_title_card",
        "framebuffer_sha256": sha256_hex(title_fb),
        "framebuffer_fnv1a64": fnv1a64_hex(title_fb),
    })
    scenarios.append({
        "name": "copyright_timer_starts_prologue",
        "source": "copyright/title card completes and advances into the amulet ancient-history prologue",
        "start_scene": "opening",
        "start_phase": "copyright_title_card",
        "duration_ms": 3470,
        "expected_scene": "opening",
        "expected_phase": "amulet_ancient_prologue_scroll",
    })
    game_handoff_fb = bytes(WIDTH * HEIGHT)
    scenarios.append({
        "name": "opening_input_exit_to_game",
        "source": "opening demo receives ENTER/SPACE and reaches game handoff",
        "start_scene": "opening",
        "input": "ENTER",
        "expected_scene": "game_handoff",
        "framebuffer_fnv1a64": fnv1a64_hex(game_handoff_fb),
    })
    return {
        "version": 1,
        "description": "Opening/title oracle scenarios for the Zeliard web port.",
        "scenarios": scenarios,
    }


def scenario_by_name(manifest: dict) -> dict[str, dict]:
    return {item["name"]: item for item in manifest["scenarios"]}
