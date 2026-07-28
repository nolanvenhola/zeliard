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
import { copyFileSync, mkdirSync, existsSync, readFileSync, statSync, writeFileSync } from 'node:fs';
import { createHash } from 'node:crypto';
import { dirname, basename, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const REPO_ROOT = resolve(__dirname, '..', '..');
const SRC_BASE  = join(REPO_ROOT, '3_Assembly', 'masm', 'working');
const DEST_ENGINE = join(REPO_ROOT, '6_WebPort', 'engine', 'assets');
const DEST_SHELL  = join(REPO_ROOT, '6_WebPort', 'shell', 'public', 'assets');
const MASM_OPDMO_BIN = '3_Assembly/masm/bin/zelres1/100OPDMO.bin';
const TRACKED_OPDMO_BIN = '3_Assembly/tasm/bin/zelres1/100OPDMO.bin';
const OPDMO_MASM_SHA256 = '424f2acbaec8c0395e5e72562ac6f6fd8bfa6f8b5c58a867fe1c5b21a6f51548';

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
];

const EXTRA_ASSET_MAP = [
    ['3_Assembly/dumps/zeliard_title_image.BIN', 'title_full.bin'],
    [OPDMO_BIN, '100opdmo.bin'],
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
console.log(`[copy_assets] ${ok}/${ASSET_MAP.length + EXTRA_ASSET_MAP.length + BINARY_SLICES.length} files copied`);
