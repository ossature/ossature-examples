# Interface: MATH_QUEST

@source: build

# MATH_QUEST Public Interface

## conf.lua

```lua
--- Configures the LÖVE application window and modules.
--- @param t table LÖVE configuration table
function love.conf(t) ... end
```

## game.lua

```lua
local Game = {}

--- Initializes game state, loads fonts and sound effects.
function Game.load() ... end

--- Updates game logic: particles, feedback, timer, auto-submit.
--- @param dt number Delta time in seconds
function Game.update(dt) ... end

--- Draws the current game state (background, particles, UI).
function Game.draw() ... end

--- Draws the title screen overlay.
function Game.draw_title() ... end

--- Draws the active gameplay overlay (score, lives, problem, input, timer bar).
function Game.draw_playing() ... end

--- Draws the game over screen overlay (final score, restart prompt).
function Game.draw_gameover() ... end

--- Handles key press events for navigation and input.
--- @param key string The key that was pressed
--- @return boolean|nil Returns true if the key was consumed (minus key)
function Game.keypressed(key) ... end

--- Handles text input events; accepts digit characters during gameplay.
--- @param t string The text input character
function Game.textinput(t) ... end

return Game
```

## main.lua

```lua
--- LÖVE entry points delegating to the Game module.

--- @see Game.load
function love.load() ... end

--- @param dt number Delta time in seconds
--- @see Game.update
function love.update(dt) ... end

--- @see Game.draw
function love.draw() ... end

--- @param key string The key that was pressed
--- @see Game.keypressed
function love.keypressed(key) ... end

--- @param t string The text input character
--- @see Game.textinput
function love.textinput(t) ... end
```

### Game Modes (Internal Enum)

| Mode        | Description                        |
|-------------|------------------------------------|
| `"title"`   | Title screen, awaiting Enter       |
| `"playing"` | Active gameplay with problem/timer |
| `"gameover"`| Game over screen, awaiting restart |

### External Asset Dependencies

| File           | Type          | Usage          |
|----------------|---------------|----------------|
| `correct.wav`  | Audio (static)| Correct answer SFX |
| `wrong.ogg`    | Audio (static)| Wrong answer SFX   |

### Constants

| Name | Value | Description |
|------|-------|-------------|
| Window width | `1280` | Fixed window width |
| Window height | `720` | Fixed window height |
| Timer duration | `10.0` | Seconds per problem |
| Starting lives | `3` | Lives at game start |
| Level interval | `5` | Score points per level |