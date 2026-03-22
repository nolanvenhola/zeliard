# DOSBox-X MCP Server — Zeliard Reverse Engineering

FastMCP server that gives Claude Code control over the DOSBox-X debugger for live Zeliard analysis.

## Setup

```
pip install -r requirements.txt
```

**Tesseract OCR** is required for register reading (`read_registers`, `trace_session`, `vga_watchpoint`):

```
winget install UB-Mannheim.TesseractOCR   # installs to C:\Program Files\Tesseract-OCR\
pip install pytesseract
```

The server hard-codes the Tesseract path to `C:\Program Files\Tesseract-OCR\tesseract.exe`.
Without it, register values in traces will appear as `????`.

The server is registered in `~/.claude.json` under `mcpServers.dosbox` and starts automatically with Claude Code.
After editing the server file, reload via `/mcp` → reconnect `dosbox` in the VS Code chat panel.

Output files (memory dumps, trace logs) are written to `c:/dosbox-x/`.

---

## Typical Workflow

```
launch_game()
  → set_breakpoint("4plane_interleaver")
  → start_game()
  → [user plays until breakpoint fires]
  → read_registers()
  → dump_memory("141F", "4000", 0x1000, "plane_src")
  → resume()
```

For automated flow recording:

```
launch_game()
  → start_game()
  → trace_session(duration_secs=20, tag="title_to_game")
  → [read c:/dosbox-x/trace_title_to_game.jsonl]
```

---

## Tools Reference

### Setup & Control

| Tool | Parameters | What it does |
|------|-----------|--------------|
| `launch_game()` | — | Start DOSBox-X + open debugger panel. Call this first. |
| `start_game()` | — | Type `zeliad` at the DOS prompt and press Enter. Call after setting breakpoints. |
| `open_debugger()` | — | Re-open the debugger panel if it was closed (also called by `launch_game`). |
| `resume()` | — | Resume execution (F5 / `run`). |

### Breakpoints

| Tool | Parameters | What it does |
|------|-----------|--------------|
| `list_known_addresses()` | — | Print all named breakpoints from `known_addresses.json`. |
| `set_breakpoint(address)` | `address`: name or `SEG:OFF` | Arm a code breakpoint. Accepts names like `"title_blit"` or raw addresses like `"0AC6:3277"`. |
| `clear_breakpoint(address)` | `address`: name or `SEG:OFF` | Remove a breakpoint (sends `bpdel 0-15`; clears all — use when only one is set). |
| `clear_all_breakpoints()` | — | Send `bpdel 0-31`. Clears everything. |

### Stepping

| Tool | Parameters | What it does |
|------|-----------|--------------|
| `step_into(count)` | `count`: 1–100 | Single-step N instructions (steps into CALLs). |
| `step_over(count)` | `count`: 1–50 | Step over N CALL instructions (executes entire subroutines). |

### Inspection

| Tool | Parameters | What it does |
|------|-----------|--------------|
| `read_registers()` | — | Screenshot debugger panel, OCR register values. Returns register dict + screenshot path. Works best when paused. |
| `dump_memory(segment, offset, length, label)` | all strings/int | `MEMDUMPBIN SEG OFF LEN MEMDUMP_<label>.BIN` → reads back as annotated hex. Max 65535 bytes. |
| `read_dump_file(filename)` | `filename`: e.g. `"MEMDUMP_vga.BIN"` | Read a previously created dump from `c:/dosbox-x/`. |
| `send_command(cmd)` | `cmd`: any string | Send a raw command to the DOSBox-X debugger console. Escape hatch for anything not covered above. |

### Automated Tracing *(new)*

| Tool | Parameters | What it does |
|------|-----------|--------------|
| `trace_session(duration_secs, tag)` | `duration_secs`: int (default 30)<br>`tag`: filename label (default `"trace"`) | Arms all known-address breakpoints. Loops for the given duration: resume → detect freeze → capture registers → log → resume. Output: `c:/dosbox-x/trace_<tag>.jsonl`. |
| `vga_watchpoint(event_count, vga_offset, tag)` | `event_count`: 1–200 (default 50)<br>`vga_offset`: hex offset (default `"0000"`)<br>`tag`: filename label (default `"vga"`) | Sets `BPM A000:<vga_offset>`. Captures register state on each access until `event_count` events. Decodes `ES:DI` into `vga_row`/`vga_col`. Output: `c:/dosbox-x/vga_watch_<tag>.jsonl`. |

