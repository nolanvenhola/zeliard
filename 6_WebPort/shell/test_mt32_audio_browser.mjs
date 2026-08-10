import { chromium } from 'playwright';

const url = process.argv[2] ?? 'http://127.0.0.1:5179/';
const browser = await chromium.launch({ headless: true });
const page = await browser.newPage();
const pageErrors = [];
page.on('pageerror', (error) => pageErrors.push(error.message));

try {
  await page.goto(url, { waitUntil: 'domcontentloaded' });
  await page.waitForFunction(() => window.__zeliard !== undefined,
    null, { timeout: 120000 });
  await page.selectOption('#audio-backend', '1');
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
  await page.waitForTimeout(1000);

  const before = await page.evaluate(() => ({
    backend: window.__zeliard._zeliard_audio_backend(),
    fallback: window.__zeliard._zeliard_audio_backend_fallback(),
    oplWrites: window.__zeliard._zeliard_audio_opl_write_count(),
    underruns: window.__zeliardAudioStats.underrunFrames,
    peak: window.__zeliardAudioStats.deliveredPeak,
    serial: window.__zeliardAudioStats.cueSerial,
  }));
  const cue = await page.evaluate(() => {
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
  before.serial, { timeout: 1000 });
  await page.waitForTimeout(300);
  const after = await page.evaluate(() => ({
    oplWrites: window.__zeliard._zeliard_audio_opl_write_count(),
    underruns: window.__zeliardAudioStats.underrunFrames,
    peak: window.__zeliardAudioStats.deliveredPeak,
  }));

  if (before.backend !== 1 || before.fallback !== 0 || before.peak <= 256 ||
      cue !== 0x1e || after.oplWrites <= before.oplWrites ||
      after.underruns !== before.underruns || pageErrors.length)
    throw new Error(`MT-32 browser stream mismatch: ${JSON.stringify({
      before, cue, after, pageErrors,
    })}`);
  console.log(`mt32_audio_browser: PASS cue=1e opl=${before.oplWrites}->${after.oplWrites} peak=${after.peak} underruns=${after.underruns}`);
  console.log('VERDICT: PASS: MT-32 music and SNDADLIB effects share clean PCM');
} finally {
  await browser.close();
}
