# ld48
Ludum Dare 48 Entry

# Installing

Make sure you clone the project to (on Mac) `~/Documents/The Electric Toy Co/freshly/games/ld48/`.

# Resource Rules

## Sprites

- All live in `sprites.png`
- Has to be in PNG format (includes transparency)
- sprites.png each dimension must be a power of 2 (...256, 512, 1024, 2048)
- Image can be no larger than 2048 on each side
- Consists of "cells" that are square and a power of 2 (...8, 16, 32, 64...)
- Sprites can span cells, but are rendered from a given rectangle of cells

## Audio

- Lives in the `audio/` folder.
- .mp3 or .wav files.

## Map

- Use the "Tiled" editor to create
- Output is a .tmx file
- Use `sprites.png` as the base spritesheet
- .tsx file is ignored.

# Tools

BFXR: https://www.bfxr.net/
The "Tiled" Map Editor: https://www.mapeditor.org/
