# Rouge

A tiny 2D woods roguelike built with **Godot 4.7**.

Slash slimes and a skeleton miniboss, open the chest to pick from a set of
roguelike upgrades, and see how long you can survive the woods.

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
| SPACE / Enter | Attack · interact (open the chest) |

## Features

- Zelda-style heart HUD, and a miniboss that shows its own hearts
- Chest shrine with 6 upgrades: Hearty, Swift, Sharp, Quick, Heavy, Sturdy
- Y-sorted trees, cliffs you can hop down, knockback combat with i-frames
- Pixel-art UI built entirely in code (`scripts/ui_theme.gd`)

## Running

Open the project in **Godot 4.7+** and press F5, or from a terminal:

```sh
godot --path .
```

## Project layout

- `scenes/` — menu, world, player, enemies, bones miniboss
- `scripts/` — gameplay and all UI code
- `art/` — sprite assets

## Credits

- **Mystic Woods (free)** art pack by [Game Endeavor](https://game-endeavor.itch.io/mystic-woods) — non-commercial license
- **Enemy Animations Set** skeleton sprites
- Made with the [Godot Engine](https://godotengine.org/) (MIT)
