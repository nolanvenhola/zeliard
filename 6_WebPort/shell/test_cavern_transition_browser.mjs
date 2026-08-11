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
  const townOrigin = await page.evaluate(() => {
    const m = window.__zeliard;
    m._zeliard_opening_set_phase_for_test(3);
    m._zeliard_key(13);
    m._zeliard_tick(0);
    /* Enter Muralla with sword #2 and a full 0100h life bar so the reverse
       route can prove that both are reconstructed from live state. */
    m._zeliard_test_game_set_u8(0x92, 2);
    m._zeliard_test_game_set_u8(0x90, 0);
    m._zeliard_test_game_set_u8(0x91, 1);
    m._zeliard_test_game_set_u8(0xB2, 0);
    m._zeliard_test_game_set_u8(0xB3, 1);
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
    /* Exercise 206GFMCA:shield_state_get and the shield-specific FMAN bank. */
    m._zeliard_test_game_set_u8(0x93, 1);
    m._zeliard_test_game_set_u8(0xFF2A, 0xDF);
    m._zeliard_test_game_set_u8(0xFF2B, 0xC5);
    m._zeliard_tick(20);
    return {
      ticks,
      startLo: m._zeliard_test_game_u8(0x80),
      startHi: m._zeliard_test_game_u8(0x81),
      scroll: m._zeliard_test_game_u8(0x82),
      column: m._zeliard_test_game_u8(0x83),
    };
  });
  if (capturePrefix) {
    await page.waitForTimeout(20);
    await page.locator('#screen').screenshot({
      path: `${capturePrefix}-town-before.png`,
    });
  }
  const route = await page.evaluate(origin => {
    const m = window.__zeliard;
    /* Capture the exact frame that main.c suspends on this same turn. Keeping
     * this adjacent to key-down avoids comparing against an intervening RAF
     * town animation frame. */
    window.__townPaletteBefore = Uint8Array.from(m.HEAPU8.subarray(
      m._zeliard_palette(), m._zeliard_palette() + 768));
    window.__townFrameBefore = Uint8Array.from(m.HEAPU8.subarray(
      m._zeliard_framebuf(), m._zeliard_framebuf() + 64000));
    m._zeliard_key_down(38);
    let doorTicks = 0;
    while (!m._zeliard_cavern_transition_active() && doorTicks++ < 100)
      m._zeliard_tick(20);
    m._zeliard_key_up(38);
    return {
      ...origin, doorTicks,
      startedAt: m._zeliard_cavern_transition_step(),
      requested: m._zeliard_town_cavern_exit_requested(),
    };
  }, townOrigin);
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
    const entry = {
      ...routeState, transitionTicks,
      active: m._zeliard_cavern_transition_active(),
      complete: m._zeliard_cavern_transition_complete(),
      step: m._zeliard_cavern_transition_step(),
    };
    m._zeliard_test_game_set_u8(0x80, 0x2D);
    m._zeliard_test_game_set_u8(0x81, 0);
    m._zeliard_test_game_set_u8(0x82, 0x3D);
    m._zeliard_test_game_set_u8(0x83, 0);
    m._zeliard_test_game_set_u8(0x85, 0);
    m._zeliard_test_game_set_u8(0x86, 0x64);
    m._zeliard_test_game_set_u8(0x87, 0);
    m._zeliard_test_game_set_u8(0x8B, 0x64);
    m._zeliard_test_game_set_u8(0x8C, 0);
    m._zeliard_test_game_set_u8(0x90, 0x40);
    m._zeliard_test_game_set_u8(0x91, 0);
    m._zeliard_test_game_set_u8(0xB2, 0);
    m._zeliard_test_game_set_u8(0xB3, 1);
    m._zeliard_test_game_set_u8(0xC2, 0);
    m._zeliard_test_game_set_u8(0xC3, 0);
    m._zeliard_tick(20);
    if (!m.ccall('zeliard_fight_active', 'number'))
      return { ...entry, returned: { error: 'fight did not start' } };
    m._zeliard_key_down(38);
    let exitTicks = 0;
    while (!m._zeliard_cavern_transition_active() && exitTicks++ < 100)
      m._zeliard_tick(20);
    m._zeliard_key_up(38);
    let returnTicks = 0;
    while (!m._zeliard_cavern_transition_complete() && returnTicks++ < 1000)
      m._zeliard_tick(20);
    m._zeliard_tick(20);
    const finishFrame = m.HEAPU8.subarray(
      m._zeliard_framebuf(), m._zeliard_framebuf() + 64000);
    const finishDiff = finishFrame.reduce((count, value, index) =>
      count + (value !== window.__townFrameBefore[index]), 0);
    const rectDiff = (x, y, width, height) => {
      let count = 0;
      for (let row = 0; row < height; ++row)
        for (let column = 0; column < width; ++column) {
          const index = (y + row) * 320 + x + column;
          count += finishFrame[index] !== window.__townFrameBefore[index];
        }
      return count;
    };
    const finishLifeDiff = rectDiff(84, 163, 100, 6);
    const finishSwordDiff = rectDiff(192, 171, 20, 18);
    /* MOLE's stone chrome contains masked OR passes.  MASM enters 106TOWN
       from a black framebuffer, so none of the preceding FIGHT/ROKA pixels
       may survive in the top or side borders.  These regions are invariant
       across a same-town round trip even though the playfield and HUD move. */
    let finishChromeDiff = rectDiff(0, 0, 320, 14);
    finishChromeDiff += rectDiff(0, 14, 48, 146);
    finishChromeDiff += rectDiff(272, 14, 48, 146);
    const rectHash = (x, y, width, height) => {
      let hash = 0xcbf29ce484222325n;
      for (let row = 0; row < height; ++row)
        for (let column = 0; column < width; ++column) {
          hash ^= BigInt(finishFrame[(y + row) * 320 + x + column]);
          hash = BigInt.asUintN(64, hash * 0x100000001b3n);
        }
      return hash.toString(16).padStart(16, '0');
    };
    const finishLifeHash = rectHash(84, 163, 100, 6);
    const finishSwordHash = rectHash(192, 171, 20, 18);
    const finishTransition = m._zeliard_cavern_transition_active();
    m._zeliard_tick(20);
    const paletteNow = m.HEAPU8.subarray(
      m._zeliard_palette(), m._zeliard_palette() + 768);
    const frameNow = m.HEAPU8.subarray(
      m._zeliard_framebuf(), m._zeliard_framebuf() + 64000);
    return { ...entry, returned: {
      exitTicks, returnTicks,
      finishDiff, finishLifeDiff, finishSwordDiff,
      finishLifeHash, finishSwordHash, finishChromeDiff, finishTransition,
      area: m._zeliard_town_area(),
      fight: m.ccall('zeliard_fight_active', 'number'),
      transition: m._zeliard_cavern_transition_active(),
      startLo: m._zeliard_test_game_u8(0x80),
      startHi: m._zeliard_test_game_u8(0x81),
      scroll: m._zeliard_test_game_u8(0x82),
      column: m._zeliard_test_game_u8(0x83),
      hp: m._zeliard_test_game_u8(0x90) |
        (m._zeliard_test_game_u8(0x91) << 8),
      paletteDiff: paletteNow.reduce((count, value, index) =>
        count + (value !== window.__townPaletteBefore[index]), 0),
      frameDiff: frameNow.reduce((count, value, index) =>
        count + (value !== window.__townFrameBefore[index]), 0),
    } };
  }, route);
  if (!result.requested || result.startedAt < 1 || !result.complete ||
      result.active || result.step !== 26)
    throw new Error(`cavern transition failed: ${JSON.stringify(result)}`);
  const returned = result.returned;
  if (capturePrefix) {
    await page.waitForTimeout(20);
    await page.locator('#screen').screenshot({
      path: `${capturePrefix}-town-after.png`,
    });
  }
  if (returned.error || returned.area !== 1 || returned.fight ||
      returned.transition || returned.finishTransition ||
      returned.hp !== 0x40 || returned.finishDiff < 1 ||
      returned.finishLifeDiff < 1 ||
      returned.finishChromeDiff !== 0 ||
      returned.finishLifeHash !== '814e303d8c7e90bd' ||
      returned.finishSwordHash !== '077a65acb967926d' ||
      returned.startLo !== 0xB3 || returned.startHi !== 0 ||
      returned.scroll !== 0x36 || returned.column !== 0x16)
    throw new Error(`cavern return failed: ${JSON.stringify({result, returned})}`);
  const satonoRoundTrip = await page.evaluate(() => {
    const m = window.__zeliard;
    if (!m._zeliard_test_restart_town(2))
      return {error: 'Satono restart failed'};
    for (let settle = 0; settle < 10; ++settle) m._zeliard_tick(16);
    const before = Uint8Array.from(m.HEAPU8.subarray(
      m._zeliard_framebuf(), m._zeliard_framebuf() + 64000));
    m._zeliard_test_game_set_u8(0x83, 0xff);
    m._zeliard_tick(90);
    let departureTicks = 0;
    while (m._zeliard_cavern_transition_active() &&
           departureTicks++ < 1000) m._zeliard_tick(16);
    if (!m._zeliard_fight_active()) m._zeliard_tick(16);
    const enteredMalicia = m._zeliard_fight_active() &&
      m._zeliard_fight_map_width() === 240;
    m._zeliard_test_game_set_u8(0x98, 1);
    const staged = m._zeliard_test_restart_fight(
      0, 128 - 16, (32 - 9) & 0x3f, 0);
    m._zeliard_key_down(38);
    let doorTicks = 0;
    while (!m._zeliard_cavern_transition_active() && doorTicks++ < 100)
      m._zeliard_tick(16);
    m._zeliard_key_up(38);
    let returnTicks = 0;
    while ((m._zeliard_fight_active() ||
            m._zeliard_cavern_transition_active()) &&
           returnTicks++ < 1000) m._zeliard_tick(16);
    m._zeliard_tick(16);
    const after = m.HEAPU8.subarray(
      m._zeliard_framebuf(), m._zeliard_framebuf() + 64000);
    let chromeDiff = 0;
    for (let y = 0; y < 160; ++y)
      for (let x = 0; x < 320; ++x) {
        if (y >= 14 && x >= 48 && x < 272) continue;
        chromeDiff += before[y * 320 + x] !== after[y * 320 + x];
      }
    return {
      enteredMalicia, staged, departureTicks, doorTicks, returnTicks,
      chromeDiff, area: m._zeliard_town_area(),
      fight: m._zeliard_fight_active(),
      transition: m._zeliard_cavern_transition_active(),
    };
  });
  if (capturePrefix) {
    await page.waitForTimeout(20);
    await page.locator('#screen').screenshot({
      path: `${capturePrefix}-satono-after.png`,
    });
  }
  if (satonoRoundTrip.error || !satonoRoundTrip.enteredMalicia ||
      !satonoRoundTrip.staged || satonoRoundTrip.area !== 2 ||
      satonoRoundTrip.fight || satonoRoundTrip.transition ||
      satonoRoundTrip.chromeDiff !== 0)
    throw new Error(`Satono round trip failed: ${JSON.stringify(satonoRoundTrip)}`);
  if (errors.length) throw new Error(`browser errors: ${JSON.stringify(errors)}`);
  console.log(`cavern_transition_browser: PASS route=${result.ticks} ` +
    `entry=${result.transitionTicks} return=${returned.returnTicks} ` +
    `steps=${result.step} paletteDiff=${returned.paletteDiff} ` +
    `finishDiff=${returned.finishDiff} frameDiff=${returned.frameDiff} ` +
    `satonoChromeDiff=${satonoRoundTrip.chromeDiff}`);
  console.log('VERDICT: PASS: clean Muralla and Satono cavern round trips');
} finally {
  await browser.close();
}
