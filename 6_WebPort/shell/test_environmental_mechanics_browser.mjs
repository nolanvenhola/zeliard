import { chromium } from 'playwright';

const url = process.argv[2] ?? 'http://127.0.0.1:5198/';
const capturePath = process.argv[3] ?? '';
const browser = await chromium.launch({ headless: true });
const page = await browser.newPage();
const errors = [];
page.on('pageerror', error => errors.push(error.message));

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
    const samples = [];
    const run = (name, selector, width, x, y) => {
      const origin = (x + width - 16) % width;
      const started = m._zeliard_test_restart_fight(
        selector, origin, (y - 9) & 0x3f, 12);
      const before = [m._zeliard_test_game_u16(0x80),
        m._zeliard_test_game_u8(0x82)];
      for (let tick = 0; tick < 30; ++tick) m._zeliard_tick(20);
      const after = [m._zeliard_test_game_u16(0x80),
        m._zeliard_test_game_u8(0x82)];
      samples.push({ name, started, before, after,
        active: m._zeliard_fight_active(), width: m._zeliard_fight_map_width() });
    };
    run('caliente', 18, 208, 125, 11);
    run('correr', 20, 128, 78, 59);
    return { samples, speed: m._zeliard_game_speed_digit() };
  });

  if (capturePath) await page.locator('#screen').screenshot({ path: capturePath });
  for (const sample of result.samples) {
    if (!sample.started || !sample.active ||
        (sample.before[0] === sample.after[0] && sample.before[1] === sample.after[1]))
      throw new Error(`environmental movement failed: ${JSON.stringify(sample)}`);
  }
  if (result.samples[0].width !== 208 || result.samples[1].width !== 128)
    throw new Error(`environmental map mismatch: ${JSON.stringify(result)}`);
  if (errors.length) throw new Error(`browser errors: ${JSON.stringify(errors)}`);
  console.log(`environmental_browser: PASS ${JSON.stringify(result.samples)}`);
  console.log('VERDICT: PASS: WASM executes Caliente and Correr environmental movement');
} finally {
  await browser.close();
}
