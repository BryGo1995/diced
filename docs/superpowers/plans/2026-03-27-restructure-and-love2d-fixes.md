# Directory Restructure and Love2D Fixes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reorganize the source tree into `core/` and `ui/screens|components|assets/` subdirectories, remove dead code, and fix three incorrect Love2D API usages.

**Architecture:** Files are moved first using `git mv` to preserve history, then all `require()` paths are updated, then Love2D fixes are applied to files at their final paths. The game will not launch between the move step and the require-path step — that window is intentional and kept short.

**Tech Stack:** Love2D (Lua 5.1), no test framework. Verification is done by launching the game (`love .` in the project root) and exercising each screen.

**Spec:** `docs/superpowers/specs/2026-03-27-restructure-and-love2d-fixes-design.md`

---

## File Map

### Files Being Moved (git mv)

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

### Files Being Deleted

- `lib/moonshine/` (entire directory)
- `src/logger.lua`
- `docs/tools/` (directory, emptied after moves)

### Files Being Modified

- `main.lua` — require paths, dead imports, love.load() additions, love.keypressed() callback
- `src/ui/assets/sprites.lua` — remove `setDefaultFilter` side effect
- `src/ui/assets/fonts.lua` — remove `setDefaultFilter` side effect
- `src/ui/screens/gameloop.lua` — require paths, random seed fix, add `toggleExitMenu()` method
- `src/ui/screens/menu.lua` — require paths only
- `src/ui/screens/gameover.lua` — require paths only
- `src/ui/components/button.lua` — no changes (no requires to update)
- `src/ui/components/stats.lua` — require paths only
- `src/core/dice.lua` — require paths only
- `src/core/save_manager.lua` — require paths only (two call sites)
- `src/core/save_utils.lua` — require paths only

---

## Task 1: Delete Dead Code

**Files:**
- Delete: `lib/moonshine/` (entire directory)
- Delete: `src/logger.lua`

- [ ] **Step 1: Remove moonshine library**

```bash
git rm -r lib/moonshine/
```

- [ ] **Step 2: Remove logger**

```bash
git rm src/logger.lua
```

- [ ] **Step 3: Verify nothing requires them**

```bash
grep -r "moonshine\|logger" src/ main.lua
```

Expected: no output (nothing references either file)

- [ ] **Step 4: Launch the game to confirm it still works**

```bash
love .
```

Expected: game launches, main menu appears, no errors in console

- [ ] **Step 5: Commit**

```bash
git commit -m "Remove unused moonshine library and logger"
```

---

## Task 2: Create New Directories and Move Files

**Files:** All files listed in the File Map above

- [ ] **Step 1: Create the new directories**

```bash
mkdir -p src/core src/ui/screens src/ui/components src/ui/assets
```

- [ ] **Step 2: Move core files**

```bash
git mv src/state.lua src/core/state.lua
git mv src/ui/dice.lua src/core/dice.lua
git mv src/save_manager.lua src/core/save_manager.lua
git mv docs/tools/json.lua src/core/json.lua
git mv docs/tools/save_utils.lua src/core/save_utils.lua
```

- [ ] **Step 3: Move screen files**

```bash
git mv src/ui/menu.lua src/ui/screens/menu.lua
git mv src/ui/gameloop.lua src/ui/screens/gameloop.lua
git mv src/ui/gameover.lua src/ui/screens/gameover.lua
```

- [ ] **Step 4: Move component files**

```bash
git mv src/ui/button.lua src/ui/components/button.lua
git mv src/ui/stats.lua src/ui/components/stats.lua
```

- [ ] **Step 5: Move asset files**

```bash
git mv src/ui/sprites.lua src/ui/assets/sprites.lua
git mv src/ui/fonts.lua src/ui/assets/fonts.lua
```

- [ ] **Step 6: Remove the now-empty docs/tools directory**

```bash
git rm -r docs/tools/
```

- [ ] **Step 7: Verify the moves with git status**

```bash
git status
```

Expected: all 12 files shown as `renamed:`, docs/tools removed

- [ ] **Step 8: Commit the moves**

```bash
git commit -m "Move files to core/ui/screens/components/assets structure"
```

Note: the game will not launch at this point — require paths still point to old locations. That is expected and will be fixed in the next two tasks.

---

## Task 3: Update Require Paths — main.lua

**Files:**
- Modify: `main.lua`

- [ ] **Step 1: Open main.lua and apply all changes**

