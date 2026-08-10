#!/usr/bin/env python3
"""Exact-release behavioral oracles for every EGA display procedure.

The earlier non-MCGA test only pinned binary membership and procedure
boundaries.  This test actually executes each reviewed procedure entry from
the MASM release images.  Three deterministic machine states exercise empty,
normal, and edge-shaped inputs.  The oracle fingerprint includes control
flow, register/flag results, non-stack writes, interrupts, and EGA port I/O.

The base driver is loaded at CS:2000 and an overlay at CS:2FFC, matching the
original loader (the overlay's four-byte SAR prefix consequently ends at
CS:3000).  Calls between the overlay and base driver therefore execute the
same release bytes they reach in DOS.  Calls outside those images are stopped
at the service boundary and included in the fingerprint.
"""

from __future__ import annotations

import csv
import hashlib
import json
import struct
import sys
from pathlib import Path

from unicorn import (
    UC_ARCH_X86,
    UC_HOOK_CODE,
    UC_HOOK_INTR,
    UC_HOOK_MEM_WRITE,
    UC_MODE_16,
    UC_PROT_ALL,
    Uc,
    UcError,
)
from unicorn.x86_const import (
    UC_X86_REG_AX,
    UC_X86_REG_BP,
    UC_X86_REG_BX,
    UC_X86_REG_CS,
    UC_X86_REG_CX,
    UC_X86_REG_DI,
    UC_X86_REG_DS,
    UC_X86_REG_DX,
    UC_X86_REG_EFLAGS,
    UC_X86_REG_ES,
    UC_X86_REG_IP,
    UC_X86_REG_SI,
    UC_X86_REG_SP,
    UC_X86_REG_SS,
)


HERE = Path(__file__).resolve().parent
MASM_ROOT = HERE.parents[1]
COVERAGE = MASM_ROOT / "functest" / "coverage.csv"

CODE_SEG = 0x1000
STACK_SEG = 0x8000
VGA_SEG = 0xA000
BASE_LOAD = 0x2000
OVERLAY_LOAD = 0x2FFC
RET_SENTINEL = 0x0080
MAX_STEPS = 4096

ADAPTER_NAME = "EGA"
EXPECTED_COUNT = 104
BASE_CHUNK = "gmega"
BASE_BIN = MASM_ROOT / "bin" / "gmega.bin"
OVERLAYS = {
    "101GDEGA": MASM_ROOT / "bin" / "zelres1" / "101GDEGA.bin",
    "107GTEGA": MASM_ROOT / "bin" / "zelres1" / "107GTEGA.bin",
    "202GFEGA": MASM_ROOT / "bin" / "zelres2" / "202GFEGA.bin",
}
CHUNKS = {BASE_CHUNK, *OVERLAYS}
ORIGINAL_GAME = MASM_ROOT.parents[1] / "1_OriginalGame"

EXPECTED_BINARY_SHA256 = {
    "gmega": "631d531060464c2e7d8139d63f11628715de6ba8d5ad49e07dad96db4c7cce0b",
    "101GDEGA": "178858b48a3cc02002e3f54b4ded22607fcd176c22a9d1ee8bfa8aea403eef5e",
    "107GTEGA": "94ee7f8145aa7c5ed63e81730ee15b7534e03b94e0af96c80e9e18179f67f2cc",
    "202GFEGA": "e21f0d27d45f3772f81b9f6e75a578e82a49d89a70b314ff697bd9ecf75d71c9",
}

# These are deliberately small dimensions: they let row/column loops execute
# real work without allowing malformed fixture data to turn into a long wait.
SCENARIOS = (
    {"ax": 0x0000, "bx": 0x0000, "cx": 0x0101, "dx": 0x03CE,
     "si": 0x8100, "di": 0x0100, "bp": 0x8200, "flags": 0x0002},
    {"ax": 0x0001, "bx": 0x0203, "cx": 0x0203, "dx": 0x03C4,
     "si": 0x8400, "di": 0x0200, "bp": 0x8500, "flags": 0x0043},
    {"ax": 0x0002, "bx": 0x0101, "cx": 0x0102, "dx": 0x03CE,
     "si": 0xFF00, "di": 0xFF00, "bp": 0xFE00, "flags": 0x0082},
)

