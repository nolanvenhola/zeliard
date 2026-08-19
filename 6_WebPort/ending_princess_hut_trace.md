# Princess hut to ending: release-MASM trace

Behavioral sources: `211OMOYP.asm`, `250ENDMO.asm`, `105GDMCA.asm`, and
their bit-perfect release binaries. Runtime addresses below use the loaded
game segment; chunk bytes land four bytes before their nominal load address.

## 211OMOYP: hut and handoff

1. `omoya_main` loads `omoya.grp` at the graphics-data destination, copies
   its first 256 bytes into the driver, invokes `drv_screen_init_a` and
   `drv_screen_init_b`, draws the "In the Hut" header, and draws the complete
   16-by-17 `banner_tile_grid`. This is the stone-Princess frame.
2. Only after that frame is complete, `test [0049h],FFh` selects the ending
   branch.
3. `end_demo_transition` loads `endmo.bin` at `6000h` and the mode-selected
   GD driver at `3000h`.
4. It clears `FF50h` and waits for exactly `012Ch` (300) raw PIT ticks. The
   stone-Princess hut frame remains visible throughout this wait.
5. It calls the GD driver through `[3006h]` with `BX=0000h`, `CX=50C8h`.
   MCGA resolves this to `105GDMCA:disp_render_a_rev`; the transition is
   produced by the assembly driver and its timer boundaries.
6. It sets cinematic flag `FF77h=FFh` and jumps through `[6000h]`. The loaded
   entry word is `6002h`.

## 250ENDMO: opening restoration shot

1. The entry block sets `SP=2000h`, narration PC `6630h=6AA8h`, selects
   palette 6, and loads `yuup.grp` (`8152h`).
2. It decompresses `yuup.grp` into `4000h`, loads/decompresses `new1.grp`
   (`8173h`) into `8000h`, and draws two `24h x 58h` panels:
   Duke at packed coordinate `0B18h`, and Felicia's lower body/legs at
   `2D71h`.
3. It holds that split composition for `FFh` timer ticks.
4. `init_wipe_loop` runs exactly `59h` (89) iterations. Each iteration takes
   the next two-row source position from `new1.grp`, blits the lower-right
   panel at its new position, and waits `0Ah` ticks. This is the upward pan
   from Felicia's legs to her face.
5. It then loads `waku.grp` (`813Dh`), draws the next scene, and enters the
   narration interpreter at the script beginning at `6AA8h`.

The native oracle locks the visible boundaries to these hashes:

- first assembly-rendered panel boundary: `c71123a36a443a72`
- complete split-panel composition: `70243a26c753c1e9`
- completed upward pan / first script byte: `8fc1408e72eafcf4`

## Remaining 250ENDMO flow

The main scene sequence loads, in execution order:

`waku` -> `new2` -> `sei` -> `yuup` + `seip` -> `himp` -> `ne80` + `ne81`.

It then starts `zend.msd` (chunk `27h`) and loads the credits/epilogue banks:

`end5`, `end4`, `end6`, `end7`, `en72`, `final`.

The credits dispatcher advances through scene indices 0 through 7. Its `F7`
opcode waits for a fresh action latch. The terminal release instruction is at
`66C8h`; the full accelerated oracle reaches it after all seven scene-index
changes and verifies music chunk `27h` remains selected.
