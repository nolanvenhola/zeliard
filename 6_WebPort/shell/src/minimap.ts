export type CavernMap = {
    selector: number;
    width: number;
    height: number;
    tiles: Uint8Array;
    doors: Array<{
        x: number;
        y: number;
        gem: number;
        hasGem: boolean;
        locked: boolean;
        town: boolean;
        destinationMap: number;
        label?: string;
    }>;
    platforms: Array<{
        x: number;
        y: number;
        kind: 'rising' | 'falling' | 'moving';
    }>;
};

export type CavernObject = {
    x: number;
    y: number;
    kind: 'enemy' | 'item' | 'chest' | 'key';
};

export type MinimapPosition = {
    playerX: number;
    playerY: number;
    scrollX: number;
    scrollY: number;
};

export type CavernPin = {
    x: number;
    y: number;
    number: number;
};

export type MinimapView = {
    centerX?: number;
    centerY?: number;
    pins?: CavernPin[];
};

type ByteReader = (offset: number) => number;

const MAP_BASE = 0xC000;
const MAP_HEIGHT = 64;
const EMPTY_COLOR = '#030606';
const GROUND_COLOR = '#285b62';
const AIR_CURRENT_COLOR = 'rgba(66, 196, 238, .72)';

const TOWN_NAMES: Record<number, string> = {
    1: 'Muralla',
    2: 'Satono',
    3: 'Bosque',
    4: 'Helada',
    5: 'Tumba',
    6: 'Dorado',
    7: 'Llama',
    8: 'Pureza',
    9: 'Esco',
};

const BOSS_NAMES_BY_LEVEL: Record<number, string> = {
    2: 'Cangrejo',
    3: 'Pulpo',
    4: 'Pollo',
    5: 'Agar',
    6: 'Vista',
    7: 'Tarso',
    8: 'Dragon',
};

function word(read: ByteReader, offset: number): number {
    return read(offset) | (read(offset + 1) << 8);
}

/** Decode the exact column-major 2-bit RLE stream consumed by 200FIGHT. */
export function decodeCavernMap(read: ByteReader,
                                selector: number): CavernMap | null {
    const width = word(read, MAP_BASE + 2);
    if (width < 1 || width > 4096) return null;

    const tiles = new Uint8Array(width * MAP_HEIGHT);
    let source = MAP_BASE + 0x1B;
    for (let column = 0; column < width; ++column) {
        let row = 0;
        let decoded = 0;
        let guard = 0;
        while (decoded < MAP_HEIGHT && source <= 0xFFFF && guard++ < 0x1000) {
            const value = read(source);
            if (value < 0) return null;
            const operation = value >> 6;
            let count: number;
            let tile: number;
            if (operation === 0) {
                count = value + 1;
                if (++source > 0xFFFF) return null;
                tile = read(source);
            } else if (operation === 1) {
                count = ((value >> 4) & 3) + 2;
                tile = (value & 0x0F) + 1;
            } else if (operation === 2) {
                count = value & 0x3F;
                tile = 0;
                if (count === 0) {
                    ++source;
                    continue;
                }
            } else {
                count = 1;
                tile = value & 0x3F;
            }
            ++source;
            decoded += count;
            while (count-- > 0 && row < MAP_HEIGHT)
                tiles[row++ * width + column] = tile;
        }
        if (row !== MAP_HEIGHT) return null;
    }

    const doors: CavernMap['doors'] = [];
    const level = read(MAP_BASE + 0x12);
    const bossDoorX = word(read, MAP_BASE + 0x13);
    const bossDoorY = read(MAP_BASE + 0x15);
    let door = word(read, MAP_BASE + 0x0A);
    for (let count = 0; door >= MAP_BASE && door <= 0xFFF3 && count < 256;
         ++count, door += 12) {
        const x = word(read, door);
        if (x === 0xFFFF) break;
        const y = read(door + 2);
        const flags = read(door + 3);
        const destinationMap = read(door + 4);
        const destinationY = word(read, door + 7);
        const town = destinationY === 0x00FF;
        /* MDT+13h/+15h is the authored door-to-boss coordinate.  The Y
         * points one row below the door record, matching its four-row art. */
        const boss = x === bossDoorX && ((y + 1) & 0x3F) === bossDoorY;
        const label = town
            ? TOWN_NAMES[destinationMap & 0x7F]
            : boss ? BOSS_NAMES_BY_LEVEL[level] : undefined;
        /* Gem IDs 1..4 are the red/blue/green/yellow keyed doors.  Zero is
         * the no-gem form used by ordinary special transitions; town and
         * boss doors are also explicitly gemless regardless of flag bits. */
        const hasGem = !town && !boss && (flags & 7) !== 0;
        doors.push({
            x,
            y,
            gem: flags & 7,
            hasGem,
            locked: (flags & 0x80) === 0,
            town,
            destinationMap,
            label,
        });
    }

    const platforms: CavernMap['platforms'] = [];
    const readPlatforms = (pointerOffset: number, stride: number,
                           kind: CavernMap['platforms'][number]['kind']) => {
        let entry = word(read, MAP_BASE + pointerOffset);
        for (let count = 0;
             entry >= MAP_BASE && entry <= 0xFFFE - stride && count < 512;
             ++count, entry += stride) {
            let x = word(read, entry);
            if (x === 0xFFFF) break;
            if (kind === 'moving') x &= 0x3FFF;
            const y = read(entry + 2) & 0x3F;
            if (x < width)
                platforms.push({ x, y, kind });
        }
    };
    readPlatforms(0x04, 3, 'rising');
    readPlatforms(0x06, 3, 'falling');
    readPlatforms(0x08, 7, 'moving');

    return {
        selector, width, height: MAP_HEIGHT, tiles, doors, platforms,
    };
}

