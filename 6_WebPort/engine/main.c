/* Zeliard web-port engine entry point.
 *
 * The reconstructed game loads OPDMO first. The opening demo itself owns the
 * copyright/title card, so there is no separate title scene before it.
 */

#include "core/types.h"
#include "core/framebuf.h"
#include "core/player_state.h"
#include "core/input.h"
#include "core/timer.h"
#include "render/palette.h"
#include "render/town_mcga.h"
#include "game/opening.h"
#include "game/town_runtime.h"
#include "game/cavern_transition.h"
#include "game/fight_masm_vm.h"
#include "game/room_masm_vm.h"
#include "game/inventory_masm_vm.h"
#include "audio/opening_audio.h"
#include "load/game_loader.h"
#include "platform/platform.h"

#include <stdlib.h>
#include <string.h>

#ifdef __EMSCRIPTEN__
#  include <emscripten.h>
#  define EXPORT EMSCRIPTEN_KEEPALIVE
#else
#  define EXPORT
#endif

typedef enum {
    SCENE_TITLE = 0, /* Reserved for API compatibility; OPDMO owns the title. */
    SCENE_OPENING = 1,
    SCENE_GAME = 2
} game_scene_t;

typedef enum {
    GAMEPLAY_LOCATION_TOWN = 0,
    GAMEPLAY_LOCATION_CAVERN = 1,
} gameplay_location_t;

static game_scene_t g_scene = SCENE_OPENING;
static gameplay_location_t g_gameplay_location = GAMEPLAY_LOCATION_TOWN;
static int g_paused;
static int g_speed_menu_active;
static int g_speed_menu_selected;
static int g_restore_menu_active;
static u8 g_gamepad_directions;
static u8 g_gamepad_buttons;
static u32 g_load_request_serial;
static int g_session_terminated;
static u8 g_game_segments[ZELIARD_GAME_SEGMENT_COUNT][ZELIARD_GAME_SEGMENT_SIZE];
static u8 g_game_vga[ZELIARD_GAME_SEGMENT_SIZE];
static u8 g_inventory_return_vga[ZELIARD_GAME_SEGMENT_SIZE];
static u8 g_inventory_return_to_fight;
static u8 g_inventory_player_before[ZEL_PLAYER_RECORD_SIZE];
static u8 g_inventory_fight_hud_override;
static u8 g_cavern_town_segments[ZELIARD_GAME_SEGMENT_COUNT]
                                 [ZELIARD_GAME_SEGMENT_SIZE];
static u8 g_cavern_town_vga[ZELIARD_GAME_SEGMENT_SIZE];
static u8 g_death_sage_chrome_vga[ZELIARD_GAME_SEGMENT_SIZE];
static u8 g_death_sage_return_vga[ZELIARD_GAME_SEGMENT_SIZE];
static zeliard_game_exec_state_t g_game_exec;
static zeliard_town_runtime_t g_town_runtime;
static zeliard_cavern_transition_t g_cavern_transition;
static zel_input_state_t g_input;
static u32 g_input_subtick_accum;
/* Monotonic count of the same 0x13B1-divisor PIT interrupts consumed by
 * stick.asm.  Automated replay uses this clock instead of host wall time. */
static u32 g_guest_tick_count;
static u8 g_fight_music_chunk = 0xFF;
static u8 g_fight_connector_music_fade;
static u8 g_fight_boundary_selector = 0xFF;

static u8 g_fight_started;
static u8 g_fight_death_pending;
static u8 g_fight_death_return_pending;
static u8 g_fight_death_audio_fade_started;
static u8 g_death_sage_chrome_active;
static u32 g_fight_regen_pit_ticks;
static u8 g_fight_regen_frames;

static int advance_fight_passive_life_restoration(u32 pit_ticks,
                                                  u16 hp_before,
                                                  u16 hp_after) {
    const u16 hp_max = (u16)(g_game_segments[0][ZEL_PLAYER_HP_MAX] |
        ((u16)g_game_segments[0][ZEL_PLAYER_HP_MAX + 1] << 8));
    const u8 direction = g_game_segments[0][0xFF17];
    const u8 buttons = g_game_segments[0][0xFF16];
    if (g_fight_death_pending || g_game_segments[0][ZEL_PLAYER_INIT_COMPLETE] ||
        direction || buttons || hp_after == 0 || hp_after >= hp_max ||
        hp_after != hp_before) {
        g_fight_regen_pit_ticks = 0;
        g_fight_regen_frames = 0;
        return 0;
    }

    const u8 speed = g_game_segments[0][0xFF33];
    const u8 frame_ticks = (u8)(4u * (speed ? speed : 1u));
    g_fight_regen_pit_ticks += pit_ticks;
    while (g_fight_regen_pit_ticks >= frame_ticks) {
        g_fight_regen_pit_ticks -= frame_ticks;
        if (++g_fight_regen_frames >= 16) {
            const u16 restored = (u16)(hp_after + 2u);
            g_game_segments[0][ZEL_PLAYER_HP] = (u8)restored;
            g_game_segments[0][ZEL_PLAYER_HP + 1] = (u8)(restored >> 8);
            zeliard_fight_masm_vm_poke_u16(ZEL_PLAYER_HP, restored);
            /* Prevent the interpreter's delayed check_state18 pass from
             * replaying the same host-timed restoration. */
            zeliard_fight_masm_vm_poke_u8(0x9F18, 0);
            g_fight_regen_frames = 0;
            return 1;
        }
    }
    return 0;
}

static void begin_fight_death(void) {
    if (g_fight_death_pending) return;
    g_fight_death_pending = 1;
}

static void restore_death_sage_chrome(void) {
    if (!g_death_sage_chrome_active) return;
    /* 217KENJP's death script owns only the central room canvas. Preserve
     * the clean room-enter stone frame and HUD around it; the exact VM may
     * update the portrait and text window inside x=32..271/y=14..159. */
    for (int y = 0; y < ZELIARD_HEIGHT; ++y) {
        u8 *dst = g_game_vga + y * ZELIARD_WIDTH;
        const u8 *src = g_death_sage_chrome_vga + y * ZELIARD_WIDTH;
        if (y < 14 || y >= 160) {
            memcpy(dst, src, ZELIARD_WIDTH);
        } else {
            memcpy(dst, src, 32);
            memcpy(dst + 272, src + 272, ZELIARD_WIDTH - 272);
        }
    }
}

typedef struct {
    u8 valid;
    u8 area_id;
    u16 start_position;
    u8 map_scroll_row;
    u8 screen_position;
} cavern_town_origin_t;

static cavern_town_origin_t g_cavern_town_origin;

static int fight_boundary_returns_to_town(u8 operation, u8 selector,
                                          u16 dispatch) {
    const int town_dispatch = operation == 0 &&
        (dispatch == 0x6002 || dispatch == 0x601C);
    /* Release-byte contract: test_fight_level_handoff_oracle.py proves that
     * 200FIGHT calls the loader with AL=1 and sets bit 7 on door targets;
     * 0x80 is the death handoff while 0x81 returns from Malicia to Muralla. */
    const int town_warp = operation == 1 &&
        (selector & 0x80u) && selector != 0x80u;
    return town_dispatch || town_warp;
}

static void sync_fight_music(void) {
    const u8 chunk = zeliard_fight_masm_vm_music_chunk();
    if (zeliard_fight_masm_vm_ending_active()) {
        if (chunk == g_fight_music_chunk) return;
        if (chunk == 39) {
            if (!zel_audio_play_music(ZEL_MUSIC_ZEND))
                platform_log("250ENDMO: ending score start failed");
            g_fight_music_chunk = chunk;
        }
        return;
    }
    const u16 map_width = zeliard_fight_masm_vm_active()
        ? zeliard_fight_masm_vm_peek_u16(0xC002) : 0;
    /* MP21 is the authored transition cavern between Malicia and Peligro.
     * 200FIGHT changes the level/music selector on entry, but the audible
     * score fades across the connector and the destination score begins at
     * the far door.  Keep the currently playing score while MP21 is live. */
    if (map_width == 96u &&
        g_fight_music_chunk != 0xFF)
        return;
    if (g_fight_connector_music_fade && map_width != 96u) {
        /* The far MP21 door is 200FIGHT's destination score boundary. */
        g_fight_connector_music_fade = 0;
        g_fight_music_chunk = 0xFF;
    }
    if (chunk == g_fight_music_chunk) return;
    const zel_music_track_t track = chunk == 86 ? ZEL_MUSIC_MUS1
                                  : chunk == 87 ? ZEL_MUSIC_MUS2
                                  : chunk == 88 ? ZEL_MUSIC_MUS3
                                  : chunk == 89 ? ZEL_MUSIC_MUS4
                                  : chunk == 90 ? ZEL_MUSIC_MUS5
                                  : chunk == 91 ? ZEL_MUSIC_MUS6
                                  : chunk == 94 ? ZEL_MUSIC_MBOS
                                  : chunk == 95 ? ZEL_MUSIC_MFAN
                                                : ZEL_MUSIC_NONE;
    if (track == ZEL_MUSIC_MFAN) {
        /* MSCADLIB clears the caller's FF26h completion byte while the
         * reward fanfare is active.  300ROKAD polls that same byte before
         * beginning its reverse sword-pose wipe. */
        g_game_segments[0][0xFF26] = 0;
        zeliard_fight_masm_vm_poke_u8(0xFF26, 0);
    }
    if (track != ZEL_MUSIC_NONE && !zel_audio_play_music(track))
        platform_log("200FIGHT: exact music chunk %u start failed",
                     (unsigned)chunk);
    g_fight_music_chunk = chunk;
}

static void sync_fight_audio_globals(void) {
    /* 200FIGHT and SNDADLIB share FF08h in the original game segment.
     * Our two interpreters use separate address spaces, so mirror the byte
     * at the same frame boundary at which 200FIGHT publishes it. */
    zel_opening_audio_set_heartbeat_volume(g_game_segments[0][0xFF08]);
}

