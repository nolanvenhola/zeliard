import { chromium } from 'playwright';
import fs from 'node:fs/promises';

function argValue(name, fallback = null) {
  const index = process.argv.indexOf(name);
  if (index < 0) return fallback;
  if (index + 1 >= process.argv.length) throw new Error(`missing value for ${name}`);
  return process.argv[index + 1];
}

const url = argValue('--url', 'http://127.0.0.1:5173/');
const output = argValue('--output');
const frameCount = Number(argValue('--frames'));
const fpsNum = Number(argValue('--fps-num', '30'));
const fpsDen = Number(argValue('--fps-den', '1'));
const wasmOriginMs = Number(argValue('--wasm-origin-ms', '1360'));
const tickStepMs = Number(argValue('--tick-step-ms', '10'));
const chunkSize = Number(argValue('--chunk-size', '240'));

if (!output || !Number.isInteger(frameCount) || frameCount <= 0)
  throw new Error('usage: --output FILE --frames N [--url URL]');
if (![fpsNum, fpsDen, tickStepMs, chunkSize].every(value => Number.isFinite(value) && value > 0))
  throw new Error('fps, tick step, and chunk size must be positive');

const browser = await chromium.launch({
  headless: true,
  args: ['--disable-background-timer-throttling', '--disable-renderer-backgrounding'],
});
const page = await browser.newPage({ viewport: { width: 640, height: 400 } });
page.on('pageerror', error => console.error(`[browser] ${error.stack || error.message}`));

try {
  await page.goto(`${url}${url.includes('?') ? '&' : '?'}full_hash=${Date.now()}&codex_capture=1`, {
    waitUntil: 'networkidle',
    timeout: 60000,
  });
  await page.waitForFunction(() => !!window.__zeliard, null, { timeout: 60000 });
  await page.evaluate(() => {
    window.__zeliard._zeliard_init();
    window.__zeliardFullHashMs = 0;
  });

  await fs.writeFile(output, JSON.stringify({
    type: 'metadata',
    source: 'browser WASM deterministic timeline',
    frame_count: frameCount,
    fps_num: fpsNum,
    fps_den: fpsDen,
    wasm_origin_ms: wasmOriginMs,
    tick_step_ms: tickStepMs,
    coarse_size: [20, 10],
  }) + '\n');

  for (let start = 0; start < frameCount; start += chunkSize) {
    const count = Math.min(chunkSize, frameCount - start);
    const rows = await page.evaluate(async params => {
      const Module = window.__zeliard;
      const width = Module._zeliard_width();
      const height = Module._zeliard_height();

      function hex(bytes) {
        return Array.from(bytes, byte => byte.toString(16).padStart(2, '0')).join('');
      }

      async function sha256(bytes) {
        return hex(new Uint8Array(await crypto.subtle.digest('SHA-256', bytes)));
      }

      function coarseRgb(rgb) {
        const cw = 20;
        const ch = 10;
        const out = new Uint8Array(cw * ch * 3);
        for (let cy = 0; cy < ch; cy++) {
          const y0 = Math.floor(cy * height / ch);
          const y1 = Math.floor((cy + 1) * height / ch);
          for (let cx = 0; cx < cw; cx++) {
            const x0 = Math.floor(cx * width / cw);
            const x1 = Math.floor((cx + 1) * width / cw);
            let r = 0;
            let g = 0;
            let b = 0;
            let pixels = 0;
            for (let y = y0; y < y1; y++) {
              for (let x = x0; x < x1; x++) {
                const offset = (y * width + x) * 3;
                r += rgb[offset];
                g += rgb[offset + 1];
                b += rgb[offset + 2];
                pixels++;
              }
            }
            const dst = (cy * cw + cx) * 3;
            out[dst] = Math.round(r / pixels);
            out[dst + 1] = Math.round(g / pixels);
            out[dst + 2] = Math.round(b / pixels);
          }
        }
        let binary = '';
        for (const value of out) binary += String.fromCharCode(value);
        return btoa(binary);
      }

      function differenceHash(rgb) {
        let value = 0n;
        let bit = 0n;
        for (let y = 0; y < 8; y++) {
          const sy = Math.floor((y + 0.5) * height / 8);
          let previous = 0;
          for (let x = 0; x < 9; x++) {
            const sx = Math.floor((x + 0.5) * width / 9);
            const offset = (sy * width + sx) * 3;
            const gray = rgb[offset] * 299 + rgb[offset + 1] * 587 + rgb[offset + 2] * 114;
            if (x > 0) {
              if (previous > gray) value |= 1n << bit;
              bit++;
            }
            previous = gray;
          }
        }
        return value.toString(16).padStart(16, '0');
      }

      const results = [];
      for (let local = 0; local < params.count; local++) {
        const index = params.start + local;
        const targetMs = Math.round(
          params.originMs + index * 1000 * params.fpsDen / params.fpsNum);
        let remaining = targetMs - window.__zeliardFullHashMs;
        while (remaining > 0) {
          const step = Math.min(remaining, params.tickStepMs);
          Module._zeliard_tick(step);
          remaining -= step;
        }
        window.__zeliardFullHashMs = targetMs;

        const framebuffer = Module.HEAPU8.slice(
          Module._zeliard_framebuf(), Module._zeliard_framebuf() + width * height);
        const palette = Module.HEAPU8.slice(
          Module._zeliard_palette(), Module._zeliard_palette() + 256 * 3);
        const rgb = new Uint8Array(width * height * 3);
        const rgbActive = Module._zeliard_rgb_framebuf_active &&
          Module._zeliard_rgb_framebuf_active() !== 0;
        if (rgbActive) {
          rgb.set(Module.HEAPU8.subarray(
            Module._zeliard_rgb_framebuf(),
            Module._zeliard_rgb_framebuf() + width * height * 3));
        } else {
          for (let pixel = 0; pixel < framebuffer.length; pixel++) {
            const src = framebuffer[pixel] * 3;
            const dst = pixel * 3;
            rgb[dst] = palette[src];
            rgb[dst + 1] = palette[src + 1];
            rgb[dst + 2] = palette[src + 2];
          }
        }
        results.push({
          type: 'frame',
          index,
          wasm_ms: targetMs,
          scene: Module._zeliard_scene(),
          phase: Module._zeliard_phase(),
          phase_elapsed_ms: Module._zeliard_phase_elapsed(),
          nec_hou_sprite_debug_word:
            Module._zeliard_opening_nec_hou_sprite_debug_word?.() ?? 0xffffffff,
          nec_hou_sprite_debug_slots:
            Module._zeliard_opening_nec_hou_sprite_debug_slots?.() ?? 0xffffffff,
          framebuffer_sha256: await sha256(framebuffer),
          palette_sha256: await sha256(palette),
          rgb_sha256: await sha256(rgb),
          dhash: differenceHash(rgb),
          coarse_rgb_base64: coarseRgb(rgb),
        });
      }
      return results;
    }, {
      start,
      count,
      fpsNum,
      fpsDen,
      originMs: wasmOriginMs,
      tickStepMs,
    });
    await fs.appendFile(output, rows.map(row => JSON.stringify(row)).join('\n') + '\n');
    console.log(`WASM hashes ${Math.min(start + count, frameCount)}/${frameCount}`);
  }
} finally {
  await browser.close();
}
