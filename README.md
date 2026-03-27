# Diced

A dice-rolling score game built with [LÖVE](https://love2d.org/) (Love2D).

![Gameplay Screenshot](docs/screenshots/gameplay.png)

## How to Play

- Select which dice to keep, then click **Roll** to roll the rest
- Score accumulates each round — play until you run out of dice
- Your lowest score is saved and displayed on the main menu
- Press **Escape** during a game to access the exit menu

## Running the Game

Requires [LÖVE 11.x](https://love2d.org/).

```bash
love .
```

## Dice

The game uses five dice types: d6, d8, d10, d12, and d20.

## Project Structure

```
src/
  core/        # State machine, dice logic, save system
  ui/
    screens/   # Main menu, game loop, game over
    components # Reusable UI (buttons, stats modal)
    assets/    # Sprites and fonts
```