# Reviewed fingerprints emitted from the exact binaries above.  A fingerprint
# is an aggregate of all three scenarios, not a static slice of procedure
# bytes.  Keep this map explicit so a changed emulator path cannot bless
# itself at test time.
EXPECTED_PROCEDURE_FINGERPRINTS: dict[str, str] = {
    "101GDEGA:blit_2plane_scroll_ega": "ae7d5da45e429ca20ca85c9045ce88eb4a3b69f195f83c0e54cc68c2217becfc",
    "101GDEGA:blit_2plane_sprite_ega": "42b24c88506afbc61dd2414ce4fd7993280b1000d7c11e9f12a560120f87ed40",
    "101GDEGA:blit_3plane_scroll_ega": "fecacaf415330cae873a3dd4fafc890fb66fbc1f28f4ec3353bef6842be86742",
    "101GDEGA:blit_via_di_ega": "e90c37215886a0961835dbc9ef944c5325e8c5771e1a68ed69107a0929367dba",
    "101GDEGA:compute_tile_vram_offset_ega": "a4e03efefdaa6c0cb92e7c98def67c8c36ae8d2de852889d94a657dc7023d806",
    "101GDEGA:copy_32_words_ega": "56f4c5a1bea95d5a13b82943d77c2011cb3ce9b0d31c216d9defcd79d6b81296",
    "101GDEGA:copy_buf_with_plane_select_ega": "153afb1d5982b1ed4a2468c4dd622fd5bf0080e83f09fa3963dc0951ecf3b734",
    "101GDEGA:copy_si_to_es_di_ega": "6369e54db65991dd620d8af419dcb39c362b4ce537b469c59fa1e74d5dd12a46",
    "101GDEGA:copy_to_di_ega": "7adc0942a9cbf353d97714ce7c67d32a1111c2e5d66139684862c554eac9f980",
    "101GDEGA:copy_with_plane_1_alt_ega": "76c987e8dc1fe4b8b752ce75010d13b49bb177e0381e8529b69bbe5359ab5dd8",
    "101GDEGA:copy_with_plane_1_ega": "6cd2529845a967855bc2ab09f184bbcd473df4f9dd000ce85400149be3eb8287",
    "101GDEGA:decode_scroll_byte_ega": "57d8396c4559279761a5ad7e4be7e99f0623c97e4e61788dec9d9aa59fd63a0e",
    "101GDEGA:draw_border_top_bottom_ega": "046403e0b3264aea812bde22649852f98436d711ba35b6e3f82a685196895a0a",
    "101GDEGA:fill_plane_via_dma_ega": "4e95df402c84bc005a4faec3c600c0ad62d22e38f21346be46c6136fdc3ea34f",
    "101GDEGA:fill_status_byte_24x_ega": "c5fcc57c4b179009500786615829caffda8ede41d0a2db00491fdeb3cd6cbd31",
    "101GDEGA:fill_with_pattern_3F_ega": "312891fba725d7506d7c8b5aed6f6056a8795f8d7535c4af95a0d4d0621f6ced",
    "101GDEGA:lookup_palette_entry_ega": "68dd84d4da2e66901be220fae8bbc2d8bde1d017befb33938a7bca07ea84109e",
    "101GDEGA:mask_write_loop_ega": "58f9ea1715b8cd20427ca20d2248e8783031e23058f19b4e4c3def2e005e3486",
    "101GDEGA:program_grfx_FF_then_zero_ega": "48eb680d1fded457b899a8fa5e8fd8ba6802f497aaffb549b53770325256838e",
    "101GDEGA:program_seq_map_mask_ega": "034a36d9f947df690dc3c7bd6e2f36fa5f45f39c0e0de4a86704b93af32ad4ed",
    "101GDEGA:run_imgctl_main_ega": "10a9ed35d04b7ace3f2ac69d89134ada4a88ba0235d29fee796c38f9227b31de",
    "101GDEGA:run_render_passes_ega": "7655e3092125ffb1e24a091ce08759dd24286c74e801098c14b950f446c2c9f4",
    "101GDEGA:seed_status_pattern_ega": "5ec5a518bfeb44cf63bb624e4435855b5f5aa944a7a7afac44f748ea29aabc1a",
    "107GTEGA:compute_col_decrement_ega": "19c0c2a72e7d056b49055b2b551c0a5ef7ee0a07a916dbdfbd2b544d17298f1b",
    "107GTEGA:compute_glyph_index_ega": "7518a0253567ff0d9a58f433f6530395acae8c0147997fb7caf3bec3c9ee9641",
    "107GTEGA:decode_entity_slot_byte_ega": "97ff4fdde0473623158cf5f77a514025dc655343a8ab7dc94a60b6c24d98461b",
    "107GTEGA:div_16bit_emit_digit_alt_ega": "40b4dc57d729aa1b8ad0fa5db554285d91de4cba99894bdd77e6b4921cf29206",
    "107GTEGA:div_16bit_emit_digit_ega": "070cfc84f12739adde31f202b86742c78ae2ae1a8a4ee145e436995ead602a57",
    "107GTEGA:div_24bit_emit_digit_ega": "33fba7e1e59f4d5d849224a6f328500275f33c9ee8973165dd2a458fcb219af0",
    "107GTEGA:init_4E_loop_ega": "5e459432b003c44630dcadb98733ed6cf654b492f6e00b63ca10823ff206deff",
    "107GTEGA:init_text_render_buf_ega": "b49aed99c6e8de494e84596ccade695619b33c725123502f9b89a983843581b5",
    "107GTEGA:load_tile_list_ptr_ega": "5f0b899da1d2759f8b48ebc8d892922e2cfbcf3d321c49fde81157cf4a311f7b",
    "107GTEGA:load_tile_list_then_use_ega": "0edabf36138dc4037e6c1faf3ad2bbcd5686acaac5dbe6189d59309b8bec6c31",
    "107GTEGA:mark_tile_FE_ega": "0d569f14ff246c35c97e83bef1205e18ce53d16574a5030728a58b8b8f75c266",
    "107GTEGA:match_tile_by_dx_ega": "cf0060460b55c28423f32e2ad51165e20c7bc16521a97900d9d74342661a3dc5",
    "107GTEGA:render_2_col_iter_ega": "4445b48891aa38cec54eeb2edc0785c3236aab4f205e94c5058c3da922aa617a",
    "107GTEGA:render_3_tile_cols_ega": "c9d851d56f6f2c992005396dabc370c6fdb2ef5489f190662d9a4f5826d266f6",
    "107GTEGA:render_tile_entry_ega": "97fe410e8582eca5d7da11816f1b79bb77528dcd7a48f23c540d281f7bdb4499",
    "107GTEGA:render_tile_if_marked_ega": "c5857c8d32847941f85eea98fa125bbd4918d405510d59921f86ff4e956ad467",
    "107GTEGA:render_via_proc_loop2_ega": "84537e6a949544a2cc3f1db98a612d88d89ddcc38bcd20314ef9ce5e4dc6548c",
    "107GTEGA:run_gtega_main": "57dfba2d1eb67bec9de1d56b97c6b9a4ef701ffee0391773daf7cfbb820adc4b",
    "107GTEGA:run_render_passes_gtega": "5fb4d4cf982bfa79f99d5ad7c38d148724a2359b116a650708d12959ee00e66f",
    "107GTEGA:save_state_then_blit_ega": "c91eb3a44db56b75b1bf0f4a38e2e604b6d1bfd46bdf432b375e48060446157a",
    "107GTEGA:set_cx_6_ega": "6140444658e5c547f8d1482a9ccb04ebabca88d12ca1ad5ffbf4c09e92833bb2",
    "107GTEGA:set_es_to_vga_ega": "2e9e796724afa383e5ee72ac08bc7b2e390d29c44333cb91c4a77aab9ff78333",
    "107GTEGA:set_seq_map_mask_7_ega": "818f57f544eefd5bd8be9713327f5da1c4379e18714ecaa1e630a60259386d80",
    "107GTEGA:step_text_char_loop2_ega": "9f3ea8ec710b11a3a891b91fec9222a6bb60c55ca383d66d9d6d64772b7d7e7b",
    "107GTEGA:step_text_char_loop_ega": "439b4031c0fc8d56e7293f95188c2edc8ac5ab8ab9c4c43f01c56af05a03d433",
    "107GTEGA:tile_col6_render": "3e4aac5425e8dec7f87688183aa3177863406d4bde9025983423902b8a4ac324",
    "202GFEGA:ega_3plane_copy": "9c528f14c31bea21d0ca61de9d64182638d2c16b7e5498c8d55c13c2bcd39943",
    "202GFEGA:ega_bg_tile_blit": "1ae5cb579bc4c3314e05ff6ce8dcbb95be81f7eaf1ff9731c4a369d96a9b70ea",
    "202GFEGA:ega_blit_2bytes_8rows": "41ce37454045b1c7fd12c4318495acc2420632fcededccf6e0bbfe9c5271d9f7",
    "202GFEGA:ega_clear_16bytes": "4ecd3ce24f58a71b42623e8623438d9aedfce33f97c661efe137c740ed8646ac",
    "202GFEGA:ega_clear_pixel_pair": "83e4118b0823cc14a976421dd933fb2833efa878e29d03357a7c630accfd232f",
    "202GFEGA:ega_col_write_loop": "45f5387f3a77bf0d460438427cf32f2a42b5c52467e4acd3ea2bb8b9d535ab09",
    "202GFEGA:ega_fade_blit": "41ca7b1c725dbe14ea400fff49712f2d8501226689afa72d9bcb49d95eb1bcde",
    "202GFEGA:ega_fill_bit_range": "43db4dcffc6aed00d14266bdd64d4e2873de3b6b59d315cdf3b1ec082e99b4a4",
    "202GFEGA:ega_fill_bit_range_wide": "8814cc52f26e479eb71fc25307d16215e6b62db22f0e9444404390d9411a8840",
    "202GFEGA:ega_plane_write_2row": "b584327f75a58a471d0b5d7263512298f7c27b3f132a63cda1fc6bb85aa5357f",
    "202GFEGA:ega_row_addr_calc": "c4251fe9ce3da6838c777743caa401b545c633154f89f2d60ec57a8cd6ffb81c",
    "202GFEGA:ega_sprite_blit": "51280078e7a034a44917baf694220b2f868d278a982def699d5dc592f00a3a94",
    "202GFEGA:ega_sprite_blit_ex": "9bdee9b4fa33d3d66e335aa234b92a71fba01c6bf894fe7ff6f8255fe724f2c5",
    "202GFEGA:ega_sprite_render_blended": "aa46a6405473aa84825a56bc9dc27fcbf40f7b596f8703f8d8011d051dffb68f",
    "202GFEGA:ega_sprite_render_solid": "a71731c231b04774bcb199f8db426522f0b62bd0892bbbf2d6e49dea88cf8388",
    "202GFEGA:ega_tile_anim_update": "468263770f04aefbb16b42ecc41070dfcefbb29569a4748f5e3c6693d17800ca",
    "202GFEGA:fade_gradient_loop": "175b423b8b94af4651decd902d9bfc2214bafd9ac07450ad92bce8fcf44cb1b9",
    "202GFEGA:frame_wait_loop": "35a63c238542f39ccff2cd6e37465e0bca7b56ffcb769e40eda27bb8a012773f",
    "202GFEGA:hero_sprite_col_blit": "1f6cfe353465a868b483cdb12e42e5ea79dc047070600cdb0727492c130a064e",
    "202GFEGA:hero_tier_get": "377d310c8609dab6b3a2f5a5c7ac3c63cc5bbeb75fac97484af54cc8ceb57683",
    "202GFEGA:phase_ptr_advance": "8d732f67d7d7c58529e1fa2132ace59ef6d43d7d8bf83632c24bc2e49f313a33",
    "202GFEGA:projectile_spawn_check": "9510073c3554f306656e2cda6ee83f09a6f4d67323fa3b161db99ebfffc07625",
    "202GFEGA:render_frame_rows": "1a9c8d67be02e3574c1cba82320d7b33d355d0e7616dcc2b30d90e8335befd27",
    "202GFEGA:restore_background_pixels": "a3dc459dcf36359010ed3c1361fb4a1de7ce713be1f46e268500b20e70bc6ef4",
    "202GFEGA:restore_background_pixels_impl": "68930fea08da2fd52f98f84ff593377fea63fae476d2f9f9a02560043a944030",
    "202GFEGA:run_gfega_main": "d27594b6619f40c494474dbc03d814dc081d963e75e119f589208733a36a648f",
    "202GFEGA:save_background_pixels": "0ace82351c9859098de6dff104dd1c53d60d8b15cfea28bc2b3912fb75065101",
    "202GFEGA:scroll_cache_invalidate": "33e526b9d83da6ad3d6da3ddd6e0ab62a1241c7c2ac17342e4f069d41b97da2b",
    "202GFEGA:scroll_pos_load": "60299480e9131ebbbdb39b910d7443629af9e8bfd0d95c650e18a92cc15acb47",
    "202GFEGA:sprite_blit_dispatch": "eb8bc8d23f99c800d1d6b4c36d990b2e6b371daf7d6e75c96f0b35ddf93c6f81",
    "202GFEGA:sprite_cell_render": "4e69c47b22bbca9a312b937029f58bbe8cd9f31eeb2df8d3faee7225101cfeaa",
    "202GFEGA:sprite_get_value": "532d1ddabf46c56d3f1a3eb3b1bc4adf341220c36054cec407640d11c0caeeea",
    "202GFEGA:sprite_slot_init": "5ff1e68ea001e82cc823fadfd5a58f4bd15340686f93527f0e5528dc81c9d72d",
    "202GFEGA:sprite_src_setup": "bc1a3c3264596a4b2ed821bd5d03aa5ff5c4ec1acac693ddcf0855f2008cac39",
    "202GFEGA:sprite_state_update": "ea60a417a6ff97dbbd57ddccd0e6da8050551da0192cce28f5a1f0ff93228358",
    "202GFEGA:sprite_wide_row_render": "f0dd72dd2273485342b1586b46ea771bc16361d9e2d2838f7276508e8cf5222e",
    "202GFEGA:step_sprite_pos_pair": "f25ec7feff102dc56aea92288ee2f92115f64d613790fa24ade48695b1517b6f",
    "202GFEGA:tile_blit_3x3": "b37b939e94bd7153d7fb3bbb05b683361f548b8b5c10546e4bcd74057e4adffd",
    "202GFEGA:wrap_scroll_si_low": "69e575adc6cc0bb74e4359908257ed69910d001fd2340b7117e51c6bc084f99e",
    "gmega:calc_text_width": "939f9ec34b9afa8bd463d32b7304b8187b999dc59d5f320db36c0451a17fe472",
    "gmega:clear_screen": "25ab2b02d69bdd84d50cd712fbe952eb7f44a9460e840a1e4b3fe5a127a6bf1a",
    "gmega:convert_time_to_bcd": "b6bbd8adc7c3276a23b315e464c6fbd1165b004f31995cbf6e03bbd2bd58b898",
    "gmega:decode_bitplane_tile": "c020f25ac2a3d7e63ebca1b010c04dfea4d2355dbc8b3c928c7c2d027a29cc81",
    "gmega:fill_horizontal_line": "c96d609a87f153abde73a0bc66216dcba0d38b6c6e7a46ac21fcce7a4f085061",
    "gmega:fill_rectangle": "01d7094b5c9045010020ea47dc811097df61728f02fc29c7899604190ec855c4",
    "gmega:fill_vertical_line": "aca55e2925003a4450c5cae45bdb45c3a26a44b30059c6258f7c17b4b6967d0a",
    "gmega:init_timestamp": "5a080f5af2a677ac831528f45cf29fdbeab796c724301431e2416ff33142f278",
    "gmega:int_divide_bcd": "91a3469ea4b332d463108a8961254e25fe161fa3515a74dcc91ee50b3108fa6f",
    "gmega:modulo_divide_bcd": "e918c78586776d060cc21d8016dd4d0f761aa912e22e8705ea4efeb1fd6565fb",
    "gmega:plot_pixel": "ea495875c142c240abab2ac844b86f597c20eb644180ec9f736da05772dbeb38",
    "gmega:render_text_char": "297c05c95b17b793cdf113b941c40ee8ac1927eada79e9045694998456daf821",
    "gmega:render_text_char_alt": "3cbaa54b991236f5317123ff6ec1d6a7105181b357afec3fb5403e395aa1856c",
    "gmega:render_tilemap_large": "c0c5fed02961afbf2f20d8300544ac5091701e86fa25769c1fd1a7c997bf60c9",
    "gmega:render_tilemap_small": "d47c19c8b59d705e3e4fa90b3d495e6e227112933cf791ab1773917f445dd794",
    "gmega:run_gmega_main": "7f5bd5be89996b9845bc06e51f23adb014e8d8dfaa8d027127210323202eecf2",
}