Replace the entire top of the file and update `love.load()`. The screen module `require` calls must move **inside** `love.load()` — this is required so that `love.graphics.setDefaultFilter` (added in Task 8) can run before any images are loaded. If the requires stay at the top of the file, they execute before `love.load()` is ever called, and `setDefaultFilter` would have no effect on already-loaded images.

Replace old lines 1–8:

```lua
require("conf")

local stateMachine = require("src/state").stateMachine
local states = require("src/state").states
local Menu = require("src/ui/menu")
local Button = require("src/ui/button")
local GameLoop = require("src/ui/gameloop")
local GameOver = require("src/ui/gameover")
```

Replace with (top of file, only state — no graphics dependency):

```lua
local stateMachine = require("src/core/state").stateMachine
local states = require("src/core/state").states
```

Then update `love.load()` to require the screen modules locally, after graphics initialization:

```lua
function love.load()
    local Menu = require("src/ui/screens/menu")
    local GameLoop = require("src/ui/screens/gameloop")
    local GameOver = require("src/ui/screens/gameover")

    -- Initialize the game state machine
    gameState = stateMachine.new()

    -- Initialize the main menu module
    menu = Menu.new()
    menu:init()

    -- Initialize the game loop module
    gameLoop = GameLoop.new(7, 6, 4, 2, 1)
    gameLoop:init()

    -- Initialize the game over screen module
    gameOver = GameOver.new()
    gameOver:init()
end
```

Changes made:
- Removed `require("conf")` — Love2D loads conf.lua automatically; the explicit require caused conf.lua to be processed twice
- Removed `local Button = require("src/ui/button")` — dead import, Button is never used in main.lua
- Updated `src/state` → `src/core/state` on two separate require calls (one per line)
- Moved `Menu`, `GameLoop`, `GameOver` requires inside `love.load()` so `setDefaultFilter` (Task 8) can precede them

- [ ] **Step 2: Commit**

```bash
git add main.lua
git commit -m "Update require paths in main.lua, move screen requires into love.load"
```

Note: the game remains unlaunchable after this commit — require paths in the screen modules still point to old locations. That is expected and will be fixed in Tasks 4 and 5.

---

## Task 4: Update Require Paths — Screens

**Files:**
- Modify: `src/ui/screens/menu.lua`
- Modify: `src/ui/screens/gameloop.lua`
- Modify: `src/ui/screens/gameover.lua`

- [ ] **Step 1: Update menu.lua requires**

Find and replace each require at the top of `src/ui/screens/menu.lua`:

| Old | New |
|-----|-----|
| `require("src/ui/button")` | `require("src/ui/components/button")` |
| `require("src/ui/sprites")` | `require("src/ui/assets/sprites")` |
| `require("src/ui/fonts")` | `require("src/ui/assets/fonts")` |
| `require("src/ui/stats")` | `require("src/ui/components/stats")` |

- [ ] **Step 2: Update gameloop.lua requires**

Find and replace each require at the top of `src/ui/screens/gameloop.lua`:

| Old | New |
|-----|-----|
| `require("src/ui/dice")` | `require("src/core/dice")` |
| `require("src/ui/button")` | `require("src/ui/components/button")` |
| `require("src/ui/sprites")` | `require("src/ui/assets/sprites")` |
| `require("src/ui/fonts")` | `require("src/ui/assets/fonts")` |

- [ ] **Step 3: Update gameover.lua requires**

Find and replace each require in `src/ui/screens/gameover.lua`:

| Old | New |
|-----|-----|
| `require("src/ui/button")` | `require("src/ui/components/button")` |
| `require("src/ui/sprites")` | `require("src/ui/assets/sprites")` |
| `require("src/ui/fonts")` | `require("src/ui/assets/fonts")` |
| `require("src/save_manager")` | `require("src/core/save_manager")` |
| `require("src/state")` | `require("src/core/state")` |

Note: `gameover.lua` may require `src/save_manager` inside a method body rather than at the top — search the whole file, not just the header.

- [ ] **Step 4: Commit**

```bash
git add src/ui/screens/menu.lua src/ui/screens/gameloop.lua src/ui/screens/gameover.lua
git commit -m "Update require paths in screen modules"
```

Note: the game remains unlaunchable after this commit — require paths in core modules and components still point to old locations. That will be fixed in Task 5.

---

## Task 5: Update Require Paths — Core and Components