static int redraw_cavern_return_hud(u8 *vga, size_t vga_size, u8 *cs) {
    if (zeliard_gmmcga_draw_first_frame_hud(
            vga, vga_size, cs, sizeof(g_game_segments[0]),
            g_town_runtime.town_text_record) != 0)
        return 0;
    const u8 sword = cs[ZEL_PLAYER_SWORD];
    if (sword && zeliard_gmmcga_draw_equipped_sword(
            vga, vga_size, g_game_segments[1],
            sizeof(g_game_segments[1]), sword, 0x18AB) != 0)
        return 0;
    const u8 shield = cs[ZEL_PLAYER_SHIELD];
    if (shield && zeliard_gmmcga_draw_equipped_shield(
            vga, vga_size, g_game_segments[1],
            sizeof(g_game_segments[1]), shield, 0x3EA4) != 0)
        return 0;
    return 1;
}

static zel_music_track_t current_town_music(void) {
    switch (g_town_runtime.music_index) {
    case 1: return ZEL_MUSIC_UGM1;
    case 2: return ZEL_MUSIC_MGT2;
    case 3: return ZEL_MUSIC_UGM2;
    default: return ZEL_MUSIC_MGT1;
    }
}

static void finish_cavern_return_to_town(void) {
    u8 *cs = g_game_segments[0];
    const u8 selector = g_cavern_transition.return_selector;
    const u8 transition_direction = g_cavern_transition.direction;
    const u8 fight_screen_position = cs[ZEL_PLAYER_SCREEN_POSITION];
    const u16 exit_scroll_count =
        zeliard_fight_masm_vm_exit_scroll_count();
    const u8 exit_scroll_dir = zeliard_fight_masm_vm_exit_scroll_dir();
    const u8 exit_player_y = zeliard_fight_masm_vm_exit_player_y();
    u8 cavern_object_state[ZEL_PLAYER_CAVERN_OBJECT_STATE_END];
    u8 cavern_progress_a[ZEL_PLAYER_FRAME_SCRATCH - ZEL_PLAYER_GOLD];
    u8 cavern_progress_b[ZEL_PLAYER_FACING_DIRECTION - ZEL_PLAYER_TEARS];
    memcpy(cavern_object_state, cs, sizeof(cavern_object_state));
    memcpy(cavern_progress_a, cs + ZEL_PLAYER_GOLD,
           sizeof(cavern_progress_a));
    memcpy(cavern_progress_b, cs + ZEL_PLAYER_TEARS,
           sizeof(cavern_progress_b));
    if (g_cavern_town_origin.valid) {
        /* FIGHT replaces most of the shared game segment with its own code,
         * maps, and scratch buffers. Restore the suspended town overlay, but
         * retain the persistent gold-through-spell state changed in combat.
         * Copying the whole low page would also import FIGHT's render scratch
         * bytes and corrupt the first town frame. */
        memcpy(g_game_segments, g_cavern_town_segments,
               sizeof(g_cavern_town_segments));
        /* STDPLY 00h..7Fh is also the per-cavern object-state bitmap.
         * Item/stash records OR their authored masks into this block and
         * process_map_seg_updates consumes it when the map is reloaded. */
        memcpy(cs, cavern_object_state, sizeof(cavern_object_state));
        memcpy(cs + ZEL_PLAYER_GOLD, cavern_progress_a,
               sizeof(cavern_progress_a));
        memcpy(cs + ZEL_PLAYER_TEARS, cavern_progress_b,
               sizeof(cavern_progress_b));
    }
    cs[ZEL_PLAYER_SAVE_SAGE] = selector;
    cs[ZEL_PLAYER_SCREEN_POSITION] = fight_screen_position;
    if (transition_direction) cs[ZEL_PLAYER_FACING_DIRECTION] |= 1;
    else cs[ZEL_PLAYER_FACING_DIRECTION] &= 0xFE;
    if (zeliard_town_prepare_cavern_door_return(
            cs, sizeof(g_game_segments[0]), selector,
            exit_scroll_count, exit_scroll_dir, exit_player_y) != 0)
        platform_log("200FIGHT: town-door return position failed");
    /* Direct selector 04 is the deterministic post-entrance Pulpo fixture.
       Authored MP20 door routes still begin with the flag clear and let
       200FIGHT copy the door entity's direction bit into C3h. */
    cs[ZEL_PLAYER_BOSS_INTRO_FLAG] = selector == 4 ? 0xFF : 0;
    cs[ZEL_PLAYER_POSE] = 0;
    /* The suspended image was captured while Up was held at the cavern
     * entrance. Reset its saved input masks so the town cannot immediately
     * enter the cavern again after the host key has been released. */
    zel_input_init(&g_input, cs);
    g_cavern_transition.complete = 0;
    g_cavern_transition.return_to_town = 0;
    g_gameplay_location = GAMEPLAY_LOCATION_TOWN;
    g_cavern_town_origin.valid = 0;
    g_fight_connector_music_fade = 0;
    g_town_runtime.cavern_exit_requested = 0;
    g_town_runtime.facing_door_type = 0xFF;
    g_town_runtime.facing_item_position = 0xFFFF;
    g_town_runtime.facing_npc_position = 0xFFFF;
    /* Loader mode 1 selects the town encoded by the cavern door, which may
     * differ from the town where the cavern journey began. Re-enter 106TOWN
     * after the reverse transition's final compute_scroll_offset_b so the
     * destination scenery, actors, HUD, and viewport all agree. */
    if (zeliard_town_enter_first_frame(
            &g_town_runtime, &g_game_exec, g_game_vga,
            sizeof(g_game_vga)) != 0) {
        platform_log("200FIGHT: return-town first frame failed");
        memcpy(g_game_vga, g_cavern_town_vga, sizeof(g_game_vga));
        if (!redraw_cavern_return_hud(
                g_game_vga, sizeof(g_game_vga), cs))
            platform_log("200FIGHT: return-town HUD fallback failed");
    }
    memcpy(g_framebuf, g_game_vga, ZELIARD_FB_SIZE);
    zel_audio_play_music(current_town_music());
}

static int finish_cavern_death_to_sage(void) {
    u8 *cs = g_game_segments[0];
    u8 cavern_object_state[ZEL_PLAYER_CAVERN_OBJECT_STATE_END];
    const u8 death_map_scroll_row = cs[ZEL_PLAYER_MAP_SCROLL_ROW];
    u8 cavern_progress_a[ZEL_PLAYER_FRAME_SCRATCH - ZEL_PLAYER_GOLD];
    u8 cavern_progress_b[ZEL_PLAYER_FACING_DIRECTION - ZEL_PLAYER_TEARS];
    const u8 last_sage = cs[ZEL_PLAYER_LAST_SAGE];
    memcpy(cavern_object_state, cs, sizeof(cavern_object_state));
    memcpy(cavern_progress_a, cs + ZEL_PLAYER_GOLD,
           sizeof(cavern_progress_a));
    memcpy(cavern_progress_b, cs + ZEL_PLAYER_TEARS,
           sizeof(cavern_progress_b));

    /* 200FIGHT's game-over path restores HP, applies the gold/almas loss,
     * copies stat_XC5 (last sage) to current_area_id, and invokes loader 1.
     * FIGHT has replaced the town overlays by then, so recover the suspended
     * town image/code first and import only the persistent combat fields. */
    if (g_cavern_town_origin.valid) {
        memcpy(g_game_segments, g_cavern_town_segments,
               sizeof(g_cavern_town_segments));
        memcpy(cs, cavern_object_state, sizeof(cavern_object_state));
        memcpy(cs + ZEL_PLAYER_GOLD, cavern_progress_a,
               sizeof(cavern_progress_a));
        memcpy(cs + ZEL_PLAYER_TEARS, cavern_progress_b,
               sizeof(cavern_progress_b));
    }
    cs[ZEL_PLAYER_LAST_SAGE] = last_sage;
    cs[ZEL_PLAYER_SAVE_SAGE] = last_sage;
    cs[ZEL_PLAYER_MAP_SCROLL_ROW] = death_map_scroll_row;
    /* The exact fight VM yields at loader mode 1 because the town overlay
     * replaces it. Complete release 200FIGHT:level_start here using the
     * selected town MDT, rather than retaining residual cavern coordinates. */
    if (zeliard_town_prepare_level_start(
            cs, sizeof(g_game_segments[0]), last_sage) != 0) {
        platform_log("200FIGHT: death sage level-start position failed");
        return 0;
    }
    cs[ZEL_PLAYER_BOSS_INTRO_FLAG] = 0;
    cs[ZEL_PLAYER_POSE] = 0;
    zel_input_init(&g_input, cs);

    g_cavern_transition.complete = 0;
    g_cavern_transition.return_to_town = 0;
    g_gameplay_location = GAMEPLAY_LOCATION_TOWN;
    g_cavern_town_origin.valid = 0;
    g_fight_connector_music_fade = 0;
    g_fight_death_pending = 0;
    g_fight_death_return_pending = 0;
    g_fight_death_audio_fade_started = 0;
    g_town_runtime.cavern_exit_requested = 0;
    zeliard_room_masm_vm_stop();
    zel_opening_audio_stop();
    g_fight_music_chunk = 0xFF;
    g_fight_connector_music_fade = 0;

    /* Loader 1 returns to the suspended town graphics context before
     * 106TOWN and 217KENJP draw.  The web fight VM owns a private VGA image,
     * so restore the captured town frame explicitly; otherwise room_enter's
     * central clear leaves FIGHT's faded/corrupted border and HUD in place. */
    memcpy(g_game_vga, g_cavern_town_vga, sizeof(g_game_vga));
    if (zeliard_town_enter_first_frame(
            &g_town_runtime, &g_game_exec, g_game_vga,
            sizeof(g_game_vga)) != 0) {
        platform_log("200FIGHT: death sage town reload failed");
        return 0;
    }
    /* Preserve town_enter's newly rendered scenery and actors at the sage
     * coordinates, but place them into loader 1's clean suspended stone/HUD
     * surface. Reusing the whole pre-cavern image would leave the old player
     * and NPC pixels under the live actors when the sage room exits. */
    memcpy(g_death_sage_return_vga, g_cavern_town_vga,
           sizeof(g_death_sage_return_vga));
    /* GTMCGA's town viewport ends at scanline 157.  Scanlines 158 and 159
     * are the two solid frame separators (palette indices 09h and 08h),
     * and loader 1 preserves them from the suspended town surface. */
    for (int y = 14; y < 158; ++y)
        memcpy(g_death_sage_return_vga + y * ZELIARD_WIDTH + 48,
               g_game_vga + y * ZELIARD_WIDTH + 48, 224);
    if (zeliard_gmmcga_draw_first_frame_hud(
            g_death_sage_return_vga, sizeof(g_death_sage_return_vga), cs,
            sizeof(g_game_segments[0]),
            g_town_runtime.town_text_record) != 0) {
        platform_log("200FIGHT: death sage HUD reconstruction failed");
        return 0;
    }
    memcpy(g_game_vga, g_death_sage_return_vga, sizeof(g_game_vga));
    if (zeliard_room_enter(&g_town_runtime.room, ZEL_ROOM_SAGE,
                            cs, sizeof(g_game_segments[0]), g_game_vga,
                            sizeof(g_game_vga)) != 0 ||
        zeliard_gmmcga_clear_playfield(
            g_game_vga, sizeof(g_game_vga)) != 0) {
        platform_log("200FIGHT: death sage room preparation failed");
        return 0;
    }
    /* Clear the normal A027 portrait prepared by room_enter. The death
     * dispatch target A006 loads KENJA.GRP and selects centered origin 0E17h
     * before drawing its own portrait. */
    memcpy(g_death_sage_chrome_vga, g_game_vga,
           sizeof(g_death_sage_chrome_vga));
    if (!zeliard_room_masm_vm_start_death_sage(
            cs, sizeof(g_game_segments[0]), g_game_vga,
            sizeof(g_game_vga))) {
        platform_log("200FIGHT: death sage room entry failed");
        return 0;
    }
    g_town_runtime.room.exact_vm_active = 1;
    g_death_sage_chrome_active = 1;
    restore_death_sage_chrome();
    memcpy(g_framebuf, g_game_vga, ZELIARD_FB_SIZE);
    return 1;
}

