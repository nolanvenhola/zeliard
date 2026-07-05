# Zeliard engine — builds WASM (Emscripten) and native (cc) targets.
#
#   make wasm     -> build/zeliard.{js,wasm} via emcc
#   make native   -> build/zeliard-native binary via cc
#   make clean

ENGINE_SRC := \
	main.c \
	core/framebuf.c \
	core/runtime.c \
	core/timer.c \
	render/palette.c \
	render/font_text.c \
	render/mcga_render.c \
	load/grp.c \
	load/fill_buffer.c \
	load/zeliad_loader.c \
	load/game_loader.c \
	load/img_open.c \
	game/opening_script.c \
	game/opening.c \
	game/gameplay_state.c

WEB_SRC    := $(ENGINE_SRC) platform/platform_web.c
NATIVE_SRC := $(ENGINE_SRC) platform/platform_sdl.c
TEST_OPENING_SRC := \
	tests/opening_parity_native.c \
	main.c \
	core/framebuf.c \
	core/timer.c \
	render/palette.c \
	render/font_text.c \
	render/mcga_render.c \
	load/grp.c \
	load/fill_buffer.c \
	load/img_open.c \
	game/opening_script.c \
	game/opening.c \
	platform/platform_sdl.c
TEST_OPENING_TRACE_SRC := \
	tests/opening_service_trace_native.c \
	main.c \
	core/framebuf.c \
	core/timer.c \
	render/palette.c \
	render/font_text.c \
	render/mcga_render.c \
	load/grp.c \
	load/fill_buffer.c \
	load/img_open.c \
	game/opening_script.c \
	game/opening.c \
	platform/platform_sdl.c
TEST_OPENING_FRAME_DUMP_SRC := \
	tests/opening_frame_dump_native.c \
	core/framebuf.c \
	core/timer.c \
	render/palette.c \
	render/font_text.c \
	render/mcga_render.c \
	load/grp.c \
	load/fill_buffer.c \
	load/img_open.c \
	game/opening_script.c \
	game/opening.c \
	platform/platform_sdl.c
TEST_GAMEPLAY_SRC := \
	tests/gameplay_parity_native.c \
	game/gameplay_state.c
TEST_ZELIAD_LOADER_SRC := \
	tests/zeliad_loader_parity_native.c \
	load/zeliad_loader.c
TEST_GAME_LOADER_SRC := \
	tests/game_loader_parity_native.c \
	load/game_loader.c
TEST_RUNTIME_SRC := \
	tests/runtime_parity_native.c \
	core/runtime.c \
	core/framebuf.c \
	core/timer.c \
	render/palette.c \
	platform/platform_sdl.c

CFLAGS_COMMON := -std=gnu11 -Wall -Wextra -Wno-unused-parameter -O2 -I.

EMCC        := emcc
EMCC_FLAGS  := $(CFLAGS_COMMON) \
	-s WASM=1 \
	-s MODULARIZE=1 \
	-s EXPORT_NAME=createZeliardModule \
	-s EXPORT_ES6=1 \
	-s ENVIRONMENT=web \
	-s ALLOW_MEMORY_GROWTH=1 \
	-s EXPORTED_FUNCTIONS='["_zeliard_init","_zeliard_tick","_zeliard_key","_zeliard_framebuf","_zeliard_rgb_framebuf","_zeliard_rgb_framebuf_active","_zeliard_palette","_zeliard_width","_zeliard_height","_zeliard_scene","_zeliard_phase","_zeliard_phase_elapsed","_zeliard_opening_nec_hou_sprite_debug_word","_zeliard_opening_nec_hou_sprite_debug_slots","_malloc","_free"]' \
	-s EXPORTED_RUNTIME_METHODS='["HEAPU8","HEAPU32","UTF8ToString","ccall","cwrap"]' \
	--preload-file assets@/assets \
	-o build/zeliard.js

WASM_DEPS := $(WEB_SRC) Makefile

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

test-native: build/opening-parity-native build/gameplay-parity-native build/zeliad-loader-parity-native build/game-loader-parity-native build/runtime-parity-native
	./build/opening-parity-native
	./build/gameplay-parity-native
	./build/zeliad-loader-parity-native
	./build/game-loader-parity-native
	./build/runtime-parity-native

build/opening-parity-native: $(TEST_OPENING_SRC) Makefile
	@mkdir -p build
	$(CC) $(CFLAGS_COMMON) -DZELIARD_NO_MAIN -o $@ $(TEST_OPENING_SRC)

build/opening-service-trace-native: $(TEST_OPENING_TRACE_SRC) Makefile
	@mkdir -p build
	$(CC) $(CFLAGS_COMMON) -DZELIARD_NO_MAIN -o $@ $(TEST_OPENING_TRACE_SRC)

build/opening-frame-dump-native: $(TEST_OPENING_FRAME_DUMP_SRC) Makefile
	@mkdir -p build
	$(CC) $(CFLAGS_COMMON) -DZELIARD_NO_MAIN -o $@ $(TEST_OPENING_FRAME_DUMP_SRC)

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
