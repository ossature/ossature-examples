# Interface: MATH_QUEST

@source: build

# MATH_QUEST Public Interface

## game.lua

```lua
-- Game module: core game logic and rendering for Math Quest

local Game = {}

--- Load all game resources and initialize state.
--- Must be called once before update/draw.
function Game.load() ... end

--- Update game logic.
--- @param dt number  Delta time in seconds since last frame.
function Game.update(dt) ... end

--- Render the current game state to the screen.
function Game.draw() ... end

--- Handle key press events.
--- @param key string  LÖVE key constant (e.g. "return", "backspace", "kpenter", "minus").
function Game.keypressed(key) ... end

--- Handle text input events (digit characters only, playing mode only).
--- @param t string  Single character string from the OS text input.
function Game.textinput(t) ... end

return Game
```

## main.lua

```lua
-- Entry point: delegates all LÖVE callbacks to the Game module.

function love.load() ... end
function love.update(dt) ... end
function love.draw() ... end
function love.keypressed(key) ... end
function love.textinput(t) ... end
```

## Window Configuration (conf.lua)

```lua
-- Window and module settings applied at startup via love.conf.
-- title:      "Math Quest"
-- width:      1280
-- height:     720
-- resizable:  false
-- audio:      enabled
-- joystick:   disabled
-- physics:    disabled
function love.conf(t) ... end
```