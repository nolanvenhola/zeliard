import { chromium } from 'playwright';

const url = process.argv[2] ?? 'http://127.0.0.1:5177/';
const capturePrefix = process.argv[3] ?? '';
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
  const route = await page.evaluate(() => {
    const m = window.__zeliard;
    m._zeliard_opening_set_phase_for_test(3);
    m._zeliard_key(13);
    m._zeliard_tick(0);
    m._zeliard_key_down(39);
    let ticks = 0;
    while (m._zeliard_town_area() !== 1 && ticks++ < 3000)
      m._zeliard_tick(20);
    m._zeliard_key_up(39);
    m._zeliard_tick(20);
    /* Same near-door state as town_runtime_native's pf30 oracle. The final
       up input, target detection, destination decode, and handoff all
       execute through the real WASM runtime. */
    m._zeliard_test_game_set_u8(0x80, 0xB9);
    m._zeliard_test_game_set_u8(0x81, 0);
    m._zeliard_test_game_set_u8(0x83, 0x10);
    m._zeliard_test_game_set_u8(0xFF2A, 0xDF);
    m._zeliard_test_game_set_u8(0xFF2B, 0xC5);
    m._zeliard_key_down(38);
    let doorTicks = 0;
    while (!m._zeliard_cavern_transition_active() && doorTicks++ < 100)
      m._zeliard_tick(20);
    m._zeliard_key_up(38);
    return {
      ticks, doorTicks,
      startedAt: m._zeliard_cavern_transition_step(),
      requested: m._zeliard_town_cavern_exit_requested(),
    };
  });
  if (capturePrefix) {
    await page.waitForTimeout(20);
    await page.locator('#screen').screenshot({
      path: `${capturePrefix}-entry.png`,
    });
  }
  await page.evaluate(() => {
    const m = window.__zeliard;
    while (m._zeliard_cavern_transition_step() < 13)
      m._zeliard_tick(20);
  });
  if (capturePrefix) {
    await page.waitForTimeout(20);
    await page.locator('#screen').screenshot({
      path: `${capturePrefix}-midpoint.png`,
    });
  }
  const result = await page.evaluate(routeState => {
    const m = window.__zeliard;
    /* Keep left held: check_c3 must ignore it and still complete 26 steps. */
    m._zeliard_key_down(37);
    let transitionTicks = 0;
    while (!m._zeliard_cavern_transition_complete() &&
           transitionTicks++ < 1000) m._zeliard_tick(20);
    m._zeliard_key_up(37);
    return {
      ...routeState, transitionTicks,
      active: m._zeliard_cavern_transition_active(),
      complete: m._zeliard_cavern_transition_complete(),
      step: m._zeliard_cavern_transition_step(),
    };
  }, route);
  if (capturePrefix) {
    await page.waitForTimeout(20);
    await page.locator('#screen').screenshot({
      path: `${capturePrefix}-complete.png`,
    });
  }
  if (!result.requested || result.startedAt < 1 || !result.complete ||
      result.active || result.step !== 26)
    throw new Error(`cavern transition failed: ${JSON.stringify(result)}`);
  if (errors.length) throw new Error(`browser errors: ${JSON.stringify(errors)}`);
  console.log(`cavern_transition_browser: PASS route=${result.ticks} ` +
    `transition=${result.transitionTicks} steps=${result.step}`);
  console.log('VERDICT: PASS: Muralla town -> forced cavern entry');
} finally {
  await browser.close();
}