export function readCavernObjects(read: ByteReader): CavernObject[] {
    const objects: CavernObject[] = [];
    let object = word(read, MAP_BASE + 0x10);
    for (let count = 0; object >= MAP_BASE && object <= 0xFFEF && count < 512;
         ++count, object += 16) {
        const x = word(read, object);
        if (x === 0xFFFF) break;
        const y = read(object + 2);
        const type = read(object + 4);
        const contents = read(object + 6);
        const spawnType = read(object + 14);
        if (x < 0xFF00 && y < MAP_HEIGHT) {
            const kind: CavernObject['kind'] = spawnType !== 0 ? 'enemy' :
                type === 0x73 && contents === 4 ? 'key' :
                type === 0x73 ? 'chest' : 'item';
            objects.push({ x, y, kind });
        }
    }
    return objects;
}

function isAirCurrentTile(map: CavernMap, tile: number): boolean {
    /* Falter's broad current field is authored with the three-pattern
     * 11h/12h/13h cycle.  Those cells surround and overlap the real platform
     * silhouettes, so filling them as terrain erases the visible gaps. */
    return map.selector === 0x1A && tile >= 0x11 && tile <= 0x13;
}

function fallbackMapColor(map: CavernMap, tile: number): string {
    return tile === 0 || isAirCurrentTile(map, tile)
        ? EMPTY_COLOR : GROUND_COLOR;
}

const GEM_COLORS = [
    '#f800f8', // purple
    '#f80000', // red
    '#007cf8', // blue
    '#00f800', // green
    '#f8f800', // yellow
];

const GEM_NAMES = ['P', 'R', 'B', 'G', 'Y'];

