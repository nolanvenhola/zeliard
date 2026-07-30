#!/usr/bin/env node
/*
 * Copies the canonical loose data files from
 *   3_Assembly/masm/working/zelresN/data/
 * into the web-port asset tree at
 *   6_WebPort/engine/assets/   (Emscripten --preload-file source)
 *   6_WebPort/shell/public/assets/   (Vite dev-server static dir)
 *
 * Renames each file to a short canonical name (e.g. 131TTL3G.grp -> ttl3.grp)
 * to keep the C code readable.
 */
import { copyFileSync, mkdirSync, existsSync, readFileSync, rmSync, statSync, writeFileSync } from 'node:fs';
import { createHash } from 'node:crypto';
import { dirname, basename, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const REPO_ROOT = resolve(__dirname, '..', '..');
const SRC_BASE  = join(REPO_ROOT, '3_Assembly', 'masm', 'working');
const DEST_ENGINE = join(REPO_ROOT, '6_WebPort', 'engine', 'assets');
const DEST_SHELL  = join(REPO_ROOT, '6_WebPort', 'shell', 'public', 'assets');
const DEST_AUDIO  = join(REPO_ROOT, '6_WebPort', 'shell', 'public', 'audio');
const MASM_OPDMO_BIN = '3_Assembly/masm/bin/zelres1/100OPDMO.bin';
const TRACKED_OPDMO_BIN = '3_Assembly/tasm/bin/zelres1/100OPDMO.bin';
const OPDMO_MASM_SHA256 = '424f2acbaec8c0395e5e72562ac6f6fd8bfa6f8b5c58a867fe1c5b21a6f51548';
const SNDADLIB_SHA256 = 'bf1c2036980f0557106ab0521be163fedb32458a187b4f49a60fee12b3b0a858';
const MSCADLIB_SHA256 = '3d972d619e94071c38c4b810f17054957aff46ad21b25a65f519a43f16158d4d';
const TINY86_BIOS_SHA256 = 'ba4b2e62246aaadeda8d90bc0928d4f00242c16039982163d7e82740dceb5e31';

function verifiedMasmOutput(relativePath, expectedHash) {
    const masm = join(REPO_ROOT, '3_Assembly', 'masm', 'bin', relativePath);
    const fallback = join(REPO_ROOT, '3_Assembly', 'tasm', 'bin', relativePath);
    const source = existsSync(masm) ? masm : fallback;
    const hash = createHash('sha256').update(readFileSync(source)).digest('hex');
    if (hash !== expectedHash)
        throw new Error(`${relativePath} does not match verified MASM release: ${hash}`);
    return source;
}

/* MASM release output is generated and ignored. CI uses the tracked TASM
 * release binary, which is byte-identical to the verified MASM build. */
const OPDMO_BIN = existsSync(join(REPO_ROOT, MASM_OPDMO_BIN))
    ? MASM_OPDMO_BIN
    : TRACKED_OPDMO_BIN;
const opdmoBytes = readFileSync(join(REPO_ROOT, OPDMO_BIN));
const opdmoHash = createHash('sha256').update(opdmoBytes).digest('hex');
if (opdmoHash !== OPDMO_MASM_SHA256) {
    throw new Error(`100OPDMO.bin does not match the verified MASM release: ${opdmoHash}`);
}

const sndadlibBytes = readFileSync(join(REPO_ROOT, '1_OriginalGame/sndadlib.drv'));
const sndadlibHash = createHash('sha256').update(sndadlibBytes).digest('hex');
if (sndadlibHash !== SNDADLIB_SHA256)
    throw new Error(`sndadlib.drv does not match the captured DOS driver: ${sndadlibHash}`);

const mscadlibBytes = readFileSync(join(REPO_ROOT, '1_OriginalGame/mscadlib.drv'));
const mscadlibHash = createHash('sha256').update(mscadlibBytes).digest('hex');
if (mscadlibHash !== MSCADLIB_SHA256)
    throw new Error(`mscadlib.drv does not match the original DOS driver: ${mscadlibHash}`);

const tiny86Bios = readFileSync(join(REPO_ROOT, '6_WebPort/engine/third_party/8086tiny/bios.bin'));
const tiny86BiosHash = createHash('sha256').update(tiny86Bios).digest('hex');
if (tiny86BiosHash !== TINY86_BIOS_SHA256)
    throw new Error(`8086tiny BIOS hash mismatch: ${tiny86BiosHash}`);

/* Map of {source file prefix} -> {short name used by C engine}.  Add entries
 * as new assets are wired up.  The number prefix on disk is the chunk
 * index; the short name matches the asm-level resource_name_table. */
const ASSET_MAP = [
    /* Bit-perfect MASM MCGA driver used for palette register lookups. */
    ['zelres1/code/105GDMCA.bin', '105GDMCA.bin'],
    /* zelres1 — opening cinematic images (resource_name_table at 100OPDMO.asm:2912) */
    ['zelres1/data/112FONTG.grp', 'font.grp'],
    ['zelres1/data/113AMEGP.grp', 'ame.grp'],
    ['zelres1/data/114DMAOU.grp', 'dmaou.grp'],
    ['zelres1/data/115HIMEG.grp', 'hime.grp'],
    ['zelres1/data/116HIMPG.grp', 'himp.grp'],
    ['zelres1/data/117HOUGP.grp', 'hou.grp'],
    ['zelres1/data/118ISIGP.grp', 'isi.grp'],
    ['zelres1/data/119MAOPG.grp', 'maop.grp'],
    ['zelres1/data/120NE80G.grp', 'ne80.grp'],
    ['zelres1/data/121NE81G.grp', 'ne81.grp'],
    ['zelres1/data/122NECGP.grp', 'nec.grp'],
    ['zelres1/data/123NEW1G.grp', 'new1.grp'],
    ['zelres1/data/124NEW2G.grp', 'new2.grp'],
    ['zelres1/data/125OUIGP.grp', 'oui.grp'],
    ['zelres1/data/126OUPGP.grp', 'oup.grp'],
    ['zelres1/data/127SEIGP.grp', 'sei.grp'],
    ['zelres1/data/128SEIPG.grp', 'seip.grp'],
    ['zelres1/data/129TTL1G.grp', 'ttl1.grp'],
    ['zelres1/data/130TTL2G.grp', 'ttl2.grp'],
    ['zelres1/data/131TTL3G.grp', 'ttl3.grp'],
    ['zelres1/data/132WAKUG.grp', 'waku.grp'],
    ['zelres1/data/133YUU1G.grp', 'yuu1.grp'],
    ['zelres1/data/134YUU2G.grp', 'yuu2.grp'],
    ['zelres1/data/135YUU3G.grp', 'yuu3.grp'],
    ['zelres1/data/136YUU4G.grp', 'yuu4.grp'],
    ['zelres1/data/137YUUPG.grp', 'yuup.grp'],
    ['zelres1/data/138ZENDM.msd', 'zend.msd'],
    ['zelres1/data/139ZOPNM.msd', 'zopn.msd'],
];

const EXTRA_ASSET_MAP = [
    ['1_OriginalGame/sndadlib.drv', 'sndadlib.drv'],
    ['1_OriginalGame/mscadlib.drv', 'mscadlib.drv'],
    ['6_WebPort/engine/third_party/8086tiny/bios.bin', '8086tiny-bios.bin'],
    ['3_Assembly/dumps/zeliard_title_image.BIN', 'title_full.bin'],
    [OPDMO_BIN, '100opdmo.bin'],
];

const GAME_BINARY_MAP = [
    [verifiedMasmOutput('stdply.bin', 'c2312fb031230d2cab839ee9f62cca415fbcd414011d884a30a38b66aae44fb8'), 'stdply.bin'],
    [verifiedMasmOutput('game.bin', '15b0f46e8113e6f8937d65df6c94358016fcd56c8de281506cb73c830978dc4c'), 'game.bin'],
    [verifiedMasmOutput('zelres1/105GDMCA.bin', '38b7b37bb040fd5d06c8be16017961a09b14a603d063c1841720d4f5771e8e0a'), 'gdmcga.bin'],
    [verifiedMasmOutput('zelres1/111GTMCA.bin', '1a3384ae85db5476165d09149bc12a31ae71d7c1f0a77a78e560ff0502a0e9c8'), 'gtmcga.bin'],
    [verifiedMasmOutput('zelres1/106TOWN.bin', 'bce0f4832d434867f17df2c5c416d3ece7b69bda78063c1b33d80f56dc6c942b'), 'town.bin'],
    [verifiedMasmOutput('zelres2/206GFMCA.bin', 'f30b5029001a3fa0b718608fcb99a4f9aa384fe5d447e5a234fe3a01298f56dd'), 'gfmcga.bin'],
    [verifiedMasmOutput('zelres2/200FIGHT.bin', 'cfb5c91d14c816e966f2c335c8e85a8c0baf60ca7cc9831b24a5088c99d40a77'), 'fight.bin'],
    [verifiedMasmOutput('zelres2/201SELCT.bin', '1814d4a7aa8ac97a913b339e55f95dbac32d7eeb069219a6f76e47fc3f3770a9'), 'select.bin'],
    [verifiedMasmOutput('zelres2/227ITMSG.grp', '6c46ca4c8af264c2c3dd5b286586efbff839a7c64f3d4c8714aead92d693ec28'), 'itemp.grp'],
    [verifiedMasmOutput('zelres2/228MAGCG.grp', '4d5f347dd02ce2b9f9dc33f12011bc99d2fd157de955fa17d938da3f75419628'), 'magic.grp'],
    [verifiedMasmOutput('zelres2/226SWRDG.grp', '761177e84da136124236b6e5c7f0622ba4f997506ad9f2327d97da86b8dcd73d'), 'sword.grp'],
    [verifiedMasmOutput('zelres2/207MOLE.bin', 'fa945314a8fd95b0ff6bb158f4fecf58c52ff05204e2e17b0de39c348f49a9bd'), 'mole.bin'],
];

const BINARY_SLICES = [
    /* Exact first rain/princess run_script_interpreter input:
     * runtime 79C6h through the SCR_BREAK at 7CACh, inclusive.
     * MASM oracle post_title_story_script_1 draws the leading 'P' before
     * the visible "Once..." text, then finishes with SI=7CADh.  File offset
     * maps through the stripped four-byte SAR chunk header. */
    [OPDMO_BIN, 0x19CA, 0x02E7, 'opdemo_story_script_1.bin'],
    [OPDMO_BIN, 0x1CB1, 0x0132, 'opdemo_story_script_2.bin'],
    [OPDMO_BIN, 0x1DE3, 0x00AE, 'opdemo_story_script_3.bin'],
    [OPDMO_BIN, 0x1E91, 0x00EB, 'opdemo_story_script_4.bin'],
    [OPDMO_BIN, 0x1F7C, 0x0001, 'opdemo_story_script_5.bin'],
    [OPDMO_BIN, 0x1F7D, 0x009D, 'opdemo_story_script_6.bin'],
    [OPDMO_BIN, 0x201A, 0x005B, 'opdemo_story_script_7.bin'],
    [OPDMO_BIN, 0x2075, 0x0004, 'opdemo_story_script_8.bin'],
    [OPDMO_BIN, 0x2079, 0x00C1, 'opdemo_story_script_9.bin'],
    [OPDMO_BIN, 0x213A, 0x00A2, 'opdemo_story_script_10.bin'],
    [OPDMO_BIN, 0x21DC, 0x004B, 'opdemo_story_script_11.bin'],
    [OPDMO_BIN, 0x2227, 0x0409, 'opdemo_story_script_12.bin'],
    [OPDMO_BIN, 0x2630, 0x0102, 'opdemo_story_script_13.bin'],
    [OPDMO_BIN, 0x2732, 0x00AD, 'opdemo_story_script_14.bin'],
    [OPDMO_BIN, 0x27DF, 0x0061, 'opdemo_story_script_15.bin'],
    [OPDMO_BIN, 0x2840, 0x0368, 'opdemo_story_script_16.bin'],
    [OPDMO_BIN, 0x2BA8, 0x0001, 'opdemo_story_script_17.bin'],
    [OPDMO_BIN, 0x2BA9, 0x0066, 'opdemo_story_script_18.bin'],
    [OPDMO_BIN, 0x2C0F, 0x0045, 'opdemo_story_script_19.bin'],
    [OPDMO_BIN, 0x2C54, 0x036C, 'opdemo_story_script_20.bin'],
    [OPDMO_BIN, 0x2FC0, 0x004D, 'opdemo_story_script_21.bin'],
    [OPDMO_BIN, 0x300D, 0x0057, 'opdemo_story_script_22.bin'],
];

function ensureDir(p) { mkdirSync(p, { recursive: true }); }

function copyOne(rel, dst) {
    const src = join(SRC_BASE, rel);
    if (!existsSync(src)) {
        console.error(`[copy_assets] MISSING: ${src}`);
        process.exitCode = 1;
        return false;
    }
    const dstA = join(DEST_ENGINE, dst);
    const dstB = join(DEST_SHELL,  dst);
    ensureDir(dirname(dstA));
    ensureDir(dirname(dstB));
    copyFileSync(src, dstA);
    copyFileSync(src, dstB);
    const sz = statSync(src).size;
    console.log(`[copy_assets] ${rel}  ->  ${dst}  (${sz} bytes)`);
    return true;
}

let ok = 0;
for (const [src, dst] of ASSET_MAP) {
    if (copyOne(src, dst)) ok++;
}
for (const [src, dst] of EXTRA_ASSET_MAP) {
    const fullSrc = join(REPO_ROOT, src);
    if (!existsSync(fullSrc)) {
        console.error(`[copy_assets] MISSING: ${fullSrc}`);
        process.exitCode = 1;
        continue;
    }
    const dstA = join(DEST_ENGINE, dst);
    const dstB = join(DEST_SHELL, dst);
    ensureDir(dirname(dstA));
    ensureDir(dirname(dstB));
    copyFileSync(fullSrc, dstA);
    copyFileSync(fullSrc, dstB);
    const sz = statSync(fullSrc).size;
    console.log(`[copy_assets] ${src}  ->  ${dst}  (${sz} bytes)`);
    ok++;
}
for (const [fullSrc, dst] of GAME_BINARY_MAP) {
    for (const base of [DEST_ENGINE, DEST_SHELL]) {
        ensureDir(base);
        copyFileSync(fullSrc, join(base, dst));
    }
    console.log(`[copy_assets] verified MASM ${basename(fullSrc)}  ->  ${dst}`);
    ok++;
}
for (const [src, offset, length, dst] of BINARY_SLICES) {
    const fullSrc = join(REPO_ROOT, src);
    if (!existsSync(fullSrc)) {
        console.error(`[copy_assets] MISSING: ${fullSrc}`);
        process.exitCode = 1;
        continue;
    }
    const source = readFileSync(fullSrc);
    const slice = source.subarray(offset, offset + length);
    if (slice.length !== length) {
        console.error(`[copy_assets] SLICE SHORT: ${src} offset=${offset} length=${length}`);
        process.exitCode = 1;
        continue;
    }
    for (const base of [DEST_ENGINE, DEST_SHELL]) {
        const output = join(base, dst);
        ensureDir(dirname(output));
        writeFileSync(output, slice);
    }
    console.log(`[copy_assets] ${src}[0x${offset.toString(16)}..+0x${length.toString(16)}]  ->  ${dst}  (${length} bytes)`);
    ok++;
}
console.log(`[copy_assets] ${ok}/${ASSET_MAP.length + EXTRA_ASSET_MAP.length + GAME_BINARY_MAP.length + BINARY_SLICES.length} files copied`);

for (const obsolete of [
    'zopn.ogg', 'zend.ogg',
    'sfx_02.wav', 'sfx_04.wav', 'sfx_3d.wav', 'sfx_3e.wav',
    'sfx_3f.wav', 'sfx_40.wav', 'sfx_41.wav',
])
    rmSync(join(DEST_AUDIO, obsolete), { force: true });
console.log('[copy_assets] browser audio uses exact SNDADLIB/MSCADLIB WASM output');