static void terminate_session(void) {
    zeliard_room_masm_vm_stop();
    zeliard_inventory_masm_vm_stop();
    zeliard_fight_masm_vm_stop();
    g_fight_music_chunk = 0xFF;
    g_fight_boundary_selector = 0xFF;
    g_fight_started = 0;
    g_fight_death_pending = 0;
    g_fight_death_return_pending = 0;
    g_fight_death_audio_fade_started = 0;
    g_death_sage_chrome_active = 0;
    g_inventory_return_to_fight = 0;
    g_inventory_fight_hud_override = 0;
    zel_opening_audio_stop();
    zel_input_release_all(&g_input, g_game_segments[0], 1);
    memset(g_game_vga, 0, sizeof(g_game_vga));
    framebuf_clear(0);
    g_paused = 0;
    g_session_terminated = 1;
}

static int inventory_can_open(void) {
    return g_scene == SCENE_GAME &&
        !g_cavern_transition.active &&
        !zeliard_inventory_masm_vm_active() &&
        !g_town_runtime.dialog.active &&
        !g_town_runtime.room.active &&
        g_town_runtime.building_transition ==
            ZEL_TOWN_BUILDING_TRANSITION_NONE;
}

static void inventory_open(void) {
    if (!inventory_can_open()) return;
    const zeliard_inventory_context_t inventory_context =
        g_gameplay_location == GAMEPLAY_LOCATION_CAVERN
            ? ZEL_INVENTORY_CONTEXT_CAVERN
            : ZEL_INVENTORY_CONTEXT_TOWN;
    g_inventory_return_to_fight =
        inventory_context == ZEL_INVENTORY_CONTEXT_CAVERN;
    memcpy(g_inventory_player_before, g_game_segments[0],
           sizeof(g_inventory_player_before));
    /* 200FIGHT remains resident while 201SELCT runs, exactly like the DOS
     * caller's swap/call/swap flow. Town has no resident execution VM, so
     * only that context needs a host-side return image. */
    if (!g_inventory_return_to_fight) {
        memcpy(g_inventory_return_vga, g_game_vga,
               sizeof(g_inventory_return_vga));
        memcpy(g_inventory_return_vga, g_framebuf, ZELIARD_FB_SIZE);
    }
    /* Reproduce the selector's inherited framebuffer contract with the
     * GMMCGA:2106 clear primitive: rows 14..157 of the 224-pixel playfield
     * are black while the stone frame and HUD remain intact. */
    if (zeliard_gmmcga_clear_playfield(g_game_vga, sizeof(g_game_vga))) {
        platform_log("201SELCT: MCGA playfield clear failed");
        return;
    }
    if (!zeliard_inventory_masm_vm_start(
            g_game_segments[0], sizeof(g_game_segments[0]),
            g_game_vga, sizeof(g_game_vga),
            inventory_context)) {
        platform_log("201SELCT: exact inventory overlay start failed");
        return;
    }
    memcpy(g_framebuf, g_game_vga, ZELIARD_FB_SIZE);
    framebuf_rgb_disable();
    /* 200FIGHT:do_combat_round posts cue 0Bh immediately before calling
     * the selector. Use the same transition cue for the host-owned call. */
    zel_opening_audio_write_cue(0x0B);
}

static bool game_fetch_asset(void *context, const char *name,
                             u8 **data, size_t *size) {
    (void)context;
    *data = platform_load_asset(name, size);
    return *data != NULL;
}

static bool game_loader_service(void *context,
                                const zeliard_game_bootstrap_call_t *call,
                                zeliard_game_exec_state_t *state) {
    (void)context;
    (void)state;
    platform_log("game loader service: kind=%u AL=%u AH=%u ref=%04X ES=CS+%04X DI=%04X",
                 (unsigned)call->kind, call->al, call->ah, call->ref_offset,
                 call->es_delta, call->dest_offset);
    return true;
}

static bool game_load_direct(const char *name, u16 destination) {
    size_t size = 0;
    u8 *data = platform_load_asset(name, &size);
    if (!data || size > (size_t)ZELIARD_GAME_SEGMENT_SIZE - destination) {
        free(data);
        return false;
    }
    memcpy(g_game_segments[0] + destination, data, size);
    free(data);
    return true;
}

static void game_memory_init(void) {
    memset(g_game_segments, 0, sizeof(g_game_segments));
    memset(g_game_vga, 0, sizeof(g_game_vga));
    memset(g_cavern_town_segments, 0, sizeof(g_cavern_town_segments));
    memset(g_cavern_town_vga, 0, sizeof(g_cavern_town_vga));
    memset(&g_game_exec, 0, sizeof(g_game_exec));
    memset(&g_cavern_transition, 0, sizeof(g_cavern_transition));
    memset(&g_cavern_town_origin, 0, sizeof(g_cavern_town_origin));
    g_fight_music_chunk = 0xFF;
    g_fight_boundary_selector = 0xFF;
    g_fight_started = 0;
    g_fight_death_pending = 0;
    g_fight_death_return_pending = 0;
    g_fight_death_audio_fade_started = 0;
    g_death_sage_chrome_active = 0;
    g_gameplay_location = GAMEPLAY_LOCATION_TOWN;
    g_inventory_return_to_fight = 0;
    g_inventory_fight_hud_override = 0;
    for (size_t i = 0; i < ZELIARD_GAME_SEGMENT_COUNT; ++i) {
        g_game_exec.segment[i] = g_game_segments[i];
        g_game_exec.segment_size[i] = ZELIARD_GAME_SEGMENT_SIZE;
    }
    if (!game_load_direct("stdply.bin", 0)) {
        platform_log("game bootstrap: stdply.bin load failed");
    }
    if (!game_load_direct("gmmcga.bin", 0x2000)) {
        platform_log("game bootstrap: gmmcga.bin load failed");
    }
    /* zeliad.asm:init_game_globals stores the default F9 speed at FF33. */
    g_game_segments[0][0xFF33] = 5;
    zel_input_init(&g_input, g_game_segments[0]);
}

static void consume_opening_advance(void) {
    if (g_scene != SCENE_OPENING)
        return;
    opening_key_advance();
    if (opening_credits_exit_waiting())
        zel_opening_audio_begin_transition_fade();
    zel_opening_audio_sync_phase(opening_phase_id());
}

