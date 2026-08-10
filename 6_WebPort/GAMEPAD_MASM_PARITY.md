# Browser gamepad parity

Ticket 188 maps the browser's standard Gamepad layout into the resident input
contract implemented by `stick.asm`; it does not create a separate gameplay
input path.

## MASM contract

- `query_input_state` merges joystick directions with the keyboard direction
  byte and joystick buttons with the keyboard skip/button byte
  (`3_Assembly/masm/working/drivers/stick.asm:841-859`).
- `calc_joystick_deadzone` returns Up `01h`, Down `02h`, Left `04h`, and Right
  `08h`, with calibrated low/high comparisons
  (`stick.asm:862-927`).
- `poll_joystick_buttons` samples the game port on the timer cadence and uses
  make/release latches for buttons A and B (`stick.asm:305-365`).
- The original saved joystick-enabled flag is `gvar_last_key`; the web host
  mirrors connection state into its `FF0A` byte (`stick.asm:311,848`).

The C boundary therefore accepts a four-bit direction mask and an eight-bit
host-action mask. It merges keyboard and controller ownership per logical key,
so releasing either device cannot release a key still held by the other.

## Standard controller layout

| Controller | Game action |
|---|---|
| Left stick / D-pad | Move and navigate |
| A | Attack / confirm / resume |
| B | Secondary / No |
| X | Inventory |
| Start | Pause |
| Back | F7 load menu |
| Y | F9 speed menu |
| LB / RB | F1 music / F2 sound |

Axes use a `0.55` press threshold and `0.35` release threshold. This hysteresis
is deterministic and prevents analog noise from producing repeated direction
edges. D-pad input takes precedence on each axis. Disconnecting emits a zero
controller mask while retaining any keyboard-held keys.

The release-byte oracle remains
`3_Assembly/masm/functest/proc_equivalence/test_stick_continuous_input_oracle.py`.
The corresponding web boundary fixtures are in
`engine/tests/continuous_input_native.c`; browser mapping fixtures are in
`shell/test_gamepad_host.mjs`.
