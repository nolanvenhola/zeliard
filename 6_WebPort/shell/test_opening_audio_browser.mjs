import { chromium } from 'playwright';

const url = process.argv[2] ?? 'http://127.0.0.1:4173/zeliard/';
const browser = await chromium.launch({ headless: true });
const page = await browser.newPage();
const audioResponses = [];
const consoleMessages = [];
const pageErrors = [];

const pressSampledKey = (key) => page.evaluate((sampledKey) => {
  const module = window.__zeliard;
  /* Give stick.asm's released-key latch an idle sample before the make edge,
   * matching the compatibility pulse and real held-key path. */
  module._zeliard_tick(50);
  window.dispatchEvent(new KeyboardEvent('keydown', { key: sampledKey }));
  module._zeliard_tick(25);
  window.dispatchEvent(new KeyboardEvent('keyup', { key: sampledKey }));
}, key);

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
  const exactDriver = await page.evaluate(
    () => window.__zeliard._zeliard_exact_music_driver());
  if (exactDriver !== 1)
    throw new Error(`original MSCADLIB runtime unavailable: ${exactDriver}`);
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

  const pauseProbeBefore = await page.evaluate(() => {
    const module = window.__zeliard;
    const ptr = module._zeliard_framebuf();
    const bytes = [];
    for (let y = 30; y < 46; y++)
      for (let x = 128; x < 192; x++)
        bytes.push(module.HEAPU8[ptr + y * 320 + x]);
    window.dispatchEvent(new KeyboardEvent('keydown', { key: 'Escape' }));
    return { bytes, oplWrites: module._zeliard_audio_opl_write_count() };
  });
  const pauseRegionBefore = pauseProbeBefore.bytes;
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
    oplWrites: window.__zeliard._zeliard_audio_opl_write_count(),
  }));
  await page.evaluate(() =>
    window.dispatchEvent(new KeyboardEvent('keyup', { key: 'Escape' })));
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
  if (pauseStart.oplWrites <= pauseProbeBefore.oplWrites)
    throw new Error(`ESC pause did not execute SNDADLIB cue 02h: ${JSON.stringify({ pauseProbeBefore, pauseStart })}`);

  const phaseBeforeUnpause = await page.evaluate(() => window.__zeliard._zeliard_phase());
  const pauseRestore = await page.evaluate(() => {
    const module = window.__zeliard;
    /* Drive the real shell key handlers, then consume the key and capture the
     * restored region in the same browser task.  A normal Playwright press can
     * be observed before the five-PIT-tick input sampler runs, or after the
     * next animated opening frame has legitimately changed these pixels. */
    window.dispatchEvent(new KeyboardEvent('keydown', { key: ' ' }));
    module._zeliard_tick(25);
    window.dispatchEvent(new KeyboardEvent('keyup', { key: ' ' }));
    const ptr = module._zeliard_framebuf();
    const bytes = [];
    for (let y = 30; y < 46; y++)
      for (let x = 128; x < 192; x++)
        bytes.push(module.HEAPU8[ptr + y * 320 + x]);
    return {
      bytes,
      paused: module._zeliard_paused(),
      phase: module._zeliard_phase(),
      elapsed: module._zeliard_phase_elapsed(),
    };
  });
  if (pauseRestore.paused !== 0 || pauseRestore.phase !== phaseBeforeUnpause ||
      pauseRestore.elapsed !== pauseEnd.elapsed)
    throw new Error(`Space did not restore at the paused tick: ${JSON.stringify(pauseRestore)}`);
  if (pauseRestore.bytes.some((value, index) => value !== pauseRegionBefore[index]))
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
  await pressSampledKey('F1');
  const musicOff = await page.evaluate(() => window.__zeliard._zeliard_music_enabled());
  await pressSampledKey('F1');
  const musicOn = await page.evaluate(() => window.__zeliard._zeliard_music_enabled());
  if (musicOff !== 0 || musicOn !== 1)
    throw new Error(`F1 music toggle mismatch: ${musicOff}->${musicOn}`);

  await pressSampledKey('F2');
  const soundOff = await page.evaluate(() => window.__zeliard._zeliard_sound_enabled());
  await pressSampledKey('F2');
  const soundOn = await page.evaluate(() => window.__zeliard._zeliard_sound_enabled());
  if (soundOff !== 0 || soundOn !== 1)
    throw new Error(`F2 sound toggle mismatch: ${soundOff}->${soundOn}`);

  const dmaouWrites = await page.evaluate(() => {
    const before = window.__zeliard._zeliard_audio_opl_write_count();
    window.__zeliard._zeliard_opening_set_phase_for_test(21);
    return before;
  });
  await page.waitForTimeout(250);
  const dmaouWritesAfter = await page.evaluate(
    () => window.__zeliard._zeliard_audio_opl_write_count());
  if (dmaouWritesAfter <= dmaouWrites)
    throw new Error(`DMAOU animation did not execute SNDADLIB cue 04h: ${dmaouWrites}->${dmaouWritesAfter}`);

  const princessWrites = await page.evaluate(() => {
    const before = window.__zeliard._zeliard_audio_opl_write_count();
    window.__zeliard._zeliard_opening_set_phase_for_test(3);
    window.__zeliard._zeliard_tick(66000);
    return before;
  });
  await page.waitForTimeout(100);
  const princessWritesAfter = await page.evaluate(
    () => window.__zeliard._zeliard_audio_opl_write_count());
  if (princessWritesAfter <= princessWrites)
    throw new Error(`Princess text did not execute SNDADLIB cue 41h: ${princessWrites}->${princessWritesAfter}`);

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
    await page.waitForTimeout(2000);
    const stream = await page.evaluate(() => ({
      ...window.__zeliardAudioStats,
      exactDriver: window.__zeliard._zeliard_exact_music_driver(),
      track: window.__zeliard._zeliard_music_track(),
      oplWrites: window.__zeliard._zeliard_audio_opl_write_count(),
      generatedPeak: window.__zeliard._zeliard_audio_generated_peak(),
    }));
    if (stream.contextState !== 'running' || stream.callbacks < 20 ||
        stream.deliveredPeak <= 256 || stream.deliveredNonzero <= 100 ||
        stream.bufferedFrames <= 0 ||
        stream.exactDriver !== 1 || stream.track !== expected)
      throw new Error(`live WebAudio stream stopped: ${JSON.stringify(stream)}`);
    console.log(`opening_audio_browser: track ${expected} stream ${JSON.stringify(stream)}`);
    await page.waitForTimeout(3000);
    const steadyStream = await page.evaluate(() => ({ ...window.__zeliardAudioStats }));
    // Chromium can request a few callbacks before the freshly selected track
    // has primed its worklet buffer.  Treat that bounded startup history as
    // acceptable, but require zero additional underruns once audio is live.
    if (steadyStream.underrunFrames !== stream.underrunFrames)
      throw new Error(`live WebAudio stream underrun after priming: ${JSON.stringify({ stream, steadyStream })}`);
  }

  await page.keyboard.press('Enter');
  await page.waitForTimeout(100);
  const creditsWait = await page.evaluate(() => ({
    track: window.__zeliard._zeliard_music_track(),
    phase: window.__zeliard._zeliard_phase(),
    attenuation: window.__zeliard._zeliard_music_attenuation(),
  }));
  if (creditsWait.track !== 2 || creditsWait.phase !== 2)
    throw new Error(`credits Enter skip did not wait for zend completion: ${JSON.stringify(creditsWait)}`);
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
  const recordedMusic = audioResponses.filter((response) =>
    response.url.endsWith('/zopn.ogg') || response.url.endsWith('/zend.ogg'));
  if (audioResponses.length !== 0 || failedAudio.length !== 0 || recordedMusic.length !== 0)
    throw new Error(`audio responses: ${JSON.stringify(audioResponses)}`);

  console.log(`opening_audio_browser: PASS tracks=${tracks.join('->')} exact_drivers=1 audio_http=0`);
  console.log('VERDICT: PASS: opening audio browser parity');
} catch (error) {
  console.error(JSON.stringify({ pageErrors, consoleMessages, audioResponses }, null, 2));
  throw error;
} finally {
  await browser.close();
}