static void apply_input_actions(u32 actions) {
    /* restore_dlg_wait_input is a blocking MASM loop: only the Y/N timer
     * bits are observed until its saved background has been restored. */
    if (g_restore_menu_active)
        return;
    if (actions & ZEL_INPUT_ACTION_TOGGLE_MUSIC)
        zel_opening_audio_toggle_music();
    if (actions & ZEL_INPUT_ACTION_TOGGLE_SOUND)
        zel_opening_audio_toggle_sound();
    if (g_speed_menu_active) {
        const u32 dismiss = ZEL_INPUT_ACTION_ESCAPE |
            ZEL_INPUT_ACTION_SPACE | ZEL_INPUT_ACTION_ENTER |
            ZEL_INPUT_ACTION_SPEED_MENU;
        if (!g_speed_menu_selected &&
            (actions & ZEL_INPUT_ACTION_ESCAPE)) {
            /* wait_for_digit_or_esc returns with AL still holding the
             * current digit on Escape. The handler redraws/stores that
             * unchanged value, posts cue 1, then enters its dismiss wait. */
            u8 speed = g_game_segments[0][0xFF33];
            if (speed < 1u || speed > 10u)
                speed = 5u;
            opening_speed_overlay_set_digit((u8)(10u - speed));
            g_game_segments[0][0xFF75] = 1;
            zel_opening_audio_write_cue(1);
            g_speed_menu_selected = 1;
            return;
        }
        if ((actions & dismiss) && g_speed_menu_selected) {
            g_game_segments[0][0xFF1D] = 0;
            g_game_segments[0][0xFF29] = 0;
            opening_speed_overlay_hide();
            if (actions & ZEL_INPUT_ACTION_ENTER)
                zel_input_consume_key(&g_input, g_game_segments[0],
                                      ZEL_INPUT_KEY_ENTER);
            else if (actions & ZEL_INPUT_ACTION_SPACE)
                zel_input_consume_key(&g_input, g_game_segments[0],
                                      ZEL_INPUT_KEY_SPACE);
            else if (actions & ZEL_INPUT_ACTION_ESCAPE)
                zel_input_consume_key(&g_input, g_game_segments[0],
                                      ZEL_INPUT_KEY_ESCAPE);
            else if (actions & ZEL_INPUT_ACTION_SPEED_MENU)
                zel_input_consume_key(&g_input, g_game_segments[0],
                                      ZEL_INPUT_KEY_F9);
            /* STICK's modal restores only its saved rectangle. 200FIGHT's
             * resident VGA page remains untouched and resumes normally. */
            g_speed_menu_active = 0;
            g_speed_menu_selected = 0;
            g_paused = 0;
        }
        return;
    }
    if ((actions & ZEL_INPUT_ACTION_SPEED_MENU) && !g_paused &&
        g_scene == SCENE_GAME) {
        u8 speed = g_game_segments[0][0xFF33];
        if (speed < 1u || speed > 10u)
            speed = 5u;
        opening_speed_overlay_show_game(g_game_segments[0], 0x10000,
                                        (u8)(10u - speed));
        g_game_segments[0][0xFF75] = 2;
        zel_opening_audio_write_cue(2);
        g_speed_menu_active = 1;
        g_speed_menu_selected = 0;
        g_paused = 1;
        return;
    }
    if ((actions & ZEL_INPUT_ACTION_RESTORE_MENU) && !g_paused &&
        g_scene == SCENE_GAME && !zeliard_inventory_masm_vm_active()) {
        opening_restore_overlay_show_game(g_game_segments[0], 0x10000);
        g_game_segments[0][0xFF75] = 2;
        zel_opening_audio_write_cue(2);
        g_restore_menu_active = 1;
        g_paused = 1;
        return;
    }
    if ((actions & ZEL_INPUT_ACTION_ESCAPE) && !g_paused) {
        if (g_scene == SCENE_GAME)
            opening_pause_overlay_show_game(g_game_segments[0], 0x10000);
        else
            opening_pause_overlay_show();
        g_paused = 1;
        zel_opening_audio_pause();
    }
    if (actions & ZEL_INPUT_ACTION_SPACE) {
        if (g_paused) {
            g_game_segments[0][0xFF1D] = 0;
            opening_pause_overlay_hide();
            g_paused = 0;
            zel_opening_audio_resume();
        } else if (g_scene == SCENE_OPENING) {
            g_game_segments[0][0xFF1D] = 0;
            consume_opening_advance();
        }
    }
    if ((actions & ZEL_INPUT_ACTION_ENTER) && !g_paused) {
        if (g_scene == SCENE_OPENING) {
            g_game_segments[0][0xFF29] = 0;
            consume_opening_advance();
        } else if (g_scene == SCENE_GAME) inventory_open();
    }
}

static bool enter_game_scene(void) {
    zeliard_player_state_t player;
    if (!zeliard_player_state_bind(
            &player, g_game_segments[0], sizeof(g_game_segments[0]))) {
        return false;
    }
    const zeliard_game_exec_services_t services = {
        .fetch_asset = game_fetch_asset,
        .loader_service = game_loader_service,
    };
    /* 100OPDMO:transition_out_to_game loads the ordinary DOS file game.bin
     * at CS:A000, sets AX=FFFFh, then jumps through CS:[6A73] = A000h. */
    if (!game_load_direct("game.bin", 0xA000)) {
        platform_log("game bootstrap: game.bin load failed");
        return false;
    }
    const zeliard_game_bootstrap_input_t input = {
        .load_saved_game = true,
        .gfx_mode = 4,
        .sword = zeliard_player_read_u8(&player, ZEL_PLAYER_SWORD),
        .shield = zeliard_player_read_u8(&player, ZEL_PLAYER_SHIELD),
        .selected_spell = zeliard_player_read_u8(&player, ZEL_PLAYER_SELECTED_SPELL),
        .music_track_count = zeliard_player_read_u8(&player, ZEL_PLAYER_TEARS),
        .current_area_id = zeliard_player_read_u8(&player, ZEL_PLAYER_SAVE_SAGE),
        .level_music_source = g_game_segments[0][0xC000],
        .town_sprite_source = g_game_segments[0][0xC001],
    };
    if (!zeliard_game_execute_bootstrap(&g_game_exec, &input, &services) ||
        !g_game_exec.branched ||
        g_game_exec.branch_target != ZELIARD_GAME_BOOT_BRANCH_GAME_LOOP) {
        platform_log("game bootstrap: game.asm execution failed");
        return false;
    }
    /* The saved-game path has just loaded town.bin at CS:6000. Release
     * 106TOWN:init_entry therefore sets town_init_flag and does not run the
     * five-step side-door entrance animation over the restored coordinates. */
    if (zeliard_town_enter_saved_first_frame(
            &g_town_runtime, &g_game_exec, g_game_vga,
            sizeof(g_game_vga)) != 0) {
        platform_log("game bootstrap: first 106TOWN castle frame failed");
        return false;
    }
    g_gameplay_location = GAMEPLAY_LOCATION_TOWN;
    memcpy(g_framebuf, g_game_vga, ZELIARD_FB_SIZE);
    /* game.asm:A1E0 resolves CMAP's descriptor byte 00 to record 0 at
     * A363 (MGT1.MSD). 106TOWN:60A9 starts that game_seg:3000 score with
     * INT 60h AX=0 immediately after the initial town draw. */
    if (!zel_audio_play_music(current_town_music())) {
        platform_log("game bootstrap: exact town music start failed");
        return false;
    }
    g_scene = SCENE_GAME;
    platform_log("zeliard_tick: saved town frame ready (area=%u, %u boot, %u town events)",
                 (unsigned)g_town_runtime.area,
                 (unsigned)g_game_exec.event_count,
                 (unsigned)g_town_runtime.event_count);
    return true;
}

EXPORT void zeliard_init(void) {
    framebuf_clear(0);
    game_memory_init();
    g_scene = SCENE_OPENING;
    g_paused = 0;
    g_speed_menu_active = 0;
    g_speed_menu_selected = 0;
    g_restore_menu_active = 0;
    g_gamepad_directions = 0;
    g_gamepad_buttons = 0;
    g_session_terminated = 0;
    g_input_subtick_accum = 0;
    g_guest_tick_count = 0;
    zel_opening_audio_init();
    opening_set_sound_cue_sink(zel_opening_audio_write_cue);
    opening_init();
    opening_tick(0);
    zel_opening_audio_sync_phase(opening_phase_id());
    platform_log("zeliard_init: ready (framebuffer %dx%d)", ZELIARD_WIDTH, ZELIARD_HEIGHT);
}

