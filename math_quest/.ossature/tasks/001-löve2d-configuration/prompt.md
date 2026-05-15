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

Create conf.lua, the LÖVE2D configuration callback that sets window dimensions (1280×720), title ('Math Quest'), disables unused modules (joystick, physics), and enables audio. This runs before love.load and requires no other files.

## Files to Produce

- `conf.lua`
</task>