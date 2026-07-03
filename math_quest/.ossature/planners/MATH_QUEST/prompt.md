# Project: math_quest v0.1.0 (lua)

## Specification (SMD)

---
id: MATH_QUEST
status: draft
priority: high
depends: []
---

# Math Quest — A Math Game for Kids

## Overview

A simple LÖVE2D game for children that presents arithmetic problems and asks the player to type the answer. The player starts with a fixed number of lives and earns points for each correct answer. Problems get progressively harder as the score increases. The visual style uses large, colorful text on a dark background with a continuous animated particle effect to keep things lively. No background music needed, but some sound effects for answer feedback, using audio assets provided in the context directory.

## Goals

- Provide a fun, distraction-free math practice game for kids aged 6-12
- Run as a standalone LÖVE2D application with no external image or font assets (audio assets are bundled)
- Keep the codebase minimal (3 Lua modules or fewer)

## Non-Goals

- Multiplayer or networking
- Persistent high scores or save files
- Image/sprite assets
- Configurable difficulty settings (difficulty scales automatically)

## Requirements

### Game States

The game has three states: title, playing, and game-over.

**Accepts:** None (state transitions driven by player input)

**Returns:** The appropriate screen rendered for the current state

### Problem Generation

Generate arithmetic problems appropriate to the player's current level using the following algorithm.

**Accepts:** Current score (integer, used to determine level)

**Returns:** A problem with a display string and its correct integer answer

### Input Handling

The player types their answer using number keys (0-9). Backspace deletes the last digit. Enter submits the answer. The current typed input is displayed below the problem in large text, surrounded by square brackets (e.g., [ 46 ]). Negative answers are not accepted. The `love.textinput()` callback must validate input by discarding any non-digit character (only accepting '0'-'9'), preventing minus/hyphen or other non-numerical characters from being added to the input buffer, showing no error message.

When the player presses Enter during the playing state, the input buffer is submitted for evaluation. The submission sequence is as follows: (1) evaluate the answer for correctness, (2) update score and lives, (3) play the appropriate sound effect via `love.audio.play()` with the loaded `sfx_correct` Source if the answer is correct, or `sfx_wrong` if the answer is incorrect or the timer expired, (4) check if lives have reached 0 and transition to game-over state if needed, (5) clear the input buffer immediately before the next problem is generated. Sound effects are triggered asynchronously and continue to play even if a state transition occurs immediately after.

**Accepts:** Keyboard events (number keys 0-9, Backspace, Enter)

**Returns:** Updated input buffer displayed below the problem; answer submission on Enter with immediate audio feedback (sfx_correct or sfx_wrong played via love.audio.play())

### Scoring and Lives

The player starts with 3 lives. A correct answer adds 1 to the score. A wrong answer removes 1 life. When lives reach 0, transition to game-over state. Display a visual feedback flash on answer lasting 0.5 seconds: green flash for correct, red flash for wrong. Timer expiry submits whatever is currently in the input buffer for evaluation: if the buffer is empty, it is treated as an incorrect answer and causes a loss of life; if the buffer is non-empty, it is evaluated normally (correct or wrong).

**Accepts:** Player's submitted answer (integer)

**Returns:** Updated score and lives; visual feedback (green flash for correct, red flash for wrong)

### Background Animation

A continuous particle animation runs behind all game states. Small colored circles (or dots) drift slowly across the screen in random directions, fading in and out. Use at least 5 distinct soft colors, defined as colors with saturation ≤ 0.7 and lightness between 0.4 and 0.9 in HSL color space. New particles spawn at random positions at a steady rate. This is purely decorative and must not interfere with text readability.

**Accepts:** Delta time (float, seconds since last frame)

**Returns:** Rendered particle layer behind all UI elements

### Audio

No background music needed.

**Accepts:** Game events (correct answer, wrong answer)

**Returns:** Audio playback

### Window Configuration

The game window is 1280×720, non-resizable, with the title "Math Quest".

**Accepts:** None (static configuration)

**Returns:** LÖVE2D window configured at launch

### No tests required

Don't generate any test code for this, as this is a game we don't need to generate test code.

**Accepts:** None

**Returns:** None

## Constraints

