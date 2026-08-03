import { chromium } from 'playwright';

const url = process.argv[2] ?? 'http://127.0.0.1:5177/';
const browser = await chromium.launch({ headless: true });
const page = await browser.newPage();

async function tick(ms) {
  await page.evaluate((duration) => {
    const module = window.__zeliard;
    for (let elapsed = 0; elapsed < duration; elapsed += 16)
      module._zeliard_tick(Math.min(16, duration - elapsed));
  }, ms);
}

async function pulse(keycode) {
  await page.evaluate((key) => window.__zeliard._zeliard_key_down(key), keycode);
  await tick(10);
  await page.evaluate((key) => window.__zeliard._zeliard_key_up(key), keycode);
  let sawBusy = false;
  for (let wait = 0; wait < 600; ++wait) {
    await tick(5);
    const input = await page.evaluate(
      () => window.__zeliard._zeliard_room_input_kind());
    sawBusy ||= input === 0;
    if (sawBusy && input !== 0) break;
  }
}

async function state() {
  return page.evaluate(() => {
    const m = window.__zeliard;
    return {
      amount: (m._zeliard_test_game_u8(0xAD29) << 16) |
              m._zeliard_test_game_u16(0xAD2A),
      delay: m._zeliard_test_game_u8(0xAD2F),
      carried: (m._zeliard_test_game_u8(0x85) << 16) |
               m._zeliard_test_game_u16(0x86),
      banked: (m._zeliard_test_game_u8(0x88) << 16) |
              m._zeliard_test_game_u16(0x89),
      direction: m._zeliard_test_game_u8(0xFF17),
      rawSpace: m._zeliard_test_game_u8(0xFF16),
      spaceLatch: m._zeliard_test_game_u8(0xFF1D),
      script: m._zeliard_test_game_u16(0xFF4C),
      row: m._zeliard_test_game_u8(0xFF56),
      input: m._zeliard_room_input_kind(),
      ip: m._zeliard_room_ip(),
    };
  });
}

function assert(condition, message, value) {
  if (!condition)
    throw new Error(`${message}: ${JSON.stringify(value)}`);
}

function assertAccelerates(samples, label) {
  const amounts = samples.map((sample) => sample.amount);
  const delays = samples.map((sample) => sample.delay);
  const earlyGain = amounts[2] - amounts[0];
  const lateGain = amounts.at(-1) - amounts.at(-3);
  assert(amounts.every((amount, index) => index === 0 || amount > amounts[index - 1]),
    `${label} amount did not increase continuously`, samples);
  assert(delays.every((delay, index) => index === 0 ||
      delay <= delays[index - 1] || (delays[index - 1] === 0 && delay === 1)),
    `${label} repeat delay did not decrease continuously`, samples);
  assert(lateGain > earlyGain * 2,
    `${label} did not progressively accelerate`, { earlyGain, lateGain, samples });
  assert(lateGain >= 80 && lateGain <= 140,
    `${label} one-tick transfer rate does not match the 236.7 Hz MASM clock`,
    { lateGain, samples });
}

async function selectAmount() {
  for (let prompt = 0; prompt < 16; ++prompt) {
    const current = await state();
    if (current.delay === 0x23 && current.input === 0) return current;
    await pulse(32);
  }
  throw new Error(`amount selector not reached: ${JSON.stringify(await state())}`);
}

async function holdUpAndSample() {
  await page.evaluate(() => window.__zeliard._zeliard_key_down(38));
  const samples = [];
  for (let interval = 0; interval < 12; ++interval) {
    await tick(250);
    samples.push(await state());
  }
  await page.evaluate(() => window.__zeliard._zeliard_key_up(38));
  await tick(80);
  return samples;
}

async function enterBank() {
  await page.goto(url, { waitUntil: 'domcontentloaded' });
  await page.waitForFunction(() => window.__zeliard !== undefined,
    null, { timeout: 120000 });
  await page.click('#start');
  await page.evaluate(() => {
    const m = window.__zeliard;
    m._zeliard_opening_set_phase_for_test(3);
    m._zeliard_key(13);
    m._zeliard_tick(0);
    m._zeliard_key_down(39);
    let ticks = 0;
    while (m._zeliard_town_area() !== 1 && ticks++ < 3000) m._zeliard_tick(20);
    m._zeliard_key_up(39);
    m._zeliard_tick(20);
    m._zeliard_test_game_set_u8(0x85, 0);
    m._zeliard_test_game_set_u8(0x86, 0xE8);
    m._zeliard_test_game_set_u8(0x87, 0x03);
    m._zeliard_test_enter_room(7);
    while ((m._zeliard_room_kind() !== 7 || m._zeliard_room_input_kind() === 0) &&
           ticks++ < 9000) m._zeliard_tick(20);
  });
}

try {
  await enterBank();
  /* 213BANKP's opening menu is entered through 106TOWN's selection driver;
   * two Down pulses select Deposit from its initial row. */
  await pulse(40);
  await pulse(40);
  await pulse(32);
  const depositStart = await selectAmount();
  assert(depositStart.ip === 0xA2DA, 'deposit selector stopped at wrong MASM IP', depositStart);
  const depositSamples = await holdUpAndSample();
  assertAccelerates(depositSamples, 'deposit');
  const depositSelected = await state();
  await pulse(32);
  const depositCommitted = await state();
  assert(depositCommitted.carried === 1000 - depositSelected.amount,
    'deposit did not subtract the selected amount', { depositSelected, depositCommitted });
  assert(depositCommitted.banked === depositSelected.amount,
    'deposit did not add the selected amount', { depositSelected, depositCommitted });
  assert(depositCommitted.spaceLatch === 0 && depositCommitted.input !== 0,
    'deposit confirm Space was replayed after the transaction', depositCommitted);

  await pulse(40);
  await pulse(32);
  const withdrawStart = await selectAmount();
  assert(withdrawStart.ip === 0xA479, 'withdraw selector stopped at wrong MASM IP', withdrawStart);
  const withdrawSamples = await holdUpAndSample();
  assertAccelerates(withdrawSamples, 'withdraw');
  const withdrawSelected = await state();
  const beforeWithdraw = {
    carried: withdrawSelected.carried,
    banked: withdrawSelected.banked,
  };
  await pulse(32);
  const withdrawCommitted = await state();
  assert(withdrawCommitted.carried === beforeWithdraw.carried + withdrawSelected.amount,
    'withdraw did not add the selected amount', { withdrawSelected, withdrawCommitted });
  assert(withdrawCommitted.banked === beforeWithdraw.banked - withdrawSelected.amount,
    'withdraw did not subtract the selected amount', { withdrawSelected, withdrawCommitted });
  assert(withdrawCommitted.spaceLatch === 0 && withdrawCommitted.input !== 0,
    'withdraw confirm Space was replayed after the transaction', withdrawCommitted);

  console.log(JSON.stringify({
    verdict: 'PASS',
    deposit: {
      start: depositStart,
      samples: depositSamples,
      selected: depositSelected.amount,
      committed: depositCommitted,
    },
    withdraw: {
      start: withdrawStart,
      samples: withdrawSamples,
      selected: withdrawSelected.amount,
      committed: withdrawCommitted,
    },
  }));
} finally {
  await browser.close();
}
