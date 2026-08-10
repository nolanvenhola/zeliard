import { chromium } from 'playwright';

const url = process.argv[2] ?? 'http://127.0.0.1:5179/';
const browser = await chromium.launch({ headless: true });
const errors = [];
const browserLogs = [];

const hashBytes = bytes => {
  let hash = 0xcbf29ce484222325n;
  for (const value of bytes) {
    hash ^= BigInt(value);
    hash = BigInt.asUintN(64, hash * 0x100000001b3n);
  }
  return hash.toString(16).padStart(16, '0');
};

async function boot(page) {
  page.on('pageerror', error => errors.push(error.message));
  page.on('console', message => browserLogs.push(message.text()));
  await page.goto(url, { waitUntil: 'domcontentloaded' });
  await page.waitForFunction(() => window.__zeliard !== undefined,
    null, { timeout: 120000 });
  await page.waitForSelector('#start:not([hidden])', { timeout: 120000 });
  await page.click('#start');
  await page.evaluate(() => {
    const m = window.__zeliard;
    m._zeliard_opening_set_phase_for_test(3);
    m._zeliard_key(13);
    m._zeliard_tick(0);
  });
  await page.waitForFunction(() => window.__zeliard._zeliard_scene() === 2);
}

async function checkpoint(page, label) {
  return page.evaluate(label => {
    const m = window.__zeliard;
    const hash = (pointer, size) => {
      let value = 0xcbf29ce484222325n;
      for (let i = 0; i < size; ++i) {
        value ^= BigInt(m.HEAPU8[pointer + i]);
        value = BigInt.asUintN(64, value * 0x100000001b3n);
      }
      return value.toString(16).padStart(16, '0');
    };
    const owner = m._zeliard_ending_active() ? 'ending'
      : m._zeliard_inventory_active() ? 'inventory'
      : m._zeliard_cavern_transition_active() ? 'transition'
      : m._zeliard_fight_active() ? 'fight' : 'town';
    return {
      label, owner,
      record: hash(m._zeliard_player_record(), 256),
      frame: hash(m._zeliard_framebuf(), 64000),
      palette: hash(m._zeliard_palette(), 768),
      music: m._zeliard_music_track(),
      cueSerial: m._zeliard_audio_cue_serial(),
      exactAudio: m._zeliard_exact_music_driver(),
      area: m._zeliard_town_area(),
      cavern: m._zeliard_test_game_u8(0xc4),
      hp: m._zeliard_test_game_u16(0x90),
      sword: m._zeliard_test_game_u8(0x92),
      shield: m._zeliard_test_game_u8(0x93),
      spell: m._zeliard_test_game_u8(0x9d),
      tears: m._zeliard_test_game_u8(0xa0),
    };
  }, label);
}

function requireAt(label, condition, detail) {
  if (!condition) throw new Error(`${label}: first divergent MASM-owned transition: ${detail}; ` +
    `console=${JSON.stringify(browserLogs.slice(-12))}`);
}

async function reachEnding(page, route, checkpoints) {
  const start = await page.evaluate(() => {
    const m = window.__zeliard;
    m._zeliard_test_game_set_u8(0x90, 0xff);
    m._zeliard_test_game_set_u8(0x91, 0x00);
    const started = m._zeliard_test_restart_fight(0x1e, 4, 21, 12);
    for (let i = 0; i < 12; ++i) m._zeliard_tick(20);
    return { started, width: m._zeliard_fight_map_width(),
      defeated: m._zeliard_test_defeat_jashiin() };
  });
  requireAt(`${route}:jashiin`, start.started && start.width === 73 && start.defeated,
    JSON.stringify(start));
  let result = await page.evaluate(() => {
    const m = window.__zeliard;
    let ticks = 0;
    while (!m._zeliard_ending_active() && ticks++ < 400) m._zeliard_tick(20);
    return { ticks, active: m._zeliard_ending_active(),
      scene: m._zeliard_ending_scene(), music: m._zeliard_fight_music_chunk() };
  });
  requireAt(`${route}:250ENDMO`, result.active && result.ticks < 400,
    JSON.stringify(result));
  checkpoints.push(await checkpoint(page, `${route}:ending-first-frame`));
}

