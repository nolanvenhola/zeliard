# Zeliard engine — builds WASM (Emscripten) and native (cc) targets.
#
#   make wasm     -> build/zeliard.{js,wasm} via emcc
#   make native   -> build/zeliard-native binary via cc
#   make clean

ENGINE_SRC := \
	main.c \
	core/framebuf.c \
	core/input.c \
	core/player_state.c \
	core/runtime.c \
	core/timer.c \
	audio/adlib_cue.c \
	audio/opening_audio.c \
	audio/mscadlib_vm.c \
	third_party/8086tiny/8086tiny.c \
	third_party/opal/src/opal.c \
	render/palette.c \
	render/font_text.c \
	render/mcga_render.c \
	render/mcga_runtime.c \
	render/town_mcga.c \
	render/room_mcga.c \
	render/town_background.c \
	load/grp.c \
	load/fill_buffer.c \
	load/zeliad_loader.c \
	load/game_loader.c \
	load/img_open.c \
	game/opening_script.c \
	game/opening_trace.c \
	game/opening.c \
	game/town_dialog.c \
	game/room_runtime.c \
	game/town_runtime.c \
	game/gameplay_state.c

WEB_SRC    := $(ENGINE_SRC) platform/platform_web.c
NATIVE_SRC := $(ENGINE_SRC) platform/platform_sdl.c
TEST_OPENING_SRC := \
	tests/opening_parity_native.c \
	main.c \
	core/framebuf.c \
	core/input.c \
	core/player_state.c \
	core/timer.c \
	audio/opening_audio.c \
	audio/mscadlib_vm.c \
	third_party/8086tiny/8086tiny.c \
	third_party/opal/src/opal.c \
	render/palette.c \
	render/font_text.c \
	render/mcga_render.c \
	render/mcga_runtime.c \
	load/grp.c \
	load/fill_buffer.c \
	load/game_loader.c \
	load/img_open.c \
	game/opening_script.c \
	game/opening_trace.c \
	game/opening.c \
	game/town_dialog.c \
	game/room_runtime.c \
	game/town_runtime.c \
	render/room_mcga.c \
	render/town_background.c \
	render/town_mcga.c \
	platform/platform_sdl.c
TEST_OPENING_TRACE_SRC := \
	tests/opening_service_trace_native.c \
	main.c \
	core/framebuf.c \
	core/input.c \
	core/player_state.c \
	core/timer.c \
	audio/opening_audio.c \
	audio/mscadlib_vm.c \
	third_party/8086tiny/8086tiny.c \
	third_party/opal/src/opal.c \
	render/palette.c \
	render/font_text.c \
	render/mcga_render.c \
	render/mcga_runtime.c \
	load/grp.c \
	load/fill_buffer.c \
	load/game_loader.c \
	load/img_open.c \
	game/opening_script.c \
	game/opening_trace.c \
	game/opening.c \
	game/town_dialog.c \
	game/room_runtime.c \
	game/town_runtime.c \
	render/room_mcga.c \
	render/town_background.c \
	render/town_mcga.c \
	platform/platform_sdl.c
TEST_OPENING_LIVE_TRACE_SRC := \
	tests/opening_live_trace_native.c \
	core/framebuf.c \
	core/timer.c \
	render/palette.c \
	render/font_text.c \
	render/mcga_render.c \
	render/mcga_runtime.c \
	load/grp.c \
	load/fill_buffer.c \
	load/img_open.c \
	game/opening_script.c \
	game/opening_trace.c \
	game/opening.c \
	platform/platform_sdl.c
TEST_OPENING_FRAME_DUMP_SRC := \
	tests/opening_frame_dump_native.c \
	core/framebuf.c \
	core/timer.c \
	render/palette.c \
	render/font_text.c \
	render/mcga_render.c \
	render/mcga_runtime.c \
	load/grp.c \
	load/fill_buffer.c \
	load/img_open.c \
	game/opening_script.c \
	game/opening_trace.c \
	game/opening.c \
	platform/platform_sdl.c
TEST_OPENING_AUDIO_SRC := \
	tests/opening_audio_native.c \
	audio/adlib_cue.c \
	audio/opening_audio.c \
	audio/mscadlib_vm.c \
	third_party/8086tiny/8086tiny.c \
	third_party/opal/src/opal.c \
	core/timer.c \
	platform/platform_sdl.c
TEST_MSCADLIB_VM_SRC := \
	tests/mscadlib_vm_native.c \
	audio/mscadlib_vm.c \
	third_party/8086tiny/8086tiny.c
