/*
 * Zeliard web shell — boots the Emscripten engine, copies the 320x200
 * paletted framebuffer into a Canvas2D ImageData each frame, and drives
 * the engine tick at ~60Hz. The engine converts elapsed milliseconds into
 * the original 236.7 Hz PIT cadence used by stick.asm.
 */

/* Emscripten exports C functions with a leading underscore (it preserves
 * the C ABI name).  Hence _zeliard_init, _zeliard_tick, etc. */
type EngineExports = {
    _zeliard_init(): void;
    _zeliard_tick(dt_ms: number): void;
    _zeliard_key(keycode: number): void;
    _zeliard_key_down(keycode: number): void;
    _zeliard_key_up(keycode: number): void;
    _zeliard_text_key(ascii: number): void;
    _zeliard_release_all_keys(): void;
    _zeliard_framebuf(): number;     // pointer (offset into HEAPU8)
    _zeliard_rgb_framebuf(): number; // optional RGB output for MCGA raster-DAC frames
    _zeliard_rgb_framebuf_active(): number;
    _zeliard_palette(): number;      // pointer to 256 RGB triples
    _zeliard_width(): number;
    _zeliard_height(): number;
    _zeliard_scene(): number;        // 0=title, 1=opening demo, 2=game handoff
    _zeliard_phase(): number;        // OPDMO phase while scene=opening
    _zeliard_phase_elapsed(): number;
    _zeliard_music_track(): number;  // zel_music_track_t from the exact runtime
    _zeliard_music_complete(track: number): void;
    _zeliard_music_attenuation(): number;
    _zeliard_paused(): number;
    _zeliard_music_enabled(): number;
    _zeliard_sound_enabled(): number;
    _zeliard_sound_cue(): number;
    _zeliard_audio_pcm(stereo: number, frames: number): number;
    _zeliard_audio_pcm_available(): number;
    _zeliard_audio_set_sample_rate(sampleRate: number): void;
    _zeliard_audio_opl_write_count(): number;
    _zeliard_audio_generated_peak(): number;
    _zeliard_audio_cue_serial(): number;
    _zeliard_exact_music_driver(): number;
    _zeliard_opening_set_phase_for_test(phase: number): void;
    _zeliard_room_kind(): number;
    _zeliard_town_area(): number;
    _zeliard_town_cavern_exit_requested(): number;
    _zeliard_test_enter_room(kind: number): number;
    _zeliard_save_serial(): number;
    _zeliard_save_name(): number;
    _zeliard_save_record(): number;
    _zeliard_load_record(record: number, size: number): number;
    _malloc(size: number): number;
    _free(pointer: number): void;
};

type ZeliardModule = EngineExports & {
    HEAPU8: Uint8Array;
    print?: (s: string) => void;
    printErr?: (s: string) => void;
    locateFile?: (path: string, prefix: string) => string;
};

type ModuleFactory = (overrides?: Partial<ZeliardModule>) => Promise<ZeliardModule>;

const statusEl = document.getElementById('status')!;
const startButton = document.getElementById('start') as HTMLButtonElement;
const canvas = document.getElementById('screen') as HTMLCanvasElement;
const ctx = canvas.getContext('2d', { alpha: false })!;
const saveControlsEl = document.getElementById('save-controls') as HTMLDivElement;
const saveSelectEl = document.getElementById('save-select') as HTMLSelectElement;
const loadSaveEl = document.getElementById('load-save') as HTMLButtonElement;
const appBaseUrl = new URL(import.meta.env.BASE_URL, window.location.href);
const engineBaseUrl = new URL('engine/', appBaseUrl);

class OpeningMusic {
    private readonly context = new AudioContext();
    private readonly node: ScriptProcessorNode;
    private readonly pcmPointer: number;
    private activeTrack = -1;
    private streamPrimed = false;
    private cueSerial = 0;
    readonly stats = {
        callbacks: 0,
        requestedFrames: 0,
        deliveredFrames: 0,
        underrunFrames: 0,
        deliveredPeak: 0,
        deliveredNonzero: 0,
        cueSerial: 0,
        cueBypassCount: 0,
        bufferedFrames: 0,
        contextState: this.context.state,
    };

