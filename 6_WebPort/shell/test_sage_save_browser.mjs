import { chromium } from 'playwright';
import { readFile } from 'node:fs/promises';

const url = process.argv[2] ?? 'http://127.0.0.1:5177/';
const browser = await chromium.launch({ headless: true });
const page = await browser.newPage();
const pageErrors = [];
page.on('pageerror', (error) => pageErrors.push(error.message));

async function tick(ms) {
  await page.evaluate((duration) => {
    const module = window.__zeliard;
    for (let elapsed = 0; elapsed < duration; elapsed += 5)
      module._zeliard_tick(Math.min(5, duration - elapsed));
  }, ms);
}

async function pulse(keycode) {
  await page.evaluate((key) => window.__zeliard._zeliard_key_down(key), keycode);
  await tick(keycode === 40 ? 5 : 20);
  await page.evaluate((key) => window.__zeliard._zeliard_key_up(key), keycode);
  let sawBusy = false;
  for (let wait = 0; wait < 1200; ++wait) {
    await tick(5);
    const input = await page.evaluate(() =>
      ({ kind: window.__zeliard._zeliard_room_input_kind(),
        terminated: window.__zeliard._zeliard_session_terminated() }));
    if (input.terminated) break;
    sawBusy ||= input.kind === 0;
    if (sawBusy && input.kind !== 0) break;
  }
}

function assert(condition, message, value) {
  if (!condition) throw new Error(`${message}: ${JSON.stringify(value)}`);
}

