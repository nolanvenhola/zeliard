import { chromium } from 'playwright';

const url = process.argv[2] ?? 'http://127.0.0.1:5179/';
const capturePrefix = process.argv[3] ?? '';
const browser = await chromium.launch({ headless: true });

const cases = [
  ['malicia', 0x00, 240, 86],
  ['cangrejo', 0x01, 73, 94],
  ['peligro', 0x02, 224, 87],
  ['malicia-peligro-connector', 0x03, 96, 87],
  ['pulpo', 0x04, 52, 94],
  ['madera', 0x05, 204, 88],
  ['riza', 0x06, 204, 88],
  ['pollo', 0x07, 73, 94],
  ['glacial', 0x08, 320, 89],
  ['escarcha', 0x09, 192, 89],
  ['agar', 0x0a, 73, 94],
  ['corroer', 0x0b, 240, 90],
  ['cementar', 0x0c, 240, 90],
  ['vista', 0x0d, 73, 94],
  ['tesoro', 0x0e, 320, 91],
  ['plata', 0x0f, 256, 91],
  ['arrugia', 0x10, 73, 91],
  ['tarso', 0x11, 73, 94],
  ['caliente', 0x12, 208, 92],
  ['reaccion', 0x13, 196, 92],
  ['correr', 0x14, 128, 92],
  ['reaccion-encounter-connector', 0x15, 73, 94],
  ['dragon', 0x16, 70, 94],
  ['absor', 0x17, 256, 93],
  ['milagro', 0x18, 256, 93],
  ['desleal', 0x19, 192, 93],
  ['falter', 0x1a, 128, 93],
  ['final', 0x1b, 64, 93],
  ['alguien', 0x1c, 70, 94],
  /* MP90 immediately executes the release phase handoff into MPA0. */
  ['jashiin-phase-transition', 0x1d, 73, 96],
  ['jashiin-phase-two', 0x1e, 73, 96],
];

try {
  const results = [];
  for (const [name, selector, expectedWidth, expectedMusic] of cases) {
    /* A separate page gives every selector a new WASM instance.  Some boss
     * and connector maps intentionally alter global ending/loader state. */
    const casePage = await browser.newPage();
    const caseErrors = [];
    casePage.on('pageerror', error => caseErrors.push(error.message));
    await casePage.goto(url, { waitUntil: 'domcontentloaded' });
    await casePage.waitForFunction(() => window.__zeliard !== undefined,
      null, { timeout: 120000 });
    await casePage.waitForSelector('#start:not([hidden])', { timeout: 120000 });
    await casePage.click('#start');
    await casePage.evaluate(() => {
      const m = window.__zeliard;
      m._zeliard_opening_set_phase_for_test(3);
      m._zeliard_key(13);
      m._zeliard_tick(0);
    });
    const result = await casePage.evaluate(({ selector, expectedWidth }) => {
      const m = window.__zeliard;
      /* Match the native/release probe's alive, redraw-ready player record. */
      m._zeliard_test_game_set_u8(0x90, 0x00);
      m._zeliard_test_game_set_u8(0x91, 0x02);
      m._zeliard_test_game_set_u8(0xb2, 0x00);
      m._zeliard_test_game_set_u8(0xb3, 0x02);
      m._zeliard_test_game_set_u8(0xff26, 0xff);
      const started = m._zeliard_test_restart_fight(selector, 4, 21, 12);
      for (let frame = 0; frame < 12; ++frame) m._zeliard_tick(20);
      const pixels = m.HEAPU8.subarray(
        m._zeliard_framebuf(), m._zeliard_framebuf() + 64000);
      let visible = 0;
      for (let y = 0; y < 158; ++y)
        for (let x = 48; x < 272; ++x)
          visible += pixels[y * 320 + x] !== 0;
      const primary = {
        started,
        active: m._zeliard_fight_active(),
        width: m._zeliard_fight_map_width(),
        chunk: m._zeliard_fight_music_chunk(),
        exactAudio: m._zeliard_exact_music_driver(),
        visible,
      };

      /* Survey every authored coordinate band, including wrapped left/right
       * edges and the lower 20 rows that are outside a top-anchored viewport.
       * This catches corrupt tiles/assets that a single entrance fixture can
       * never render.  It is a coordinate survey, not a claim that collision
       * makes every sampled cell player-reachable. */
      const verticalBands = [0, 16, 32, 48, 63];
      let surveySamples = 0;
      let surveyFailures = 0;
      let surveyMinVisible = 64000;
      for (const worldY of verticalBands) {
        for (let worldX = 0; worldX < expectedWidth; worldX += 16) {
          m._zeliard_test_game_set_u8(0x90, 0x00);
          m._zeliard_test_game_set_u8(0x91, 0x02);
          m._zeliard_test_game_set_u8(0xb2, 0x00);
          m._zeliard_test_game_set_u8(0xb3, 0x02);
          m._zeliard_test_game_set_u8(0xff26, 0xff);
          const origin = (worldX + expectedWidth - 16) % expectedWidth;
          const row = (worldY + 64 - 9) & 63;
          const surveyed = m._zeliard_test_restart_fight(
            selector, origin, row, 12);
          const frame = m.HEAPU8.subarray(
            m._zeliard_framebuf(), m._zeliard_framebuf() + 64000);
          let sampleVisible = 0;
          for (let index = 0; index < 320 * 158; ++index)
            sampleVisible += frame[index] !== 0;
          ++surveySamples;
          surveyMinVisible = Math.min(surveyMinVisible, sampleVisible);
          surveyFailures += !surveyed || !m._zeliard_fight_active() ||
            m._zeliard_fight_map_width() !== expectedWidth ||
            sampleVisible < 100;
        }
      }
      return {
        ...primary,
        surveySamples,
        surveyFailures,
        surveyMinVisible,
      };
    }, { selector, expectedWidth });
    results.push({ name, ...result });
    if (capturePrefix)
      await casePage.locator('#screen').screenshot({
        path: `${capturePrefix}-${name}.png`,
      });
    await casePage.close();
    if (caseErrors.length)
      throw new Error(`${name} browser errors: ${JSON.stringify(caseErrors)}`);
    /* 200FIGHT returns FF when a same-family/connector map deliberately
     * inherits the already-playing track instead of issuing a new load. */
    const musicMatches = result.chunk === expectedMusic || result.chunk === 255;
    if (!result.started || !result.active || result.width !== expectedWidth ||
        !musicMatches || !result.exactAudio ||
        result.visible < 1000 || result.surveyFailures !== 0)
      throw new Error(`${name} browser parity failed: ${JSON.stringify(result)}`);
  }
  console.log(`remaining_caverns_browser: PASS ${JSON.stringify(results)}`);
  console.log('VERDICT: PASS: all 31 release cavern selectors render through WASM with exact audio');
} finally {
  await browser.close();
}
