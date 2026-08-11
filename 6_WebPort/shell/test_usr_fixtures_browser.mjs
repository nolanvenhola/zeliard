import { chromium } from 'playwright';
import { readFile, mkdir, writeFile } from 'node:fs/promises';
import { resolve } from 'node:path';

const url = process.argv[2] ?? 'http://127.0.0.1:5179/';
const fixtureDir = resolve('../..', 'scripts/state/fixtures/valid');
const fixtureNames = ['BASE.USR', 'CLEAR.USR', 'PROGRESS.USR', 'BOUNDARY.USR', 'LEAKAGE.USR'];

const fnv64 = bytes => {
  let hash = 0xcbf29ce484222325n;
  for (const byte of bytes) {
    hash ^= BigInt(byte);
    hash = BigInt.asUintN(64, hash * 0x100000001b3n);
  }
  return hash.toString(16).padStart(16, '0');
};

const browser = await chromium.launch({ headless: true });
const page = await browser.newPage();
try {
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

  const checkpoints = [];
  for (const name of fixtureNames) {
    const record = new Uint8Array(await readFile(resolve(fixtureDir, name)));
    const checkpoint = await page.evaluate(({ name, record }) => {
      const m = window.__zeliard;
      const pointer = m._malloc(record.length);
      m.HEAPU8.set(record, pointer);
      const loaded = m._zeliard_load_record(pointer, record.length);
      m._free(pointer);
      if (loaded !== 1) throw new Error(`${name}: WASM rejected fixture`);

      const gamePointer = m._zeliard_game_segment();
      const gameSize = m._zeliard_game_segment_size();
      const segment = Array.from(m.HEAPU8.slice(gamePointer, gamePointer + gameSize));
      const output = segment.slice(0, 256);
      const owner = m._zeliard_inventory_active() ? 'inventory'
        : m._zeliard_cavern_transition_active() ? 'transition'
        : m._zeliard_fight_active() ? 'fight' : 'town';
      return {
        name, loaded, owner, scene: m._zeliard_scene(), area: m._zeliard_town_area(),
        record: output, segment,
        globals: {
          timerFlag: segment[0xFF17], timerCounter: segment[0xFF18] | (segment[0xFF19] << 8),
          frameTimer: segment[0xFF1A], animTimer: segment[0xFF1B] | (segment[0xFF1C] << 8),
          rngState: segment[0xFF2E] | (segment[0xFF2F] << 8),
          inputSubtick: m._zeliard_input_subtick_accum(),
        },
        transients: {
          sceneRequest: output[0xE6], pose: output[0xE7], initComplete: output[0xE8],
        },
        frame: Array.from(m.HEAPU8.slice(m._zeliard_framebuf(), m._zeliard_framebuf() + 64000)),
        palette: Array.from(m.HEAPU8.slice(m._zeliard_palette(), m._zeliard_palette() + 768)),
        audio: { track: m._zeliard_music_track(), cueSerial: m._zeliard_audio_cue_serial() },
      };
    }, { name, record: Array.from(record) });

    // Scene initialization owns positional/transient bytes. All durable
    // progression, inventory, equipment, spell, economy, and shop state must
    // survive the real load entry point exactly.
    const durableOffsets = [
      ...Array.from({ length: 0x80 }, (_, i) => i),
      ...Array.from({ length: 0x3D }, (_, i) => 0x85 + i),
      0xC4, 0xC5,
      ...Array.from({ length: 0x1D }, (_, i) => 0xC9 + i),
    ];
    for (const offset of durableOffsets) {
      if (checkpoint.record[offset] !== record[offset]) {
        throw new Error(`${name}: persistent byte 0x${offset.toString(16)} changed ` +
          `${record[offset]} -> ${checkpoint.record[offset]} during WASM load`);
      }
    }
    checkpoints.push({
      name, owner: checkpoint.owner, scene: checkpoint.scene, area: checkpoint.area,
      hashes: { record: fnv64(checkpoint.record), segment: fnv64(checkpoint.segment),
        frame: fnv64(checkpoint.frame), palette: fnv64(checkpoint.palette) },
      globals: checkpoint.globals, transients: checkpoint.transients, audio: checkpoint.audio,
    });
  }

  // Prove a prior scene's dirty transient record cannot leak into the next
  // load: BASE must converge to the same complete segment on both sides.
  const base = new Uint8Array(await readFile(resolve(fixtureDir, 'BASE.USR')));
  const replay = await page.evaluate(record => {
    const m = window.__zeliard;
    const pointer = m._malloc(record.length);
    m.HEAPU8.set(record, pointer);
    const loaded = m._zeliard_load_record(pointer, record.length);
    m._free(pointer);
    const start = m._zeliard_game_segment();
    return { loaded, segment: Array.from(m.HEAPU8.slice(start, start + m._zeliard_game_segment_size())) };
  }, Array.from(base));
  if (replay.loaded !== 1) throw new Error('BASE replay rejected');
  const firstBase = checkpoints.find(checkpoint => checkpoint.name === 'BASE.USR');
  if (fnv64(replay.segment) !== firstBase.hashes.segment)
    throw new Error('cross-scene state leakage: BASE full-segment replay differs');

  const artifactDir = resolve('../..', 'artifacts/state-checkpoints');
  await mkdir(artifactDir, { recursive: true });
  await writeFile(resolve(artifactDir, 'wasm-usr-fixtures.json'),
    `${JSON.stringify({ format: 'zeliard-wasm-checkpoints-v1', checkpoints }, null, 2)}\n`);
  console.log(`usr-fixtures: PASS (${checkpoints.length} checkpoints)`);
} finally {
  await browser.close();
}
