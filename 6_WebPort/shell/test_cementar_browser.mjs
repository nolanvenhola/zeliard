import { chromium } from 'playwright';

const url = process.argv[2] ?? 'http://127.0.0.1:5177/';
const capturePrefix = process.argv[3] ?? '';
const browser = await chromium.launch({ headless: true });
const page = await browser.newPage();
const errors = [];
page.on('pageerror', error => errors.push(error.message));
page.on('console', message => {
  if (message.type() === 'error')
    console.log(`browser:${message.type()}: ${message.text()}`);
});

try {
  await page.goto(url, { waitUntil: 'domcontentloaded' });
  await page.waitForFunction(() => window.__zeliard !== undefined,
    null, { timeout: 120000 });
  await page.waitForSelector('#start:not([hidden])', { timeout: 120000 });
  await page.click('#start');

  const entry = await page.evaluate(() => {
    const m = window.__zeliard;
    m._zeliard_opening_set_phase_for_test(3);
    m._zeliard_key(13);
    m._zeliard_tick(0);
    const started = m._zeliard_test_restart_fight(
      12, 88 - 16, (34 - 9) & 0x3f, 12);
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
      music: m._zeliard_music_track(),
      exactAudio: m._zeliard_exact_music_driver(),
      visible,
    };
  });

  const boss = await page.evaluate(() => {
    const m = window.__zeliard;
    m._zeliard_test_game_set_u8(0x98, 1);
    const started = m._zeliard_test_restart_fight(
      12, 157 - 16, (16 - 9) & 0x3f, 12);
    m._zeliard_key_down(38);
    let ticks = 0;
    let encounterStart = 0;
    let encounterFinish = 0;
    let sawBossMusic = false;
    while (m._zeliard_fight_active() && ticks++ < 2200) {
      if (encounterStart) m._zeliard_key_up(38);
      m._zeliard_tick(20);
      if (!encounterStart && m._zeliard_fight_map_width() === 73)
        encounterStart = ticks;
      sawBossMusic ||= m._zeliard_fight_music_chunk() === 94;
      if (encounterStart && !encounterFinish &&
          m._zeliard_fight_ip() === 0x629c) {
        encounterFinish = ticks;
        break;
      }
    }
    m._zeliard_key_up(38);
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
      music: m._zeliard_music_track(),
      encounterStart, encounterFinish, sawBossMusic, ticks, visible,
      intro: m._zeliard_test_game_u8(0xC3),
    };
  });

  if (capturePrefix) {
    await page.waitForTimeout(100);
    await page.locator('#screen').screenshot({
      path: `${capturePrefix}-vista.png`,
    });
    await page.evaluate(() => {
      const m = window.__zeliard;
      m._zeliard_test_restart_fight(12, 88 - 16, (34 - 9) & 0x3f, 12);
      for (let frame = 0; frame < 12; ++frame) m._zeliard_tick(20);
    });
    await page.waitForTimeout(100);
    await page.locator('#screen').screenshot({
      path: `${capturePrefix}-cementar.png`,
    });
  }

  if (!entry.started || !entry.active || entry.width !== 240 ||
      entry.chunk !== 90 || entry.music !== 13 || !entry.exactAudio ||
      entry.visible < 1000 || !boss.started || !boss.active ||
      boss.width !== 73 || boss.chunk !== 94 || !boss.sawBossMusic ||
      !boss.encounterStart || !boss.encounterFinish || boss.intro !== 0 ||
      boss.visible < 1000)
    throw new Error(`Cementar browser parity failed: ${JSON.stringify({entry, boss})}`);
  if (errors.length)
    throw new Error(`browser errors: ${JSON.stringify(errors)}`);
  console.log(`cementar_browser: PASS width=${entry.width} ` +
    `music=${entry.chunk}/${entry.music} visible=${entry.visible}`);
  console.log(`vista_encounter_browser: PASS ticks=${boss.ticks} ` +
    `start=${boss.encounterStart} finish=${boss.encounterFinish} ` +
    `music=${boss.chunk}/${boss.music} visible=${boss.visible}`);
  console.log('VERDICT: PASS: Cementar runtime and exact Vista entrance');
} finally {
  await browser.close();
}
