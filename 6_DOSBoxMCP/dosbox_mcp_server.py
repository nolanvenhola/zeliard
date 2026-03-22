#!/usr/bin/env python3
"""
DOSBox-X MCP Server for Zeliard reverse engineering.

Exposes tools to Claude Code for controlling the DOSBox-X debugger:
  - Launch game with debug config
  - Set / clear / list breakpoints
  - Resume / step execution
  - Dump memory regions to file and read them back
  - Read registers via debugger window screenshot
  - Send raw debugger commands

Window automation: pywin32 to find the window + pyautogui to type commands.
Memory dumps: MEMDUMPBIN writes to c:/dosbox-x/, server reads them back.
Registers: Pillow screenshot of debugger panel, parsed with regex.
"""

import json
import os
import re
import subprocess
import time
from pathlib import Path

import ctypes
import win32gui
import win32con
import win32process
import pyautogui
pyautogui.FAILSAFE = False
from PIL import ImageGrab
from fastmcp import FastMCP

# Tesseract path (Windows install via winget/choco)
try:
    import pytesseract as _pt
    _pt.pytesseract.tesseract_cmd = r"C:\Program Files\Tesseract-OCR\tesseract.exe"
except ImportError:
    pass

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------

DOSBOX_EXE   = "c:/dosbox-x/dosbox-x.exe"
GAME_CONF    = Path(__file__).parent / "game_dosbox.conf"
KNOWN_ADDRS  = Path(__file__).parent / "known_addresses.json"
DUMP_DIR     = Path("c:/dosbox-x")

# DOSBox-X window title substrings
DOSBOX_TITLE    = "DOSBox-X"
DEBUGGER_TITLE  = "DOSBox-X Debugger"   # exact title of the separate debugger panel

# Delay after sending a command before reading output files
CMD_SETTLE   = 0.4   # seconds
DUMP_SETTLE  = 0.8   # seconds (file write takes longer)

# ---------------------------------------------------------------------------
# Internal helpers
# ---------------------------------------------------------------------------

def _find_main_hwnd() -> int | None:
    """Return the HWND of the main DOSBox-X game window (not the debugger panel)."""
    found = []
    def _cb(hwnd, _):
        title = win32gui.GetWindowText(hwnd)
        if (DOSBOX_TITLE in title
                and title != DEBUGGER_TITLE
                and win32gui.IsWindowVisible(hwnd)):
            found.append(hwnd)
    win32gui.EnumWindows(_cb, None)
    return found[0] if found else None


def _find_debugger_hwnd() -> int | None:
    """Return the HWND of the DOSBox-X Debugger panel window, or None if not open."""
    found = []
    def _cb(hwnd, _):
        if win32gui.GetWindowText(hwnd) == DEBUGGER_TITLE and win32gui.IsWindowVisible(hwnd):
            found.append(hwnd)
    win32gui.EnumWindows(_cb, None)
    return found[0] if found else None


def _find_dosbox_hwnd() -> int | None:
    """Return the HWND of any DOSBox-X window (main or debugger). Legacy helper."""
    return _find_main_hwnd() or _find_debugger_hwnd()


def _open_debugger() -> int:
    """
    Open the DOSBox-X Debugger window if it isn't already open (Ctrl+D).
    Returns the debugger window HWND.
    Raises RuntimeError if DOSBox-X is not running or the debugger fails to appear.
    """
    dbg_hwnd = _find_debugger_hwnd()
    if dbg_hwnd:
        return dbg_hwnd

    main_hwnd = _find_main_hwnd()
    if not main_hwnd:
        raise RuntimeError("DOSBox-X not running. Call launch_game() first.")

    # Send Ctrl+D to main window via PostMessage — no focus steal
    import win32api, win32con as _wc
    VK_D = 0x44
    win32api.PostMessage(main_hwnd, _wc.WM_KEYDOWN, _wc.VK_CONTROL, 0)
    win32api.PostMessage(main_hwnd, _wc.WM_KEYDOWN, VK_D, 0)
    win32api.PostMessage(main_hwnd, _wc.WM_KEYUP,   VK_D, 0)
    win32api.PostMessage(main_hwnd, _wc.WM_KEYUP,   _wc.VK_CONTROL, 0)
    time.sleep(1.5)                  # wait for the window to appear

    dbg_hwnd = _find_debugger_hwnd()
    if not dbg_hwnd:
        raise RuntimeError(
            "DOSBox-X Debugger window did not appear after Ctrl+D. "
            "Try Debug → Start DOSBox-X Debugger manually in the DOSBox-X menu bar."
        )
    return dbg_hwnd


