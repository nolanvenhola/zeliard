"use strict";
/*
 * Zeliard web shell — boots the Emscripten engine, copies the 320x200
 * paletted framebuffer into a Canvas2D ImageData each frame, and drives
 * the engine tick at ~60Hz (the engine itself maintains its own 18.2Hz
 * game-tick internally; the host just calls _zeliard_tick() per requestAnimationFrame).
 */
const statusEl = document.getElementById('status');
const canvas = document.getElementById('screen');
const ctx = canvas.getContext('2d', { alpha: false });
function setStatus(msg) {
    statusEl.textContent = msg;
    console.log('[zeliard]', msg);
}
async function loadEngineModule(cacheBust) {
    /* The engine .js / .wasm / .data triple lives under /engine/ in the
     * shell's public dir (mirrored there by `make wasm`).  Importing via
     * an absolute URL prevents Vite from bundling the JS and lets the
     * Emscripten runtime resolve .wasm + .data with relative URLs. */
    const url = `${window.location.origin}/engine/zeliard.js?v=${cacheBust}`;
    const mod = await import(/* @vite-ignore */ url);
    return mod.default;
}
async function boot() {
    const params = new URLSearchParams(window.location.search);
    const deterministicCapture = params.has('codex_capture');
    const engineCacheBust = Date.now().toString(36);
    setStatus('loading engine module…');
    const factory = await loadEngineModule(engineCacheBust);
    setStatus('instantiating WASM…');
    const Module = await factory({
        print: (s) => console.log('[wasm]', s),
        printErr: (s) => console.error('[wasm]', s),
        locateFile: (path) => `/engine/${path}?v=${engineCacheBust}`,
    });
    setStatus('initialising engine…');
    Module._zeliard_init();
    window.__zeliard = Module;
    const w = Module._zeliard_width();
    const h = Module._zeliard_height();
    const fbPtr = Module._zeliard_framebuf();
    const rgbPtr = Module._zeliard_rgb_framebuf();
    const palPtr = Module._zeliard_palette();
    setStatus(`engine running — ${w}×${h}, framebuf @ ${fbPtr}, palette @ ${palPtr}`);
    /* Forward ENTER/SPACE to the engine so it can apply OPDMO phase-specific advance rules. */
    window.addEventListener('keydown', (e) => {
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
    let lastPresentedIndices = null;
    let lastPresentedPalette = null;
    let visualPresentSequence = 0;
    const visualPresentTrace = [];
    function hashBytes(bytes) {
        let hash = 0x811c9dc5;
        for (const byte of bytes) {
            hash ^= byte;
            hash = Math.imul(hash, 0x01000193) >>> 0;
        }
        return hash.toString(16).padStart(8, '0');
    }
    function recordPresent(indices, palette) {
        let minX = w, minY = h, maxX = -1, maxY = -1, changed = 0;
        if (lastPresentedIndices) {
            for (let i = 0; i < indices.length; i++) {
                if (indices[i] === lastPresentedIndices[i]) continue;
                const x = i % w;
                const y = (i / w) | 0;
                minX = Math.min(minX, x); minY = Math.min(minY, y);
                maxX = Math.max(maxX, x); maxY = Math.max(maxY, y);
                changed++;
            }
        } else {
            minX = 0; minY = 0; maxX = w - 1; maxY = h - 1; changed = indices.length;
        }
        visualPresentTrace.push({
            sequence: visualPresentSequence++,
            op: 'present',
            x: changed ? minX : 0,
            y: changed ? minY : 0,
            width: changed ? maxX - minX + 1 : 0,
            height: changed ? maxY - minY + 1 : 0,
            changedPixels: changed,
            hash: hashBytes(indices),
            paletteHash: hashBytes(palette),
            paletteChanged: !lastPresentedPalette ||
                hashBytes(palette) !== hashBytes(lastPresentedPalette),
            scene: Module._zeliard_scene(),
            phase: Module._zeliard_phase(),
        });
        if (visualPresentTrace.length > 256) visualPresentTrace.shift();
        lastPresentedIndices = Uint8Array.from(indices);
        lastPresentedPalette = Uint8Array.from(palette);
    }
    /* Raw capture API used by the parity harness. Copies detach the artifact
     * from mutable WASM memory and retain palette indices independently from
     * the DAC, unlike a canvas or host-window screenshot. */
    window.__zeliardVisualCapture = (checkpoint) => ({
        schemaVersion: 1,
        checkpoint,
        runtime: 'wasm',
        videoMode: 'mcga-320x200x8',
        width: w,
        height: h,
        indices: Array.from(Module.HEAPU8.slice(fbPtr, fbPtr + w * h)),
        palette: Array.from(Module.HEAPU8.slice(palPtr, palPtr + 256 * 3)),
        rgbActive: Module._zeliard_rgb_framebuf_active() !== 0,
        dirtyRect: visualPresentTrace.length ? visualPresentTrace.at(-1) : null,
        renderTrace: visualPresentTrace.map(event => ({ ...event })),
    });
    function sceneName(scene) {
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
                out[o] = rgb[idx];
                out[o + 1] = rgb[idx + 1];
                out[o + 2] = rgb[idx + 2];
                out[o + 3] = 255;
            }
        }
        else {
            for (let i = 0; i < fb.length; i++) {
                const idx = fb[i] * 3;
                const o = i * 4;
                out[o] = pal[idx];
                out[o + 1] = pal[idx + 1];
                out[o + 2] = pal[idx + 2];
                out[o + 3] = 255;
            }
        }
        ctx.putImageData(imageData, 0, 0);
        if (deterministicCapture) recordPresent(fb, pal);
        if (++frameCount === 1) {
            // First-frame diagnostics: count distinct paletted indices to
            // confirm the engine actually wrote something interesting.
            const seen = new Set();
            let nonzero = 0;
            for (let i = 0; i < fb.length; i++) {
                if (fb[i] !== 0)
                    nonzero++;
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
    function frame(now) {
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
