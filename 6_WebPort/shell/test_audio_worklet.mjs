let Processor;
const messages = [];

globalThis.AudioWorkletProcessor = class {
  constructor() {
    this.port = {
      onmessage: null,
      postMessage: (message) => messages.push(message),
    };
  }
};
globalThis.registerProcessor = (name, implementation) => {
  if (name !== 'zeliard-pcm') throw new Error(`unexpected processor ${name}`);
  Processor = implementation;
};

await import('./public/audio-worklet.js');
const processor = new Processor();
const pcm = new Int16Array(4096 * 2);
for (let frame = 0; frame < 4096; ++frame) {
  pcm[frame * 2] = 1000 + frame;
  pcm[frame * 2 + 1] = -(1000 + frame);
}
processor.port.onmessage({ data: { type: 'pcm', pcm } });

/* The first twenty-four callbacks model a 64 ms main-thread fight-frame
 * stall; the final eight verify that the queued tail drains cleanly. */
for (let block = 0; block < 32; ++block) {
  const left = new Float32Array(128);
  const right = new Float32Array(128);
  if (!processor.process([], [[left, right]]))
    throw new Error('processor stopped');
  if (left[0] === 0 || right[0] === 0)
    throw new Error(`PCM gap in block ${block}`);
}

const live = messages.at(-1)?.stats;
if (!live || live.deliveredFrames !== 4096 || live.underrunFrames !== 0 ||
    live.bufferedFrames !== 0 || live.deliveredPeak !== 5095)
  throw new Error(`worklet stream mismatch: ${JSON.stringify(live)}`);

const fadeLeft = new Float32Array(128);
const fadeRight = new Float32Array(128);
processor.process([], [[fadeLeft, fadeRight]]);
if (fadeLeft[0] === 0 || fadeRight[0] === 0 || fadeLeft[63] !== 0 ||
    fadeRight[63] !== 0 || fadeLeft.slice(64).some(Boolean) ||
    fadeRight.slice(64).some(Boolean))
  throw new Error('empty worklet did not ramp cleanly to silence');

const silentLeft = new Float32Array(128);
const silentRight = new Float32Array(128);
processor.process([], [[silentLeft, silentRight]]);
if (silentLeft.some(Boolean) || silentRight.some(Boolean))
  throw new Error('post-ramp worklet did not remain silent');

processor.port.onmessage({ data: { type: 'reset' } });
if (processor.bufferedFrames !== 0 || processor.primed)
  throw new Error('worklet reset retained stream state');

console.log('audio_worklet: PASS: continuous queued PCM and clean underrun');
