import { spawn } from 'node:child_process';
import { once } from 'node:events';
import fs from 'node:fs/promises';
import path from 'node:path';
import { chromium } from 'playwright';

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
const batchSize = Number(argValue('--batch-size', '30'));

if (!output || !Number.isInteger(frameCount) || frameCount <= 0)
  throw new Error('usage: --output FILE --frames N [--url URL]');
if (![fpsNum, fpsDen, tickStepMs, batchSize].every(value => Number.isFinite(value) && value > 0))
  throw new Error('fps, tick step, and batch size must be positive');

const outputPath = path.resolve(output);
await fs.mkdir(path.dirname(outputPath), { recursive: true });
const ffmpeg = spawn('ffmpeg', [
  '-hide_banner', '-loglevel', 'warning', '-y',
  '-f', 'rawvideo', '-pixel_format', 'rgb24',
  '-video_size', '320x200', '-framerate', `${fpsNum}/${fpsDen}`,
  '-i', 'pipe:0', '-an', '-c:v', 'libx264', '-preset', 'veryfast',
  '-crf', '17', '-pix_fmt', 'yuv420p', '-movflags', '+faststart',
  outputPath,
], { stdio: ['pipe', 'inherit', 'inherit'] });

const browser = await chromium.launch({
  headless: true,
  args: ['--disable-background-timer-throttling', '--disable-renderer-backgrounding'],
});

try {
  const page = await browser.newPage({ viewport: { width: 640, height: 400 } });
  page.on('pageerror', error => console.error(`[browser] ${error.stack || error.message}`));
  await page.goto(`${url}${url.includes('?') ? '&' : '?'}video=${Date.now()}&codex_capture=1`, {
    waitUntil: 'networkidle',
    timeout: 60000,
  });
  await page.waitForFunction(() => !!window.__zeliard, null, { timeout: 60000 });
  await page.evaluate(() => {
    window.__zeliard._zeliard_init();
    window.__zeliardVideoMs = 0;
  });

  for (let start = 0; start < frameCount; start += batchSize) {
    const count = Math.min(batchSize, frameCount - start);
    const encodedFrames = await page.evaluate(params => {
      const Module = window.__zeliard;
      const width = Module._zeliard_width();
      const height = Module._zeliard_height();

      function base64(bytes) {
        let binary = '';
        const stride = 0x8000;
        for (let offset = 0; offset < bytes.length; offset += stride) {
          binary += String.fromCharCode(...bytes.subarray(offset, offset + stride));
        }
        return btoa(binary);
      }

      const frames = [];
      for (let local = 0; local < params.count; local++) {
        const index = params.start + local;
        const targetMs = Math.round(
          params.originMs + index * 1000 * params.fpsDen / params.fpsNum);
        let remaining = targetMs - window.__zeliardVideoMs;
        while (remaining > 0) {
          const step = Math.min(remaining, params.tickStepMs);
          Module._zeliard_tick(step);
          remaining -= step;
        }
        window.__zeliardVideoMs = targetMs;

        const framebuffer = Module.HEAPU8.subarray(
          Module._zeliard_framebuf(), Module._zeliard_framebuf() + width * height);
        const palette = Module.HEAPU8.subarray(
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
        frames.push(base64(rgb));
      }
      return frames;
    }, {
      start,
      count,
      fpsNum,
      fpsDen,
      originMs: wasmOriginMs,
      tickStepMs,
    });

    for (const encoded of encodedFrames) {
      const frame = Buffer.from(encoded, 'base64');
      if (!ffmpeg.stdin.write(frame)) await once(ffmpeg.stdin, 'drain');
    }
    if ((start + count) % 300 === 0 || start + count === frameCount)
      console.log(`WASM video ${start + count}/${frameCount}`);
  }
} catch (error) {
  ffmpeg.stdin.destroy(error);
  throw error;
} finally {
  await browser.close();
}

ffmpeg.stdin.end();
const [exitCode] = await once(ffmpeg, 'close');
if (exitCode !== 0) throw new Error(`ffmpeg exited with code ${exitCode}`);
