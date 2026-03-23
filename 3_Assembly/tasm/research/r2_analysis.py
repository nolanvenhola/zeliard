"""
r2_analysis.py - Run radare2 analysis on Zeliard chunks and cross-reference
with our named ASM functions.
"""
import subprocess
import re
import os


def r2_analyze(binary_path, bits=16):
    """Run r2 analysis and return function list as {offset: size}"""
    result = subprocess.run(
        ['radare2', '-b', str(bits), '-q', '-c', 'aaa; afl', binary_path],
        capture_output=True, text=True, timeout=30
    )
    functions = {}
    for line in result.stdout.splitlines():
        m = re.search(r'(0x[0-9a-f]+)\s+\d+\s+(\d+)', line)
        if m:
            offset = int(m.group(1), 16)
            size = int(m.group(2))
            functions[offset] = size
    return functions


def extract_asm_functions(asm_path):
    """Extract function name -> offset from an ASM file using proc declarations"""
    funcs = {}
    current_offset = 0
    with open(asm_path, encoding='latin-1') as f:
        for line in f:
            # Count bytes from org 0
            # Look for proc declarations preceded by labels
            m = re.match(r'^(\w+)\s+proc\s+', line)
            if m:
                funcs[m.group(1)] = current_offset
    return funcs


def main():
    base = r"C:\Projects\Zeliard"

    # Analyze zeliad.exe
    print("=== ZELIAD.EXE Analysis ===")
    fns = r2_analyze(os.path.join(base, r"1_OriginalGame\zeliad.exe"))
    print(f"r2 found {len(fns)} functions:")

    # Map to our named functions from zeliad.asm
    named = {
        0x000:  'entry / zeliad',
        0x2a2:  'flush_keyboard',
        0x2be:  'read_config_line',
        0x2f6:  'parse_graphics_mode',
        0x341:  'parse_music_driver',
        0x385:  'find_colon_in_line',
        0x390:  'cfg_error',
        0x3cc:  'parse_music_driver',
        0x443:  'parse_joystick_name',
        0x47c:  'parse_joystick_enable',
        0x493:  'load_driver_file',
        0x4da:  'display_file_error',
        0x4ef:  'load_driver_file',
        0x520:  'read_config_line',
        0x57a:  'ctrl_c_handler',
        0x57e:  'set_video_mode',
        0x5f9:  'parse_command_line',
    }

    for offset, size in sorted(fns.items()):
        name = named.get(offset, '???')
        print(f"  0x{offset:04X} ({size:4d} bytes)  {name}")

    print()

    # Analyze all code chunks
    print("=== CODE CHUNK Summary ===")
    chunk_files = [
        (r"2_SAR\ExtractedChunks\zelres2_extracted\chunk_00.bin", "main_game_loop (zelres2)"),
        (r"2_SAR\ExtractedChunks\zelres1_extracted\chunk_00.bin", "opening_scene (zelres1)"),
        (r"2_SAR\ExtractedChunks\zelres2_extracted\chunk_04.bin", "physics_engine"),
        (r"2_SAR\ExtractedChunks\zelres2_extracted\chunk_06.bin", "enemy_ai"),
    ]

    for rel_path, desc in chunk_files:
        full_path = os.path.join(base, rel_path)
        if os.path.exists(full_path):
            fns = r2_analyze(full_path)
            size_kb = os.path.getsize(full_path) / 1024
            print(f"  {desc}: {len(fns)} functions detected ({size_kb:.1f} KB)")
        else:
            print(f"  {desc}: file not found")


if __name__ == '__main__':
    main()