**Files:**
- Modify: `src/core/dice.lua`
- Modify: `src/core/save_manager.lua`
- Modify: `src/core/save_utils.lua`
- Modify: `src/ui/components/stats.lua`

- [ ] **Step 1: Update dice.lua requires**

Find and replace in `src/core/dice.lua`:

| Old | New |
|-----|-----|
| `require("src/ui/sprites")` | `require("src/ui/assets/sprites")` |
| `require("src/ui/fonts")` | `require("src/ui/assets/fonts")` |

- [ ] **Step 2: Update save_manager.lua requires**

`save_manager.lua` has two inline `require("docs/tools/json")` calls — one inside `serializeData()` and one inside `deserializeData()`. Search the whole file and update both:

| Old | New |
|-----|-----|
| `require("docs/tools/json")` | `require("src/core/json")` |

Verify with:

```bash
grep -n "docs/tools/json" src/core/save_manager.lua
```

Expected: no output (both occurrences replaced)

- [ ] **Step 3: Update save_utils.lua requires**

Find and replace in `src/core/save_utils.lua`:

| Old | New |
|-----|-----|
| `require("src/save_manager")` | `require("src/core/save_manager")` |

- [ ] **Step 4: Update stats.lua requires**

Find and replace in `src/ui/components/stats.lua`:

| Old | New |
|-----|-----|
| `require("src/ui/button")` | `require("src/ui/components/button")` |
| `require("src/ui/sprites")` | `require("src/ui/assets/sprites")` |
| `require("src/ui/fonts")` | `require("src/ui/assets/fonts")` |
| `require("src/save_manager")` | `require("src/core/save_manager")` |

- [ ] **Step 5: Commit**

```bash
git add src/core/dice.lua src/core/save_manager.lua src/core/save_utils.lua src/ui/components/stats.lua
git commit -m "Update require paths in core modules and stats component"
```

---

## Task 6: Smoke Test After Restructure

- [ ] **Step 1: Launch the game**

```bash
love .
```

Expected: game launches with no errors, main menu visible

- [ ] **Step 2: Test all screens**

Manually verify:
- Main menu renders and buttons are clickable
- Click Start — game loop screen loads, dice appear
- Select dice and click Roll — dice roll, score updates
- Play through until game over — game over screen appears with score
- Click Play Again — returns to game loop
- Click Menu — returns to main menu
- Open stats modal on main menu — stats display appears

- [ ] **Step 3: Fix any require errors found**

If the game fails with a `module 'X' not found` error, find the offending require in the error message and check the require path table in the spec. Correct and relaunch.

- [ ] **Step 4: Commit any fixes**

```bash
git add -p
git commit -m "Fix any remaining require paths after restructure"
```

---

## Task 7: Fix Random Seeding

**Files:**
- Modify: `main.lua`
- Modify: `src/ui/screens/gameloop.lua`

- [ ] **Step 1: Add love.math.setRandomSeed to love.load() in main.lua**

In `main.lua`, inside `love.load()`, add this as the first line of the function body:

```lua
function love.load()
    love.math.setRandomSeed(os.time())
    -- Initialize the game state machine
    ...
```

- [ ] **Step 2: Fix randomizeDicePositions in gameloop.lua**

In `src/ui/screens/gameloop.lua`, find the `randomizeDicePositions` function. It currently contains:

```lua
math.randomseed(os.time())
...
local randomIndex = math.random(1, #dicePositions)
```

Remove the `math.randomseed(os.time())` line entirely and change `math.random` to `love.math.random`:

```lua
local randomIndex = love.math.random(1, #dicePositions)
```

- [ ] **Step 3: Launch and verify dice positions randomize on roll**

```bash
love .
```

Roll dice several times and confirm positions vary each roll and do not follow a predictable pattern.

- [ ] **Step 4: Commit**

```bash
git add main.lua src/ui/screens/gameloop.lua
git commit -m "Fix random seeding: use love.math.setRandomSeed once in love.load"
```

---

## Task 8: Fix setDefaultFilter Placement

**Files:**
- Modify: `main.lua`
- Modify: `src/ui/assets/sprites.lua`
- Modify: `src/ui/assets/fonts.lua`

Background: `love.graphics.setDefaultFilter` only applies to images loaded **after** the call. In Task 3, the screen module `require` calls were moved inside `love.load()`. This means `setDefaultFilter` just needs to be placed before those `require` lines in `love.load()` and it will take effect for all image loading.

