import { chromium } from 'playwright';
import fs from 'node:fs/promises';
import path from 'node:path';

function argValue(name, fallback = null) {
  const idx = process.argv.indexOf(name);
  if (idx < 0)
    return fallback;
  if (idx + 1 >= process.argv.length)
    throw new Error(`missing value for ${name}`);
  return process.argv[idx + 1];
}

const schedulePath = argValue('--schedule');
const url = argValue('--url', 'http://127.0.0.1:5173/');
const outDir = argValue('--out-dir');
const tickStepMs = Number(argValue('--tick-step-ms', '10'));
const quiet = process.argv.includes('--quiet');
const rawPpm = process.argv.includes('--raw-ppm');

if (!schedulePath || !outDir) {
  console.error('usage: node capture_opening_wasm_frames.mjs --schedule schedule.json --out-dir dir [--url http://127.0.0.1:5173/] [--tick-step-ms 10] [--quiet] [--raw-ppm]');
  process.exit(2);
}

if (!Number.isFinite(tickStepMs) || tickStepMs <= 0) {
  throw new Error(`invalid --tick-step-ms ${tickStepMs}`);
}

const schedule = JSON.parse(await fs.readFile(schedulePath, 'utf8'));
await fs.mkdir(outDir, { recursive: true });

const browser = await chromium.launch({ headless: true });
const page = await browser.newPage({
  viewport: { width: 640, height: 400 },
  deviceScaleFactor: 1,
});

if (!quiet) {
  page.on('console', msg => console.log(`[browser:${msg.type()}] ${msg.text()}`));
  page.on('pageerror', err => console.log(`[browser:error] ${err.stack || err.message}`));
}

await page.goto(`${url}${url.includes('?') ? '&' : '?'}codex=${Date.now()}&codex_capture=1`, {
  waitUntil: 'networkidle',
  timeout: 30000,
});
await page.waitForFunction(() => !!window.__zeliard, null, { timeout: 30000 });

async function paintCanvas() {
  return await page.evaluate(() => {
    const Module = window.__zeliard;
    const canvas = document.getElementById('screen');
    const ctx = canvas.getContext('2d', { alpha: false });
    const w = Module._zeliard_width();
    const h = Module._zeliard_height();
    const fbPtr = Module._zeliard_framebuf();
    const rgbPtr = Module._zeliard_rgb_framebuf ? Module._zeliard_rgb_framebuf() : 0;
    const palPtr = Module._zeliard_palette();
    const imageData = ctx.createImageData(w, h);
    const fb = Module.HEAPU8.subarray(fbPtr, fbPtr + w * h);
    const pal = Module.HEAPU8.subarray(palPtr, palPtr + 256 * 3);
    const rgbActive = Module._zeliard_rgb_framebuf_active &&
      Module._zeliard_rgb_framebuf_active() !== 0;
    const out = imageData.data;
    if (rgbActive) {
      const rgb = Module.HEAPU8.subarray(rgbPtr, rgbPtr + w * h * 3);
      for (let i = 0; i < fb.length; i++) {
        const rgbIdx = i * 3;
        const outIdx = i * 4;
        out[outIdx] = rgb[rgbIdx];
        out[outIdx + 1] = rgb[rgbIdx + 1];
        out[outIdx + 2] = rgb[rgbIdx + 2];
        out[outIdx + 3] = 255;
      }
    } else {
      for (let i = 0; i < fb.length; i++) {
        const palIdx = fb[i] * 3;
        const outIdx = i * 4;
        out[outIdx] = pal[palIdx];
        out[outIdx + 1] = pal[palIdx + 1];
        out[outIdx + 2] = pal[palIdx + 2];
        out[outIdx + 3] = 255;
      }
    }
    ctx.putImageData(imageData, 0, 0);
    return {
      scene: Module._zeliard_scene(),
      phase: Module._zeliard_phase(),
      phase_elapsed_ms: Module._zeliard_phase_elapsed(),
      nec_hou_sprite_debug_word: Module._zeliard_opening_nec_hou_sprite_debug_word
        ? Module._zeliard_opening_nec_hou_sprite_debug_word() >>> 0
        : null,
      nec_hou_sprite_debug_slots: Module._zeliard_opening_nec_hou_sprite_debug_slots
        ? Module._zeliard_opening_nec_hou_sprite_debug_slots() >>> 0
        : null,
    };
  });
}