    constructor(private readonly module: ZeliardModule) {
        const frames = 512;
        this.module._zeliard_audio_set_sample_rate(this.context.sampleRate);
        this.cueSerial = this.module._zeliard_audio_cue_serial();
        this.pcmPointer = this.module._malloc(frames * 2 * Int16Array.BYTES_PER_ELEMENT);
        this.node = this.context.createScriptProcessor(frames, 0, 2);
        this.node.onaudioprocess = (event) => {
            const output = event.outputBuffer;
            const buffered = this.module._zeliard_audio_pcm_available();
            const cueSerial = this.module._zeliard_audio_cue_serial();
            this.stats.bufferedFrames = buffered;
            if (cueSerial !== this.cueSerial) {
                this.cueSerial = cueSerial;
                this.stats.cueSerial = cueSerial;
                this.stats.cueBypassCount++;
            }
            if (!this.streamPrimed && buffered >= 1536)
                this.streamPrimed = true;
            if (this.streamPrimed && buffered < output.length)
                this.streamPrimed = false;
            const available = this.streamPrimed
                ? this.module._zeliard_audio_pcm(this.pcmPointer, output.length)
                : 0;
            const pcm = new Int16Array(this.module.HEAPU8.buffer,
                this.pcmPointer, available * 2);
            const left = output.getChannelData(0);
            const right = output.getChannelData(1);
            this.stats.callbacks++;
            this.stats.requestedFrames += output.length;
            this.stats.deliveredFrames += available;
            this.stats.underrunFrames += output.length - available;
            this.stats.contextState = this.context.state;
            left.fill(0);
            right.fill(0);
            for (let i = 0; i < available; ++i) {
                left[i] = pcm[i * 2] / 32768;
                right[i] = pcm[i * 2 + 1] / 32768;
                this.stats.deliveredPeak = Math.max(this.stats.deliveredPeak,
                    Math.abs(pcm[i * 2]), Math.abs(pcm[i * 2 + 1]));
                this.stats.deliveredNonzero +=
                    pcm[i * 2] !== 0 || pcm[i * 2 + 1] !== 0 ? 1 : 0;
            }
        };
        this.node.connect(this.context.destination);
    }

    static async load(module: ZeliardModule): Promise<OpeningMusic> {
        if (!module._zeliard_exact_music_driver())
            throw new Error('original MSCADLIB runtime unavailable');
        return new OpeningMusic(module);
    }

    async unlock(): Promise<void> {
        await this.context.resume();
    }

