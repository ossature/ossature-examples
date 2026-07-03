<project_config>
Project: math_quest v0.1.0
Language: lua
</project_config>

<project_brief>
Math Quest is a 2D educational math game built with the Lua programming language and the LÖVE2D framework. The application generates progressive arithmetic problems for players while tracking score and player lives in a persistent game state. Structurally, the codebase organizers its execution around native LÖVE2D lifecycle methods to connect four key subsystems: a problem-generation engine, an input validation controller, an audio feedback system, and a visual rendering pipeline. The problem generator uses the current score to dynamically scale arithmetic complexity, while the input validation controller captures keyboard inputs for answer feedback. Upon answer submission, the validation state triggers both mathematical state updates and the audio system to play corresponding feedback sound assets from the directory. Simultaneously, the visual rendering pipeline draws high-contrast, colorful text interfaces and manages a continuous, animated particle system using LÖVE2D's simulation properties to maintain a dynamic background throughout the gameplay loop.
</project_brief>

<spec_brief spec="MATH_QUEST">
This standalone LÖVE2D module implements an educational arithmetic game featuring dynamic difficulty scaling, stateful life and score tracking, and text-based input processing. Its key responsibilities include rendering high-contrast UI elements with an active, animated particle background, managing math problem generation, and controlling gameplay state transitions. The module integrates directly with LÖVE2D system APIs for graphics, input, and audio, utilizing local sound assets to provide real-time audio feedback.
</spec_brief>

<specification_context>
### Game States

The game has three states: title, playing, and game-over.

**Accepts:** None (state transitions driven by player input)

**Returns:** The appropriate screen rendered for the current state

### Problem Generation

Generate arithmetic problems appropriate to the player's current level using the following algorithm.

**Accepts:** Current score (integer, used to determine level)

**Returns:** A problem with a display string and its correct integer answer

### Input Handling

The player types their answer using number keys (0-9). Backspace deletes the last digit. Enter submits the answer. The current typed input is displayed below the problem in large text, surrounded by square brackets (e.g., [ 46 ]). Negative answers are not accepted. The `love.textinput()` callback and gameplay key actions (numbers and Backspace) are only active and mapped to the input buffer when the game's actual state is 'playing', ensuring text input and editing are completely ignored during non-playing states (such as the 'title' or 'game-over' screens). The `love.textinput()` callback must validate input by discarding any non-digit character (only accepting '0'-'9'), preventing minus/hyphen or other non-numerical characters from being added to the input buffer, showing no error message.

When the player presses Enter during the playing state, if the input buffer is empty, the press is ignored (doing nothing, costing no lives, and maintaining the current state). Otherwise, the input buffer is submitted for evaluation. The submission sequence is as follows: (1) evaluate the answer for correctness, (2) update score and lives, (3) play the appropriate sound effect via `love.audio.play()` with the loaded `sfx_correct` Source if the answer is correct, or `sfx_wrong` if the answer is incorrect (including an incorrect or empty timer-expiry submission), (4) check if lives have reached 0 and transition to game-over state if needed, (5) clear the input buffer immediately before the next problem is generated. Sound effects are triggered asynchronously and continue to play even if a state transition occurs immediately after.

**Accepts:** Keyboard events (number keys 0-9, Backspace, Enter)

**Returns:** Updated input buffer displayed below the problem; answer submission on Enter with immediate audio feedback (sfx_correct or sfx_wrong played via love.audio.play())

### Scoring and Lives

The player starts with 3 lives. A correct answer adds 1 to the score. A wrong answer removes 1 life. When lives reach 0, transition to game-over state. Display a visual feedback flash on answer lasting 0.5 seconds: green flash for correct, red flash for wrong. During this 0.5-second feedback flash, gameplay updates (specifically the 10-second countdown timer) and user text input are paused, all keypress handling (specifically Enter for submission, Backspace, and numeric inputs) must be completely disabled and ignored, and the next problem is generated and its countdown timer is started only after the 0.5-second flash has fully completed. Timer expiry automatically submits whatever is currently in the input buffer, triggering the exact same 5-step evaluation sequence (steps 1 through 5) outlined in the Input Handling section: if the buffer is empty, it is treated as an incorrect answer and causes a loss of life; if the buffer is non-empty, it is evaluated normally (correct or wrong).

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
</architecture_context>

<dependency_files>
The following files from previous tasks are available. Use `grep_file` and `read_lines` to inspect the types, interfaces, and signatures you need.

- `correct.wav`
- `wrong.ogg`
</dependency_files>

<task>
## Core Game Logic and Drawing Module

Implement the main game.lua module. This module holds local state for mode, score, lives, current problem, input buffer, timer, feedback flash info, and particles list. It implements: (1) HSL-to-RGB particle system processing continuously independent of screen state, using at least 5 distinct soft colors; (2) arithmetic problem generation based on current score (ensuring positive results for subtraction); (3) gameplay pausing during the 0.5-second feedback flash (preventing input or countdown logic while particles still animate); (4) audio playback of correct.wav and wrong.ogg; (5) input validation via love.textinput (accepting only '0'-'9' characters in textinput and handling backspace/enter in keypressed) to avoid duplicate digit entries; (6) font and drawing operations utilizing LÖVE's built-in vector graphics. State mode constants must stick strictly to 'title', 'playing', and 'gameover'.

## Files to Produce

- `game.lua`
</task>