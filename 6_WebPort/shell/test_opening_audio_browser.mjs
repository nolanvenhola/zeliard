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

  const failedAudio = audioResponses.filter((response) => response.status !== 200);
  if (audioResponses.length !== 2 || failedAudio.length !== 0)
    throw new Error(`audio responses: ${JSON.stringify(audioResponses)}`);

  for (const track of [1, 2]) {
    if (!consoleMessages.includes(`[zeliard] MASM music load: track ${track}`))
      throw new Error(`browser audio proxy did not start track ${track}`);
  }

  console.log(`opening_audio_browser: PASS tracks=${tracks.join('->')} audio_http=200,200`);
  console.log('VERDICT: PASS: opening audio browser parity');
} catch (error) {
  console.error(JSON.stringify({ pageErrors, consoleMessages, audioResponses }, null, 2));
  throw error;
} finally {
  await browser.close();
}
