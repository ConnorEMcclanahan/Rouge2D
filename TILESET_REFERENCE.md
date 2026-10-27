# Tileset Reference — Mystic Woods (free)

Everything lives under `art/mystic_woods_free_2.2/sprites/`.
All atlas coordinates below are `(x, y)` in **16x16 tiles** unless noted.
Textures must be used with nearest filtering (project already forces it).

---

## 1. `tilesets/plains.png` — 96x192 = 6x12 tiles (16px)
Used as **TileSet source 0** in `world.tscn`.

| Rows | Cols | What it is |
|------|------|-----------|
| 0-2  | 0-5  | Grass variants (speckled detail) |
| 3    | 0-3  | Grass variants; 4-5 EMPTY |
| 4-5  | 0-5  | **Cliff CAPS** (grassy top edge of a cliff) |
| 6    | 0-4  | **Cliff FACE** (rocky wall); col 5 = cap/face blend |
| 7    | 0-3  | Cliff reverse edge (grass on top, rock below); 4-5 EMPTY |
| 8-10 | 0-5  | Uniform ground base (this is the main map grass) |
| 11   | 0-3  | Ground base variants; 4-5 lighter grass |

### The cliff cluster: atlas (1..3, 4..6) — a 3x3 block
```
(1,4)(2,4)(3,4)   <- cap row (grassy top)
(1,5)(2,5)(3,5)   <- cap row
(1,6)(2,6)(3,6)   <- face row (rock)
```
**Native orientation: the face is on the SOUTH side** (caps on top).
This is the exact block the world's cliff layer uses.

---

## 2. `tilesets/grass.png` — 16x16, ONE tile
Single grass tile at `(0,0)`.

---

## 3. `objects/objects.png` — 256x208 = 16x13 tiles (16px)
Used as **TileSet source 2** (the ysort layer) in `world.tscn`.
NOTE: the art pack ships native collision polygons on some tiles, but the game
replaces them with full-tile rects at runtime (`ysort_collision.gd`).

### Trees (registered in the world TileSet)
| Atlas | Size in atlas | Description |
|-------|---------------|-------------|
| (0,0) | 1x1 | Small tree |
| (0,1) | 1x1 | Small tree |
| (11,2) | 1x2 | Thin tree |
| (0,5) | 3x4 | **Big tree** (spawns at base cell, extends up-left) |
| (6,7) | 2x2 | Medium tree |
| (8,6) | 2x3 | Medium tree |
| (10,7) | 2x2 | Medium tree |
| (5,0) | 1x1 | Small tree |
| (10,0),(11,0) | 1x1 | Small trees |

### Props / interactables (NOT in the world TileSet yet — add them as needed)
| Atlas | Description |
|-------|-------------|
| **(5,0)** | **Wooden SIGN board** (dense wood + carved marks) |
| **(10,3), (11,3)** | **CRATES** (breakable boxes) |
| (0,8),(6,8),(7,8),(8,8),(9,8) | Rocks / boulders |
| (1,8),(4,8),(10,8),(11,8),(4,0),(4,1),(9,1) | Bushes / foliage |
| (2,8),(5,8) | Twigs / sticks |
| (1..4,3),(11..14,3) | Red flower bushes |
| (1..4,9),(11,9),(6..9,12),(6..9,0) | Red flower bushes |

## 4. `objects/chest_01.png` — 64x16 = 4 frames of 16px
Chest open animation (frame 0 = closed, frames 1-3 = opening). Used by
`shrine.gd` — the upgrade chest placed in the world.

---

## Quick cheat sheet
- **Main grass field**: plains rows 8-10 (or grass.png single tile)
- **Cliff walls**: plains cluster (1..3, 4..6)
- **Trees that y-sort over the player**: objects.png tiles above, on a ysort layer
- **Upgrade chest**: chest_01.png frames via `shrine.gd` (in the world)
- **Breakable crate art**: objects.png (10,3) / (11,3)
- **Readable sign art**: objects.png (5,0)
- **Hearts / UI**: generated in code (`ui_theme.gd`), no art files
