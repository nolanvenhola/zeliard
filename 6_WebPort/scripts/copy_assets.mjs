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
    [verifiedMasmOutput('zelres2/235DPATG.grp', '73eac4be24de62cf52816f6a251c365a6ee261bd5b4bd4818915cf3a90c5c84c'), 'dpat.grp'],
    [verifiedMasmOutput('zelres2/229MMANG.grp', '99743acf6fc08f80fd6c286a17c71872c84c878d93fde4f85cd66640c62eec87'), 'mman.grp'],
    [verifiedMasmOutput('zelres2/230CMANG.grp', '52f518594b3297999006346bf69da1c03b2ddf910d21a872ce640f2de19b275e'), 'cman.grp'],
    [verifiedMasmOutput('zelres2/231TMANG.grp', '193abe062dd5cfc11d9c37a1522d1947753de36e844e75e07f95c45cb3cc0e26'), 'tman.grp'],
    [verifiedMasmOutput('zelres2/236CMAP.mdt', 'b17a070dcd246f37a12f4299cb9a9cd53901e753647bfe6f7773144875bb986b'), 'cmap.mdt'],
    [verifiedMasmOutput('zelres2/237MRMP.mdt', '7c2e8c771b8c0582a6e1cf8fb78aa7b42d9830d47d04e039dbb090cf42782d83'), 'mrmp.mdt'],
    [verifiedMasmOutput('zelres2/238STMP.mdt', '7aa03913251d353cd4758e77db78174f986719b29723c307a674ff2509353450'), 'stmp.mdt'],
    [verifiedMasmOutput('zelres2/239BSMP.mdt', '9af943ae81e431f219784d2d5050976480bbaba48f4c5f8fe07c1ff155d811ff'), 'bsmp.mdt'],
    [verifiedMasmOutput('zelres2/240HLMP.mdt', '67af5d4ff9ed9504d5b454bb8b00cdfb0b2e52aeda5d61763c13c0b2e6a76c06'), 'hlmp.mdt'],
    [verifiedMasmOutput('zelres2/241TMMP.mdt', 'f568a1df5589c89837d0e7e5c2538a5ef5e4199ac3dbd664005e566ad411351a'), 'tmmp.mdt'],
    [verifiedMasmOutput('zelres2/242DRMP.mdt', 'f55ed17ef56c26447469f96ac966c5cd163f3a7ccd23756cad4e02a35d2c0b49'), 'drmp.mdt'],
    [verifiedMasmOutput('zelres2/243LLMP.mdt', '00140a4065e22c71e33b0c9620f2d1e9b5f49d168c00ebdfe832117c72dcf2a2'), 'llmp.mdt'],
    [verifiedMasmOutput('zelres2/244PRMP.mdt', '9feb513c17adeb8158d45918dd6268e661d649c6c8e9f1c5ec217d457231234d'), 'prmp.mdt'],
    [verifiedMasmOutput('zelres2/245ESMP.mdt', '6c43552869e9c323bdbc0875b3af7c2fc12a4fe7acaf5c2e3ab1ce5375990f32'), 'esmp.mdt'],
    [verifiedMasmOutput('zelres2/206GFMCA.bin', 'f30b5029001a3fa0b718608fcb99a4f9aa384fe5d447e5a234fe3a01298f56dd'), 'gfmcga.bin'],
    [verifiedMasmOutput('zelres2/200FIGHT.bin', 'cfb5c91d14c816e966f2c335c8e85a8c0baf60ca7cc9831b24a5088c99d40a77'), 'fight.bin'],
    [verifiedMasmOutput('zelres2/201SELCT.bin', '1814d4a7aa8ac97a913b339e55f95dbac32d7eeb069219a6f76e47fc3f3770a9'), 'select.bin'],
    [verifiedMasmOutput('zelres2/227ITMSG.grp', '6c46ca4c8af264c2c3dd5b286586efbff839a7c64f3d4c8714aead92d693ec28'), 'itemp.grp'],
    [verifiedMasmOutput('zelres2/228MAGCG.grp', '4d5f347dd02ce2b9f9dc33f12011bc99d2fd157de955fa17d938da3f75419628'), 'magic.grp'],
    [verifiedMasmOutput('zelres2/226SWRDG.grp', '761177e84da136124236b6e5c7f0622ba4f997506ad9f2327d97da86b8dcd73d'), 'sword.grp'],
    /* Final-victory overlay and its release ending/credits graphics. */
    [verifiedMasmOutput('zelres2/250ENDMO.bin', '83f34e5b9adb321a1717019ed24fecadb619c53d515a53b25f8f7d79472b9350'), 'endmo.bin'],
    [verifiedMasmOutput('zelres2/251EN72G.grp', 'a9bea867201d7ad809a068add9ea5172010a2a30b44d4553878db8a0cae811d3'), 'en72.grp'],
    [verifiedMasmOutput('zelres2/252END4G.grp', 'd7608203cd444687e6804290b8dff54c6d832ae0e6f9febf01746f546b680c77'), 'end4.grp'],
    [verifiedMasmOutput('zelres2/253END5G.grp', 'cb7aeb2f039373b17f1f7a158b07929f82e3f5d617e501f1537fc4413d07cc85'), 'end5.grp'],
    [verifiedMasmOutput('zelres2/254END6G.grp', '310149ed8d61ffc93d9d686ff96b81eefdd5dbe31c7384be3757df684f9ed655'), 'end6.grp'],
    [verifiedMasmOutput('zelres2/255END7G.grp', '75f024d610aa76bdd648f80dd5fbeb5583590e9f75b76b5af31a8e287ffc8475'), 'end7.grp'],
    [verifiedMasmOutput('zelres2/256FINAL.grp', 'e538fd9ff7a5c1c06ee1541a14506816eea6464eda1404d78781205986ad6528'), 'final.grp'],
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
    [verifiedMasmOutput('zelres2/216INNAP.bin', 'fe937910a238e012d750238df9a7f5bed9574327eec1b5e3b5048f56074ef9b2'), 'innapro.bin'],
    [verifiedMasmOutput('zelres2/224SPRTS.grp', '0f635d9eb8eeac27d89efd69dbc1de60410bb75b5495768d4911384513911526'), 'inn.grp'],
    /* First cavern: exact MP10 map, Area 1 AI/sprites, palette, boss, and score. */
    [verifiedMasmOutput('zelres3/301EAI1.bin', 'fe2d16a57a9078091dd320b7050ee106a85a7ab53fb9148a78617de38063e543'), 'eai1.bin'],
    /* Boss-victory ROKADEMO overlay: raised sword, crystal ascent, HUD award. */
    [verifiedMasmOutput('zelres3/300ROKAD.bin', '07236ac426e926d2bf73eccf750101614fb1f04fdc80745dc1a2982cc05ca500'), 'rokad.bin'],
    [verifiedMasmOutput('zelres3/353DMAN.grp', '687faa9cc9ee9dc7217caf9709c343f28453e4bcbe602418b581b5f8698e8a9e'), 'dman.grp'],
    [verifiedMasmOutput('zelres3/394MFAN.msd', '87b5ec7f3ee8ea5f4086a3198076fc06e1de28d05811159eb8e9f5a829a80dff'), 'mfan.msd'],
    [verifiedMasmOutput('zelres3/309CRAB.bin', 'ed879a6e33168b07be953cdb1a8ff114b2b384c9aafce9bd860fadf406597329'), 'crab.bin'],
    [verifiedMasmOutput('zelres3/320MP10.mdt', '5f27a710ed0470de24d2aa5c3c8b13b9269dee47585fa2e4385961451d1ed66a'), 'mp10.mdt'],
    [verifiedMasmOutput('zelres3/321MP1D.mdt', 'f58ed6112af3c9b79766f82342e5dc243200e405587cd94c156b64477e512848'), 'mp1d.mdt'],
    [verifiedMasmOutput('zelres3/354DCHR.grp', 'c4e5068a0d02d45c05e070bd934cc58287a85baffc83c64075f6a536b81e121c'), 'dchr.grp'],
    [verifiedMasmOutput('zelres3/355ENCNT.grp', 'fd9fd239d60cca4418d042a5785f2f8924685f4edd03ae4768209e4ae0be1e5b'), 'encnt.grp'],
    [verifiedMasmOutput('zelres3/356ENP1.grp', '75c81a2047bb94293884c88e87858be1680af28fd44d2115c89daecbfb318b0f'), 'enp1.grp'],
    [verifiedMasmOutput('zelres3/364CRAB.grp', '91a15f5e73be4f5b0247162ca6fe6c5ec6820600c71a0b9900d7069ad6235e95'), 'crab.grp'],
    [verifiedMasmOutput('zelres3/374MPP1.grp', '4987c57069e1af6583cad22829049d9b6be98efa687fa092c63594153b7a868c'), 'mpp1.grp'],
    [verifiedMasmOutput('zelres3/385MUS1.msd', 'bae9870479e27245be7c47d670141a832c57270de1ac94cf9c50ef18785af556'), 'mus1.msd'],
    /* Second cavern and the MP21 connector between Malicia and Peligro. */
    [verifiedMasmOutput('zelres3/302EAI2.bin', 'c56d8a00d1373649cc01d6bebf86865760562c69b9a355bce0a3a98935943782'), 'eai2.bin'],
    [verifiedMasmOutput('zelres3/310TAKO.bin', '0488d3f38fab427d2df2e6f4a5b177fa5624175b0d51cabde93888a4435b1adf'), 'tako.bin'],
    [verifiedMasmOutput('zelres3/322MP20.mdt', '60de08ec157a335362b85017d38e8b3de31643ec32cff2ff80076731a615f5c2'), 'mp20.mdt'],
    [verifiedMasmOutput('zelres3/323MP21.mdt', '0151fac5e295f9ed3d59c59aabe804c5db8a6dc6e209199296c1347c176f0868'), 'mp21.mdt'],
    [verifiedMasmOutput('zelres3/324MP2D.mdt', 'f541aa1655be55aa5b5c38fdff380e1ebb920d71871b06d5bacf5825b7e8650f'), 'mp2d.mdt'],
    [verifiedMasmOutput('zelres3/357ENP2.grp', 'd0bdc05fc75ee4012d44da9e146f0c1ead0265e508b9b9107040ff2bc2e3f612'), 'enp2.grp'],
    [verifiedMasmOutput('zelres3/365TAKO.grp', '9e8743c74982e2d61a01cb987f717a658d5799eec262a8f7cb7f32926b4dcc60'), 'tako.grp'],
    [verifiedMasmOutput('zelres3/375MPP2.grp', '8636da08949f84401780fa6ea1a187a7585b1e31336bcde161cdf9540fcdd219'), 'mpp2.grp'],
    [verifiedMasmOutput('zelres3/386MUS2.msd', 'ce68a441eda87754f2fe6f31102f0d8e3fee366cf102adde2bf2c3cb11b63179'), 'mus2.msd'],
    /* Madera (area 3): exact release map and shared forest resource family. */
    [verifiedMasmOutput('zelres3/303EAI3.bin', 'a3e0d505989486b8f5250d2d60f13e664fbea5d19317f29183f757d0be3ea89f'), 'eai3.bin'],
    [verifiedMasmOutput('zelres3/325MP30.mdt', 'e8ac822b5c748a98eedcc691f24aa305c51595570eaeab127d8815fa56746feb'), 'mp30.mdt'],
    [verifiedMasmOutput('zelres3/358ENP3.grp', 'c09e98daa21c766f2d55e4b550bb7b8e15f4531ef7bc4bb089ad5c7a7029118d'), 'enp3.grp'],
    [verifiedMasmOutput('zelres3/376MPP3.grp', '1ed8823204df4b736c7e20bdd7fb337360b85208675c335cfaa24fb732dbe411'), 'mpp3.grp'],
    [verifiedMasmOutput('zelres3/387MUS3.msd', '9bba17b712e90f6acf6541f22b8a6dd708ba5f9f2d5040a62fd906694aedbbe9'), 'mus3.msd'],
    /* Escarcha (MP41) plus adjoining Glacial MP40 and the Area-4 ice family. */
    [verifiedMasmOutput('zelres3/304EAI4.bin', 'b0c7de9d05227cc94938fc8bf570d900606175d413ec7d2e88fd9c424c92f0a5'), 'eai4.bin'],
    [verifiedMasmOutput('zelres3/328MP40.mdt', '45b8011d17f6be5207f87040ae5bbb3f0ec3349ea87ae91526f36171fdc042fc'), 'mp40.mdt'],
    [verifiedMasmOutput('zelres3/329MP41.mdt', '8e30300abec8aa83ad5acc8c7cc24699e19254741a4e5a831c44b934caea6ff0'), 'mp41.mdt'],
    [verifiedMasmOutput('zelres3/359ENP4.grp', '5b6765a6c3748afd902d0bb0ce62c3401423cf30eb60e321d095ab1bd68508da'), 'enp4.grp'],
    [verifiedMasmOutput('zelres3/377MPP4.grp', '206424b4aa8aa37b1a725663e92623b98fbcc8e264c3d5c6c099b24967a71909'), 'mpp4.grp'],
    [verifiedMasmOutput('zelres3/388MUS4.msd', '2d7b8854ae7b8aaac0ee98cafb6cfd6567d62f0cc0fc85498d5bd29fe31b96a1'), 'mus4.msd'],
    /* Glacial's exact Agar chamber handoff. */
    [verifiedMasmOutput('zelres3/312ZELA.bin', '93fe0e0b96810082867875884b142ed75548617e47491fa7f7c518bb43c8f875'), 'zela.bin'],
    [verifiedMasmOutput('zelres3/330MP4D.mdt', 'f6d72154c8bc0f379511516235b50096b5feb23295600c89ad891358772f2df2'), 'mp4d.mdt'],
    [verifiedMasmOutput('zelres3/367ZELA.grp', 'ff2ec29b24d111d28b9d1727ffc7ae93b7c1cb193e97036b84a3d155c424d99f'), 'zela.grp'],
    /* Cementar, its Corroer reverse routes, and the Vista chamber. */
    [verifiedMasmOutput('zelres3/305EAI5.bin', '1da372b13d26b4a70607a9a0d54d7db505dd6486bc22173b6d874b3f6bbe9410'), 'eai5.bin'],
    [verifiedMasmOutput('zelres3/313MEDA.bin', '2aae9bee5cf6581507c2f1a5aca63b9083bb6dd6635e5dca69addb51d4e16c5c'), 'meda.bin'],
    [verifiedMasmOutput('zelres3/331MP50.mdt', 'ab94a37b64917f7a10a54b9fb199dcdaab05d4c089d0fc88054bedbb854bb325'), 'mp50.mdt'],
    [verifiedMasmOutput('zelres3/332MP51.mdt', 'c8ffd7c7a14f09b09617b18ba4c24c4e7526b8c88efe338ab82937cb89c4f106'), 'mp51.mdt'],
    [verifiedMasmOutput('zelres3/333MP5D.mdt', '5163eb116c039b3b92cad56b0ece00b3af1a935a075b5bc80fbf7626239514f9'), 'mp5d.mdt'],
    [verifiedMasmOutput('zelres3/360ENP5.grp', '5489c7b79f6a061d3351a04f0d7d6dd19f5b2dc90c9659c50b564b41466559f8'), 'enp5.grp'],
    [verifiedMasmOutput('zelres3/368MEDA.grp', '6822616f1c7e71e9b340e8c54f8100f1962fcc7c33772548bf822d60c2b2baaa'), 'meda.grp'],
    [verifiedMasmOutput('zelres3/378MPP5.grp', '1e9dff8ee09cb8861fcc1be7ed307d307891092ca0a91b06ed09791fd7fa364f'), 'mpp5.grp'],
    [verifiedMasmOutput('zelres3/389MUS5.msd', '457c266ae94e1f26628ee6ed322e0ae52d088dbe546417ccdb4068206539e0cc'), 'mus5.msd'],
    /* Plata/Tesoro, the Tarso chamber, and the Area-6 gold family. */
    [verifiedMasmOutput('zelres3/306EAI6.bin', '87e10d8c62ad709f981f3c77e48f83074439779b0542a271523ac3dc7305541e'), 'eai6.bin'],
    [verifiedMasmOutput('zelres3/334MP60.mdt', 'fb7edfcf4e17c0f9c0a7004644af603d85bcc4023c66ed34fba8a32dbb2ad766'), 'mp60.mdt'],
    [verifiedMasmOutput('zelres3/335MP61.mdt', 'b6368328e0e88ee3f4e64868a79127f30985aa5f5ab90fc461600e38ce61ac66'), 'mp61.mdt'],
    /* MP62 is Arrugia's Lion-keyed secret treasure cavern. */
    [verifiedMasmOutput('zelres3/336MP62.mdt', '3248ca6fc3d05ef72e42ca3db29e2d0622c20b653f5d08f9e86b5eeec7060402'), 'mp62.mdt'],
    [verifiedMasmOutput('zelres3/314LEGA.bin', '8f660070d9c78a535862ce0afb9ec8dfb0c01a766bfd2e42fe74ed28a8dc0e7c'), 'lega.bin'],
    [verifiedMasmOutput('zelres3/337MP6D.mdt', '534d5fe2dd647ba2bb6c49ba365931c2931155102cb2a0d8cb5405e6c88f01d3'), 'mp6d.mdt'],
    [verifiedMasmOutput('zelres3/361ENP6.grp', '6df8b6d5ac7ccf37d78fbea9d3928e72277356ddc1ac4736fbdfe959f6405ec7'), 'enp6.grp'],
    [verifiedMasmOutput('zelres3/369LEGA.grp', '96b25f7bea9dd369c8088b947388bb20b2b3b79928b0f0f42700cd5f8171535e'), 'lega.grp'],
    [verifiedMasmOutput('zelres3/379MPP6.grp', '38cdd9a3442b5db1c8ef0473b82479e1cd7000ca525118d1a745ea1d5ef98a51'), 'mpp6.grp'],
    [verifiedMasmOutput('zelres3/390MUS6.msd', 'e7915cda939ede7dc3df69399cb044b0f9acf63880ed44c41e3142c0f1b81cee'), 'mus6.msd'],
    /* Caliente and Dragon's exact Area-7 heat, encounter, and audio family. */
    [verifiedMasmOutput('zelres3/307EAI7.bin', '40eb8d98ce4eaaed8f4c3d231bb7e369f5b5b2870b5b579e3b4a5cc61d52c21e'), 'eai7.bin'],
    [verifiedMasmOutput('zelres3/316DRGN.bin', 'c03672dff738c3220d86c164a9520361fabc9ae3f5434bab8c07b5a200b49f86'), 'drgn.bin'],
    [verifiedMasmOutput('zelres3/338MP70.mdt', '1d2247ca9584eb627c7c0582e60b2e44b1bfafeccdc88a26dff38dc81a497094'), 'mp70.mdt'],
    [verifiedMasmOutput('zelres3/339MP71.mdt', 'c1ab0694efd43ef1d5c4f40be33059a81d34ba02604d0a2bb68da749446f9b61'), 'mp71.mdt'],
    [verifiedMasmOutput('zelres3/340MP72.mdt', 'b1a78a9d6ea7dc4f4b3867b05d14622d2cef953842d03a8726d53c1e40386522'), 'mp72.mdt'],
    [verifiedMasmOutput('zelres3/341MP73.mdt', 'a9ce3cf74e2a491ed00ee4040af0730d7e9deb4b8881b67716807228d2548686'), 'mp73.mdt'],
    [verifiedMasmOutput('zelres3/342MP7D.mdt', '20beabad8ed3b592395a8c690ba6ef76d7e9282b7e2e9e2fc8a5899b86c07e68'), 'mp7d.mdt'],
    [verifiedMasmOutput('zelres3/362ENP7.grp', '21cd44fff5a86165b6d2bfd66fae001fd79421471561aca836960314e6acdef1'), 'enp7.grp'],
    [verifiedMasmOutput('zelres3/370DRGN.grp', '08cad787630482e422152df806de61f22c227f0362cbf63bc904b2ffa98b0f49'), 'drgn.grp'],
    [verifiedMasmOutput('zelres3/380MPP7.grp', '2f8a8f2207be3deb686e520e11530d60a71fff1f0c628cb92397173217be75c9'), 'mpp7.grp'],
    [verifiedMasmOutput('zelres3/391MUS7.msd', 'e0404d16eaad567e7ed932690f4f1c16f7246875413b463cb4be086c95213c4a'), 'mus7.msd'],
    /* Reaccion completes Area 7; Area 8 continues through Absor, Milagro,
     * Desleal, Falter, Final, Alguien, and the two-part final encounter. */
    [verifiedMasmOutput('zelres3/308EAI8.bin', 'dd014b53e0108527bcf55b5514f23601063086dc73aabe81b80fc3134965ee7a'), 'eai8.bin'],
    [verifiedMasmOutput('zelres3/315ZEL2.bin', '71ae2d4bc7bcf3c24bfbb055099016cd4330deb5d512bbfa179ff7a45c033579'), 'zel2.bin'],
    [verifiedMasmOutput('zelres3/317AKMA.bin', 'cea5025222dc6bb039607a81347ee1cecff17042dc7558dc8cc75c1755973c87'), 'akma.bin'],
    [verifiedMasmOutput('zelres3/318MAO1.bin', '262bc8f20064f1a7aa055d90bb0618b6895b5d034dd9db2ef975432790e894af'), 'mao1.bin'],
    [verifiedMasmOutput('zelres3/319MAO2.bin', 'edebfb70b4a98d59dd3cf0ccc99342682320afa3fb73d0e2fbf89a0cb9acdabb'), 'mao2.bin'],
    [verifiedMasmOutput('zelres3/343MP80.mdt', '688f9a3b6d194cb0968d0cadf89eb77fb5bb477537fc5198b0445c3369ad2b76'), 'mp80.mdt'],
    [verifiedMasmOutput('zelres3/344MP81.mdt', 'f0d6da6d3b527b03c10b364bcb0c5cbbcdae1b58b0ad7480c195466ebde923f8'), 'mp81.mdt'],
    [verifiedMasmOutput('zelres3/345MP82.mdt', '915a9ee1cccf93e2972b463aeb1e8759d12d2551124eb300daffc56f50499edd'), 'mp82.mdt'],
    [verifiedMasmOutput('zelres3/346MP83.mdt', 'faafc62dfa83169a304c3a22a61d5a896f0ceddc666cdb11db75c971499612e9'), 'mp83.mdt'],
    [verifiedMasmOutput('zelres3/347MP84.mdt', 'adaedb8c3a834976d986917faa222359b2c1ecb2c589026db8e54b06b1d3d97c'), 'mp84.mdt'],
    [verifiedMasmOutput('zelres3/348MP8D.mdt', '2a6ffe29b8b4cc955cb30e45ced4a23ce87a30776e1251d59696d03cc23d0589'), 'mp8d.mdt'],
    [verifiedMasmOutput('zelres3/349MP90.mdt', 'b33d5880f8e37686a31acb8c0dd891525992d3a4f35a2b7acad3361571122d8e'), 'mp90.mdt'],
    [verifiedMasmOutput('zelres3/350MPA0.mdt', 'cabc22c986da57f7181699c80a4886a9265679ebe4d19f6e045b9e356a8d7a56'), 'mpa0.mdt'],
    [verifiedMasmOutput('zelres3/363ENP8.grp', '0020cb2ec543950939b0405c24b4f77196b31dc75eef25ce0196afd0d4c9a8bf'), 'enp8.grp'],
    [verifiedMasmOutput('zelres3/371AKMA.grp', '6fa2640e7f506bf4e834dad8c32e41b1addb0efacacbae3e67d5b2cd5592d014'), 'akma.grp'],
    [verifiedMasmOutput('zelres3/372MAO1.grp', '6ac1fb19a5a8e5a24ce46796b302001494808b9cd9bdc64eaba97cbb97630808'), 'mao1.grp'],
    [verifiedMasmOutput('zelres3/373MAO2.grp', '91775c0257e207fe398ef3655ace55c1aed1c4817a9bad162433a43b995530cf'), 'mao2.grp'],
    [verifiedMasmOutput('zelres3/381MPP8.grp', '197992cf1019aacb4004f6c6a9a32df8a128e48bb9ed74184d78687ca457fea4'), 'mpp8.grp'],
    [verifiedMasmOutput('zelres3/382MPP9.grp', '79fbaaa13969846f8e6710991ab4e197083b4e9fe469673cb1c50a9597e65add'), 'mpp9.grp'],
    [verifiedMasmOutput('zelres3/383MPPA.grp', 'b4a8dde3c155c05d983592d6516d6f80b4bbbf01f2812cb54001fa804dcc9b8c'), 'mppa.grp'],
    [verifiedMasmOutput('zelres3/384MPPB.grp', '9fec1465feb9aa65ff8e15483f5b1bb520d238a361648b6d8aa8a137c96b024b'), 'mppb.grp'],
    [verifiedMasmOutput('zelres3/392MUS8.msd', 'b4e453e4bd8407e9d8154334bf07943f17a9f1b2b974be6bc6561533430bfd98'), 'mus8.msd'],
    [verifiedMasmOutput('zelres3/395MMAO.msd', 'bc05bb7ffac4a2a5641973aa2c2c2c1ae0d74118e2916b4f9a22c738dc146d8b'), 'mmao.msd'],
    /* Riza and its exact Pollo chamber handoff. */
    [verifiedMasmOutput('zelres3/311TORI.bin', 'a387232517b65a73853f57bf368a1c8b3a45ffe41607c38f056779267ec11aac'), 'tori.bin'],
    [verifiedMasmOutput('zelres3/326MP31.mdt', '4b54099bff4ab44ea5cae76fc554ad6c2c684a025a3d9922e330431fbe2b2ae3'), 'mp31.mdt'],
    [verifiedMasmOutput('zelres3/327MP3D.mdt', 'b7a4df4e67ebff7ea3345701f5d1a25d2f0df645fa3b296a935ef9d4e99efd1e'), 'mp3d.mdt'],
    [verifiedMasmOutput('zelres3/366TORI.grp', '8681fe7105dcf38795407b08fc6dc822b7d13ae8567b41337ed3c59a7456ae5b'), 'tori.grp'],
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
