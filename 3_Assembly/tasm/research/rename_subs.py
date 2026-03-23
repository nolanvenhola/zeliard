#!/usr/bin/env python3
"""Bulk rename sub_N functions using file context + code pattern analysis"""

import os
import re

def get_sub_body(content, sub_name):
    """Extract lines between sub_N proc and sub_N endp"""
    pattern = rf'{re.escape(sub_name)}\s+proc\b'
    end_pattern = rf'{re.escape(sub_name)}\s+endp\b'

    lines = content.split('\n')
    in_sub = False
    body = []

    for line in lines:
        if re.search(pattern, line):
            in_sub = True
            continue
        if in_sub and re.search(end_pattern, line):
            break
        if in_sub:
            body.append(line.strip().lower())
            if len(body) >= 40:
                break

    return ' '.join(body)

def classify_sub(body, file_prefix, sub_num):
    """Classify a subroutine based on its code patterns and file context"""

    # VGA/Graphics operations
    if '0a000h' in body or 'a000h' in body:
        if 'stosb' in body or 'stosw' in body:
            return f'{file_prefix}_fill_vga'
        if 'movsb' in body or 'movsw' in body:
            return f'{file_prefix}_copy_vga'
        return f'{file_prefix}_vga_op'

    # Buffer operations
    if 'rep\tstos' in body or 'rep stosb' in body or 'rep stosw' in body:
        if 'xor\tal,al' in body or 'xor ax,ax' in body:
            return f'{file_prefix}_clear_buf'
        return f'{file_prefix}_fill_buf'

    if 'rep\tmovs' in body or 'rep movsb' in body or 'rep movsw' in body:
        return f'{file_prefix}_copy_buf'

    # DOS file I/O
    if 'int\t21h' in body or 'int 21h' in body:
        if '3dh' in body or '3d00h' in body:
            return f'{file_prefix}_open_file'
        if 'ah,3fh' in body or 'ah,3f' in body:
            return f'{file_prefix}_read_file'
        if 'ah,3eh' in body or 'ah,3e' in body:
            return f'{file_prefix}_close_file'
        if 'ah,40h' in body or 'ah,40' in body:
            return f'{file_prefix}_write_file'
        if 'ah,9' in body:
            return f'{file_prefix}_print_str'
        return f'{file_prefix}_dos_call'

    # Video BIOS
    if 'int\t10h' in body or 'int 10h' in body:
        if '1010h' in body:
            return f'{file_prefix}_set_palette'
        if '1012h' in body:
            return f'{file_prefix}_get_palette'
        return f'{file_prefix}_video_call'

    # Chunk loading
    if 'call\tword ptr cs:[10ch]' in body or '[10ch]' in body or '[0x10c]' in body:
        return f'{file_prefix}_load_chunk'

    # Graphics driver calls
    if '[3008h]' in body or '[3000h]' in body or '[300' in body:
        return f'{file_prefix}_call_driver'

    # Math operations
    if ('mul\t' in body or 'mul ' in body) and ('div\t' in body or 'div ' in body):
        return f'{file_prefix}_calc'
    if 'mul\t' in body or 'mul ' in body:
        return f'{file_prefix}_multiply'

    # Bit manipulation
    if ('shl\t' in body or 'shr\t' in body) and ('and\t' in body):
        return f'{file_prefix}_extract_bits'

    # Loop patterns
    if 'loop\t' in body or 'loop ' in body:
        if 'cmp\t' in body:
            return f'{file_prefix}_scan_loop'
        return f'{file_prefix}_process_loop'

    # Comparison/branch heavy = decision logic
    cmp_count = body.count('cmp\t') + body.count('cmp ')
    if cmp_count >= 4:
        return f'{file_prefix}_check_state'

    # Very short functions (likely getters/setters)
    if len(body) < 100:
        if 'mov\t' in body and 'retn' in body:
            return f'{file_prefix}_get_value'

    # Default: use file prefix + number
    return f'{file_prefix}_func_{sub_num}'