    sync(track: number, enabled: boolean, paused: boolean, attenuation: number): void {
        if (track !== this.activeTrack) {
            this.activeTrack = track;
            this.streamPrimed = false;
            this.stats.callbacks = 0;
            this.stats.requestedFrames = 0;
            this.stats.deliveredFrames = 0;
            this.stats.underrunFrames = 0;
            this.stats.deliveredPeak = 0;
            this.stats.deliveredNonzero = 0;
        }
        void enabled; void paused; void attenuation;
    }
}

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

    const imageData = ctx.createImageData(w, h);
    let last = performance.now();
    let frameCount = 0;
    let lastScene = -1;
    let lastPhase = -1;
    let lastPhaseElapsedBucket = -1;
    let lastPaused = false;
    let lastSaveSerial = Module._zeliard_save_serial();

    const listSaves = () => Object.keys(localStorage)
        .filter((key) => key.startsWith('zeliard.save.'))
        .sort()
        .map((key) => {
            try {
                const value = JSON.parse(localStorage.getItem(key) ?? 'null');
                return value?.version === 1 && typeof value.name === 'string' &&
                    Array.isArray(value.record) && value.record.length === 0x100 &&
                    value.record.every((byte: unknown) => Number.isInteger(byte) &&
                        (byte as number) >= 0 && (byte as number) <= 0xFF)
                    ? value : null;
            } catch {
                return null;
            }
        }).filter((save): save is { version: number; name: string; record: number[] } =>
            save !== null);
    (window as any).__zeliardSaves = listSaves;
    const loadSave = (name: string) => {
        const save = listSaves().find((candidate) =>
            candidate.name.toUpperCase() === name.toUpperCase() ||
            candidate.name.toUpperCase() === `${name.toUpperCase()}.USR`);
        if (!save) return false;
        const pointer = Module._malloc(0x100);
        if (!pointer) return false;
        Module.HEAPU8.set(save.record, pointer);
        const loaded = Module._zeliard_load_record(pointer, 0x100) !== 0;
        Module._free(pointer);
        return loaded;
    };
    (window as any).__zeliardLoadSave = loadSave;
    const refreshSaveControls = () => {
        const saves = listSaves();
        const selected = saveSelectEl.value;
        saveSelectEl.replaceChildren(...saves.map((save) => {
            const option = document.createElement('option');
            option.value = save.name;
            option.textContent = save.name.replace(/\.usr$/i, '');
            return option;
        }));
        if (saves.some((save) => save.name === selected))
            saveSelectEl.value = selected;
        saveControlsEl.hidden = saves.length === 0;
    };
    loadSaveEl.addEventListener('click', () => {
        if (!saveSelectEl.value) return;
        if (!loadSave(saveSelectEl.value))
            setStatus('saved game could not be loaded');
    });
    refreshSaveControls();

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
        const paused = Module._zeliard_paused() !== 0;
        if (scene !== lastScene || phase !== lastPhase ||
            phaseElapsedBucket !== lastPhaseElapsedBucket || paused !== lastPaused) {
            lastScene = scene;
            lastPhase = phase;
            lastPhaseElapsedBucket = phaseElapsedBucket;
            lastPaused = paused;
            setStatus(paused ? 'paused' :
                `engine running - ${sceneName(scene)} / phase ${phase} / ${phaseElapsed}ms`);
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

    setStatus('loading exact AdLib audio...');
    let music: OpeningMusic | null = null;
    try {
        music = await OpeningMusic.load(Module);
    } catch (err) {
        console.error('[zeliard] audio load failed', err);
    }
    let started = false;
    let tickRemainderMs = 0;
    async function startPlayback() {
        if (started)
            return;
        await music?.unlock();
        (window as any).__zeliardAudioStats = music?.stats ?? null;
        started = true;
        startButton.hidden = true;
        last = performance.now();
        tickRemainderMs = 0;
        music?.sync(Module._zeliard_music_track(),
            Module._zeliard_music_enabled() !== 0,
            Module._zeliard_paused() !== 0,
            Module._zeliard_music_attenuation());
        requestAnimationFrame(frame);
    }

    startButton.hidden = false;
    startButton.addEventListener('click', () => void startPlayback());
    window.addEventListener('keydown', (e: KeyboardEvent) => {
        const keycodes: Record<string, number> = {
            Enter: 13,
            ' ': 32,
            ArrowLeft: 37,
            ArrowUp: 38,
            ArrowRight: 39,
            ArrowDown: 40,
            Escape: 27,
            F1: 112,
            F2: 113,
        };
        const keycode = keycodes[e.key];
        if (keycode === undefined) {
            if (!e.repeat && (e.key === 'Backspace' ||
                /^[a-zA-Z0-9]$/.test(e.key))) {
                e.preventDefault();
                Module._zeliard_text_key(e.key === 'Backspace'
                    ? 8 : e.key.toUpperCase().charCodeAt(0));
            }
            return;
        }
        e.preventDefault();
        if (e.repeat)
            return;
        if (!started) {
            void startPlayback();
            return;
        }
        Module._zeliard_key_down(keycode);
        music?.sync(Module._zeliard_music_track(),
            Module._zeliard_music_enabled() !== 0,
            Module._zeliard_paused() !== 0,
            Module._zeliard_music_attenuation());
    });
    window.addEventListener('keyup', (e: KeyboardEvent) => {
        const keycodes: Record<string, number> = {
            Enter: 13,
            ' ': 32,
            ArrowLeft: 37,
            ArrowUp: 38,
            ArrowRight: 39,
            ArrowDown: 40,
            Escape: 27,
            F1: 112,
            F2: 113,
        };
        const keycode = keycodes[e.key];
        if (keycode === undefined)
            return;
        e.preventDefault();
        Module._zeliard_key_up(keycode);
    });
    const releaseHeldKeys = () => Module._zeliard_release_all_keys();
    window.addEventListener('blur', releaseHeldKeys);
    document.addEventListener('visibilitychange', () => {
        if (document.hidden)
            releaseHeldKeys();
    });
    setStatus(music ? 'ready' : 'ready (audio unavailable)');

    function frame(now: number) {
        const dt = Math.max(0, Math.min(now - last, 100));
        last = now;
        tickRemainderMs += dt;
        const tickMs = Math.floor(tickRemainderMs);
        tickRemainderMs -= tickMs;
        Module._zeliard_tick(tickMs);
        const saveSerial = Module._zeliard_save_serial();
        if (saveSerial !== lastSaveSerial) {
            lastSaveSerial = saveSerial;
            const namePointer = Module._zeliard_save_name();
            let name = '';
            for (let at = namePointer;
                 Module.HEAPU8[at] && name.length < 12; ++at)
                name += String.fromCharCode(Module.HEAPU8[at]);
            const recordPointer = Module._zeliard_save_record();
            const record = Array.from(Module.HEAPU8.subarray(
                recordPointer, recordPointer + 0x100));
            console.log(`[zeliard] saved ${name} (${record.length} bytes)`);
            refreshSaveControls();
        }
        music?.sync(Module._zeliard_music_track(),
            Module._zeliard_music_enabled() !== 0,
            Module._zeliard_paused() !== 0,
            Module._zeliard_music_attenuation());
        paintFrame();
        requestAnimationFrame(frame);
    }
}

boot().catch((err) => {
    console.error(err);
    setStatus(`boot failed: ${err?.message ?? err}`);
});