async function runNewGameRoute(page) {
  const checkpoints = [await checkpoint(page, 'new:felishika')];
  await page.evaluate(() => {
    const m = window.__zeliard;
    /* Deterministic acceleration state: equipment, spell, permanent pickups,
       opened wall/chest, and tears remain the same live 256-byte record. */
    for (const [offset, value] of [[2, 0x78], [3, 0xe0], [0x12, 0x6c],
      [0x13, 0x30], [0x92, 6], [0x93, 6], [0x9d, 4], [0xa0, 8],
      [0xab + 4, 3], [0xbb + 4, 0xff]])
      m._zeliard_test_game_set_u8(offset, value);
  });
  const persistent = await checkpoint(page, 'new:progression-seeded');
  checkpoints.push(persistent);

  for (let area = 0; area <= 9; ++area) {
    const state = await page.evaluate(area => {
      const m = window.__zeliard;
      const started = m._zeliard_test_restart_town(area);
      m._zeliard_tick(20);
      return { started, area: m._zeliard_town_area(), marker: m._zeliard_test_game_u8(2) };
    }, area);
    requireAt(`new:town-${area}`, state.started && state.area === area && state.marker === 0x78,
      JSON.stringify(state));
    checkpoints.push(await checkpoint(page, `new:town-${area}`));
  }

  const purezaSecret = await page.evaluate(() => {
    const m = window.__zeliard;
    const set = (offset, value) => m._zeliard_test_game_set_u8(offset, value);
    const started = m._zeliard_test_restart_town(8);
    /* 106TOWN's Pureza special-door record is at world position 0126h.  A
       player at 0115h/column 0Dh faces it while moving up (direction 1). */
    for (const [offset, value] of [[0x45, 0x80], [0x80, 0x15],
      [0x81, 0x01], [0x83, 0x0d], [0xc5, 0x88]]) set(offset, value);
    const tile = 0xc017 + 0x0115 * 8;
    set(0xff2a, tile & 0xff);
    set(0xff2b, tile >> 8);
    m._zeliard_key_down(38);
    let ticks = 0;
    while (m._zeliard_town_area() !== 6 && ticks++ < 160)
      m._zeliard_tick(20);
    m._zeliard_key_up(38);
    m._zeliard_tick(20);
    return {
      started, ticks, area: m._zeliard_town_area(),
      selector: m._zeliard_test_game_u8(0xc4),
      sage: m._zeliard_test_game_u8(0xc5),
      position: m._zeliard_test_game_u16(0x80),
      column: m._zeliard_test_game_u8(0x83),
    };
  });
  requireAt('new:pureza-secret', purezaSecret.started &&
    purezaSecret.area === 6 && purezaSecret.selector === 0x86 &&
    purezaSecret.sage === 0x88 && purezaSecret.position === 0x0084 &&
    purezaSecret.column === 0x0d, JSON.stringify(purezaSecret));
  checkpoints.push(await checkpoint(page, 'new:pureza-secret-dorado'));

  const inventory = await page.evaluate(() => {
    const m = window.__zeliard;
    const cueBefore = m._zeliard_audio_cue_serial();
    m._zeliard_key_down(13); m._zeliard_tick(20); m._zeliard_key_up(13);
    m._zeliard_tick(20);
    const opened = m._zeliard_inventory_active();
    const selected = m._zeliard_test_game_u8(0x9d);
    m._zeliard_key_down(13); m._zeliard_tick(20);
    m._zeliard_key_up(13); m._zeliard_tick(20);
    return { opened, closed: !m._zeliard_inventory_active(), selected,
      selectedAfter: m._zeliard_test_game_u8(0x9d),
      cueDelta: m._zeliard_audio_cue_serial() - cueBefore };
  });
  requireAt('new:inventory', inventory.opened && inventory.closed &&
    inventory.selected === inventory.selectedAfter && inventory.selected >= 1 &&
    inventory.selected <= 5 && inventory.cueDelta >= 2, JSON.stringify(inventory));
  checkpoints.push(await checkpoint(page, 'new:inventory-return'));

  const boundary = await page.evaluate(() => {
    const m = window.__zeliard;
    m._zeliard_test_restart_town(1);
    m._zeliard_test_game_set_u8(0x80, 0xb9);
    m._zeliard_test_game_set_u8(0x81, 0);
    m._zeliard_test_game_set_u8(0x83, 0x10);
    m._zeliard_key_down(38);
    let entry = 0;
    while (!m._zeliard_cavern_transition_active() && entry++ < 100) m._zeliard_tick(20);
    m._zeliard_key_up(38);
    let crossing = 0;
    while (!m._zeliard_cavern_transition_complete() && crossing++ < 1000) m._zeliard_tick(20);
    m._zeliard_tick(20);
    return { entry, crossing, complete: m._zeliard_cavern_transition_complete(),
      fight: m._zeliard_fight_active(), marker: m._zeliard_test_game_u8(2) };
  });
  requireAt('new:muralla-cavern', boundary.complete && boundary.fight &&
    boundary.marker === 0x78, JSON.stringify(boundary));
  checkpoints.push(await checkpoint(page, 'new:muralla-cavern'));

  for (let selector = 0; selector < 0x1e; ++selector) {
    const state = await page.evaluate(selector => {
      const m = window.__zeliard;
      const town = m._zeliard_test_restart_town(1);
      const started = m._zeliard_test_restart_fight(selector, 32, 24, 12);
      for (let i = 0; i < 3; ++i) m._zeliard_tick(20);
      return { town, started, active: m._zeliard_fight_active(),
        marker: m._zeliard_test_game_u8(2), width: m._zeliard_fight_map_width() };
    }, selector);
    requireAt(`new:cavern-${selector.toString(16)}`, state.town && state.started && state.active &&
      state.marker === 0x78 && state.width > 0, JSON.stringify(state));
    checkpoints.push(await checkpoint(page, `new:cavern-${selector.toString(16)}`));
  }

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
    return { started, ticks, room: m._zeliard_room_kind(),
      fight: m._zeliard_fight_active(), marker: m._zeliard_test_game_u8(2) };
  });
  requireAt('new:death-sage', death.started && death.room === 2 && !death.fight &&
    death.marker === 0x78, JSON.stringify(death));
  checkpoints.push(await checkpoint(page, 'new:death-sage'));

  const saved = await page.evaluate(() => {
    const m = window.__zeliard;
    m._zeliard_test_restart_town(1);
    const at = m._zeliard_player_record();
    return Array.from(m.HEAPU8.subarray(at, at + 256));
  });
  await reachEnding(page, 'new', checkpoints);
  return { checkpoints, saved };
}

