import { chromium } from 'playwright';

const url = process.argv[2] ?? 'http://127.0.0.1:5197/';
const capturePrefix = process.argv[3] ?? '';
const browser = await chromium.launch({ headless: true });
const page = await browser.newPage();
const errors = [];
page.on('pageerror', error => errors.push(error.message));
page.on('console', message => {
  if (message.type() === 'error')
    console.log(`browser:${message.type()}: ${message.text()}`);
});

try {
  await page.goto(url, { waitUntil: 'domcontentloaded' });
  await page.waitForFunction(() => window.__zeliard !== undefined,
    null, { timeout: 120000 });
  await page.waitForSelector('#start:not([hidden])', { timeout: 120000 });
  await page.click('#start');

  const result = await page.evaluate(() => {
    const m = window.__zeliard;
    m._zeliard_opening_set_phase_for_test(3);
    m._zeliard_key(13);
    m._zeliard_tick(0);
    const started = m._zeliard_test_restart_fight(
      20, 64 - 16, (30 - 9) & 0x3f, 12);
    for (let frame = 0; frame < 12; ++frame) m._zeliard_tick(20);
    const pixels = m.HEAPU8.subarray(
      m._zeliard_framebuf(), m._zeliard_framebuf() + 64000);
    let visible = 0;
    for (let y = 0; y < 158; ++y)
      for (let x = 48; x < 272; ++x)
        visible += pixels[y * 320 + x] !== 0;

    const canvas = document.createElement('canvas');
    canvas.id = 'correr-capture';
    canvas.width = 320;
    canvas.height = 200;
    canvas.style.width = '960px';
    canvas.style.height = '600px';
    canvas.style.imageRendering = 'pixelated';
    document.body.appendChild(canvas);
    const ctx = canvas.getContext('2d');
    const image = ctx.createImageData(320, 200);
    const palette = m.HEAPU8.subarray(
      m._zeliard_palette(), m._zeliard_palette() + 256 * 3);
    for (let i = 0; i < pixels.length; ++i) {
      const source = pixels[i] * 3;
      const target = i * 4;
      image.data[target] = palette[source];
      image.data[target + 1] = palette[source + 1];
      image.data[target + 2] = palette[source + 2];
      image.data[target + 3] = 255;
    }
    ctx.putImageData(image, 0, 0);
    return {
      started,
      active: m._zeliard_fight_active(),
      width: m._zeliard_fight_map_width(),
      chunk: m._zeliard_fight_music_chunk(),
      music: m._zeliard_music_track(),
      exactAudio: m._zeliard_exact_music_driver(),
      visible,
    };
  });

  if (capturePrefix) {
    await page.locator('#correr-capture').screenshot({
      path: `${capturePrefix}-correr.png`,
    });
  }
  if (!result.started || !result.active || result.width !== 128 ||
      result.chunk !== 92 || result.music !== 3 || !result.exactAudio ||
      result.visible < 1000)
    throw new Error(`Correr browser parity failed: ${JSON.stringify(result)}`);
  if (errors.length)
    throw new Error(`browser errors: ${JSON.stringify(errors)}`);
  console.log(`correr_browser: PASS width=${result.width} ` +
    `music=${result.chunk}/${result.music} visible=${result.visible}`);
  console.log('VERDICT: PASS: Correr runtime and exact Area-7 audio');
} finally {
  await browser.close();
}
