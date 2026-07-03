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
### Input Handling

The player types their answer using number keys (0-9). Backspace deletes the last digit. Enter submits the answer. The current typed input is displayed below the problem in large text, surrounded by square brackets (e.g., [ 46 ]). Negative answers are not accepted. The `love.textinput()` callback and gameplay key actions (numbers and Backspace) are only active and mapped to the input buffer when the game's actual state is 'playing', ensuring text input and editing are completely ignored during non-playing states (such as the 'title' or 'game-over' screens). The `love.textinput()` callback must validate input by discarding any non-digit character (only accepting '0'-'9'), preventing minus/hyphen or other non-numerical characters from being added to the input buffer, showing no error message.

When the player presses Enter during the playing state, if the input buffer is empty, the press is ignored (doing nothing, costing no lives, and maintaining the current state). Otherwise, the input buffer is submitted for evaluation. The submission sequence is as follows: (1) evaluate the answer for correctness, (2) update score and lives, (3) play the appropriate sound effect via `love.audio.play()` with the loaded `sfx_correct` Source if the answer is correct, or `sfx_wrong` if the answer is incorrect (including an incorrect or empty timer-expiry submission), (4) check if lives have reached 0 and transition to game-over state if needed, (5) clear the input buffer immediately before the next problem is generated. Sound effects are triggered asynchronously and continue to play even if a state transition occurs immediately after.

**Accepts:** Keyboard events (number keys 0-9, Backspace, Enter)

**Returns:** Updated input buffer displayed below the problem; answer submission on Enter with immediate audio feedback (sfx_correct or sfx_wrong played via love.audio.play())

### Overview

A simple LÖVE2D game for children that presents arithmetic problems and asks the player to type the answer. The player starts with a fixed number of lives and earns points for each correct answer. Problems get progressively harder as the score increases. The visual style uses large, colorful text on a dark background with a continuous animated particle effect to keep things lively. No background music needed, but some sound effects for answer feedback, using audio assets provided in the context directory.
</specification_context>

<architecture_context>
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
</architecture_context>

<dependency_files>
The following files from previous tasks are available. Use `grep_file` and `read_lines` to inspect the types, interfaces, and signatures you need.

- `game.lua`
</dependency_files>

<task>
## Main Entry Point Integration

Implement main.lua which requires 'game.lua' and maps all system-level LÖVE callbacks (love.load, love.update, love.draw, love.keypressed, love.textinput) cleanly to the Game module interfaces with zero extra logic.

## Files to Produce

- `main.lua`
</task>