async function runLoadedRoute(page, saved) {
  const loaded = await page.evaluate(saved => {
    const m = window.__zeliard;
    const pointer = m._malloc(256);
    m.HEAPU8.set(saved, pointer);
    const ok = m._zeliard_load_record(pointer, 256);
    m._free(pointer);
    return { ok, marker: m._zeliard_test_game_u8(2), sword: m._zeliard_test_game_u8(0x92),
      shield: m._zeliard_test_game_u8(0x93), spell: m._zeliard_test_game_u8(0x9d) };
  }, saved);
  requireAt('load:record', loaded.ok && loaded.marker === 0x78 && loaded.sword === 6 &&
    loaded.shield === 6 && loaded.spell === saved[0x9d], JSON.stringify(loaded));
  const checkpoints = [await checkpoint(page, 'load:town')];
  await reachEnding(page, 'load', checkpoints);
  return checkpoints;
}

try {
  const newPage = await browser.newPage();
  await boot(newPage);
  const newRoute = await runNewGameRoute(newPage);
  const loadedPage = await browser.newPage();
  await boot(loadedPage);
  const loadedRoute = await runLoadedRoute(loadedPage, newRoute.saved);
  requireAt('browser', errors.length === 0, JSON.stringify(errors));
  const all = [...newRoute.checkpoints, ...loadedRoute];
  requireAt('checkpoints', all.every(point => point.exactAudio && point.frame !==
    '0000000000000000' && point.palette !== '0000000000000000'), JSON.stringify(all));
  console.log(`continuous_playthrough_browser: PASS checkpoints=${all.length} ` +
    `new=${newRoute.checkpoints.length} loaded=${loadedRoute.length} ` +
    `record=${hashBytes(newRoute.saved)}`);
  console.log('VERDICT: PASS: continuous new-game and loaded-save routes reach 250ENDMO');
} finally {
  await browser.close();
}