def release_image(chunk: str, generated: Path) -> bytes:
    """Load an exact image in both local-build and clean-checkout contexts."""
    if generated.exists():
        return generated.read_bytes()
    if chunk.startswith(("gmcga", "gmega", "gmhgc", "gmtga")):
        return (ORIGINAL_GAME / f"{chunk}.bin").read_bytes()
    archive = int(chunk[0])
    index = int(chunk[1:3])
    sar = (ORIGINAL_GAME / f"zelres{archive}.sar").read_bytes()
    start = struct.unpack_from("<I", sar, index * 4)[0]
    size = struct.unpack_from("<I", sar, start)[0]
    image = sar[start:start + 4 + size]
    if len(image) != 4 + size:
        raise AssertionError(f"short release image for {chunk}")
    return image

REGISTERS = {
    "ax": UC_X86_REG_AX,
    "bx": UC_X86_REG_BX,
    "cx": UC_X86_REG_CX,
    "dx": UC_X86_REG_DX,
    "si": UC_X86_REG_SI,
    "di": UC_X86_REG_DI,
    "bp": UC_X86_REG_BP,
}


def patterned(size: int, mul: int, add: int) -> bytes:
    return bytes((index * mul + add) & 0xFF for index in range(size))


CODE_PATTERNS = tuple(patterned(0x10000, 37, 11 + i * 29)
                      for i in range(len(SCENARIOS)))