TEST_MAIN_CONTROLS_SRC := \
	tests/main_controls_native.c \
	main.c \
	core/framebuf.c \
	core/input.c \
	core/player_state.c \
	core/timer.c \
	audio/opening_audio.c \
	audio/mscadlib_vm.c \
	third_party/8086tiny/8086tiny.c \
	third_party/opal/src/opal.c \
	render/palette.c \
	render/font_text.c \
	render/mcga_render.c \
	render/mcga_runtime.c \
	load/grp.c \
	load/fill_buffer.c \
	load/game_loader.c \
	load/img_open.c \
	game/opening_script.c \
	game/opening_trace.c \
	game/opening.c \
	game/town_dialog.c \
	game/room_runtime.c \
	game/town_runtime.c \
	render/room_mcga.c \
	render/town_background.c \
	render/town_mcga.c \
	platform/platform_sdl.c
TEST_CONTINUOUS_INPUT_SRC := \
	tests/continuous_input_native.c \
	core/input.c
TEST_GAMEPLAY_SRC := \
	tests/gameplay_parity_native.c \
	core/player_state.c \
	game/gameplay_state.c
TEST_ZELIAD_LOADER_SRC := \
	tests/zeliad_loader_parity_native.c \
	load/zeliad_loader.c
TEST_GAME_LOADER_SRC := \
	tests/game_loader_parity_native.c \
	load/game_loader.c \
	load/fill_buffer.c
TEST_RUNTIME_SRC := \
	tests/runtime_parity_native.c \
	core/runtime.c \
	core/framebuf.c \
	core/input.c \
	core/timer.c \
	render/palette.c \
	render/font_text.c \
	render/mcga_render.c \
	render/mcga_runtime.c \
	load/grp.c \
	load/fill_buffer.c \
	platform/platform_sdl.c
TEST_MCGA_FONT_INV_SRC := \
	tests/mcga_font_inv_native.c \
	load/fill_buffer.c \
	render/mcga_render.c
TEST_MCGA_DRV_SEG_3_SRC := \
	tests/mcga_disp_drv_seg_3_native.c \
	render/mcga_render.c
TEST_MCGA_TILE_RENDER_SRC := \
	tests/mcga_disp_tile_render_native.c \
	render/mcga_render.c
TEST_MCGA_TILEMAP_RENDER_SRC := \
	tests/mcga_disp_tilemap_render_native.c \
	render/mcga_render.c
TEST_MCGA_RENDER_A_FULL_SRC := \
	tests/mcga_disp_render_a_full_native.c \
	render/mcga_render.c
TEST_MCGA_GFX_UPDATE_DA_SRC := \
	tests/mcga_gfx_update_da_native.c \
	render/mcga_render.c
TEST_MCGA_TITLE_TILE_PIPELINE_SRC := \
	tests/mcga_title_tile_pipeline_native.c \
	render/mcga_render.c
TEST_MCGA_TITLE_SWEEP_ASSETS_SRC := \
	tests/mcga_title_sweep_assets_native.c \
	load/grp.c load/fill_buffer.c render/mcga_render.c platform/platform_sdl.c
TEST_MCGA_RUNTIME_SRC := \
	tests/mcga_runtime_native.c \
	core/timer.c \
	load/fill_buffer.c \
	render/mcga_render.c \
	render/mcga_runtime.c
TEST_MCGA_SPRITE_PALETTE_SRC := \
	tests/mcga_sprite_palette_native.c \
	render/palette.c \
	platform/platform_sdl.c
TEST_TOWN_MCGA_DISPATCH_SRC := \
	tests/town_mcga_dispatch_native.c \
	core/player_state.c \
	render/town_mcga.c
TEST_TOWN_MCGA_SERVICES_SRC := \
	tests/town_mcga_services_native.c \
	core/player_state.c \
	render/town_mcga.c
TEST_TOWN_BACKGROUND_SRC := \
	tests/town_background_native.c \
	render/town_background.c
TEST_TOWN_ACTOR_SRC := \
	tests/town_actor_native.c \
	core/player_state.c \
	render/town_mcga.c \
	load/fill_buffer.c
TEST_TOWN_RUNTIME_SRC := \
	tests/town_runtime_native.c \
	core/player_state.c \
	game/town_dialog.c \
	game/room_runtime.c \
	game/town_runtime.c \
	render/room_mcga.c \
	render/town_background.c \
	render/town_mcga.c \
	render/palette.c \
	load/fill_buffer.c \
	platform/platform_sdl.c