EXPORT void zeliard_tick(u32 dt_ms) {
    if (g_session_terminated) return;
    const int was_paused = g_paused;
    const u32 input_ticks =
        zel_timer_advance_ms(&g_input_subtick_accum, dt_ms);
    g_guest_tick_count += input_ticks;
    apply_input_actions(zel_input_advance_pit(
        &g_input, g_game_segments[0], input_ticks));
    if (was_paused) {
        if (g_paused)
            zel_opening_audio_tick(dt_ms);
        return;
    }
    if (g_paused) {
        zel_opening_audio_tick(dt_ms);
        return;
    }
    if (g_scene == SCENE_GAME) {
        if (g_fight_death_return_pending) {
            /* The VM has just completed fade_step_loop and
             * drv_fade_to_black. Preserve that final cavern frame/palette
             * across a host presentation boundary, and do not enter the sage
             * room until the paired music fade has completed. */
            if (zel_opening_audio_ready_for_transition())
                finish_cavern_death_to_sage();
            zel_opening_audio_tick(dt_ms);
            return;
        }
        if (g_cavern_transition.active) {
            const int frames = zeliard_cavern_transition_advance_pit(
                &g_cavern_transition, g_game_segments[0],
                sizeof(g_game_segments[0]), g_game_vga,
                sizeof(g_game_vga), input_ticks);
            if (frames > 0)
                memcpy(g_framebuf, g_game_vga, ZELIARD_FB_SIZE);
            zel_opening_audio_tick(dt_ms);
            return;
        }
        if (g_cavern_transition.complete &&
            g_cavern_transition.return_to_town) {
            finish_cavern_return_to_town();
            zel_opening_audio_tick(dt_ms);
            return;
        }
        if (g_cavern_transition.complete &&
            !zeliard_fight_masm_vm_active() && !g_fight_started) {
            if (!zeliard_fight_masm_vm_start(
                    g_game_segments[0], sizeof(g_game_segments[0]),
                    g_game_vga, sizeof(g_game_vga))) {
                platform_log("200FIGHT: exact cavern runtime start failed");
            } else {
                g_fight_started = 1;
                g_gameplay_location = GAMEPLAY_LOCATION_CAVERN;
                g_inventory_fight_hud_override = 0;
                g_fight_death_pending = 0;
                g_fight_death_return_pending = 0;
                g_fight_death_audio_fade_started = 0;
                g_fight_regen_pit_ticks = 0;
                g_fight_regen_frames = 0;
                g_fight_boundary_selector = 0xFF;
                memcpy(g_framebuf, g_game_vga, ZELIARD_FB_SIZE);
                sync_fight_audio_globals();
                sync_fight_music();
            }
            zel_opening_audio_tick(dt_ms);
            return;
        }
        if (zeliard_inventory_masm_vm_active()) {
            const u16 timer_counter = (u16)(g_game_segments[0][0xFF18] |
                ((u16)g_game_segments[0][0xFF19] << 8));
            zeliard_inventory_masm_vm_advance(
                g_game_segments[0], sizeof(g_game_segments[0]),
                g_game_vga, sizeof(g_game_vga), input_ticks,
                g_game_segments[0][0xFF17],
                g_game_segments[0][0xFF1D] != 0,
                (timer_counter & 1u) != 0);
            u8 inventory_cue;
            while ((inventory_cue =
                    zeliard_inventory_masm_vm_take_sound_cue()) != 0)
                zel_opening_audio_write_cue(inventory_cue);
            g_game_segments[0][0xFF75] = 0;
            if (zeliard_inventory_masm_vm_active()) {
                memcpy(g_framebuf, g_game_vga, ZELIARD_FB_SIZE);
            } else {
                if (g_inventory_return_to_fight) {
                    /* Return to the resident 200FIGHT loop. Do not restore a
                     * saved screen: its private VGA and world state remained
                     * live while 201SELCT executed. */
                    g_inventory_fight_hud_override = memcmp(
                        g_inventory_player_before, g_game_segments[0],
                        sizeof(g_inventory_player_before)) != 0;
                    zeliard_fight_masm_vm_restore_game_state(
                        g_game_segments[0], sizeof(g_game_segments[0]));
                    /* The close key belongs to 201SELCT, not the resumed
                     * fight loop. Match combat_palette_update's reset. */
                    g_game_segments[0][0xFF18] &= 0xFEu;
                    g_game_segments[0][0xFF1D] = 0;
                    g_game_segments[0][0xFF1E] = 0;
                    zel_opening_audio_write_cue(0x0B);
                    g_inventory_return_to_fight = 0;
                    /* Fall through and advance 200FIGHT in this same host
                     * tick, reproducing the normal post-selector return. */
                } else {
                    memcpy(g_game_vga, g_inventory_return_vga,
                           sizeof(g_inventory_return_vga));
                    /* 201SELCT changes DS:009Dh in place. The DOS caller's
                     * GMMCGA path redraws the selected spell frame and
                     * 106TOWN charge after returning; replay those writes
                     * over the restored town framebuffer. */
                    const u8 spell = g_game_segments[0]
                        [ZEL_PLAYER_SELECTED_SPELL];
                    if (spell) {
                        zeliard_gmmcga_draw_equipped_spell(
                            g_game_vga, sizeof(g_game_vga),
                            g_game_segments[1], sizeof(g_game_segments[1]),
                            spell, 0x37A4);
                        zeliard_gmmcga_draw_status_line(
                            g_game_vga, sizeof(g_game_vga), 0,
                            0xAA1C, 0x1700);
                        zeliard_gmmcga_draw_spell_charge(
                            g_game_vga, sizeof(g_game_vga),
                            g_game_segments[0], sizeof(g_game_segments[0]));
                    }
                    memcpy(g_framebuf, g_game_vga, ZELIARD_FB_SIZE);
                    framebuf_rgb_disable();
                    zel_opening_audio_write_cue(0x0B);
                    g_inventory_return_to_fight = 0;
                    zel_opening_audio_tick(dt_ms);
                    return;
                }
            }
            if (zeliard_inventory_masm_vm_active()) {
                zel_opening_audio_tick(dt_ms);
                return;
            }
        }
        if (zeliard_fight_masm_vm_active()) {
            if (zeliard_fight_masm_vm_ending_active()) {
                const int frames = zeliard_fight_masm_vm_advance(
                    g_game_segments[0], sizeof(g_game_segments[0]),
                    g_game_vga, sizeof(g_game_vga), input_ticks,
                    g_game_segments[0][0xFF17]);
                if (frames > 0)
                    memcpy(g_framebuf, g_game_vga, ZELIARD_FB_SIZE);
                sync_fight_music();
                zel_opening_audio_tick(dt_ms);
                return;
            }
            if (zeliard_fight_masm_vm_music_chunk() == 95 &&
                zel_opening_audio_ready_for_transition()) {
                /* Exact driver's score-complete callback writes FF26h=FFh,
                 * releasing 300ROKAD:wait_enable_all. */
                g_game_segments[0][0xFF26] = 0xFF;
                zeliard_fight_masm_vm_poke_u8(0xFF26, 0xFF);
            }
            const u16 hp_before = (u16)(g_game_segments[0][ZEL_PLAYER_HP] |
                ((u16)g_game_segments[0][ZEL_PLAYER_HP + 1] << 8));
            if (hp_before <= 1) begin_fight_death();
            const u16 map_width_before =
                zeliard_fight_masm_vm_peek_u16(0xC002);
            const int frames = zeliard_fight_masm_vm_advance(
                g_game_segments[0], sizeof(g_game_segments[0]),
                g_game_vga, sizeof(g_game_vga), input_ticks,
                g_game_segments[0][0xFF17]);
            if (zeliard_fight_masm_vm_ending_requested()) {
                g_fight_death_pending = 0;
                g_fight_death_return_pending = 0;
                g_fight_death_audio_fade_started = 0;
                g_fight_music_chunk =
                    zeliard_fight_masm_vm_music_chunk();
                if (!zeliard_fight_masm_vm_begin_ending())
                    platform_log("319MAO2: 250ENDMO overlay handoff failed");
                zel_opening_audio_tick(dt_ms);
                return;
            }
            const u16 hp_after_vm = (u16)(
                g_game_segments[0][ZEL_PLAYER_HP] |
                ((u16)g_game_segments[0][ZEL_PLAYER_HP + 1] << 8));
            const int passive_life_restored =
                advance_fight_passive_life_restoration(
                    input_ticks, hp_before, hp_after_vm);
            if (g_inventory_fight_hud_override || passive_life_restored) {
                zeliard_gmmcga_draw_life_current(
                    g_game_vga, sizeof(g_game_vga), g_game_segments[0],
                    sizeof(g_game_segments[0]));
                if (g_game_segments[0][ZEL_PLAYER_SELECTED_SPELL]) {
                    /* 200FIGHT:combat_palette_update returns from
                     * 201SELCT through the MCGA equipment renderer before
                     * presenting the next combat frame.  Refresh both the
                     * selected spell portrait and its charge; otherwise a
                     * live Fuego -> Saeta change leaves Fuego's portrait in
                     * the resident fight VGA page. */
                    zeliard_gmmcga_draw_equipped_spell(
                        g_game_vga, sizeof(g_game_vga),
                        g_game_segments[1], sizeof(g_game_segments[1]),
                        g_game_segments[0][ZEL_PLAYER_SELECTED_SPELL],
                        0x37A4);
                    zeliard_gmmcga_draw_spell_charge(
                        g_game_vga, sizeof(g_game_vga), g_game_segments[0],
                        sizeof(g_game_segments[0]));
                }
                if (g_game_segments[0][ZEL_PLAYER_SHIELD])
                    zeliard_gmmcga_draw_shield_hp(
                        g_game_vga, sizeof(g_game_vga), g_game_segments[0],
                        sizeof(g_game_segments[0]));
                zeliard_fight_masm_vm_restore_vga(
                    g_game_vga, sizeof(g_game_vga));
                g_inventory_fight_hud_override = 0;
            }
            const u16 map_width_after =
                zeliard_fight_masm_vm_peek_u16(0xC002);
            if (map_width_before != 96u && map_width_after == 96u) {
                g_fight_connector_music_fade = 1;
                zel_opening_audio_begin_gameplay_transition_fade();
            }
            const u16 hp_after = (u16)(g_game_segments[0][ZEL_PLAYER_HP] |
                ((u16)g_game_segments[0][ZEL_PLAYER_HP + 1] << 8));
            if (hp_after <= 1) begin_fight_death();
            if (g_fight_death_pending &&
                !g_fight_death_audio_fade_started &&
                g_game_segments[0][0xFF24] == 8) {
                /* Exact 200FIGHT:fade_out boundary. FF24=8 is both the
                 * game-over wipe mode and MSCADLIB's fade interval. */
                g_fight_death_audio_fade_started = 1;
                zel_opening_audio_begin_gameplay_death_fade();
            }
            if (frames > 0)
                memcpy(g_framebuf, g_game_vga, ZELIARD_FB_SIZE);
            sync_fight_audio_globals();
            if (frames > 0)
                framebuf_rgb_disable();
            u8 fight_cue;
            while ((fight_cue =
                    zeliard_fight_masm_vm_take_sound_cue()) != 0)
                zel_opening_audio_write_cue(fight_cue);
            g_game_segments[0][0xFF75] = 0;
            sync_fight_music();
            if (!zeliard_fight_masm_vm_active()) {
                g_inventory_fight_hud_override = 0;
                const u8 operation = zeliard_fight_masm_vm_exit_operation();
                const u8 selector = zeliard_fight_masm_vm_exit_selector();
                const u16 dispatch =
                    zeliard_fight_masm_vm_exit_dispatch_slot();
                const int town_warp = operation == 1 &&
                    (selector & 0x80u) && selector != 0x80u;
                if (fight_boundary_returns_to_town(
                        operation, selector, dispatch)) {
                    g_cavern_transition.complete = 0;
                    g_fight_started = 0;
                    if (g_fight_death_pending) {
                        /* Do not overwrite drv_fade_to_black's result with
                         * the sage room in this same browser frame. */
                        g_fight_death_return_pending = 1;
                        zel_opening_audio_tick(dt_ms);
                        return;
                    }
                    if (town_warp && !g_fight_death_pending) {
                        /* 200FIGHT:check_c3 keeps the cavern score running
                         * throughout the reverse ROKA walk.  level_start is
                         * the first subsequent INT 60h AX=1 boundary. */
                        g_fight_music_chunk = 0xFF;
                        if (zeliard_cavern_transition_begin_return(
                                &g_cavern_transition, selector,
                                g_game_segments[0],
                                sizeof(g_game_segments[0]), g_game_vga,
                                sizeof(g_game_vga)) != 0) {
                            platform_log(
                                "200FIGHT: reverse cavern transition failed");
                            g_game_segments[0][0x00C4] = selector;
                            finish_cavern_return_to_town();
                        } else {
                            zel_opening_audio_begin_gameplay_transition_fade();
                            memcpy(g_framebuf, g_game_vga,
                                   ZELIARD_FB_SIZE);
                        }
                        zel_opening_audio_tick(dt_ms);
                        return;
                    }
                    g_fight_death_pending = 0;
                    g_gameplay_location = GAMEPLAY_LOCATION_TOWN;
                    if (!zeliard_town_area_supported(
                            g_game_segments[0][0x00C4])) {
                        const u8 saved_area = g_game_segments[0][0x00C5];
                        g_game_segments[0][0x00C4] =
                            zeliard_town_area_supported(saved_area)
                                ? saved_area
                                : (u8)(0x80u + (u8)g_town_runtime.area);
                    }
                    zel_opening_audio_stop();
                    g_fight_music_chunk = 0xFF;
                    if (zeliard_town_enter_first_frame(
                            &g_town_runtime, &g_game_exec, g_game_vga,
                            sizeof(g_game_vga)) != 0) {
                        platform_log("200FIGHT: town return frame failed");
                    } else {
                        memcpy(g_framebuf, g_game_vga, ZELIARD_FB_SIZE);
                        zel_audio_play_music(current_town_music());
                    }
                } else {
                    g_fight_boundary_selector = selector;
                    platform_log("200FIGHT: outbound boundary AL=%u AH=%u BX=%04X",
                                 (unsigned)operation, (unsigned)selector,
                                 dispatch);
                }
            }
            zel_opening_audio_tick(dt_ms);
            return;
        }
        if (g_fight_boundary_selector != 0xFF) {
            zel_opening_audio_tick(dt_ms);
            return;
        }
        const int room_was_active = g_town_runtime.room.active;
        const zeliard_town_area_t town_area_before = g_town_runtime.area;
        cavern_town_origin_t town_origin = {
            .valid = 1,
            .area_id = g_game_segments[0][ZEL_PLAYER_SAVE_SAGE],
            .start_position = (u16)(
                g_game_segments[0][ZEL_PLAYER_START_POSITION] |
                ((u16)g_game_segments[0][ZEL_PLAYER_START_POSITION + 1]
                 << 8)),
            .map_scroll_row =
                g_game_segments[0][ZEL_PLAYER_MAP_SCROLL_ROW],
            .screen_position =
                g_game_segments[0][ZEL_PLAYER_SCREEN_POSITION],
        };
        const int cavern_snapshot_ready =
            (g_game_segments[0][0xFF17] & 1u) != 0;
        if (cavern_snapshot_ready) {
            memcpy(g_cavern_town_segments, g_game_segments,
                   sizeof(g_cavern_town_segments));
            memset(g_cavern_town_vga, 0, sizeof(g_cavern_town_vga));
            memcpy(g_cavern_town_vga, g_framebuf, ZELIARD_FB_SIZE);
        }
        const int frames = zeliard_town_advance_pit(
            &g_town_runtime, &g_game_exec, g_game_vga, sizeof(g_game_vga),
            input_ticks, g_game_segments[0][0xFF17]);
        if (g_death_sage_chrome_active) {
            if (g_town_runtime.room.active)
                restore_death_sage_chrome();
            else
                g_death_sage_chrome_active = 0;
        }
        if (g_town_runtime.room.session_exit_requested) {
            terminate_session();
            return;
        }
        if (frames < 0) {
            platform_log("zeliard_tick: 106TOWN live frame failed (%d)", frames);
        } else if (frames > 0) {
            memcpy(g_framebuf, g_game_vga, ZELIARD_FB_SIZE);
        }
        if (g_town_runtime.cavern_exit_requested) {
            if (!zeliard_town_area_supported(town_origin.area_id))
                town_origin.area_id =
                    (u8)(0x80u + (u8)g_town_runtime.area);
            g_cavern_town_origin = town_origin;
            if (!cavern_snapshot_ready) {
                memcpy(g_cavern_town_segments, g_game_segments,
                       sizeof(g_cavern_town_segments));
                memset(g_cavern_town_vga, 0, sizeof(g_cavern_town_vga));
                memcpy(g_cavern_town_vga, g_framebuf, ZELIARD_FB_SIZE);
            }
            /* 106TOWN hands off to 200FIGHT without an audio-driver call.
             * Keep MGT1 running through check_c3's 26-step ROKA walk; the
             * destination level_start boundary switches to MUS1. */
            if (zeliard_cavern_transition_begin(
                    &g_cavern_transition, g_game_segments[0],
                    sizeof(g_game_segments[0]), g_game_vga,
                    sizeof(g_game_vga)) != 0) {
                platform_log("200FIGHT: cavern transition start failed");
            } else {
                zel_opening_audio_begin_gameplay_transition_fade();
                memcpy(g_framebuf, g_game_vga, ZELIARD_FB_SIZE);
            }
        }
        /* 106TOWN:door_type_shop invokes INT 60h AX=1 after the blocking
         * MCGA entry fade and reloads/plays the current town score only after
         * the room program returns. */
        if (!room_was_active && g_town_runtime.room.active)
            zel_opening_audio_stop();
        else if (room_was_active && !g_town_runtime.room.active)
            zel_audio_play_music(current_town_music());
        else if (town_area_before != g_town_runtime.area)
            zel_audio_play_music(current_town_music());
        if (g_town_runtime.dialog.pending_sound_cue) {
            zel_opening_audio_write_cue(
                g_town_runtime.dialog.pending_sound_cue);
            g_town_runtime.dialog.pending_sound_cue = 0;
        }
        if (g_town_runtime.room.pending_sound_cue) {
            zel_opening_audio_write_cue(
                g_town_runtime.room.pending_sound_cue);
            g_town_runtime.room.pending_sound_cue = 0;
        }
        zel_opening_audio_tick(dt_ms);
        return;
    }
    while (dt_ms > 0 || (dt_ms == 0 && g_scene == SCENE_OPENING)) {
        u32 step_ms = dt_ms > 100 ? 100 : dt_ms;
        if (g_scene == SCENE_OPENING) {
            if (opening_credits_exit_waiting())
                zel_opening_audio_begin_transition_fade();
            zel_opening_audio_tick(step_ms);
            if (opening_credits_exit_waiting() &&
                zel_opening_audio_ready_for_transition())
                opening_credits_exit_release();
            opening_tick(step_ms);
            zel_opening_audio_sync_phase(opening_phase_id());
            if (opening_done() && !enter_game_scene())
                break;
        }
        if (dt_ms <= step_ms)
            break;
        dt_ms -= step_ms;
    }
}

