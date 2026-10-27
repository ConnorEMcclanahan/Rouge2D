# Rouge

A tiny 2D woods roguelike I'm making in **Godot 4.7**.

Slash slimes and a skeleton miniboss, open the chest to pick from a set of
upgrades, and see how long you last.

## Screenshots

| Title screen | Gameplay |
|:---:|:---:|
| ![Title screen](docs/screenshots/menu.png) | ![Gameplay](docs/screenshots/world.png) |

| Upgrade choice | Game over |
|:---:|:---:|
| ![Upgrade choice](docs/screenshots/upgrade.png) | ![Game over](docs/screenshots/gameover.png) |

## Controls

| Input | Action |
|-------|--------|
| WASD / Arrow keys | Move |
| SPACE / Enter | Attack / interact (open the chest) |
| ESC | Pause |

## What's in it

- Heart-based health (zelda style), the miniboss shows his own hearts
- Chest with 6 upgrades: Hearty, Swift, Sharp, Quick, Heavy, Sturdy
- Y-sorted trees, cliffs you can hop down, knockback combat with i-frames
- Floating damage numbers, boss nameplate with a segmented hp bar
- Run timer + kill counter in the HUD
- Pause menu with volume sliders and a fullscreen toggle
- Scene transitions with a pixel-dissolve shader (`scripts/dissolve.gdshader`)
- All UI is drawn in code (`scripts/ui_theme.gd`), no theme files

## Running

Open the project in **Godot 4.7+** and press F5, or from a terminal:

```sh
godot --path .
```

## Project layout

- `scenes/` — menu, world, player, enemies, bones miniboss
- `scripts/` — gameplay and UI
- `art/` — sprite assets

## Credits

- **Mystic Woods (free)** art pack by [Game Endeavor](https://game-endeavor.itch.io/mystic-woods) — non-commercial license
- **Enemy Animations Set** skeleton sprites
- Made with the [Godot Engine](https://godotengine.org/) (MIT)
