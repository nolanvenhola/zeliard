import { chromium } from 'playwright';

const url = process.argv[2] ?? 'http://127.0.0.1:5177/';
const capturePrefix = process.argv[3] ?? '';
const browser = await chromium.launch({ headless: true });
const page = await browser.newPage();
const errors = [];
page.on('pageerror', error => errors.push(error.message));

async function capture(name) {
  if (!capturePrefix) return;
  await page.waitForTimeout(20);
  await page.locator('#screen').screenshot({
    path: `${capturePrefix}-${name}.png`,
  });
}

try {
  await page.goto(url, { waitUntil: 'domcontentloaded' });
  await page.waitForFunction(() => window.__zeliard !== undefined,
    null, { timeout: 120000 });
  await page.waitForSelector('#start:not([hidden])', { timeout: 120000 });
  await page.click('#start');

  const result = await page.evaluate(() => {
    const m = window.__zeliard;
    m._zeliard_opening_set_phase_for_test(3);
    m._zeliard_key(13);
    m._zeliard_tick(0);
    m._zeliard_key_down(39);
    let townTicks = 0;
    while (m._zeliard_town_area() !== 1 && townTicks++ < 3000)
      m._zeliard_tick(20);
    m._zeliard_key_up(39);

    /* Muralla's authored cavern door: enter the same ROKA transition used
       by normal play, then let main.c start MP10. */
    m._zeliard_test_game_set_u8(0x80, 0xB9);
    m._zeliard_test_game_set_u8(0x81, 0);
    m._zeliard_test_game_set_u8(0x83, 0x10);
    m._zeliard_key_down(38);
    let entryTicks = 0;
    while (!m._zeliard_cavern_transition_active() && entryTicks++ < 100)
      m._zeliard_tick(20);
    m._zeliard_key_up(38);
    while (!m._zeliard_cavern_transition_complete() && entryTicks++ < 1200)
      m._zeliard_tick(20);
    while (!m._zeliard_fight_active() && entryTicks++ < 1300)
      m._zeliard_tick(20);
    const maliciaWidth = m._zeliard_fight_map_width();

    /* MP10 x=95/y=50 -> MP21 x=15/y=50 (selector 03). */
    const maliciaRestart = m._zeliard_test_restart_fight(
      0, 95 - 16, (50 - 9) & 0x3F, 0);
    const maliciaMusic = m._zeliard_music_track();
    const maliciaLevel = m._zeliard_test_game_u8(0xC8);
    m._zeliard_key_down(38);
    let connectorTicks = 0;
    while (m._zeliard_fight_map_width() !== 96 && connectorTicks++ < 200)
      m._zeliard_tick(20);
    m._zeliard_key_up(38);
    const connectorWidth = m._zeliard_fight_map_width();
    const connectorLevel = m._zeliard_test_game_u8(0xC8);
    const connectorMusic = m._zeliard_music_track();
    const connectorFadeStart = m._zeliard_music_attenuation();
    let connectorFadePeak = connectorFadeStart;
    /* Remain inside MP21 long enough to prove attenuation progresses over
       the connector itself rather than switching scores at its entrance. */
    for (let fadeTick = 0; fadeTick < 80; ++fadeTick) {
      m._zeliard_tick(20);
      connectorFadePeak = Math.max(connectorFadePeak,
        m._zeliard_music_attenuation());
    }

    /* MP21 x=66/y=35 -> MP20 x=146/y=35 (selector 02). */
    /* Move the still-running exact MP21 VM to its authored far door.  Do not
       restart it: the music fade and level handoff are persistent VM state. */
    m._zeliard_test_game_set_u8(0x80, 66 - 16);
    m._zeliard_test_game_set_u8(0x81, 0);
    m._zeliard_test_game_set_u8(0x82, (35 - 9) & 0x3F);
    m._zeliard_test_game_set_u8(0x83, 0);
    const connectorRestart = 1;
    m._zeliard_key_down(38);
    let peligroTicks = 0;
    while (m._zeliard_fight_map_width() !== 224 && peligroTicks++ < 200) {
      m._zeliard_tick(20);
      connectorFadePeak = Math.max(connectorFadePeak,
        m._zeliard_music_attenuation());
    }
    m._zeliard_key_up(38);
    /* Allow the destination's normal gameplay frame to complete. */
    for (let i = 0; i < 4; ++i) m._zeliard_tick(20);

    const frame = m.HEAPU8.subarray(
      m._zeliard_framebuf(), m._zeliard_framebuf() + 64000);
    let visible = 0;
    for (let y = 0; y < 158; ++y)
      for (let x = 48; x < 272; ++x)
        visible += frame[y * 320 + x] !== 0;
    return {
      townTicks, entryTicks, connectorTicks, peligroTicks,
      maliciaWidth, connectorWidth, maliciaRestart, connectorRestart,
      maliciaMusic, connectorMusic, maliciaLevel, connectorLevel,
      connectorFadeStart, connectorFadePeak,
      peligroWidth: m._zeliard_fight_map_width(),
      peligroChunk: m._zeliard_fight_music_chunk(),
      music: m._zeliard_music_track(),
      active: m._zeliard_fight_active(),
      visible,
      position: [m._zeliard_test_game_u8(0x80),
        m._zeliard_test_game_u8(0x82), m._zeliard_test_game_u8(0x83)],
    };
  });

  await capture('peligro');
  const combatAndBoss = await page.evaluate(() => {
    const m = window.__zeliard;
    /* Representative Peligro combat at the same authored enemy checkpoint
       used by peligro_runtime_native.c. */
    const combatRestart = m._zeliard_test_restart_fight(
      2, 0, (38 - 9) & 0x3F, 0);
    m._zeliard_test_game_set_u8(0x92, 1);
    m._zeliard_test_game_set_u8(0x93, 1);
    for (let settle = 0; settle < 5; ++settle) m._zeliard_tick(20);
    const combatBefore = Uint8Array.from(m.HEAPU8.subarray(
      m._zeliard_framebuf(), m._zeliard_framebuf() + 64000));
    const cueBefore = m._zeliard_audio_cue_serial();
    let attackSeen = false;
    m._zeliard_key_down(32);
    for (let tick = 0; tick < 40; ++tick) {
      m._zeliard_tick(20);
      attackSeen ||= m._zeliard_test_game_u8(0xFF45) !== 0;
    }
    m._zeliard_key_up(32);
    const cueDelta = m._zeliard_audio_cue_serial() - cueBefore;
    const combatAfter = m.HEAPU8.subarray(
      m._zeliard_framebuf(), m._zeliard_framebuf() + 64000);
    const combatDiff = combatAfter.reduce((count, value, index) =>
      count + (value !== combatBefore[index]), 0);

    /* MP20 x=190/y=47 is the canonical Pulpo arena door. */
    m._zeliard_test_game_set_u8(0xC3, 0);
    const bossRestart = m._zeliard_test_restart_fight(
      2, 190 - 16, (47 - 9) & 0x3F, 0);
    m._zeliard_key_down(38);
    let bossTicks = 0;
    while (m._zeliard_fight_map_width() !== 52 && bossTicks++ < 200)
      m._zeliard_tick(20);
    m._zeliard_key_up(38);
    const bossChunkAtEntry = m._zeliard_fight_music_chunk();
    const bossMusicAtEntry = m._zeliard_music_track();
    const bossDoorWidth = m._zeliard_fight_map_width();

    /* Do not skip from the door straight to selector 04.  The release
       FIGHT module owns a long, host-presented sequence here: reverse ROKA
       run, animated ENCOUNTER art, chamber wipe, and Pulpo emergence. */
    const entranceFrames = new Set();
    const entranceFrameHash = () => {
      const pixels = m.HEAPU8.subarray(
        m._zeliard_framebuf(), m._zeliard_framebuf() + 64000);
      let hash = 2166136261;
      for (let i = 0; i < pixels.length; i += 13)
        hash = Math.imul(hash ^ pixels[i], 16777619) >>> 0;
      return hash;
    };
    let encounterTicks = 0;
    let sawBossMusic = false;
    let encounterFinished = false;
    while (!encounterFinished && encounterTicks++ < 2000) {
      m._zeliard_tick(20);
      entranceFrames.add(entranceFrameHash());
      sawBossMusic ||= m._zeliard_fight_music_chunk() === 94 &&
        m._zeliard_music_track() === 8;
      encounterFinished = sawBossMusic && m._zeliard_fight_ip() === 0x629c;
    }
    /* 629Ch is the first gameplay boundary after the chamber wipe.  Pulpo
       continues emerging across subsequent presented frames. */
    for (let tick = 0; encounterFinished && tick < 64; ++tick) {
      m._zeliard_tick(20);
      entranceFrames.add(entranceFrameHash());
    }
    const bossIntroFlag = m._zeliard_test_game_u8(0xC3);
    const entranceUniqueFrames = entranceFrames.size;
    const entranceFinalWidth = m._zeliard_fight_map_width();
    const entranceFinalChunk = m._zeliard_fight_music_chunk();
    const entranceFinalMusic = m._zeliard_music_track();
    return {
      combatRestart, attackSeen, cueDelta, combatDiff, bossRestart, bossTicks,
      bossDoorWidth, bossChunkAtEntry, bossMusicAtEntry,
      encounterTicks, sawBossMusic, encounterFinished, bossIntroFlag,
      entranceUniqueFrames, entranceFinalWidth, entranceFinalChunk,
      entranceFinalMusic,
      active: m._zeliard_fight_active(),
    };
  });

  /* Keep the synthetic post-boss reward fixture independent from the live
     entrance route.  The latter intentionally leaves a real, moving Pulpo
     chamber active and must not be treated as fixture setup. */
  await page.reload({ waitUntil: 'domcontentloaded' });
  await page.waitForFunction(() => window.__zeliard !== undefined,
    null, { timeout: 120000 });
  await page.waitForSelector('#start:not([hidden])', { timeout: 120000 });
  await page.click('#start');
  const victory = await page.evaluate(() => {
    const m = window.__zeliard;
    m._zeliard_opening_set_phase_for_test(3);
    m._zeliard_key(13);
    m._zeliard_tick(0);
    m._zeliard_test_game_set_u8(0x90, 0);
    m._zeliard_test_game_set_u8(0x91, 1);
    const bossDirect = m._zeliard_test_restart_fight(4, 0x08, 0x09, 0);
    const bossDirectWidth = m._zeliard_fight_map_width();
    const bossDirectChunk = m._zeliard_fight_music_chunk();
    const bossDirectMusic = m._zeliard_music_track();
    const tearsBefore = m._zeliard_test_game_u8(0xA0);
    const defeatStarted = m._zeliard_test_defeat_pulpo();
    let deathTicks = 0;
    while (m._zeliard_test_game_u8(0xFF30) !== 0xFF && deathTicks++ < 400)
      m._zeliard_tick(20);
    const completionSeen = m._zeliard_test_game_u8(0xFF30) === 0xFF;

    m._zeliard_key_down(39);
    for (let tick = 0; tick < 48; ++tick) m._zeliard_tick(20);
    m._zeliard_key_up(39);
    m._zeliard_key_down(37);
    for (let tick = 0; tick < 40; ++tick) m._zeliard_tick(20);
    m._zeliard_key_up(37);
    m._zeliard_key_down(38);
    let collectTicks = 0;
    let rokaStarted = false;
    while (!rokaStarted && collectTicks++ < 160) {
      m._zeliard_tick(20);
      const ip = m._zeliard_fight_ip();
      rokaStarted = ip >= 0xA009 && ip < 0xA5A8;
    }
    m._zeliard_key_up(38);
    let rokaTicks = 0;
    let sawRaisedSword = false;
    let sawCrystalLaunch = false;
    let sawCrystalMotion = false;
    let sawCrystalArrival = false;
    let sawFanfare = false;
    let rokaFinished = false;
    while (rokaStarted && !rokaFinished && rokaTicks++ < 1400) {
      m._zeliard_tick(20);
      const ip = m._zeliard_fight_ip();
      const inRoka = ip >= 0xA009 && ip < 0xA5A8;
      const pose = m._zeliard_test_fight_u8(0xE7);
      const crystalY = m._zeliard_test_fight_u8(0xA59C);
      const crystalX = m._zeliard_test_fight_u8(0xA59D);
      sawRaisedSword ||= inRoka && pose >= 5 && pose <= 9;
      sawCrystalLaunch ||= inRoka && crystalY === 0x94 && crystalX === 0x50;
      sawCrystalMotion ||= inRoka && crystalY < 0x94 && crystalY > 0x3C;
      sawCrystalArrival ||= inRoka && crystalY === 0x3C && crystalX === 0x02;
      sawFanfare ||= m._zeliard_fight_music_chunk() === 95 &&
        m._zeliard_music_track() === 10;
      rokaFinished = !inRoka && sawCrystalArrival &&
        m._zeliard_fight_map_width() === 224;
    }
    return {
      bossDirect, bossDirectWidth, bossDirectChunk, bossDirectMusic,
      defeatStarted, deathTicks, completionSeen, collectTicks,
      rokaStarted, rokaTicks, rokaFinished, sawRaisedSword,
      sawCrystalLaunch, sawCrystalMotion, sawCrystalArrival, sawFanfare,
      tearsBefore, tearsAfter: m._zeliard_test_game_u8(0xA0),
      active: m._zeliard_fight_active(),
    };
  });
  if (result.maliciaWidth !== 240 || result.connectorWidth !== 96 ||
      result.peligroWidth !== 224 || !result.active ||
      !result.maliciaRestart || !result.connectorRestart ||
      result.maliciaMusic !== 7 || result.connectorMusic !== 7 ||
      result.connectorFadeStart < 1 ||
      result.connectorFadePeak <= result.connectorFadeStart ||
      result.music !== 9 || result.visible < 1000)
    throw new Error(`Peligro route failed: ${JSON.stringify(result)}`);
  if (!combatAndBoss.combatRestart || combatAndBoss.cueDelta < 1 ||
      combatAndBoss.combatDiff < 100 || !combatAndBoss.bossRestart ||
      combatAndBoss.bossDoorWidth !== 52 ||
      !combatAndBoss.encounterFinished || !combatAndBoss.sawBossMusic ||
      combatAndBoss.bossIntroFlag !== 0x40 ||
      combatAndBoss.entranceUniqueFrames < 25 ||
      combatAndBoss.entranceFinalWidth !== 52 ||
      combatAndBoss.entranceFinalChunk !== 94 ||
      combatAndBoss.entranceFinalMusic !== 8 || !combatAndBoss.active)
    throw new Error(`Peligro combat/entrance failed: ${JSON.stringify(combatAndBoss)}`);
  if (!victory.bossDirect || victory.bossDirectWidth !== 52 ||
      victory.bossDirectChunk !== 94 || victory.bossDirectMusic !== 8 ||
      !victory.defeatStarted || !victory.completionSeen ||
      !victory.rokaStarted || !victory.rokaFinished ||
      !victory.sawRaisedSword || !victory.sawCrystalLaunch ||
      !victory.sawCrystalMotion || !victory.sawCrystalArrival ||
      !victory.sawFanfare ||
      victory.tearsAfter !== victory.tearsBefore + 1 || !victory.active)
    throw new Error(`Peligro victory failed: ${JSON.stringify(victory)}`);
  if (errors.length) throw new Error(`browser errors: ${JSON.stringify(errors)}`);
  console.log(`peligro_browser: PASS Malicia=${result.maliciaWidth} ` +
    `MP21=${result.connectorWidth} Peligro=${result.peligroWidth} ` +
    `music=${result.maliciaMusic}>${result.connectorMusic}>${result.music} ` +
    `fade=${result.connectorFadeStart}>${result.connectorFadePeak} visible=${result.visible} ` +
    `ticks=${result.connectorTicks}/${result.peligroTicks}`);
  console.log(`peligro_browser_combat: PASS cues=${combatAndBoss.cueDelta} ` +
    `frameDiff=${combatAndBoss.combatDiff} Pulpo=${combatAndBoss.entranceFinalWidth} ` +
    `chunk=${combatAndBoss.entranceFinalChunk} ticks=${combatAndBoss.bossTicks}`);
  console.log(`peligro_browser_encounter: PASS ticks=${combatAndBoss.encounterTicks} ` +
    `frames=${combatAndBoss.entranceUniqueFrames} intro=0x${combatAndBoss.bossIntroFlag.toString(16)} ` +
    `chunk=${combatAndBoss.entranceFinalChunk}`);
  console.log(`peligro_browser_victory: PASS death=${victory.deathTicks} ` +
    `collect=${victory.collectTicks} roka=${victory.rokaTicks} ` +
    `tears=${victory.tearsBefore}->${victory.tearsAfter}`);
  console.log('VERDICT: PASS: Malicia -> MP21 -> Peligro -> Pulpo victory');
} finally {
  await browser.close();
}
