/*
 * Zeliard web shell — boots the Emscripten engine, copies the 320x200
 * paletted framebuffer into a Canvas2D ImageData each frame, and drives
 * the engine tick at ~60Hz (the engine itself maintains its own 18.2Hz
 * game-tick internally; the host just calls _zeliard_tick() per requestAnimationFrame).
 */

/* Emscripten exports C functions with a leading underscore (it preserves
 * the C ABI name).  Hence _zeliard_init, _zeliard_tick, etc. */
type EngineExports = {
    _zeliard_init(): void;
    _zeliard_tick(dt_ms: number): void;
    _zeliard_key(keycode: number): void;  // ENTER=13, SPACE=32 → skip opening
    _zeliard_framebuf(): number;     // pointer (offset into HEAPU8)
    _zeliard_palette(): number;      // pointer to 256 RGB triples
    _zeliard_width(): number;
    _zeliard_height(): number;
};

type ZeliardModule = EngineExports & {
    HEAPU8: Uint8Array;
    print?: (s: string) => void;
    printErr?: (s: string) => void;
    locateFile?: (path: string, prefix: string) => string;
};

type ModuleFactory = (overrides?: Partial<ZeliardModule>) => Promise<ZeliardModule>;

const statusEl = document.getElementById('status')!;
const canvas = document.getElementById('screen') as HTMLCanvasElement;
const ctx = canvas.getContext('2d', { alpha: false })!;

function setStatus(msg: string) {
    statusEl.textContent = msg;
    console.log('[zeliard]', msg);
}

async function loadEngineModule(): Promise<ModuleFactory> {
    /* The engine .js / .wasm / .data triple lives under /engine/ in the
     * shell's public dir (mirrored there by `make wasm`).  Importing via
     * an absolute URL prevents Vite from bundling the JS and lets the
     * Emscripten runtime resolve .wasm + .data with relative URLs. */
    const url = `${window.location.origin}/engine/zeliard.js`;
    const mod = await import(/* @vite-ignore */ url);
    return mod.default as ModuleFactory;
}

async function boot() {
    setStatus('loading engine module…');
    const factory = await loadEngineModule();

    setStatus('instantiating WASM…');
    const Module = await factory({
        print:    (s: string) => console.log('[wasm]', s),
        printErr: (s: string) => console.error('[wasm]', s),
        locateFile: (path: string) => `/engine/${path}`,
    });

    setStatus('initialising engine…');
    Module._zeliard_init();

    const w = Module._zeliard_width();
    const h = Module._zeliard_height();
    const fbPtr = Module._zeliard_framebuf();
    const palPtr = Module._zeliard_palette();
    setStatus(`engine running — ${w}×${h}, framebuf @ ${fbPtr}, palette @ ${palPtr}`);

    /* Forward ENTER/SPACE to the engine so it can skip the opening cinematic. */
    window.addEventListener('keydown', (e: KeyboardEvent) => {
        if (e.key === 'Enter' || e.key === ' ') {
            e.preventDefault();
            Module._zeliard_key(e.keyCode);
        }
    });

    const imageData = ctx.createImageData(w, h);
    let last = performance.now();
    let frameCount = 0;

    function frame(now: number) {
        const dt = now - last;
        last = now;
        Module._zeliard_tick(dt | 0);

        const heap = Module.HEAPU8;
        const fb = heap.subarray(fbPtr, fbPtr + w * h);
        const pal = heap.subarray(palPtr, palPtr + 256 * 3);

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

        if (++frameCount === 1) {
            // First-frame diagnostics: count distinct paletted indices to
            // confirm the engine actually wrote something interesting.
            const seen = new Set<number>();
            let nonzero = 0;
            for (let i = 0; i < fb.length; i++) {
                if (fb[i] !== 0) nonzero++;
                seen.add(fb[i]);
            }
            console.log(`[zeliard] first frame: ${nonzero} non-zero pixels, ${seen.size} distinct indices`);
        }
        requestAnimationFrame(frame);
    }
    requestAnimationFrame(frame);
}

boot().catch((err) => {
    console.error(err);
    setStatus(`boot failed: ${err?.message ?? err}`);
});
