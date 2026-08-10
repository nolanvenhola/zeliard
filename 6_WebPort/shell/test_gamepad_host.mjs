import assert from 'node:assert/strict';
import fs from 'node:fs';
import ts from 'typescript';

const source = fs.readFileSync(new URL('./src/gamepad.ts', import.meta.url),
    'utf8');
const js = ts.transpileModule(source, {
    compilerOptions: { module: ts.ModuleKind.CommonJS,
        target: ts.ScriptTarget.ES2020 },
}).outputText;
const exports = {};
new Function('exports', 'module', js)(exports, { exports });
const { mapBrowserGamepad, firstConnectedGamepad } = exports;

function pad({ axes = [0, 0], pressed = [] } = {}) {
    const buttons = Array.from({ length: 16 }, (_, index) => ({
        pressed: pressed.includes(index),
        value: pressed.includes(index) ? 1 : 0,
    }));
    return { connected: true, axes, buttons };
}

const neutral = { directions: 0, buttons: 0 };
assert.deepEqual(mapBrowserGamepad(pad(), neutral), neutral);
assert.equal(mapBrowserGamepad(pad({ axes: [0.54, 0] }), neutral).directions, 0);
let state = mapBrowserGamepad(pad({ axes: [0.56, 0] }), neutral);
assert.equal(state.directions, 0x08, 'right is MASM bit 3');
state = mapBrowserGamepad(pad({ axes: [0.40, 0] }), state);
assert.equal(state.directions, 0x08, 'axis hysteresis retains direction');
state = mapBrowserGamepad(pad({ axes: [0.34, 0] }), state);
assert.equal(state.directions, 0, 'axis releases below deadzone');
assert.equal(mapBrowserGamepad(pad({ pressed: [12, 14] }), neutral).directions,
    0x05, 'D-pad up/left uses stick.asm low-nibble bits');
assert.equal(mapBrowserGamepad(pad({ pressed: [0, 1, 2, 3, 4, 5, 8, 9] }),
    neutral).buttons, 0xff, 'standard buttons cover all host actions');
assert.equal(firstConnectedGamepad([null, pad()])?.connected, true);
assert.equal(firstConnectedGamepad([null]), null);
console.log('gamepad host mapping: PASS');
