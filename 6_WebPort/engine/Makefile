# Zeliard engine — builds WASM (Emscripten) and native (cc) targets.
#
#   make wasm     -> build/zeliard.{js,wasm} via emcc
#   make native   -> build/zeliard-native binary via cc
#   make clean

ENGINE_SRC := \
	main.c \
	core/framebuf.c \
	render/palette.c \
	load/grp.c \
	load/fill_buffer.c \
	load/img_open.c \
	game/opening.c

WEB_SRC    := $(ENGINE_SRC) platform/platform_web.c
NATIVE_SRC := $(ENGINE_SRC) platform/platform_sdl.c

CFLAGS_COMMON := -std=gnu11 -Wall -Wextra -Wno-unused-parameter -O2 -I.

EMCC        := emcc
EMCC_FLAGS  := $(CFLAGS_COMMON) \
	-s WASM=1 \
	-s MODULARIZE=1 \
	-s EXPORT_NAME=createZeliardModule \
	-s EXPORT_ES6=1 \
	-s ENVIRONMENT=web \
	-s ALLOW_MEMORY_GROWTH=1 \
	-s EXPORTED_FUNCTIONS='["_zeliard_init","_zeliard_tick","_zeliard_key","_zeliard_framebuf","_zeliard_palette","_zeliard_width","_zeliard_height","_malloc","_free"]' \
	-s EXPORTED_RUNTIME_METHODS='["HEAPU8","HEAPU32","UTF8ToString","ccall","cwrap"]' \
	--preload-file assets@/assets \
	-o build/zeliard.js

WASM_DEPS := $(WEB_SRC) Makefile

WASM_OUT := build/zeliard.js build/zeliard.wasm build/zeliard.data

.PHONY: wasm native clean check-assets

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

clean:
	rm -rf build
