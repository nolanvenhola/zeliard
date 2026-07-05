import { chromium } from 'playwright';
import fs from 'node:fs/promises';

const outDir = 'C:/Projects/Zeliard/6_WebPort/tests/artifacts/browser_rain_hime_transition';
await fs.mkdir(outDir, { recursive: true });

const browser = await chromium.launch({ headless: true });
const page = await browser.newPage({ viewport: { width: 1000, height: 680 }, deviceScaleFactor: 1 });
await page.addInitScript(() => {
  window.requestAnimationFrame = () => 0;
});
page.on('console', msg => console.log(`[browser:${msg.type()}] ${msg.text()}`));
page.on('pageerror', err => console.log(`[browser:error] ${err.stack || err.message}`));
await page.goto('http://127.0.0.1:5173/?codex=' + Date.now(), { waitUntil: 'networkidle' });
await page.waitForFunction(() => !!window.__zeliard, null, { timeout: 30000 });

async function paint() {
  return await page.evaluate(() => {
    const Module = window.__zeliard;
    const canvas = document.getElementById('screen');
    const ctx = canvas.getContext('2d', { alpha: false });
    const w = Module._zeliard_width();
    const h = Module._zeliard_height();
    const fbPtr = Module._zeliard_framebuf();
    const palPtr = Module._zeliard_palette();
    const imageData = ctx.createImageData(w, h);
    const fb = Module.HEAPU8.subarray(fbPtr, fbPtr + w * h);
    const pal = Module.HEAPU8.subarray(palPtr, palPtr + 256 * 3);
    const out = imageData.data;
    let redish = 0;
    let whiteish = 0;
    let nonzero = 0;
    for (let i = 0; i < fb.length; i++) {
      const idx = fb[i] * 3;
      const r = pal[idx], g = pal[idx + 1], b = pal[idx + 2];
      const o = i * 4;
      out[o] = r; out[o + 1] = g; out[o + 2] = b; out[o + 3] = 255;
      if (fb[i] !== 0) nonzero++;
      if (r > 160 && g < 80 && b < 80) redish++;
      if (r > 200 && g > 200 && b > 200) whiteish++;
    }
    ctx.putImageData(imageData, 0, 0);
    return {
      scene: Module._zeliard_scene(),
      phase: Module._zeliard_phase(),
      elapsed: Module._zeliard_phase_elapsed(),
      nonzero, redish, whiteish,
      status: document.getElementById('status')?.textContent || ''
    };
  });
}

async function tickToPhase(targetPhase) {
  for (let i = 0; i < 5000; i++) {
    const state = await page.evaluate(() => ({
      phase: window.__zeliard._zeliard_phase(),
      scene: window.__zeliard._zeliard_scene(),
      elapsed: window.__zeliard._zeliard_phase_elapsed()
    }));
    if (state.scene !== 1) {
      throw new Error('left opening before target phase: ' + JSON.stringify(state));
    }
    if (state.phase === targetPhase) {
      return state;
    }
    await page.evaluate(() => window.__zeliard._zeliard_tick(100));
  }
  throw new Error('never reached phase ' + targetPhase);
}

const reached = await tickToPhase(4);
console.log('reached', JSON.stringify(reached));
for (const t of [0, 100, 300, 500, 672, 700]) {
  await page.evaluate((elapsedTarget) => {
    const Module = window.__zeliard;
    Module._zeliard_init();
    let guard = 0;
    while (Module._zeliard_phase() !== 4 && Module._zeliard_scene() === 1 && guard++ < 5000) {
      Module._zeliard_tick(100);
    }
    Module._zeliard_tick(elapsedTarget);
  }, t);
  const info = await paint();
  const path = `${outDir}/phase4_${String(t).padStart(4, '0')}.png`;
  await page.locator('#screen').screenshot({ path });
  console.log(`${t}: ${JSON.stringify(info)} -> ${path}`);
}
await browser.close();
