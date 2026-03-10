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
### Window Configuration

The game window is 1280×720, non-resizable, with the title "Math Quest".

**Accepts:** None (static configuration)

**Returns:** LÖVE2D window configured at launch

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
</architecture_context>

<task>
## LÖVE2D Configuration

Create the conf.lua file that configures the LÖVE2D window (1280×720, non-resizable, titled 'Math Quest') and disables unused modules. This is the first file LÖVE loads before anything else.

## Files to Produce

- `conf.lua`
</task>