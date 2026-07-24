import { chromium } from 'playwright';
import { createHash } from 'node:crypto';
import fs from 'node:fs/promises';
import path from 'node:path';

function argValue(name, fallback = null) {
  const index = process.argv.indexOf(name);
  if (index < 0) return fallback;
  if (index + 1 >= process.argv.length) throw new Error(`missing value for ${name}`);
  return process.argv[index + 1];
}

const schedulePath = argValue('--schedule', 'hybrid_reference_schedule.json');
const outDir = argValue('--out-dir', '../tests/artifacts/hybrid_masm_reference');
const url = argValue('--url', 'http://127.0.0.1:5173/hybrid.html');
const quiet = process.argv.includes('--quiet');
const schedule = JSON.parse(await fs.readFile(schedulePath, 'utf8'));

if (!Array.isArray(schedule.samples) || schedule.samples.length === 0) {
  throw new Error('schedule must contain at least one sample');
}

let previousMs = -1;
for (const sample of schedule.samples) {
  if (!Number.isInteger(sample.after_mcga_ms) || sample.after_mcga_ms < previousMs) {
    throw new Error(`after_mcga_ms must be a monotonic non-negative integer (${sample.id})`);
  }
  previousMs = sample.after_mcga_ms;
}

await fs.mkdir(outDir, { recursive: true });
const browser = await chromium.launch({
  headless: true,
  args: ['--disable-background-timer-throttling', '--disable-renderer-backgrounding'],
});
const page = await browser.newPage({ viewport: { width: 1280, height: 820 }, deviceScaleFactor: 1 });

if (!quiet) {
  page.on('console', message => console.log(`[hybrid:${message.type()}] ${message.text()}`));
  page.on('pageerror', error => console.log(`[hybrid:error] ${error.stack || error.message}`));
}

try {
  const requestUrl = `${url}${url.includes('?') ? '&' : '?'}capture=${Date.now()}`;
  await page.goto(requestUrl, { waitUntil: 'domcontentloaded', timeout: 60000 });
  await page.waitForFunction(() => window.__zeliardMasmCapture?.mcga_started_at_ms !== null, null, {
    timeout: 60000,
  });

  const startedAt = await page.evaluate(() => window.__zeliardMasmCapture.mcga_started_at_ms);
  const capturedFrames = await page.evaluate(async ({ startedAt, samples }) => {
    const frames = [];
    for (const sample of samples) {
      let canvas;
      let context;
      let pixels;
      if (sample.expected_rgba_sha256) {
        const deadline = performance.now() + (sample.state_timeout_ms || 120000);
        for (;;) {
          canvas = document.querySelector('#screen-container canvas');
          if (!canvas || canvas.width !== 320 || canvas.height !== 200) {
            throw new Error('v86 screen canvas is not in MCGA 320x200 mode');
          }
          context = canvas.getContext('2d', { willReadFrequently: true });
          if (!context) throw new Error('v86 screen has no 2D context');
          pixels = context.getImageData(0, 0, canvas.width, canvas.height).data;
          const digest = new Uint8Array(
            await crypto.subtle.digest('SHA-256', pixels));
          const hash = Array.from(digest, byte =>
            byte.toString(16).padStart(2, '0')).join('');
          if (hash === sample.expected_rgba_sha256)
            break;
          if (performance.now() >= deadline) {
            throw new Error(
              `timed out waiting for MASM framebuffer state ${sample.id} ` +
              `(${sample.expected_rgba_sha256})`);
          }
          /* Canvas hashing is deliberately sampled rather than run every RAF:
           * hashing continuously steals enough host time to change v86's
           * throughput through CPU-bound REP/VGA loops. */
          await new Promise(resolve => setTimeout(resolve, 20));
        }
      } else {
        const targetAt = startedAt + sample.after_mcga_ms;
        const waitMs = targetAt - performance.now();
        if (waitMs > 0)
          await new Promise(resolve => setTimeout(resolve, waitMs));
        canvas = document.querySelector('#screen-container canvas');
        if (!canvas || canvas.width !== 320 || canvas.height !== 200) {
          throw new Error('v86 screen canvas is not in MCGA 320x200 mode');
        }
        context = canvas.getContext('2d', { willReadFrequently: true });
        if (!context) throw new Error('v86 screen has no 2D context');
        pixels = context.getImageData(0, 0, canvas.width, canvas.height).data;
      }
      frames.push({
        png: canvas.toDataURL('image/png').split(',', 2)[1],
        rgba: Array.from(pixels),
        captured_at_ms: performance.now(),
      });
    }
    return {
      frames,
      modes: window.__zeliardMasmCapture.modes,
    };
  }, { startedAt, samples: schedule.samples });

  const log = [];
  for (let index = 0; index < schedule.samples.length; index++) {
    const sample = schedule.samples[index];
    const frame = capturedFrames.frames[index];
    const png = Buffer.from(frame.png, 'base64');
    const rgba = Buffer.from(frame.rgba);
    const rgb = Buffer.alloc(320 * 200 * 3);
    for (let src = 0, dst = 0; src < rgba.length; src += 4, dst += 3) {
      rgb[dst] = rgba[src];
      rgb[dst + 1] = rgba[src + 1];
      rgb[dst + 2] = rgba[src + 2];
    }
    const file = `${String(sample.after_mcga_ms).padStart(6, '0')}_${sample.id}.png`;
    const ppmFile = `${String(sample.after_mcga_ms).padStart(6, '0')}_${sample.id}.ppm`;
    await fs.writeFile(path.join(outDir, file), png);
    await fs.writeFile(
      path.join(outDir, ppmFile),
      Buffer.concat([Buffer.from('P6\n320 200\n255\n', 'ascii'), rgb]),
    );
    log.push({
      ...sample,
      file,
      ppm_file: ppmFile,
      actual_after_mcga_ms: Math.round(frame.captured_at_ms - startedAt),
      alignment: sample.expected_rgba_sha256 ? 'frame_state' : 'wall_clock',
      png_sha256: createHash('sha256').update(png).digest('hex'),
      rgba_sha256: createHash('sha256').update(rgba).digest('hex'),
      rgb_sha256: createHash('sha256').update(rgb).digest('hex'),
      modes: capturedFrames.modes,
    });
  }
  await fs.writeFile(path.join(outDir, 'manifest.json'), JSON.stringify({
    source: 'v86 executing 3_Assembly/masm/bin release files',
    schedule: path.basename(schedulePath),
    samples: log,
  }, null, 2));
  console.log(`VERDICT: PASS (${log.length} MASM reference frames -> ${outDir})`);
} finally {
  await browser.close();
}
