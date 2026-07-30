# Town MCGA Parity Inventory

MASM authority: `106TOWN.asm`, `111GTMCA.asm`, and the verified release
`111GTMCA.bin` loaded at `CS:3000h`.

`106TOWN` reaches two graphics layers. Slots at `2000h..2042h` belong to
the resident GMMCGA service layer. Slots at `3002h..3026h` are words in the
loaded GTMCGA chunk. These targets are decoded directly from release bytes.

## GTMCGA Slots

| Slot | Target | 106TOWN name | Calls | First-frame role |
| --- | --- | --- | ---: | --- |
| `3002` | `3028` | `gfx_draw_fn` | 3 | Initial map draw |
| `3004` | `3051` | `gfx_update_fn` | 1 | Movement loop |
| `3006` | `3628` | `gfx_scroll_left_fn` | 1 | Scrolling |
| `3008` | `3677` | `gfx_scroll_right_fn` | 1 | Scrolling |
| `300A` | `36A4` | `gfx_scroll_right2_fn` | 1 | Scrolling |
| `300C` | `36F1` | `gfx_scroll_left2_fn` | 1 | Scrolling |
| `300E` | `32FC` | `gfx_npc_draw_fn` | 1 | NPC loop |
| `3010` | `3526` | `gfx_npc_update_fn` | 1 | NPC loop |
| `3012` | `359A` | `gfx_fn_3012` | 1 | NPC loop; semantic pending oracle |
| `3014` | `34EC` | `gfx_fn_3014` | 1 | NPC loop; semantic pending oracle |
| `3018` | `3785` | `gfx_cursor_fn` | 3 | Menu/dialog |
| `301A` | `3805` | `gfx_sel_init_fn` | 6 | Menu/dialog |
| `301C` | `37CC` | `gfx_sel_draw_fn` | 2 | Menu/dialog |
| `301E` | `3999` | `gfx_sel_scroll_up_fn` | 2 | Menu/dialog |
| `3020` | `39EF` | `gfx_sel_scroll_dn_fn` | 2 | Menu/dialog |
| `3024` | `3AF9` | `gfx_ret_fn` | 1 | Resource-return path |
| `3026` | `3A71` | `gfx_copy_fn` | 3 | Tile encoder: packed pixels plus alpha masks |

`town_mcga_dispatch_native` verifies all 17 slot words and 31 static calls.

## Resident GMMCGA Boundary

The first stable frame also reaches `gfx_clear_fn`, `gfx_draw_tile_fn`,
`gfx_draw_player_fn`, HUD `gfx_render_a..d`, icon draws, and
`gfx_draw_map_fn`. These are resident `CS:2000h` services, not GTMCGA
entries. Their direct framebuffer fixtures are the next implementation span.

Later resident calls cover fill, image load, text character/string, row
scroll/clear, blit, and refresh. None may be replaced by synthetic castle
composition.

| Slot | Target | 106TOWN name | Calls | First-frame role |
| --- | --- | --- | ---: | --- |
| `2000` | `2046` | `gfx_fill_fn` | 12 | Later dialogs/HUD |
| `2002` | `2106` | `gfx_clear_fn` | 4 | Initial clear |
| `2004` | `2195` | `gfx_draw_tile_fn` | 5 | Three HUD tiles, later icons |
| `2006` | `2227` | `gfx_render_a_fn` | 1 | Initial HUD |
| `2008` | `2256` | `gfx_render_b_fn` | 1 | Initial HUD |
| `200E` | `22BF` | `gfx_load_img_fn` | 4 | Dialog resources |
| `2010` | `22CD` | `gfx_draw_map_fn` | 2 | Initial map |
| `2012` | `2385` | `gfx_draw_player_fn` | 2 | Initial player |
| `2014` | `238F` | `gfx_render_c_fn` | 2 | Initial HUD |
| `2016` | `23AC` | `gfx_render_d_fn` | 1 | Initial HUD |
| `2018` | `23CC` | `gfx_draw_icon_a_fn` | 1 | Initial HUD icon |
| `201A` | `23F5` | `gfx_draw_icon_b_fn` | 1 | Initial HUD icon |
| `2022` | `27E9` | `gfx_draw_char_fn` | 5 | Dialog text |
| `2024` | `2857` | `gfx_scroll_row_fn` | 2 | Dialog scroll |
| `2026` | `289A` | `gfx_text_layout_a_fn` | 1 | Dialog layout |
| `2028` | `28D9` | `gfx_text_layout_b_fn` | 1 | Dialog layout |
| `202A` | `291A` | `gfx_draw_str_fn` | 3 | Dialog/menu text |
| `2038` | `22DB` | `gfx_clear_row_fn` | 1 | Dialog clear |
| `2040` | `2130` | `gfx_blit_fn` | 4 | Dialog/menu blit |
| `2042` | `2C01` | `gfx_refresh_fn` | 1 | Menu refresh |

`town_mcga_dispatch_native` verifies all 20 resident slot words and 54 static
calls directly against the raw MASM `gmmcga.bin` driver image.

## Translated Services

| Target | C function | Direct oracle | State |
| --- | --- | --- | --- |
| `GMMCGA:2106` | `zeliard_gmmcga_clear_playfield` | Full VGA hash and exact `(48,14) 224x144` clear rectangle | Green |
| `GMMCGA:2195` | `zeliard_gmmcga_draw_status_line` | Initial three-call register sequence and full VGA hash | Green |
| `GTMCGA:3A71` | `zeliard_gtmcga_encode_tile_block` | Three planar tiles; packed bytes, transparency masks, and scratch hashes | Green |
