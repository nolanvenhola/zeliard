/** Values are the graphics_mode indexes parsed by zeliad.asm. */
export const DISPLAY_MODE = {
    ega: 0,
    cga: 1,
    cga2: 2,
    hgc: 3,
    mcga: 4,
    tandy: 5,
} as const;

export type DisplayMode = typeof DISPLAY_MODE[keyof typeof DISPLAY_MODE];

const RGBI_16: readonly (readonly [number, number, number])[] = [
    [0, 0, 0], [0, 0, 170], [0, 170, 0], [0, 170, 170],
    [170, 0, 0], [170, 0, 170], [170, 85, 0], [170, 170, 170],
    [85, 85, 85], [85, 85, 255], [85, 255, 85], [85, 255, 255],
    [255, 85, 85], [255, 85, 255], [255, 255, 85], [255, 255, 255],
];

/* BIOS mode 5's color-burst-disabled four-color interpretation. */
const CGA_4: readonly (readonly [number, number, number])[] = [
    [0, 0, 0], [0, 170, 170], [170, 0, 170], [170, 170, 170],
];
const BAYER_2 = [0, 2, 3, 1] as const;
const BAYER_4 = [
    0, 8, 2, 10,
    12, 4, 14, 6,
    3, 11, 1, 9,
    15, 7, 13, 5,
] as const;

function nearest(r: number, g: number, b: number,
                 palette: readonly (readonly [number, number, number])[]) {
    let best = palette[0];
    let bestDistance = Number.MAX_SAFE_INTEGER;
    for (const color of palette) {
        const dr = r - color[0];
        const dg = g - color[1];
        const db = b - color[2];
        const distance = dr * dr + dg * dg + db * db;
        if (distance < bestDistance) {
            best = color;
            bestDistance = distance;
        }
    }
    return best;
}

function luminance(r: number, g: number, b: number) {
    return (r * 77 + g * 150 + b * 29) >> 8;
}

/**
 * Convert the canonical logical frame to the hardware color/resolution
 * constraints selected by the original RESOURCE.CFG graphics_mode byte.
 * MCGA is deliberately a no-op.
 */
export function applyDisplayMode(frame: Uint8ClampedArray, width: number,
                                 height: number, mode: DisplayMode): void {
    if (mode === DISPLAY_MODE.mcga) return;
    for (let y = 0; y < height; ++y) {
        for (let x = 0; x < width; ++x) {
            const at = (y * width + x) * 4;
            let r = frame[at];
            let g = frame[at + 1];
            let b = frame[at + 2];
            let color: readonly [number, number, number];
            if (mode === DISPLAY_MODE.hgc || mode === DISPLAY_MODE.cga2) {
                const light = luminance(r, g, b);
                const threshold = mode === DISPLAY_MODE.hgc
                    ? BAYER_4[(y & 3) * 4 + (x & 3)] * 16
                    : BAYER_2[(y & 1) * 2 + (x & 1)] * 64;
                const on = light > threshold;
                color = on
                    ? (mode === DISPLAY_MODE.hgc
                        ? [222, 222, 210] : [255, 255, 255])
                    : [0, 0, 0];
            } else {
                if (mode === DISPLAY_MODE.cga) {
                    const bias = (BAYER_2[(y & 1) * 2 + (x & 1)] - 1.5) * 24;
                    r = Math.max(0, Math.min(255, r + bias));
                    g = Math.max(0, Math.min(255, g + bias));
                    b = Math.max(0, Math.min(255, b + bias));
                }
                color = nearest(r, g, b,
                    mode === DISPLAY_MODE.cga ? CGA_4 : RGBI_16);
            }
            frame[at] = color[0];
            frame[at + 1] = color[1];
            frame[at + 2] = color[2];
        }
    }
}

export function parseDisplayMode(value: string | null): DisplayMode {
    const parsed = Number(value ?? DISPLAY_MODE.mcga);
    return Number.isInteger(parsed) && parsed >= DISPLAY_MODE.ega &&
        parsed <= DISPLAY_MODE.tandy ? parsed as DisplayMode : DISPLAY_MODE.mcga;
}
