import { chromium } from 'playwright';

const url = process.argv[2] ?? 'http://127.0.0.1:5175/';
const browser = await chromium.launch({ headless: true });
const page = await browser.newPage();
const pageErrors = [];
page.on('pageerror', (error) => pageErrors.push(error.message));

try {
  await page.goto(url, { waitUntil: 'domcontentloaded' });
  await page.waitForFunction(() => window.__zeliard !== undefined,
    null, { timeout: 120000 });
  await page.waitForSelector('#start:not([hidden])', { timeout: 120000 });
  await page.click('#start');
  await page.evaluate(() => {
    const module = window.__zeliard;
    module._zeliard_opening_set_phase_for_test(3);
    module._zeliard_key(13);
    module._zeliard_tick(0);
  });
  await page.waitForFunction(() => window.__zeliard._zeliard_scene() === 2,
    null, { timeout: 5000 });

  const entryStart = await page.evaluate(() => ({
    result: window.__zeliard._zeliard_test_enter_room(3),
    kind: window.__zeliard._zeliard_room_kind(),
  }));
  if (entryStart.result !== 0 || entryStart.kind !== 0)
    throw new Error(`viewing-room transition failed: ${JSON.stringify(entryStart)}`);
  await page.waitForFunction(() => window.__zeliard._zeliard_room_kind() === 3,
    null, { timeout: 5000 });
  const entered = await page.evaluate(() => {
    const module = window.__zeliard;
    const framebuffer = module._zeliard_framebuf();
    let hash = 0xCBF29CE484222325n;
    for (let row = 0; row < 128; ++row) {
      const at = framebuffer + (30 + row) * 320 + 96;
      for (let column = 0; column < 136; ++column) {
        hash ^= BigInt(module.HEAPU8[at + column]);
        hash = BigInt.asUintN(64, hash * 0x100000001B3n);
      }
    }
    return { kind: module._zeliard_room_kind(),
      artwork: hash.toString(16).padStart(16, '0') };
  });
  if (entered.kind !== 3 || entered.artwork !== '33207d5a3e0a63ef')
    throw new Error(`viewing-room entry mismatch: ${JSON.stringify(entered)}`);

  const exitStartKind = await page.evaluate(() => {
    const module = window.__zeliard;
    module._zeliard_key(32);
    module._zeliard_tick(100);
    return module._zeliard_room_kind();
  });
  if (exitStartKind !== 3)
    throw new Error(`viewing-room exit skipped fade: kind=${exitStartKind}`);
  await page.waitForFunction(() => window.__zeliard._zeliard_room_kind() === 0,
    null, { timeout: 1000 });
  if (pageErrors.length)
    throw new Error(`browser errors: ${JSON.stringify(pageErrors)}`);
  console.log(`felishika_rooms_browser: PASS kind=3 artwork=${entered.artwork} return=castle`);
  console.log('VERDICT: PASS: MASM viewing-room browser smoke');
} finally {
  await browser.close();
}
