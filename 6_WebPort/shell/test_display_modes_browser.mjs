import { chromium } from 'playwright';

const url = process.argv[2] ?? 'http://127.0.0.1:5179/';
const browser = await chromium.launch({ headless: true });
const page = await browser.newPage();
const errors = [];
page.on('pageerror', error => errors.push(error.message));

const limits = [16, 4, 2, 2, 256, 16];
const names = ['EGA', 'CGA', 'CGA2', 'HGC', 'MCGA', 'Tandy'];

async function verifyModes(label) {
  const samples = [];
  for (let mode = 0; mode < limits.length; ++mode) {
    await page.selectOption('#display-mode', String(mode));
    await page.waitForTimeout(50);
    const sample = await page.evaluate(() => {
      const canvas = document.querySelector('#screen');
      const pixels = canvas.getContext('2d').getImageData(
        0, 0, canvas.width, canvas.height).data;
      const colors = new Set();
      let hash = 0x811c9dc5;
      let opaque = true;
      for (let i = 0; i < pixels.length; i += 4) {
        colors.add(`${pixels[i]},${pixels[i + 1]},${pixels[i + 2]}`);
        opaque &&= pixels[i + 3] === 255;
        hash ^= pixels[i]; hash = Math.imul(hash, 0x01000193);
        hash ^= pixels[i + 1]; hash = Math.imul(hash, 0x01000193);
        hash ^= pixels[i + 2]; hash = Math.imul(hash, 0x01000193);
      }
      return { colors: colors.size, hash: (hash >>> 0).toString(16), opaque };
    });
    if (!sample.opaque || sample.colors < 2 || sample.colors > limits[mode])
      throw new Error(`${label}/${names[mode]} invalid canvas: ${JSON.stringify(sample)}`);
    samples.push(`${names[mode]}=${sample.colors}:${sample.hash}`);
  }
  return `${label}[${samples.join(',')}]`;
}

try {
  await page.goto(url, { waitUntil: 'domcontentloaded' });
  await page.waitForFunction(() => window.__zeliard !== undefined,
    null, { timeout: 120000 });
  await page.waitForSelector('#start:not([hidden])', { timeout: 120000 });
  await page.click('#start');

  const results = [await verifyModes('opening')];
  await page.evaluate(() => {
    const m = window.__zeliard;
    m._zeliard_opening_set_phase_for_test(3);
    m._zeliard_key(13);
    m._zeliard_tick(0);
  });
  await page.waitForFunction(() => window.__zeliard._zeliard_scene() === 2);
  results.push(await verifyModes('town'));

  await page.evaluate(() => {
    window.__zeliard._zeliard_test_enter_room(2);
    window.__zeliard._zeliard_tick(20);
  });
  results.push(await verifyModes('room'));

  await page.evaluate(() => {
    const m = window.__zeliard;
    m._zeliard_test_restart_town(1);
    m._zeliard_key_down(13); m._zeliard_tick(20); m._zeliard_key_up(13);
    m._zeliard_tick(20);
  });
  if (!await page.evaluate(() => window.__zeliard._zeliard_inventory_active()))
    throw new Error('inventory did not open');
  results.push(await verifyModes('inventory'));

  const cavern = await page.evaluate(() => {
    const m = window.__zeliard;
    m._zeliard_key_down(13); m._zeliard_tick(20); m._zeliard_key_up(13);
    m._zeliard_tick(20);
    const started = m._zeliard_test_restart_fight(0, 32, 24, 12);
    for (let i = 0; i < 4; ++i) m._zeliard_tick(20);
    return started && m._zeliard_fight_active();
  });
  if (!cavern) throw new Error('cavern fixture did not start');
  results.push(await verifyModes('cavern'));

  const boss = await page.evaluate(() => {
    const m = window.__zeliard;
    const started = m._zeliard_test_restart_fight(4, 8, 9, 0);
    for (let i = 0; i < 4; ++i) m._zeliard_tick(20);
    return started && m._zeliard_fight_active();
  });
  if (!boss) throw new Error('boss fixture did not start');
  results.push(await verifyModes('boss'));

  const death = await page.evaluate(() => {
    const m = window.__zeliard;
    m._zeliard_test_restart_town(1);
    m._zeliard_test_game_set_u8(0x90, 1);
    m._zeliard_test_game_set_u8(0x91, 0);
    const started = m._zeliard_test_restart_fight(0, 32, 24, 12);
    let ticks = 0;
    while (m._zeliard_room_kind() !== 2 && ticks++ < 1200) {
      m._zeliard_tick(20);
      const track = m._zeliard_music_track();
      if (track >= 0) m._zeliard_music_complete(track);
    }
    return started && m._zeliard_room_kind() === 2;
  });
  if (!death) throw new Error('death/sage fixture did not complete');
  results.push(await verifyModes('death'));

  const ending = await page.evaluate(() => {
    const m = window.__zeliard;
    m._zeliard_test_game_set_u8(0x90, 0xff);
    m._zeliard_test_game_set_u8(0x91, 0);
    const started = m._zeliard_test_restart_fight(0x1e, 4, 21, 12);
    for (let i = 0; i < 12; ++i) m._zeliard_tick(20);
    const defeated = m._zeliard_test_defeat_jashiin();
    let ticks = 0;
    while (!m._zeliard_ending_active() && ticks++ < 400) m._zeliard_tick(20);
    return started && defeated && m._zeliard_ending_active();
  });
  if (!ending) throw new Error('ending fixture did not start');
  results.push(await verifyModes('ending'));

  await page.selectOption('#display-mode', '4');
  const persisted = await page.evaluate(() => ({
    selected: document.querySelector('#display-mode').value,
    stored: localStorage.getItem('zeliard.displayMode'),
  }));
  if (persisted.selected !== '4' || persisted.stored !== '4')
    throw new Error(`display selection did not persist: ${JSON.stringify(persisted)}`);
  if (errors.length) throw new Error(`browser errors: ${JSON.stringify(errors)}`);

  for (const result of results) console.log(result);
  console.log('VERDICT: PASS: all original display choices cover opening, town, room, inventory, cavern, boss, death, and ending');
} finally {
  await browser.close();
}
