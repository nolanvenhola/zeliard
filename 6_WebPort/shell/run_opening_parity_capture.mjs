import { spawn } from 'node:child_process';
import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { createHash } from 'node:crypto';
import { createServer } from 'vite';

const here = path.dirname(fileURLToPath(import.meta.url));
const outputRoot = path.resolve(here, '../tests/artifacts/opening_masm_wasm_latest');
const masmDir = path.join(outputRoot, 'masm');
const wasmDir = path.join(outputRoot, 'wasm');
const reportDir = path.join(outputRoot, 'report');
const schedule = path.join(here, 'hybrid_reference_schedule.json');
const masmStateSchedule = path.join(outputRoot, 'masm_state_schedule.json');
const host = '127.0.0.1';
const port = 5193;
const baseUrl = `http://${host}:${port}`;

async function run(command, args, cwd = here, allowFailure = false) {
  return await new Promise((resolve, reject) => {
    const child = spawn(command, args, { cwd, stdio: 'inherit', shell: false });
    child.on('error', reject);
    child.on('exit', code => {
      if (code === 0 || allowFailure) resolve(code);
      else reject(new Error(`${command} exited with ${code}`));
    });
  });
}

await fs.rm(outputRoot, { recursive: true, force: true });
await fs.mkdir(outputRoot, { recursive: true });

const requiredEngineFiles = ['zeliard.js', 'zeliard.wasm', 'zeliard.data'];
for (const file of requiredEngineFiles) {
  try {
    await fs.access(path.join(here, 'public/engine', file));
  } catch {
    throw new Error(`missing public/engine/${file}; build the WASM engine first`);
  }
}

await run(process.execPath, ['../scripts/build-hybrid-dos-image.mjs'], here);
const server = await createServer({
  root: here,
  logLevel: 'error',
  server: { host, port, strictPort: true },
});

try {
  await server.listen();
  await run(process.execPath, [
    'capture_opening_wasm_frames.mjs',
    '--schedule', schedule,
    '--out-dir', wasmDir,
    '--url', `${baseUrl}/`,
    '--raw-ppm',
    '--quiet',
  ]);

  const sourceSchedule = JSON.parse(await fs.readFile(schedule, 'utf8'));
  const wasmLog = JSON.parse(
    await fs.readFile(path.join(wasmDir, 'wasm_capture_log.json'), 'utf8'));
  const wasmById = new Map(wasmLog.map(sample => [sample.id, sample]));
  const stateSamples = [];
  for (const sample of sourceSchedule.samples) {
    if (sample.alignment !== 'frame_state') {
      stateSamples.push(sample);
      continue;
    }
    const wasm = wasmById.get(sample.id);
    if (!wasm)
      throw new Error(`WASM capture is missing state checkpoint ${sample.id}`);
    const ppm = await fs.readFile(wasm.path);
    let newline = -1;
    for (let count = 0; count < 3; count++)
      newline = ppm.indexOf(0x0A, newline + 1);
    const rgb = ppm.subarray(newline + 1);
    if (rgb.length !== 320 * 200 * 3)
      throw new Error(`${sample.id}: unexpected PPM payload ${rgb.length}`);
    const rgba = Buffer.alloc(320 * 200 * 4);
    for (let src = 0, dst = 0; src < rgb.length; src += 3, dst += 4) {
      rgba[dst] = rgb[src];
      rgba[dst + 1] = rgb[src + 1];
      rgba[dst + 2] = rgb[src + 2];
      rgba[dst + 3] = 255;
    }
    stateSamples.push({
      ...sample,
      expected_rgba_sha256: createHash('sha256').update(rgba).digest('hex'),
    });
  }
  await fs.writeFile(masmStateSchedule, JSON.stringify({
    ...sourceSchedule,
    clock: 'Ordered MASM framebuffer states; wall time is diagnostic only.',
    samples: stateSamples,
  }, null, 2) + '\n');

  await run(process.execPath, [
    'capture_hybrid_masm_frames.mjs',
    '--schedule', masmStateSchedule,
    '--out-dir', masmDir,
    '--url', `${baseUrl}/hybrid.html`,
    '--quiet',
  ]);

  const python = process.platform === 'win32' ? 'py' : 'python3';
  const pythonArgs = process.platform === 'win32' ? ['-3.13'] : [];
  const comparisonExit = await run(python, [
    ...pythonArgs,
    '../tests/compare_hybrid_masm_to_wasm.py',
    '--masm-dir', masmDir,
    '--wasm-dir', wasmDir,
    '--out-dir', reportDir,
  ], here, true);
  console.log(`Parity report: ${path.join(reportDir, 'report.md')}`);
  process.exitCode = comparisonExit;
} finally {
  await server.close();
}
