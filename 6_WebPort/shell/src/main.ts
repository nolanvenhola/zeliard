/*
 * Zeliard web shell — boots the Emscripten engine, copies the 320x200
 * paletted framebuffer into a Canvas2D ImageData each frame, and drives
 * the engine tick at ~60Hz (the engine itself maintains its own 18.2Hz
 * game-tick internally; the host just calls zeliard_tick() per requestAnimationFrame).
 */

// Vite resolves this to the engine build output written by `make wasm`.
// @ts-expect-error — emcc-generated module has no type declarations.
import createZeliardModule from '../../engine/build/zeliard.js';

/* Emscripten exports C functions with a leading underscore (it preserves
 * the C ABI name).  Hence _zeliard_init, _zeliard_tick, etc. */
type EngineExports = {
    _zeliard_init(): void;
    _zeliard_tick(dt_ms: number): void;
    _zeliard_framebuf(): number;     // pointer (offset into HEAPU8)
    _zeliard_palette(): number;      // pointer to 256 RGB triples
    _zeliard_width(): number;
    _zeliard_height(): number;
};

type ZeliardModule = EngineExports & {
    HEAPU8: Uint8Array;
};

const status = document.getElementById('status')!;
const canvas = document.getElementById('screen') as HTMLCanvasElement;
const ctx = canvas.getContext('2d', { alpha: false })!;

function setStatus(msg: string) {
    status.textContent = msg;
}

async function boot() {
    setStatus('instantiating engine…');
    const Module = (await createZeliardModule()) as ZeliardModule;
    Module._zeliard_init();

    const w = Module._zeliard_width();
    const h = Module._zeliard_height();
    const fbPtr = Module._zeliard_framebuf();
    const palPtr = Module._zeliard_palette();
    setStatus(`engine ready — framebuffer ${w}x${h} @ HEAPU8[${fbPtr}], palette @ HEAPU8[${palPtr}]`);

    const imageData = ctx.createImageData(w, h);
    let last = performance.now();

    function frame(now: number) {
        const dt = now - last;
        last = now;
        Module._zeliard_tick(dt | 0);

        // Snapshot the engine's paletted framebuffer + palette via views into
        // the WASM heap.  HEAPU8 may be detached if memory grows, so refetch
        // each frame.
        const heap = Module.HEAPU8;
        const fb = heap.subarray(fbPtr, fbPtr + w * h);
        const pal = heap.subarray(palPtr, palPtr + 256 * 3);

        // Convert paletted to RGBA.
        const out = imageData.data;
        for (let i = 0; i < fb.length; i++) {
            const idx = fb[i] * 3;
            const o = i * 4;
            out[o    ] = pal[idx    ];
            out[o + 1] = pal[idx + 1];
            out[o + 2] = pal[idx + 2];
            out[o + 3] = 255;
        }
        ctx.putImageData(imageData, 0, 0);
        requestAnimationFrame(frame);
    }
    requestAnimationFrame(frame);
}

boot().catch((err) => {
    console.error(err);
    setStatus(`boot failed: ${err?.message ?? err}`);
});