VGA_PATTERNS = tuple(patterned(0x10000, 53, 7 + i * 31)
                     for i in range(len(SCENARIOS)))


def load_rows() -> list[dict[str, str]]:
    with COVERAGE.open(newline="", encoding="utf-8") as source:
        rows = [row for row in csv.DictReader(source) if row["chunk"] in CHUNKS]
    return sorted(rows, key=lambda row: (row["chunk"], int(row["entry_addr"], 0)))


def resolve_entry(row: dict[str, str], image: bytes) -> int:
    entry = int(row["entry_addr"], 0)
    if entry:
        load = BASE_LOAD if row["chunk"] == BASE_CHUNK else OVERLAY_LOAD
        return load + entry

    # The broad run_* procs own dispatch-table data as well as executable
    # dispatch code.  Enter the real dispatcher rather than decoding its table
    # as instructions.  Base drivers have a 35-word table; overlays store the
    # first absolute dispatch target immediately after the four-byte SAR size.
    if row["chunk"] == BASE_CHUNK:
        return BASE_LOAD + 35 * 2
    return int.from_bytes(image[4:6], "little")


def execute_scenario(row: dict[str, str], scenario_index: int,
                     base_image: bytes, overlay_image: bytes | None) -> dict:
    scenario = SCENARIOS[scenario_index]
    mu = Uc(UC_ARCH_X86, UC_MODE_16)
    mu.mem_map(0, 0x110000, UC_PROT_ALL)
    code_linear = CODE_SEG << 4
    stack_linear = STACK_SEG << 4
    mu.mem_write(code_linear, CODE_PATTERNS[scenario_index])
    mu.mem_write(VGA_SEG << 4, VGA_PATTERNS[scenario_index])
    mu.mem_write(code_linear + BASE_LOAD, base_image)
    allowed = [(BASE_LOAD, BASE_LOAD + len(base_image))]
    image = base_image
    if overlay_image is not None:
        mu.mem_write(code_linear + OVERLAY_LOAD, overlay_image)
        allowed.append((OVERLAY_LOAD, OVERLAY_LOAD + len(overlay_image)))
        image = overlay_image

    entry = resolve_entry(row, image)
    mu.reg_write(UC_X86_REG_CS, CODE_SEG)
    mu.reg_write(UC_X86_REG_DS, CODE_SEG)
    mu.reg_write(UC_X86_REG_ES, VGA_SEG)
    mu.reg_write(UC_X86_REG_SS, STACK_SEG)
    mu.reg_write(UC_X86_REG_SP, 0xFFF8)
    mu.mem_write(stack_linear + 0xFFF8,
                 bytes((RET_SENTINEL, 0, CODE_SEG & 0xFF, CODE_SEG >> 8)))
    for name, register in REGISTERS.items():
        mu.reg_write(register, scenario[name])
    mu.reg_write(UC_X86_REG_EFLAGS, scenario["flags"])

    state: dict[str, object] = {
        "trace": [], "writes": [], "ports": [], "interrupts": [],
        "reason": None,
    }

    def in_loaded_image(ip: int) -> bool:
        return any(start <= ip < end for start, end in allowed)

    def code_hook(uc, address, size, _user):
        ip = uc.reg_read(UC_X86_REG_IP) & 0xFFFF
        if ip == RET_SENTINEL:
            state["reason"] = "returned"
            uc.emu_stop()
            return
        if not in_loaded_image(ip):
            state["reason"] = f"service:{ip:04x}"
            uc.emu_stop()
            return
        state["trace"].append(ip)
        opcode = bytes(uc.mem_read(address, min(size, 2)))
        dx = uc.reg_read(UC_X86_REG_DX) & 0xFFFF
        ax = uc.reg_read(UC_X86_REG_AX) & 0xFFFF
        if opcode[0] == 0xEE:
            state["ports"].append((dx, ax & 0xFF, 1))
        elif opcode[0] == 0xEF:
            state["ports"].append((dx, ax, 2))
        elif len(opcode) > 1 and opcode[0] == 0xE6:
            state["ports"].append((opcode[1], ax & 0xFF, 1))
        elif len(opcode) > 1 and opcode[0] == 0xE7:
            state["ports"].append((opcode[1], ax, 2))

    def write_hook(_uc, _access, address, size, value, _user):
        if stack_linear <= address < stack_linear + 0x10000:
            return
        state["writes"].append((address, size, value & ((1 << (size * 8)) - 1)))

    def interrupt_hook(uc, intno, _user):
        state["interrupts"].append(intno)
        state["reason"] = f"interrupt:{intno:02x}"
        uc.emu_stop()

    mu.hook_add(UC_HOOK_CODE, code_hook)
    mu.hook_add(UC_HOOK_MEM_WRITE, write_hook)
    mu.hook_add(UC_HOOK_INTR, interrupt_hook)
    try:
        mu.emu_start(code_linear + entry, 0, count=MAX_STEPS)
    except UcError as error:
        state["reason"] = f"uc-error:{error.errno}"
    if state["reason"] is None:
        state["reason"] = "instruction-limit"

    state["registers"] = {
        name: mu.reg_read(register) & 0xFFFF
        for name, register in REGISTERS.items()
    }
    state["registers"]["sp"] = mu.reg_read(UC_X86_REG_SP) & 0xFFFF
    state["registers"]["ip"] = mu.reg_read(UC_X86_REG_IP) & 0xFFFF
    state["registers"]["flags"] = mu.reg_read(UC_X86_REG_EFLAGS) & 0xFFFF
    return state