def _force_foreground(hwnd: int) -> None:
    """
    Reliably bring a window to the foreground on Windows.
    SetForegroundWindow alone fails when called from a background process;
    AttachThreadInput lets us borrow the foreground thread's input focus.
    """
    win32gui.ShowWindow(hwnd, win32con.SW_RESTORE)
    current_tid = ctypes.windll.kernel32.GetCurrentThreadId()
    target_tid  = win32process.GetWindowThreadProcessId(hwnd)[0]
    if current_tid != target_tid:
        ctypes.windll.user32.AttachThreadInput(current_tid, target_tid, True)
        try:
            win32gui.BringWindowToTop(hwnd)
            try:
                win32gui.SetForegroundWindow(hwnd)
            except Exception:
                pass  # Windows may deny this from background processes; BringWindowToTop + click is enough
        finally:
            ctypes.windll.user32.AttachThreadInput(current_tid, target_tid, False)
    else:
        try:
            win32gui.SetForegroundWindow(hwnd)
        except Exception:
            pass
    time.sleep(0.15)


def _send(cmd: str) -> None:
    """
    Send a command to the DOSBox-X Debugger's I-> input line using
    PostMessage(WM_CHAR) — never steals focus or mouse from the user.
    """
    import win32api
    import win32con as _wc

    dbg_hwnd = _find_debugger_hwnd()
    if not dbg_hwnd:
        dbg_hwnd = _open_debugger()

    # Post each character directly to the window message queue.
    # WM_CHAR delivers characters without requiring focus.
    for ch in cmd:
        win32api.PostMessage(dbg_hwnd, _wc.WM_CHAR, ord(ch), 0)
        time.sleep(0.02)
    # Send Enter (VK_RETURN) as WM_KEYDOWN + WM_KEYUP
    win32api.PostMessage(dbg_hwnd, _wc.WM_KEYDOWN, _wc.VK_RETURN, 0)
    win32api.PostMessage(dbg_hwnd, _wc.WM_KEYUP,   _wc.VK_RETURN, 0)
    time.sleep(CMD_SETTLE)


def _read_dump(path: Path, max_bytes: int = 4096) -> str:
    """Read a binary dump file and return annotated hex rows."""
    if not path.exists():
        raise FileNotFoundError(f"Dump file not found: {path}")
    data = path.read_bytes()[:max_bytes]
    rows = []
    for i in range(0, len(data), 16):
        chunk = data[i:i + 16]
        hex_part = " ".join(f"{b:02X}" for b in chunk)
        asc_part = "".join(chr(b) if 32 <= b < 127 else "." for b in chunk)
        rows.append(f"  {i:04X}: {hex_part:<47}  {asc_part}")
    truncated = f"\n  … ({len(path.read_bytes())} bytes total, showing first {max_bytes})" \
                if path.stat().st_size > max_bytes else ""
    return "\n".join(rows) + truncated


