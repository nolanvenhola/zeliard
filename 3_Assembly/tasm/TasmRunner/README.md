# TASM Runner for DOSBox

A C# console application that automates running TASM (Turbo Assembler) and TLINK in DOSBox with background execution, output capture, and logging.

## Features

- 🚀 **Automated DOSBox configuration** - Generates temporary conf files with proper mounts
- 🔗 **Assembly + Linking** - Assembles with TASM and links with TLINK in one command
- 📝 **Dual output** - Logs to both console and timestamped log files
- 🔧 **Flexible paths** - Configure DOSBox, TASM, and output locations
- ✅ **Exit codes** - Returns 0 on success, 1 on failure (for build scripts)
- 🧹 **Clean execution** - Auto-deletes temporary config files
- 📊 **Verification** - Checks for output files (.obj, .lst, .exe/.com)

## Prerequisites

**None!** The tool is completely self-contained:

1. **DOSBox** - Bundled with the executable
   - DOSBox 0.74-3 and SDL.dll automatically copied to `./dosbox/` during build
   - No system installation required
2. **TASM** - Bundled with the executable
   - TASM tools automatically copied to `./tool/` during build
   - Includes `TASM.EXE`, `TLINK.EXE`, and all other TASM utilities
   - Fully portable - works from any directory

## Building

```bash
cd 3_Assembly/tasm/TasmRunner
dotnet build
```

Or build in Release mode:
```bash
dotnet build -c Release
```

**Note:** The build automatically copies DOSBox and TASM to the output folder:
- `bin/Debug/net8.0/dosbox/` - DOSBox 0.74-3 + SDL.dll (~4 MB)
- `bin/Debug/net8.0/tool/` - TASM utilities (~12 MB)

The executable is completely self-contained and portable. Copy the entire output directory to any Windows machine and it will work without any installation.

## Usage

### Zeliard — Compile to raw .bin (game.bin and all drivers)

Use `--bin --output` to strip the MZ header and place output in `tasm/bin/`:

```bash
# Run from 3_Assembly/tasm/TasmRunner/
dotnet run -- ../working/core/game.asm       --bin --output ../bin
dotnet run -- ../working/core/zeliad.asm           --output ../bin
dotnet run -- ../working/drivers/gmmcga.asm  --bin --output ../bin
dotnet run -- ../working/drivers/gmcga.asm   --bin --output ../bin
dotnet run -- ../working/drivers/gmega.asm   --bin --output ../bin
dotnet run -- ../working/drivers/gmhgc.asm   --bin --output ../bin
dotnet run -- ../working/drivers/gmtga.asm   --bin --output ../bin
dotnet run -- ../working/drivers/stdply.asm  --bin --output ../bin
dotnet run -- ../working/drivers/stick.asm   --bin --output ../bin
```

Final outputs land in `3_Assembly/tasm/bin/`:
- `zeliad.exe` — main loader (EXE with MZ header)
- `game.bin`, `gmmcga.bin`, `gmcga.bin`, `gmega.bin`, `gmhgc.bin`, `gmtga.bin`, `stdply.bin`, `stick.bin` — raw code segments

The `--bin` flag strips the 512-byte MZ header from the TLINK output and writes
the raw code section as `<name>.bin` (the intermediate `.exe` is deleted).

### Zeliard — Compile zeliad.asm (the working command)

Run from `3_Assembly/tasm/TasmRunner/`:

```bash
# Prerequisite: srmacros.inc must be next to the .asm file
cp ../working/srmacros.inc ../working/core/

dotnet run -- ../working/core/zeliad.asm
```

Output: `3_Assembly/tasm/working/core/zeliad.exe` (and `.obj`, `.lst`)

### Basic Usage

```bash
dotnet run --project TasmRunner.csproj -- myfile.asm
```

Or after building:
```bash
./bin/Debug/net8.0/TasmRunner.exe myfile.asm
```

### With Options

```bash
# Specify custom DOSBox path
TasmRunner myfile.asm --dosbox "C:\DOSBox-X\dosbox-x.exe"

# Specify TASM location
TasmRunner myfile.asm --tasm "D:\TOOLS\TASM"

# Custom output directory
TasmRunner myfile.asm --output ./build

# Additional TASM arguments (debug info + listing + multiple passes)
TasmRunner myfile.asm --tasm-args "/zi /l /m"

# Custom TLINK arguments (for .EXE files instead of .COM)
TasmRunner myfile.asm --tlink-args "/x"

# Skip linking step (only assemble to .obj)
TasmRunner myfile.asm --no-link

# Keep the temporary DOSBox config for debugging
TasmRunner myfile.asm --keep-conf

# Combine multiple options
TasmRunner myfile.asm --output ./build --tasm-args "/zi /l /m" --logdir ./logs
```

### Command-Line Options