- All rendering uses LÖVE2D's built-in drawing API and default font (scaled up) — no external font files
- The game must run with `love .` from the output directory
- All state (score, lives, current problem) is in-memory only — no file I/O during gameplay
- Timer per problem is 10 seconds
- Minimum font size for the problem text is 48px; answer input is 36px
- Background animation must run at a consistent frame rate independent of the game state
- All generated problems must have non-negative integer answers (e.g., for subtraction, ensure the first operand is >= the second operand)

## Examples

### Title Screen

**Input:**

```
love .
```

**Output:**

```
╔══════════════════════════╗
        ║                          ║
        ║       MATH QUEST         ║
        ║                          ║
        ║   Press Enter to Start   ║
        ║                          ║
        ╚══════════════════════════╝
```

### Playing Screen

**Input:**

```
Player presses Enter to start, answers problem "12 + 34 = ?" by typing "46"
```

**Output:**

```
Score: 7          Lives: X X X

              12 + 34 = ?

                 [ 46 ]

            ████████░░  (timer bar)
```

### Game Over Screen

**Input:**

```
Player loses last life
```

**Output:**

```
╔══════════════════════════╗
        ║                          ║
        ║       GAME OVER          ║
        ║                          ║
        ║     Final Score: 12      ║
        ║                          ║
        ║  Press Enter to Restart  ║
        ║                          ║
        ╚══════════════════════════╝
```

## Acceptance Criteria

- [ ] Game launches with `love .` and displays the title screen
- [ ] Pressing Enter on the title screen or game-over screen starts a new game with score 0 and 3 lives
- [ ] Problems are displayed with large readable text
- [ ] Player can type a numeric answer and submit with Enter
- [ ] Correct answers increment score, wrong answers decrement lives
- [ ] Game ends at 0 lives and shows final score
- [ ] Background animation runs continuously across all states
- [ ] Problems scale in difficulty as score increases
- [ ] Timer bar counts down and auto-submits on expiry
- [ ] No background music
- [ ] Correct/wrong answer sound effects play on submission

## Notes



## Architecture Documents (AMD)

---
spec: MATH_QUEST
status: draft
---

# Architecture: Architecture: Math Quest

## Overview

Minimal LÖVE2D game structured as three Lua modules: a configuration file, a game logic module, and the main entry point that wires LÖVE callbacks to the game module. All state lives in a single game state table managed by `game.lua`.

## Components

### Configuration

@path: conf.lua

LÖVE2D configuration callback. Sets window dimensions, title, and disables unused modules.

**Interface:**

```lua
-- Called by LÖVE before love.load
function love.conf(t)
    t.window.title = "Math Quest"
    t.window.width = 1280
    t.window.height = 720
    t.window.resizable = false
    t.modules.audio = true
    t.modules.joystick = false
    t.modules.physics = false
end
```

### Game Logic

@path: game.lua

Core module managing all game state, problem generation, input handling, scoring, timer, audio, and rendering. Exports a table of functions called by main.lua. Loads audio assets (`correct.wav`, `wrong.ogg`) at startup and plays them in response to game events.

**Interface:**

```lua
local Game = {}

-- State: "title" | "playing" | "gameover"
-- Managed internally via Game.state

function Game.load()           -- Initialize state, particles, fonts, load sound effects
function Game.update(dt)       -- Update timer, particles, feedback flash
function Game.draw()           -- Render current state (background, UI, problem)
function Game.keypressed(key)  -- Handle Enter (start/submit/restart), Backspace; play correct/wrong sounds on answer
function Game.textinput(t)     -- Handle digit input (0-9)

return Game
```

### Main Entry Point

@path: main.lua

Wires LÖVE2D callbacks to the Game module. Contains no logic of its own.

**Interface:**

```lua
local Game = require("game")

function love.load()           Game.load() end
function love.update(dt)       Game.update(dt) end
function love.draw()           Game.draw() end
function love.keypressed(key)  Game.keypressed(key) end
function love.textinput(t)     Game.textinput(t) end
```

**Depends on:** Game Logic

## Data Models

### Game State