try {
  await page.goto(url, { waitUntil: 'domcontentloaded' });
  await page.waitForFunction(() => window.__zeliard !== undefined,
    null, { timeout: 120000 });
  await page.evaluate(() => localStorage.clear());
  await page.click('#start');
  await page.evaluate(() => {
    const module = window.__zeliard;
    module._zeliard_opening_set_phase_for_test(3);
    module._zeliard_key(13);
    module._zeliard_tick(0);
    module._zeliard_test_game_set_u8(0x80, 0x20);
    module._zeliard_test_game_set_u8(0x81, 0x00);
    module._zeliard_test_game_set_u8(0x83, 0x10);
    module._zeliard_test_game_set_u8(0xC4, 0x81);
    module._zeliard_test_enter_room(2);
  });
  await page.waitForFunction(() => window.__zeliard._zeliard_room_kind() === 2,
    null, { timeout: 5000 });
  for (let prompt = 0; prompt < 80; ++prompt) {
    const kind = await page.evaluate(() =>
      window.__zeliard._zeliard_room_input_kind());
    if (kind === 1) break;
    if (kind !== 0) await pulse(32);
    else await tick(100);
  }
  assert(await page.evaluate(() =>
    window.__zeliard._zeliard_room_input_kind()) === 1,
    'Sage main menu was not reached');

  for (let row = 0; row < 3; ++row) await pulse(40);
  await pulse(32);
  for (let prompt = 0; prompt < 80; ++prompt) {
    const kind = await page.evaluate(() =>
      window.__zeliard._zeliard_room_input_kind());
    if (kind === 3) break;
    if (kind !== 0) await pulse(32);
    else await tick(100);
  }
  const nameInput = await page.evaluate(() => ({
    kind: window.__zeliard._zeliard_room_input_kind(),
    ip: window.__zeliard._zeliard_room_ip(),
    script: window.__zeliard._zeliard_test_game_u16(0xFF4C),
    row: window.__zeliard._zeliard_test_game_u8(0xBB14),
    locked: window.__zeliard._zeliard_test_game_u8(0xFF74),
  }));
  assert(nameInput.kind === 3, 'Sage name editor was not reached', nameInput);

  for (const character of 'CODEX') {
    await page.evaluate((ascii) =>
      window.__zeliard._zeliard_text_key(ascii), character.charCodeAt(0));
    await tick(40);
  }
  const serialBefore = await page.evaluate(() =>
    window.__zeliard._zeliard_save_serial());
  const downloadPromise = page.waitForEvent('download');
  await pulse(13);
  const download = await downloadPromise;
  const downloadPath = await download.path();
  const downloadedRecord = await readFile(downloadPath);
  await page.waitForFunction((serial) =>
    window.__zeliard._zeliard_save_serial() === serial + 1,
    serialBefore, { timeout: 30000 });
  await page.waitForFunction(() => !document.querySelector('#save-controls').hidden,
    null, { timeout: 5000 });
  await page.waitForFunction(() =>
    window.__zeliard._zeliard_room_input_kind() === 1,
    null, { timeout: 30000 });

  const continuePrompt = await page.evaluate(() => ({
    kind: window.__zeliard._zeliard_room_input_kind(),
    columns: window.__zeliard._zeliard_test_game_u8(0xFF52),
    rows: window.__zeliard._zeliard_test_game_u8(0xFF53),
    script: window.__zeliard._zeliard_test_game_u16(0xFF4C),
  }));
  await tick(1000);
  continuePrompt.stillWaiting = await page.evaluate(() =>
    window.__zeliard._zeliard_room_input_kind() === 1);
  assert(continuePrompt.kind === 1 && continuePrompt.columns === 2 &&
    continuePrompt.rows === 2 && continuePrompt.stillWaiting,
    'continue-quest Yes/No prompt was not waiting for fresh input',
    continuePrompt);

  const persisted = await page.evaluate(() => {
    const save = JSON.parse(localStorage.getItem('zeliard.save.CODEX.USR'));
    return { name: save?.name, size: save?.record?.length,
      selected: document.querySelector('#save-select').value };
  });
  assert(persisted.name === 'CODEX.usr' && persisted.size === 0x100,
    'browser save payload mismatch', persisted);
  const persistedRecord = await page.evaluate(() =>
    JSON.parse(localStorage.getItem('zeliard.save.CODEX.USR')).record);
  assert(download.suggestedFilename() === 'CODEX.usr' &&
    downloadedRecord.length === 0x100 &&
    downloadedRecord.equals(Buffer.from(persistedRecord)),
    'portable .usr download mismatch', {
      name: download.suggestedFilename(), size: downloadedRecord.length });

  await pulse(40);
  await pulse(32);
  await page.waitForFunction(() =>
    window.__zeliard._zeliard_session_terminated() === 1,
    null, { timeout: 10000 });
  await page.waitForFunction(() =>
    !document.querySelector('#restart').hidden &&
    document.querySelector('#stored-save-controls').hidden,
    null, { timeout: 5000 });
  const terminated = await page.evaluate(() => {
    const module = window.__zeliard;
    const frame = module._zeliard_framebuf();
    let nonzero = 0;
    for (let index = 0; index < 320 * 200; ++index)
      nonzero += module.HEAPU8[frame + index] !== 0 ? 1 : 0;
    return {
      terminated: module._zeliard_session_terminated(),
      nonzero,
      musicTrack: module._zeliard_music_track(),
      restartHidden: document.querySelector('#restart').hidden,
      storedControlsHidden:
        document.querySelector('#stored-save-controls').hidden,
      openHidden: document.querySelector('label[for="open-save"]').hidden,
    };
  });
  assert(terminated.terminated === 1 && terminated.nonzero === 0 &&
    terminated.musicTrack === 0 && !terminated.restartHidden &&
    terminated.storedControlsHidden && !terminated.openHidden,
    'Sage No did not produce the web session-end state', terminated);
  await page.click('#restart');
  await page.waitForFunction(() =>
    window.__zeliard._zeliard_session_terminated() === 0 &&
    window.__zeliard._zeliard_scene() === 1 &&
    document.querySelector('#restart').hidden,
    null, { timeout: 5000 });
  const restarted = await page.evaluate(() => ({
    terminated: window.__zeliard._zeliard_session_terminated(),
    scene: window.__zeliard._zeliard_scene(),
    restartHidden: document.querySelector('#restart').hidden,
  }));

  const expected = {
    expectedGoldHigh: downloadedRecord[0x85],
    expectedSages: downloadedRecord[0xE5],
  };
  await page.evaluate(() => {
    const module = window.__zeliard;
    module._zeliard_test_game_set_u8(
      0x85, module._zeliard_test_game_u8(0x85) ^ 0xFF);
  });
  await page.locator('#open-save').setInputFiles({
    name: 'CODEX.usr',
    mimeType: 'application/octet-stream',
    buffer: downloadedRecord,
  });
  await page.waitForFunction(() =>
    window.__zeliard._zeliard_scene() === 2 &&
    window.__zeliard._zeliard_town_area() === 1 &&
    window.__zeliard._zeliard_session_terminated() === 0);
  const restored = await page.evaluate((saved) => {
    const module = window.__zeliard;
    let frameHash = 0xCBF29CE484222325n;
    const frame = module._zeliard_framebuf();
    for (let index = 0; index < 320 * 200; ++index) {
      frameHash ^= BigInt(module.HEAPU8[frame + index]);
      frameHash = BigInt.asUintN(64, frameHash * 0x100000001B3n);
    }
    return { loaded: true, scene: module._zeliard_scene(),
      goldHigh: module._zeliard_test_game_u8(0x85),
      expectedGoldHigh: saved.expectedGoldHigh,
      sages: module._zeliard_test_game_u8(0xE5),
      expectedSages: saved.expectedSages,
      area: module._zeliard_town_area(),
      position: module._zeliard_test_game_u16(0x80),
      column: module._zeliard_test_game_u8(0x83),
      frameHash: frameHash.toString(16).padStart(16, '0') };
  }, expected);
  assert(restored.loaded && restored.scene === 2 &&
    restored.goldHigh === restored.expectedGoldHigh &&
    restored.sages === restored.expectedSages && restored.area === 1 &&
    restored.position === 0x20 && restored.column === 0x10,
    'saved-game bootstrap did not restore the record', restored);
  assert(restored.frameHash === '776b165581f82eb8',
    'Muralla saved-game frame mismatch', restored);
  assert(pageErrors.length === 0, 'browser errors', pageErrors);
  console.log(JSON.stringify({ verdict: 'PASS', continuePrompt, persisted,
    terminated, restarted,
    download: { name: download.suggestedFilename(),
      size: downloadedRecord.length }, restored }));
  console.log('VERDICT: PASS: exact Sage save, No exit, import, and restore');
} finally {
  await browser.close();
}
