#!/usr/bin/env python3
"""
TasmHarness — load a flat chunk into a Unicorn 16-bit x86 emulator, call any
function in isolation, and observe the resulting register/memory state.

The class name is historical. The active behavior tests now live under the
MASM tree and should load MASM-built bytes unless a test explicitly documents
an archival fixture.

Design goals
------------
* No DOSBox, no full game, no live hardware. One Python process, deterministic.
* No naming-via-LLM in the loop: the test asserts observable BEHAVIOR
  (memory writes, register effects, flags), not "this is `move_monster_E`."
* CALL handling: by default the harness lets calls through. Tests can
  install `stub_calls` to short-circuit out-of-scope dependencies (e.g. a
  test of `move_monster_E` can stub `check_collision_E2` to return CF=0
  to take the "passable" branch without dragging in the proximity map).

Calling convention
------------------
* The chunk is loaded so file_offset N maps to CS:IP = (load_base + N).
* Stack lives in its own segment (SS != CS) starting near 0xFFFE; we push
  a sentinel return address and watch for execution to land there to
  detect a clean return.
* DS is set to a separately-mapped data segment so tests can write fake
  structs (e.g. a fake `monster` struct at DS:0x1000) without colliding
  with the chunk's own constants.
"""

from unicorn import (
    Uc, UC_ARCH_X86, UC_MODE_16,
    UC_HOOK_CODE, UC_HOOK_MEM_INVALID,
    UC_HOOK_MEM_READ, UC_HOOK_MEM_WRITE,
    UC_PROT_ALL,
)
from unicorn.x86_const import (
    UC_X86_REG_CS, UC_X86_REG_DS, UC_X86_REG_ES, UC_X86_REG_SS,
    UC_X86_REG_IP, UC_X86_REG_SP, UC_X86_REG_BP,
    UC_X86_REG_AX, UC_X86_REG_BX, UC_X86_REG_CX, UC_X86_REG_DX,
    UC_X86_REG_SI, UC_X86_REG_DI, UC_X86_REG_EFLAGS,
)

# CPU flags bitmask (only the ones we care about)
FLAG_CF = 0x0001
FLAG_ZF = 0x0040
FLAG_SF = 0x0080
FLAG_OF = 0x0800

# Layout: pick segment values that give non-overlapping linear regions.
# CS_SEG << 4 = code base; DS_SEG << 4 = data base; SS_SEG << 4 = stack base.
# We map 64KB at each.
CODE_SEG  = 0x1000   # linear 0x10000
DATA_SEG  = 0x3000   # linear 0x30000
STACK_SEG = 0x5000   # linear 0x50000
STACK_TOP = 0xFFFE   # initial SP within stack segment

# Sentinel address pushed as the return address. When IP reaches this, the
# function has returned cleanly. We place the sentinel near the bottom of
# the code segment (well clear of any chunk's actual code, which always
# loads at >= 0x100) and pre-fill the area with NOPs so x86 instruction
# prefetch doesn't overshoot into unmapped memory before the hook stops us.
RET_SENTINEL = 0x80
SENTINEL_FILL = 0x90  # NOP — gives prefetch a valid, idempotent landing pad


