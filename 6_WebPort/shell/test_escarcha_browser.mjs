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

  const result = await page.evaluate(() => {
    const m = window.__zeliard;
    m._zeliard_opening_set_phase_for_test(3);
    m._zeliard_key(13);
    m._zeliard_tick(0);
    m._zeliard_key_down(39);
    let townTicks = 0;
    while (m._zeliard_town_area() !== 1 && townTicks++ < 3000)
      m._zeliard_tick(20);
    m._zeliard_key_up(39);

    const started = m._zeliard_test_restart_fight(
      9, 16 - 16, (21 - 9) & 0x3f, 12);
    for (let frame = 0; frame < 10; ++frame) m._zeliard_tick(20);
    const pixels = m.HEAPU8.subarray(
      m._zeliard_framebuf(), m._zeliard_framebuf() + 64000);
    let visible = 0;
    for (let y = 0; y < 158; ++y)
      for (let x = 48; x < 272; ++x)
        visible += pixels[y * 320 + x] !== 0;
    const entry = {
      started,
      active: m._zeliard_fight_active(),
      width: m._zeliard_fight_map_width(),
      chunk: m._zeliard_fight_music_chunk(),
      music: m._zeliard_music_track(),
      exactAudio: m._zeliard_exact_music_driver(),
      visible,
    };

    /* Exercise the paired MP41 x56/y55 -> MP40 x22/y9 door and return
       without restarting the resident 200FIGHT VM. */
    m._zeliard_test_restart_fight(9, 56 - 16, (55 - 9) & 0x3f, 12);
    m._zeliard_test_game_set_u8(0xC3, 0xff);
    m._zeliard_key_down(38);
    let forwardTicks = 0;
    while (m._zeliard_fight_map_width() !== 320 && forwardTicks++ < 200)
      m._zeliard_tick(20);
    m._zeliard_key_up(38);
    const forwardWidth = m._zeliard_fight_map_width();
    m._zeliard_test_game_set_u8(0x80, 22 - 16);
    m._zeliard_test_game_set_u8(0x81, 0);
    m._zeliard_test_game_set_u8(0x82, 0);
    m._zeliard_key_down(38);
    let returnTicks = 0;
    while (m._zeliard_fight_map_width() !== 192 && returnTicks++ < 200)
      m._zeliard_tick(20);
    m._zeliard_key_up(38);
    const returnWidth = m._zeliard_fight_map_width();

    const slide = selectedAccessory => {
      m._zeliard_test_game_set_u8(0x9E, selectedAccessory);
      if (selectedAccessory === 4) m._zeliard_test_game_set_u8(0xA1, 4);
      m._zeliard_test_restart_fight(
        9, 16 - 16, (21 - 9) & 0x3f, 12);
      for (let settle = 0; settle < 5; ++settle) m._zeliard_tick(20);
      m._zeliard_key_down(39);
      for (let tick = 0; tick < 20; ++tick) m._zeliard_tick(20);
      m._zeliard_key_up(39);
      for (let tick = 0; tick < 40; ++tick) m._zeliard_tick(20);
      return m._zeliard_test_game_u8(0x80) |
        (m._zeliard_test_game_u8(0x81) << 8);
    };
    const bareX = slide(0);
    const shoesX = slide(4);
    /* Leave the capture on a settled Escarcha entry frame rather than the
       tail of the synthetic inertia comparison. */
    m._zeliard_test_restart_fight(
      9, 16 - 16, (21 - 9) & 0x3f, 12);
    for (let settle = 0; settle < 10; ++settle) m._zeliard_tick(20);
    return {
      entry, townTicks, forwardTicks, returnTicks, forwardWidth, returnWidth,
      bareX, shoesX,
      finalChunk: m._zeliard_fight_music_chunk(),
      finalMusic: m._zeliard_music_track(),
    };
  });

  if (capturePrefix) {
    await page.locator('#screen').screenshot({
      path: `${capturePrefix}-escarcha.png`,
    });
  }
  if (!result.entry.started || !result.entry.active ||
      result.entry.width !== 192 || result.entry.chunk !== 89 ||
      result.entry.music !== 12 || !result.entry.exactAudio ||
      result.entry.visible < 1000 || result.forwardWidth !== 320 ||
      result.returnWidth !== 192 || result.bareX === result.shoesX ||
      result.finalMusic !== 12)
    throw new Error(`Escarcha browser parity failed: ${JSON.stringify(result)}`);
  if (errors.length)
    throw new Error(`browser errors: ${JSON.stringify(errors)}`);
  console.log(`escarcha_browser: PASS width=${result.entry.width} ` +
    `music=${result.entry.chunk}/${result.entry.music} ` +
    `visible=${result.entry.visible} route=${result.forwardWidth}>${result.returnWidth} ` +
    `slide=${result.bareX}/${result.shoesX}`);
  console.log('VERDICT: PASS: Helada -> Escarcha ice runtime and reverse route');
} finally {
  await browser.close();
}