export function drawCavernMinimap(canvas: HTMLCanvasElement,
                                  map: CavernMap,
                                  position: MinimapPosition,
                                  objects: CavernObject[],
                                  expanded: boolean,
                                  view: MinimapView = {}): void {
    const context = canvas.getContext('2d');
    if (!context) return;
    const viewWidth = Math.min(map.width, expanded ? 128 : 64);
    const viewHeight = Math.min(map.height, expanded ? 56 : 32);
    const centerX = expanded && view.centerX !== undefined
        ? view.centerX : position.playerX;
    const centerY = expanded && view.centerY !== undefined
        ? view.centerY : position.playerY;
    const viewLeft = Math.floor(centerX - viewWidth / 2);
    const viewTop = Math.floor(centerY - viewHeight / 2);
    const scale = Math.min(canvas.width / viewWidth,
        canvas.height / viewHeight);
    const drawnWidth = viewWidth * scale;
    const drawnHeight = viewHeight * scale;
    const left = (canvas.width - drawnWidth) / 2;
    const top = (canvas.height - drawnHeight) / 2;
    const wrap = (value: number, size: number) =>
        ((value % size) + size) % size;
    const viewX = (worldX: number) => wrap(worldX - viewLeft, map.width);
    const viewY = (worldY: number) => wrap(worldY - viewTop, map.height);

    context.fillStyle = EMPTY_COLOR;
    context.fillRect(0, 0, canvas.width, canvas.height);
    for (let row = 0; row < viewHeight; ++row) {
        const mapRow = wrap(viewTop + row, map.height);
        for (let column = 0; column < viewWidth; ++column) {
            const mapColumn = wrap(viewLeft + column, map.width);
            const tile = map.tiles[mapRow * map.width + mapColumn];
            /* All solid MDT tiles share one restrained color.  Tile-specific
             * render sampling made structural shapes difficult to read. */
            context.fillStyle = fallbackMapColor(map, tile);
            context.fillRect(left + column * scale, top + row * scale,
                Math.ceil(scale), Math.ceil(scale));
        }
    }

    /* Show the current without turning its whole MDT field into terrain. */
    context.fillStyle = AIR_CURRENT_COLOR;
    for (let row = 0; row < viewHeight; ++row) {
        const mapRow = wrap(viewTop + row, map.height);
        for (let column = 0; column < viewWidth; ++column) {
            const mapColumn = wrap(viewLeft + column, map.width);
            const tile = map.tiles[mapRow * map.width + mapColumn];
            if (!isAirCurrentTile(map, tile) ||
                ((mapColumn + mapRow) & 3) !== 0) continue;
            const x = left + (column + .5) * scale;
            const y = top + (row + .5) * scale;
            context.fillRect(x - Math.max(1, scale * .32), y,
                Math.max(1.5, scale * .64), Math.max(1, scale * .16));
        }
    }

    for (const platform of map.platforms) {
        const x = viewX(platform.x);
        const y = viewY(platform.y);
        if (x >= viewWidth || y >= viewHeight) continue;
        context.fillStyle = platform.kind === 'falling' ? '#f8d748' :
            platform.kind === 'moving' ? '#38c8c8' : '#42d35b';
        context.fillRect(left + x * scale, top + y * scale,
            Math.max(3, scale * 3), Math.max(1.5, scale * .65));
    }

    for (const door of map.doors) {
        const x = viewX(door.x);
        const y = viewY(door.y);
        if (x >= viewWidth || y >= viewHeight) continue;
        const centerX = left + x * scale;
        /* 200FIGHT renders four rows beginning at the authored door Y.
         * Treating that coordinate as the bottom made markers float. */
        const baseY = top + (y + 4) * scale;
        const doorWidth = Math.max(7, scale * 2.4);
        const doorHeight = Math.max(9, scale * 4);
        const gemRadius = Math.max(2.5, scale * .72);

        /* A high-contrast arch makes doors readable before any other marker;
         * the gem remains the canonical MASM low-three-bit identity. */
        context.fillStyle = 'rgba(4,4,8,.92)';
        context.strokeStyle = door.town ? '#f8f8f8' : '#b878b8';
        context.lineWidth = Math.max(1.25, scale * .28);
        context.beginPath();
        context.roundRect(centerX - doorWidth / 2,
            baseY - doorHeight, doorWidth, doorHeight,
            [doorWidth / 2, doorWidth / 2, 0, 0]);
        context.fill();
        context.stroke();

        if (door.hasGem) {
            const gemColor = GEM_COLORS[door.gem] ?? '#f8f8f8';
            const gemY = baseY - doorHeight + gemRadius * .75;
            context.fillStyle = gemColor;
            context.strokeStyle = '#080808';
            context.lineWidth = Math.max(1, scale * .18);
            context.beginPath();
            context.arc(centerX, gemY, gemRadius, 0, Math.PI * 2);
            context.fill();
            context.stroke();
        }

        if (door.locked) {
            context.strokeStyle = '#f8d748';
            context.lineWidth = Math.max(1.4, scale * .3);
            context.strokeRect(centerX - doorWidth * .38,
                baseY - doorHeight * .48, doorWidth * .76,
                doorHeight * .42);
        }
        if (expanded) {
            context.fillStyle = '#fff';
            context.font = `bold ${Math.max(8, scale * 1.45)}px monospace`;
            context.textAlign = 'center';
            context.textBaseline = 'bottom';
            if (door.hasGem)
                context.fillText(GEM_NAMES[door.gem] ?? '?', centerX,
                    baseY - doorHeight - gemRadius * 1.25);
            if (door.label) {
                const label = `${door.town ? 'City' : 'Boss'}: ${door.label}`;
                const labelY = baseY - doorHeight - gemRadius * 4;
                const width = context.measureText(label).width + 6;
                context.fillStyle = 'rgba(0,0,0,.82)';
                context.fillRect(centerX - width / 2, labelY - 10, width, 11);
                context.fillStyle = '#fff';
                context.fillText(label, centerX, labelY);
            }
        }
    }
    for (const object of objects) {
        if (object.kind === 'item' && !expanded) continue;
        const x = viewX(object.x);
        const y = viewY(object.y);
        if (x >= viewWidth || y >= viewHeight) continue;
        const centerX = left + (x + .5) * scale;
        const centerY = top + (y + .5) * scale;
        if (object.kind === 'chest' || object.kind === 'key') {
            const size = Math.max(4, scale * (expanded ? 1.7 : 1.15));
            context.fillStyle = object.kind === 'key' ? '#ffe45c' : '#b86c24';
            context.strokeStyle = '#211205';
            context.lineWidth = 1;
            context.fillRect(centerX - size / 2, centerY - size * .38,
                size, size * .76);
            context.strokeRect(centerX - size / 2, centerY - size * .38,
                size, size * .76);
            context.beginPath();
            context.moveTo(centerX - size / 2, centerY - size * .05);
            context.lineTo(centerX + size / 2, centerY - size * .05);
            context.stroke();
            if (expanded) {
                context.fillStyle = object.kind === 'key' ? '#201800' : '#fff';
                context.font = `bold ${Math.max(8, scale * 1.3)}px monospace`;
                context.textAlign = 'center';
                context.textBaseline = 'middle';
                context.fillText(object.kind === 'key' ? 'K' : 'C',
                    centerX, centerY + .5);
            }
        } else {
            const size = object.kind === 'item' ? Math.max(1.5, scale) :
                Math.max(2.5, scale * (expanded ? 1.15 : .8));
            context.fillStyle = object.kind === 'item' ? '#55e6ff' : '#f04b3f';
            context.strokeStyle = '#190504';
            context.lineWidth = 1;
            if (object.kind === 'item') {
                const radius = Math.max(2, size * .72);
                context.beginPath();
                context.moveTo(centerX, centerY - radius);
                context.lineTo(centerX + radius, centerY);
                context.lineTo(centerX, centerY + radius);
                context.lineTo(centerX - radius, centerY);
                context.closePath();
                context.fill();
                context.strokeStyle = '#05232a';
                context.stroke();
            } else {
                context.beginPath();
                context.arc(centerX, centerY, size / 2, 0, Math.PI * 2);
                context.fill();
                context.stroke();
            }
        }
    }

    for (const pin of view.pins ?? []) {
        const x = viewX(pin.x);
        const y = viewY(pin.y);
        if (x >= viewWidth || y >= viewHeight) continue;
        const centerX = left + (x + .5) * scale;
        const centerY = top + (y + .5) * scale;
        const radius = Math.max(3, scale * (expanded ? 1.15 : .75));
        context.fillStyle = '#ffb400';
        context.strokeStyle = '#180d00';
        context.lineWidth = Math.max(1, scale * .2);
        context.beginPath();
        context.arc(centerX, centerY, radius, 0, Math.PI * 2);
        context.fill();
        context.stroke();
        if (expanded) {
            context.fillStyle = '#111';
            context.font = `bold ${Math.max(8, radius * 1.25)}px monospace`;
            context.textAlign = 'center';
            context.textBaseline = 'middle';
            context.fillText(String(pin.number), centerX, centerY + .5);
        }
    }

    const viewportX = viewX(position.scrollX + 4);
    const viewportY = viewY(position.scrollY + 3);
    context.strokeStyle = 'rgba(255,255,255,.55)';
    context.lineWidth = expanded ? 1.5 : 1;
    context.strokeRect(left + viewportX * scale,
        top + viewportY * scale, 28 * scale, 18 * scale);

    const playerX = left + viewX(position.playerX) * scale;
    const playerY = top + viewY(position.playerY) * scale;
    context.fillStyle = '#fff';
    context.strokeStyle = '#101010';
    context.lineWidth = 1;
    context.beginPath();
    context.arc(playerX, playerY, Math.max(2.2, scale * 1.8), 0,
        Math.PI * 2);
    context.fill();
    context.stroke();
}

