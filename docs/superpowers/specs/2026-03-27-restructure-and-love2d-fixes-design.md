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

All `require()` calls throughout the codebase must be updated to reflect the new file locations. This includes:
- `main.lua` requiring screens, state
- Each screen requiring components, assets, and core modules
- `save_manager.lua` requiring `json`
- `gameover.lua` requiring `save_manager`

---

## 2. Love2D Code Fixes

### Fix 1: Random Seeding

**Problem:** `math.randomseed(os.time())` is called inside `randomizeDicePositions()` on every roll. This re-seeds on every invocation and uses the stdlib RNG instead of Love2D's.

**Fix:**
- Remove `math.randomseed(os.time())` from `randomizeDicePositions()`
- Add `love.math.setRandomSeed(os.time())` once in `love.load()` in `main.lua`
- Replace all `math.random()` calls with `love.math.random()`

**Files affected:** `main.lua`, `src/ui/gameloop.lua` (new path: `src/ui/screens/gameloop.lua`)

### Fix 2: setDefaultFilter Placement

**Problem:** `love.graphics.setDefaultFilter("nearest", "nearest")` is called as a side effect inside `sprites.lua` at module load time. Graphics state initialization belongs in `love.load()`.

**Fix:**
- Remove the `setDefaultFilter` call from `sprites.lua`
- Add it to `love.load()` in `main.lua` before any assets are loaded

**Files affected:** `main.lua`, `src/ui/assets/sprites.lua`

### Fix 3: Escape Key Handler

**Problem:** No keyboard input handling exists. Love2D convention expects Escape to be handled. Players expect it to open an exit/pause menu.

**Fix:**
- Add `love.keypressed(key)` callback to `main.lua`
- In `GAME_LOOP` state: Escape toggles the exit confirmation menu (same as clicking the exit button)
- In `MAIN_MENU` and `GAME_OVER` states: Escape is a no-op

**Files affected:** `main.lua`, `src/ui/screens/gameloop.lua` (needs an `onKeyPressed` method or the exit menu toggle exposed)

### Fix 4: Remove Dead Code

**Problem:** `lib/moonshine/` and `src/logger.lua` are included in the project but never referenced. Dead code increases confusion and build size.

**Fix:** Delete both. No source changes required — nothing requires them.

---

## Out of Scope

- Hardcoded window dimensions (1400×900 magic numbers) — deferred, not part of this change
- d12/d20 missing numbered sprites — separate issue
- Button instance state (`self.buttons` vs module globals) — separate refactor
- Score calculation deduplication — separate refactor

---

## Implementation Order

1. Delete dead code (`lib/moonshine/`, `src/logger.lua`)
2. Apply Love2D code fixes (random seed, setDefaultFilter, keypressed)
3. Move files to new directory structure
4. Update all `require()` paths
5. Smoke test: launch game, navigate all screens, roll dice, save score