class TasmHarness:
    def __init__(self, flat_path, load_base):
        """flat_path: path to the IDA-style flat (header-stripped) chunk.
        load_base: CPU IP at which the file starts (e.g. 0x6000 for fight.bin)."""
        self.mu = Uc(UC_ARCH_X86, UC_MODE_16)
        self.load_base = load_base

        # Map regions (must be 4KB-aligned, 4KB-multiple sizes)
        self.mu.mem_map(CODE_SEG  << 4, 0x10000, UC_PROT_ALL)
        self.mu.mem_map(DATA_SEG  << 4, 0x10000, UC_PROT_ALL)
        self.mu.mem_map(STACK_SEG << 4, 0x10000, UC_PROT_ALL)

        # Pre-fill the entire code segment with NOPs (0x90).  This means a
        # function's RET landing on an unmapped sentinel can't walk into
        # garbage during prefetch: it just nop-slides until the hook stops.
        self.mu.mem_write(CODE_SEG << 4, bytes([SENTINEL_FILL] * 0x10000))

        # Load chunk so file_offset N -> CS:(load_base + N)
        with open(flat_path, 'rb') as f:
            data = f.read()
        self.mu.mem_write((CODE_SEG << 4) + load_base, data)
        self.chunk_size = len(data)

    # ---------- memory helpers -----------------------------------------
    def write_data(self, offset, raw_bytes):
        """Write raw bytes to DS:offset."""
        self.mu.mem_write((DATA_SEG << 4) + offset, bytes(raw_bytes))

    def read_data(self, offset, length):
        return bytes(self.mu.mem_read((DATA_SEG << 4) + offset, length))

    def write_code(self, offset, raw_bytes):
        """Write raw bytes to CS:offset.  Useful for installing far-call
        thunks: pre-place a CB (retf) at some unused offset, then write a
        far pointer (offset, CODE_SEG) at the dispatch slot the function
        under test reads from.  The far-call then executes the RETF and
        comes back without leaving the current segment."""
        self.mu.mem_write((CODE_SEG << 4) + offset, bytes(raw_bytes))

    def install_farcall_thunk(self, dispatch_slot_offset, thunk_offset=0x100):
        """Convenience: install a far-call thunk that simply RETFs.
        The dispatch slot (a far pointer in CS) is pointed at thunk_offset,
        which gets a single CB byte.  Both writes are in CS so DS is
        untouched."""
        # Place RETF (0xCB) at thunk_offset
        self.write_code(thunk_offset, [0xCB])
        # Write far pointer (offset:segment) at dispatch_slot_offset
        ds_off = thunk_offset
        seg    = CODE_SEG
        self.write_code(dispatch_slot_offset,
                        [ds_off & 0xFF, (ds_off >> 8) & 0xFF,
                         seg    & 0xFF, (seg    >> 8) & 0xFF])

    def write_byte(self, offset, value):
        self.write_data(offset, [value & 0xFF])

    def read_byte(self, offset):
        return self.read_data(offset, 1)[0]

    def write_word(self, offset, value):
        self.write_data(offset, [value & 0xFF, (value >> 8) & 0xFF])

    def read_word(self, offset):
        b = self.read_data(offset, 2)
        return b[0] | (b[1] << 8)

    # ---------- snapshot / restore -------------------------------------
    def snapshot(self):
        """Save the data segment + register state.  Cheap (~64 KB copy).
        Use this when running N probes against the same setup — write
        fixtures once, snapshot, run probe, restore, run next probe."""
        return {
            'data': bytes(self.mu.mem_read(DATA_SEG << 4, 0x10000)),
            'regs': {r: self.mu.reg_read(uc) for r, uc in {
                'ax': UC_X86_REG_AX, 'bx': UC_X86_REG_BX,
                'cx': UC_X86_REG_CX, 'dx': UC_X86_REG_DX,
                'si': UC_X86_REG_SI, 'di': UC_X86_REG_DI,
                'bp': UC_X86_REG_BP, 'sp': UC_X86_REG_SP,
                'eflags': UC_X86_REG_EFLAGS,
            }.items()},
        }

    def restore(self, snap):
        """Restore a snapshot returned by snapshot()."""
        self.mu.mem_write(DATA_SEG << 4, snap['data'])
        reg_map = {
            'ax': UC_X86_REG_AX, 'bx': UC_X86_REG_BX,
            'cx': UC_X86_REG_CX, 'dx': UC_X86_REG_DX,
            'si': UC_X86_REG_SI, 'di': UC_X86_REG_DI,
            'bp': UC_X86_REG_BP, 'sp': UC_X86_REG_SP,
            'eflags': UC_X86_REG_EFLAGS,
        }
        for k, v in snap['regs'].items():
            self.mu.reg_write(reg_map[k], v)

    # ---------- result formatting --------------------------------------
    @staticmethod
    def format_diffs(result, base=0):
        """Canonical string of byte deltas: 'DS:0x86 0x00->0x64'.
        Pass base != 0 to print absolute addresses (e.g. base=DS).
        Reused across all tests so output is grep-able.
        """
        lines = []
        for off, before, after in result.get('mem_diffs', []):
            lines.append(f'DS:0x{base + off:04X} 0x{before:02X}->0x{after:02X}')
        return '\n'.join(lines)

    @staticmethod
    def fingerprint(result):
        """Hashable tuple summarizing what the function did.  Two runs that
        produce the same fingerprint behaved identically at the byte level.
        Used by tests that group N functions by behavior (see
        test_fight_dispatch_8slots_fingerprint.py)."""
        diffs = tuple(sorted(
            (off, before, after)
            for off, before, after in result.get('mem_diffs', [])
        ))
        flags = tuple(sorted(result.get('flags_after', {}).items()))
        return (diffs, flags, result.get('stopped_reason'))

    # ---------- function call ------------------------------------------
    def call_function(self, func_addr, regs=None, stub_calls=None,
                      max_steps=10000, trace=False,
                      watch_reads=None, watch_writes=None):
        """Call the function at CPU address `func_addr`. Returns a dict.

        regs: dict of register-name -> value (e.g. {'si': 0x1000, 'ax': 0}).
              CS/DS/ES/SS are set automatically; IP is set to func_addr.
        stub_calls: dict of target_addr -> stub_dict. When execution reaches
                    one of these addresses, it RETs immediately with the
                    given effects: {'cf': 0|1, 'ax': int (optional),
                    'scan_si_until': [byte, ...] (optional)}.
        max_steps: instruction-budget safety cap.
        trace: if True, prints every instruction's address as it executes.
        watch_reads: list of DS offsets to monitor; result['reads_observed']
                     gets a list of (offset, ip) tuples whenever code reads
                     one of these.  Used to detect 'is anyone reading [9Ch]?'
        watch_writes: same shape for write detection.
        """
        regs = regs or {}
        stub_calls = stub_calls or {}

        # Snapshot data segment so we can diff after.
        before_data = bytes(self.mu.mem_read(DATA_SEG << 4, 0x10000))

        # Initial register state
        self.mu.reg_write(UC_X86_REG_CS, CODE_SEG)
        self.mu.reg_write(UC_X86_REG_DS, DATA_SEG)
        self.mu.reg_write(UC_X86_REG_ES, DATA_SEG)
        self.mu.reg_write(UC_X86_REG_SS, STACK_SEG)
        self.mu.reg_write(UC_X86_REG_SP, STACK_TOP)
        self.mu.reg_write(UC_X86_REG_BP, 0)
        self.mu.reg_write(UC_X86_REG_EFLAGS, 0x0002)  # always-1 bit only

        reg_map = {
            'ax': UC_X86_REG_AX, 'bx': UC_X86_REG_BX,
            'cx': UC_X86_REG_CX, 'dx': UC_X86_REG_DX,
            'si': UC_X86_REG_SI, 'di': UC_X86_REG_DI,
            'bp': UC_X86_REG_BP,
            'ds': UC_X86_REG_DS, 'es': UC_X86_REG_ES,
        }
        for k, v in regs.items():
            if k.lower() not in reg_map:
                raise KeyError(f'unknown register: {k}')
            self.mu.reg_write(reg_map[k.lower()], v & 0xFFFF)

        # Push sentinel return address (near-call/near-RET convention).
        sp = STACK_TOP - 2
        self.mu.mem_write((STACK_SEG << 4) + sp,
                          bytes([RET_SENTINEL & 0xFF, (RET_SENTINEL >> 8) & 0xFF]))
        self.mu.reg_write(UC_X86_REG_SP, sp)

        # Stop-condition state
        state = {
            'stopped_reason': None,
            'instructions':   0,
            'last_ip':        None,
            'trace':          [] if trace else None,
            'reads_observed': [] if watch_reads is not None else None,
            'writes_observed': [] if watch_writes is not None else None,
        }
        watch_read_set  = set(watch_reads or [])
        watch_write_set = set(watch_writes or [])

        def hook_code(uc, addr, size, _ud):
            state['instructions'] += 1
            state['last_ip'] = addr
            if trace:
                state['trace'].append((addr, size))
            # Stop if we've returned to sentinel
            ip_only = addr - (CODE_SEG << 4)
            if ip_only == RET_SENTINEL:
                state['stopped_reason'] = 'returned_to_sentinel'
                uc.emu_stop()
                return
            # If we landed at a stubbed call target, simulate that the
            # call ran, set the stub's effects, and resume emulation at
            # the caller (no emu_stop here — we want the test function to
            # continue past the call site).
            if ip_only in stub_calls:
                stub = stub_calls[ip_only]
                state.setdefault('stubs_fired', []).append(ip_only)
                state.setdefault('stub_regs', []).append({
                    'ip': ip_only,
                    'ax': uc.reg_read(UC_X86_REG_AX) & 0xFFFF,
                    'bx': uc.reg_read(UC_X86_REG_BX) & 0xFFFF,
                    'cx': uc.reg_read(UC_X86_REG_CX) & 0xFFFF,
                    'dx': uc.reg_read(UC_X86_REG_DX) & 0xFFFF,
                    'si': uc.reg_read(UC_X86_REG_SI) & 0xFFFF,
                    'di': uc.reg_read(UC_X86_REG_DI) & 0xFFFF,
                    'ds': uc.reg_read(UC_X86_REG_DS) & 0xFFFF,
                    'es': uc.reg_read(UC_X86_REG_ES) & 0xFFFF,
                })

                eflags = uc.reg_read(UC_X86_REG_EFLAGS)
                if 'cf' in stub:
                    if stub['cf']:
                        eflags |= FLAG_CF
                    else:
                        eflags &= ~FLAG_CF
                uc.reg_write(UC_X86_REG_EFLAGS, eflags)
                if 'ax' in stub:
                    uc.reg_write(UC_X86_REG_AX, stub['ax'] & 0xFFFF)
                if 'scan_si_until' in stub:
                    terminators = set(stub['scan_si_until'])
                    scan_seg = uc.reg_read(UC_X86_REG_DS) & 0xFFFF
                    scan_si = uc.reg_read(UC_X86_REG_SI) & 0xFFFF
                    while True:
                        value = uc.mem_read((scan_seg << 4) + scan_si, 1)[0]
                        scan_si = (scan_si + 1) & 0xFFFF
                        if value in terminators:
                            break
                    uc.reg_write(UC_X86_REG_SI, scan_si)

                # Simulate RET: pop the return address from the stack,
                # set IP to it, leave SP advanced.  Resume emulation.
                cur_sp = uc.reg_read(UC_X86_REG_SP)
                ret_bytes = uc.mem_read((STACK_SEG << 4) + cur_sp, 2)
                ret_ip = ret_bytes[0] | (ret_bytes[1] << 8)
                uc.reg_write(UC_X86_REG_SP, cur_sp + 2)
                # Tell Unicorn to resume at the post-call IP rather than
                # executing the stub_target's real instruction.
                uc.emu_stop()  # exit current emu_start; outer loop reissues
                state['_resume_ip'] = ret_ip
                return

        def hook_invalid(uc, _typ, addr, _size, _val, _ud):
            state['stopped_reason'] = f'invalid_mem_access_at_0x{addr:X}'
            return False  # let Unicorn raise

        ds_base = DATA_SEG << 4

        def hook_read(_uc, _access, addr, size, _value, _ud):
            for off in range(addr, addr + size):
                ds_off = off - ds_base
                if ds_off in watch_read_set:
                    state['reads_observed'].append((ds_off, state['last_ip']))

        def hook_write(_uc, _access, addr, size, _value, _ud):
            for off in range(addr, addr + size):
                ds_off = off - ds_base
                if ds_off in watch_write_set:
                    state['writes_observed'].append((ds_off, state['last_ip']))

        h_code = self.mu.hook_add(UC_HOOK_CODE, hook_code)
        h_inv  = self.mu.hook_add(UC_HOOK_MEM_INVALID, hook_invalid)
        h_read = h_write = None
        if watch_read_set:
            lo = ds_base + min(watch_read_set)
            hi = ds_base + max(watch_read_set)
            h_read = self.mu.hook_add(UC_HOOK_MEM_READ, hook_read, begin=lo, end=hi)
        if watch_write_set:
            lo = ds_base + min(watch_write_set)
            hi = ds_base + max(watch_write_set)
            h_write = self.mu.hook_add(UC_HOOK_MEM_WRITE, hook_write, begin=lo, end=hi)

        # Re-entry loop: each time a stub fires we exit emu_start cleanly,
        # then jump back in at the simulated post-RET IP.  Loop until either
        # the sentinel is reached, an invalid memory access happens, or the
        # instruction budget is exhausted.
        next_ip = func_addr
        try:
            while True:
                state.pop('_resume_ip', None)
                budget_left = max_steps - state['instructions']
                if budget_left <= 0:
                    state['stopped_reason'] = (
                        f'max_steps_exhausted ({max_steps})')
                    break
                self.mu.emu_start(
                    begin=(CODE_SEG << 4) + next_ip,
                    until=0,                # rely on hooks for stop
                    count=budget_left,
                )
                # If a stub fired, resume at the simulated return-IP.
                if state.get('_resume_ip') is not None:
                    next_ip = state['_resume_ip']
                    state['stopped_reason'] = None  # transient stop
                    continue
                # Otherwise we hit sentinel, invalid mem, or count==0.
                if state['stopped_reason'] is None:
                    state['stopped_reason'] = (
                        f'max_steps_exhausted ({max_steps})')
                break
        except Exception as e:
            if state['stopped_reason'] is None:
                state['stopped_reason'] = f'exception: {e}'
        finally:
            self.mu.hook_del(h_code)
            self.mu.hook_del(h_inv)
            if h_read is not None:
                self.mu.hook_del(h_read)
            if h_write is not None:
                self.mu.hook_del(h_write)

        # Snapshot resulting state
        regs_after = {
            'ax': self.mu.reg_read(UC_X86_REG_AX) & 0xFFFF,
            'bx': self.mu.reg_read(UC_X86_REG_BX) & 0xFFFF,
            'cx': self.mu.reg_read(UC_X86_REG_CX) & 0xFFFF,
            'dx': self.mu.reg_read(UC_X86_REG_DX) & 0xFFFF,
            'si': self.mu.reg_read(UC_X86_REG_SI) & 0xFFFF,
            'di': self.mu.reg_read(UC_X86_REG_DI) & 0xFFFF,
            'ds': self.mu.reg_read(UC_X86_REG_DS) & 0xFFFF,
            'es': self.mu.reg_read(UC_X86_REG_ES) & 0xFFFF,
            'bp': self.mu.reg_read(UC_X86_REG_BP) & 0xFFFF,
            'sp': self.mu.reg_read(UC_X86_REG_SP) & 0xFFFF,
        }
        eflags = self.mu.reg_read(UC_X86_REG_EFLAGS)
        flags_after = {
            'CF': bool(eflags & FLAG_CF),
            'ZF': bool(eflags & FLAG_ZF),
            'SF': bool(eflags & FLAG_SF),
            'OF': bool(eflags & FLAG_OF),
        }

        # Diff data segment
        after_data = bytes(self.mu.mem_read(DATA_SEG << 4, 0x10000))
        mem_diffs = []
        for i in range(len(before_data)):
            if before_data[i] != after_data[i]:
                mem_diffs.append((i, before_data[i], after_data[i]))

        return {
            'regs_after':       regs_after,
            'flags_after':      flags_after,
            'mem_diffs':        mem_diffs,
            'instructions':     state['instructions'],
            'stopped_reason':   state['stopped_reason'],
            'last_ip':          state['last_ip'],
            'reads_observed':   state['reads_observed'],
            'writes_observed':  state['writes_observed'],
            'stubs_fired':      state.get('stubs_fired', []),
            'stub_regs':        state.get('stub_regs', []),
        }
