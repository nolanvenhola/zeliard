#!/usr/bin/env python3
"""Exact-release behavioral oracles for every CGA display procedure.

This configures the reviewed display-procedure VM used by the EGA suite with
the original CGA base driver, dungeon/town/fight overlays, B800 framebuffer,
and independently pinned behavioral fingerprints.
"""

from __future__ import annotations

import test_ega_display_procedure_oracle as oracle


oracle.ADAPTER_NAME = "CGA"
oracle.EXPECTED_COUNT = 107
oracle.VGA_SEG = 0xB800
oracle.BASE_CHUNK = "gmcga"
oracle.BASE_BIN = oracle.MASM_ROOT / "bin" / "gmcga.bin"
oracle.OVERLAYS = {
    "102GDCGA": oracle.MASM_ROOT / "bin" / "zelres1" / "102GDCGA.bin",
    "108GTCGA": oracle.MASM_ROOT / "bin" / "zelres1" / "108GTCGA.bin",
    "203GFCGA": oracle.MASM_ROOT / "bin" / "zelres2" / "203GFCGA.bin",
}
oracle.CHUNKS = {oracle.BASE_CHUNK, *oracle.OVERLAYS}
oracle.EXPECTED_BINARY_SHA256 = {
    "gmcga": "53d0b58ab3dfc965fa4355008a66ed0d6a6bce4cd45a3dedbcaea2d54b67e415",
    "102GDCGA": "5f15f3c5ccf7c25ee6b1d6d736ec690b0311ab88c4ee384cf81a2b925f4075e3",
    "108GTCGA": "f66a392090f4b20a9316596efe7a0eebced1e0ab9406ce95f406fbd9c07d4a31",
    "203GFCGA": "5b2211763ca0d179b23ca5f50d47794c235319ad86b06da1efc7bf6efbe4505d",
}