/* Browser keycodes enter the same make/break state machine as stick.asm. */
EXPORT void zeliard_key_down(int keycode) {
    if (g_session_terminated) return;
    apply_input_actions(zel_input_key_down(
        &g_input, g_game_segments[0], keycode));
}

EXPORT void zeliard_key_up(int keycode) {
    if (g_session_terminated) return;
    zel_input_key_up(&g_input, g_game_segments[0], keycode);
}

EXPORT void zeliard_text_key(int ascii) {
    if (g_session_terminated) return;
    if (g_restore_menu_active) {
        if (ascii >= 'a' && ascii <= 'z') ascii -= 'a' - 'A';
        if (ascii != 'Y' && ascii != 'N') return;
        /* stick.asm waits for timer bits 20h (Y) or 40h (N), restores the
         * saved box, and returns carry only for Y. */
        opening_restore_overlay_hide();
        g_game_segments[0][0xFF17] = 0;
        g_game_segments[0][0xFF1D] = 0;
        g_game_segments[0][0xFF1E] = 0;
        g_restore_menu_active = 0;
        g_paused = 0;
        if (ascii == 'Y') ++g_load_request_serial;
        return;
    }
    if (g_speed_menu_active && ascii >= '0' && ascii <= '9') {
        const u8 digit = (u8)(ascii - '0');
        const u8 speed = (u8)(10u - digit);
        g_game_segments[0][0xFF33] = speed;
        if (zeliard_fight_masm_vm_active())
            zeliard_fight_masm_vm_poke_u8(0xFF33, speed);
        opening_speed_overlay_set_digit(digit);
        g_game_segments[0][0xFF75] = 1;
        zel_opening_audio_write_cue(1);
        g_speed_menu_selected = 1;
        return;
    }
    if (g_scene != SCENE_GAME || !g_town_runtime.room.active ||
        g_town_runtime.room.kind != ZEL_ROOM_SAGE) return;
    if (ascii >= 'a' && ascii <= 'z') ascii -= 'a' - 'A';
    if ((ascii >= 'A' && ascii <= 'Z') ||
        (ascii >= '0' && ascii <= '9') || ascii == 8)
        zeliard_room_masm_vm_text_key((u8)ascii);
}

/* Browser Gamepad API input enters the same MASM-shaped direction and button
 * bytes as keyboard input. Raw masks are retained so modal overlays can
 * consume controller edges without leaking held movement into gameplay. */
EXPORT void zeliard_gamepad_update(int connected, int directions, int buttons) {
    if (g_session_terminated) return;
    const u8 next_directions = connected ? (u8)(directions & 0x0F) : 0;
    const u8 next_buttons = connected ? (u8)buttons : 0;
    const u8 direction_edges =
        (u8)(next_directions & (u8)~g_gamepad_directions);
    const u8 button_edges = (u8)(next_buttons & (u8)~g_gamepad_buttons);
    g_gamepad_directions = next_directions;
    g_gamepad_buttons = next_buttons;
    /* stick.asm uses FF0A as the saved joystick-enabled flag. */
    g_game_segments[0][0xFF0A] = connected ? 0xFF : 0;

    if (g_restore_menu_active) {
        (void)zel_input_gamepad_update(&g_input, g_game_segments[0], 0,
            (u8)(next_buttons & ~(ZEL_GAMEPAD_A | ZEL_GAMEPAD_B)));
        if (button_edges & ZEL_GAMEPAD_A)
            zeliard_text_key('Y');
        else if (button_edges & ZEL_GAMEPAD_B)
            zeliard_text_key('N');
        return;
    }
    if (g_speed_menu_active && !g_speed_menu_selected) {
        (void)zel_input_gamepad_update(&g_input, g_game_segments[0], 0,
            (u8)(next_buttons & ~ZEL_GAMEPAD_A));
        if ((button_edges & ZEL_GAMEPAD_A) || direction_edges) {
            u8 speed = g_game_segments[0][0xFF33];
            u8 digit;
            if (speed < 1u || speed > 10u) speed = 5u;
            digit = (u8)(10u - speed);
            if (direction_edges & (ZEL_GAMEPAD_UP | ZEL_GAMEPAD_RIGHT))
                digit = (u8)((digit + 9u) % 10u);
            else if (direction_edges &
                     (ZEL_GAMEPAD_DOWN | ZEL_GAMEPAD_LEFT))
                digit = (u8)((digit + 1u) % 10u);
            zeliard_text_key('0' + digit);
        }
        return;
    }
    u32 actions = zel_input_gamepad_update(
        &g_input, g_game_segments[0], next_directions, next_buttons);
    /* Start is a controller-friendly pause toggle.  The original pause wait
     * exits through the same Space action used by keyboard confirmation. */
    if (g_paused && (button_edges & ZEL_GAMEPAD_START))
        actions |= ZEL_INPUT_ACTION_SPACE;
    apply_input_actions(actions);
}

