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

/* Town playback uses a smaller prime target so NPC dialog effects do not
 * wait behind the fight VM's full 4096-frame underrun cushion. */
processor.port.onmessage({ data: { type: 'buffer-target', frames: 1024 } });
const townPcm = new Int16Array(1024 * 2);
townPcm.fill(1200);
processor.port.onmessage({ data: { type: 'pcm', pcm: townPcm } });
const townLeft = new Float32Array(128);
const townRight = new Float32Array(128);
processor.process([], [[townLeft, townRight]]);
if (townLeft[0] === 0 || townRight[0] === 0 ||
    processor.primeTargetFrames !== 1024)
  throw new Error('low-latency town target did not start at 1024 frames');

/* A dialog cue must bypass PCM already queued on the audio thread. */
const staleTownPcm = new Int16Array(512 * 2);
staleTownPcm.fill(2000);
processor.port.onmessage({ data: { type: 'pcm', pcm: staleTownPcm } });
processor.port.onmessage({ data: { type: 'cue-rebase' } });
if (processor.bufferedFrames !== 0 || processor.primed)
  throw new Error('dialog cue retained pre-cue worklet audio');
const cuePcm = new Int16Array(1024 * 2);
cuePcm.fill(3000);
processor.port.onmessage({ data: { type: 'pcm', pcm: cuePcm } });
const cueLeft = new Float32Array(128);
const cueRight = new Float32Array(128);
processor.process([], [[cueLeft, cueRight]]);
if (cueLeft[0] === 0 || cueRight[0] === 0 ||
    processor.bufferedFrames !== 896)
  throw new Error('dialog cue did not resume from its new PCM boundary');
if (Math.abs(cueLeft[64] - 3000 / 32768) > 1e-6 ||
    Math.abs(cueRight[64] - 3000 / 32768) > 1e-6)
  throw new Error('dialog cue crossfade restarted a second fade-in');

processor.port.onmessage({ data: { type: 'reset' } });
processor.port.onmessage({ data: { type: 'buffer-target', frames: 4096 } });
processor.port.onmessage({ data: { type: 'pcm', pcm: townPcm } });
const fightLeft = new Float32Array(128);
const fightRight = new Float32Array(128);
processor.process([], [[fightLeft, fightRight]]);
if (fightLeft.some(Boolean) || fightRight.some(Boolean) || processor.primed)
  throw new Error('fight target started without its 4096-frame cushion');

console.log('audio_worklet: PASS: adaptive PCM buffering and clean underrun');
