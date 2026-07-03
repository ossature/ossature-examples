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
### Window Configuration

The game window is 1280×720, non-resizable, with the title "Math Quest".

**Accepts:** None (static configuration)

**Returns:** LÖVE2D window configured at launch
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
## LÖVE2D Window Configuration

Create the conf.lua configuration file to customize the LÖVE2D window (title 'Math Quest', width 1280, height 720, non-resizable) and disable unused modules (joystick, physics) as outlined in the AMD.

## Files to Produce

- `conf.lua`
</task>