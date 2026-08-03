#ifndef ZELIARD_TOWN_MCGA_H
#define ZELIARD_TOWN_MCGA_H

#include "../core/types.h"

typedef struct {
    u16 slot;
    u16 target;
    const char *name;
    u8 town_call_count;
} zeliard_gtmcga_dispatch_t;

typedef struct {
    u16 slot;
    u16 target;
    const char *name;
    u8 town_call_count;
} zeliard_gmmcga_dispatch_t;

size_t zeliard_gtmcga_resolve_town_dispatch(
    const u8 *chunk, size_t chunk_size,
    zeliard_gtmcga_dispatch_t *out, size_t out_count);

size_t zeliard_gmmcga_resolve_town_dispatch(
    const u8 *driver, size_t driver_size,
    zeliard_gmmcga_dispatch_t *out, size_t out_count);

/* GMMCGA:2106, resident dispatch slot CS:2002. */
int zeliard_gmmcga_clear_playfield(u8 *vga, size_t vga_size);

/* GMMCGA:2130, resident dispatch slot CS:2040.  Applies one of the eight
 * progressive 01h..FFh black-wipe masks used around every town building. */
int zeliard_gmmcga_building_blit_pass(u8 *vga, size_t vga_size,
                                      u8 pass_index);

/* GMMCGA:2130, resident dispatch slot CS:2040. One of eight masks in the
 * building-entry/exit framebuffer fade to black. */
int zeliard_gmmcga_building_fade_pass(u8 *vga, size_t vga_size, u8 pass);

/* GMMCGA:2046, 27E9, 289A, and 28D9 dialog primitives. */
int zeliard_gmmcga_fill_frame(u8 *vga, size_t vga_size,
                              u16 bx, u16 cx, u8 cinematic);
int zeliard_gmmcga_clear_rect(u8 *vga, size_t vga_size, u16 bx, u16 cx);
int zeliard_gmmcga_draw_text_char(u8 *vga, size_t vga_size,
                                  const u8 *game_seg, size_t game_size,
                                  u8 character, u8 selector, u16 bx, u8 y);
int zeliard_gmmcga_save_rect(const u8 *vga, size_t vga_size,
                             u8 *scratch, size_t scratch_size,
                             u16 ax, u16 cx, u16 di);
int zeliard_gmmcga_restore_rect(u8 *vga, size_t vga_size,
                                const u8 *scratch, size_t scratch_size,
                                u16 ax, u16 cx, u16 di);

/* GTMCGA:3A71, loaded dispatch slot CS:3026. */
int zeliard_gtmcga_encode_tile_block(u8 *ds, size_t ds_size, u16 si,
                                     u8 *es, size_t es_size, u16 di,
                                     u16 tile_count);

/* GTMCGA:3AF9, loaded dispatch slot CS:3024. */
int zeliard_gtmcga_process_pattern_tiles(u8 *game_data,
                                         size_t game_data_size);

/* GMMCGA:2195, resident dispatch slot CS:2004, normal (AL=0) path. */
int zeliard_gmmcga_draw_status_line(u8 *vga, size_t vga_size,
                                    u16 ax, u16 bx, u16 cx);

/* GMMCGA:2385, resident dispatch slot CS:2012. */
int zeliard_gmmcga_draw_life_scale(u8 *vga, size_t vga_size, u16 ax);

/* GMMCGA:2227/2256, resident dispatch slots CS:2006/2008. */
int zeliard_gmmcga_draw_life_max(u8 *vga, size_t vga_size,
                                 const u8 *game_seg, size_t game_size);
int zeliard_gmmcga_draw_life_current(u8 *vga, size_t vga_size,
                                     const u8 *game_seg, size_t game_size);

/* GMMCGA:22CD, resident dispatch slot CS:2010. */
int zeliard_gmmcga_draw_town_text_record(u8 *vga, size_t vga_size,
                                         u8 *game_seg, size_t game_size,
                                         u16 si);

/* GMMCGA:22BF, resident dispatch slot CS:200E. */
int zeliard_gmmcga_draw_hud_label(u8 *vga, size_t vga_size,
                                  u8 *game_seg, size_t game_size, u16 si);

/* GMMCGA:238F/23AC/23CC/23F5, slots CS:2014..201A. */
int zeliard_gmmcga_draw_almas(u8 *vga, size_t vga_size,
                              u8 *game_seg, size_t game_size);
int zeliard_gmmcga_draw_gold(u8 *vga, size_t vga_size,
                             u8 *game_seg, size_t game_size);
int zeliard_gmmcga_draw_spell_charge(u8 *vga, size_t vga_size,
                                     u8 *game_seg, size_t game_size);
int zeliard_gmmcga_draw_shield_hp(u8 *vga, size_t vga_size,
                                  u8 *game_seg, size_t game_size);

/* GMMCGA:254C, resident dispatch slot CS:201C. */
int zeliard_gmmcga_draw_equipped_sword(u8 *vga, size_t vga_size,
                                       const u8 *item_seg, size_t item_size,
                                       u8 sword, u16 bx);

/* GMMCGA:25FC, resident dispatch slot CS:2020. */
int zeliard_gmmcga_draw_equipped_shield(u8 *vga, size_t vga_size,
                                        const u8 *item_seg, size_t item_size,
                                        u8 shield, u16 bx);

/* Combined initial 106TOWN frame_update HUD call span. */
int zeliard_gmmcga_draw_first_frame_hud(u8 *vga, size_t vga_size,
                                        u8 *game_seg, size_t game_size,
                                        u16 town_text_si);

/* GTMCGA:3028, loaded dispatch slot CS:3002. */
int zeliard_gtmcga_capture_playfield(const u8 *vga, size_t vga_size,
                                     u8 *game_seg, size_t game_size);

/* GTMCGA:32FC, loaded dispatch slot CS:300E. */
int zeliard_gtmcga_draw_npc_tiles(const u8 *tile_ids, size_t tile_id_size,
                                  const u8 *game_data, size_t game_data_size,
                                  u8 *vga, size_t vga_size);

/* GTMCGA:359A, loaded dispatch slot CS:3012. */
int zeliard_gtmcga_draw_player_tiles(const u8 *tile_ids, size_t tile_id_size,
                                     const u8 *game_data, size_t game_data_size,
                                     const u8 *mask_data, size_t mask_data_size,
                                     u8 *vga, size_t vga_size);

/* 106TOWN:stamp_npcs_save_tiles/render_town_actors through GTMCGA:3012. */
int zeliard_gtmcga_render_town_actors(u8 *game_seg, size_t game_size,
                                      u8 *game_data, size_t game_data_size,
                                      const u8 *mask_data, size_t mask_data_size,
                                      u8 *vga, size_t vga_size);

/* GTMCGA:3051, loaded dispatch slot CS:3004. */
int zeliard_gtmcga_update_town_frame(u8 *game_seg, size_t game_size,
                                     const u8 *game_data, size_t game_data_size,
                                     const u8 *mask_data, size_t mask_data_size,
                                     u8 *vga, size_t vga_size);

/* GTMCGA:scroll_left/scroll_right, dispatch slots CS:3006/300Ah. */
int zeliard_gtmcga_scroll_view_left(u8 *vga, size_t vga_size);
int zeliard_gtmcga_scroll_view_right(u8 *vga, size_t vga_size);

#endif