def procedure_fingerprint(row: dict[str, str], base_image: bytes,
                          overlay_image: bytes | None) -> tuple[str, list[dict]]:
    results = [execute_scenario(row, index, base_image, overlay_image)
               for index in range(len(SCENARIOS))]
    encoded = json.dumps(results, sort_keys=True, separators=(",", ":")).encode()
    return hashlib.sha256(encoded).hexdigest(), results


def main() -> int:
    emit = "--emit" in sys.argv[1:]
    failures: list[str] = []
    base_image = release_image(BASE_CHUNK, BASE_BIN)
    images = {BASE_CHUNK: base_image, **{
        chunk: release_image(chunk, path) for chunk, path in OVERLAYS.items()
    }}
    for chunk, expected in EXPECTED_BINARY_SHA256.items():
        actual = hashlib.sha256(images[chunk]).hexdigest()
        if actual != expected:
            failures.append(f"{chunk}: release SHA-256 mismatch")

    rows = load_rows()
    if len(rows) != EXPECTED_COUNT:
        failures.append(
            f"coverage inventory: expected {EXPECTED_COUNT} rows, got {len(rows)}")

    actual_fingerprints: dict[str, str] = {}
    for row in rows:
        chunk = row["chunk"]
        overlay = None if chunk == BASE_CHUNK else images[chunk]
        actual, results = procedure_fingerprint(row, base_image, overlay)
        key = f"{chunk}:{row['name']}"
        actual_fingerprints[key] = actual
        if any(not result["trace"] for result in results):
            failures.append(f"{key}: a scenario executed no release instructions")
        expected = EXPECTED_PROCEDURE_FINGERPRINTS.get(key)
        if not emit and actual != expected:
            failures.append(f"{key}: {actual} != {expected or 'missing'}")

    if emit:
        print(json.dumps(actual_fingerprints, indent=4, sort_keys=True))
        print(f"VERDICT: PASS: emitted {ADAPTER_NAME} behavioral fingerprints")
        return 0

    extra = set(EXPECTED_PROCEDURE_FINGERPRINTS) - set(actual_fingerprints)
    if extra:
        failures.append("stale expected entries: " + ", ".join(sorted(extra)))

    adapter = ADAPTER_NAME.lower()
    print(f"{adapter}_behavioral_procedures: {len(rows)}/{EXPECTED_COUNT}")
    print(f"{adapter}_behavioral_scenarios: {len(rows) * len(SCENARIOS)}")
    if failures:
        for failure in failures:
            print("FAIL: " + failure)
        print(f"VERDICT: FAIL: {ADAPTER_NAME} procedure behavior differs from MASM release")
        return 1
    print(f"VERDICT: PASS: all {ADAPTER_NAME} procedures match exact MASM behavior")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
