import { chromium } from 'playwright';

const url = process.argv[2] ?? 'http://127.0.0.1:4173/zeliard/';
const browser = await chromium.launch({ headless: true });
const page = await browser.newPage();
const audioResponses = [];
const consoleMessages = [];
const pageErrors = [];

page.on('response', (response) => {
  if (response.url().includes('/audio/'))
    audioResponses.push({ status: response.status(), url: response.url() });
});
page.on('console', (message) => consoleMessages.push(message.text()));
page.on('pageerror', (error) => pageErrors.push(error.message));

try {
  await page.goto(url, { waitUntil: 'domcontentloaded' });
  console.log('opening_audio_browser: DOM ready');
  await page.waitForFunction(() => window.__zeliard !== undefined, null, { timeout: 120000 });
  console.log('opening_audio_browser: WASM ready');
  await page.waitForSelector('#start:not([hidden])', { timeout: 120000 });
  console.log('opening_audio_browser: audio assets ready');

  const before = await page.evaluate(() => ({
    elapsed: window.__zeliard._zeliard_phase_elapsed(),
    track: window.__zeliard._zeliard_music_track(),
  }));
  await page.waitForTimeout(250);
  const pausedElapsed = await page.evaluate(
    () => window.__zeliard._zeliard_phase_elapsed(),
  );
  if (pausedElapsed !== before.elapsed)
    throw new Error(`opening advanced before activation: ${before.elapsed} -> ${pausedElapsed}`);

  await page.click('#start');
  console.log('opening_audio_browser: activated');
  await page.waitForTimeout(250);
  const startedElapsed = await page.evaluate(
    () => window.__zeliard._zeliard_phase_elapsed(),
  );
  if (startedElapsed <= pausedElapsed)
    throw new Error(`opening did not advance after activation: ${startedElapsed}`);

  const pauseRegionBefore = await page.evaluate(() => {
    const module = window.__zeliard;
    const ptr = module._zeliard_framebuf();
    const bytes = [];
    for (let y = 30; y < 46; y++)
      for (let x = 128; x < 192; x++)
        bytes.push(module.HEAPU8[ptr + y * 320 + x]);
    return bytes;
  });
  await page.keyboard.press('Escape');
  await page.waitForTimeout(100);
  const pauseStart = await page.evaluate(() => ({
    paused: window.__zeliard._zeliard_paused(),
    elapsed: window.__zeliard._zeliard_phase_elapsed(),
    borderTopLeft: window.__zeliard.HEAPU8[
      window.__zeliard._zeliard_framebuf() + 30 * 320 + 128],
    borderBottomRight: window.__zeliard.HEAPU8[
      window.__zeliard._zeliard_framebuf() + 45 * 320 + 191],
    interior: window.__zeliard.HEAPU8[
      window.__zeliard._zeliard_framebuf() + 33 * 320 + 130],
  }));
  await page.waitForTimeout(250);
  const pauseEnd = await page.evaluate(() => ({
    paused: window.__zeliard._zeliard_paused(),
    elapsed: window.__zeliard._zeliard_phase_elapsed(),
  }));
  if (pauseStart.paused !== 1 || pauseEnd.paused !== 1 ||
      pauseStart.elapsed !== pauseEnd.elapsed)
    throw new Error(`ESC pause did not freeze opening: ${JSON.stringify({ pauseStart, pauseEnd })}`);
  if (pauseStart.borderTopLeft !== 0xFF || pauseStart.borderBottomRight !== 0xFF ||
      pauseStart.interior !== 0)
    throw new Error(`MASM PAUSE box pixels mismatch: ${JSON.stringify(pauseStart)}`);
  if (!consoleMessages.includes('[zeliard] MASM SNDADLIB cue: 2'))
    throw new Error('ESC pause did not play MASM SNDADLIB cue 02h');

  const phaseBeforeUnpause = await page.evaluate(() => window.__zeliard._zeliard_phase());
  await page.keyboard.press('Space');
  const pauseRegionAfter = await page.evaluate(() => {
    const module = window.__zeliard;
    const ptr = module._zeliard_framebuf();
    const bytes = [];
    for (let y = 30; y < 46; y++)
      for (let x = 128; x < 192; x++)
        bytes.push(module.HEAPU8[ptr + y * 320 + x]);
    return bytes;
  });
  if (pauseRegionAfter.some((value, index) => value !== pauseRegionBefore[index]))
    throw new Error('MASM PAUSE box did not restore its saved framebuffer region');
  await page.waitForTimeout(150);
  const afterUnpause = await page.evaluate(() => ({
    paused: window.__zeliard._zeliard_paused(),
    phase: window.__zeliard._zeliard_phase(),
    elapsed: window.__zeliard._zeliard_phase_elapsed(),
  }));
  if (afterUnpause.paused !== 0 || afterUnpause.phase !== phaseBeforeUnpause ||
      afterUnpause.elapsed <= pauseEnd.elapsed)
    throw new Error(`Space did not exclusively unpause: ${JSON.stringify(afterUnpause)}`);
  await page.keyboard.press('F1');
  const musicOff = await page.evaluate(() => window.__zeliard._zeliard_music_enabled());
  await page.keyboard.press('F1');
  const musicOn = await page.evaluate(() => window.__zeliard._zeliard_music_enabled());
  if (musicOff !== 0 || musicOn !== 1)
    throw new Error(`F1 music toggle mismatch: ${musicOff}->${musicOn}`);

  await page.keyboard.press('F2');
  const soundOff = await page.evaluate(() => window.__zeliard._zeliard_sound_enabled());
  await page.keyboard.press('F2');
  const soundOn = await page.evaluate(() => window.__zeliard._zeliard_sound_enabled());
  if (soundOff !== 0 || soundOn !== 1)
    throw new Error(`F2 sound toggle mismatch: ${soundOff}->${soundOn}`);

  await page.evaluate(() =>
    window.__zeliard._zeliard_opening_set_phase_for_test(21));
  await page.waitForTimeout(100);
  if (!consoleMessages.includes('[zeliard] MASM SNDADLIB cue: 4'))
    throw new Error('DMAOU animation did not play MASM cue 04');

  await page.evaluate(() => {
    window.__zeliard._zeliard_opening_set_phase_for_test(3);
    window.__zeliard._zeliard_tick(66000);
  });
  await page.waitForTimeout(100);
  if (!consoleMessages.includes('[zeliard] MASM SNDADLIB cue: 65'))
    throw new Error('Princess text did not play MASM cue 41h');

  const tracks = [before.track];
  for (const expected of [1, 2]) {
    const phase = expected === 1 ? 22 : 2;
    const actual = await page.evaluate((nextPhase) => {
      window.__zeliard._zeliard_opening_set_phase_for_test(nextPhase);
      return window.__zeliard._zeliard_music_track();
    }, phase);
    if (actual !== expected)
      throw new Error(`MASM phase ${phase} selected music track ${actual}, expected ${expected}`);
    tracks.push(expected);
    console.log(`opening_audio_browser: selected track ${expected}`);
    await page.waitForTimeout(50);
  }

  const track2StartsBefore = consoleMessages.filter((message) =>
    message.startsWith('[zeliard] MASM music resume: track 2 @ ')).length;
  await page.keyboard.press('Enter');
  await page.waitForTimeout(100);
  const creditsWait = await page.evaluate(() => ({
    track: window.__zeliard._zeliard_music_track(),
    phase: window.__zeliard._zeliard_phase(),
    attenuation: window.__zeliard._zeliard_music_attenuation(),
  }));
  if (creditsWait.track !== 2 || creditsWait.phase !== 2)
    throw new Error(`credits Enter skip did not wait for zend completion: ${JSON.stringify(creditsWait)}`);
  const track2StartsAfter = consoleMessages.filter((message) =>
    message.startsWith('[zeliard] MASM music resume: track 2 @ ')).length;
  if (track2StartsAfter !== track2StartsBefore)
    throw new Error('credits Enter skip restarted zend playback');

  await page.waitForFunction(
    () => window.__zeliard._zeliard_music_attenuation() > 0 &&
          window.__zeliard._zeliard_music_attenuation() < 64,
    { timeout: 1000 });
  await page.waitForFunction(
    () => window.__zeliard._zeliard_phase() === 3,
    { timeout: 6000 });
  const princessHandoff = await page.evaluate(() => ({
    track: window.__zeliard._zeliard_music_track(),
    phase: window.__zeliard._zeliard_phase(),
  }));
  if (princessHandoff.track !== 0 || princessHandoff.phase !== 3)
    throw new Error(`zend completion did not release princess setup: ${JSON.stringify(princessHandoff)}`);

  const failedAudio = audioResponses.filter((response) => response.status !== 200);
  if (audioResponses.length !== 9 || failedAudio.length !== 0)
    throw new Error(`audio responses: ${JSON.stringify(audioResponses)}`);

  for (const track of [1, 2]) {
    if (!consoleMessages.some((message) =>
      message.startsWith(`[zeliard] MASM music resume: track ${track} @ `)))
      throw new Error(`browser audio proxy did not start track ${track}`);
  }

  console.log(`opening_audio_browser: PASS tracks=${tracks.join('->')} audio_http=9x200`);
  console.log('VERDICT: PASS: opening audio browser parity');
} catch (error) {
  console.error(JSON.stringify({ pageErrors, consoleMessages, audioResponses }, null, 2));
  throw error;
} finally {
  await browser.close();
}