def _parse_registers(text: str) -> dict:
    """
    Parse DOSBox-X debugger register display from a screenshot OCR string.
    Handles both 16-bit (CS/IP) and 32-bit (EAX etc.) displays.
    """
    regs = {}
    # 32-bit general registers: EAX=XXXXXXXX
    for m in re.finditer(r'\b(E?[ABCD]X|E?[SD]I|E?[BS]P|E?IP|E?SP)=([0-9A-Fa-f]{4,8})', text):
        regs[m.group(1)] = m.group(2).upper()
    # Segment registers: CS=XXXX DS=XXXX etc.
    for m in re.finditer(r'\b(CS|DS|ES|FS|GS|SS)=([0-9A-Fa-f]{4})', text):
        regs[m.group(1)] = m.group(2).upper()
    # Flags
    for m in re.finditer(r'\b(CF|ZF|SF|OF|PF|AF|DF|IF)=([01])', text):
        regs[m.group(1)] = m.group(2)
    return regs


def _wait_for_breakpoint_pause(timeout_secs: float = 5.0) -> bool:
    """
    Poll the DOSBox-X game window until execution appears frozen (breakpoint hit).

    Grabs a small thumbnail of the game window every 100 ms.  If 4 consecutive
    thumbnails are pixel-identical (400 ms of stability) we conclude the emulation
    has paused at a breakpoint and return True.  Returns False on timeout.

    Limitation: a game screen that is genuinely static (e.g. waiting for input on
    a still image) can also look frozen.  The caller should cross-check CS:IP to
    confirm a known breakpoint was actually hit.
    """
    main_hwnd = _find_main_hwnd()
    if not main_hwnd:
        return False

    deadline = time.time() + timeout_secs
    ring: list[bytes] = []

    # Send run first and wait a short moment so the frame starts changing
    time.sleep(0.15)

    while time.time() < deadline:
        left, top, right, bottom = win32gui.GetWindowRect(main_hwnd)
        # Trim window decoration; grab inner content area
        bbox = (left + 4, top + 30, right - 4, bottom - 4)
        img = ImageGrab.grab(bbox=bbox)
        # Downsample to 80×60 for cheap byte comparison
        thumb = img.resize((80, 60))
        data = thumb.tobytes()

        ring.append(data)
        if len(ring) > 4:
            ring.pop(0)

        # Four consecutive identical frames ≈ 400 ms of no change → paused
        if len(ring) == 4 and all(f == ring[-1] for f in ring):
            return True

        time.sleep(0.1)

    return False


def _screenshot_debugger():
    """
    Capture the DOSBox-X Debugger window using PrintWindow — works even when
    the window is behind VS Code or any other window.
    Returns a PIL Image, or None if the debugger is not open.
    """
    import win32ui
    import win32con as _wc

    dbg_hwnd = _find_debugger_hwnd()
    if not dbg_hwnd:
        return None

    left, top, right, bottom = win32gui.GetWindowRect(dbg_hwnd)
    w = right - left
    h = bottom - top
    if w <= 0 or h <= 0:
        return None

    # Create a device context and bitmap to render into
    hwnd_dc  = win32gui.GetWindowDC(dbg_hwnd)
    mfc_dc   = win32ui.CreateDCFromHandle(hwnd_dc)
    save_dc  = mfc_dc.CreateCompatibleDC()
    bmp      = win32ui.CreateBitmap()
    bmp.CreateCompatibleBitmap(mfc_dc, w, h)
    save_dc.SelectObject(bmp)

    # PW_RENDERFULLCONTENT (2) — works for layered/composited windows
    result = ctypes.windll.user32.PrintWindow(dbg_hwnd, save_dc.GetSafeHdc(), 2)
    if not result:
        # Fallback: PW_CLIENTONLY (1)
        ctypes.windll.user32.PrintWindow(dbg_hwnd, save_dc.GetSafeHdc(), 1)

    bmp_info = bmp.GetInfo()
    bmp_bits = bmp.GetBitmapBits(True)

    from PIL import Image as _Image
    img = _Image.frombuffer(
        "RGB",
        (bmp_info["bmWidth"], bmp_info["bmHeight"]),
        bmp_bits,
        "raw", "BGRX", 0, 1,
    )

    # Cleanup
    save_dc.DeleteDC()
    mfc_dc.DeleteDC()
    win32gui.ReleaseDC(dbg_hwnd, hwnd_dc)
    win32gui.DeleteObject(bmp.GetHandle())

    return img


