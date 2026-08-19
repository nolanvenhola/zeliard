import { firstConnectedGamepad, mapBrowserGamepad,
    type GamepadMask } from './gamepad';
import { applyDisplayMode, parseDisplayMode,
    type DisplayMode } from './display';
import { cavernMinimapWorldAt, decodeCavernMap, drawCavernMinimap,
    readCavernObjects, type CavernMap,
    type CavernPin, type MinimapPosition } from './minimap';

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
    _zeliard_gamepad_update(connected: number, directions: number,
        buttons: number): void;
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
    _zeliard_speed_menu_active(): number;
    _zeliard_restore_menu_active(): number;
    _zeliard_load_request_serial(): number;
    _zeliard_game_speed_digit(): number;
    _zeliard_debug_invincible(): number;
    _zeliard_debug_set_invincible(enabled: number): void;
    _zeliard_debug_unlimited_magic(): number;
    _zeliard_debug_set_unlimited_magic(enabled: number): void;
    _zeliard_debug_no_gravity(): number;
    _zeliard_debug_set_no_gravity(enabled: number): void;
    _zeliard_debug_restore_shield_magic(): void;
    _zeliard_debug_add_item(itemId: number): number;
    _zeliard_test_defeat_jashiin(): number;
    _zeliard_test_start_ending(): number;
    _zeliard_session_terminated(): number;
    _zeliard_music_enabled(): number;
    _zeliard_sound_enabled(): number;
    _zeliard_sound_cue(): number;
    _zeliard_audio_pcm(stereo: number, frames: number): number;
    _zeliard_audio_pcm_available(): number;
    _zeliard_audio_set_sample_rate(sampleRate: number): void;
    _zeliard_audio_opl_write_count(): number;
    _zeliard_audio_generated_peak(): number;
    _zeliard_audio_cue_serial(): number;
    _zeliard_audio_cue_rebase_serial(): number;
    _zeliard_audio_reset_serial(): number;
    _zeliard_exact_music_driver(): number;
    _zeliard_audio_set_backend(backend: number): number;
    _zeliard_audio_backend(): number;
    _zeliard_audio_backend_fallback(): number;
    _zeliard_opening_set_phase_for_test(phase: number): void;
    _zeliard_room_kind(): number;
    _zeliard_town_dialog_active(): number;
    _zeliard_inventory_active(): number;
    _zeliard_town_area(): number;
    _zeliard_town_cavern_exit_requested(): number;
    _zeliard_cavern_transition_active(): number;
    _zeliard_cavern_transition_complete(): number;
    _zeliard_cavern_transition_step(): number;
    _zeliard_fight_active(): number;
    _zeliard_fight_ip(): number;
    _zeliard_fight_map_width(): number;
    _zeliard_fight_boundary(): number;
    _zeliard_test_fight_u8(offset: number): number;
    _zeliard_test_restart_fight(selector: number, startPosition: number,
        mapScrollRow: number, screenPosition: number): number;
    _zeliard_test_enter_room(kind: number): number;
    _zeliard_test_restart_town(area: number): number;
    _zeliard_save_serial(): number;
    _zeliard_save_name(): number;
    _zeliard_save_record(): number;
    _zeliard_load_record(record: number, size: number): number;
    _zeliard_guest_tick(): number;
    _zeliard_game_segment(): number;
    _zeliard_game_segment_size(): number;
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

const startButton = document.getElementById('start') as HTMLButtonElement;
const canvas = document.getElementById('screen') as HTMLCanvasElement;
const ctx = canvas.getContext('2d', { alpha: false })!;
const storedSaveControlsEl = document.getElementById(
    'stored-save-controls') as HTMLSpanElement;
const restartEl = document.getElementById('restart') as HTMLButtonElement;
const saveSelectEl = document.getElementById('save-select') as HTMLSelectElement;
const loadSaveEl = document.getElementById('load-save') as HTMLButtonElement;
const downloadSaveEl = document.getElementById(
    'download-save') as HTMLButtonElement;
const openSaveEl = document.getElementById('open-save') as HTMLInputElement;
const audioBackendEl = document.getElementById('audio-backend') as HTMLSelectElement;
const displayModeEl = document.getElementById('display-mode') as HTMLSelectElement;
const musicToggleEl = document.getElementById('music-toggle') as HTMLButtonElement;
const soundToggleEl = document.getElementById('sound-toggle') as HTMLButtonElement;
const gameSpeedEl = document.getElementById('game-speed') as HTMLSelectElement;
const invincibleToggleEl = document.getElementById(
    'invincible-toggle') as HTMLButtonElement;
const unlimitedMagicToggleEl = document.getElementById(
    'unlimited-magic-toggle') as HTMLButtonElement;
const debugKillBossEl = document.getElementById(
    'debug-kill-boss') as HTMLButtonElement;
const debugStartEndingEl = document.getElementById(
    'debug-start-ending') as HTMLButtonElement;
const restoreResourcesEl = document.getElementById(
    'restore-resources') as HTMLButtonElement;
const debugItemSelectEl = document.getElementById(
    'debug-item-select') as HTMLSelectElement;
const debugAddItemEl = document.getElementById(
    'debug-add-item') as HTMLButtonElement;
const flyingToggleEl = document.getElementById(
    'flying-toggle') as HTMLButtonElement;
const debugWarpDestinationEl = document.getElementById(
    'debug-warp-destination') as HTMLSelectElement;
const debugWarpRoomEl = document.getElementById(
    'debug-warp-room') as HTMLButtonElement;
const debugWarpMapEl = document.getElementById(
    'debug-warp-map') as HTMLButtonElement;
const debugToggleEl = document.getElementById(
    'debug-toggle') as HTMLButtonElement;
const debugControlsEl = document.getElementById(
    'debug-controls') as HTMLDivElement;
const minimapToggleEl = document.getElementById(
    'minimap-toggle') as HTMLButtonElement;
const minimapEl = document.getElementById('minimap') as HTMLElement;
const minimapCanvasEl = document.getElementById(
    'minimap-canvas') as HTMLCanvasElement;
const minimapDetailsEl = document.getElementById(
    'minimap-details') as HTMLDivElement;
const checkpointSlotEl = document.getElementById(
    'checkpoint-slot') as HTMLSelectElement;
const checkpointNameEl = document.getElementById(
    'checkpoint-name') as HTMLInputElement;
const checkpointSaveEl = document.getElementById(
    'checkpoint-save') as HTMLButtonElement;
const checkpointLoadEl = document.getElementById(
    'checkpoint-load') as HTMLButtonElement;
const checkpointClearEl = document.getElementById(
    'checkpoint-clear') as HTMLButtonElement;
const checkpointOpenEl = document.getElementById(
    'checkpoint-open') as HTMLInputElement;
const checkpointStatusEl = document.getElementById(
    'checkpoint-status') as HTMLOutputElement;
const keymapOpenEl = document.getElementById('keymap-open') as HTMLButtonElement;
const keymapCloseEl = document.getElementById('keymap-close') as HTMLButtonElement;
const keymapDialogEl = document.getElementById('keymap-dialog') as HTMLDialogElement;
const playerLevelEl = document.getElementById('player-level') as HTMLOutputElement;
const playerExperienceEl = document.getElementById(
    'player-experience') as HTMLOutputElement;
