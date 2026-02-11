# Flood: The Game — C to MIPS Translation

This project is a full translation of a C implementation of Flood, a grid-based puzzle game inspired by Simon Tatham’s *Flood*, into **MIPS assembly**. The goal was to reproduce the exact behaviour of the original C program at the assembly level, function by function, while respecting strict structural constraints.

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
