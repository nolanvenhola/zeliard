import { chromium } from 'playwright';

const url = process.argv[2] ?? 'http://127.0.0.1:5177/';
const capturePrefix = process.argv[3] ?? '';
const browser = await chromium.launch({ headless: true });
const page = await browser.newPage();
const errors = [];
page.on('pageerror', error => errors.push(error.message));
page.on('console', message => {
  if (message.type() === 'error')
    console.log(`browser:${message.type()}: ${message.text()}`);
});

try {
  await page.goto(url, { waitUntil: 'domcontentloaded' });
  await page.waitForFunction(() => window.__zeliard !== undefined,
    null, { timeout: 120000 });
  await page.waitForSelector('#start:not([hidden])', { timeout: 120000 });
  await page.click('#start');

  const entry = await page.evaluate(() => {
    const m = window.__zeliard;
    m._zeliard_opening_set_phase_for_test(3);
    m._zeliard_key(13);
    m._zeliard_tick(0);
    const started = m._zeliard_test_restart_fight(
      8, 22 - 16, (9 - 9) & 0x3f, 12);
    for (let frame = 0; frame < 12; ++frame) m._zeliard_tick(20);
    const pixels = m.HEAPU8.subarray(
      m._zeliard_framebuf(), m._zeliard_framebuf() + 64000);
    let visible = 0;
    for (let y = 0; y < 158; ++y)
      for (let x = 48; x < 272; ++x)
        visible += pixels[y * 320 + x] !== 0;
    return {
      started,
      active: m._zeliard_fight_active(),
      width: m._zeliard_fight_map_width(),
      chunk: m._zeliard_fight_music_chunk(),
      music: m._zeliard_music_track(),
      exactAudio: m._zeliard_exact_music_driver(),
      visible,
    };
  });
  const boss = await page.evaluate(() => {
    const m = window.__zeliard;
    m._zeliard_test_game_set_u8(0x98, 1);
    m._zeliard_test_game_set_u8(0x9d, 3);  // Fuego selected
    m._zeliard_test_game_set_u8(0xab, 6);  // Espada charge
    m._zeliard_test_game_set_u8(0xac, 6);  // Saeta charge
    m._zeliard_test_game_set_u8(0xad, 6);  // Fuego charge
    m._zeliard_test_game_set_u8(0xbb, 0xff);
    m._zeliard_test_game_set_u8(0xbc, 0xff);
    m._zeliard_test_game_set_u8(0xbd, 0xff);
    const started = m._zeliard_test_restart_fight(
      8, 224 - 16, (18 - 9) & 0x3f, 12);
    m._zeliard_key_down(38);
    let ticks = 0;
    let encounterStart = 0;
    let encounterFinish = 0;
    let sawBossMusic = false;
    while (m._zeliard_fight_active() && ticks++ < 2200) {
      if (encounterStart) m._zeliard_key_up(38);
      m._zeliard_tick(20);
      if (!encounterStart && m._zeliard_fight_map_width() === 73)
        encounterStart = ticks;
      sawBossMusic ||= m._zeliard_fight_music_chunk() === 94;
      if (encounterStart && !encounterFinish &&
          m._zeliard_fight_ip() === 0x629c) {
        encounterFinish = ticks;
        break;
      }
    }
    m._zeliard_key_up(38);
    const pixels = m.HEAPU8.subarray(
      m._zeliard_framebuf(), m._zeliard_framebuf() + 64000);
    let visible = 0;
    for (let y = 0; y < 158; ++y)
      for (let x = 48; x < 272; ++x)
        visible += pixels[y * 320 + x] !== 0;
    return {
      started,
      active: m._zeliard_fight_active(),
      width: m._zeliard_fight_map_width(),
      chunk: m._zeliard_fight_music_chunk(),
      music: m._zeliard_music_track(),
      encounterStart, encounterFinish, sawBossMusic, ticks, visible,
      intro: m._zeliard_test_game_u8(0xC3),
    };
  });
  const spellSwitch = await page.evaluate(() => {
    const m = window.__zeliard;
    /* Exercise the shared spell selector/cast path in an ordinary Riza
     * cavern room, independently of the Agar encounter overlay. */
    const regularStarted = m._zeliard_test_restart_fight(
      8, 22 - 16, (9 - 9) & 0x3f, 12);
    for (let frame = 0; frame < 12; ++frame) m._zeliard_tick(20);
    const tickKey = (key, ticks = 90) => {
      m._zeliard_key_down(key);
      m._zeliard_tick(ticks);
      m._zeliard_key_up(key);
      m._zeliard_tick(ticks);
    };
    const frameHash = () => {
      const frame = m.HEAPU8.subarray(
        m._zeliard_framebuf(), m._zeliard_framebuf() + 64000);
      let hash = 0xcbf29ce484222325n;
      for (let y = 0; y < 158; ++y)
        for (let x = 0; x < 320; ++x) {
          hash ^= BigInt(frame[y * 320 + x]);
          hash = BigInt.asUintN(64, hash * 0x100000001b3n);
        }
      return hash.toString(16).padStart(16, '0');
    };
    /* Exact reported sequence: cast the town-selected Fuego once before
     * opening the cavern inventory and changing the selected spell. */
    m._zeliard_key_down(18);
    let initialCastActive = false;
    let initialCastReleased = false;
    for (let frame = 0; frame < 128; ++frame) {
      m._zeliard_tick(20);
      if (m._zeliard_test_game_u8(0xff3e)) {
        initialCastActive = true;
        if (!initialCastReleased) {
          m._zeliard_key_up(18);
          initialCastReleased = true;
        }
      } else if (initialCastActive) break;
    }
    if (!initialCastReleased) m._zeliard_key_up(18);
    tickKey(13);
    const opened = m._zeliard_inventory_active() !== 0;
    tickKey(37);
    const selectedInInventory = m._zeliard_test_game_u8(0x9d);
    tickKey(13);
    const closed = m._zeliard_inventory_active() === 0;
    const selectedAfter = m._zeliard_test_game_u8(0x9d);
    const selectedInFight = m._zeliard_test_fight_u8(0x9d);

    const pixels = m.HEAPU8.subarray(
      m._zeliard_framebuf(), m._zeliard_framebuf() + 64000);
    let iconHash = 0xcbf29ce484222325n;
    for (let y = 164; y < 180; ++y)
      for (let x = 222; x < 238; ++x) {
        iconHash ^= BigInt(pixels[y * 320 + x]);
        iconHash = BigInt.asUintN(64, iconHash * 0x100000001b3n);
      }

    m._zeliard_key_down(18);
    let castTicks = 0;
    let sawActive = false;
    let sawProjectile = false;
    let slotFrame = 0;
    let slotDirection = 0;
    let castKeyReleased = false;
    const saetaRendered = [];
    while (castTicks++ < 64) {
      m._zeliard_tick(20);
      if (m._zeliard_test_game_u8(0xff3e) !== 0) {
        sawActive = true;
        if (!castKeyReleased) {
          m._zeliard_key_up(18);
          castKeyReleased = true;
        }
        slotFrame = m._zeliard_test_fight_u8(0xeb19);
        slotDirection = m._zeliard_test_fight_u8(0xeb1a);
        sawProjectile = slotFrame !== 0;
        if (saetaRendered.length < 16) saetaRendered.push(frameHash());
      } else if (sawActive) break;
    }
    if (!castKeyReleased) m._zeliard_key_up(18);

    tickKey(13);
    const fuegoOpened = m._zeliard_inventory_active() !== 0;
    tickKey(39);
    const fuegoSelectedInInventory = m._zeliard_test_game_u8(0x9d);
    tickKey(13);
    const fuegoClosed = m._zeliard_inventory_active() === 0;
    const fuegoSelectedAfter = m._zeliard_test_game_u8(0x9d);
    const fuegoSelectedInFight = m._zeliard_test_fight_u8(0x9d);
    let fuegoIconHash = 0xcbf29ce484222325n;
    const fuegoPixels = m.HEAPU8.subarray(
      m._zeliard_framebuf(), m._zeliard_framebuf() + 64000);
    for (let y = 164; y < 180; ++y)
      for (let x = 222; x < 238; ++x) {
        fuegoIconHash ^= BigInt(fuegoPixels[y * 320 + x]);
        fuegoIconHash = BigInt.asUintN(
          64, fuegoIconHash * 0x100000001b3n);
      }
    m._zeliard_key_down(18);
    let fuegoTicks = 0;
    let fuegoActive = false;
    let fuegoProjectile = false;
    let fuegoSlotFrame = 0;
    let fuegoSlotDirection = 0;
    let fuegoKeyReleased = false;
    const fuegoRendered = [];
    while (fuegoTicks++ < 96) {
      m._zeliard_tick(20);
      if (m._zeliard_test_game_u8(0xff3e) !== 0) {
        fuegoActive = true;
        if (!fuegoKeyReleased) {
          m._zeliard_key_up(18);
          fuegoKeyReleased = true;
        }
        fuegoSlotFrame = m._zeliard_test_fight_u8(0xeb19);
        fuegoSlotDirection = m._zeliard_test_fight_u8(0xeb1a);
        fuegoProjectile = fuegoSlotFrame !== 0;
        if (fuegoRendered.length < 16) fuegoRendered.push(frameHash());
      } else if (fuegoActive) break;
    }
    if (!fuegoKeyReleased) m._zeliard_key_up(18);

    tickKey(13);
    const espadaOpened = m._zeliard_inventory_active() !== 0;
    tickKey(37);
    tickKey(37);
    const espadaSelectedInInventory = m._zeliard_test_game_u8(0x9d);
    tickKey(13);
    const espadaClosed = m._zeliard_inventory_active() === 0;
    const espadaSelectedAfter = m._zeliard_test_game_u8(0x9d);
    const espadaSelectedInFight = m._zeliard_test_fight_u8(0x9d);
    let espadaIconHash = 0xcbf29ce484222325n;
    const espadaPixels = m.HEAPU8.subarray(
      m._zeliard_framebuf(), m._zeliard_framebuf() + 64000);
    for (let y = 164; y < 180; ++y)
      for (let x = 222; x < 238; ++x) {
        espadaIconHash ^= BigInt(espadaPixels[y * 320 + x]);
        espadaIconHash = BigInt.asUintN(
          64, espadaIconHash * 0x100000001b3n);
      }
    m._zeliard_key_down(18);
    let espadaTicks = 0;
    let espadaActive = false;
    let espadaProjectile = false;
    let espadaSlotFrame = 0;
    let espadaSlotDirection = 0;
    let espadaKeyReleased = false;
    const espadaRendered = [];
    while (espadaTicks++ < 96) {
      m._zeliard_tick(20);
      if (m._zeliard_test_game_u8(0xff3e) !== 0) {
        espadaActive = true;
        if (!espadaKeyReleased) {
          m._zeliard_key_up(18);
          espadaKeyReleased = true;
        }
        espadaSlotFrame = m._zeliard_test_fight_u8(0xeb19);
        espadaSlotDirection = m._zeliard_test_fight_u8(0xeb1a);
        espadaProjectile = espadaSlotFrame !== 0;
        if (espadaRendered.length < 16) espadaRendered.push(frameHash());
      } else if (espadaActive) break;
    }
    if (!espadaKeyReleased) m._zeliard_key_up(18);
    return {
      regularStarted,
      initialCastActive,
      spellSpritePointers: Array.from({length: 12}, (_, index) =>
        m._zeliard_test_fight_u8(0x8c81 + index)),
      opened, selectedInInventory, closed,
      selectedAfter, selectedInFight,
      iconHash: iconHash.toString(16).padStart(16, '0'),
      sawActive, sawProjectile, slotFrame, slotDirection, castTicks,
      saetaRendered,
      fuegoOpened, fuegoSelectedInInventory, fuegoClosed,
      fuegoSelectedAfter, fuegoSelectedInFight,
      fuegoIconHash: fuegoIconHash.toString(16).padStart(16, '0'),
      fuegoActive, fuegoProjectile, fuegoSlotFrame, fuegoSlotDirection,
      fuegoTicks,
      fuegoRendered,
      espadaOpened, espadaSelectedInInventory, espadaClosed,
      espadaSelectedAfter, espadaSelectedInFight,
      espadaIconHash: espadaIconHash.toString(16).padStart(16, '0'),
      espadaActive, espadaProjectile, espadaSlotFrame,
      espadaSlotDirection, espadaTicks,
      espadaRendered,
    };
  });
  if (capturePrefix) {
    await page.waitForTimeout(100);
    await page.locator('#screen').screenshot({
      path: `${capturePrefix}-agar.png`,
    });
    await page.evaluate(() => {
      const m = window.__zeliard;
      m._zeliard_test_restart_fight(8, 22 - 16, 0, 12);
      for (let frame = 0; frame < 12; ++frame) m._zeliard_tick(20);
    });
    await page.waitForTimeout(100);
    await page.locator('#screen').screenshot({
      path: `${capturePrefix}-glacial.png`,
    });
  }

  if (!entry.started || !entry.active || entry.width !== 320 ||
      entry.chunk !== 89 || entry.music !== 12 || !entry.exactAudio ||
      entry.visible < 1000 || !boss.started || !boss.active ||
      boss.width !== 73 || boss.chunk !== 94 || !boss.sawBossMusic ||
      !boss.encounterStart || !boss.encounterFinish || boss.intro !== 0 ||
      boss.visible < 1000 || !spellSwitch.regularStarted ||
      !spellSwitch.initialCastActive ||
      !spellSwitch.opened ||
      spellSwitch.selectedInInventory !== 2 || !spellSwitch.closed ||
      spellSwitch.selectedAfter !== 2 || spellSwitch.selectedInFight !== 2 ||
      spellSwitch.iconHash !== '38ec34bd15886153' ||
      !spellSwitch.sawActive || !spellSwitch.sawProjectile ||
      spellSwitch.slotDirection !== 0 || !spellSwitch.fuegoOpened ||
      spellSwitch.saetaRendered[4] !== 'bc69b2a557768615' ||
      spellSwitch.saetaRendered[9] !== 'cd90101bc5add762' ||
      spellSwitch.fuegoSelectedInInventory !== 3 ||
      !spellSwitch.fuegoClosed || spellSwitch.fuegoSelectedAfter !== 3 ||
      spellSwitch.fuegoSelectedInFight !== 3 ||
      spellSwitch.fuegoIconHash !== '27be1bb89569ff7d' ||
      !spellSwitch.fuegoActive || !spellSwitch.fuegoProjectile ||
      spellSwitch.fuegoSlotDirection !== 4 || !spellSwitch.espadaOpened ||
      spellSwitch.fuegoRendered[4] !== '88781c7d97790396' ||
      spellSwitch.fuegoRendered[9] !== 'dd3db50b8ea15672' ||
      spellSwitch.espadaSelectedInInventory !== 1 ||
      !spellSwitch.espadaClosed || spellSwitch.espadaSelectedAfter !== 1 ||
      spellSwitch.espadaSelectedInFight !== 1 ||
      spellSwitch.espadaIconHash !== '4b78edcb41024ae4' ||
      !spellSwitch.espadaActive || !spellSwitch.espadaProjectile ||
      spellSwitch.espadaRendered[4] !== 'd10bf622427f01f1' ||
      spellSwitch.espadaRendered[9] !== '920a30762d6f3c08' ||
      spellSwitch.espadaSlotDirection !== 1)
    throw new Error(`Glacial browser parity failed: ${JSON.stringify({entry, boss, spellSwitch})}`);
  if (errors.length)
    throw new Error(`browser errors: ${JSON.stringify(errors)}`);
  console.log(`glacial_browser: PASS width=${entry.width} ` +
    `music=${entry.chunk}/${entry.music} visible=${entry.visible}`);
  console.log(`agar_encounter_browser: PASS ticks=${boss.ticks} ` +
    `start=${boss.encounterStart} finish=${boss.encounterFinish} ` +
    `music=${boss.chunk}/${boss.music} visible=${boss.visible}`);
  console.log(`agar_spell_switch_browser: PASS ${JSON.stringify(spellSwitch)}`);
  console.log('VERDICT: PASS: Glacial runtime and exact Agar entrance');
} finally {
  await browser.close();
}
