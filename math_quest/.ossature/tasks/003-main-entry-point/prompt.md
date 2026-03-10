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
</architecture_context>

<dependency_files>
The following files from previous tasks are available. Use `grep_file` and `read_lines` to inspect the types, interfaces, and signatures you need.

- `conf.lua` (9 lines)
- `game.lua` (448 lines)
</dependency_files>

<task>
## Main Entry Point

Create main.lua — the thin entry point that wires all LÖVE2D callbacks (love.load, love.update, love.draw, love.keypressed, love.textinput) to the Game module. Contains no logic of its own, just delegation.

## Files to Produce

- `main.lua`
</task>