TEST_TOWN_FIRST_DIALOG_SRC := \
	tests/town_first_dialog_native.c \
	core/player_state.c \
	game/town_dialog.c \
	render/town_mcga.c \
	load/fill_buffer.c
TEST_FELISHIKA_ROOMS_SRC := \
	tests/felishika_rooms_native.c \
	core/player_state.c \
	game/room_runtime.c \
	render/room_mcga.c \
	render/town_mcga.c \
	render/palette.c \
	load/fill_buffer.c \
	platform/platform_sdl.c

CFLAGS_COMMON := -std=gnu11 -Wall -Wextra -Wno-unused-parameter -O2 -fno-strict-aliasing -I. -Ithird_party/opal/include

EMCC        := emcc
EMCC_FLAGS  := $(CFLAGS_COMMON) \
	-s WASM=1 \
	-s MODULARIZE=1 \
	-s EXPORT_NAME=createZeliardModule \
	-s EXPORT_ES6=1 \
	-s ENVIRONMENT=web \
	-s ALLOW_MEMORY_GROWTH=1 \
	-s EXPORTED_FUNCTIONS='["_zeliard_init","_zeliard_tick","_zeliard_key","_zeliard_key_down","_zeliard_key_up","_zeliard_release_all_keys","_zeliard_framebuf","_zeliard_rgb_framebuf","_zeliard_rgb_framebuf_active","_zeliard_palette","_zeliard_width","_zeliard_height","_zeliard_scene","_zeliard_phase","_zeliard_phase_elapsed","_zeliard_music_track","_zeliard_music_complete","_zeliard_music_attenuation","_zeliard_paused","_zeliard_music_enabled","_zeliard_sound_enabled","_zeliard_sound_cue","_zeliard_audio_pcm","_zeliard_audio_pcm_available","_zeliard_audio_set_sample_rate","_zeliard_audio_opl_write_count","_zeliard_audio_generated_peak","_zeliard_audio_cue_serial","_zeliard_exact_music_driver","_zeliard_opening_set_phase_for_test","_zeliard_opening_nec_hou_sprite_debug_word","_zeliard_opening_nec_hou_sprite_debug_slots","_zeliard_room_kind","_zeliard_test_enter_room","_malloc","_free"]' \
	-s EXPORTED_RUNTIME_METHODS='["HEAPU8","HEAPU32","UTF8ToString","ccall","cwrap"]' \
	--preload-file assets@/assets \
	-o build/zeliard.js

