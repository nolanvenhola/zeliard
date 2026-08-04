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

static game_scene_t g_scene = SCENE_OPENING;
static int g_paused;
static int g_session_terminated;
static u8 g_game_segments[ZELIARD_GAME_SEGMENT_COUNT][ZELIARD_GAME_SEGMENT_SIZE];
static u8 g_game_vga[ZELIARD_GAME_SEGMENT_SIZE];
static u8 g_inventory_return_vga[ZELIARD_GAME_SEGMENT_SIZE];
static zeliard_game_exec_state_t g_game_exec;
static zeliard_town_runtime_t g_town_runtime;
static zeliard_cavern_transition_t g_cavern_transition;
static zel_input_state_t g_input;
static u32 g_input_subtick_accum;
static u8 g_fight_music_chunk = 0xFF;
static u8 g_fight_boundary_selector = 0xFF;
static u8 g_fight_started;

static void sync_fight_music(void) {
    const u8 chunk = zeliard_fight_masm_vm_music_chunk();
    if (chunk == g_fight_music_chunk) return;
    const zel_music_track_t track = chunk == 86 ? ZEL_MUSIC_MUS1
                                  : chunk == 94 ? ZEL_MUSIC_MBOS
                                                : ZEL_MUSIC_NONE;
    if (track != ZEL_MUSIC_NONE && !zel_audio_play_music(track))
        platform_log("200FIGHT: exact music chunk %u start failed",
                     (unsigned)chunk);
    g_fight_music_chunk = chunk;
}

