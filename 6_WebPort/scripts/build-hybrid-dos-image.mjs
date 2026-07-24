#!/usr/bin/env node
/*
 * Build the two images used by the browser-side MASM reference runner.
 * A: is the small FreeDOS boot disk; B: contains the current MASM release.
 * Keeping this generated makes the byte provenance explicit: B: is made
 * directly from 3_Assembly/masm/bin after its bit-perfect verification.
 */
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, "../..");
const hybridDir = path.join(root, "6_WebPort/shell/public/hybrid");
const sourceBoot = path.join(hybridDir, "freedos722.img");
const bootOut = path.join(hybridDir, "freedos-zeliard.img");
const gameOut = path.join(hybridDir, "masm-release.img");
const gameDir = path.join(root, "3_Assembly/masm/bin");
const v86Wasm = path.join(root, "6_WebPort/shell/node_modules/v86/build/v86.wasm");

function die(message) {
    throw new Error(`build-hybrid-dos-image: ${message}`);
}

function shortName(name) {
    const upper = name.toUpperCase();
    const dot = upper.lastIndexOf(".");
    const base = dot < 0 ? upper : upper.slice(0, dot);
    const ext = dot < 0 ? "" : upper.slice(dot + 1);
    if (!/^[A-Z0-9_$~!#%&'(){}@^`-]{1,8}$/.test(base) ||
        (ext && !/^[A-Z0-9_$~!#%&'(){}@^`-]{1,3}$/.test(ext))) {
        die(`cannot encode DOS 8.3 name ${name}`);
    }
    return Buffer.from(`${base.padEnd(8, " ")}${ext.padEnd(3, " ")}`, "ascii");
}

function patchAutoexec(image) {
    const bytesPerSector = image.readUInt16LE(11);
    const reserved = image.readUInt16LE(14);
    const fats = image[16];
    const sectorsPerFat = image.readUInt16LE(22);
    const rootEntries = image.readUInt16LE(17);
    const sectorsPerCluster = image[13];
    const rootOffset = (reserved + fats * sectorsPerFat) * bytesPerSector;
    const clusterOffset = (reserved + fats * sectorsPerFat +
        Math.ceil(rootEntries * 32 / bytesPerSector)) * bytesPerSector;
    const fatOffset = reserved * bytesPerSector;
    const clusterBytes = sectorsPerCluster * bytesPerSector;
    const target = Buffer.from("AUTOEXECBAT", "ascii");
    let entry;
    for (let i = 0; i < rootEntries; i++) {
        const candidate = rootOffset + i * 32;
        if (image.subarray(candidate, candidate + 11).equals(target)) {
            entry = candidate;
            break;
        }
    }
    if (entry === undefined) die("AUTOEXEC.BAT not found on FreeDOS image");

    const firstCluster = image.readUInt16LE(entry + 26);
    const oldSize = image.readUInt32LE(entry + 28);
    const script = Buffer.from("@echo off\r\nB:\r\nzeliad.exe\r\n", "ascii");
    if (script.length > oldSize || oldSize > clusterBytes) {
        die("FreeDOS AUTOEXEC.BAT does not have enough contiguous room");
    }

    // The published 720K boot disk keeps AUTOEXEC in one cluster. Assert
    // that rather than silently corrupting a future image with a FAT chain.
    const fatIndex = firstCluster + (firstCluster >> 1);
    const next = firstCluster & 1
        ? (image[fatOffset + fatIndex] >> 4) | (image[fatOffset + fatIndex + 1] << 4)
        : image[fatOffset + fatIndex] | ((image[fatOffset + fatIndex + 1] & 0x0F) << 8);
    if (next < 0xFF8) die("AUTOEXEC.BAT is unexpectedly fragmented");

    const dataOffset = clusterOffset + (firstCluster - 2) * clusterBytes;
    image.fill(0, dataOffset, dataOffset + clusterBytes);
    script.copy(image, dataOffset);
    image.writeUInt32LE(script.length, entry + 28);
}

function makeGameImage(files) {
    const bytesPerSector = 512;
    // B: is an emulated floppy drive. Keep this a conventional 1.44 MiB
    // FAT12 disk rather than attaching a hard-disk-shaped FAT volume there.
    const totalSectors = 2880;
    const reserved = 1;
    const fats = 2;
    const sectorsPerFat = 9;
    const rootEntries = 224;
    const rootSectors = Math.ceil(rootEntries * 32 / bytesPerSector);
    const dataStart = reserved + fats * sectorsPerFat + rootSectors;
    const image = Buffer.alloc(totalSectors * bytesPerSector);
    image.write("ZELIARD ", 3, "ascii");
    image.writeUInt16LE(bytesPerSector, 11);
    image[13] = 1;
    image.writeUInt16LE(reserved, 14);
    image[16] = fats;
    image.writeUInt16LE(rootEntries, 17);
    image.writeUInt16LE(totalSectors, 19);
    image[21] = 0xF0;
    image.writeUInt16LE(sectorsPerFat, 22);
    image.writeUInt16LE(18, 24);
    image.writeUInt16LE(2, 26);
    image[36] = 0x80;
    image[38] = 0x29;
    image.writeUInt32LE(0x5A454C49, 39);
    image.write("ZELIARDMASM", 43, "ascii");
    image.write("FAT12   ", 54, "ascii");
    image[510] = 0x55;
    image[511] = 0xAA;
    const rootOffset = (reserved + fats * sectorsPerFat) * bytesPerSector;
    const fatOffsets = Array.from({ length: fats }, (_, i) =>
        (reserved + i * sectorsPerFat) * bytesPerSector);
    for (const offset of fatOffsets) {
        image[offset] = 0xF0;
        image[offset + 1] = 0xFF;
        image[offset + 2] = 0xFF;
    }

    function writeFat12(cluster, value) {
        for (const offset of fatOffsets) {
            const index = cluster + (cluster >> 1);
            if (cluster & 1) {
                image[offset + index] = (image[offset + index] & 0x0F) | ((value << 4) & 0xF0);
                image[offset + index + 1] = value >> 4;
            } else {
                image[offset + index] = value & 0xFF;
                image[offset + index + 1] = (image[offset + index + 1] & 0xF0) | (value >> 8);
            }
        }
    }

    let cluster = 2;
    files.forEach(({ name, data }, index) => {
        const clusterCount = Math.max(1, Math.ceil(data.length / bytesPerSector));
        const entry = rootOffset + index * 32;
        shortName(name).copy(image, entry);
        image[entry + 11] = 0x20;
        image.writeUInt16LE(cluster, entry + 26);
        image.writeUInt32LE(data.length, entry + 28);
        for (let n = 0; n < clusterCount; n++) {
            writeFat12(cluster + n, n + 1 === clusterCount ? 0xFFF : cluster + n + 1);
        }
        data.copy(image, (dataStart + cluster - 2) * bytesPerSector);
        cluster += clusterCount;
    });
    return image;
}

if (!fs.existsSync(sourceBoot)) die(`missing ${sourceBoot}; fetch the v86 FreeDOS image first`);
if (!fs.existsSync(gameDir)) die(`missing ${gameDir}`);
if (!fs.existsSync(v86Wasm)) die("missing shell/node_modules/v86; run npm install in 6_WebPort/shell");
fs.mkdirSync(hybridDir, { recursive: true });
const boot = fs.readFileSync(sourceBoot);
patchAutoexec(boot);
fs.writeFileSync(bootOut, boot);

const files = fs.readdirSync(gameDir, { withFileTypes: true })
    .filter(entry => entry.isFile() && entry.name.toLowerCase() !== "zelplay.bat")
    .map(entry => ({ name: entry.name, data: fs.readFileSync(path.join(gameDir, entry.name)) }));
if (files.length > 512) die(`too many root entries (${files.length})`);
const image = makeGameImage(files);
fs.writeFileSync(gameOut, image);
fs.copyFileSync(v86Wasm, path.join(hybridDir, "v86.wasm"));
console.log(`wrote ${path.relative(root, bootOut)} and ${path.relative(root, gameOut)} (${files.length} MASM release files)`);