WASM_DEPS := $(WEB_SRC) Makefile $(wildcard assets/*)

WASM_OUT := build/zeliard.js build/zeliard.wasm build/zeliard.data

.PHONY: wasm native test-native clean check-assets

wasm: check-assets $(WASM_OUT)

# Sanity: the asset dir must exist before emcc --preload-file runs.
# Populate it from the host with: node scripts/copy_assets.mjs
check-assets:
	@test -d assets || (echo "engine/assets/ missing — run 'node ../scripts/copy_assets.mjs' first" && exit 1)

build/zeliard.js: $(WASM_DEPS)
	@mkdir -p build
	$(EMCC) $(EMCC_FLAGS) $(WEB_SRC)
	@# Mirror build artefacts into shell/public/engine/ so the Vite dev
	@# server can serve them at /engine/<name> alongside the page.  The
	@# Emscripten loader fetches zeliard.data + zeliard.wasm relative to
	@# the JS file's URL, so they must live in the same directory.
	@mkdir -p ../shell/public/engine
	@cp build/zeliard.js build/zeliard.wasm build/zeliard.data ../shell/public/engine/
	@echo "  -> mirrored to shell/public/engine/"

native: build/zeliard-native

build/zeliard-native: $(NATIVE_SRC) Makefile
	@mkdir -p build
	$(CC) $(CFLAGS_COMMON) -o $@ $(NATIVE_SRC)

test-native: build/opening-parity-native build/opening-audio-native build/mscadlib-vm-native build/main-controls-native build/continuous-input-native build/gameplay-parity-native build/zeliad-loader-parity-native build/game-loader-parity-native build/runtime-parity-native build/mcga-font-inv-native build/mcga-drv-seg-3-native build/mcga-tile-render-native build/mcga-tilemap-render-native build/mcga-render-a-full-native build/mcga-gfx-update-da-native build/mcga-title-tile-pipeline-native build/mcga-title-sweep-assets-native build/mcga-runtime-native build/mcga-sprite-palette-native build/town-mcga-dispatch-native build/town-mcga-services-native build/town-background-native build/town-actor-native build/town-runtime-native build/town-first-dialog-native build/felishika-rooms-native
	./build/opening-parity-native
	./build/opening-audio-native
	./build/mscadlib-vm-native
	./build/main-controls-native
	./build/continuous-input-native
	./build/gameplay-parity-native
	./build/zeliad-loader-parity-native
	./build/game-loader-parity-native
	./build/runtime-parity-native
	./build/mcga-font-inv-native
	./build/mcga-drv-seg-3-native
	./build/mcga-tile-render-native
	./build/mcga-tilemap-render-native
	./build/mcga-render-a-full-native
	./build/mcga-gfx-update-da-native
	./build/mcga-title-tile-pipeline-native
	./build/mcga-title-sweep-assets-native
	./build/mcga-runtime-native
	./build/mcga-sprite-palette-native
	./build/town-mcga-dispatch-native
	./build/town-mcga-services-native
	./build/town-background-native
	./build/town-actor-native
	./build/town-runtime-native
	./build/town-first-dialog-native
	./build/felishika-rooms-native

build/opening-parity-native: $(TEST_OPENING_SRC) Makefile
	@mkdir -p build
	$(CC) $(CFLAGS_COMMON) -DZELIARD_NO_MAIN -o $@ $(TEST_OPENING_SRC)

build/opening-audio-native: $(TEST_OPENING_AUDIO_SRC) Makefile
	@mkdir -p build
	$(CC) $(CFLAGS_COMMON) -o $@ $(TEST_OPENING_AUDIO_SRC)

build/mscadlib-vm-native: $(TEST_MSCADLIB_VM_SRC) Makefile
	@mkdir -p build
	$(CC) $(CFLAGS_COMMON) -Wno-parentheses -Wno-sign-compare -Wno-unused-value -Wno-implicit-fallthrough -Wno-deprecated-declarations -o $@ $(TEST_MSCADLIB_VM_SRC)

build/main-controls-native: $(TEST_MAIN_CONTROLS_SRC) Makefile
	@mkdir -p build
	$(CC) $(CFLAGS_COMMON) -DZELIARD_NO_MAIN -o $@ $(TEST_MAIN_CONTROLS_SRC)

build/continuous-input-native: $(TEST_CONTINUOUS_INPUT_SRC) Makefile
	@mkdir -p build
	$(CC) $(CFLAGS_COMMON) -o $@ $(TEST_CONTINUOUS_INPUT_SRC)

build/opening-service-trace-native: $(TEST_OPENING_TRACE_SRC) Makefile
	@mkdir -p build
	$(CC) $(CFLAGS_COMMON) -DZELIARD_NO_MAIN -o $@ $(TEST_OPENING_TRACE_SRC)

build/opening-live-trace-native: $(TEST_OPENING_LIVE_TRACE_SRC) Makefile
	@mkdir -p build
	$(CC) $(CFLAGS_COMMON) -DZELIARD_NO_MAIN -o $@ $(TEST_OPENING_LIVE_TRACE_SRC)

build/opening-frame-dump-native: $(TEST_OPENING_FRAME_DUMP_SRC) Makefile
	@mkdir -p build
	$(CC) $(CFLAGS_COMMON) -DZELIARD_NO_MAIN -o $@ $(TEST_OPENING_FRAME_DUMP_SRC)

build/mcga-font-inv-native: $(TEST_MCGA_FONT_INV_SRC) Makefile
	@mkdir -p build
	$(CC) $(CFLAGS_COMMON) -o $@ $(TEST_MCGA_FONT_INV_SRC)

build/mcga-drv-seg-3-native: $(TEST_MCGA_DRV_SEG_3_SRC) Makefile
	@mkdir -p build
	$(CC) $(CFLAGS_COMMON) -o $@ $(TEST_MCGA_DRV_SEG_3_SRC)

build/mcga-tile-render-native: $(TEST_MCGA_TILE_RENDER_SRC) Makefile
	@mkdir -p build
	$(CC) $(CFLAGS_COMMON) -o $@ $(TEST_MCGA_TILE_RENDER_SRC)

build/mcga-tilemap-render-native: $(TEST_MCGA_TILEMAP_RENDER_SRC) Makefile
	@mkdir -p build
	$(CC) $(CFLAGS_COMMON) -o $@ $(TEST_MCGA_TILEMAP_RENDER_SRC)

build/mcga-render-a-full-native: $(TEST_MCGA_RENDER_A_FULL_SRC) Makefile
	@mkdir -p build
	$(CC) $(CFLAGS_COMMON) -o $@ $(TEST_MCGA_RENDER_A_FULL_SRC)

build/mcga-gfx-update-da-native: $(TEST_MCGA_GFX_UPDATE_DA_SRC) Makefile
	@mkdir -p build
	$(CC) $(CFLAGS_COMMON) -o $@ $(TEST_MCGA_GFX_UPDATE_DA_SRC)

build/mcga-title-tile-pipeline-native: $(TEST_MCGA_TITLE_TILE_PIPELINE_SRC) Makefile
	@mkdir -p build
	$(CC) $(CFLAGS_COMMON) -o $@ $(TEST_MCGA_TITLE_TILE_PIPELINE_SRC)

build/mcga-title-sweep-assets-native: $(TEST_MCGA_TITLE_SWEEP_ASSETS_SRC) Makefile
	@mkdir -p build
	$(CC) $(CFLAGS_COMMON) -o $@ $(TEST_MCGA_TITLE_SWEEP_ASSETS_SRC)

build/mcga-runtime-native: $(TEST_MCGA_RUNTIME_SRC) Makefile
	@mkdir -p build
	$(CC) $(CFLAGS_COMMON) -o $@ $(TEST_MCGA_RUNTIME_SRC)

build/mcga-sprite-palette-native: $(TEST_MCGA_SPRITE_PALETTE_SRC) Makefile
	@mkdir -p build
	$(CC) $(CFLAGS_COMMON) -o $@ $(TEST_MCGA_SPRITE_PALETTE_SRC)

build/town-mcga-dispatch-native: $(TEST_TOWN_MCGA_DISPATCH_SRC) Makefile
	@mkdir -p build
	$(CC) $(CFLAGS_COMMON) -o $@ $(TEST_TOWN_MCGA_DISPATCH_SRC)

build/town-mcga-services-native: $(TEST_TOWN_MCGA_SERVICES_SRC) Makefile
	@mkdir -p build
	$(CC) $(CFLAGS_COMMON) -o $@ $(TEST_TOWN_MCGA_SERVICES_SRC)

build/town-background-native: $(TEST_TOWN_BACKGROUND_SRC) Makefile
	@mkdir -p build
	$(CC) $(CFLAGS_COMMON) -o $@ $(TEST_TOWN_BACKGROUND_SRC)

build/town-actor-native: $(TEST_TOWN_ACTOR_SRC) Makefile
	@mkdir -p build
	$(CC) $(CFLAGS_COMMON) -o $@ $(TEST_TOWN_ACTOR_SRC)

build/town-runtime-native: $(TEST_TOWN_RUNTIME_SRC) Makefile
	@mkdir -p build
	$(CC) $(CFLAGS_COMMON) -o $@ $(TEST_TOWN_RUNTIME_SRC)

build/town-first-dialog-native: $(TEST_TOWN_FIRST_DIALOG_SRC) Makefile
	@mkdir -p build
	$(CC) $(CFLAGS_COMMON) -o $@ $(TEST_TOWN_FIRST_DIALOG_SRC)

build/felishika-rooms-native: $(TEST_FELISHIKA_ROOMS_SRC) Makefile
	@mkdir -p build
	$(CC) $(CFLAGS_COMMON) -o $@ $(TEST_FELISHIKA_ROOMS_SRC)

build/gameplay-parity-native: $(TEST_GAMEPLAY_SRC) Makefile
	@mkdir -p build
	$(CC) $(CFLAGS_COMMON) -o $@ $(TEST_GAMEPLAY_SRC)

build/zeliad-loader-parity-native: $(TEST_ZELIAD_LOADER_SRC) Makefile
	@mkdir -p build
	$(CC) $(CFLAGS_COMMON) -o $@ $(TEST_ZELIAD_LOADER_SRC)

build/game-loader-parity-native: $(TEST_GAME_LOADER_SRC) Makefile
	@mkdir -p build
	$(CC) $(CFLAGS_COMMON) -o $@ $(TEST_GAME_LOADER_SRC)

build/runtime-parity-native: $(TEST_RUNTIME_SRC) Makefile
	@mkdir -p build
	$(CC) $(CFLAGS_COMMON) -o $@ $(TEST_RUNTIME_SRC)

clean:
	rm -rf build