static void terminate_session(void) {
    zeliard_room_masm_vm_stop();
    zeliard_inventory_masm_vm_stop();
    zeliard_fight_masm_vm_stop();
    g_fight_music_chunk = 0xFF;
    g_fight_boundary_selector = 0xFF;
    g_fight_started = 0;
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
    memcpy(g_inventory_return_vga, g_game_vga, sizeof(g_inventory_return_vga));
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
            zeliard_fight_masm_vm_active() ? ZEL_INVENTORY_CONTEXT_CAVERN
                                          : ZEL_INVENTORY_CONTEXT_TOWN)) {
        platform_log("201SELCT: exact inventory overlay start failed");
        return;
    }
    memcpy(g_framebuf, g_game_vga, ZELIARD_FB_SIZE);
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
    memset(&g_game_exec, 0, sizeof(g_game_exec));
    memset(&g_cavern_transition, 0, sizeof(g_cavern_transition));
    g_fight_music_chunk = 0xFF;
    g_fight_boundary_selector = 0xFF;
    g_fight_started = 0;
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
    if (actions & ZEL_INPUT_ACTION_TOGGLE_MUSIC)
        zel_opening_audio_toggle_music();
    if (actions & ZEL_INPUT_ACTION_TOGGLE_SOUND)
        zel_opening_audio_toggle_sound();
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
    if (zeliard_town_enter_first_frame(&g_town_runtime, &g_game_exec,
                                        g_game_vga, sizeof(g_game_vga)) != 0) {
        platform_log("game bootstrap: first 106TOWN castle frame failed");
        return false;
    }
    memcpy(g_framebuf, g_game_vga, ZELIARD_FB_SIZE);
    /* game.asm:A1E0 resolves CMAP's descriptor byte 00 to record 0 at
     * A363 (MGT1.MSD). 106TOWN:60A9 starts that game_seg:3000 score with
     * INT 60h AX=0 immediately after the initial town draw. */
    if (!zel_audio_play_music(ZEL_MUSIC_MGT1)) {
        platform_log("game bootstrap: MGT1.MSD exact music start failed");
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
    g_session_terminated = 0;
    g_input_subtick_accum = 0;
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
            !zeliard_fight_masm_vm_active() && !g_fight_started) {
            if (!zeliard_fight_masm_vm_start(
                    g_game_segments[0], sizeof(g_game_segments[0]),
                    g_game_vga, sizeof(g_game_vga))) {
                platform_log("200FIGHT: exact Malicia runtime start failed");
            } else {
                g_fight_started = 1;
                g_fight_boundary_selector = 0xFF;
                memcpy(g_framebuf, g_game_vga, ZELIARD_FB_SIZE);
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
            if (zeliard_inventory_masm_vm_active()) {
                memcpy(g_framebuf, g_game_vga, ZELIARD_FB_SIZE);
            } else {
                memcpy(g_game_vga, g_inventory_return_vga,
                       sizeof(g_inventory_return_vga));
                memcpy(g_framebuf, g_game_vga, ZELIARD_FB_SIZE);
            }
            zel_opening_audio_tick(dt_ms);
            return;
        }
        if (zeliard_fight_masm_vm_active()) {
            const int frames = zeliard_fight_masm_vm_advance(
                g_game_segments[0], sizeof(g_game_segments[0]),
                g_game_vga, sizeof(g_game_vga), input_ticks,
                g_game_segments[0][0xFF17]);
            if (frames > 0)
                memcpy(g_framebuf, g_game_vga, ZELIARD_FB_SIZE);
            if (g_game_segments[0][0xFF75]) {
                zel_opening_audio_write_cue(g_game_segments[0][0xFF75]);
                g_game_segments[0][0xFF75] = 0;
            }
            sync_fight_music();
            if (!zeliard_fight_masm_vm_active()) {
                const u8 operation = zeliard_fight_masm_vm_exit_operation();
                const u8 selector = zeliard_fight_masm_vm_exit_selector();
                const u16 dispatch =
                    zeliard_fight_masm_vm_exit_dispatch_slot();
                const int town_warp = operation == 1 &&
                    (selector & 0x80u) && selector != 0x80u;
                if ((operation == 0 && dispatch == 0x601C) || town_warp) {
                    g_cavern_transition.complete = 0;
                    g_fight_started = 0;
                    if (town_warp)
                        g_game_segments[0][0x00C4] = selector & 0x7Fu;
                    zel_opening_audio_stop();
                    g_fight_music_chunk = 0xFF;
                    if (zeliard_town_enter_first_frame(
                            &g_town_runtime, &g_game_exec, g_game_vga,
                            sizeof(g_game_vga)) != 0) {
                        platform_log("200FIGHT: Muralla return frame failed");
                    } else {
                        memcpy(g_framebuf, g_game_vga, ZELIARD_FB_SIZE);
                        zel_audio_play_music(ZEL_MUSIC_MGT1);
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
        const int frames = zeliard_town_advance_pit(
            &g_town_runtime, &g_game_exec, g_game_vga, sizeof(g_game_vga),
            input_ticks, g_game_segments[0][0xFF17]);
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
            zel_opening_audio_stop();
            if (zeliard_cavern_transition_begin(
                    &g_cavern_transition, g_game_segments[0],
                    sizeof(g_game_segments[0]), g_game_vga,
                    sizeof(g_game_vga)) != 0) {
                platform_log("200FIGHT: cavern transition start failed");
            } else {
                memcpy(g_framebuf, g_game_vga, ZELIARD_FB_SIZE);
            }
        }
        /* 106TOWN:door_type_shop invokes INT 60h AX=1 after the blocking
         * MCGA entry fade and reloads/plays the current town score only after
         * the room program returns. */
        if (!room_was_active && g_town_runtime.room.active)
            zel_opening_audio_stop();
        else if (room_was_active && !g_town_runtime.room.active)
            zel_audio_play_music(ZEL_MUSIC_MGT1);
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
    if (g_scene != SCENE_GAME || !g_town_runtime.room.active ||
        g_town_runtime.room.kind != ZEL_ROOM_SAGE) return;
    if (ascii >= 'a' && ascii <= 'z') ascii -= 'a' - 'A';
    if ((ascii >= 'A' && ascii <= 'Z') ||
        (ascii >= '0' && ascii <= '9') || ascii == 8)
        zeliard_room_masm_vm_text_key((u8)ascii);
}

EXPORT void zeliard_release_all_keys(void) {
    if (g_session_terminated) return;
    zel_input_release_all(&g_input, g_game_segments[0], 1);
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
EXPORT void             zeliard_opening_set_phase_for_test(int phase) {
    opening_set_phase_for_test(phase);
    zel_opening_audio_sync_phase(opening_phase_id());
}
EXPORT u32              zeliard_opening_nec_hou_sprite_debug_word(void) { return opening_nec_hou_sprite_debug_word(); }
#ifndef __EMSCRIPTEN__
int zeliard_test_town_dialog_active(void) { return g_town_runtime.dialog.active; }
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
    g_session_terminated = 0;
    g_input_subtick_accum = 0;
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

#if !defined(__EMSCRIPTEN__) && !defined(ZELIARD_NO_MAIN)
int main(void) {
    zeliard_init();
    zeliard_tick(0);
    platform_log("native build: done");
    return 0;
}
#endif
