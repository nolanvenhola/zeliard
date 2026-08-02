import { chromium } from 'playwright';

const url = process.argv[2] ?? 'http://127.0.0.1:5176/';
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

  const inventory = await page.evaluate(() => {
    const module = window.__zeliard;
    const framebuffer = module._zeliard_framebuf();
    let hash = 0xCBF29CE484222325n;
    let nonzero = 0;
    for (let row = 0; row < 18; ++row) {
      const at = framebuffer + (171 + row) * 320 + 192;
      for (let column = 0; column < 20; ++column) {
        const pixel = module.HEAPU8[at + column];
        nonzero += pixel !== 0;
        hash ^= BigInt(pixel);
        hash = BigInt.asUintN(64, hash * 0x100000001B3n);
      }
    }
    return { hash: hash.toString(16).padStart(16, '0'), nonzero };
  });
  if (inventory.hash !== 'ace1eec895369b0a' || inventory.nonzero === 0)
    throw new Error(`Training Sword mismatch: ${JSON.stringify(inventory)}`);
  if (pageErrors.length)
    throw new Error(`browser errors: ${JSON.stringify(pageErrors)}`);
  console.log(`castle_inventory_browser: PASS sword=${inventory.hash} nonzero=${inventory.nonzero}`);
  console.log('VERDICT: PASS: MASM Training Sword browser smoke');
} finally {
  await browser.close();
}