| Option | Description | Default |
|--------|-------------|---------|
| `<asmfile>` | Path to .asm file (required) | - |
| `--dosbox <path>` | DOSBox executable path | `./dosbox/dosbox.exe` (bundled) |
| `--tasm <path>` | TASM directory | `./tool` (bundled) |
| `--output <path>` | Output directory for .obj/.lst/.exe | Same as .asm file |
| `--logdir <path>` | Log file directory | `./logs` |
| `--tasm-args <args>` | Additional TASM arguments | `/l` (listing only) |
| `--tlink-args <args>` | TLINK arguments | `/c /x` (creates .COM) |
| `--link` | Link after assembly | `true` |
| `--no-link` | Skip linking step | - |
| `--keep-conf` | Don't delete temp DOSBox config | false |
| `--bin` | Strip MZ header; output raw `.bin` instead of `.exe` | false |

### TASM Arguments Reference

Common TASM command-line switches:
- `/zi` - Debug info (symbols)
- `/l` - Generate listing file (.lst)
- `/m` - Multiple passes
- `/mx` - Case-sensitive symbols
- `/t` - Suppress error messages
- `/w2` - Warning level 2

### TLINK Arguments Reference

Common TLINK command-line switches:
- `/c` - Create .COM file (tiny model)
- `/x` - No map file
- `/v` - Include debug information
- `/s` - Detailed segment map
- `/t` - Create .COM file (alternative syntax)
- `/3` - Enable 386 instructions

**Default**: `/c /x` creates a .COM file without a map file.

For .EXE files, use: `--tlink-args "/x"` (omit `/c`)

## Output

### Console Output
```
=== TASM Runner for DOSBox ===

Starting TASM assembly at 2026-02-16 14:30:45
Input file: test.asm
Generated DOSBox config: C:\Temp\dosbox_tasm_a1b2c3d4.conf
Running DOSBox...

Assembling test.asm...
Turbo Assembler  Version 3.1  Copyright (c) 1988, 1992 Borland International
test.asm(1)
test.asm(2)
Assembly successful!

Linking test.obj...
Turbo Link  Version 3.0  Copyright (c) 1987, 1990 Borland International
Linking successful!

DOSBox exited with code: 0
✓ Created: test.obj
✓ Created: test.lst
✓ Created: test.exe
Assembly completed with exit code: 0

Log saved to: ./logs/tasm_20260216_143045.log
```

### Log Files

Logs are saved to `./logs/tasm_YYYYMMDD_HHMMSS.log` with full timestamped output.

## Integration with Build Scripts

### Batch File

```batch
@echo off
TasmRunner.exe myfile.asm --output ./build
if errorlevel 1 (
    echo Assembly failed!
    exit /b 1
)
echo Assembly succeeded!
```

### PowerShell

```powershell
$result = & TasmRunner.exe myfile.asm --output ./build
if ($LASTEXITCODE -ne 0) {
    Write-Error "Assembly failed!"
    exit 1
}
Write-Host "Assembly succeeded!"
```

### Bash (Git Bash on Windows)

```bash
#!/bin/bash
./TasmRunner.exe myfile.asm --output ./build
if [ $? -ne 0 ]; then
    echo "Assembly failed!"
    exit 1
fi
echo "Assembly succeeded!"
```

## How It Works

1. **Build** - TASM tools are copied to `./tool/` in the output directory (self-contained)
2. **Parses arguments** - Validates ASM file and options
3. **Creates temp DOSBox config** - Generates `[autoexec]` section with:
   - Mount for TASM directory (`T:`)
   - Mount for working directory (`W:`)
   - Mount for output directory (`O:`) if different
   - PATH setup to include TASM
   - TASM command with arguments
4. **Runs DOSBox** - Executes with `-noconsole -exit` for background operation
5. **Captures output** - Streams stdout/stderr to console and log file
6. **Verifies results** - Checks for .obj file creation
7. **Cleanup** - Deletes temp config (unless `--keep-conf`)

## Troubleshooting

### "DOSBox not found"
- DOSBox is bundled with the executable in `./dosbox/` directory
- Verify dosbox.exe exists: `bin/Debug/net8.0/dosbox/dosbox.exe`
- If missing, rebuild the project to copy DOSBox
- Or specify custom path with `--dosbox`

### "TASM not found"
- TASM is bundled with the executable in `./tool/` directory
- Verify TASM.EXE exists: `bin/Debug/net8.0/tool/TASM.EXE`
- If missing, rebuild the project to copy TASM tools
- Or specify custom path with `--tasm`

### "Assembly failed but no errors shown"
- Use `--keep-conf` to inspect generated DOSBox config
- Run DOSBox manually with the config to see detailed errors
- Check the log file for complete output

### ".obj file not created" / "Can't locate file: srmacros.inc"
- Every Zeliard `.asm` file requires `srmacros.inc` in the same directory
- The master copy lives at `3_Assembly/tasm/working/srmacros.inc`
- Copy it next to the `.asm` file before assembling:
  ```bash
  cp 3_Assembly/tasm/working/srmacros.inc 3_Assembly/tasm/working/core/
  ```
- Or specify an include path with `--tasm-args "/l /Ipath"` where `path` is the DOS drive+dir containing `srmacros.inc`
- Note: TASM writes fatal errors to **stderr**, not stdout, so they won't appear in `tasm_output_<name>.txt` — use `--keep-conf` and run DOSBox manually to see them

### ".obj file not created" (other causes)
- Check TASM syntax errors in the log
- Verify TASM arguments are correct
- Ensure output directory exists and is writable

## License

Part of the Zeliard reverse engineering project.
