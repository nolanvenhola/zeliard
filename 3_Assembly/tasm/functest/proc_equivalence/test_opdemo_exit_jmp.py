#!/usr/bin/env python3
"""
test_opdemo_exit_jmp.py — verify what the indirect jmp at the end of
opdemo.bin's `transition_out_to_game` actually targets.

Background
----------
At the end of the opening cinematic (100OPDMO.asm:1039), opdemo runs:

    mov ax, 0FFFFh
    jmp word ptr cs:scene_data_b      ; scene_data_b equ 6A73h

`scene_data_b` is a CS-relative address inside opdemo's loaded chunk
(opdemo loads at game_seg:0x6000, so scene_data_b = game_seg:0x6A73 =
file offset 0xA73 in opdemo.bin).

Static reading of the rebuilt 100OPDMO.bin shows the bytes at file
offset 0xA73-0xA74 are FF 26 = LE word 0x26FF.  But those bytes are
ALSO the second/third bytes of the jmp instruction itself (whose
encoding is `2E FF 26 73 6A` at file offset 0xA72-0xA76).  So the
jmp reads its own opcode bytes as the target address.

Possibilities:
  (a) The jmp really does land at game_seg:0x26FF — somewhere inside
      the loaded gfx-mode driver (which lives at game_seg:0x2000).
  (b) Some earlier code in opdemo OR in gfx_init_fn writes a real
      function pointer to game_seg:0x6A73 before the jmp executes,
      overriding the compile-time bytes.

This test verifies (a) for the ISOLATED case (no other code has run):
load opdemo, point IP at the jmp instruction, step once, and confirm
the new IP equals 0x26FF.

Test (b) — what happens if you let opdemo's init code run first —
would require loading gmega.bin too and emulating dispatch slots.
That's beyond scope for a quick functional confirmation; this test
just locks in the static fact.
"""
import sys
from pathlib import Path

# Allow `import harness` from the parent functest directory
HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))

from harness import TasmHarness, CODE_SEG  # noqa: E402

OPDEMO_BIN = HERE.parent.parent / 'bin' / 'zelres1' / '100OPDMO.bin'
LOAD_BASE  = 0x6000               # opdemo loads at game_seg:0x6000
JMP_INST_FILE_OFFSET = 0xA72      # `2E FF 26 73 6A` jmp word ptr cs:[6A73]
JMP_INST_RUNTIME_IP  = LOAD_BASE + JMP_INST_FILE_OFFSET  # 0x6A72
SCENE_DATA_B_ADDR    = 0x6A73     # CS-relative address of the jump-target ptr


def test_static_jmp_target():
    """Load opdemo, single-step the jmp, confirm the static target."""
    h = TasmHarness(str(OPDEMO_BIN), LOAD_BASE)

    # Sanity-check: confirm we found the right instruction at the
    # expected offset.  Bytes should be 2E FF 26 73 6A.
    instr_bytes = bytes(h.mu.mem_read(
        (CODE_SEG << 4) + JMP_INST_RUNTIME_IP, 5))
    assert instr_bytes == bytes([0x2E, 0xFF, 0x26, 0x73, 0x6A]), (
        f'instruction at IP 0x{JMP_INST_RUNTIME_IP:X} is '
        f'{instr_bytes.hex()}, expected 2eff26736a')

    # Read the word stored AT scene_data_b before any code runs
    # (this is just opdemo's compile-time bytes at that offset).
    target_word = bytes(h.mu.mem_read(
        (CODE_SEG << 4) + SCENE_DATA_B_ADDR, 2))
    target_addr = target_word[0] | (target_word[1] << 8)
    print(f'scene_data_b @ CS:0x{SCENE_DATA_B_ADDR:04X} = 0x{target_addr:04X}')

    # Set up CPU: CS = code seg, IP = jmp instruction, push a sentinel
    # return address (irrelevant for jmp but harness expects it).
    from unicorn import UcError
    from unicorn.x86_const import (
        UC_X86_REG_CS, UC_X86_REG_DS, UC_X86_REG_ES, UC_X86_REG_SS,
        UC_X86_REG_IP, UC_X86_REG_SP, UC_X86_REG_AX,
    )
    h.mu.reg_write(UC_X86_REG_CS, CODE_SEG)
    h.mu.reg_write(UC_X86_REG_DS, CODE_SEG)
    h.mu.reg_write(UC_X86_REG_ES, CODE_SEG)
    h.mu.reg_write(UC_X86_REG_SS, 0x5000)
    h.mu.reg_write(UC_X86_REG_SP, 0xFFFE)
    h.mu.reg_write(UC_X86_REG_AX, 0xFFFF)  # what opdemo sets just before the jmp
    h.mu.reg_write(UC_X86_REG_IP, JMP_INST_RUNTIME_IP)

    # Single-step exactly one instruction (the jmp).
    start_linear = (CODE_SEG << 4) + JMP_INST_RUNTIME_IP
    try:
        h.mu.emu_start(start_linear, start_linear + 100, count=1)
    except UcError as e:
        # The jmp may land in unmapped memory if 0x26FF is outside any
        # loaded region — that's OK, we still get to read the new IP.
        print(f'(emu_start raised {e}; likely jumped to unmapped memory)')

    new_ip = h.mu.reg_read(UC_X86_REG_IP)
    print(f'After 1-instruction step: IP = 0x{new_ip:04X}')

    # Verify the jmp landed where the static analysis predicted.
    assert new_ip == target_addr, (
        f'jmp landed at 0x{new_ip:04X}, expected 0x{target_addr:04X}')
    assert new_ip == 0x26FF, (
        f'expected static target 0x26FF, got 0x{new_ip:04X}')
    print(f'PASS: static jmp target verified at 0x{new_ip:04X}')

    # Where would 0x26FF be in the live game?  The gfx-mode driver
    # (gmega/gmcga/etc.) loads at game_seg:0x2000 per zeliad's driver
    # record, so 0x26FF = gfx_driver_offset 0x6FF.  Print this for
    # documentation — the actual function at that offset is
    # graphics-mode-specific (different bytes per driver).
    gfx_drv_offset = 0x26FF - 0x2000
    print(f'Note: in the live game, IP=0x{new_ip:04X} lands at')
    print(f'      gfx-driver offset 0x{gfx_drv_offset:X} (gfx driver loads at 0x2000)')


