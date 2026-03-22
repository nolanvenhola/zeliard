#!/usr/bin/env python3
"""Extract VGA palette data from DOSBox-X video debug overlay screenshots."""

from PIL import Image
import json
import os

DUMPS_DIR = os.path.dirname(os.path.abspath(__file__))

def extract_palette_from_strip(img, strip_x_start=590, strip_x_end=1068, sample_y=250):
    """
    Extract 256 colors from the vertical color strip in DOSBox-X debug view.
    The strip spans from strip_x_start to strip_x_end pixels wide.
    """
    width = strip_x_end - strip_x_start
    colors = []
    for i in range(256):
        # Map color index to x position in the strip
        x = strip_x_start + int(i * width / 256) + int(width / 512)
        pixel = img.getpixel((x, sample_y))
        colors.append(pixel[:3])  # RGB only
    return colors

def find_strip_bounds(img):
    """
    Auto-detect the color strip bounds by looking for the dense multi-color region.
    The strip has max color variance vertically.
    """
    width, height = img.size
    # Sample a row in the middle-upper area
    sample_y = height // 3

    # Find where the strip starts (sharp color change from black)
    row_pixels = [img.getpixel((x, sample_y))[:3] for x in range(width)]

    # Look for the start: first non-black region after center
    start_x = None
    end_x = None

    for x in range(width // 2, width):
        r, g, b = row_pixels[x]
        brightness = r + g + b
        if brightness > 100 and start_x is None:
            start_x = x
        if start_x and brightness < 30:
            end_x = x
            break

    if not end_x:
        end_x = width - 80  # fallback

    return start_x, end_x

def extract_rpal_row(img, row_label_y=None):
    """
    Extract palette from the RPAL6 row at the bottom of the screen.
    The RPAL6 row shows 256 color swatches in a grid.
    """
    # The status bar is at the bottom ~30px
    height = img.size[1]

    # Try to find the colored rows at bottom
    # They appear to be at roughly y=430-480 in a 490px tall image
    pass

def process_palette_image(filename, name):
    img = Image.open(filename).convert('RGB')
    width, height = img.size
    print(f"\n=== {name} ({width}x{height}) ===")

    # Auto-detect strip bounds
    start_x, end_x = find_strip_bounds(img)
    print(f"  Detected strip: x={start_x} to x={end_x} ({end_x-start_x}px wide)")

    # Sample at multiple y positions to get stable readings
    # Use middle of the image (avoid black bars at top/bottom)
    y_samples = [height // 4, height // 3, height // 2]

    all_palettes = []
    for y in y_samples:
        colors = extract_palette_from_strip(img, start_x, end_x, sample_y=y)
        all_palettes.append(colors)

    # Average the samples
    palette = []
    for i in range(256):
        r = sum(all_palettes[j][i][0] for j in range(len(y_samples))) // len(y_samples)
        g = sum(all_palettes[j][i][1] for j in range(len(y_samples))) // len(y_samples)
        b = sum(all_palettes[j][i][2] for j in range(len(y_samples))) // len(y_samples)
        palette.append((r, g, b))

    # Print first 64 entries for inspection
    print("  First 64 palette entries (RGB):")
    for i in range(0, 64, 16):
        row = [f"#{palette[i+j][0]:02X}{palette[i+j][1]:02X}{palette[i+j][2]:02X}"
               for j in range(16)]
        print(f"  [{i:3d}-{i+15:3d}]: {' '.join(row)}")

    return palette

def save_palette_as_act(palette, filename):
    """Save palette as Adobe Color Table (.act) format - 768 bytes, 256 RGB triplets."""
    with open(filename, 'wb') as f:
        for r, g, b in palette:
            f.write(bytes([r, g, b]))
    print(f"  Saved: {filename}")

def save_palette_as_cs(palette, name, filename):
    """Save palette as C# array for MonoGame."""
    lines = [f"// {name} - VGA palette extracted from DOSBox-X debug overlay",
             f"// 256 entries, 8-bit RGB",
             f"public static readonly Color[] {name.replace(' ','_').replace('-','_')} = new Color[]",
             "{"]
    for i, (r, g, b) in enumerate(palette):
        comment = f" // [{i:3d}]"
        lines.append(f"    new Color({r}, {g}, {b}),{comment}")
    lines.append("};")
    with open(filename, 'w') as f:
        f.write('\n'.join(lines))
    print(f"  Saved: {filename}")

def main():
    palettes_info = [
        ("Palette1.png", "Opening_Cinematic"),
        ("Palette2.png", "Title_Screen"),
        ("Palette3.png", "Gameplay"),
    ]

    all_palettes = {}

    for png_file, pal_name in palettes_info:
        filepath = os.path.join(DUMPS_DIR, png_file)
        if not os.path.exists(filepath):
            print(f"Not found: {filepath}")
            continue

        palette = process_palette_image(filepath, pal_name)
        all_palettes[pal_name] = palette

        # Save in multiple formats
        act_file = os.path.join(DUMPS_DIR, f"{pal_name}.act")
        save_palette_as_act(palette, act_file)

        cs_file = os.path.join(DUMPS_DIR, f"{pal_name}.cs.txt")
        save_palette_as_cs(palette, pal_name, cs_file)

    # Save JSON summary
    json_data = {name: [[r,g,b] for r,g,b in pal] for name, pal in all_palettes.items()}
    json_file = os.path.join(DUMPS_DIR, "palettes.json")
    with open(json_file, 'w') as f:
        json.dump(json_data, f, indent=2)
    print(f"\nAll palettes saved to: {json_file}")

    # Compare palettes - find where they differ
    if len(all_palettes) >= 2:
        names = list(all_palettes.keys())
        print(f"\n=== Differences between {names[0]} and {names[1]} ===")
        diff_count = 0
        for i in range(256):
            c1 = all_palettes[names[0]][i]
            c2 = all_palettes[names[1]][i]
            if c1 != c2:
                diff_count += 1
                if diff_count <= 20:
                    print(f"  [{i:3d}]: #{c1[0]:02X}{c1[1]:02X}{c1[2]:02X} -> #{c2[0]:02X}{c2[1]:02X}{c2[2]:02X}")
        print(f"  Total differences: {diff_count}/256")

if __name__ == '__main__':
    main()
