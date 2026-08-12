import { chromium } from 'playwright';
import { readFile, writeFile } from 'node:fs/promises';
import { resolve } from 'node:path';

const args = process.argv.slice(2);
const valueAfter = flag => {
  const index = args.indexOf(flag);
  return index >= 0 ? args[index + 1] : undefined;
};
const scenarioPath = valueAfter('--scenario');
const outputPath = valueAfter('--output');
const repeat = Number.parseInt(valueAfter('--repeat') ?? '1', 10);
const baseUrl = valueAfter('--url') ?? 'http://127.0.0.1:5179/';
if (!scenarioPath || !outputPath || !Number.isInteger(repeat) || repeat < 1)
  throw new Error('usage: node run_guest_replay.mjs --scenario FILE --output FILE [--repeat N] [--url URL]');

const scenario = JSON.parse(await readFile(resolve(scenarioPath), 'utf8'));
if (scenario.format !== 'zeliard-replay-v1' || !Array.isArray(scenario.events))
  throw new Error('runner requires canonical zeliard-replay-v1 JSON');

const browserKeycodes = {
  escape: 27, enter: 13, alt: 18, space: 32, left: 37, up: 38,
  right: 39, down: 40, f1: 112, f2: 113, f7: 118, f9: 120,
};
const setupRecord = scenario.setup?.save
  ? Array.from(new Uint8Array(await readFile(resolve('../..', scenario.setup.save))))
  : null;
if (setupRecord && setupRecord.length !== 0x100)
  throw new Error(`setup save must be 256 bytes, got ${setupRecord.length}`);
for (const [offset, byte] of Object.entries(scenario.setup?.patches ?? {}))
  setupRecord[Number.parseInt(offset, 0)] = byte;