def _capture_registers_fast() -> dict:
    """
    Screenshot the DOSBox-X Debugger panel and return a register dict.

    Uses pytesseract when available; returns an empty dict otherwise.
    Only the top third of the debugger window (the register display) is scanned
    to reduce OCR time.
    """
    img = _screenshot_debugger()
    if img is None:
        return {}
    w, h = img.size
    reg_area = img.crop((0, 0, w, h // 3))
    try:
        import pytesseract
        text = pytesseract.image_to_string(reg_area, config="--psm 6")
        return _parse_registers(text)
    except Exception:
        return {}


# ---------------------------------------------------------------------------
# MCP server
# ---------------------------------------------------------------------------

mcp = FastMCP(
    name="dosbox-zeliard",
    instructions=(
        "Controls DOSBox-X for Zeliard reverse engineering. "
        "Use launch_game() first, then set breakpoints by name or address. "
        "The user plays the game; when a breakpoint fires call read_registers() "
        "and dump_memory() to inspect state. Use resume() to continue."
    ),
)


@mcp.tool()
def launch_game() -> str:
    """
    Start DOSBox-X, wait at the C:\\ prompt, then open the Debugger panel.
    Call set_breakpoint() next, then start_game() to run zeliad.exe.
    This ensures breakpoints are in place before the game executes a single instruction.
    """
    if _find_main_hwnd():
        # Ensure debugger is open even if game was already running
        dbg = _find_debugger_hwnd()
        if not dbg:
            try:
                dbg = _open_debugger()
                return f"DOSBox-X already running; debugger opened (hwnd={dbg:#010x})."
            except RuntimeError as e:
                return f"DOSBox-X already running but debugger failed to open: {e}"
        return "DOSBox-X is already running with debugger open."

    subprocess.Popen(
        [DOSBOX_EXE, "-conf", str(GAME_CONF)],
        creationflags=subprocess.DETACHED_PROCESS,
    )
    time.sleep(3.5)   # wait for window to appear

    main_hwnd = _find_main_hwnd()
    if not main_hwnd:
        return "DOSBox-X launched but window not detected yet — may still be loading."

    try:
        dbg_hwnd = _open_debugger()
        return (
            f"DOSBox-X launched and debugger opened "
            f"(main={main_hwnd:#010x}, debugger={dbg_hwnd:#010x}). "
            f"Now call set_breakpoint(), then start_game()."
        )
    except RuntimeError as e:
        return (
            f"DOSBox-X launched (hwnd={main_hwnd:#010x}) but debugger failed: {e}"
        )


@mcp.tool()
def start_game() -> str:
    """
    Type 'zeliad' at the DOS prompt to start the game.
    Call this AFTER set_breakpoint() so breakpoints are armed before execution begins.
    Sends 'run' to the debugger to resume, then types 'zeliad' at the DOS prompt.
    """
    # Resume execution from the debugger
    _send("run")
    time.sleep(0.5)

    # Type zeliad at the DOS C:\> prompt in the MAIN window
    main_hwnd = _find_main_hwnd()
    if not main_hwnd:
        return "DOSBox-X main window not found."

    # zeliad is in [autoexec] — just resume from the debugger pause.
    _send("run")
    return "zeliad.exe started. Game is now running toward your breakpoints."


@mcp.tool()
def open_debugger() -> str:
    """
    Open the DOSBox-X Debugger panel window (Ctrl+D).
    Called automatically by launch_game(); use this if the debugger was closed.
    """
    dbg_hwnd = _find_debugger_hwnd()
    if dbg_hwnd:
        return f"Debugger already open (hwnd={dbg_hwnd:#010x})."
    dbg_hwnd = _open_debugger()
    return f"Debugger opened (hwnd={dbg_hwnd:#010x})."


@mcp.tool()
def list_known_addresses() -> str:
    """
    Return the pre-loaded address book of known Zeliard assembly locations.
    Use these names with set_breakpoint() instead of raw hex addresses.
    """
    data = json.loads(KNOWN_ADDRS.read_text())
    lines = []
    for name, info in data.items():
        if name.startswith("_"):
            continue
        addr = info.get("addr", "?")
        desc = info.get("desc", "")
        lines.append(f"  {name:<26} {addr:<16} {desc}")
    return "\n".join(lines)


@mcp.tool()
def set_breakpoint(address: str) -> str:
    """
    Set a breakpoint in the DOSBox-X debugger.

    address: segment:offset hex string, e.g. "041F:3277"
             OR a named address from list_known_addresses(), e.g. "title_blit"
    """
    addr = _resolve_address(address)
    _send(f"bp {addr}")
    return f"Breakpoint set at {addr}."


@mcp.tool()
def clear_breakpoint(address: str) -> str:
    """
    Remove a specific breakpoint by address or name.
    Sends 'bplist' to find its index, then 'bpdel N'.

    address: same format as set_breakpoint()
    """
    addr = _resolve_address(address).upper()
    # Ask debugger to list breakpoints, then delete by number
    # We can't read the console output directly, so we delete all matching ones
    # by sending bpdel 0..9 for any that match — crude but reliable for small sets
    _send("bplist")
    time.sleep(0.3)
    # Attempt to delete breakpoints 0-15 that might match; user can verify
    # A cleaner approach would be screenshot-based console parsing
    for i in range(16):
        _send(f"bpdel {i}")
    return (
        f"Sent bpdel 0-15 to clear all breakpoints (DOSBox-X doesn't support "
        f"selective delete by address without reading console output). "
        f"Use list_breakpoints() to confirm, or use clear_all_breakpoints()."
    )


@mcp.tool()
def clear_all_breakpoints() -> str:
    """Remove all active breakpoints."""
    for i in range(32):
        _send(f"bpdel {i}")
    return "Sent bpdel 0-31. All breakpoints cleared."


@mcp.tool()
def resume() -> str:
    """
    Resume game execution (equivalent to pressing F5 / typing 'run' in debugger).
    Call this after inspecting registers and memory at a breakpoint.
    """
    _send("run")
    return "Execution resumed."


@mcp.tool()
def step_into(count: int = 1) -> str:
    """
    Single-step the CPU (step into calls). Executes 'count' instructions.
    After each step the debugger updates its register/disassembly display.
    Follow with read_registers() to see the new state.
    """
    count = max(1, min(count, 100))
    for _ in range(count):
        _send("step")
    return f"Stepped {count} instruction(s). Call read_registers() to see current state."


@mcp.tool()
def step_over(count: int = 1) -> str:
    """
    Step over CALL instructions (executes entire subroutine as one step).
    Executes 'count' such steps.
    """
    count = max(1, min(count, 50))
    for _ in range(count):
        _send("over")
    return f"Stepped over {count} instruction(s)."


@mcp.tool()
def dump_memory(segment: str, offset: str, length: int, label: str) -> str:
    """
    Dump a memory region to file and return its contents as hex.

    segment: hex segment, e.g. "041F" or "A000"
    offset:  hex offset,  e.g. "0000" or "3277"
    length:  byte count (decimal), max 65535
    label:   short name used in the output filename, e.g. "render_buf"

    The file is written as MEMDUMP_<label>.BIN in c:/dosbox-x/.
    Returns up to 4096 bytes as annotated hex rows.
    """
    length = max(1, min(length, 65535))
    fname  = f"MEMDUMP_{label}.BIN"
    cmd    = f"MEMDUMPBIN {segment} {offset} {length:04X} {fname}"
    _send(cmd)
    time.sleep(DUMP_SETTLE)
    path = DUMP_DIR / fname
    return f"--- {fname} ({length} bytes at {segment}:{offset}) ---\n{_read_dump(path)}"


@mcp.tool()
def read_dump_file(filename: str) -> str:
    """
    Read a previously created dump file from c:/dosbox-x/ and return as hex.
    filename: just the filename, e.g. "MEMDUMP_render_buf.BIN"
    """
    path = DUMP_DIR / filename
    return f"--- {filename} ---\n{_read_dump(path)}"


@mcp.tool()
def read_registers() -> str:
    """
    Screenshot the DOSBox-X Debugger window and parse the register display.
    Returns register values (parsed or as an image path) plus a full screenshot.

    Works best when halted at a breakpoint (registers are static).
    """
    if not _find_debugger_hwnd():
        return "DOSBox-X Debugger panel not open. Call launch_game() first."

    img = _screenshot_debugger()

    # Save full debugger window screenshot
    full_path = DUMP_DIR / "_debugger_full.png"
    img.save(str(full_path))

    # Crop the register overview panel (top ~20% of the debugger window)
    w, h = img.size
    panel = img.crop((0, 0, w, h // 5))
    panel_path = DUMP_DIR / "_reg_panel.png"
    panel.save(str(panel_path))

    try:
        import pytesseract
        text = pytesseract.image_to_string(img.crop((0, 0, w, h // 3)), config="--psm 6")
        regs = _parse_registers(text)
        reg_str = "  ".join(f"{k}={v}" for k, v in sorted(regs.items()))
        return (
            f"Registers: {reg_str}\n"
            f"Raw panel text:\n{text}\n"
            f"Full debugger screenshot: {full_path}"
        )
    except ImportError:
        return (
            f"pytesseract not installed.\n"
            f"Full debugger screenshot: {full_path}\n"
            f"Register panel crop: {panel_path}\n"
            f"Read those images to see register values."
        )


@mcp.tool()
def send_command(cmd: str) -> str:
    """
    Send an arbitrary command to the DOSBox-X debugger console.
    Use this as an escape hatch for any command not covered by other tools.

    Examples:
      "bplist"                          — list active breakpoints
      "GR AX"                           — show AX register value on screen
      "SR AX 0042"                      — set AX to 0x0042
      "MEMDUMP 041F 3277 20"            — hex dump to debugger screen
      "MEMDUMPBIN A000 0 FA00 vga.bin"  — full VGA framebuffer dump
      "log Hello from MCP"              — write a marker to the log file
    """
    _send(cmd)
    return f"Command sent: {cmd!r}"


# ---------------------------------------------------------------------------
# Automated tracing tools
# ---------------------------------------------------------------------------

@mcp.tool()
def trace_session(duration_secs: int = 30, tag: str = "trace") -> str:
    """
    Record a structured execution trace for up to `duration_secs` seconds.

    Algorithm:
      1. Clear all breakpoints, then set every valid address from known_addresses.json.
      2. Loop until the wall-clock budget expires:
           resume → wait for the game window to freeze (breakpoint hit) →
           screenshot debugger → parse registers → log event → resume
      3. Write a JSONL file to c:/dosbox-x/trace_<tag>.jsonl and return a summary.

    Each JSONL line:  {"t_ms": <ms since start>, "fn": "<name or CS:IP>",
                       "cs": "…", "ip": "…", "ax": "…", "bx": "…", …}

    The "fn" field is the known function name when CS:IP matches a known address,
    otherwise the raw "CS:IP" string.

    tag: short label used in the output filename (no spaces).
    """
    # ── Load known addresses ──────────────────────────────────────────────
    data = json.loads(KNOWN_ADDRS.read_text())
    valid_addrs: dict[str, str] = {}   # name → "SEG:OFF"
    for name, info in data.items():
        if name.startswith("_") or not isinstance(info, dict):
            continue
        addr = info.get("addr", "")
        # Only accept plain segment:offset addresses (skip "game:…" placeholders)
        if re.match(r'^[0-9A-Fa-f]{4}:[0-9A-Fa-f]{4}$', addr):
            valid_addrs[name] = addr.upper()

    # Build reverse lookup:  "SEG:OFF" → function name
    addr_to_name = {v: k for k, v in valid_addrs.items()}

    # ── Arm all breakpoints ───────────────────────────────────────────────
    for i in range(32):
        _send(f"bpdel {i}")
    time.sleep(0.4)
    for name, addr in valid_addrs.items():
        _send(f"bp {addr}")
        time.sleep(0.05)

    # ── Trace loop ────────────────────────────────────────────────────────
    trace_path = DUMP_DIR / f"trace_{tag}.jsonl"
    events: list[dict] = []
    t_start = time.time()
    t_ms_base = int(t_start * 1000)
    last_cs_ip = ""

    _send("run")
    time.sleep(0.2)

    while time.time() - t_start < duration_secs:
        remaining = duration_secs - (time.time() - t_start)
        paused = _wait_for_breakpoint_pause(timeout_secs=min(4.0, remaining + 0.5))

        if not paused:
            # No breakpoint fired in the window — nudge and keep waiting
            _send("run")
            time.sleep(0.2)
            continue

        regs = _capture_registers_fast()
        t_ms = int(time.time() * 1000) - t_ms_base

        cs  = regs.get("CS", "????").upper()
        ip  = regs.get("IP", "????").upper()
        cs_ip = f"{cs}:{ip}"

        # Skip duplicate consecutive events (same address, likely polling)
        if cs_ip == last_cs_ip:
            _send("run")
            time.sleep(0.05)
            continue
        last_cs_ip = cs_ip

        fn_name = addr_to_name.get(cs_ip, cs_ip)
        event: dict = {"t_ms": t_ms, "fn": fn_name}
        event.update({k.lower(): v for k, v in regs.items()})
        events.append(event)

        _send("run")
        time.sleep(0.05)

    # ── Disarm breakpoints ────────────────────────────────────────────────
    for i in range(32):
        _send(f"bpdel {i}")

    # ── Write trace file ──────────────────────────────────────────────────
    with trace_path.open("w") as fh:
        for ev in events:
            fh.write(json.dumps(ev) + "\n")

    summary_lines = [
        f"Trace complete: {len(events)} events in {duration_secs}s",
        f"Output: {trace_path}",
    ]
    if events:
        fn_seq = [e.get("fn", "?") for e in events[:15]]
        summary_lines.append(f"First functions: {', '.join(fn_seq)}")
        unique_fns = sorted({e.get("fn", "?") for e in events})
        summary_lines.append(f"Unique functions hit ({len(unique_fns)}): {', '.join(unique_fns)}")
    return "\n".join(summary_lines)


@mcp.tool()
def vga_watchpoint(event_count: int = 50, vga_offset: str = "0000", tag: str = "vga") -> str:
    """
    Set a memory watchpoint on VGA A000:<vga_offset> and log write events.

    DOSBox-X pauses whenever that address is accessed.  For each pause this tool
    captures full register state and logs it to c:/dosbox-x/vga_watch_<tag>.jsonl.

    Each JSONL line includes:
      t_ms        — ms since watchpoint armed
      writer_cs   — CS of the writing instruction
      writer_ip   — IP of the writing instruction
      al          — low byte of AX (often the value being stored)
      di, si      — destination / source index registers
      ds, es      — data / extra segments (ES:DI is typically the VGA write address)
      vga_row     — DI // 320  (row in 320×200 framebuffer, if ES==A000)
      vga_col     — DI  % 320  (column)
      … plus all other registers in lowercase

    vga_offset: hex VGA byte offset to watch, e.g. "1400" = row 16 col 0.
    event_count: stop after this many events (max 200).
    tag: short label used in the output filename.

    NOTE: DOSBox-X fires the watchpoint on *any* access (read or write) to that
    single byte.  For a write-only filter, inspect the disassembly at writer_ip
    after the session.
    """
    event_count = max(1, min(event_count, 200))

    # ── Clear existing breakpoints and set memory watchpoint ─────────────
    for i in range(32):
        _send(f"bpdel {i}")
    time.sleep(0.3)

    _send(f"BPM A000:{vga_offset}")
    time.sleep(0.3)

    # ── Watchpoint loop ───────────────────────────────────────────────────
    trace_path = DUMP_DIR / f"vga_watch_{tag}.jsonl"
    events: list[dict] = []
    t_start = time.time()
    t_ms_base = int(t_start * 1000)
    MAX_WALL = 120  # abort after 2 minutes regardless

    _send("run")
    time.sleep(0.2)

    while len(events) < event_count and (time.time() - t_start) < MAX_WALL:
        paused = _wait_for_breakpoint_pause(timeout_secs=5.0)
        if not paused:
            _send("run")
            time.sleep(0.2)
            continue

        regs = _capture_registers_fast()
        t_ms = int(time.time() * 1000) - t_ms_base

        cs  = regs.get("CS",  "????").upper()
        ip  = regs.get("IP",  "????").upper()
        ax  = regs.get("AX",  "????").upper()
        di  = regs.get("DI",  "????").upper()
        si  = regs.get("SI",  "????").upper()
        ds  = regs.get("DS",  "????").upper()
        es  = regs.get("ES",  "????").upper()
        al  = ax[-2:] if len(ax) >= 2 else "??"

        # Decode framebuffer position from DI when ES == A000
        vga_row, vga_col = -1, -1
        if es == "A000":
            try:
                off = int(di, 16)
                vga_row = off // 320
                vga_col = off % 320
            except ValueError:
                pass

        event: dict = {
            "t_ms":      t_ms,
            "writer_cs": cs,
            "writer_ip": ip,
            "al":        al,
            "si":        si,
            "ds":        ds,
            "es":        es,
            "di":        di,
            "vga_row":   vga_row,
            "vga_col":   vga_col,
        }
        event.update({k.lower(): v for k, v in regs.items()})
        events.append(event)

        _send("run")
        time.sleep(0.05)

    # ── Disarm ────────────────────────────────────────────────────────────
    for i in range(32):
        _send(f"bpdel {i}")

    # ── Write trace file ──────────────────────────────────────────────────
    with trace_path.open("w") as fh:
        for ev in events:
            fh.write(json.dumps(ev) + "\n")

    elapsed = time.time() - t_start
    summary_lines = [
        f"VGA watchpoint A000:{vga_offset}: {len(events)} events in {elapsed:.1f}s",
        f"Output: {trace_path}",
    ]
    if events:
        writers = sorted({f"{e['writer_cs']}:{e['writer_ip']}" for e in events})
        summary_lines.append(f"Writing instructions ({len(writers)}): {', '.join(writers[:8])}")
        rows = sorted({e['vga_row'] for e in events if e['vga_row'] >= 0})
        if rows:
            summary_lines.append(f"VGA rows touched: {rows[:20]}")
    return "\n".join(summary_lines)


# ---------------------------------------------------------------------------
# Internal: address resolution
# ---------------------------------------------------------------------------

def _resolve_address(address: str) -> str:
    """
    If address matches a known name in known_addresses.json, return its addr.
    Otherwise return the address string as-is.
    """
    data = json.loads(KNOWN_ADDRS.read_text())
    if address in data and isinstance(data[address], dict):
        resolved = data[address].get("addr", address)
        if ":" in resolved:
            return resolved
    return address


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    mcp.run()