def test_no_runtime_write_to_scene_data_b():
    """Run opdemo from `start:` for many instructions with all dispatch
    slot calls stubbed.  Watch the bytes at scene_data_b — if no code
    writes them, then the compile-time value (0x26FF) is what the live
    game's jmp actually uses.

    This is the test that resolves the open question in
    OPENING_CINEMATIC.md (open question 1): is scene_data_b's value
    set at runtime or is it really the static 0x26FF?
    """
    from unicorn import UcError, UC_HOOK_MEM_WRITE
    from unicorn.x86_const import (
        UC_X86_REG_CS, UC_X86_REG_DS, UC_X86_REG_ES, UC_X86_REG_SS,
        UC_X86_REG_IP, UC_X86_REG_SP, UC_X86_REG_AX,
    )

    h = TasmHarness(str(OPDEMO_BIN), LOAD_BASE)

    # Pre-fill the entire CODE region with 0xC3 (near RET) so any
    # CALL into a dispatch slot (cs:[10Ch], cs:[120h], etc.) just
    # returns without doing anything.  This lets opdemo's startup
    # code run past its dependencies.
    h.mu.mem_write(CODE_SEG << 4, b'\xC3' * 0x10000)
    # Re-write opdemo's bytes on top of the C3 fill
    with open(OPDEMO_BIN, 'rb') as f:
        opdemo_bytes = f.read()
    h.mu.mem_write((CODE_SEG << 4) + LOAD_BASE, opdemo_bytes)

    # Track writes to scene_data_b range (0x6A73-0x6A74 is the word).
    SCENE_DATA_B_LIN = (CODE_SEG << 4) + SCENE_DATA_B_ADDR
    writes_to_scene_data_b = []

    def watch_write(_uc, _access, addr, size, value, _ud):
        end = addr + size
        if end > SCENE_DATA_B_LIN and addr <= SCENE_DATA_B_LIN + 1:
            ip = _uc.reg_read(UC_X86_REG_IP)
            writes_to_scene_data_b.append((ip, addr, size, value))

    h.mu.hook_add(UC_HOOK_MEM_WRITE, watch_write,
                  begin=SCENE_DATA_B_LIN, end=SCENE_DATA_B_LIN + 1)

    # Read initial value of scene_data_b
    initial_word = bytes(h.mu.mem_read(SCENE_DATA_B_LIN, 2))
    initial_val = initial_word[0] | (initial_word[1] << 8)
    print(f'\nBefore execution: scene_data_b = 0x{initial_val:04X}')

    # Set up CPU and run from opdemo's start: (game_seg:0x6000)
    h.mu.reg_write(UC_X86_REG_CS, CODE_SEG)
    h.mu.reg_write(UC_X86_REG_DS, CODE_SEG)
    h.mu.reg_write(UC_X86_REG_ES, CODE_SEG)
    h.mu.reg_write(UC_X86_REG_SS, 0x5000)
    h.mu.reg_write(UC_X86_REG_SP, 0xFFFE)
    h.mu.reg_write(UC_X86_REG_AX, 0)            # NEW game flag
    h.mu.reg_write(UC_X86_REG_IP, LOAD_BASE)    # opdemo's `start:`

    # Run for a reasonable instruction budget.  opdemo is roughly
    # 13869 bytes; with all calls stubbed the startup will plough
    # straight through, eventually crashing on something we can't
    # stub.  10000 instructions is enough to cover the early init
    # (gfx_init_fn, narration setup, first scene loads).
    start_lin = (CODE_SEG << 4) + LOAD_BASE
    try:
        h.mu.emu_start(start_lin, start_lin + 0x10000, count=20000)
    except UcError as e:
        ip_at_fault = h.mu.reg_read(UC_X86_REG_IP)
        print(f'(emu_start stopped at IP=0x{ip_at_fault:04X}: {e})')

    final_word = bytes(h.mu.mem_read(SCENE_DATA_B_LIN, 2))
    final_val = final_word[0] | (final_word[1] << 8)
    print(f'After execution:  scene_data_b = 0x{final_val:04X}')
    print(f'Writes to scene_data_b range: {len(writes_to_scene_data_b)}')
    for ip, addr, sz, val in writes_to_scene_data_b[:10]:
        print(f'  IP=0x{ip:04X}: addr=0x{addr:X} size={sz} value=0x{val:X}')

    # Conclusion
    if writes_to_scene_data_b:
        print(f'\nFINDING: scene_data_b IS modified at runtime.')
        print(f'         The actual jump target depends on what gets written.')
    else:
        print(f'\nFINDING: scene_data_b is NEVER written during opdemo init.')
        print(f'         The compile-time value 0x{initial_val:04X} is what')
        print(f'         the live game jumps to: game_seg:0x{initial_val:04X}')
        print(f'         = gfx-driver offset 0x{initial_val - 0x2000:X}.')


if __name__ == '__main__':
    print('=== Test 1: Single-step the indirect jmp ===')
    test_static_jmp_target()
    print('\n=== Test 2: Watch for runtime writes to scene_data_b ===')
    test_no_runtime_write_to_scene_data_b()
