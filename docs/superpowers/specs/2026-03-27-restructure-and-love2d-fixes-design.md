# Design: Directory Restructure and Love2D Code Fixes

**Date:** 2026-03-27
**Branch:** refactor-cleanup
**Status:** Approved

---

## Overview

Two related changes to the Diced Love2D game:

1. Reorganize the directory structure to separate game logic from UI rendering
2. Fix incorrect and inefficient usage of Love2D APIs

---

## 1. Directory Structure

### Target Structure

```
diced/
├── conf.lua
├── main.lua
├── src/
│   ├── core/                   # Pure game logic, no rendering
│   │   ├── state.lua
│   │   ├── dice.lua
│   │   ├── save_manager.lua
│   │   ├── save_utils.lua
│   │   └── json.lua
│   └── ui/
│       ├── screens/            # Full-screen views (one per game state)
│       │   ├── menu.lua
│       │   ├── gameloop.lua
│       │   └── gameover.lua
│       ├── components/         # Reusable UI pieces
│       │   ├── button.lua
│       │   └── stats.lua
│       └── assets/             # Asset loaders
│           ├── sprites.lua
│           └── fonts.lua
├── docs/
│   └── SAVE_SYSTEM.md
└── assets/
    ├── fonts/
    └── sprites/
```

### File Moves

| From | To |
|------|----|
| `src/state.lua` | `src/core/state.lua` |
| `src/ui/dice.lua` | `src/core/dice.lua` |
| `src/save_manager.lua` | `src/core/save_manager.lua` |
| `docs/tools/json.lua` | `src/core/json.lua` |
| `docs/tools/save_utils.lua` | `src/core/save_utils.lua` |
| `src/ui/menu.lua` | `src/ui/screens/menu.lua` |
| `src/ui/gameloop.lua` | `src/ui/screens/gameloop.lua` |
| `src/ui/gameover.lua` | `src/ui/screens/gameover.lua` |
| `src/ui/button.lua` | `src/ui/components/button.lua` |
| `src/ui/stats.lua` | `src/ui/components/stats.lua` |
| `src/ui/sprites.lua` | `src/ui/assets/sprites.lua` |
| `src/ui/fonts.lua` | `src/ui/assets/fonts.lua` |

### Deletions

- `lib/moonshine/` — entire directory (unused shader library)
- `src/logger.lua` — unused logging utility
- `docs/tools/` — directory removed after files moved to `src/core/`

### Require Path Updates

Complete map of all `require()` calls that change due to the file moves:

| File (new path) | Old require | New require |
|-----------------|-------------|-------------|
| `main.lua` | `require("src/state")` | `require("src/core/state")` |
| `main.lua` | `require("src/ui/menu")` | `require("src/ui/screens/menu")` |
| `main.lua` | `require("src/ui/gameloop")` | `require("src/ui/screens/gameloop")` |
| `main.lua` | `require("src/ui/gameover")` | `require("src/ui/screens/gameover")` |
| `src/ui/screens/menu.lua` | `require("src/ui/button")` | `require("src/ui/components/button")` |
| `src/ui/screens/menu.lua` | `require("src/ui/sprites")` | `require("src/ui/assets/sprites")` |
| `src/ui/screens/menu.lua` | `require("src/ui/fonts")` | `require("src/ui/assets/fonts")` |
| `src/ui/screens/menu.lua` | `require("src/ui/stats")` | `require("src/ui/components/stats")` |
| `src/ui/screens/gameloop.lua` | `require("src/ui/dice")` | `require("src/core/dice")` |
| `src/ui/screens/gameloop.lua` | `require("src/ui/button")` | `require("src/ui/components/button")` |
| `src/ui/screens/gameloop.lua` | `require("src/ui/sprites")` | `require("src/ui/assets/sprites")` |
| `src/ui/screens/gameloop.lua` | `require("src/ui/fonts")` | `require("src/ui/assets/fonts")` |
| `src/ui/screens/gameover.lua` | `require("src/ui/button")` | `require("src/ui/components/button")` |
| `src/ui/screens/gameover.lua` | `require("src/ui/sprites")` | `require("src/ui/assets/sprites")` |
| `src/ui/screens/gameover.lua` | `require("src/ui/fonts")` | `require("src/ui/assets/fonts")` |
| `src/ui/screens/gameover.lua` | `require("src/save_manager")` | `require("src/core/save_manager")` |
| `src/ui/screens/gameover.lua` | `require("src/state")` | `require("src/core/state")` |
| `src/ui/components/stats.lua` | `require("src/save_manager")` | `require("src/core/save_manager")` |
| `src/core/dice.lua` | `require("src/ui/sprites")` | `require("src/ui/assets/sprites")` |
| `src/core/dice.lua` | `require("src/ui/fonts")` | `require("src/ui/assets/fonts")` |
| `src/core/save_manager.lua` | `require("docs/tools/json")` | `require("src/core/json")` — **two occurrences**: inside `serializeData()` and `deserializeData()`, both must be updated |
| `src/core/save_utils.lua` | `require("src/save_manager")` | `require("src/core/save_manager")` |
| `src/ui/components/stats.lua` | `require("src/ui/button")` | `require("src/ui/components/button")` |
| `src/ui/components/stats.lua` | `require("src/ui/sprites")` | `require("src/ui/assets/sprites")` |
| `src/ui/components/stats.lua` | `require("src/ui/fonts")` | `require("src/ui/assets/fonts")` |