---

## Known Addresses (`known_addresses.json`)

Pre-configured breakpoints for key Zeliard functions. All in DOSBox-X real-mode segment `0AC6` (same code as Spice86 segment `041F`, different DOS load address).

| Name | Address | Description |
|------|---------|-------------|
| `title_blit` | `0AC6:3277` | Blit nibble-packed render buffer → VGA A000 (mask-table based, 8 passes) |
| `title_blit_alt` | `0AC6:3239` | Alternate entry to the same blit function |
| `4plane_interleaver` | `0AC6:30FC` | Convert 2-plane 1bpp source → 4-logical-plane nibble-packed buffer |
| `4plane_interleaver_2` | `0AC6:4469` | Secondary interleaver entry point |
| `grp_decode_entry` | `0AC6:6036` | GRP decode pipeline: calls RLE decoder → interleaver → blit |
| `rle_6de1` | `0AC6:6DE1` | Image RLE decoder (NOT fill_buffer) — 1-byte and 2-byte modes |
| `fill_buffer` | `0AC6:0DAD` | Chunk decompressor — opcodes 0/3/6/7 at dispatch table 0DBC |
| `fill_buffer_dispatch` | `0AC6:0DBC` | fill_buffer opcode dispatch table |
| `chunk_loader` | `0AC6:010C` | SAR loader: AL=2 (decompress), AL=3 (raw); SI=ref, DI=dest |
| `palette_set` | `0AC6:0748` | VGA palette setup — 3-plane×2-bit, 64 colors |
| `opening_slideshow` | `0AC6:0155` | Opening cinematic loop over image list at 0x311E |
| `title_screen_entry` | `0AC6:0410` | Title screen entry point |
| `image_decode` | `0AC6:6D62` | Opening scene: ctrl bytes + XOR differential 2-bit decode |
| `tile_renderer` | `0AC6:364F` | 48×34 / 32×18 character-cell tile renderer |

---

## Trace Output Format

### `trace_<tag>.jsonl`

One JSON object per breakpoint event:

```json
{"t_ms": 1234, "fn": "4plane_interleaver", "cs": "0AC6", "ip": "30FC", "ax": "0041", "bx": "0000", "cx": "0070", "dx": "0000", "si": "4000", "di": "0000", "ds": "141F", "es": "341F", "ss": "0AC6", "sp": "FE3A"}
```

- `t_ms` — milliseconds since `trace_session()` started
- `fn` — function name from `known_addresses.json`, or raw `"CS:IP"` if unrecognised
- All other keys are register names in lowercase

### `vga_watch_<tag>.jsonl`

One JSON object per watchpoint hit:

```json
{"t_ms": 456, "writer_cs": "0AC6", "writer_ip": "3277", "al": "AA", "si": "0000", "ds": "341F", "es": "A000", "di": "12DE", "vga_row": 15, "vga_col": 30, "ax": "00AA", ...}
```

- `writer_cs:writer_ip` — address of the instruction that triggered the watchpoint
- `al` — low byte of AX (typically the value being written)
- `vga_row`, `vga_col` — decoded from DI when ES == A000 (320×200 framebuffer)
- `ds:si` — source address (points into sprite/render buffer when rendering)

---

## Useful `send_command()` Examples

```python
send_command("bplist")                          # list active breakpoints
send_command("SR AX 0042")                      # set AX = 0x0042
send_command("MEMDUMPBIN A000 0 FA00 vga.bin")  # full VGA framebuffer (320×200)
send_command("MEMDUMPBIN 141F 4000 2000 src.bin") # dump render source buffer
send_command("BPM A000:6853")                   # watchpoint at row 83 col 51 (player pos)
send_command("BPINT 10 0")                      # break on INT 10h (video BIOS)
```
