/*
 * Browser-only reference lane. This does not translate or reinterpret the
 * opening: it boots FreeDOS and executes the bit-perfect MASM release files.
 * Its canvas is the visual/input/timing oracle for the mechanical C runtime.
 */
import { V86 } from "v86";
import type { BootOrder } from "v86";

const status = document.getElementById("status")!;
const screen = document.getElementById("screen-container")!;

type HybridCaptureState = {
    mcga_started_at_ms: number | null;
    modes: Array<{ width: number; height: number; bpp: number; at_ms: number }>;
};

const captureState: HybridCaptureState = {
    mcga_started_at_ms: null,
    modes: [],
};

function setStatus(message: string) {
    status.textContent = message;
    console.log(`[zeliard-masm] ${message}`);
}

setStatus("booting FreeDOS and the MASM release...");
const emulator = new V86({
    wasm_path: "/hybrid/v86.wasm",
    memory_size: 32 * 1024 * 1024,
    vga_memory_size: 2 * 1024 * 1024,
    bios: { url: "/hybrid/seabios.bin" },
    vga_bios: { url: "/hybrid/vgabios.bin" },
    fda: { url: "/hybrid/freedos-zeliard.img" },
    fdb: { url: "/hybrid/masm-release.img" },
    screen: { container: screen },
    boot_order: 0x321 as BootOrder,
    autostart: true,
});

emulator.add_listener("emulator-ready", () => setStatus("MASM reference running - click display to send input"));
emulator.add_listener("emulator-stopped", () => setStatus("MASM reference stopped"));
emulator.add_listener("screen-set-size", ([width, height, bpp]) => {
    const at_ms = performance.now();
    captureState.modes.push({ width, height, bpp, at_ms });
    if (width === 320 && height === 200 && bpp === 8 && captureState.mcga_started_at_ms === null) {
        captureState.mcga_started_at_ms = at_ms;
    }
    console.log(`[zeliard-masm] video mode ${width}x${height}x${bpp}`);
});

screen.addEventListener("click", () => {
    const canvas = screen.querySelector("canvas");
    canvas?.focus();
});

// Exposed deliberately for Playwright capture and state/screenshot tooling.
(window as Window & { __zeliardMasm?: V86 }).__zeliardMasm = emulator;
(window as Window & { __zeliardMasmCapture?: HybridCaptureState }).__zeliardMasmCapture = captureState;