oracle.EXPECTED_PROCEDURE_FINGERPRINTS = {
    "102GDCGA:blit_sprite_cga": "74264dccb3c41d2de8046bde036a2d2b71565bed37eaadb00c3a7297d85624e9",
    "102GDCGA:blit_sprite_clipped_cga": "d8a07de9fb73aa6ae1a87fa3cff7f0fcde31d92cb12ecd1f970c6549837884b3",
    "102GDCGA:build_pixel_pair_cga": "2a48881d6c93b135345559b5da5aecbb2355ae4fe58da3cd6326caba6b1a455b",
    "102GDCGA:clear_status_buf_rows_cga": "6ad64709f47126915b03b3a51474870220c17391cb345d16eeb733115d19265f",
    "102GDCGA:compute_tile_vram_offset_cga": "fe2f099976e0c15facd5accaddabad048cf354872bfe86cef83cda4671e2ce24",
    "102GDCGA:copy_pixel_row_cga": "2234c39001d2f1d35ab3f7c27af404f2e6d9c9ae92d35fb66f2bfb4c291dfa9a",
    "102GDCGA:copy_status_loop_cga": "0983b8f8e73e244a24f0c77461a51b0631882326676c48829e0f323db0389a53",
    "102GDCGA:copy_to_di_cga": "9f98d74aa353cfe771e06a1568f18b32932927f7988308a52fc7d8def133e749",
    "102GDCGA:extract_pixel_bits_cga": "81dc41fc5e1e5e08a892e1e692e74f050461ba62ea2246b0e76d1dd71abc3c06",
    "102GDCGA:extract_pixel_pair_alt_cga": "41bcfd48203364c1e485627675d0a18b87b9f069c9a3eec6b295a808bf395264",
    "102GDCGA:extract_pixel_pair_cga": "82a4ffa53d897498942ee4065aea41a038795bd7876c2e58163fea84ab1ca0c1",
    "102GDCGA:fill_status_byte_24x_cga": "73b99493f6df43a14c415677c0e87f3e8eab6b290e5fc9a0d19a4f2c7d6d8f96",
    "102GDCGA:init_status_buf_cga": "873a79a260cf4c640d86ca6ab9b0e0dae1fcea2eda2a381fbc8b6d342a4e7cbe",
    "102GDCGA:init_status_row_11_cga": "819df8781f2410cd41c7960626cba18808afb1e1dc7b3caccb79e0c3a88d5bb8",
    "102GDCGA:init_status_row_28_cga": "18bac6599cd1e4748cf46f6cb97a1f7195c37fdd4aede16b6b91e9287cc179ea",
    "102GDCGA:run_imgctl_main_cga": "55a9fc3e606bc80d7f501167fc50dbc7298e8d6155fd6f1e287a8bbb2320b48c",
    "102GDCGA:run_render_passes_cga": "8a165078778b268757d8604f3bee4903cf251eda4a96e1d718cb7cfe6495fbc9",
    "102GDCGA:seed_status_pattern_cga": "f63cf61d40d00c87ad523fc95d3fce9ca3e956ddeee24c84ef304d10e949b070",
    "102GDCGA:write_status_pattern_0_cga": "9c36b589271d66306948bd0704b3ee7fa57fcad43787577dd0deab3b893fcf68",
    "108GTCGA:bcd_extract_div": "e9155a343b481316949f780c7b084f7139f8f65f40a3e332897db5a8033bc0df",
    "108GTCGA:bcd_extract_sub": "a0dd72d40b59024212365e9319f1244888650f75b75600e6200bea7b7c19c022",
    "108GTCGA:blend_tile_planes": "d716431b08f95a04c2a7b31bf089a07824e791f105a7ec67d24fcd5b12b2d32d",
    "108GTCGA:blit_3rows_to_cga": "5c8d2c837e8fd463b679f2c780668f9e1bb2a1ea3c086eda23e332855f61e51c",
    "108GTCGA:calc_tile_cga_ofs": "60c78c29844abaa84b940cceead3c03b066b46d8b70465e3b2a07826c07d8127",
    "108GTCGA:cga_check_blit_col": "b269c7fe69f4110b17a3027a31975c5834085466ba487a6d672b9559167c8c5d",
    "108GTCGA:convert_time_bcd": "8d4cb8f473213ddfd5acb7a4a1bf5292fdfb79e558ff1dedeb7157bbdb284b9e",
    "108GTCGA:dispatch_via_tbl_a_cga": "866af4fe91066cf0d4a67099613e9528d99583fcca9cf04db15cbff5e3e1546d",
    "108GTCGA:draw_door_init": "7c48a1559bf349369e954f64053a170cd011c9886c1e4d2739f109b8449ddb25",
    "108GTCGA:draw_door_tile": "09acdd514e8e1d0c62b024999dd8aecf902c876853fb015da36fe4b7ecbf7800",
    "108GTCGA:draw_masked_tile": "7d4d83ab8d4fe4ac17815109f61be14668dd7cd8c836c699dcb6a66ead190e19",
    "108GTCGA:draw_opaque_tile": "579f12ff00c76f121b4d1245dda206ac662f3c5980dbe4513102d598ccece4b0",
    "108GTCGA:encode_bitplanes_cga": "cab67e37fb1d08483e6454bebd09fde4112b6435a05ef17a7fd6e5f3e4e6a959",
    "108GTCGA:encode_mask_cga": "fe8c68e9fa7febcfa0d2ef0c5197fb99d7577865a2b550e861def301ad71b1cd",
    "108GTCGA:find_entity_at_row": "7e14bbafd0d2a67c49193918ea75021ac93704a09d2875ca7f239c7a8fff2b56",
    "108GTCGA:find_nonfd_entry": "97ac7d1c73947c9609b7053bbb40db60bc8fac1811dd0c50a03cfab7ad4df502",
    "108GTCGA:init_status_buf": "b553dc4d6838a2945ade4cf594270d2cf3ae4624a7b5ce5fe49e370a4ba1152f",
    "108GTCGA:load_6tiles_to_buf": "7e3d95e304da91b5428fcbf481d119cb9fe42dd0008c84efe138c37e79f14566",
    "108GTCGA:load_tiles_3_from_b": "b4860d6724a2c8494de768a2f8b7c5e8bc50dc4a4f4079d0fb6791a4c00e5851",
    "108GTCGA:load_tiles_to_buf": "cc9369088aa0c2c23fad7fb3cec6713f3b05152b929804a8317bab75292ab2f1",
    "108GTCGA:render_char_glyph": "fa9a834cc10f1dbb068d525c3c20d91ee7b10b88b98be1c4bd324ec80d8102ba",
    "108GTCGA:render_char_row": "3b5ecfdfcfa53c81d0603439a7616374a48e442ab22259c2139ec53ad57d0239",
    "108GTCGA:render_char_set": "547690b355700850901d0412a2901dafe7ef72d93c8f97c8b151f06d18e3d8b0",
    "108GTCGA:render_string": "7c556de227df5fffafd7706434a69ea095b240dd92455775e03ef372459ba450",
    "108GTCGA:run_gtcga_main": "e314c6549f526730c8cc4f82b788a006ea22761151026d00aaa94c633ca0b36e",
    "108GTCGA:scan_entity_next": "63003c2520e1e5dc3ed83c9c5ea64a92b1de515b1d5ca45a8eff65dacf218930",
    "108GTCGA:scan_entity_tbl": "5fe6eff684ed84e7392ffbd1aa0ffa5f4ca8d4d8b6140d3de0df3478f9b9ceb7",
    "203GFCGA:bg_col_blit_row": "06062d7f01d4522fd010e61ceedebde446f801b6d1f00f11640c5f873d5a63ce",
    "203GFCGA:bg_tile_blit_inner": "71235d73231a3b3d042f67212e47055d404d1308a51e3a446cfdb4f7e54cf05c",
    "203GFCGA:bg_tile_restore_3x3": "3a3ee332602ad8fba3e3f10dc87d8b9bee10f4d68045a5cbd54813087b865c58",
    "203GFCGA:cga_blit_2rows_stride": "5e978c7407b87e8845cd153286a0d6c605f5b9ad6dec5a30469716084b7b267d",
    "203GFCGA:cga_clear_2rows": "feeb1c4b7a2772487c03695b12d0cf2e669b1b776a7d890489663acf3594556c",
    "203GFCGA:cga_fade_blit": "a49805a3c8d27bda3219a152c6553f616c2991ed599afa897dc9ef49e17df925",
    "203GFCGA:cga_fill_bit_range_wide": "6710bdb0ab9ff3666d200d57ecfe7f1f3acf06dcfc304d0631dd18cffa3975c4",
    "203GFCGA:cga_inner_fade": "ab8411d2eb7f030316db347154af45e9d069ec19e8a7ede0f2b3fc67227820ab",
    "203GFCGA:cga_nibble_mask_advance": "0b7ed9ded53c11053bf63388ac1e752484dd4993554dcdd10037855f1cb4501c",
    "203GFCGA:cga_nibble_mask_alt": "58d114fcc7ba1aace127dacbc14475af4c16385620b7f13b9bde7e23a4860bd7",
    "203GFCGA:cga_plane_mask_2bit": "faec7e4a88f1254e76fb4014d1b6aa3b11b187fe2d0e959eb94d518cfd56f4be",
    "203GFCGA:cga_plane_mask_combine": "2f041d8de243700a9a5e231ed82d6cce6d90bb58ade3d13586339f3424b8419c",
    "203GFCGA:cga_row_addr_calc": "c8e2446aea4e08f5d18f6fad5f724d1dae258e294af7bc39e93e6006b20c8d6e",
    "203GFCGA:cga_sprite_blit": "59bc07b2d015ca413531e076d8e1006db465cda6babeabc6041a9ea6b77e5078",
    "203GFCGA:cga_sprite_blit_ex": "c5fb89ced7ff4696f023f434e5cc8e3bd607869cd5c73404e0bf7c4225a80854",
    "203GFCGA:cga_sprite_render_blended": "34483103ba8d2be199a46c8fb42095ea104be7843d7c74aa4213be0e19a9469e",
    "203GFCGA:cga_sprite_render_solid": "1e723a265fb73005b11463fab176d39406c6f94183c070334313907afbab7731",
    "203GFCGA:col_write_inner": "7c72a0f5541f35081f8c45e239b6d3507a9dfd6f99f858446030fdba99c68f7c",
    "203GFCGA:frame_wait_loop": "68bafef1964d77df30f72cdcffce39d113c2b9dd1a7e9f8a5b8349d7400c206c",
    "203GFCGA:hero_tier_get": "8b7e9339512e29b949c6e5911b4efecdab1d9c06117c2345fded7a50d735dd03",
    "203GFCGA:hud_clear": "8a38192889dc927c22d570b88b8d7812d16cfef81ff0e3e08568b267db4cc1d0",
    "203GFCGA:projectile_spawn_check": "b281ad910b628e7f01daa799f1a147f12e422338955ea72530e0de1f6c85d3bd",
    "203GFCGA:render_frame_rows": "ed7af616cdc4f23b28f440da9cd5736099e8b36612ffa71920c11cada5eec5b9",
    "203GFCGA:restore_background_pixels": "745429be1b07a2dcd79f94ebc0b962a2ddacc9330079fabbba12b11eceab1e16",
    "203GFCGA:restore_scroll_pixels": "8d6573a82a74ed56f611d0836dc92c4fc24c538f417958d2047c3250023cf0c6",
    "203GFCGA:row_ofs_advance": "a3da95b4d53c75e5bcacc417cee8d9e6930164c5eed44d21949e280a4ed109e8",
    "203GFCGA:run_gfcga_main": "07162fb32f34446315079228eb419b13969b35906080bc198fad21c3abe3fdb8",
    "203GFCGA:save_background_pixels": "3a57a6436f70b1f0a830a42e9c5c773bfa163ec2ed620e44a55e9a5b9ff8efce",
    "203GFCGA:scroll_pos_load": "513c1706413a2a77f2a046b326ef90791702074a55deb833069325fc6304bea5",
    "203GFCGA:sprite_bit_extract": "647ef88b35d0d6c9cd7b0f81eddca97c1ca0241c711dd4271f269e08e6fcdc14",
    "203GFCGA:sprite_blit_dispatch": "793ab8919449e4488bafcea3ec5191b5ff385718a45230cf57c1f404e305a4ed",
    "203GFCGA:sprite_cell_render": "268cea7787da07512c9d94a15e82ba50c3ca48963ca7bd1d73f9e7bb1ee19289",
    "203GFCGA:sprite_clear_8words": "2e1fb22b2dc90ad06cedfd3a8b8a93070d0eef9a3fa69a8c152a53de92ad7709",
    "203GFCGA:sprite_col_render_loop": "f3451acd21aa5d280c1c974416c6f8cd82787760b743747ed06d71ed34d2a3a1",
    "203GFCGA:sprite_copy_8words": "b409cc72ffeac62f48ddd606659f354265d94fcd036ec6f982ccf9b0fc3d75e6",
    "203GFCGA:sprite_get_value": "c7b88c0777aec423617220d60bdb276a9898e34342371c2fdcfda904bf7483db",
    "203GFCGA:sprite_slot_init": "df947dd6be15ab501570055ad5981fcc7671a7487607bb94c8649db86dde1c22",
    "203GFCGA:sprite_src_setup": "a32912382f8b2337b1a91e94b420ca7f944193b9b43eb962880c7ecc609be23f",
    "203GFCGA:sprite_state_update": "d4b67363a9660ff878fb4d1164ea020241af33363bb590543468ed2eb35f3dca",
    "203GFCGA:sprite_wide_row_render": "8d70c13ac45a8d43f439b43a9445839b2d174ce664f5222c5a4500ab49c7b71c",
    "203GFCGA:step_sprite_pos_pair": "455f976d99b836616b6a2c173b4175610c6687a202f62afb92a8751eeeea0086",
    "203GFCGA:wrap_scroll_si_low": "18ff6e3243d6f2d09ee5c282402992fab3e2ddb4a72217de439271b4f9ee7d8c",
    "gmcga:calc_text_width": "2027d9e79b0bc901d7c1132dd60b7ae4686b6b3593fb43d109386dd74c62f743",
    "gmcga:clear_screen": "1789b7ff5fcaa81e621aff9a9438d472c8a5d7aaa85c6afbae79e2c493cfec01",
    "gmcga:convert_time_to_bcd": "6894ac66b125f12fc481fb2568c0f246b7231b83907b7eedd2dc0722cfdf9ba6",
    "gmcga:decode_bitplane_tile": "b11f7c29f78a9c0292da914b961f8d6f3ea9897b38a8883dc60b74c26f7cc1ec",
    "gmcga:expand_font_bits": "f9a008af0eae6ce133d5460103ad38e9140ee04e4859fcef9ad628c43c63291e",
    "gmcga:extract_bitplane_pixels": "1eee93f5917a6a9135710689795b9592a4aeaf514d2ab3c17c263f4f712be5b3",
    "gmcga:fill_horizontal_line": "a197f24d8d5957b299e90954333c0861eb7ba8e769a33788e396354c5135043b",
    "gmcga:fill_rectangle": "188a665ae625a4454b63c0031872c9a31834f716aab029290e7648d24796af9b",
    "gmcga:fill_vertical_line": "cb0910d56f4ec102e480b0ad88981a8296fc442f75150174eba45482bbdd814d",
    "gmcga:init_timestamp": "de823474421e8745e2ae06e24456a5077f055bd7ddfaa05792d8201d3239449f",
    "gmcga:int_divide_bcd": "c32333474455e8f486837d462b1b1f84fec7df05ce9b5c84cdcf188f1b7a1b26",
    "gmcga:modulo_divide_bcd": "17a6a189aac28cec435e264c213ba7d86608e07c0b6fd372afc5d326f77bf253",
    "gmcga:plot_pixel": "00a11b883af1943cddedf93955e529cf407afaf7f24ff97ae98db7eb7db2612f",
    "gmcga:process_sprite_row": "3f28d9bbc5902424fca1ade4c02d9becf639b64e6ec012cc0c101b0148d84caa",
    "gmcga:render_text_char": "30331efc69cdfe9d79cff2a3ede6e54717afc72edb10dec1afb4d1cedf921663",
    "gmcga:render_text_char_alt": "b099292c0f01c5368db35f1819252141bbe180a3793d22c84b5319470c42c365",
    "gmcga:render_tilemap_large": "1abedaba5922c7f39a3414a94ead949dd28e0b3a608202ef8ef75ef72e0252de",
    "gmcga:render_tilemap_small": "1541cfb66a9ca807969146822184dcb2b8b9ef5ce9f39890147dd0fb5bb636b2",
    "gmcga:run_gmcga_main": "20a77af218b16a9b34b015ee167479827ec62acde327e5f8deb48b64fa80dc99",
}


if __name__ == "__main__":
    raise SystemExit(oracle.main())
