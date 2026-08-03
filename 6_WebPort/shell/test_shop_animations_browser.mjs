import { chromium } from 'playwright';

const url = process.argv[2] ?? 'http://127.0.0.1:5177/';
const browser = await chromium.launch({ headless: true });
const page = await browser.newPage();

const hashRect = async (rect) => page.evaluate(
  ({ x, y, width, height }) => {
    const module = window.__zeliard;
    const framebuffer = module._zeliard_framebuf();
    let hash = 0xCBF29CE484222325n;
    for (let row = 0; row < height; ++row) {
      const offset = framebuffer + (y + row) * 320 + x;
      for (let column = 0; column < width; ++column) {
        hash ^= BigInt(module.HEAPU8[offset + column]);
        hash = BigInt.asUintN(64, hash * 0x100000001B3n);
      }
    }
    return hash.toString(16).padStart(16, '0');
  }, rect);

async function enterRoom(kind) {
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
  const reached = await page.evaluate((kind) => {
    const module = window.__zeliard;
    module._zeliard_key_down(39);
    let ticks = 0;
    while (module._zeliard_town_area() !== 1 && ticks++ < 3000)
      module._zeliard_tick(20);
    module._zeliard_key_up(39);
    module._zeliard_tick(20);
    const result = module._zeliard_test_enter_room(kind);
    while ((module._zeliard_room_kind() !== kind ||
            module._zeliard_room_input_kind() === 0) && ticks++ < 9000)
      module._zeliard_tick(20);
    return { ticks, area: module._zeliard_town_area(), result,
      room: module._zeliard_room_kind(),
      input: module._zeliard_room_input_kind() };
  }, kind);
  if (reached.area !== 1 || reached.result !== 0 ||
      reached.room !== kind || reached.input === 0)
    throw new Error(`room ${kind} not ready: ${JSON.stringify(reached)}`);
}

async function pulse(key) {
  await page.evaluate((key) => {
    const module = window.__zeliard;
    module._zeliard_key_down(key);
    module._zeliard_tick(60);
    module._zeliard_key_up(key);
    module._zeliard_tick(60);
  }, key);
}

async function sampleOption({ name, kind, down, preSpaces = 1, rect }) {
  await enterRoom(kind);
  for (let row = 0; row < down; ++row) await pulse(40);
  for (let press = 0; press < preSpaces; ++press) await pulse(32);
  const before = await hashRect(rect);
  const bounds = await page.evaluate(({ x, y, width, height }) => {
    const module = window.__zeliard;
    const framebuffer = module._zeliard_framebuf();
    const baseline = module.HEAPU8.slice(framebuffer, framebuffer + 64000);
    let minX = 320, minY = 200, maxX = 0, maxY = 0, changed = 0;
    const hashes = new Set();
    module._zeliard_key_down(32);
    for (let sample = 0; sample < 120; ++sample) {
      module._zeliard_tick(55);
      for (let at = 0; at < 64000; ++at) {
        if (module.HEAPU8[framebuffer + at] === baseline[at]) continue;
        const x = at % 320, y = Math.floor(at / 320);
        minX = Math.min(minX, x); maxX = Math.max(maxX, x);
        minY = Math.min(minY, y); maxY = Math.max(maxY, y);
        ++changed;
      }
      let hash = 0xCBF29CE484222325n;
      for (let row = 0; row < height; ++row) {
        const offset = framebuffer + (y + row) * 320 + x;
        for (let column = 0; column < width; ++column) {
          hash ^= BigInt(module.HEAPU8[offset + column]);
          hash = BigInt.asUintN(64, hash * 0x100000001B3n);
        }
      }
      hashes.add(hash.toString(16));
    }
    module._zeliard_key_up(32);
    return { minX, minY, maxX, maxY, changed, unique: hashes.size };
  }, rect);
  return { name, before, count: bounds.unique, bounds };
}

try {
  const results = [await sampleOption({
    // 212ARMRP render_shopkeeper_frame: BX=0717h -> (56, 23).
    name: 'armory-shopkeeper', kind: 4, down: 2,
    rect: { x: 56, y: 23, width: 96, height: 96 },
  }), await sampleOption({
    // 215DRUGP animate_wizard_glyphs: BX=0D17h -> (104, 23).
    name: 'witchcraft-glyphs', kind: 5, down: 0, preSpaces: 1,
    rect: { x: 104, y: 23, width: 48, height: 48 },
  }), await sampleOption({
    // 213BANKP draw_banner_8x5: BX=091Fh -> (72, 31).
    name: 'bank-banner', kind: 7, down: 0, preSpaces: 1,
    rect: { x: 72, y: 31, width: 64, height: 40 },
  })];
  const staticResults = results.filter(({ count }) => count < 3);
  if (staticResults.length)
    throw new Error(`static MASM animation regions: ${staticResults.map(
      ({ name, count }) => `${name}=${count}`).join(', ')}`);
  console.log(`shop_animations_browser: PASS ${results.map(
    ({ name, count }) => `${name}=${count}`).join(' ')}`);
  console.log('VERDICT: PASS: MASM shop animations reach browser framebuffer');
} finally {
  await browser.close();
}
