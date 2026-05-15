<project_config>
Project: math_quest v0.1.0
Language: lua
</project_config>

<project_brief>
Math Quest is a children's arithmetic game built with the LÖVE2D (Love2D) framework in Lua that presents progressively harder addition, subtraction, multiplication, and division problems for the player to answer by typing. The single spec (MATH_QUEST) covers the entire game, which is structured around a main game loop managing three states: a start screen, an active gameplay screen, and a game-over screen. During gameplay, the player has a fixed number of lives, earns points for correct answers, and loses lives for incorrect ones; problem difficulty scales with the current score by increasing the range of operands. The visual layer renders large, colorful text on a dark background and maintains a continuous animated particle system for visual engagement. Sound effects sourced from the project's context directory provide audio feedback for correct and incorrect answers. The codebase uses standard LÖVE2D callbacks (`love.load`, `love.update`, `love.draw`, `love.keypressed`, `love.textinput`) to manage initialization, frame updates, rendering, and keyboard input respectively. State transitions, score tracking, life management, problem generation, particle system updates, and sound playback are all handled within this single-file or tightly coupled module structure driven by the LÖVE2D runtime.
</project_brief>

<spec_brief spec="MATH_QUEST">
Math Quest is a self-contained LÖVE2D children's arithmetic game that presents randomized addition, subtraction, and multiplication problems with increasing difficulty tied to the player's score. It manages core game state including lives, score, and player input, rendering everything as large colorful text on a dark background with a continuous particle animation system. The module integrates with LÖVE2D's graphics, audio, and keyboard APIs, loading sound effect assets from the context directory for correct and incorrect answer feedback.
</spec_brief>

<specification_context>
### Overview

A simple LÖVE2D game for children that presents arithmetic problems and asks the player to type the answer. The player starts with a fixed number of lives and earns points for each correct answer. Problems get progressively harder as the score increases. The visual style uses large, colorful text on a dark background with a continuous animated particle effect to keep things lively. No background music needed, but some sound effects for answer feedback, using audio assets provided in the context directory.

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

- `conf.lua`
- `game.lua`
</dependency_files>

<task>
## Main Entry Point

Create main.lua, which requires game.lua and wires all LÖVE2D callbacks (love.load, love.update, love.draw, love.keypressed, love.textinput) to the corresponding Game module functions. Contains no game logic of its own.

## Files to Produce

- `main.lua`
</task>