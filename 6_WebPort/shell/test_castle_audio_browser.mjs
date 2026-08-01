import { chromium } from 'playwright';

const url = process.argv[2] ?? 'http://127.0.0.1:4173/zeliard/';
const browser = await chromium.launch({ headless: true });
const page = await browser.newPage();
const pageErrors = [];
const recordedAudio = [];

page.on('pageerror', (error) => pageErrors.push(error.message));
page.on('response', (response) => {
  if (/\.(ogg|wav)(\?|$)/i.test(response.url()))
    recordedAudio.push(response.url());
});

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
  await page.waitForFunction(() =>
    window.__zeliard._zeliard_scene() === 2 &&
    window.__zeliard._zeliard_music_track() === 3,
  null, { timeout: 5000 });

  const writesAtStart = await page.evaluate(() =>
    window.__zeliard._zeliard_audio_opl_write_count());
  await page.waitForTimeout(2000);
  const running = await page.evaluate(() => ({
    ...window.__zeliardAudioStats,
    scene: window.__zeliard._zeliard_scene(),
    track: window.__zeliard._zeliard_music_track(),
    exactDriver: window.__zeliard._zeliard_exact_music_driver(),
    oplWrites: window.__zeliard._zeliard_audio_opl_write_count(),
  }));
  if (running.scene !== 2 || running.track !== 3 ||
      running.exactDriver !== 1 || running.oplWrites <= writesAtStart ||
      running.contextState !== 'running' || running.deliveredPeak <= 256 ||
      running.deliveredNonzero <= 100)
    throw new Error(`castle MGT1 stream did not run: ${JSON.stringify(running)}`);

  const beforeCue = await page.evaluate(() => ({
    underruns: window.__zeliardAudioStats.underrunFrames,
    serial: window.__zeliardAudioStats.cueSerial,
  }));
  const dialogCue = await page.evaluate(() => {
    const module = window.__zeliard;
    module._zeliard_key_down(39);
    module._zeliard_tick(90);
    module._zeliard_key_up(39);
    module._zeliard_tick(90);
    module._zeliard_key_down(32);
    module._zeliard_tick(90);
    module._zeliard_key_up(32);
    module._zeliard_tick(90);
    return module._zeliard_sound_cue();
  });
  await page.waitForFunction((serial) =>
    window.__zeliardAudioStats.cueSerial > serial,
  beforeCue.serial, { timeout: 1000 });
  await page.waitForTimeout(250);
  const afterCue = await page.evaluate(() => ({
    underruns: window.__zeliardAudioStats.underrunFrames,
    serial: window.__zeliardAudioStats.cueSerial,
  }));
  if (dialogCue !== 0x1E || afterCue.underruns !== beforeCue.underruns)
    throw new Error(`dialog SFX interrupted castle music: ${JSON.stringify({
      dialogCue, beforeCue, afterCue,
    })}`);

  await page.evaluate(() => window.__zeliard._zeliard_key(112));
  const muted = await page.evaluate(() => ({
    enabled: window.__zeliard._zeliard_music_enabled(),
    track: window.__zeliard._zeliard_music_track(),
  }));
  await page.evaluate(() => window.__zeliard._zeliard_key(112));
  const restored = await page.evaluate(() => ({
    enabled: window.__zeliard._zeliard_music_enabled(),
    track: window.__zeliard._zeliard_music_track(),
  }));
  if (muted.enabled !== 0 || muted.track !== 3 ||
      restored.enabled !== 1 || restored.track !== 3)
    throw new Error(`castle F1 state mismatch: ${JSON.stringify({ muted, restored })}`);

  if (pageErrors.length || recordedAudio.length)
    throw new Error(`browser errors or recorded audio fallback: ${JSON.stringify({ pageErrors, recordedAudio })}`);
  console.log(`castle_audio_browser: PASS track=3 writes=${running.oplWrites} peak=${running.deliveredPeak} cue=1e underruns=${afterCue.underruns}`);
  console.log('VERDICT: PASS: exact MSCADLIB castle browser audio');
} finally {
  await browser.close();
}