EXPORT void zeliard_release_all_keys(void) {
    if (g_session_terminated) return;
    zel_input_release_all(&g_input, g_game_segments[0], 1);
    g_gamepad_directions = 0;
    g_gamepad_buttons = 0;
    g_game_segments[0][0xFF0A] = 0;
}

/* Compatibility pulse for older native callers. Browser code uses down/up. */
EXPORT void zeliard_key(int keycode) {
    if (g_session_terminated) return;
    /* Arm stick.asm's make-edge latch during an idle sample first. */
    apply_input_actions(zel_input_advance_pit(
        &g_input, g_game_segments[0], 10));
    u32 actions = zel_input_key_down(&g_input, g_game_segments[0], keycode);
    actions |= zel_input_advance_pit(&g_input, g_game_segments[0], 5);
    apply_input_actions(actions);
    zel_input_key_up(&g_input, g_game_segments[0], keycode);
    apply_input_actions(zel_input_advance_pit(
        &g_input, g_game_segments[0], 5));
}

EXPORT u8*              zeliard_framebuf(void) { return g_framebuf; }
EXPORT u8*              zeliard_rgb_framebuf(void) { return g_rgb_framebuf; }
EXPORT int              zeliard_rgb_framebuf_active(void) { return g_rgb_framebuf_active; }
EXPORT palette_color_t* zeliard_palette(void)  { return g_palette; }
EXPORT int              zeliard_width(void)    { return ZELIARD_WIDTH; }
EXPORT int              zeliard_height(void)   { return ZELIARD_HEIGHT; }
EXPORT int              zeliard_scene(void)    { return (int)g_scene; }
EXPORT int              zeliard_phase(void)    { return opening_phase_id(); }
EXPORT u32              zeliard_phase_elapsed(void) { return opening_phase_elapsed_ms(); }
EXPORT int              zeliard_music_track(void) { return zel_opening_audio_music_track(); }
EXPORT void             zeliard_music_complete(int track) { zel_opening_audio_music_complete(track); }
EXPORT int              zeliard_music_attenuation(void) { return zel_opening_audio_attenuation(); }
EXPORT int              zeliard_paused(void) { return g_paused; }
EXPORT int              zeliard_speed_menu_active(void) { return g_speed_menu_active; }
EXPORT int              zeliard_restore_menu_active(void) { return g_restore_menu_active; }
EXPORT u32              zeliard_load_request_serial(void) { return g_load_request_serial; }
EXPORT int              zeliard_game_speed_digit(void) {
    const u8 speed = g_game_segments[0][0xFF33];
    return speed >= 1u && speed <= 10u ? 10 - speed : 5;
}
EXPORT int              zeliard_session_terminated(void) { return g_session_terminated; }
EXPORT int              zeliard_music_enabled(void) { return zel_opening_audio_music_enabled(); }
EXPORT int              zeliard_sound_enabled(void) { return zel_opening_audio_sound_enabled(); }
EXPORT int              zeliard_sound_cue(void) { return (int)zel_opening_audio_take_cue(); }
EXPORT int              zeliard_audio_pcm(short *stereo, int frames) {
    return frames > 0 ? (int)zel_opening_audio_read_pcm(stereo, (size_t)frames) : 0;
}
EXPORT int              zeliard_audio_pcm_available(void) { return (int)zel_opening_audio_pcm_available(); }
EXPORT int              zeliard_exact_music_driver(void) { return zel_opening_audio_exact_driver_active(); }
EXPORT void             zeliard_audio_set_sample_rate(int sample_rate) { zel_opening_audio_set_sample_rate(sample_rate); }
EXPORT u32              zeliard_audio_opl_write_count(void) { return zel_opening_audio_opl_write_count(); }
EXPORT u32              zeliard_audio_generated_peak(void) { return zel_opening_audio_generated_peak(); }
EXPORT u32              zeliard_audio_cue_serial(void) { return zel_opening_audio_cue_serial(); }
EXPORT u32              zeliard_audio_reset_serial(void) { return zel_opening_audio_reset_serial(); }
EXPORT int              zeliard_audio_set_backend(int backend) { return zel_opening_audio_set_backend(backend); }
EXPORT int              zeliard_audio_backend(void) { return zel_opening_audio_backend(); }
EXPORT int              zeliard_audio_backend_fallback(void) { return zel_opening_audio_backend_fallback(); }
EXPORT void             zeliard_opening_set_phase_for_test(int phase) {
    opening_set_phase_for_test(phase);
    zel_opening_audio_sync_phase(opening_phase_id());
}
EXPORT u32              zeliard_opening_nec_hou_sprite_debug_word(void) { return opening_nec_hou_sprite_debug_word(); }
#ifndef __EMSCRIPTEN__
int zeliard_test_town_dialog_active(void) { return g_town_runtime.dialog.active; }
int zeliard_test_fight_returns_to_town(int operation, int selector,
                                       int dispatch) {
    return fight_boundary_returns_to_town(
        (u8)operation, (u8)selector, (u16)dispatch);
}
static int test_begin_malicia_at(u16 hp, u16 start_position,
                                  u8 map_scroll_row,
                                  int screen_position) {
    if (g_scene != SCENE_GAME) return 0;
    u8 *cs = g_game_segments[0];
    zeliard_room_masm_vm_stop();
    zeliard_inventory_masm_vm_stop();
    zeliard_fight_masm_vm_stop();
    cs[0x0080] = (u8)start_position;
    cs[0x0082] = map_scroll_row;
    if (screen_position >= 0) {
        cs[0x0081] = (u8)(start_position >> 8);
        cs[0x0083] = (u8)screen_position;
    }
    cs[0x0085] = 0;
    cs[0x0086] = 0x64;
    cs[0x0087] = 0;
    cs[0x008B] = 0x64;
    cs[0x008C] = 0;
    cs[0x0090] = (u8)hp;
    cs[0x0091] = (u8)(hp >> 8);
    cs[0x00B2] = 0;
    cs[0x00B3] = 1;
    cs[0x00C4] = 0;
    cs[0x00C5] = 0x81;
    cs[0xFF33] = 5;
    memset(&g_cavern_transition, 0, sizeof(g_cavern_transition));
    g_cavern_transition.complete = 1;
    g_fight_started = 1;
    g_gameplay_location = GAMEPLAY_LOCATION_CAVERN;
    g_fight_death_pending = 0;
    g_fight_death_return_pending = 0;
    g_fight_death_audio_fade_started = 0;
    g_inventory_fight_hud_override = 0;
    g_fight_regen_pit_ticks = 0;
    g_fight_regen_frames = 0;
    return zeliard_fight_masm_vm_start(
        cs, sizeof(g_game_segments[0]), g_game_vga, sizeof(g_game_vga));
}
static int test_begin_malicia(u16 hp) {
    return test_begin_malicia_at(hp, 26 - 16, (23 - 9) & 0x3F, -1);
}
int zeliard_test_begin_malicia_combat(void) {
    return test_begin_malicia(0x0100);
}
int zeliard_test_begin_malicia_transition(void) {
    if (g_scene != SCENE_GAME) return 0;
    g_fight_started = 0;
    g_fight_music_chunk = 0xFF;
    const int started = zeliard_cavern_transition_begin(
        &g_cavern_transition, g_game_segments[0],
        sizeof(g_game_segments[0]), g_game_vga, sizeof(g_game_vga)) == 0;
    if (started) zel_opening_audio_begin_gameplay_transition_fade();
    return started;
}
int zeliard_test_begin_malicia_exit(void) {
    if (g_scene != SCENE_GAME) return 0;
    u8 *cs = g_game_segments[0];
    memcpy(g_cavern_town_segments, g_game_segments,
           sizeof(g_cavern_town_segments));
    memset(g_cavern_town_vga, 0, sizeof(g_cavern_town_vga));
    memcpy(g_cavern_town_vga, g_framebuf, ZELIARD_FB_SIZE);
    g_cavern_town_origin = (cavern_town_origin_t){
        .valid = 1,
        .area_id = 0x81,
        .start_position = (u16)(cs[ZEL_PLAYER_START_POSITION] |
            ((u16)cs[ZEL_PLAYER_START_POSITION + 1] << 8)),
        .map_scroll_row = cs[ZEL_PLAYER_MAP_SCROLL_ROW],
        .screen_position = cs[ZEL_PLAYER_SCREEN_POSITION],
    };
    cs[ZEL_PLAYER_FACING_DIRECTION] = 0;
    cs[ZEL_PLAYER_BOSS_INTRO_FLAG] = 0;
    if (!test_begin_malicia_at(0x0100, 0x2D, 0x3D, 0)) return 0;
    return 1;
}
int zeliard_test_begin_malicia_death(void) {
    u8 *cs = g_game_segments[0];
    memcpy(g_cavern_town_segments, g_game_segments,
           sizeof(g_cavern_town_segments));
    memset(g_cavern_town_vga, 0, sizeof(g_cavern_town_vga));
    memcpy(g_cavern_town_vga, g_framebuf, ZELIARD_FB_SIZE);
    g_cavern_town_origin = (cavern_town_origin_t){
        .valid = 1,
        .area_id = cs[ZEL_PLAYER_SAVE_SAGE],
        .start_position = (u16)(cs[ZEL_PLAYER_START_POSITION] |
            ((u16)cs[ZEL_PLAYER_START_POSITION + 1] << 8)),
        .map_scroll_row = cs[ZEL_PLAYER_MAP_SCROLL_ROW],
        .screen_position = cs[ZEL_PLAYER_SCREEN_POSITION],
    };
    return test_begin_malicia(0x0010);
}
int zeliard_test_redraw_town(void) {
    if (g_scene != SCENE_GAME ||
        zeliard_town_enter_first_frame(&g_town_runtime, &g_game_exec,
                                       g_game_vga,
                                       sizeof(g_game_vga)) != 0)
        return 0;
    memcpy(g_framebuf, g_game_vga, ZELIARD_FB_SIZE);
    g_gameplay_location = GAMEPLAY_LOCATION_TOWN;
    return 1;
}
#endif
EXPORT u32              zeliard_opening_nec_hou_sprite_debug_slots(void) { return opening_nec_hou_sprite_debug_slots(); }
EXPORT int              zeliard_room_kind(void) { return (int)g_town_runtime.room.kind; }
EXPORT int              zeliard_room_input_kind(void) {
    return zeliard_room_masm_vm_input_kind();
}
EXPORT int              zeliard_room_ip(void) {
    return zeliard_room_masm_vm_active() ? zeliard_room_masm_vm_ip() : -1;
}
EXPORT u32              zeliard_save_serial(void) {
    return zeliard_room_masm_vm_save_serial();
}
EXPORT const char      *zeliard_save_name(void) {
    return zeliard_room_masm_vm_save_name();
}
EXPORT const u8        *zeliard_save_record(void) {
    return zeliard_room_masm_vm_save_record();
}
EXPORT const u8        *zeliard_player_record(void) {
    return g_game_segments[0];
}
/* Full shared game segment for automated parity checkpoints.  The first 256
 * bytes are the persistent .USR record; MASM globals, input latches, RNG
 * working state, and timers live elsewhere in the same 64 KiB segment. */
