# Interface: MATH_QUEST

@source: build

# MATH_QUEST Public Interface

## conf.lua

Configures the LÖVE game window and enabled modules.

```lua
---Configures LÖVE engine settings.
---@param t table LÖVE configuration table
function love.conf(t) end
```

---

## game.lua

The core gameplay module, exposing state and lifecycle methods.

### Types

```lua
---@alias GameMode "title" | "playing" | "gameover"

---@class Problem
---@field text string The formatted mathematical expression to display
---@field answer number The correct mathematical result

---@class Feedback
---@field r number Red channel color value [0, 1]
---@field g number Green channel color value [0, 1]
---@field b number Blue channel color value [0, 1]
---@field timer number Time remaining in seconds for the feedback display
---@field type "correct" | "wrong" The evaluation type

---@class Particle
---@field x number X coordinate
---@field y number Y coordinate
---@field dx number X velocity (drift)
---@field dy number Y velocity (drift)
---@field r number Red channel color value [0, 1]
---@field g number Green channel color value [0, 1]
---@field b number Blue channel color value [0, 1]
---@field alpha number Current opacity [0, 1]
---@field life number Remaining lifespan in seconds
---@field max_life number Initial maximum lifespan in seconds
---@field radius number Visual circle radius

---@class GameState
---@field mode GameMode Current screen mode
---@field score number Player's current score
---@field lives number Remaining lives
---@field problem Problem Currently active arithmetic problem
---@field input string Current keyboard input buffer
---@field timer number Seconds remaining for the current problem
---@field feedback Feedback | nil Triggers a temporary color flash on submit
---@field particles Particle[] Background decorative particles
---@field sfx_correct love.Source | nil Audio source for correct answers
---@field sfx_wrong love.Source | nil Audio source for wrong/expired answers
```

### Module Interface

```lua
local Game = {}

---The live core state of the game
---@type GameState
Game.state = ...

---Initializes resources, assets, and pre-populates background particles.
function Game.load() end

---Updates particle positions, standard game timers, and feedback stages.
---@param dt number Delta time in seconds since the last frame
function Game.update(dt) end

---Clears the screen and draws active screen interfaces (title, playing, gameover) and particles.
function Game.draw() end

---Handles keyboard commands such as start/reset entries and backspaces.
---@param key string The name of the pressed key
function Game.keypressed(key) end

---Handles validated numeric digit input buffers.
---@param t string The text string representing typed characters
function Game.textinput(t) end

return Game
```

---

## main.lua

Main entrypoint hooking LÖVE callbacks directly to standard module methods.

```lua
---Loads the main game module on game start
function love.load() end

---Updates game state
---@param dt number Delta time
function love.update(dt) end

---Draws current game graphics
function love.draw() end

---Delegates keypresses to the game module
---@param key string Key pressed
function love.keypressed(key) end

---Delegates character input to the game module
---@param t string Written text character
function love.textinput(t) end
```