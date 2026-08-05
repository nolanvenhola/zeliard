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
const VERIFIED_DATA_HASHES = new Map([
    ['zelres2/data/246MGT1S.msd', '40836c6321800fb3b6821d358a08eb4c4168fd317a7c0101279b176aa3647ed7'],
    ['zelres2/data/247MGT2S.msd', '80fbf9d10f5fe1e51c04393f30235db551f16e584ac7ca693abe7bd9c77441f5'],
    ['zelres2/data/248UGM1S.msd', 'cdc86b6f8cc2ef02f2f7395e29be7aabc73810276850d371020352c159d4c5de'],
    ['zelres2/data/249UGM2S.msd', '6743ee4a9bcd6a6fd2a4717712c2d0767dfdff1e3650d30910d2df81aa3ab9f0'],
    ['zelres3/data/320MP10.mdt', '5f27a710ed0470de24d2aa5c3c8b13b9269dee47585fa2e4385961451d1ed66a'],
    ['zelres3/data/351FMAN.grp', 'f8ac50e4c6d0fc9038914751360b6eb89ab90f14f39b7be500814494a3e11dda'],
    ['zelres3/data/352ROKA.grp', 'cd72a12bb051de507ba3e52aad335d6fed099d0db31b75dd5c7a703926d5d693'],
    ['zelres3/data/374MPP1.grp', '4987c57069e1af6583cad22829049d9b6be98efa687fa092c63594153b7a868c'],
]);

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
    /* Gameplay scores loaded through the same MSCADLIB INT 60h service. */
    ['zelres2/data/246MGT1S.msd', 'mgt1.msd'],
    ['zelres2/data/247MGT2S.msd', 'mgt2.msd'],
    ['zelres2/data/248UGM1S.msd', 'ugm1.msd'],
    ['zelres2/data/249UGM2S.msd', 'ugm2.msd'],
    /* 200FIGHT cold entry: forced ROKA doorway crossing. */
    ['zelres3/data/351FMAN.grp', 'fman.grp'],
    ['zelres3/data/352ROKA.grp', 'roka.grp'],
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
    [verifiedMasmOutput('stick.bin', '3255d2a0f1f3d5c4a603e61fa8bca57dcf2130a44d8c37ed7e1df63c6ea7f8a9'), 'stick.bin'],
    [verifiedMasmOutput('gmmcga.bin', '95aafd24d1300e8cb7fd66fc651839a968da1bdc7616c0ddf71d1337056b7579'), 'gmmcga.bin'],
    [verifiedMasmOutput('game.bin', '15b0f46e8113e6f8937d65df6c94358016fcd56c8de281506cb73c830978dc4c'), 'game.bin'],
    [verifiedMasmOutput('zelres1/105GDMCA.bin', '38b7b37bb040fd5d06c8be16017961a09b14a603d063c1841720d4f5771e8e0a'), 'gdmcga.bin'],
    [verifiedMasmOutput('zelres1/111GTMCA.bin', '1a3384ae85db5476165d09149bc12a31ae71d7c1f0a77a78e560ff0502a0e9c8'), 'gtmcga.bin'],
    [verifiedMasmOutput('zelres1/106TOWN.bin', 'bce0f4832d434867f17df2c5c416d3ece7b69bda78063c1b33d80f56dc6c942b'), 'town.bin'],
    [verifiedMasmOutput('zelres2/208YMPD.bin', '00fc13d63b6ef310bb10096581337ca5498b1342cf3806c04b77315c1c937342'), 'ympd.bin'],
    [verifiedMasmOutput('zelres2/233CPATG.grp', 'e6355b4a8f2fc6c0cd2bca33ac0add875f20e1b994e71b5ea9a1b32c8e2a8cf8'), 'cpat.grp'],
    [verifiedMasmOutput('zelres2/234MPATG.grp', '8b45794a38d7e6953e7c90d53d05c2c7b41838339ca208bc3499fccba6c8265f'), 'mpat.grp'],
    [verifiedMasmOutput('zelres2/229MMANG.grp', '99743acf6fc08f80fd6c286a17c71872c84c878d93fde4f85cd66640c62eec87'), 'mman.grp'],
    [verifiedMasmOutput('zelres2/231TMANG.grp', '193abe062dd5cfc11d9c37a1522d1947753de36e844e75e07f95c45cb3cc0e26'), 'tman.grp'],
    [verifiedMasmOutput('zelres2/236CMAP.mdt', 'b17a070dcd246f37a12f4299cb9a9cd53901e753647bfe6f7773144875bb986b'), 'cmap.mdt'],
    [verifiedMasmOutput('zelres2/237MRMP.mdt', '7c2e8c771b8c0582a6e1cf8fb78aa7b42d9830d47d04e039dbb090cf42782d83'), 'mrmp.mdt'],
    [verifiedMasmOutput('zelres2/206GFMCA.bin', 'f30b5029001a3fa0b718608fcb99a4f9aa384fe5d447e5a234fe3a01298f56dd'), 'gfmcga.bin'],
    [verifiedMasmOutput('zelres2/200FIGHT.bin', 'cfb5c91d14c816e966f2c335c8e85a8c0baf60ca7cc9831b24a5088c99d40a77'), 'fight.bin'],
    [verifiedMasmOutput('zelres2/201SELCT.bin', '1814d4a7aa8ac97a913b339e55f95dbac32d7eeb069219a6f76e47fc3f3770a9'), 'select.bin'],
    [verifiedMasmOutput('zelres2/227ITMSG.grp', '6c46ca4c8af264c2c3dd5b286586efbff839a7c64f3d4c8714aead92d693ec28'), 'itemp.grp'],
    [verifiedMasmOutput('zelres2/228MAGCG.grp', '4d5f347dd02ce2b9f9dc33f12011bc99d2fd157de955fa17d938da3f75419628'), 'magic.grp'],
    [verifiedMasmOutput('zelres2/226SWRDG.grp', '761177e84da136124236b6e5c7f0622ba4f997506ad9f2327d97da86b8dcd73d'), 'sword.grp'],
    [verifiedMasmOutput('zelres2/207MOLE.bin', 'fa945314a8fd95b0ff6bb158f4fecf58c52ff05204e2e17b0de39c348f49a9bd'), 'mole.bin'],
    [verifiedMasmOutput('zelres2/210KINGP.bin', '617676335275adcfd98ed7bc0ed28b43ca92a4330eb65d7e4749332703a77e44'), 'kingpro.bin'],
    [verifiedMasmOutput('zelres2/218KINGG.grp', 'a824f647653146eacfcbfb91a609f5f329be86aad78cbfd88218337c9ba34290'), 'king.grp'],
    [verifiedMasmOutput('zelres2/211OMOYP.bin', '456710ff9fbc63f5926aeb15d33c5c8401930da45eb5064aecbd8e9060d9f37e'), 'omoypro.bin'],
    [verifiedMasmOutput('zelres2/219OMOYG.grp', '4d19d21fcc54d1cfc5df6b2052f2f354119f302d90d69311e186a2cddd80b9fa'), 'omoya.grp'],
    [verifiedMasmOutput('zelres2/217KENJP.bin', '47acc800138d8b89c39344a51aeef6f34a6ad6a376b76f38838f3fcdb422eac0'), 'kenjpro.bin'],
    [verifiedMasmOutput('zelres2/225KNJYG.grp', 'b25caf982062f1026e0ead3fd3a355b9762bb4d8fd8d00746b885a7ca2a78cbe'), 'kenja.grp'],
    [verifiedMasmOutput('zelres2/212ARMRP.bin', 'ed837bbb17e8540d89b2e182047c954de5a5dea45422c06d563738ed049641d4'), 'armrpro.bin'],
    [verifiedMasmOutput('zelres2/220ARMRG.grp', '4ccd2c2ae407a87ed4360298401ef693d19001bf217daeb2549bb83ffa7e7872'), 'armr.grp'],
    [verifiedMasmOutput('zelres2/213BANKP.bin', '029903cf59c12aaf5436c7eb5afb10dda751088a69f377070c46adcca7d7e2b6'), 'bankpro.bin'],
    [verifiedMasmOutput('zelres2/221BANKG.grp', 'd04d8154ea1dbfb611f86c3a48e47cd473c4d7556b9651b7828c3dd379a0adaf'), 'bank.grp'],
    [verifiedMasmOutput('zelres2/214CHURP.bin', '906b9a86a3508a8e8943074287108d2d743cd33a5651179dc08bcd16579f0484'), 'churpro.bin'],
    [verifiedMasmOutput('zelres2/222CHRCH.grp', '75d435e68e4a4c0030ed38f7d7ab5ccc8544a580441322d18bf903e155ffeea5'), 'church.grp'],
    [verifiedMasmOutput('zelres2/215DRUGP.bin', 'c4fe6430497686cc0a01919fca71a410ccd956f2675fc82b547f441211dbb6e5'), 'drugpro.bin'],
    [verifiedMasmOutput('zelres2/223DRUGG.grp', '2826d141c6a8eec7f4330e788e5dd0a533479b007638558c99eb9caef0d2db19'), 'drug.grp'],
    /* First cavern: exact MP10 map, Area 1 AI/sprites, palette, boss, and score. */
    [verifiedMasmOutput('zelres3/301EAI1.bin', 'fe2d16a57a9078091dd320b7050ee106a85a7ab53fb9148a78617de38063e543'), 'eai1.bin'],
    [verifiedMasmOutput('zelres3/309CRAB.bin', 'ed879a6e33168b07be953cdb1a8ff114b2b384c9aafce9bd860fadf406597329'), 'crab.bin'],
    [verifiedMasmOutput('zelres3/320MP10.mdt', '5f27a710ed0470de24d2aa5c3c8b13b9269dee47585fa2e4385961451d1ed66a'), 'mp10.mdt'],
    [verifiedMasmOutput('zelres3/321MP1D.mdt', 'f58ed6112af3c9b79766f82342e5dc243200e405587cd94c156b64477e512848'), 'mp1d.mdt'],
    [verifiedMasmOutput('zelres3/354DCHR.grp', 'c4e5068a0d02d45c05e070bd934cc58287a85baffc83c64075f6a536b81e121c'), 'dchr.grp'],
    [verifiedMasmOutput('zelres3/355ENCNT.grp', 'fd9fd239d60cca4418d042a5785f2f8924685f4edd03ae4768209e4ae0be1e5b'), 'encnt.grp'],
    [verifiedMasmOutput('zelres3/356ENP1.grp', '75c81a2047bb94293884c88e87858be1680af28fd44d2115c89daecbfb318b0f'), 'enp1.grp'],
    [verifiedMasmOutput('zelres3/364CRAB.grp', '91a15f5e73be4f5b0247162ca6fe6c5ec6820600c71a0b9900d7069ad6235e95'), 'crab.grp'],
    [verifiedMasmOutput('zelres3/374MPP1.grp', '4987c57069e1af6583cad22829049d9b6be98efa687fa092c63594153b7a868c'), 'mpp1.grp'],
    [verifiedMasmOutput('zelres3/385MUS1.msd', 'bae9870479e27245be7c47d670141a832c57270de1ac94cf9c50ef18785af556'), 'mus1.msd'],
    [verifiedMasmOutput('zelres3/393MBOS.msd', 'dd78504393a7ae762f8a60ecaccf182cb11cc31ea04b945bbeeee838b663d716'), 'mbos.msd'],
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
    const expectedHash = VERIFIED_DATA_HASHES.get(rel);
    if (expectedHash) {
        const actualHash = createHash('sha256').update(readFileSync(src)).digest('hex');
        if (actualHash !== expectedHash)
            throw new Error(`${rel} does not match verified MASM data: ${actualHash}`);
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
