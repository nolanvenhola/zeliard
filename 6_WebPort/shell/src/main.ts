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
    _zeliard_key(keycode: number): void;  // ENTER=13, SPACE=32 -> OPDMO phase advance
    _zeliard_framebuf(): number;     // pointer (offset into HEAPU8)
    _zeliard_rgb_framebuf(): number; // optional RGB output for MCGA raster-DAC frames
    _zeliard_rgb_framebuf_active(): number;
    _zeliard_palette(): number;      // pointer to 256 RGB triples
    _zeliard_width(): number;
    _zeliard_height(): number;
    _zeliard_scene(): number;        // 0=title, 1=opening demo, 2=game handoff
    _zeliard_phase(): number;        // OPDMO phase while scene=opening
    _zeliard_phase_elapsed(): number;
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
const appBaseUrl = new URL(import.meta.env.BASE_URL, window.location.href);
const engineBaseUrl = new URL('engine/', appBaseUrl);

function setStatus(msg: string) {
    statusEl.textContent = msg;
    console.log('[zeliard]', msg);
}

async function loadEngineModule(cacheBust: string): Promise<ModuleFactory> {
    /* The engine .js / .wasm / .data triple lives under engine/ in the
     * shell's public dir (mirrored there by `make wasm`).  Importing via
     * an absolute URL prevents Vite from bundling the JS while retaining
     * the repository base path used by GitHub Pages. */
    const moduleUrl = new URL('zeliard.js', engineBaseUrl);
    moduleUrl.searchParams.set('v', cacheBust);
    const mod = await import(/* @vite-ignore */ moduleUrl.href);
    return mod.default as ModuleFactory;
}

async function boot() {
    const params = new URLSearchParams(window.location.search);
    const deterministicCapture = params.has('codex_capture');
    const engineCacheBust = Date.now().toString(36);
    setStatus('loading engine module…');
    const factory = await loadEngineModule(engineCacheBust);

    setStatus('instantiating WASM…');
    const Module = await factory({
        print:    (s: string) => console.log('[wasm]', s),
        printErr: (s: string) => console.error('[wasm]', s),
        locateFile: (path: string) => {
            const assetUrl = new URL(path, engineBaseUrl);
            assetUrl.searchParams.set('v', engineCacheBust);
            return assetUrl.href;
        },
    });

    setStatus('initialising engine…');
    Module._zeliard_init();
    (window as any).__zeliard = Module;

    const w = Module._zeliard_width();
    const h = Module._zeliard_height();
    const fbPtr = Module._zeliard_framebuf();
    const rgbPtr = Module._zeliard_rgb_framebuf();
    const palPtr = Module._zeliard_palette();
    setStatus(`engine running — ${w}×${h}, framebuf @ ${fbPtr}, palette @ ${palPtr}`);

    /* Forward ENTER/SPACE to the engine so it can apply OPDMO phase-specific advance rules. */
    window.addEventListener('keydown', (e: KeyboardEvent) => {
        if (e.key === 'Enter' || e.key === ' ') {
            e.preventDefault();
            if (e.repeat)
                return;
            Module._zeliard_key(e.keyCode);
        }
    });

    const imageData = ctx.createImageData(w, h);
    let last = performance.now();
    let frameCount = 0;
    let lastScene = -1;
    let lastPhase = -1;
    let lastPhaseElapsedBucket = -1;

    function sceneName(scene: number): string {
        switch (scene) {
            case 0: return 'title';
            case 1: return 'opening demo';
            case 2: return 'game handoff';
            default: return `scene ${scene}`;
        }
    }

    function paintFrame() {
        const scene = Module._zeliard_scene();
        const phase = Module._zeliard_phase();
        const phaseElapsed = Module._zeliard_phase_elapsed();
        const phaseElapsedBucket = Math.floor(phaseElapsed / 1000);
        if (scene !== lastScene || phase !== lastPhase ||
            phaseElapsedBucket !== lastPhaseElapsedBucket) {
            lastScene = scene;
            lastPhase = phase;
            lastPhaseElapsedBucket = phaseElapsedBucket;
            setStatus(`engine running - ${sceneName(scene)} / phase ${phase} / ${phaseElapsed}ms`);
        }

        const heap = Module.HEAPU8;
        const fb = heap.subarray(fbPtr, fbPtr + w * h);
        const pal = heap.subarray(palPtr, palPtr + 256 * 3);
        const rgbActive = Module._zeliard_rgb_framebuf_active() !== 0;

        const out = imageData.data;
        if (rgbActive) {
            const rgb = heap.subarray(rgbPtr, rgbPtr + w * h * 3);
            for (let i = 0; i < fb.length; i++) {
                const idx = i * 3;
                const o = i * 4;
                out[o    ] = rgb[idx    ];
                out[o + 1] = rgb[idx + 1];
                out[o + 2] = rgb[idx + 2];
                out[o + 3] = 255;
            }
        } else {
            for (let i = 0; i < fb.length; i++) {
                const idx = fb[i] * 3;
                const o = i * 4;
                out[o    ] = pal[idx    ];
                out[o + 1] = pal[idx + 1];
                out[o + 2] = pal[idx + 2];
                out[o + 3] = 255;
            }
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
    }

    paintFrame();

    if (deterministicCapture) {
        setStatus(`engine capture-ready - ${sceneName(Module._zeliard_scene())} / phase ${Module._zeliard_phase()} / ${Module._zeliard_phase_elapsed()}ms`);
        return;
    }

    function frame(now: number) {
        const dt = Math.max(0, Math.min(now - last, 100));
        last = now;
        Module._zeliard_tick(dt | 0);
        paintFrame();
        requestAnimationFrame(frame);
    }
    requestAnimationFrame(frame);
}

boot().catch((err) => {
    console.error(err);
    setStatus(`boot failed: ${err?.message ?? err}`);
});
