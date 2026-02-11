# Flood: The Game — C to MIPS Translation

This project is a full translation of a C implementation of Flood, a grid-based puzzle game inspired by Simon Tatham’s *Flood*, into **MIPS assembly**. The goal was to reproduce the exact behaviour of the original C program at the assembly level, function by function, while respecting strict structural constraints.

---

## File Overview

| File        | Description |
|-------------|-------------|
| `flood.c`   | Original C reference implementation of the Flood game. Used as the behavioural baseline for the MIPS translation. |
| `flood.s`   | Full MIPS assembly translation of `flood.c`. Implements identical game logic, control flow, and output under strict constraints. |
| `Makefile`  | Build script for compiling and running the Flood program. Automates assembly and linking steps for the MIPS implementation. |
| `README.md` | Project documentation describing the game, translation task, design constraints, and implementation details. |
| `input.txt` | Sample input file used for testing and verifying game behaviour and command handling. |

---

## About the Game

Flood is played on a coloured grid. The player performs repeated **flood-fill operations** starting from the top-left cell, attempting to make the entire grid a single colour within a limited number of steps.

### Game Rules
- The game is **won** when all cells are the same colour.
- The game is **lost** if the player runs out of allowed steps.
- The number of steps allowed is based on an optimal solution, with a small margin to make the game achievable.

---

## Controls

The program supports the following commands:

- `w` / `a` / `s` / `d` — Move the selected cell up / left / down / right  
- `h` — Print instructions  
- `e` — Perform a flood fill  
- `c` — Print a (relatively) optimal solution  
- `q` — Quit the game  

---

## Original C Program

The provided C program (`flood.c`) implements all game logic, including:
- Grid initialisation
- Flood-fill mechanics
- Input handling
- Win/loss detection
- Optimal-solution calculation

You can compile and run the original C version with:

```bash
dcc flood.c -o flood
./flood
