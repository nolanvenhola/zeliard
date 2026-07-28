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
    _zeliard_key(keycode: number): void;
    _zeliard_framebuf(): number;     // pointer (offset into HEAPU8)
    _zeliard_rgb_framebuf(): number; // optional RGB output for MCGA raster-DAC frames
    _zeliard_rgb_framebuf_active(): number;
    _zeliard_palette(): number;      // pointer to 256 RGB triples
    _zeliard_width(): number;
    _zeliard_height(): number;
    _zeliard_scene(): number;        // 0=title, 1=opening demo, 2=game handoff
    _zeliard_phase(): number;        // OPDMO phase while scene=opening
    _zeliard_phase_elapsed(): number;
    _zeliard_music_track(): number;  // 0=none, 1=zopn.msd, 2=zend.msd
    _zeliard_music_complete(track: number): void;
    _zeliard_music_attenuation(): number;
    _zeliard_paused(): number;
    _zeliard_music_enabled(): number;
    _zeliard_sound_enabled(): number;
    _zeliard_sound_cue(): number;
    _zeliard_opening_set_phase_for_test(phase: number): void;
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
const appBaseUrl = new URL(import.meta.env.BASE_URL, window.location.href);
const engineBaseUrl = new URL('engine/', appBaseUrl);
const audioBaseUrl = new URL('audio/', appBaseUrl);

class OpeningMusic {
    private readonly context = new AudioContext();
    private readonly gain = this.context.createGain();
    private readonly buffers = new Map<number, AudioBuffer>();
    private source: AudioBufferSourceNode | null = null;
    private activeTrack = 0;
    private playbackOffset = 0;
    private sourceStartedAt = 0;
    private playbackEnded = false;
    private trackEndedSink: ((track: number) => void) | null = null;

    constructor() {
        this.gain.connect(this.context.destination);
    }

    static async load(): Promise<OpeningMusic> {
        const music = new OpeningMusic();
        const tracks: Array<[number, string]> = [
            [1, 'zopn.ogg'],
            [2, 'zend.ogg'],
        ];
        await Promise.all(tracks.map(async ([id, name]) => {
            const response = await fetch(new URL(name, audioBaseUrl));
            if (!response.ok)
                throw new Error(`audio ${name}: HTTP ${response.status}`);
            const buffer = await music.context.decodeAudioData(await response.arrayBuffer());
            music.buffers.set(id, buffer);
        }));
        return music;
    }

    async unlock(): Promise<void> {
        await this.context.resume();
    }

    setTrackEndedSink(sink: (track: number) => void): void {
        this.trackEndedSink = sink;
    }

    private stopSource(preserveOffset: boolean): void {
        if (this.source) {
            if (preserveOffset) {
                const buffer = this.buffers.get(this.activeTrack);
                this.playbackOffset += this.context.currentTime - this.sourceStartedAt;
                if (buffer && buffer.duration > 0)
                    this.playbackOffset %= buffer.duration;
            }
            this.source.onended = null;
            this.source.stop();
            this.source.disconnect();
            this.source = null;
        }
    }

    sync(track: number, enabled: boolean, paused: boolean, attenuation: number): void {
        /* MSCADLIB applies FF25h/4 to the OPL total-level fields. OPL total
         * level is logarithmic in 0.75 dB steps; level 64 is followed by
         * key-off rather than another audible level. */
        const level = Math.max(0, Math.min(63, attenuation));
        this.gain.gain.setValueAtTime(Math.pow(10, (-0.75 * level) / 20),
            this.context.currentTime);
        if (track !== this.activeTrack) {
            this.stopSource(false);
            this.activeTrack = track;
            this.playbackOffset = 0;
            this.playbackEnded = false;
        }

        const shouldRun = track !== 0 && enabled && !paused && !this.playbackEnded;
        if (!shouldRun) {
            this.stopSource(track !== 0);
            return;
        }
        if (this.source)
            return;

        this.activeTrack = track;
        const buffer = this.buffers.get(track);
        if (!buffer)
            return;
        const source = this.context.createBufferSource();
        source.buffer = buffer;
        source.connect(this.gain);
        this.sourceStartedAt = this.context.currentTime;
        source.onended = () => {
            if (this.source !== source)
                return;
            source.disconnect();
            this.source = null;
            this.playbackOffset = buffer.duration;
            this.playbackEnded = true;
            this.trackEndedSink?.(track);
            console.log(`[zeliard] MASM music complete: track ${track}`);
        };
        source.start(0, this.playbackOffset);
        this.source = source;
        console.log(`[zeliard] MASM music resume: track ${track} @ ${this.playbackOffset.toFixed(3)}s`);
    }
}