/** Convert an internal canvas position to its wrapped cavern tile. */
export function cavernMinimapWorldAt(canvas: HTMLCanvasElement,
                                     map: CavernMap,
                                     position: MinimapPosition,
                                     expanded: boolean,
                                     canvasX: number,
                                     canvasY: number,
                                     view: MinimapView = {}):
        { x: number; y: number } | null {
    const viewWidth = Math.min(map.width, expanded ? 128 : 64);
    const viewHeight = Math.min(map.height, expanded ? 56 : 32);
    const centerX = expanded && view.centerX !== undefined
        ? view.centerX : position.playerX;
    const centerY = expanded && view.centerY !== undefined
        ? view.centerY : position.playerY;
    const viewLeft = Math.floor(centerX - viewWidth / 2);
    const viewTop = Math.floor(centerY - viewHeight / 2);
    const scale = Math.min(canvas.width / viewWidth,
        canvas.height / viewHeight);
    const left = (canvas.width - viewWidth * scale) / 2;
    const top = (canvas.height - viewHeight * scale) / 2;
    const column = Math.floor((canvasX - left) / scale);
    const row = Math.floor((canvasY - top) / scale);
    if (column < 0 || column >= viewWidth || row < 0 || row >= viewHeight)
        return null;
    const wrap = (value: number, size: number) =>
        ((value % size) + size) % size;
    return {
        x: wrap(viewLeft + column, map.width),
        y: wrap(viewTop + row, map.height),
    };
}
