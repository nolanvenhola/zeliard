#!/usr/bin/env node
/*
 * Copies the canonical loose data files from
 *   3_Assembly/tasm/working/zelresN/data/
 * into the web-port asset tree at
 *   6_WebPort/engine/assets/   (Emscripten --preload-file source)
 *   6_WebPort/shell/public/assets/   (Vite dev-server static dir)
 *
 * Renames each file to a short canonical name (e.g. 131TTL3G.grp -> ttl3.grp)
 * to keep the C code readable.
 */
import { copyFileSync, mkdirSync, readdirSync, existsSync, statSync } from 'node:fs';
import { dirname, basename, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const REPO_ROOT = resolve(__dirname, '..', '..');
const SRC_BASE  = join(REPO_ROOT, '3_Assembly', 'tasm', 'working');
const DEST_ENGINE = join(REPO_ROOT, '6_WebPort', 'engine', 'assets');
const DEST_SHELL  = join(REPO_ROOT, '6_WebPort', 'shell', 'public', 'assets');

/* Map of {source file prefix} -> {short name used by C engine}.  Add entries
 * as new assets are wired up.  The number prefix on disk is the chunk
 * index; the short name matches the asm-level resource_name_table. */
const ASSET_MAP = [
    /* zelres1 — opening + title + UI */
    ['zelres1/data/112FONTG.grp', 'font.grp'],
    ['zelres1/data/122NECGP.grp', 'nec.grp'],
    ['zelres1/data/129TTL1G.grp', 'ttl1.grp'],
    ['zelres1/data/130TTL2G.grp', 'ttl2.grp'],
    ['zelres1/data/131TTL3G.grp', 'ttl3.grp'],
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
console.log(`[copy_assets] ${ok}/${ASSET_MAP.length} files copied`);
