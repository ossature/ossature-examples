<project_config>
Project: math_quest v0.1.0
Language: lua
</project_config>

<project_brief>
Math Quest is a children's arithmetic game built with LÖVE2D (Lua) that presents progressively difficult math problems and accepts typed numeric answers. The project consists of a single main spec (MATH_QUEST) responsible for the entire game loop, including problem generation, input handling, scoring, lives tracking, and rendering. The game starts the player with a fixed number of lives and generates arithmetic problems that increase in difficulty as the player's score rises. Players type their answers using the keyboard, receiving immediate feedback through sound effects loaded from provided audio assets. The visual presentation uses large, colorful text rendered against a dark background, accompanied by a continuous animated particle system (using LÖVE2D's built-in ParticleSystem) to maintain visual engagement for young players. Core LÖVE2D callbacks (love.load, love.update, love.draw, love.keypressed) drive the game structure, managing state transitions between active gameplay and game-over screens. The difficulty scaling system adjusts operand ranges and potentially introduces new arithmetic operations (addition, subtraction, multiplication) based on score thresholds. No external libraries are used beyond the LÖVE2D framework itself, and no background music is included—only sound effects for correct and incorrect answer feedback. The entire project is contained in a single Lua codebase targeting the LÖVE2D runtime.
</project_brief>

<spec_brief spec="MATH_QUEST">
Math Quest is a LÖVE2D children's arithmetic game with three states (title, playing, game-over) that generates progressively harder math problems based on the player's score, tracks lives (starting at 3) and points, enforces a 10-second timer per problem, and provides visual feedback flashes and audio sound effects (sfx_correct/sfx_wrong) on answer submission. Key responsibilities include problem generation with guaranteed non-negative integer answers, keyboard input handling (digits, backspace, enter, with explicit minus-key suppression), score/lives management with automatic difficulty scaling, and a continuous decorative particle animation rendered behind all UI across all game states. It is a self-contained LÖVE2D application (1280×720 window, no external fonts or images, bundled audio assets only) structured in 3 or fewer Lua modules using LÖVE2D's built-in drawing API, audio system, and default font.
</spec_brief>

<specification_context>
### Overview

A simple LÖVE2D game for children that presents arithmetic problems and asks the player to type the answer. The player starts with a fixed number of lives and earns points for each correct answer. Problems get progressively harder as the score increases. The visual style uses large, colorful text on a dark background with a continuous animated particle effect to keep things lively. No background music needed, but some sound effects for answer feedback, using audio assets provided in the context directory.

### Game States

The game has three states: title, playing, and game-over.

**Accepts:** None (state transitions driven by player input)

**Returns:** The appropriate screen rendered for the current state

### Problem Generation

Generate arithmetic problems appropriate to the player's current level using the following algorithm.

**Accepts:** Current score (integer, used to determine level)

**Returns:** A problem with a display string and its correct integer answer

### Input Handling

The player types their answer using number keys (0-9). Backspace deletes the last digit. Enter submits the answer. The current typed input is displayed below the problem in large text, surrounded by square brackets (e.g., [ 46 ]). Negative answers are not accepted. If the player presses the minus/hyphen key, the `love.keypressed()` callback must check if `key == 'minus'` and consume the event (return true) without modifying the input buffer, preventing any character from being added and showing no error message. The `love.textinput()` callback is not involved in minus-key suppression; suppression is handled entirely in `love.keypressed()`.

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

### Constraints

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
</specification_context>

<architecture_context>
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

### Flow

```
```
love.load  → Game.load()  → init state, spawn particles, create fonts
love.update(dt) → Game.update(dt) → update timer, particles, feedback
love.draw  → Game.draw()  → draw particles, then draw state-specific UI
love.keypressed → Game.keypressed(key) → state transitions, submit answer
love.textinput  → Game.textinput(t) → append digit to input buffer
```
```

### Notes

All game state is held in a local table inside game.lua. No global variables. The particle system is hand-rolled (a simple table of particle structs updated each frame) — do not use love.graphics.newParticleSystem. Audio assets (`correct.wav`, `wrong.ogg`) are provided in the context directory and must be present in the output directory at runtime. Sound effects are loaded as static sources.
</architecture_context>

<dependency_files>
The following files from previous tasks are available. Use `grep_file` and `read_lines` to inspect the types, interfaces, and signatures you need.

- `conf.lua` (9 lines)
</dependency_files>

<context_files>
The following files from the project's context directory are assigned to this task. Use `copy_context_file(context_path, dest_path)` to copy assets into the appropriate location within the output directory (choose a destination path that fits the project structure, e.g. `assets/audio/music.mp3` or `sounds/correct.wav`). Use `read_context_file(context_path)` to read text files on demand.

- `correct.wav` — `audio/wav` (102736 bytes)

- `wrong.ogg` — `audio/ogg` (7425 bytes)
</context_files>

<task>
## Game Logic Module

Create game.lua — the core module containing all game state, problem generation, input handling, scoring, timer, background particle animation, audio loading/playback, feedback flashes, and rendering for all three game states (title, playing, gameover). This single module implements the full game logic per the architecture's design of keeping all state in a local table. Audio assets (correct.wav, wrong.ogg) are loaded as static sources at startup. The particle system is hand-rolled. Difficulty scales with score. The minus key is consumed in keypressed and also filtered in textinput to address the audit finding about LÖVE2D not suppressing textinput from keypressed return values. Timer expiry auto-submits the buffer with sound effects matching the submission sequence.

## Files to Produce

- `game.lua`
</task>