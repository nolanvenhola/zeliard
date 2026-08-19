# Zeliard Cavern Maps

This directory contains 19 cavern and level maps extracted from Zeliard, saved as bitmap (.bmp) files.

## Map Files

### Area 1 (Malicia Region)
- **1-MALICIA.bmp** - Cavern of Malicia (first dungeon)
- **1-PELIGRO.bmp** - Cavern of Peligro (danger)

### Area 2 (Madera Region)
- **2-MADERA.bmp** - Cavern of Madera (wood)
- **2-RIZA.bmp** - Cavern of Riza

### Area 3 (Escarcha Region)
- **3-ESCARCHA.bmp** - Cavern of Escarcha (frost)
- **3-GLACIAL.bmp** - Glacial Cavern

### Area 4 (Corrosion Region)
- **4-CEMENTAR.bmp** - Cavern of Cementar (cement)
- **4-CORROER.bmp** - Cavern of Corroer (corrosion)

### Area 5 (Tesoro Region)
- **5-PLATA.bmp** - Cavern of Plata (silver)
- **5-TESORO.bmp** - Cavern of Tesoro (treasure)

### Area 6 (Caliente Region)
- **6-ARRUGIA.bmp** - Cavern of Arrugia
- **6-CALIENTE.bmp** - Cavern of Caliente (hot)
- **6-CORRER.bmp** - Cavern of Correr (run)
- **6-REACCION.bmp** - Cavern of Reaccion (reaction)

### Area 7 (Absor Region)
- **7-ABSOR.bmp** - Cavern of Absor (absorption)
- **7-MILAGRO.bmp** - Cavern of Milagro (miracle)

### Area 8 (Final Region)
- **8-DESLEAL.bmp** - Cavern of Desleal (disloyal)
- **8-FALTER.bmp** - Cavern of Falter
- **8-FINAL.bmp** - Final Cavern (Archfiend's Abode)

## Additional Info

See **readme.txt** for original extraction notes.

## Map Format

- **Format**: Windows Bitmap (.bmp)
- **Dimensions**: Varies per cavern
- **Colors**: Original VGA palette (256 colors)
- **Orientation**: Top-down tile-based layout

## Viewing Maps

### Windows
Double-click to open in default image viewer (Paint, Photos, etc.)

### Cross-platform
- **GIMP**: Free image editor
- **ImageMagick**: Command-line: `magick display <map-file>.bmp`
- **Web browser**: Drag and drop into browser window

## Usage in the Web Port

These maps can be used for:
- Level layout reference
- Collision map generation
- Tile placement verification
- Minimap rendering

See `../../6_WebPort/engine/game/` for the active gameplay implementation.

## Related Resources

- **Sprite Maps**: `../Sprites/` - Sprite sheets and tile sets
- **Game Data**: `../GameData/` - Level structure and enemy placement
- **Interactive Maps**: Some maps in `../Sprites/SpritersResource/Maps/` (PNG format)
