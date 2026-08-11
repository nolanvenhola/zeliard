import { chromium } from 'playwright';
import { mkdir, writeFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { createHash } from 'node:crypto';

const url = process.argv[2] ?? 'http://127.0.0.1:5179/';
const output = resolve('../..', 'artifacts/visual-checkpoints/wasm/opening-title');
const browser = await chromium.launch({ headless: true });
const page = await browser.newPage();
page.on('console', message => console.log(`[browser:${message.type()}] ${message.text()}`));
page.on('pageerror', error => console.error(`[browser:error] ${error.message}`));
try {
  await page.goto(`${url}${url.includes('?') ? '&' : '?'}codex_capture=1`, { waitUntil: 'domcontentloaded' });
  await page.waitForFunction(() => window.__zeliardVisualCapture !== undefined,
    null, { timeout: 120000 });
  const capture = await page.evaluate(() => window.__zeliardVisualCapture('opening-title'));
  if (capture.width !== 320 || capture.height !== 200 || capture.indices.length !== 64000)
    throw new Error('WASM capture did not expose the canonical 320x200 indexed framebuffer');
  if (capture.palette.length !== 768)
    throw new Error('WASM capture did not expose the complete 256-entry palette');
  if (!capture.dirtyRect || !capture.renderTrace.length)
    throw new Error('WASM capture did not expose dirty-rectangle/present metadata');

  const indices = Uint8Array.from(capture.indices);
  const palette = Uint8Array.from(capture.palette);
  const sha256 = bytes => createHash('sha256').update(bytes).digest('hex');
  const trace = capture.renderTrace.map(event => JSON.stringify(event)).join('\n') + '\n';
  const manifest = {
    schemaVersion: capture.schemaVersion,
    checkpoint: capture.checkpoint,
    runtime: capture.runtime,
    videoMode: capture.videoMode,
    width: capture.width,
    height: capture.height,
    indexSha256: sha256(indices),
    paletteSha256: sha256(palette),
    rgbActive: capture.rgbActive,
    dirtyRect: capture.dirtyRect,
    files: { indices: 'framebuffer.bin', palette: 'palette.rgb', trace: 'render-trace.jsonl' },
  };
  await mkdir(output, { recursive: true });
  await Promise.all([
    writeFile(resolve(output, 'framebuffer.bin'), indices),
    writeFile(resolve(output, 'palette.rgb'), palette),
    writeFile(resolve(output, 'render-trace.jsonl'), trace),
    writeFile(resolve(output, 'manifest.json'), JSON.stringify(manifest, null, 2) + '\n'),
  ]);
  console.log(`visual capture PASS: ${manifest.indexSha256} / ${manifest.paletteSha256}`);
} finally {
  await browser.close();
}