- [ ] **Step 1: Add setDefaultFilter to love.load() in main.lua**

In `main.lua`, add `love.graphics.setDefaultFilter("nearest", "nearest")` at the top of `love.load()`, before the `require` calls for `Menu`, `GameLoop`, and `GameOver`. It must come before those lines because those requires chain into sprites.lua and fonts.lua where all images are loaded.

```lua
function love.load()
    love.math.setRandomSeed(os.time())
    love.graphics.setDefaultFilter("nearest", "nearest")

    local Menu = require("src/ui/screens/menu")
    local GameLoop = require("src/ui/screens/gameloop")
    local GameOver = require("src/ui/screens/gameover")
    ...
```

- [ ] **Step 2: Remove setDefaultFilter from sprites.lua**

In `src/ui/assets/sprites.lua`, delete line 3:

```lua
love.graphics.setDefaultFilter("nearest", "nearest")
```

- [ ] **Step 3: Remove setDefaultFilter from fonts.lua**

In `src/ui/assets/fonts.lua`, delete line 3:

```lua
love.graphics.setDefaultFilter("nearest", "nearest")
```

- [ ] **Step 4: Launch and verify sprites still render pixel-perfect**

```bash
love .
```

All dice and UI sprites should appear crisp/pixelated (not blurry). If anything looks blurry, confirm the `setDefaultFilter` line in `love.load()` appears before the `require("src/ui/screens/menu")` line.

- [ ] **Step 5: Commit**

```bash
git add main.lua src/ui/assets/sprites.lua src/ui/assets/fonts.lua
git commit -m "Move setDefaultFilter to love.load, remove module-level side effects"
```

---

## Task 9: Add Escape Key Handler

**Files:**
- Modify: `main.lua`
- Modify: `src/ui/screens/gameloop.lua`

- [ ] **Step 1: Add toggleExitMenu method to GameLoop**

In `src/ui/screens/gameloop.lua`, add the following method. Place it near the other input-handling methods (near `GameLoop:onClick`):

```lua
function GameLoop:toggleExitMenu()
    self.displayExitMenu = not self.displayExitMenu
end
```

- [ ] **Step 2: Add love.keypressed callback to main.lua**

In `main.lua`, add a new callback after `love.mousepressed`:

```lua
function love.keypressed(key)
    local currentState = gameState:getState()
    if currentState == states.GAME_LOOP then
        if key == "escape" then
            gameLoop:toggleExitMenu()
        end
    end
end
```

- [ ] **Step 3: Launch and test Escape key**

```bash
love .
```

- Start a game and press Escape — exit confirmation menu should appear
- Press Escape again — exit confirmation menu should disappear
- On main menu and game over screen, pressing Escape should do nothing

- [ ] **Step 4: Commit**

```bash
git add main.lua src/ui/screens/gameloop.lua
git commit -m "Add Escape key handler to toggle exit menu in game loop"
```

---

## Task 10: Final Smoke Test

- [ ] **Step 1: Full playthrough**

```bash
love .
```

Run a complete playthrough:
1. Main menu renders correctly
2. Stats modal opens and closes
3. Start game — all dice types visible (d6, d8, d10, d12, d20)
4. Select dice, roll multiple times, score accumulates
5. Press Escape mid-game — exit menu appears and dismisses
6. Play until game over
7. Game over screen shows correct score
8. Verify save works — replay and check if low score updates
9. Return to menu via both Play Again and Menu buttons

- [ ] **Step 2: Verify directory structure matches spec**

```bash
find src/ -name "*.lua" | sort
```

Expected output:
```
src/core/dice.lua
src/core/json.lua
src/core/save_manager.lua
src/core/save_utils.lua
src/core/state.lua
src/ui/assets/fonts.lua
src/ui/assets/sprites.lua
src/ui/components/button.lua
src/ui/components/stats.lua
src/ui/screens/gameover.lua
src/ui/screens/gameloop.lua
src/ui/screens/menu.lua
```

- [ ] **Step 3: Confirm dead code is gone**

```bash
ls lib/ 2>/dev/null && echo "lib/ still exists" || echo "lib/ removed"
ls src/logger.lua 2>/dev/null && echo "logger.lua still exists" || echo "logger.lua removed"
```

Expected: both report removed

- [ ] **Step 4: Final commit if any loose ends**

```bash
git status
```

If clean, the work is done. If there are unstaged changes, review and commit them.
