import fs from 'node:fs';
import { chromium } from 'playwright';

const url = process.argv[2] ?? 'http://127.0.0.1:5179/';
const savePath = process.argv[3] ??
  'C:/Users/nvenh/OneDrive/Desktop/BOSQUE2.usr';
const capturePrefix = process.argv[4] ?? '';
const save = new Uint8Array(fs.readFileSync(savePath));
const browser = await chromium.launch({ headless: true });
const page = await browser.newPage();

function countVisible(bytes) {
  let count = 0;
  for (let y = 0; y < 158; ++y)
    for (let x = 48; x < 272; ++x)
      count += bytes[y * 320 + x] !== 0;
  return count;
}

try {
  await page.goto(url, { waitUntil: 'domcontentloaded' });
  await page.waitForFunction(() => window.__zeliard !== undefined,
    null, { timeout: 120000 });
  await page.click('#start');
  const setup = await page.evaluate(record => {
    const m = window.__zeliard;
    const pointer = m._malloc(record.length);
    m.HEAPU8.set(record, pointer);
    const loaded = m._zeliard_load_record(pointer, record.length);
    m._free(pointer);
    for (let tick = 0; tick < 80; ++tick) m._zeliard_tick(20);
    /* Use Bosque's authored town-to-Riza door instead of the fight test
       restart. This exercises the same transition and VM bootstrap as play. */
    m._zeliard_test_game_set_u8(0x80, 125);
    m._zeliard_test_game_set_u8(0x81, 0);
    m._zeliard_test_game_set_u8(0x83, 13);
    const tile = 0xc017 + 125 * 8;
    m._zeliard_test_game_set_u8(0xff2a, tile & 0xff);
    m._zeliard_test_game_set_u8(0xff2b, tile >>> 8);
    m._zeliard_key_down(38);
    let transitionTicks = 0;
    while (!m._zeliard_cavern_transition_active() && transitionTicks++ < 80)
      m._zeliard_tick(20);
    m._zeliard_key_up(38);
    while (!m._zeliard_cavern_transition_complete() && transitionTicks++ < 1200)
      m._zeliard_tick(20);
    while (!m._zeliard_fight_active() && transitionTicks++ < 1300)
      m._zeliard_tick(20);
    for (let tick = 0; tick < 8; ++tick) m._zeliard_tick(20);
    return { loaded, transitionTicks, active: m._zeliard_fight_active() };
  }, [...save]);

  const sample = () => page.evaluate(() => {
    const m = window.__zeliard;
    const indexed = m.HEAPU8.slice(
      m._zeliard_framebuf(), m._zeliard_framebuf() + 64000);
    const rgbActive = m._zeliard_rgb_framebuf_active();
    const rgb = m.HEAPU8.slice(
      m._zeliard_rgb_framebuf(), m._zeliard_rgb_framebuf() + 64000 * 3);
    let indexedVisible = 0;
    let rgbVisible = 0;
    for (let y = 0; y < 158; ++y) {
      for (let x = 48; x < 272; ++x) {
        indexedVisible += indexed[y * 320 + x] !== 0;
        const p = (y * 320 + x) * 3;
        rgbVisible += rgb[p] !== 0 || rgb[p + 1] !== 0 || rgb[p + 2] !== 0;
      }
    }
    return {
      indexedVisible, rgbVisible, rgbActive,
      paused: m._zeliard_paused(), speedMenu: m._zeliard_speed_menu_active(),
      speed: m._zeliard_game_speed_digit(), active: m._zeliard_fight_active(),
      inventory: m._zeliard_inventory_active(),
      transition: m._zeliard_cavern_transition_active(),
      townArea: m._zeliard_town_area(),
      area: m._zeliard_test_game_u8(0xc4),
      previousArea: m._zeliard_test_game_u8(0xc5),
      timerKeys: m._zeliard_test_game_u16(0xff18),
      ip: m._zeliard_fight_ip(), width: m._zeliard_fight_map_width(),
    };
  });

  const before = await sample();
  await page.locator('#screen').click();
  await page.keyboard.down('F9');
  await page.waitForTimeout(100);
  await page.keyboard.up('F9');
  const opened = await sample();
  await page.keyboard.press('7');
  const selected = await sample();
  await page.keyboard.down('Enter');
  await page.waitForTimeout(100);
  await page.keyboard.up('Enter');
  const immediate = await sample();
  await page.waitForTimeout(250);
  const resumed = await sample();
  const sustained = await page.evaluate(async () => {
    const m = window.__zeliard;
    let minimumVisible = 64000;
    let blackFrames = 0;
    for (let frame = 0; frame < 600; ++frame) {
      await new Promise(resolve => requestAnimationFrame(resolve));
      const indexed = m.HEAPU8.subarray(
        m._zeliard_framebuf(), m._zeliard_framebuf() + 64000);
      let visible = 0;
      for (let y = 0; y < 158; ++y)
        for (let x = 48; x < 272; ++x)
          visible += indexed[y * 320 + x] !== 0;
      minimumVisible = Math.min(minimumVisible, visible);
      blackFrames += visible < 1000;
    }
    return { minimumVisible, blackFrames, active: m._zeliard_fight_active() };
  });
  const heartbeat = await page.evaluate(() => {
    const m = window.__zeliard;
    /* MP31.mdt C013/C015 stores the target at 188/21. 200FIGHT writes
       SNDADLIB's attenuation byte at FF08; there is no FF75 heartbeat cue. */
    const started = m._zeliard_test_restart_fight(
      6, 188 - 16, (21 - 9) & 0x3f, 12);
    for (let frame = 0; frame < 8; ++frame) m._zeliard_tick(20);
    const nearVolume = m._zeliard_test_game_u8(0xff08);
    m._zeliard_test_game_set_u8(0x80, 0);
    m._zeliard_test_game_set_u8(0x81, 0);
    m._zeliard_test_game_set_u8(0x82, 0);
    for (let frame = 0; frame < 8; ++frame) m._zeliard_tick(20);
    const farVolume = m._zeliard_test_game_u8(0xff08);
    return { started, nearVolume, farVolume };
  });
  const heartbeatAudio = await page.evaluate(async () => {
    const m = window.__zeliard;
    const started = m._zeliard_test_restart_fight(
      6, 188 - 16, (21 - 9) & 0x3f, 12);
    const before = { ...(window.__zeliardAudioStats ?? {}) };
    await new Promise(resolve => setTimeout(resolve, 5000));
    const after = { ...(window.__zeliardAudioStats ?? {}) };
    return { started, before, after, volume: m._zeliard_test_game_u8(0xff08) };
  });
  const heartbeatReload = await page.evaluate(async record => {
    const m = window.__zeliard;
    const beforeReset = m._zeliard_audio_reset_serial();
    const pointer = m._malloc(record.length);
    m.HEAPU8.set(record, pointer);
    const loaded = m._zeliard_load_record(pointer, record.length);
    m._free(pointer);
    await new Promise(resolve => setTimeout(resolve, 500));
    return {
      loaded,
      beforeReset,
      afterReset: m._zeliard_audio_reset_serial(),
      heartbeatVolume: m._zeliard_test_game_u8(0xff08),
      fightActive: m._zeliard_fight_active(),
      area: m._zeliard_test_game_u8(0xc4),
    };
  }, [...save]);
  if (capturePrefix)
    await page.locator('#screen').screenshot({ path: `${capturePrefix}.png` });
  const result = {
    setup, before, opened, selected, immediate, resumed, sustained, heartbeat,
    heartbeatAudio, heartbeatReload,
  };
  console.log(JSON.stringify(result, null, 2));
  const visible = resumed.rgbActive ? resumed.rgbVisible : resumed.indexedVisible;
  if (!setup.loaded || !setup.active || !opened.speedMenu || !opened.paused ||
      selected.speed !== 7 || selected.speedMenu !== 1 ||
      !resumed.active || resumed.speedMenu || resumed.paused || visible < 1000 ||
      sustained.blackFrames !== 0 || !sustained.active ||
      !heartbeat.started || heartbeat.nearVolume !== 15 ||
      heartbeat.farVolume !== 0 || !heartbeatReload.loaded ||
      heartbeatReload.afterReset === heartbeatReload.beforeReset ||
      heartbeatReload.heartbeatVolume !== 0 || heartbeatReload.fightActive)
    process.exitCode = 1;
} finally {
  await browser.close();
}