const playerExperienceThresholdEl = document.getElementById(
    'player-experience-threshold') as HTMLOutputElement;
/* 217KENJP sage_hp_thresh at A28Ch. Experience is spent on growth, so this
 * is the per-level target required by the next blessing. */
const experienceThresholds = [
    50, 150, 300, 420, 1000, 1500, 3000, 5000,
    6000, 8000, 10000, 15000, 20000, 40000, 50000, 60000,
];
const appBaseUrl = new URL(import.meta.env.BASE_URL, window.location.href);
const engineBaseUrl = new URL('engine/', appBaseUrl);

class OpeningMusic {
    private readonly node: AudioWorkletNode;
    private readonly pcmPointer: number;
    private readonly pumpFrames = 3072;
    private activeTrack = -1;
    private cueSerial = 0;
    private cueRebaseSerial = 0;
    private resetSerial = 0;
    private bufferTargetFrames = 4096;
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
        contextState: 'suspended' as AudioContextState,
    };

    private constructor(private readonly module: ZeliardModule,
                        private readonly context: AudioContext) {
        this.module._zeliard_audio_set_sample_rate(this.context.sampleRate);
        this.cueSerial = this.module._zeliard_audio_cue_serial();
        this.cueRebaseSerial =
            this.module._zeliard_audio_cue_rebase_serial();
        this.resetSerial = this.module._zeliard_audio_reset_serial();
        this.pcmPointer = this.module._malloc(
            this.pumpFrames * 2 * Int16Array.BYTES_PER_ELEMENT);
        this.node = new AudioWorkletNode(this.context, 'zeliard-pcm', {
            numberOfInputs: 0,
            numberOfOutputs: 1,
            outputChannelCount: [2],
        });
        this.node.port.onmessage = (event: MessageEvent) => {
            if (event.data?.type !== 'stats') return;
            Object.assign(this.stats, event.data.stats);
            this.stats.contextState = this.context.state;
        };
        this.node.connect(this.context.destination);
    }

    static async load(module: ZeliardModule): Promise<OpeningMusic> {
        if (!module._zeliard_exact_music_driver())
            throw new Error('original audio driver runtime unavailable');
        const context = new AudioContext({ latencyHint: 'interactive' });
        const workletUrl = new URL('audio-worklet.js', appBaseUrl);
        workletUrl.searchParams.set('v', Date.now().toString(36));
        await context.audioWorklet.addModule(workletUrl.href);
        return new OpeningMusic(module, context);
    }

    async unlock(): Promise<void> {
        await this.context.resume();
        this.stats.contextState = this.context.state;
    }

    pump(): void {
        const cueSerial = this.module._zeliard_audio_cue_serial();
        if (cueSerial !== this.cueSerial) {
            this.cueSerial = cueSerial;
            this.stats.cueSerial = cueSerial;
            this.stats.cueBypassCount++;
        }
        const cueRebaseSerial =
            this.module._zeliard_audio_cue_rebase_serial();
        if (cueRebaseSerial !== this.cueRebaseSerial) {
            this.cueRebaseSerial = cueRebaseSerial;
            /* Only the town NPC/page dialog path discards pre-cue PCM.
             * Shop character cues remain continuous and never rebase. */
            if (this.bufferTargetFrames === 1024)
                this.node.port.postMessage({ type: 'cue-rebase' });
        }
        let buffered = this.module._zeliard_audio_pcm_available();
        while (buffered > 0) {
            const requested = Math.min(buffered, this.pumpFrames);
            const delivered = this.module._zeliard_audio_pcm(
                this.pcmPointer, requested);
            if (delivered <= 0) break;
            const source = new Int16Array(this.module.HEAPU8.buffer,
                this.pcmPointer, delivered * 2);
            const pcm = new Int16Array(source);
            this.node.port.postMessage({ type: 'pcm', pcm }, [pcm.buffer]);
            buffered -= delivered;
        }
    }

    setLowLatency(enabled: boolean): void {
        const targetFrames = enabled ? 1024 : 4096;
        if (targetFrames === this.bufferTargetFrames) return;
        this.bufferTargetFrames = targetFrames;
        this.node.port.postMessage({
            type: 'buffer-target',
            frames: targetFrames,
        });
    }

    sync(track: number, enabled: boolean, paused: boolean, attenuation: number): void {
        const resetSerial = this.module._zeliard_audio_reset_serial();
        if (track !== this.activeTrack || resetSerial !== this.resetSerial) {
            this.activeTrack = track;
            this.resetSerial = resetSerial;
            this.node.port.postMessage({ type: 'reset' });
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

/* Status strings used to be rendered below the game and mirrored to the
 * console.  Keep call sites as internal state annotations without exposing
 * the development feed in the player UI. */
function setStatus(_msg: string) {}

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
        print:    () => {},
        printErr: (s: string) => console.error('[wasm]', s),
        locateFile: (path: string) => {
            const assetUrl = new URL(path, engineBaseUrl);
            assetUrl.searchParams.set('v', engineCacheBust);
            return assetUrl.href;
        },
    });
    const requestedAudio = Math.max(0, Math.min(3, Number(
        params.get('audio') ?? localStorage.getItem('zeliard.audioBackend') ?? '0')));
    audioBackendEl.value = String(requestedAudio);
    Module._zeliard_audio_set_backend(requestedAudio);
    audioBackendEl.value = String(Module._zeliard_audio_backend());
    audioBackendEl.addEventListener('change', () => {
        const backend = Number(audioBackendEl.value);
        localStorage.setItem('zeliard.audioBackend', String(backend));
        Module._zeliard_audio_set_backend(backend);
        audioBackendEl.value = String(Module._zeliard_audio_backend());
        if (Module._zeliard_audio_backend_fallback())
            setStatus('selected audio unavailable; using AdLib');
    });
    let displayMode: DisplayMode = parseDisplayMode(
        params.get('display') ?? localStorage.getItem('zeliard.displayMode'));
    displayModeEl.value = String(displayMode);
    displayModeEl.addEventListener('change', () => {
        displayMode = parseDisplayMode(displayModeEl.value);
        localStorage.setItem('zeliard.displayMode', String(displayMode));
    });

    setStatus('initialising engine…');
    Module._zeliard_init();
    (window as any).__zeliard = Module;

    let debugToolsEnabled =
        localStorage.getItem('zeliard.debugTools') === 'true';
    type MinimapMode = 'off' | 'compact' | 'expanded';
    const savedMinimapMode = localStorage.getItem('zeliard.minimapMode');
    let minimapMode: MinimapMode = savedMinimapMode === 'compact' ||
        savedMinimapMode === 'expanded' ? savedMinimapMode : 'off';
    let minimapMap: CavernMap | null = null;
    let minimapMapKey = '';
    let minimapSelector = -1;
    let minimapCenter: { x: number; y: number } | null = null;
    let minimapLastPosition: MinimapPosition | null = null;
    let minimapPins: CavernPin[] = [];
    let minimapWarpArmed = false;
    const minimapPinKey = (selector: number) =>
        `zeliard.minimapPins.${selector.toString(16).padStart(2, '0')}`;
    const loadMinimapPins = (selector: number): CavernPin[] => {
        try {
            const pins = JSON.parse(localStorage.getItem(
                minimapPinKey(selector)) ?? '[]');
            return Array.isArray(pins) ? pins.filter((pin: any) =>
                Number.isInteger(pin?.x) && Number.isInteger(pin?.y) &&
                Number.isInteger(pin?.number)).slice(0, 99) : [];
        } catch {
            return [];
        }
    };
    const saveMinimapPins = () => {
        if (minimapSelector >= 0)
            localStorage.setItem(minimapPinKey(minimapSelector),
                JSON.stringify(minimapPins));
    };
    type DebugCheckpoint = {
        version: 1;
        name: string;
        savedAt: string;
        location: 'town' | 'cavern';
        area: number;
        selector: number;
        startPosition: number;
        mapScrollRow: number;
        screenPosition: number;
        playerY: number;
        record: number[];
    };
    const checkpointKey = (slot: string) =>
        `zeliard.debugCheckpoint.${slot}`;
    const townNames = [
        'Felishika', 'Muralla', 'Satono', 'Bosque', 'Helada',
        'Tumba', 'Dorado', 'Llama', 'Pureza', 'Esco',
    ];
    const cavernMapNames = [
        'MP10', 'MP1D', 'MP20', 'MP21', 'MP2D', 'MP30', 'MP31', 'MP3D',
        'MP40', 'MP41', 'MP4D', 'MP50', 'MP51', 'MP5D', 'MP60', 'MP61',
        'MP62', 'MP6D', 'MP70', 'MP71', 'MP72', 'MP73', 'MP7D', 'MP80',
        'MP81', 'MP82', 'MP83', 'MP84', 'MP8D', 'MP90', 'MPA0',
    ];
    const isCheckpoint = (value: any): value is DebugCheckpoint =>
        value?.version === 1 && typeof value.name === 'string' &&
        typeof value.savedAt === 'string' &&
        (value.location === 'town' || value.location === 'cavern') &&
        Number.isInteger(value.area) && Number.isInteger(value.selector) &&
        Number.isInteger(value.startPosition) &&
        Number.isInteger(value.mapScrollRow) &&
        Number.isInteger(value.screenPosition) && Number.isInteger(value.playerY) &&
        Array.isArray(value.record) && value.record.length === 0x100 &&
        value.record.every((byte: unknown) => Number.isInteger(byte) &&
            (byte as number) >= 0 && (byte as number) <= 0xFF);
    const readCheckpoint = (slot = checkpointSlotEl.value):
            DebugCheckpoint | null => {
        try {
            const value = JSON.parse(localStorage.getItem(
                checkpointKey(slot)) ?? 'null');
            if (!isCheckpoint(value)) return null;
            /* Active 200FIGHT keeps its current map selector in C4. Early
             * debug-state files incorrectly stored C8 (the level resource
             * index), which could restart in a different cavern. Recover
             * those files from their embedded live player record. */
            if (value.location === 'cavern' && value.record[0xC4] < 0x80)
                value.selector = value.record[0xC4];
            return value;
        } catch {
            return null;
        }
    };
    const checkpointDescription = (checkpoint: DebugCheckpoint) => {
        const place = checkpoint.location === 'cavern'
            ? `${cavernMapNames[checkpoint.selector] ??
                `Cavern ${checkpoint.selector.toString(16).toUpperCase()
                    .padStart(2, '0')}`} @ ${checkpoint.startPosition +
                checkpoint.screenPosition + 4},${(checkpoint.mapScrollRow +
                checkpoint.playerY + 3) & 0x3F}`
            : `${townNames[checkpoint.area] ?? `Town ${checkpoint.area}`} @ ${
                checkpoint.startPosition + checkpoint.screenPosition}`;
        return place;
    };
    const canSaveCheckpoint = () => Module._zeliard_scene() === 2 &&
        Module._zeliard_cavern_transition_active() === 0 &&
        Module._zeliard_inventory_active() === 0 &&
        Module._zeliard_town_dialog_active() === 0;
    const refreshCheckpointControls = () => {
        for (const option of Array.from(checkpointSlotEl.options)) {
            const checkpoint = readCheckpoint(option.value);
            option.textContent = checkpoint
                ? `${checkpoint.name} — ${checkpointDescription(checkpoint)}`
                : `Checkpoint ${option.value} — empty`;
        }
        const selected = readCheckpoint();
        checkpointSaveEl.disabled = !canSaveCheckpoint();
        checkpointLoadEl.disabled = !selected;
        checkpointClearEl.disabled = !selected;
    };
    const safeCheckpointName = (name: string) => name.trim()
        .replace(/\.zstate$/i, '').replace(/[<>:"/\\|?*\x00-\x1F]/g, '_')
        .replace(/[. ]+$/g, '').slice(0, 40) ||
        `checkpoint-${checkpointSlotEl.value}`;
    const downloadCheckpoint = (checkpoint: DebugCheckpoint) => {
        const url = URL.createObjectURL(new Blob(
            [JSON.stringify(checkpoint, null, 2)],
            { type: 'application/json' }));
        const anchor = document.createElement('a');
        anchor.href = url;
        anchor.download = `${safeCheckpointName(checkpoint.name)}.zstate`;
        anchor.click();
        setTimeout(() => URL.revokeObjectURL(url), 0);
    };

    const w = Module._zeliard_width();
    const h = Module._zeliard_height();
    const fbPtr = Module._zeliard_framebuf();
    const rgbPtr = Module._zeliard_rgb_framebuf();
    const palPtr = Module._zeliard_palette();
    setStatus(`engine running — ${w}×${h}, framebuf @ ${fbPtr}, palette @ ${palPtr}`);

    const imageData = ctx.createImageData(w, h);
    let last = performance.now();
    let lastScene = -1;
    let lastPhase = -1;
    let lastPhaseElapsedBucket = -1;
    let lastPaused = false;
    let lastTerminated = false;
    let lastPresentedIndices: Uint8Array | null = null;
    let lastPresentedPalette: Uint8Array | null = null;
    let visualPresentSequence = 0;
    type VisualPresentEvent = {
        sequence: number; op: string; x: number; y: number;
        width: number; height: number; changedPixels: number;
        hash: string; paletteHash: string; paletteChanged: boolean;
        scene: number; phase: number;
    };
    const visualPresentTrace: VisualPresentEvent[] = [];
    const hashBytes = (bytes: Uint8Array): string => {
        let hash = 0x811c9dc5;
        for (const byte of bytes) {
            hash ^= byte;
            hash = Math.imul(hash, 0x01000193) >>> 0;
        }
        return hash.toString(16).padStart(8, '0');
    };
    const recordPresent = (indices: Uint8Array, palette: Uint8Array) => {
        let minX = w, minY = h, maxX = -1, maxY = -1, changed = 0;
        if (lastPresentedIndices) {
            for (let i = 0; i < indices.length; i++) {
                if (indices[i] === lastPresentedIndices[i]) continue;
                const x = i % w;
                const y = Math.floor(i / w);
                minX = Math.min(minX, x); minY = Math.min(minY, y);
                maxX = Math.max(maxX, x); maxY = Math.max(maxY, y);
                changed++;
            }
        } else {
            minX = 0; minY = 0; maxX = w - 1; maxY = h - 1;
            changed = indices.length;
        }
        const paletteHash = hashBytes(palette);
        visualPresentTrace.push({
            sequence: visualPresentSequence++, op: 'present',
            x: changed ? minX : 0, y: changed ? minY : 0,
            width: changed ? maxX - minX + 1 : 0,
            height: changed ? maxY - minY + 1 : 0,
            changedPixels: changed, hash: hashBytes(indices), paletteHash,
            paletteChanged: !lastPresentedPalette ||
                paletteHash !== hashBytes(lastPresentedPalette),
            scene: Module._zeliard_scene(), phase: Module._zeliard_phase(),
        });
        if (visualPresentTrace.length > 256) visualPresentTrace.shift();
        lastPresentedIndices = Uint8Array.from(indices);
        lastPresentedPalette = Uint8Array.from(palette);
    };
    (window as any).__zeliardVisualCapture = (checkpoint: string) => ({
        schemaVersion: 1,
        checkpoint,
        runtime: 'wasm',
        videoMode: 'mcga-320x200x8',
        width: w,
        height: h,
        indices: Array.from(Module.HEAPU8.slice(fbPtr, fbPtr + w * h)),
        palette: Array.from(Module.HEAPU8.slice(palPtr, palPtr + 256 * 3)),
        rgbActive: Module._zeliard_rgb_framebuf_active() !== 0,
        dirtyRect: visualPresentTrace.length
            ? visualPresentTrace[visualPresentTrace.length - 1] : null,
        renderTrace: visualPresentTrace.map(event => ({ ...event })),
    });
    let lastSaveSerial = Module._zeliard_save_serial();
    let lastLoadRequestSerial = Module._zeliard_load_request_serial();

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
    const loadRecord = (record: ArrayLike<number>) => {
        if (record.length !== 0x100) return false;
        const pointer = Module._malloc(0x100);
        if (!pointer) return false;
        Module.HEAPU8.set(record, pointer);
        const loaded = Module._zeliard_load_record(pointer, 0x100) !== 0;
        Module._free(pointer);
        return loaded;
    };
    const findSave = (name: string) => listSaves().find((candidate) =>
            candidate.name.toUpperCase() === name.toUpperCase() ||
            candidate.name.toUpperCase() === `${name.toUpperCase()}.USR`);
    const loadSave = (name: string) => {
        const save = findSave(name);
        if (!save) return false;
        return loadRecord(save.record);
    };
    (window as any).__zeliardLoadSave = loadSave;
    const downloadRecord = (name: string, record: ArrayLike<number>) => {
        if (record.length !== 0x100) return false;
        const filename = name.toLowerCase().endsWith('.usr')
            ? name : `${name}.usr`;
        const url = URL.createObjectURL(new Blob(
            [Uint8Array.from(record)], { type: 'application/octet-stream' }));
        const anchor = document.createElement('a');
        anchor.href = url;
        anchor.download = filename;
        anchor.click();
        setTimeout(() => URL.revokeObjectURL(url), 0);
        return true;
    };
    (window as any).__zeliardDownloadSave = (name: string) => {
        const save = findSave(name);
        return !!save && downloadRecord(save.name, save.record);
    };
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
        storedSaveControlsEl.hidden = saves.length === 0 ||
            Module._zeliard_session_terminated() !== 0;
    };
    const refreshSessionControls = () => {
        const terminated = Module._zeliard_session_terminated() !== 0;
        restartEl.hidden = !terminated;
        if (terminated) {
            storedSaveControlsEl.hidden = true;
            setStatus('session ended');
        } else {
            refreshSaveControls();
        }
    };
    loadSaveEl.addEventListener('click', () => {
        if (!saveSelectEl.value) return;
        if (!loadSave(saveSelectEl.value))
            setStatus('saved game could not be loaded');
        else
            refreshSessionControls();
    });
    downloadSaveEl.addEventListener('click', () => {
        const save = findSave(saveSelectEl.value);
        if (!save || !downloadRecord(save.name, save.record))
            setStatus('saved game could not be downloaded');
    });
    openSaveEl.addEventListener('change', async () => {
        const file = openSaveEl.files?.[0];
        openSaveEl.value = '';
        if (!file) return;
        const record = new Uint8Array(await file.arrayBuffer());
        if (record.length !== 0x100) {
            setStatus(`${file.name} is not a 256-byte Zeliard save`);
            return;
        }
        const base = file.name.replace(/\.usr$/i, '').slice(0, 8);
        const name = `${base || 'ZELIARD'}.usr`;
        localStorage.setItem(`zeliard.save.${name.toUpperCase()}`,
            JSON.stringify({ version: 1, name, record: Array.from(record) }));
        refreshSaveControls();
        if (!loadRecord(record)) {
            setStatus(`${file.name} could not be loaded`);
            return;
        }
        refreshSessionControls();
        saveSelectEl.value = name;
        setStatus(`loaded ${name}`);
    });
    restartEl.addEventListener('click', () => {
        Module._zeliard_init();
        last = performance.now();
        lastScene = -1;
        lastPhase = -1;
        lastPhaseElapsedBucket = -1;
        lastPaused = false;
        lastTerminated = false;
        refreshSessionControls();
        paintFrame();
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
        applyDisplayMode(out, w, h, displayMode);
        ctx.putImageData(imageData, 0, 0);
        if (deterministicCapture) recordPresent(fb, pal);

        refreshMinimap();

    }

    paintFrame();

    if (deterministicCapture) {
        setStatus(`engine capture-ready - ${sceneName(Module._zeliard_scene())} / phase ${Module._zeliard_phase()} / ${Module._zeliard_phase_elapsed()}ms`);
        return;
    }

    setStatus('loading original audio driver...');
    let music: OpeningMusic | null = null;
    try {
        music = await OpeningMusic.load(Module);
    } catch (err) {
        console.error('[zeliard] audio load failed', err);
    }
    let started = false;
    let tickRemainderMs = 0;
    let gamepadConnected = false;
    let gamepadMask: GamepadMask = { directions: 0, buttons: 0 };

    function pollGamepad() {
        const pad = typeof navigator.getGamepads === 'function'
            ? firstConnectedGamepad(Array.from(navigator.getGamepads()))
            : null;
        const connected = pad !== null;
        const next = pad ? mapBrowserGamepad(pad, gamepadMask)
            : { directions: 0, buttons: 0 };
        if (connected !== gamepadConnected ||
            next.directions !== gamepadMask.directions ||
            next.buttons !== gamepadMask.buttons) {
            Module._zeliard_gamepad_update(connected ? 1 : 0,
                next.directions, next.buttons);
        }
        gamepadConnected = connected;
        gamepadMask = next;
    }
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

    function refreshGameControls() {
        const musicEnabled = Module._zeliard_music_enabled() !== 0;
        const soundEnabled = Module._zeliard_sound_enabled() !== 0;
        musicToggleEl.textContent = `Music: ${musicEnabled ? 'On' : 'Off'}`;
        musicToggleEl.setAttribute('aria-pressed', String(musicEnabled));
        soundToggleEl.textContent = `Sound FX: ${soundEnabled ? 'On' : 'Off'}`;
        soundToggleEl.setAttribute('aria-pressed', String(soundEnabled));
        gameSpeedEl.value = String(Module._zeliard_game_speed_digit());
        gameSpeedEl.disabled = Module._zeliard_scene() !== 2 ||
            Module._zeliard_paused() !== 0;
        const debugEnabled = Module._zeliard_scene() === 2;
        const invincible = Module._zeliard_debug_invincible() !== 0;
        const unlimitedMagic = Module._zeliard_debug_unlimited_magic() !== 0;
        const flying = Module._zeliard_debug_no_gravity() !== 0;
        invincibleToggleEl.textContent =
            `Invincible: ${invincible ? 'On' : 'Off'}`;
        invincibleToggleEl.setAttribute('aria-pressed', String(invincible));
        unlimitedMagicToggleEl.textContent =
            `Unlimited Magic: ${unlimitedMagic ? 'On' : 'Off'}`;
        unlimitedMagicToggleEl.setAttribute(
            'aria-pressed', String(unlimitedMagic));
        flyingToggleEl.textContent = `Flying: ${flying ? 'On' : 'Off'}`;
        flyingToggleEl.setAttribute('aria-pressed', String(flying));
        invincibleToggleEl.disabled = !debugEnabled;
        unlimitedMagicToggleEl.disabled = !debugEnabled;
        flyingToggleEl.disabled = !debugEnabled;
        restoreResourcesEl.disabled = !debugEnabled;
        debugItemSelectEl.disabled = !debugEnabled;
        debugAddItemEl.disabled = !debugEnabled;
        debugWarpDestinationEl.disabled = !debugEnabled;
        debugWarpRoomEl.disabled = !debugEnabled;
        const fightActive = debugEnabled &&
            Module._zeliard_fight_active() !== 0;
        debugKillBossEl.disabled = !fightActive;
        debugStartEndingEl.disabled = !debugEnabled;
        if (!fightActive) minimapWarpArmed = false;
        debugWarpMapEl.disabled = !fightActive;
        debugWarpMapEl.textContent = `Warp on Map: ${
            minimapWarpArmed ? 'On' : 'Off'}`;
        debugWarpMapEl.setAttribute('aria-pressed', String(minimapWarpArmed));
        debugControlsEl.hidden = !debugToolsEnabled;
        debugToggleEl.textContent = `Testing Tools: ${
            debugToolsEnabled ? 'On' : 'Off'}`;
        debugToggleEl.setAttribute('aria-pressed', String(debugToolsEnabled));
        minimapToggleEl.disabled = !fightActive;
        minimapToggleEl.textContent = `Map: ${minimapMode === 'off' ? 'Off' :
            minimapMode === 'compact' ? 'Compact' : 'Large'}`;
        minimapToggleEl.setAttribute('aria-pressed', String(
            minimapMode !== 'off'));
        refreshCheckpointControls();

        if (Module._zeliard_scene() === 2) {
            const player = Module._zeliard_game_segment();
            const level = Module.HEAPU8[player + 0x8D];
            const experience =
                Module.HEAPU8[player + 0x8E] |
                (Module.HEAPU8[player + 0x8F] << 8);
            const threshold = experienceThresholds[Math.min(level, 15)];
            playerLevelEl.value = String(level);
            playerExperienceEl.value = String(experience);
            playerExperienceThresholdEl.value = String(threshold);
        } else {
            playerLevelEl.value = '—';
            playerExperienceEl.value = '—';
            playerExperienceThresholdEl.value = '—';
        }
    }

    function setMinimapMode(mode: MinimapMode) {
        if (mode === 'expanded' && minimapMode !== 'expanded')
            minimapCenter = null;
        if (mode !== 'expanded') minimapWarpArmed = false;
        minimapMode = mode;
        localStorage.setItem('zeliard.minimapMode', mode);
        refreshGameControls();
        refreshMinimap();
    }

    function refreshMinimap() {
        const active = debugToolsEnabled && minimapMode !== 'off' &&
            Module._zeliard_scene() === 2 &&
            Module._zeliard_fight_active() !== 0;
        minimapEl.hidden = !active;
        if (!active) return;

        const player = Module._zeliard_game_segment();
        const selector = Module.HEAPU8[player + 0xC4];
        const width = Module._zeliard_fight_map_width();
        const mapKey = `${selector}:${width}`;
        const readFightByte = (offset: number) =>
            Module._zeliard_test_fight_u8(offset);
        if (!minimapMap || mapKey !== minimapMapKey) {
            minimapMap = decodeCavernMap(readFightByte, selector);
            minimapMapKey = mapKey;
            minimapSelector = selector;
            minimapCenter = null;
            minimapPins = loadMinimapPins(selector);
        }
        if (!minimapMap) {
            minimapEl.hidden = true;
            return;
        }

        const scrollX = Module.HEAPU8[player + 0x80] |
            (Module.HEAPU8[player + 0x81] << 8);
        const scrollY = Module.HEAPU8[player + 0x82];
        const screenX = Module.HEAPU8[player + 0x83];
        const screenY = Module.HEAPU8[player + 0x84];
        const playerX = (scrollX + screenX + 4) % minimapMap.width;
        const playerY = (scrollY + screenY + 3) & 0x3F;
        const expanded = minimapMode === 'expanded';
        minimapLastPosition = { playerX, playerY, scrollX, scrollY };
        minimapEl.classList.toggle('expanded', expanded);
        minimapEl.classList.toggle('warp-armed', expanded && minimapWarpArmed);
        drawCavernMinimap(minimapCanvasEl, minimapMap, {
            playerX, playerY, scrollX, scrollY,
        }, readCavernObjects(readFightByte), expanded, {
            centerX: minimapCenter?.x,
            centerY: minimapCenter?.y,
            pins: minimapPins,
        });
        minimapDetailsEl.textContent = expanded && minimapWarpArmed
            ? `Select destination  ·  Click: warp  ·  ` +
              `Drag/wheel: pan  ·  Warp on Map: cancel`
            : expanded
            ? `Map ${selector.toString(16).toUpperCase().padStart(2, '0')}  ` +
              `${minimapMap.width}\u00d7${minimapMap.height}  ` +
              `Player ${playerX},${playerY}  ·  Drag/wheel: pan  ·  ` +
              `Click: toggle pin  ·  Right-click: remove  ·  ` +
              `Middle-click: recenter`
            : 'M: hide  Shift+M: enlarge';
    }

    musicToggleEl.addEventListener('click', async () => {
        await startPlayback();
        Module._zeliard_key(112); // F1: stick.asm music toggle
        music?.sync(Module._zeliard_music_track(),
            Module._zeliard_music_enabled() !== 0,
            Module._zeliard_paused() !== 0,
            Module._zeliard_music_attenuation());
        refreshGameControls();
    });
    soundToggleEl.addEventListener('click', async () => {
        await startPlayback();
        Module._zeliard_key(113); // F2: stick.asm sound-effects toggle
        refreshGameControls();
    });
    gameSpeedEl.addEventListener('change', () => {
        if (Module._zeliard_scene() !== 2 || Module._zeliard_paused()) {
            refreshGameControls();
            return;
        }
        /* Use the original F9 dialog path so the browser control and the
         * keyboard option update the same shared FF33h speed byte. */
        Module._zeliard_key(120);
        Module._zeliard_text_key(gameSpeedEl.value.charCodeAt(0));
        Module._zeliard_key(32);
        refreshGameControls();
    });
    invincibleToggleEl.addEventListener('click', () => {
        Module._zeliard_debug_set_invincible(
            Module._zeliard_debug_invincible() ? 0 : 1);
        refreshGameControls();
    });
    unlimitedMagicToggleEl.addEventListener('click', () => {
        Module._zeliard_debug_set_unlimited_magic(
            Module._zeliard_debug_unlimited_magic() ? 0 : 1);
        refreshGameControls();
    });
    debugKillBossEl.addEventListener('click', () => {
        Module._zeliard_release_all_keys();
        const defeated = Module._zeliard_test_defeat_jashiin() !== 0;
        debugKillBossEl.textContent = defeated ? 'Boss Defeated' : 'Not in Jashiin Fight';
        window.setTimeout(() => {
            debugKillBossEl.textContent = 'Kill Boss';
        }, 1200);
        refreshGameControls();
    });
    debugStartEndingEl.addEventListener('click', () => {
        Module._zeliard_release_all_keys();
        const started = Module._zeliard_test_start_ending() !== 0;
        debugStartEndingEl.textContent = started ? 'Ending Started' : 'Start Failed';
        window.setTimeout(() => {
            debugStartEndingEl.textContent = 'Start Final Ending';
        }, 1200);
        minimapWarpArmed = false;
        refreshGameControls();
    });
    restoreResourcesEl.addEventListener('click', () => {
        Module._zeliard_debug_restore_shield_magic();
        refreshGameControls();
    });
    debugAddItemEl.addEventListener('click', () => {
        const added = Module._zeliard_debug_add_item(
            Number(debugItemSelectEl.value));
        debugAddItemEl.textContent = added ? 'Added' : 'Inventory Full';
        window.setTimeout(() => {
            debugAddItemEl.textContent = 'Add Item';
        }, 1200);
        refreshGameControls();
    });
    flyingToggleEl.addEventListener('click', () => {
        Module._zeliard_debug_set_no_gravity(
            Module._zeliard_debug_no_gravity() ? 0 : 1);
        refreshGameControls();
    });
    debugWarpRoomEl.addEventListener('click', () => {
        const [area, kind] = debugWarpDestinationEl.value.split(':').map(Number);
        Module._zeliard_release_all_keys();
        minimapWarpArmed = false;
        const restarted = Module._zeliard_test_restart_town(area) !== 0;
        const entered = restarted && Module._zeliard_test_enter_room(kind) === 0;
        debugWarpRoomEl.textContent = entered ? 'Warped' : 'Warp Failed';
        window.setTimeout(() => {
            debugWarpRoomEl.textContent = 'Warp to Room';
        }, 1200);
        minimapMap = null;
        minimapMapKey = '';
        refreshGameControls();
        refreshMinimap();
    });
    debugWarpMapEl.addEventListener('click', () => {
        if (Module._zeliard_fight_active() === 0) return;
        minimapWarpArmed = !minimapWarpArmed;
        if (minimapWarpArmed) setMinimapMode('expanded');
        else {
            refreshGameControls();
            refreshMinimap();
        }
    });
    debugToggleEl.addEventListener('click', () => {
        debugToolsEnabled = !debugToolsEnabled;
        localStorage.setItem('zeliard.debugTools', String(debugToolsEnabled));
        refreshGameControls();
        refreshMinimap();
    });
    minimapToggleEl.addEventListener('click', () => setMinimapMode(
        minimapMode === 'off' ? 'compact' :
        minimapMode === 'compact' ? 'expanded' : 'off'));

    const wrapMapCoordinate = (value: number, size: number) =>
        ((value % size) + size) % size;
    const currentMinimapCenter = () => {
        if (!minimapMap || !minimapLastPosition) return null;
        return {
            x: minimapCenter?.x ?? minimapLastPosition.playerX,
            y: minimapCenter?.y ?? minimapLastPosition.playerY,
        };
    };
    const minimapTileAt = (clientX: number, clientY: number) => {
        if (!minimapMap || !minimapLastPosition) return null;
        const rect = minimapCanvasEl.getBoundingClientRect();
        if (!rect.width || !rect.height) return null;
        return cavernMinimapWorldAt(minimapCanvasEl, minimapMap,
            minimapLastPosition, true,
            (clientX - rect.left) * minimapCanvasEl.width / rect.width,
            (clientY - rect.top) * minimapCanvasEl.height / rect.height, {
                centerX: minimapCenter?.x,
                centerY: minimapCenter?.y,
                pins: minimapPins,
            });
    };
    const wrappedTileDistance = (a: number, b: number, size: number) => {
        const distance = Math.abs(a - b);
        return Math.min(distance, size - distance);
    };
    const nearestMinimapPin = (x: number, y: number,
                               maximumDistance: number) => {
        if (!minimapMap) return -1;
        let nearest = -1;
        let nearestDistance = maximumDistance;
        minimapPins.forEach((pin, index) => {
            const dx = wrappedTileDistance(pin.x, x, minimapMap!.width);
            const dy = wrappedTileDistance(pin.y, y, minimapMap!.height);
            const distance = Math.hypot(dx, dy);
            if (distance <= nearestDistance) {
                nearest = index;
                nearestDistance = distance;
            }
        });
        return nearest;
    };
    const removeMinimapPinAt = (clientX: number, clientY: number) => {
        const tile = minimapTileAt(clientX, clientY);
        if (!tile) return false;
        const index = nearestMinimapPin(tile.x, tile.y, 2);
        if (index < 0) return false;
        minimapPins.splice(index, 1);
        saveMinimapPins();
        refreshMinimap();
        return true;
    };
    const toggleMinimapPinAt = (clientX: number, clientY: number) => {
        const tile = minimapTileAt(clientX, clientY);
        if (!tile) return;
        const index = nearestMinimapPin(tile.x, tile.y, 1.5);
        if (index >= 0) {
            minimapPins.splice(index, 1);
        } else if (minimapPins.length < 99) {
            let number = 1;
            while (minimapPins.some(pin => pin.number === number)) number++;
            minimapPins.push({ x: tile.x, y: tile.y, number });
        }
        saveMinimapPins();
        refreshMinimap();
    };
    const warpToMinimapTileAt = (clientX: number, clientY: number) => {
        const tile = minimapTileAt(clientX, clientY);
        if (!tile || !minimapMap || minimapSelector < 0) return;
        const player = Module._zeliard_game_segment();
        const screenX = 14;
        const screenY = Module.HEAPU8[player + 0x84];
        const startPosition = wrapMapCoordinate(
            tile.x - screenX - 4, minimapMap.width);
        const mapScrollRow = wrapMapCoordinate(
            tile.y - screenY - 3, minimapMap.height);
        Module._zeliard_release_all_keys();
        minimapWarpArmed = false;
        const warped = Module._zeliard_test_restart_fight(
            minimapSelector, startPosition, mapScrollRow, screenX) !== 0;
        if (warped) {
            minimapCenter = null;
            minimapMap = null;
            minimapMapKey = '';
        } else {
            debugWarpMapEl.textContent = 'Warp Failed';
            window.setTimeout(() => refreshGameControls(), 1200);
        }
        refreshGameControls();
        refreshMinimap();
    };
    type MinimapDrag = {
        pointerId: number;
        startClientX: number;
        startClientY: number;
        centerX: number;
        centerY: number;
        moved: boolean;
    };
    let minimapDrag: MinimapDrag | null = null;
    minimapCanvasEl.addEventListener('pointerdown', event => {
        if (minimapMode !== 'expanded' || !minimapMap ||
            !minimapLastPosition) return;
        if (event.button === 1) {
            event.preventDefault();
            minimapCenter = null;
            refreshMinimap();
            return;
        }
        if (event.button !== 0) return;
        const center = currentMinimapCenter();
        if (!center) return;
        event.preventDefault();
        minimapDrag = {
            pointerId: event.pointerId,
            startClientX: event.clientX,
            startClientY: event.clientY,
            centerX: center.x,
            centerY: center.y,
            moved: false,
        };
        minimapCanvasEl.setPointerCapture(event.pointerId);
    });
    minimapCanvasEl.addEventListener('pointermove', event => {
        if (!minimapDrag || event.pointerId !== minimapDrag.pointerId ||
            !minimapMap) return;
        const rect = minimapCanvasEl.getBoundingClientRect();
        if (!rect.width || !rect.height) return;
        const dx = event.clientX - minimapDrag.startClientX;
        const dy = event.clientY - minimapDrag.startClientY;
        if (Math.hypot(dx, dy) >= 4) {
            minimapDrag.moved = true;
            minimapCanvasEl.classList.add('dragging');
        }
        if (!minimapDrag.moved) return;
        const viewWidth = Math.min(minimapMap.width, 128);
        const viewHeight = Math.min(minimapMap.height, 56);
        minimapCenter = {
            x: wrapMapCoordinate(minimapDrag.centerX -
                dx / rect.width * viewWidth, minimapMap.width),
            y: wrapMapCoordinate(minimapDrag.centerY -
                dy / rect.height * viewHeight, minimapMap.height),
        };
        refreshMinimap();
    });
    const finishMinimapDrag = (event: PointerEvent) => {
        if (!minimapDrag || event.pointerId !== minimapDrag.pointerId) return;
        const wasMoved = minimapDrag.moved;
        minimapDrag = null;
        minimapCanvasEl.classList.remove('dragging');
        if (minimapCanvasEl.hasPointerCapture(event.pointerId))
            minimapCanvasEl.releasePointerCapture(event.pointerId);
        if (!wasMoved) {
            if (minimapWarpArmed)
                warpToMinimapTileAt(event.clientX, event.clientY);
            else
                toggleMinimapPinAt(event.clientX, event.clientY);
        }
    };
    minimapCanvasEl.addEventListener('pointerup', finishMinimapDrag);
    minimapCanvasEl.addEventListener('pointercancel', event => {
        if (!minimapDrag || event.pointerId !== minimapDrag.pointerId) return;
        minimapDrag = null;
        minimapCanvasEl.classList.remove('dragging');
    });
    minimapCanvasEl.addEventListener('contextmenu', event => {
        if (minimapMode !== 'expanded') return;
        event.preventDefault();
        removeMinimapPinAt(event.clientX, event.clientY);
    });
    minimapCanvasEl.addEventListener('wheel', event => {
        if (minimapMode !== 'expanded' || !minimapMap ||
            !minimapLastPosition) return;
        event.preventDefault();
        const center = currentMinimapCenter();
        const rect = minimapCanvasEl.getBoundingClientRect();
        if (!center || !rect.width || !rect.height) return;
        const unit = event.deltaMode === WheelEvent.DOM_DELTA_LINE ? 16 :
            event.deltaMode === WheelEvent.DOM_DELTA_PAGE ? rect.height : 1;
        const deltaX = (event.deltaX + (event.shiftKey ? event.deltaY : 0)) *
            unit;
        const deltaY = (event.shiftKey ? 0 : event.deltaY) * unit;
        minimapCenter = {
            x: wrapMapCoordinate(center.x + deltaX / rect.width *
                Math.min(minimapMap.width, 128), minimapMap.width),
            y: wrapMapCoordinate(center.y + deltaY / rect.height *
                Math.min(minimapMap.height, 56), minimapMap.height),
        };
        refreshMinimap();
    }, { passive: false });

    checkpointSlotEl.addEventListener('change', () => {
        checkpointStatusEl.value = '';
        checkpointNameEl.value = readCheckpoint()?.name ?? '';
        refreshCheckpointControls();
    });
    checkpointSaveEl.addEventListener('click', () => {
        if (!canSaveCheckpoint()) return;
        Module._zeliard_release_all_keys();
        const pointer = Module._zeliard_game_segment();
        const record = Array.from(Module.HEAPU8.slice(pointer, pointer + 0x100));
        const cavern = Module._zeliard_fight_active() !== 0;
        const name = safeCheckpointName(checkpointNameEl.value ||
            checkpointDescription({
                version: 1, name: '', savedAt: '',
                location: cavern ? 'cavern' : 'town',
                area: cavern ? -1 : Module._zeliard_town_area(),
                selector: cavern ? record[0xC4] : record[0xC8],
                startPosition: record[0x80] | (record[0x81] << 8),
                mapScrollRow: record[0x82], screenPosition: record[0x83],
                playerY: record[0x84], record,
            }));
        const checkpoint: DebugCheckpoint = {
            version: 1,
            name,
            savedAt: new Date().toISOString(),
            location: cavern ? 'cavern' : 'town',
            area: cavern ? -1 : Module._zeliard_town_area(),
            selector: cavern ? record[0xC4] : record[0xC8],
            startPosition: record[0x80] | (record[0x81] << 8),
            mapScrollRow: record[0x82],
            screenPosition: record[0x83],
            playerY: record[0x84],
            record,
        };
        localStorage.setItem(checkpointKey(checkpointSlotEl.value),
            JSON.stringify(checkpoint));
        checkpointNameEl.value = name;
        downloadCheckpoint(checkpoint);
        checkpointStatusEl.value = 'Saved to disk';
        refreshCheckpointControls();
    });
    const restoreCheckpoint = (checkpoint: DebugCheckpoint) => {
        Module._zeliard_release_all_keys();
        const record = checkpoint.record.slice();
        /* A normal USR boot always starts in a town. For a cavern checkpoint,
         * bootstrap through the last valid sage town, then immediately start
         * 200FIGHT with the captured live selector and coordinates. */
        if (checkpoint.location === 'cavern') {
            const returnTown = record[0xC5];
            record[0xC4] = returnTown >= 0x80 && returnTown <= 0x89
                ? returnTown : 0x80;
        }
        const loaded = loadRecord(record);
        const restored = loaded && (checkpoint.location === 'town' ||
            Module._zeliard_test_restart_fight(checkpoint.selector,
                checkpoint.startPosition, checkpoint.mapScrollRow,
                checkpoint.screenPosition) !== 0);
        checkpointStatusEl.value = restored ? 'Restored' : 'Restore failed';
        minimapMap = null;
        minimapMapKey = '';
        refreshGameControls();
        refreshMinimap();
        return restored;
    };
    checkpointLoadEl.addEventListener('click', () => {
        const checkpoint = readCheckpoint();
        if (checkpoint) restoreCheckpoint(checkpoint);
    });
    checkpointOpenEl.addEventListener('change', async () => {
        const file = checkpointOpenEl.files?.[0];
        checkpointOpenEl.value = '';
        if (!file) return;
        try {
            const checkpoint = JSON.parse(await file.text());
            if (!isCheckpoint(checkpoint)) throw new Error('invalid state file');
            if (checkpoint.location === 'cavern' &&
                checkpoint.record[0xC4] < 0x80)
                checkpoint.selector = checkpoint.record[0xC4];
            checkpoint.name = safeCheckpointName(checkpoint.name || file.name);
            localStorage.setItem(checkpointKey(checkpointSlotEl.value),
                JSON.stringify(checkpoint));
            checkpointNameEl.value = checkpoint.name;
            refreshCheckpointControls();
            restoreCheckpoint(checkpoint);
        } catch {
            checkpointStatusEl.value = 'Invalid state file';
        }
    });
    checkpointClearEl.addEventListener('click', () => {
        localStorage.removeItem(checkpointKey(checkpointSlotEl.value));
        checkpointStatusEl.value = 'Cleared';
        refreshCheckpointControls();
    });
    keymapOpenEl.addEventListener('click', () => {
        Module._zeliard_release_all_keys();
        keymapDialogEl.showModal();
    });
    keymapCloseEl.addEventListener('click', () => keymapDialogEl.close());
    keymapDialogEl.addEventListener('click', (e: MouseEvent) => {
        if (e.target === keymapDialogEl)
            keymapDialogEl.close();
    });

    startButton.hidden = false;
    startButton.addEventListener('click', () => void startPlayback());
    refreshGameControls();
    window.addEventListener('keydown', (e: KeyboardEvent) => {
        if (keymapDialogEl.open) {
            if (e.key === 'Escape') {
                e.preventDefault();
                keymapDialogEl.close();
            }
            return;
        }
        if (!e.repeat && debugToolsEnabled &&
            Module._zeliard_fight_active() !== 0 && e.key.toLowerCase() === 'm') {
            e.preventDefault();
            if (e.shiftKey)
                setMinimapMode(minimapMode === 'expanded' ? 'compact' : 'expanded');
            else
                setMinimapMode(minimapMode === 'off' ? 'compact' : 'off');
            return;
        }
        const keycodes: Record<string, number> = {
            Enter: 13,
            Shift: 16,
            Control: 17,
            Alt: 18,
            ' ': 32,
            ArrowLeft: 37,
            ArrowUp: 38,
            ArrowRight: 39,
            ArrowDown: 40,
            Escape: 27,
            F1: 112,
            F2: 113,
            F7: 118,
            F9: 120,
            e: 69,
            E: 69,
            s: 83,
            S: 83,
        };
        const keycode = keycodes[e.key];
        if (keycode === undefined) {
            if (!e.repeat && (e.key === 'Backspace' ||
                /^[a-zA-Z0-9]$/.test(e.key))) {
                e.preventDefault();
                Module._zeliard_text_key(e.key === 'Backspace'
                    ? 8 : e.key.toUpperCase().charCodeAt(0));
                const loadRequestSerial = Module._zeliard_load_request_serial();
                if (loadRequestSerial !== lastLoadRequestSerial) {
                    lastLoadRequestSerial = loadRequestSerial;
                    openSaveEl.click();
                }
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
        if ((keycode === 69 || keycode === 83) &&
            !e.ctrlKey && !e.metaKey && !e.altKey)
            Module._zeliard_text_key(keycode);
        music?.sync(Module._zeliard_music_track(),
            Module._zeliard_music_enabled() !== 0,
            Module._zeliard_paused() !== 0,
            Module._zeliard_music_attenuation());
    });
    window.addEventListener('keyup', (e: KeyboardEvent) => {
        if (keymapDialogEl.open)
            return;
        const keycodes: Record<string, number> = {
            Enter: 13,
            Shift: 16,
            Control: 17,
            Alt: 18,
            ' ': 32,
            ArrowLeft: 37,
            ArrowUp: 38,
            ArrowRight: 39,
            ArrowDown: 40,
            Escape: 27,
            F1: 112,
            F2: 113,
            F7: 118,
            F9: 120,
            e: 69,
            E: 69,
            s: 83,
            S: 83,
        };
        const keycode = keycodes[e.key];
        if (keycode === undefined)
            return;
        e.preventDefault();
        Module._zeliard_key_up(keycode);
    });
    const releaseHeldKeys = () => {
        Module._zeliard_release_all_keys();
        gamepadConnected = false;
        gamepadMask = { directions: 0, buttons: 0 };
    };
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
        pollGamepad();
        Module._zeliard_tick(tickMs);
        const terminated = Module._zeliard_session_terminated() !== 0;
        if (terminated !== lastTerminated) {
            lastTerminated = terminated;
            refreshSessionControls();
        }
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
            refreshSaveControls();
            downloadRecord(name, record);
        }
        const loadRequestSerial = Module._zeliard_load_request_serial();
        if (loadRequestSerial !== lastLoadRequestSerial) {
            lastLoadRequestSerial = loadRequestSerial;
            openSaveEl.click();
        }
        /* Town dialog cues should not sit behind the fight VM's 85 ms
         * underrun cushion. Opening, cavern transitions, and active fights
         * retain it; ordinary town execution uses a ~21 ms target. */
        music?.setLowLatency(Module._zeliard_scene() === 2 &&
            Module._zeliard_fight_active() === 0 &&
            Module._zeliard_cavern_transition_active() === 0);
        music?.sync(Module._zeliard_music_track(),
            Module._zeliard_music_enabled() !== 0,
            Module._zeliard_paused() !== 0,
            Module._zeliard_music_attenuation());
        music?.pump();
        refreshGameControls();
        paintFrame();
        requestAnimationFrame(frame);
    }
}

boot().catch((err) => {
    console.error(err);
    setStatus(`boot failed: ${err?.message ?? err}`);
});