Note: `main.lua` line 6 has `local Button = require("src/ui/button")` but `Button` is never used in `main.lua`. Remove this dead import entirely rather than updating its path.

Note: `main.lua` currently has `require("conf")` at the top. Love2D loads `conf.lua` automatically before `main.lua`, so this explicit require causes `conf.lua` to be processed twice. Remove the `require("conf")` line from `main.lua`.

---

## 2. Love2D Code Fixes

### Fix 1: Random Seeding

**Problem:** `math.randomseed(os.time())` is called inside `randomizeDicePositions()` in `gameloop.lua` on every roll. This re-seeds on every invocation and uses the stdlib RNG instead of Love2D's. Note: `dice.lua` already correctly uses `love.math.random()` — only `gameloop.lua` needs updating.

**Fix:**
- Remove `math.randomseed(os.time())` from `randomizeDicePositions()` in `gameloop.lua`
- Replace `math.random()` calls in `randomizeDicePositions()` with `love.math.random()`
- Add `love.math.setRandomSeed(os.time())` once in `love.load()` in `main.lua`

**Files affected:** `main.lua`, `src/ui/screens/gameloop.lua`

### Fix 2: setDefaultFilter Placement

**Problem:** `love.graphics.setDefaultFilter("nearest", "nearest")` is called as a module-level side effect in both `sprites.lua` and `fonts.lua`. Graphics state initialization belongs in `love.load()`, called once before any assets are loaded.

**Fix:**
- Remove the `setDefaultFilter` call from both `sprites.lua` and `fonts.lua`
- Add a single `love.graphics.setDefaultFilter("nearest", "nearest")` call to `love.load()` in `main.lua`, before any asset modules are required

**Files affected:** `main.lua`, `src/ui/assets/sprites.lua`, `src/ui/assets/fonts.lua`

### Fix 3: Escape Key Handler

**Problem:** No keyboard input handling exists. Love2D convention expects Escape to be handled. Players expect it to open an exit/pause menu.

**Fix:**
- Add `love.keypressed(key)` callback to `main.lua`
- In `GAME_LOOP` state: Escape toggles the exit confirmation menu (same as clicking the exit button); requires exposing a `toggleExitMenu()` method on `GameLoop`
- In `MAIN_MENU` and `GAME_OVER` states: Escape is a no-op

**Files affected:** `main.lua`, `src/ui/screens/gameloop.lua`

### Fix 4: Remove Dead Code

**Problem:** `lib/moonshine/` and `src/logger.lua` are included in the project but never referenced. Dead code increases confusion and build size.

**Fix:** Delete both. No source changes required — nothing requires them.

---

## Out of Scope

- Hardcoded window dimensions (1400×900 magic numbers) — deferred, not part of this change
- d12/d20 missing numbered sprites — separate issue
- Button instance state (`self.buttons` vs module globals) — separate refactor
- Score calculation deduplication — separate refactor
- `require("conf")` double-load in `main.lua` — addressed in require path updates section above

---

## Implementation Order

Files are moved first so that all Love2D fixes are applied to files at their final paths. This keeps the git diff clean and avoids editing files that are about to move.

1. Delete dead code (`lib/moonshine/`, `src/logger.lua`)
2. Move all files to new directory structure (create new directories, move files)
3. Update all `require()` paths using the complete map above
4. Apply Love2D code fixes (random seed, setDefaultFilter, keypressed, remove `require("conf")`)
5. Smoke test: launch game, navigate all screens, roll dice, save score