EXPORT const u8        *zeliard_game_segment(void) {
    return g_game_segments[0];
}
EXPORT int              zeliard_game_segment_size(void) {
    return (int)sizeof(g_game_segments[0]);
}
EXPORT u32              zeliard_input_subtick_accum(void) {
    return g_input_subtick_accum;
}
EXPORT u32              zeliard_guest_tick(void) {
    return g_guest_tick_count;
}
EXPORT int              zeliard_load_record(const u8 *record, int size) {
    u8 snapshot[ZEL_PLAYER_RECORD_SIZE];
    if (!record || size != ZEL_PLAYER_RECORD_SIZE) return 0;
    memcpy(snapshot, record, sizeof(snapshot));

    zeliard_room_masm_vm_stop();
    zeliard_inventory_masm_vm_stop();
    zeliard_fight_masm_vm_stop();
    zel_opening_audio_stop();
    game_memory_init();
    memcpy(g_game_segments[0], snapshot, sizeof(snapshot));
    g_paused = 0;
    g_restore_menu_active = 0;
    g_session_terminated = 0;
    g_input_subtick_accum = 0;
    g_guest_tick_count = 0;
    if (!enter_game_scene()) return 0;
    return 1;
}
EXPORT int              zeliard_town_dialog_active(void) {
    return g_town_runtime.dialog.active != 0;
}
EXPORT int              zeliard_inventory_active(void) {
    return zeliard_inventory_masm_vm_active();
}
EXPORT int              zeliard_town_area(void) { return (int)g_town_runtime.area; }
EXPORT int              zeliard_town_cavern_exit_requested(void) { return g_town_runtime.cavern_exit_requested; }
EXPORT int              zeliard_cavern_transition_active(void) { return g_cavern_transition.active; }
EXPORT int              zeliard_cavern_transition_complete(void) { return g_cavern_transition.complete; }
EXPORT int              zeliard_cavern_transition_step(void) { return g_cavern_transition.step; }
EXPORT int              zeliard_fight_active(void) { return zeliard_fight_masm_vm_active(); }
EXPORT int              zeliard_fight_ip(void) { return zeliard_fight_masm_vm_ip(); }
EXPORT int              zeliard_fight_map_width(void) {
    return zeliard_fight_masm_vm_active()
        ? zeliard_fight_masm_vm_peek_u16(0xC002)
        : -1;
}
EXPORT int              zeliard_fight_music_chunk(void) {
    return zeliard_fight_masm_vm_active()
        ? zeliard_fight_masm_vm_music_chunk()
        : -1;
}
EXPORT int              zeliard_ending_active(void) {
    return zeliard_fight_masm_vm_ending_active();
}
EXPORT int              zeliard_ending_finished(void) {
    return zeliard_fight_masm_vm_ending_finished();
}
EXPORT int              zeliard_ending_scene(void) {
    return zeliard_fight_masm_vm_ending_scene();
}
EXPORT int              zeliard_test_restart_fight(
                            int selector, int start_position,
                            int map_scroll_row, int screen_position) {
    if (g_scene != SCENE_GAME || selector < 0 || selector > 0xFF ||
        start_position < 0 || start_position > 0xFFFF ||
        map_scroll_row < 0 || map_scroll_row > 0xFF ||
        screen_position < 0 || screen_position > 0xFF)
        return 0;
    u8 *cs = g_game_segments[0];
    zeliard_fight_masm_vm_stop();
    cs[0x0080] = (u8)start_position;
    cs[0x0081] = (u8)((unsigned)start_position >> 8);
    cs[0x0082] = (u8)map_scroll_row;
    cs[0x0083] = (u8)screen_position;
    cs[0x00C4] = (u8)selector;
    cs[ZEL_PLAYER_BOSS_INTRO_FLAG] = 0;
    cs[0xFF33] = 5;
    g_fight_started = 1;
    g_gameplay_location = GAMEPLAY_LOCATION_CAVERN;
    g_fight_death_pending = 0;
    g_fight_death_return_pending = 0;
    g_fight_death_audio_fade_started = 0;
    g_fight_regen_pit_ticks = 0;
    g_fight_regen_frames = 0;
    if (!zeliard_fight_masm_vm_start(
            cs, sizeof(g_game_segments[0]), g_game_vga,
            sizeof(g_game_vga)))
        return 0;
    memcpy(g_framebuf, g_game_vga, ZELIARD_FB_SIZE);
    sync_fight_audio_globals();
    sync_fight_music();
    return 1;
}
EXPORT int              zeliard_test_defeat_pulpo(void) {
    if (!zeliard_fight_masm_vm_active() ||
        zeliard_fight_masm_vm_peek_u16(0xC002) != 52)
        return 0;
    return zeliard_fight_masm_vm_poke_u16(0xAA83, 0) &&
           zeliard_fight_masm_vm_poke_u8(0xAA9E, 0) &&
           zeliard_fight_masm_vm_poke_u8(0xFF2E, 0xFF);
}
EXPORT int              zeliard_test_defeat_jashiin(void) {
    if (!zeliard_fight_masm_vm_active() ||
        zeliard_fight_masm_vm_peek_u16(0xC002) != 73 ||
        g_game_segments[0][0xC4] != 0x1E)
        return 0;
    return zeliard_fight_masm_vm_poke_u16(0xAC06, 0) &&
           zeliard_fight_masm_vm_poke_u8(0xAC20, 0) &&
           zeliard_fight_masm_vm_poke_u8(0xFF2E, 0xFF);
}
EXPORT int              zeliard_test_fight_u8(unsigned offset) {
    return zeliard_fight_masm_vm_active() && offset <= 0xFFFF
        ? zeliard_fight_masm_vm_peek_u8((u16)offset) : -1;
}
EXPORT int              zeliard_fight_boundary(void) {
    return g_fight_boundary_selector == 0xFF ? -1
                                             : g_fight_boundary_selector;
}
EXPORT int              zeliard_test_enter_room(int kind) {
    if (g_scene != SCENE_GAME || g_town_runtime.room.active ||
        (kind != ZEL_ROOM_KING && kind != ZEL_ROOM_SAGE &&
         kind != ZEL_ROOM_VIEWING && kind != ZEL_ROOM_ARMORY &&
         kind != ZEL_ROOM_DRUGSTORE && kind != ZEL_ROOM_CHURCH &&
         kind != ZEL_ROOM_BANK)) return -1;
    return zeliard_town_begin_room_transition(
        &g_town_runtime, (zeliard_room_kind_t)kind,
        g_game_vga, sizeof(g_game_vga));
}

EXPORT int zeliard_test_game_u8(unsigned offset) {
    return offset < sizeof(g_game_segments[0]) ? g_game_segments[0][offset] : -1;
}

EXPORT int zeliard_test_game_u16(unsigned offset) {
    if (offset + 1 >= sizeof(g_game_segments[0])) return -1;
    return g_game_segments[0][offset] |
           ((int)g_game_segments[0][offset + 1] << 8);
}

EXPORT int zeliard_test_game_set_u8(unsigned offset, unsigned value) {
    if (offset >= sizeof(g_game_segments[0])) return -1;
    g_game_segments[0][offset] = (u8)value;
    return 0;
}

EXPORT int zeliard_test_restart_town(int area) {
    if (g_scene != SCENE_GAME || area < ZEL_TOWN_AREA_FELISHIKA ||
        area > ZEL_TOWN_AREA_ESCO ||
        !zeliard_town_area_supported((u8)(0x80u | (u8)area)))
        return 0;
    zeliard_room_masm_vm_stop();
    zeliard_inventory_masm_vm_stop();
    zeliard_fight_masm_vm_stop();
    zel_input_release_all(&g_input, g_game_segments[0], 1);
    if (zeliard_town_prepare_level_start(
            g_game_segments[0], sizeof(g_game_segments[0]),
            (u8)(0x80u | (u8)area)) != 0)
        return 0;
    g_game_segments[0][ZEL_PLAYER_SAVE_SAGE] = (u8)(0x80u | (u8)area);
    g_fight_started = 0;
    g_cavern_transition.active = 0;
    g_cavern_transition.complete = 0;
    return enter_game_scene() ? 1 : 0;
}

#if !defined(__EMSCRIPTEN__) && !defined(ZELIARD_NO_MAIN)
int main(void) {
    zeliard_init();
    zeliard_tick(0);
    platform_log("native build: done");
    return 0;
}
#endif
