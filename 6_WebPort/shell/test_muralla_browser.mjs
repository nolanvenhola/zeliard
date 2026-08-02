import { chromium } from 'playwright';

const url = process.argv[2] ?? 'http://127.0.0.1:5177/';
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

  const route = await page.evaluate(() => {
    const module = window.__zeliard;
    const advance = (key, limit, stop) => {
      module._zeliard_key_down(key);
      let steps = 0;
      while (!stop() && steps++ < limit) module._zeliard_tick(20);
      module._zeliard_key_up(key);
      module._zeliard_tick(20);
      return steps;
    };
    const toMuralla = advance(39, 2500, () => module._zeliard_town_area() === 1);
    let npcSteps = 0;
    module._zeliard_key_down(39);
    while (!module._zeliard_town_dialog_active() && npcSteps++ < 2500) {
      module._zeliard_tick(20);
      if ((npcSteps % 5) === 0) module._zeliard_key(32);
    }
    module._zeliard_key_up(39);
    module._zeliard_tick(20);
    const dialogOpened = module._zeliard_town_dialog_active();
    let dialogPages = 0;
    while (module._zeliard_town_dialog_active() && dialogPages++ < 8) {
      module._zeliard_key(32);
      module._zeliard_tick(100);
    }
    return { toMuralla, npcSteps, dialogOpened, dialogPages,
      area: module._zeliard_town_area() };
  });
  if (route.area !== 1 || !route.dialogOpened)
    throw new Error(`Muralla traversal/dialog failed: ${JSON.stringify(route)}`);

  const roomStart = await page.evaluate(() => ({
    result: window.__zeliard._zeliard_test_enter_room(4),
    area: window.__zeliard._zeliard_town_area(),
  }));
  if (roomStart.result !== 0 || roomStart.area !== 1)
    throw new Error(`Armory transition failed: ${JSON.stringify(roomStart)}`);
  await page.waitForFunction(() => window.__zeliard._zeliard_room_kind() === 4,
    null, { timeout: 5000 });
  const room = await page.evaluate(() => {
    const module = window.__zeliard;
    let ticks = 0;
    while (module._zeliard_room_kind() !== 0 && ticks++ < 6000) {
      module._zeliard_tick(20);
      if (module._zeliard_room_input_kind() !== 0) module._zeliard_key(32);
    }
    return { ticks, kind: module._zeliard_room_kind() };
  });
  if (room.kind !== 0)
    throw new Error(`Armory round trip failed: ${JSON.stringify(room)}`);

  const returned = await page.evaluate(() => {
    const module = window.__zeliard;
    module._zeliard_key_down(37);
    let steps = 0;
    while (module._zeliard_town_area() !== 0 && steps++ < 4000)
      module._zeliard_tick(20);
    module._zeliard_key_up(37);
    module._zeliard_tick(20);
    return { steps, area: module._zeliard_town_area() };
  });
  if (returned.area !== 0)
    throw new Error(`Muralla return route failed: ${JSON.stringify(returned)}`);
  if (pageErrors.length)
    throw new Error(`browser errors: ${JSON.stringify(pageErrors)}`);
  console.log(`muralla_browser: PASS entry=${route.toMuralla} npc=${route.npcSteps} ` +
    `pages=${route.dialogPages} room=${room.ticks} return=${returned.steps}`);
  console.log('VERDICT: PASS: Felishika -> Muralla -> Armory -> Felishika browser smoke');
} finally {
  await browser.close();
}