```lua
-- Internal to game.lua, not exported
state = {
    mode = "title",        -- "title" | "playing" | "gameover"
    score = 0,
    lives = 3,
    problem = {            -- Current problem
        text = "12 + 34",  -- Display string
        answer = 46,       -- Correct answer (integer)
    },
    input = "",            -- Player's typed digits
    timer = 10.0,          -- Seconds remaining
    feedback = nil,        -- { color = {r,g,b}, timer = 0.5 } or nil
    particles = {},        -- List of background particle tables
    sfx_correct = nil,     -- love.audio.Source ("static")
    sfx_wrong = nil,       -- love.audio.Source ("static")
}
```

### Particle

```lua
-- Each particle in state.particles
{
    x = 400, y = 300,      -- Position
    dx = 0.5, dy = -0.3,   -- Velocity (pixels/sec)
    r = 0.4, g = 0.6, b = 1.0,  -- Color
    alpha = 0.7,           -- Current opacity
    life = 5.0,            -- Seconds remaining
    max_life = 5.0,        -- Total lifespan (for fade calc)
    radius = 4,            -- Circle radius
}
```

## Flow

```
```
love.load  → Game.load()  → init state, spawn particles, create fonts
love.update(dt) → Game.update(dt) → update timer, particles, feedback
love.draw  → Game.draw()  → draw particles, then draw state-specific UI
love.keypressed → Game.keypressed(key) → state transitions, submit answer
love.textinput  → Game.textinput(t) → append digit to input buffer
```
```

## Dependencies

- LÖVE2D 11.x: Game framework (love.graphics, love.timer, love.math, love.audio)

## Notes

All game state is held in a local table inside game.lua. No global variables. The particle system is hand-rolled (a simple table of particle structs updated each frame) — do not use love.graphics.newParticleSystem. Audio assets (`correct.wav`, `wrong.ogg`) are provided in the context directory and must be present in the output directory at runtime. Sound effects are loaded as static sources.

## Audit Findings
Account for the following findings when planning. Avoid generating tasks that would hit these known spec issues:

- [WARNING] Requirements > Scoring and Lives, L82: There is an ambiguity regarding the 0.5-second feedback flash and the transition to the game-over screen when lives reach 0. It is unclear if the transition is delayed by 0.5 seconds to show the final red flash on the playing screen, or if the screen transitions to the game-over state immediately (and if so, whether the red flash is drawn on the game-over screen or bypassed completely).
- [WARNING] Requirements > Input Handling, L72: The spec notes that 'gameplay key actions (numbers and Backspace)' are active in keypressed during the 'playing' state, but also states that love.textinput() validates and appends digits. In LÖVE2D, handling numerical keys in both callbacks (e.g. keypressed and textinput) causes duplicate numeric entries (such as typing '1' and getting '11').
- [INFO] Architecture Documents (AMD) > Data Models > Game State, L88: There is a minor discrepancy in the string representation for the game-over state. The SMD uses 'game-over' (with a hyphen, e.g., L30, L40, L72) while the AMD uses 'gameover' (without a hyphen, e.g., L47, L88). This could lead to mismatched state comparisons causing runtime crashes or lockups.
- [INFO] Requirements > Scoring and Lives, L82: The requirement specifies that during the 0.5-second feedback flash, 'gameplay updates (specifically the 10-second countdown timer) and user text input are paused'. Because the decorative background particle system is meant to run continuously and at a consistent frame rate, a naive pause of Game.update(dt) would incorrectly pause the background animation too.

## Context Files

The following files are available in the project's context directory. These are pre-existing assets (audio, images, reference code, documentation, and so on) that may be useful during implementation.

- `.DS_Store` (application/octet-stream)
- `correct.wav` (audio/wav)
- `wrong.ogg` (audio/ogg)

Two ways to use them in a task. For files the LLM should READ as reference (example code, docs, spec snippets), list them in the task's `context_files` field. Text files get included in the task's prompt; binary assets are exposed via tools so the implementer can copy them into the output directory (often under `assets/` or `sounds/`).

For files that should be copied verbatim with no transformation (binary assets, fixtures, reference data), emit a copy task instead. Set `source = ["context://<path-or-glob>"]` and leave `verify` empty. The build system copies matched files directly without calling the LLM. Source and output patterns pair 1:1 by index, and any `*` or `**` wildcard in source must align with one in outputs so each matched basename is preserved. Typical candidates are opaque/binary assets like `.mp3`, `.wav`, `.png`, `.ttf`, `.pdf`, fonts, and fixtures where the output is byte-identical to the context file.