def get_file_prefix(filename):
    """Generate a short prefix from the filename"""
    name = os.path.splitext(filename)[0]

    prefixes = {
        'opening_scene': 'scene',
        'image_controller': 'imgctl',
        'equipment': 'equip',
        'image_decode': 'imgdec',
        'player_stats': 'stats',
        'palette_graphics': 'pal',
        'player_advanced': 'player',
        'vga_decompressor': 'vgadec',
        'image_decoder_a': 'deca',
        'image_decoder_b': 'decb',
        'large_image_renderer': 'limg',
        'small_image_renderer': 'simg',
        'utilities_a': 'util',
        'utilities_b': 'util2',
        'main_game_loop': 'game',
        'combat_ui': 'combat',
        'sprite_renderer': 'sprite',
        'physics_subsystems': 'physsub',
        'physics_engine': 'physics',
        'animation_system': 'anim',
        'enemy_ai': 'ai',
        'enemy_slime': 'slime',
        'enemy_bat': 'bat',
        'enemy_spider': 'spider',
        'enemy_skeleton': 'skel',
        'enemy_ghost': 'ghost',
        'enemy_goblin': 'goblin',
        'enemy_orc': 'orc',
        'enemy_wizard': 'wizard',
        'boss_behaviors': 'boss',
        'enemy_special': 'special',
        'utility_a': 'util',
        'utility_b': 'util2',
        'data_tables': 'data',
        'level_loader': 'lvload',
        'level_renderer': 'lvrender',
        'tile_collision': 'tilecol',
        'town_npc': 'town',
        'enemy_behavior': 'enbehav',
        'npc_interaction': 'npc',
        'trigger_events': 'trigger',
        'enemy_manager': 'enmgr',
        'utility_small': 'util',
        'boss_ai': 'bossai',
        'boss_patterns': 'bosspat',
        'utility_tiny': 'util2',
    }

    return prefixes.get(name, name[:6])

def update_header(content, filename):
    """Replace old Sourcer header with clean one"""
    basename = os.path.splitext(filename)[0].upper()

    # Try to replace the old Sourcer-style header
    old_patterns = [
        r';[^\n]*\n;[^\n]*\n;[^\n]*ZR[0-9]_[0-9]+[^\n]*\n;[^\n]*\n;[^\n]*Created[^\n]*\n;[^\n]*Code type[^\n]*\n;[^\n]*Passes[^\n]*\n;[^\n]*\n;[^\n]*\n',
        r';=+\n;\n;  [^\n]*\n;\n;=+\n',
    ]

    new_header = f""";==========================================================================
;
;  {basename} - Code Module
;
;==========================================================================
"""

    for pat in old_patterns:
        if re.search(pat, content):
            content = re.sub(pat, new_header, content, count=1)
            break

    return content

def process_file(filepath, filename):
    """Process one ASM file: find and rename all sub_N"""
    with open(filepath, 'r', encoding='latin-1') as f:
        content = f.read()

    # Find all unique sub_N
    subs = sorted(set(re.findall(r'\bsub_(\d+)\b', content)), key=lambda x: int(x))

    if not subs:
        return 0

    prefix = get_file_prefix(filename)
    used_names = set()
    renames = {}

    for sub_num in subs:
        sub_name = f"sub_{sub_num}"
        body = get_sub_body(content, sub_name)

        new_name = classify_sub(body, prefix, sub_num)

        # Ensure uniqueness
        base = new_name
        counter = 2
        while new_name in used_names:
            new_name = f"{base}_{counter}"
            counter += 1
        used_names.add(new_name)
        renames[sub_name] = new_name

    # Apply renames (longest first to avoid partial matches)
    for old, new in sorted(renames.items(), key=lambda x: -len(x[0])):
        content = re.replace_all(old, new, content) if hasattr(re, 'replace_all') else content.replace(old, new)

    # Update header
    content = update_header(content, filename)

    with open(filepath, 'w', encoding='latin-1') as f:
        f.write(content)

    return len(renames)

def main():
    base = r"C:\Projects\Zeliard\3_Assembly\tasm\working"
    total = 0

    for subdir in ['zelres1/code', 'zelres2/code', 'zelres3/code']:
        dirpath = os.path.join(base, subdir)
        if not os.path.exists(dirpath):
            continue

        for filename in sorted(os.listdir(dirpath)):
            if not filename.endswith('.asm'):
                continue

            filepath = os.path.join(dirpath, filename)
            count = process_file(filepath, filename)

            if count > 0:
                print(f"  {subdir}/{filename}: {count} renames")
                total += count

    print(f"\nTotal: {total} functions renamed")

if __name__ == "__main__":
    main()