const browser = await chromium.launch({ headless: true });
const runs = [];
try {
  for (let run = 0; run < repeat; run++) {
    const page = await browser.newPage();
    const errors = [];
    page.on('pageerror', error => errors.push(error.message));
    try {
      const url = new URL(baseUrl);
      url.searchParams.set('codex_capture', '1');
      await page.goto(url.toString(), { waitUntil: 'domcontentloaded' });
      await page.waitForFunction(() => window.__zeliard !== undefined,
        null, { timeout: 120000 });
      const result = await page.evaluate(({ events, browserKeycodes, setupRecord }) => {
        const m = window.__zeliard;
        if (setupRecord) {
          const pointer = m._malloc(setupRecord.length);
          m.HEAPU8.set(setupRecord, pointer);
          const loaded = m._zeliard_load_record(pointer, setupRecord.length);
          m._free(pointer);
          if (loaded !== 1) throw new Error('WASM rejected scenario setup save');
        }
        const checkpoints = [];
        let lastAccepted = null;
        const held = new Set();
        let joystick = { directions: 0, buttons: 0 };

        const fnv = bytes => {
          let hash = 0xcbf29ce484222325n;
          for (const byte of bytes) {
            hash ^= BigInt(byte);
            hash = BigInt.asUintN(64, hash * 0x100000001b3n);
          }
          return hash.toString(16).padStart(16, '0').toUpperCase();
        };
        const state = () => {
          const segment = m._zeliard_game_segment();
          const start = m.HEAPU8[segment + 0x80] |
            (m.HEAPU8[segment + 0x81] << 8);
          const screenPosition = m.HEAPU8[segment + 0x83];
          const npcTable = m.HEAPU8[segment + 0xC00F] |
            (m.HEAPU8[segment + 0xC010] << 8);
          const npcPositions = [];
          const npcRecords = [];
          for (let at = npcTable; at < 0xFFF8 && npcPositions.length < 32; at += 8) {
            const position = m.HEAPU8[segment + at] |
              (m.HEAPU8[segment + at + 1] << 8);
            if (position === 0xFFFF) break;
            npcPositions.push(position);
            npcRecords.push({ position, facing: m.HEAPU8[segment + at + 2],
              flags: m.HEAPU8[segment + at + 6] });
          }
          return {
            guestTick: m._zeliard_guest_tick(),
            scene: m._zeliard_scene(),
            phase: m._zeliard_phase(),
            paused: m._zeliard_paused(),
            inventoryActive: m._zeliard_inventory_active(),
            dialogActive: m._zeliard_town_dialog_active(),
            townArea: m._zeliard_town_area(),
            fightActive: m._zeliard_fight_active(),
            playerStartPosition: start,
            playerScreenPosition: screenPosition,
            playerWorldPosition: start + ((screenPosition + 4) & 0xFF),
            npcTable,
            npcPositions,
            npcRecords,
          };
        };
        const assertExpected = (expected, sequence) => {
          const actual = state();
          for (const [key, value] of Object.entries(expected)) {
            if (!(key in actual))
              throw new Error(`event ${sequence}: unsupported assertion ${key}`);
            if (actual[key] !== value)
              throw new Error(`event ${sequence}: ${key}=${actual[key]}, expected ${value}`);
          }
        };
        const advanceTo = (target, sequence) => {
          let guard = 0;
          while (m._zeliard_guest_tick() < target) {
            m._zeliard_tick(1);
            if (++guard > 2000000)
              throw new Error(`event ${sequence}: guest tick stalled at ${m._zeliard_guest_tick()}`);
          }
          if (m._zeliard_guest_tick() !== target)
            throw new Error(`event ${sequence}: missed tick ${target}; reached ${m._zeliard_guest_tick()}`);
        };

        for (const event of events) {
          const target = event.when.clock === 'breakpoint'
            ? event.when.resolvedTick : event.when.value;
          if (!Number.isInteger(target))
            throw new Error(`event ${event.sequence}: unresolved breakpoint ${event.when.value}`);
          advanceTo(target, event.sequence);
          switch (event.action) {
            case 'key_down':
              m._zeliard_key_down(browserKeycodes[event.key]);
              held.add(event.key);
              break;
            case 'key_up':
              m._zeliard_key_up(browserKeycodes[event.key]);
              held.delete(event.key);
              break;
            case 'text_key':
              m._zeliard_text_key(event.text.charCodeAt(0));
              break;
            case 'joystick':
              joystick = { directions: event.directions, buttons: event.buttons };
              m._zeliard_gamepad_update(1, joystick.directions, joystick.buttons);
              break;
            case 'assert':
              assertExpected(event.expected, event.sequence);
              break;
            case 'checkpoint': {
              if (event.expected) assertExpected(event.expected, event.sequence);
              const segmentPointer = m._zeliard_game_segment();
              const segmentSize = m._zeliard_game_segment_size();
              const framebufferPointer = m._zeliard_framebuf();
              const palettePointer = m._zeliard_palette();
              checkpoints.push({
                name: event.name,
                sequence: event.sequence,
                state: state(),
                hashes: {
                  segment: fnv(m.HEAPU8.subarray(segmentPointer,
                    segmentPointer + segmentSize)),
                  framebuffer: fnv(m.HEAPU8.subarray(framebufferPointer,
                    framebufferPointer + 64000)),
                  palette: fnv(m.HEAPU8.subarray(palettePointer,
                    palettePointer + 768)),
                },
              });
              break;
            }
            default:
              throw new Error(`event ${event.sequence}: unsupported action ${event.action}`);
          }
          lastAccepted = { sequence: event.sequence, action: event.action,
            tick: m._zeliard_guest_tick() };
        }
        if (held.size)
          throw new Error(`stuck keys after replay: ${Array.from(held).join(',')}`);
        if (joystick.directions || joystick.buttons)
          throw new Error('stuck joystick state after replay');
        return { checkpoints, lastAccepted };
      }, { events: scenario.events, browserKeycodes, setupRecord });
      if (errors.length) throw new Error(`browser errors: ${errors.join('; ')}`);
      runs.push({ run, status: 'pass', ...result });
    } catch (error) {
      runs.push({ run, status: 'fail', error: String(error) });
      throw error;
    } finally {
      await page.close();
    }
  }
} finally {
  await browser.close();
}

const signatures = runs.map(run => JSON.stringify(run.checkpoints));
const deterministic = signatures.every(signature => signature === signatures[0]);
const report = {
  format: 'zeliard-replay-result-v1', runtime: 'wasm',
  scenario: scenario.name, repeat, deterministic, runs,
};
await writeFile(resolve(outputPath), JSON.stringify(report, null, 2) + '\n');
if (!deterministic) throw new Error('repeated WASM replay diverged');
console.log(`guest_replay: PASS ${scenario.name} x${repeat} checkpoints=${runs[0].checkpoints.length}`);
console.log('VERDICT: PASS: guest-tick replay is deterministic');
