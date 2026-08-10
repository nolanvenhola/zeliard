export const GAMEPAD_DIRECTION = {
    up: 0x01,
    down: 0x02,
    left: 0x04,
    right: 0x08,
} as const;

export const GAMEPAD_BUTTON = {
    a: 0x01,
    b: 0x02,
    x: 0x04,
    start: 0x08,
    back: 0x10,
    y: 0x20,
    lb: 0x40,
    rb: 0x80,
} as const;

export type GamepadMask = { directions: number; buttons: number };

export type BrowserGamepad = {
    connected: boolean;
    axes: readonly number[];
    buttons: readonly { pressed: boolean; value: number }[];
};

const PRESS_THRESHOLD = 0.55;
const RELEASE_THRESHOLD = 0.35;

function pressed(pad: BrowserGamepad, index: number): boolean {
    const button = pad.buttons[index];
    return !!button && (button.pressed || button.value >= 0.5);
}

function axisDirection(value: number, negative: number, positive: number,
                       previous: number): number {
    const negativeThreshold = previous & negative
        ? RELEASE_THRESHOLD : PRESS_THRESHOLD;
    const positiveThreshold = previous & positive
        ? RELEASE_THRESHOLD : PRESS_THRESHOLD;
    if (value <= -negativeThreshold) return negative;
    if (value >= positiveThreshold) return positive;
    return 0;
}

/** Convert the standard browser layout to stick.asm's AL/AH bit masks. */
export function mapBrowserGamepad(pad: BrowserGamepad,
                                  previous: GamepadMask): GamepadMask {
    let directions = 0;
    const dpadHorizontal = (pressed(pad, 14) ? GAMEPAD_DIRECTION.left : 0) |
        (pressed(pad, 15) ? GAMEPAD_DIRECTION.right : 0);
    const dpadVertical = (pressed(pad, 12) ? GAMEPAD_DIRECTION.up : 0) |
        (pressed(pad, 13) ? GAMEPAD_DIRECTION.down : 0);
    directions |= dpadHorizontal || axisDirection(pad.axes[0] ?? 0,
        GAMEPAD_DIRECTION.left, GAMEPAD_DIRECTION.right,
        previous.directions);
    directions |= dpadVertical || axisDirection(pad.axes[1] ?? 0,
        GAMEPAD_DIRECTION.up, GAMEPAD_DIRECTION.down,
        previous.directions);

    let buttons = 0;
    if (pressed(pad, 0)) buttons |= GAMEPAD_BUTTON.a;
    if (pressed(pad, 1)) buttons |= GAMEPAD_BUTTON.b;
    if (pressed(pad, 2)) buttons |= GAMEPAD_BUTTON.x;
    if (pressed(pad, 9)) buttons |= GAMEPAD_BUTTON.start;
    if (pressed(pad, 8)) buttons |= GAMEPAD_BUTTON.back;
    if (pressed(pad, 3)) buttons |= GAMEPAD_BUTTON.y;
    if (pressed(pad, 4)) buttons |= GAMEPAD_BUTTON.lb;
    if (pressed(pad, 5)) buttons |= GAMEPAD_BUTTON.rb;
    return { directions, buttons };
}

export function firstConnectedGamepad(
    pads: readonly (BrowserGamepad | null)[]): BrowserGamepad | null {
    return pads.find((pad): pad is BrowserGamepad => !!pad?.connected) ?? null;
}
