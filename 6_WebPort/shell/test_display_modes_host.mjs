import assert from 'node:assert/strict';
import fs from 'node:fs';
import ts from 'typescript';

const source = fs.readFileSync(new URL('./src/display.ts', import.meta.url),
    'utf8');
const js = ts.transpileModule(source, {
  compilerOptions: { module: ts.ModuleKind.CommonJS,
    target: ts.ScriptTarget.ES2020 },
}).outputText;
const exports = {};
new Function('exports', 'module', js)(exports, { exports });
const { applyDisplayMode, parseDisplayMode, DISPLAY_MODE } = exports;

const original = new Uint8ClampedArray(16 * 16 * 4);
for (let y = 0; y < 16; ++y) {
  for (let x = 0; x < 16; ++x) {
    const at = (y * 16 + x) * 4;
    original[at] = x * 17;
    original[at + 1] = y * 17;
    original[at + 2] = (x ^ y) * 17;
    original[at + 3] = 255;
  }
}

function hash(bytes) {
  let value = 2166136261;
  for (const byte of bytes) {
    value ^= byte;
    value = Math.imul(value, 16777619) >>> 0;
  }
  return value.toString(16).padStart(8, '0');
}

const expected = {
  0: '3b4c351d', 1: '737c7af3', 2: 'f4926325', 3: '476dcc4f',
  4: 'ba288005', 5: '3b4c351d',
};
const colorLimits = { 0: 16, 1: 4, 2: 2, 3: 2, 4: 256, 5: 16 };
const hashes = {};
for (let mode = 0; mode <= 5; ++mode) {
  const frame = new Uint8ClampedArray(original);
  applyDisplayMode(frame, 16, 16, mode);
  hashes[mode] = hash(frame);
  const colors = new Set();
  for (let at = 0; at < frame.length; at += 4) {
    colors.add(`${frame[at]},${frame[at + 1]},${frame[at + 2]}`);
    assert.equal(frame[at + 3], 255);
  }
  assert.ok(colors.size <= colorLimits[mode],
    `mode ${mode} used ${colors.size} colors`);
}
console.log(JSON.stringify(hashes));
for (let mode = 0; mode <= 5; ++mode)
  assert.equal(hashes[mode], expected[mode]);
assert.deepEqual(hashes[DISPLAY_MODE.mcga], hash(original),
  'MCGA conversion must remain byte-identical');
assert.equal(parseDisplayMode('0'), DISPLAY_MODE.ega);
assert.equal(parseDisplayMode('5'), DISPLAY_MODE.tandy);
assert.equal(parseDisplayMode('99'), DISPLAY_MODE.mcga);
console.log('display mode host conversion: PASS');
