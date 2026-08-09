import { chromium } from 'playwright';

const url = process.argv[2] ?? 'http://127.0.0.1:5179/';
const capturePrefix = process.argv[3] ?? '';
const browser = await chromium.launch({ headless: true });
const page = await browser.newPage();
const errors = [];
page.on('pageerror', error => errors.push(error.message));

const cases = [
  ['reaccion', 0x13, 196, 92],
  ['absor', 0x17, 256, 93],
  ['milagro', 0x18, 256, 93],
  ['desleal', 0x19, 192, 93],
  ['falter', 0x1a, 128, 93],
  ['final', 0x1b, 64, 93],
];

try {
  await page.goto(url, { waitUntil: 'domcontentloaded' });
  await page.waitForFunction(() => window.__zeliard !== undefined,
    null, { timeout: 120000 });
  await page.waitForSelector('#start:not([hidden])', { timeout: 120000 });
  await page.click('#start');
  await page.evaluate(() => {
    const m = window.__zeliard;
    m._zeliard_opening_set_phase_for_test(3);
    m._zeliard_key(13);
    m._zeliard_tick(0);
  });

  const results = [];
  for (const [name, selector, expectedWidth, expectedMusic] of cases) {
    const result = await page.evaluate(({ selector }) => {
      const m = window.__zeliard;
      const started = m._zeliard_test_restart_fight(selector, 4, 21, 12);
      for (let frame = 0; frame < 12; ++frame) m._zeliard_tick(20);
      const pixels = m.HEAPU8.subarray(
        m._zeliard_framebuf(), m._zeliard_framebuf() + 64000);
      let visible = 0;
      for (let y = 0; y < 158; ++y)
        for (let x = 48; x < 272; ++x)
          visible += pixels[y * 320 + x] !== 0;
      return {
        started,
        active: m._zeliard_fight_active(),
        width: m._zeliard_fight_map_width(),
        chunk: m._zeliard_fight_music_chunk(),
        exactAudio: m._zeliard_exact_music_driver(),
        visible,
      };
    }, { selector });
    results.push({ name, ...result });
    if (capturePrefix)
      await page.locator('#screen').screenshot({
        path: `${capturePrefix}-${name}.png`,
      });
    if (!result.started || !result.active || result.width !== expectedWidth ||
        result.chunk !== expectedMusic || !result.exactAudio ||
        result.visible < 1000)
      throw new Error(`${name} browser parity failed: ${JSON.stringify(result)}`);
  }
  if (errors.length)
    throw new Error(`browser errors: ${JSON.stringify(errors)}`);
  console.log(`remaining_caverns_browser: PASS ${JSON.stringify(results)}`);
  console.log('VERDICT: PASS: all remaining caverns render through WASM with exact audio');
} finally {
  await browser.close();
}
