import fs from 'node:fs/promises';
import path from 'node:path';

function argValue(name, fallback = null) {
  const index = process.argv.indexOf(name);
  if (index < 0) return fallback;
  if (index + 1 >= process.argv.length) throw new Error(`missing value for ${name}`);
  return process.argv[index + 1];
}

const schedulePath = argValue('--schedule', 'hybrid_reference_schedule.json');
const firstDir = argValue('--first');
const secondDir = argValue('--second');
if (!firstDir || !secondDir) {
  throw new Error('usage: node verify_hybrid_masm_capture.mjs --first capture_a --second capture_b [--schedule schedule.json]');
}

const schedule = JSON.parse(await fs.readFile(schedulePath, 'utf8'));
const first = JSON.parse(await fs.readFile(path.join(firstDir, 'manifest.json'), 'utf8'));
const second = JSON.parse(await fs.readFile(path.join(secondDir, 'manifest.json'), 'utf8'));
const firstById = new Map(first.samples.map(sample => [sample.id, sample]));
const secondById = new Map(second.samples.map(sample => [sample.id, sample]));
let failed = 0;
let exact = 0;
let animated = 0;

for (const sample of schedule.samples) {
  const a = firstById.get(sample.id);
  const b = secondById.get(sample.id);
  if (!a || !b) {
    console.error(`FAIL ${sample.id}: missing from capture manifest`);
    failed++;
    continue;
  }
  const same = a.rgba_sha256 === b.rgba_sha256;
  if (sample.comparison === 'exact') {
    exact++;
    if (!same) {
      console.error(`FAIL ${sample.id}: exact checkpoint diverged (${a.rgba_sha256} != ${b.rgba_sha256})`);
      failed++;
    } else {
      console.log(`PASS ${sample.id}: ${a.rgba_sha256}`);
    }
  } else {
    animated++;
    console.log(`WINDOW ${sample.id}: ${same ? 'same frame' : 'timer-phase variant'}`);
  }
}

if (failed) {
  console.log(`VERDICT: FAIL (${failed}/${exact} exact checkpoints diverged; ${animated} animated windows)`);
  process.exit(1);
}
console.log(`VERDICT: PASS (${exact} repeatable exact checkpoints; ${animated} animated windows retained for sequence alignment)`);