class OpeningSound {
    private readonly context = new AudioContext();
    private readonly buffers = new Map<number, AudioBuffer>();

    static async load(): Promise<OpeningSound> {
        const sound = new OpeningSound();
        const cues: Array<[number, string]> = [
            [0x02, 'sfx_02.wav'],
            [0x04, 'sfx_04.wav'],
            [0x3d, 'sfx_3d.wav'],
            [0x3e, 'sfx_3e.wav'],
            [0x3f, 'sfx_3f.wav'],
            [0x40, 'sfx_40.wav'],
            [0x41, 'sfx_41.wav'],
        ];
        await Promise.all(cues.map(async ([cue, name]) => {
            const response = await fetch(new URL(name, audioBaseUrl));
            if (!response.ok)
                throw new Error(`audio ${name}: HTTP ${response.status}`);
            const buffer = await sound.context.decodeAudioData(await response.arrayBuffer());
            sound.buffers.set(cue, buffer);
        }));
        return sound;
    }

    async unlock(): Promise<void> {
        await this.context.resume();
    }

    play(cue: number): void {
        const buffer = this.buffers.get(cue);
        if (!buffer)
            return;
        const source = this.context.createBufferSource();
        source.buffer = buffer;
        source.connect(this.context.destination);
        source.start();
        console.log(`[zeliard] MASM SNDADLIB cue: ${cue}`);
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

    setStatus('loading opening music...');
    let music: OpeningMusic | null = null;
    let sound: OpeningSound | null = null;
    try {
        [music, sound] = await Promise.all([
            OpeningMusic.load(),
            OpeningSound.load(),
        ]);
    } catch (err) {
        console.error('[zeliard] audio load failed', err);
    }
    music?.setTrackEndedSink((track) => Module._zeliard_music_complete(track));

    let started = false;
    async function startPlayback() {
        if (started)
            return;
        await Promise.all([
            music?.unlock(),
            sound?.unlock(),
        ]);
        started = true;
        startButton.hidden = true;
        last = performance.now();
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
            Escape: 27,
            F1: 112,
            F2: 113,
        };
        const keycode = keycodes[e.key];
        if (keycode === undefined)
            return;
        e.preventDefault();
        if (e.repeat)
            return;
        if (!started) {
            void startPlayback();
            return;
        }
        Module._zeliard_key(keycode);
        music?.sync(Module._zeliard_music_track(),
            Module._zeliard_music_enabled() !== 0,
            Module._zeliard_paused() !== 0,
            Module._zeliard_music_attenuation());
        sound?.play(Module._zeliard_sound_cue());
    });
    setStatus(music ? 'ready' : 'ready (audio unavailable)');

    function frame(now: number) {
        const dt = Math.max(0, Math.min(now - last, 100));
        last = now;
        Module._zeliard_tick(dt | 0);
        music?.sync(Module._zeliard_music_track(),
            Module._zeliard_music_enabled() !== 0,
            Module._zeliard_paused() !== 0,
            Module._zeliard_music_attenuation());
        const cue = Module._zeliard_sound_cue();
        sound?.play(cue);
        paintFrame();
        requestAnimationFrame(frame);
    }
}

boot().catch((err) => {
    console.error(err);
    setStatus(`boot failed: ${err?.message ?? err}`);
});