async function readFramebufferPpm() {
  return await page.evaluate(() => {
    const Module = window.__zeliard;
    const w = Module._zeliard_width();
    const h = Module._zeliard_height();
    const fbPtr = Module._zeliard_framebuf();
    const rgbPtr = Module._zeliard_rgb_framebuf ? Module._zeliard_rgb_framebuf() : 0;
    const palPtr = Module._zeliard_palette();
    const fb = Module.HEAPU8.subarray(fbPtr, fbPtr + w * h);
    const pal = Module.HEAPU8.subarray(palPtr, palPtr + 256 * 3);
    const rgbActive = Module._zeliard_rgb_framebuf_active &&
      Module._zeliard_rgb_framebuf_active() !== 0;
    const rgb = new Uint8Array(w * h * 3);
    if (rgbActive) {
      rgb.set(Module.HEAPU8.subarray(rgbPtr, rgbPtr + w * h * 3));
    } else {
      for (let i = 0; i < fb.length; i++) {
        const palIdx = fb[i] * 3;
        const outIdx = i * 3;
        rgb[outIdx] = pal[palIdx];
        rgb[outIdx + 1] = pal[palIdx + 1];
        rgb[outIdx + 2] = pal[palIdx + 2];
      }
    }
    return {
      scene: Module._zeliard_scene(),
      phase: Module._zeliard_phase(),
      phase_elapsed_ms: Module._zeliard_phase_elapsed(),
      nec_hou_sprite_debug_word: Module._zeliard_opening_nec_hou_sprite_debug_word
        ? Module._zeliard_opening_nec_hou_sprite_debug_word() >>> 0
        : null,
      nec_hou_sprite_debug_slots: Module._zeliard_opening_nec_hou_sprite_debug_slots
        ? Module._zeliard_opening_nec_hou_sprite_debug_slots() >>> 0
        : null,
      w,
      h,
      rgb: Array.from(rgb),
    };
  });
}

await page.evaluate(() => window.__zeliard._zeliard_init());
let currentMs = 0;
const log = [];

async function advanceRuntime(remainingMs) {
  if (remainingMs <= 0)
    return;

  /* Keep the exact fixed tick quantum, but run it in one page evaluation.
   * A 15-minute capture otherwise performs ~90,000 Playwright round trips;
   * that made the comparison process look hung after the WASM frame was
   * already correct. */
  await page.evaluate(({ remaining, quantum }) => {
    const tick = window.__zeliard._zeliard_tick;
    while (remaining > 0) {
      const step = Math.min(remaining, quantum);
      tick(step);
      remaining -= step;
    }
  }, { remaining: remainingMs, quantum: tickStepMs });
}

for (const sample of schedule.samples) {
  const targetMs = Number(sample.wasm_ms ?? sample.after_mcga_ms);
  if (!Number.isFinite(targetMs) || targetMs < currentMs)
    throw new Error(`schedule must be monotonic; got ${sample.wasm_ms ?? sample.after_mcga_ms}`);

  const remaining = Math.round(targetMs - currentMs);
  await advanceRuntime(remaining);
  currentMs += remaining;

  const state = rawPpm ? await readFramebufferPpm() : await paintCanvas();
  const file = sample.file ||
    `wasm_${String(Math.round(targetMs)).padStart(8, '0')}.${rawPpm ? 'ppm' : 'png'}`;
  const outPath = path.join(outDir, file);
  if (rawPpm) {
    const header = Buffer.from(`P6\n${state.w} ${state.h}\n255\n`, 'ascii');
    await fs.writeFile(outPath, Buffer.concat([header, Buffer.from(state.rgb)]));
  } else {
    await page.locator('#screen').screenshot({ path: outPath });
  }
  const { w, h, rgb, ...logState } = state;
  log.push({ ...sample, ...logState, path: outPath });
}

await fs.writeFile(path.join(outDir, 'wasm_capture_log.json'),
                   JSON.stringify(log, null, 2));
await browser.close();
