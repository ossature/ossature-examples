# Specification (SMD)

---
L1: ---
L2: id: MATH_QUEST
L3: status: draft
L4: priority: high
L5: depends: []
L6: ---
L7: # Math Quest — A Math Game for Kids
L8: 
L9: ## Overview
L10: 
L11: A simple LÖVE2D game for children that presents arithmetic problems and asks the player to type the answer. The player starts with a fixed number of lives and earns points for each correct answer. Problems get progressively harder as the score increases. The visual style uses large, colorful text on a dark background with a continuous animated particle effect to keep things lively. No background music needed, but some sound effects for answer feedback, using audio assets provided in the context directory.
L12: 
L13: ## Goals
L14: 
L15: - Provide a fun, distraction-free math practice game for kids aged 6-12
L16: - Run as a standalone LÖVE2D application with no external image or font assets (audio assets are bundled)
L17: - Keep the codebase minimal (3 Lua modules or fewer)
L18: 
L19: ## Non-Goals
L20: 
L21: - Multiplayer or networking
L22: - Persistent high scores or save files
L23: - Image/sprite assets
L24: - Configurable difficulty settings (difficulty scales automatically)
L25: 
L26: ## Requirements
L27: 
L28: ### Game States
L29: 
L30: The game has three states: title, playing, and game-over.
L31: 
L32: **Accepts:** None (state transitions driven by player input)
L33: 
L34: **Returns:** The appropriate screen rendered for the current state
L35: 
L36: **Title state:** Display the game name "Math Quest" in large centered text with "Press Enter to Start" below it. The background animation runs in all states.
L37: 
L38: **Playing state:** Show the current problem, an input field for the player's answer, the current score, and remaining lives. A countdown timer (configurable, default 10 seconds) ticks down for each problem. The timer resets to 10.0 seconds every time a new problem is generated. If the timer expires, it counts as a wrong answer.
L39: 
L40: **Game-over state:** Display "Game Over", the final score, and "Press Enter to Play Again". Pressing Enter returns to the title state.
L41: 
L42: ### Problem Generation
L43: 
L44: Generate arithmetic problems appropriate to the player's current level using the following algorithm.
L45: 
L46: **Accepts:** Current score (integer, used to determine level)
L47: 
L48: **Returns:** A problem with a display string and its correct integer answer
L49: 
L50: **Problem Generation Algorithm:**
L51: 
L52: Level L is calculated as: L = score ÷ 5 (integer division)
L53: 
L54: For each problem, randomly select one of the three operations below:
L55: 
L56: 1. **Addition:** Both operands are randomly chosen from 1 to 10×(L+1)
L57: 2. **Subtraction:** Minuend (first operand) = score + 10; subtrahend (second operand) randomly chosen from 1 to score (or 1 if score is 0). This ensures the first operand is always ≥ the second operand, yielding a non-negative result.
L58: 3. **Multiplication:** Both operands are randomly chosen from 1 to (L+3)
L59: 
L60: All problems must have non-negative integer answers. Division is excluded entirely. A random problem is chosen from the eligible set for the current level on each generation.
L61: 
L62: **Example Difficulty Progression:**
L63: 
L64: - **Level 0 (score 0–4):** Single-digit addition (e.g., 5 + 7) and subtraction with small operands
L65: - **Level 1 (score 5–9):** Two-digit addition (e.g., 15 + 23) and subtraction
L66: - **Level 2 (score 10–14):** Single-digit multiplication (e.g., 3 × 4) and larger addition
L67: - **Level 3 (score 15–19):** Two-digit multiplication (e.g., 6 × 12) and mixed operations
L68: - **Level 4+ (score ≥20):** Continued growth in operand ranges as L increases
L69: 
L70: ### Input Handling
L71: 
L72: The player types their answer using number keys (0-9). Backspace deletes the last digit. Enter submits the answer. The current typed input is displayed below the problem in large text, surrounded by square brackets (e.g., [ 46 ]). Negative answers are not accepted. If the player presses the minus/hyphen key, the `love.keypressed()` callback must check if `key == 'minus'` and consume the event (return true) without modifying the input buffer, preventing any character from being added and showing no error message. The `love.textinput()` callback is not involved in minus-key suppression; suppression is handled entirely in `love.keypressed()`.
L73: 
L74: When the player presses Enter during the playing state, the input buffer is submitted for evaluation. The submission sequence is as follows: (1) evaluate the answer for correctness, (2) update score and lives, (3) play the appropriate sound effect via `love.audio.play()` with the loaded `sfx_correct` Source if the answer is correct, or `sfx_wrong` if the answer is incorrect or the timer expired, (4) check if lives have reached 0 and transition to game-over state if needed, (5) clear the input buffer immediately before the next problem is generated. Sound effects are triggered asynchronously and continue to play even if a state transition occurs immediately after.
L75: 
L76: **Accepts:** Keyboard events (number keys 0-9, Backspace, Enter)
L77: 
L78: **Returns:** Updated input buffer displayed below the problem; answer submission on Enter with immediate audio feedback (sfx_correct or sfx_wrong played via love.audio.play())
L79: 
L80: ### Scoring and Lives
L81: 
L82: The player starts with 3 lives. A correct answer adds 1 to the score. A wrong answer removes 1 life. When lives reach 0, transition to game-over state. Display a visual feedback flash on answer lasting 0.5 seconds: green flash for correct, red flash for wrong. Timer expiry submits whatever is currently in the input buffer for evaluation: if the buffer is empty, it is treated as an incorrect answer and causes a loss of life; if the buffer is non-empty, it is evaluated normally (correct or wrong).
L83: 
L84: **Accepts:** Player's submitted answer (integer)
L85: 
L86: **Returns:** Updated score and lives; visual feedback (green flash for correct, red flash for wrong)
L87: 
L88: ### Background Animation
L89: 
L90: A continuous particle animation runs behind all game states. Small colored circles (or dots) drift slowly across the screen in random directions, fading in and out. Use at least 5 distinct soft colors, defined as colors with saturation ≤ 0.7 and lightness between 0.4 and 0.9 in HSL color space. New particles spawn at random positions at a steady rate. This is purely decorative and must not interfere with text readability.
L91: 
L92: **Accepts:** Delta time (float, seconds since last frame)
L93: 
L94: **Returns:** Rendered particle layer behind all UI elements
L95: 
L96: ### Audio
L97: 
L98: No background music needed.
L99: 
L100: **Accepts:** Game events (correct answer, wrong answer)
L101: 
L102: **Returns:** Audio playback
L103: 
L104: **Background music:** None
L105: 
L106: **Correct answer sound (`correct.wav`):** Plays once when the player submits a correct answer.
L107: 
L108: **Wrong answer sound (`wrong.ogg`):** Plays once when the player submits a wrong answer or the timer expires.
L109: 
L110: Audio assets are provided in the context directory and must be copied to the output directory during build. They are loaded at startup via `love.audio.newSource`.
L111: 
L112: ### Window Configuration
L113: 
L114: The game window is 1280×720, non-resizable, with the title "Math Quest".
L115: 
L116: **Accepts:** None (static configuration)
L117: 
L118: **Returns:** LÖVE2D window configured at launch
L119: 
L120: ### No tests required
L121: 
L122: Don't generate any test code for this, as this is a game we don't need to generate test code.
L123: 
L124: **Accepts:** None
L125: 
L126: **Returns:** None
L127: 
L128: ## Constraints
L129: 
L130: - All rendering uses LÖVE2D's built-in drawing API and default font (scaled up) — no external font files
L131: - The game must run with `love .` from the output directory
L132: - All state (score, lives, current problem) is in-memory only — no file I/O during gameplay
L133: - Timer per problem is 10 seconds
L134: - Minimum font size for the problem text is 48px; answer input is 36px
L135: - Background animation must run at a consistent frame rate independent of the game state
L136: - All generated problems must have non-negative integer answers (e.g., for subtraction, ensure the first operand is >= the second operand)
L137: 
L138: ## Examples
L139: 
L140: ### Title Screen
L141: 
L142: **Input:**
L143: 
L144: ```
L145: love .
L146: ```
L147: 
L148: **Output:**
L149: 
L150: ```
L151:         ╔══════════════════════════╗
L152:         ║                          ║
L153:         ║       MATH QUEST         ║
L154:         ║                          ║
L155:         ║   Press Enter to Start   ║
L156:         ║                          ║
L157:         ╚══════════════════════════╝
L158: ```
L159: 
L160: ### Playing Screen
L161: 
L162: **Input:**
L163: 
L164: ```
L165: Player presses Enter to start, answers problem "12 + 34 = ?" by typing "46"
L166: ```
L167: 
L168: **Output:**
L169: 
L170: ```
L171:         Score: 7          Lives: X X X
L172: 
L173:               12 + 34 = ?
L174: 
L175:                  [ 46 ]
L176: 
L177:             ████████░░  (timer bar)
L178: ```
L179: 
L180: ### Game Over Screen
L181: 
L182: **Input:**
L183: 
L184: ```
L185: Player loses last life
L186: ```
L187: 
L188: **Output:**
L189: 
L190: ```
L191:         ╔══════════════════════════╗
L192:         ║                          ║
L193:         ║       GAME OVER          ║
L194:         ║                          ║
L195:         ║     Final Score: 12      ║
L196:         ║                          ║
L197:         ║  Press Enter to Restart  ║
L198:         ║                          ║
L199:         ╚══════════════════════════╝
L200: ```
L201: 
L202: ## Acceptance Criteria
L203: 
L204: - Game launches with `love .` and displays the title screen
L205: - Pressing Enter starts a new game with score 0 and 3 lives
L206: - Problems are displayed with large readable text
L207: - Player can type a numeric answer and submit with Enter
L208: - Correct answers increment score, wrong answers decrement lives
L209: - Game ends at 0 lives and shows final score
L210: - Background animation runs continuously across all states
L211: - Problems scale in difficulty as score increases
L212: - Timer bar counts down and auto-submits on expiry
L213: - No background music
L214: - Correct/wrong answer sound effects play on submission
---

# Architecture Documents (AMD)

---
L1: ---
L2: spec: MATH_QUEST
L3: status: draft
L4: ---
L5: # Architecture: Math Quest
L6: 
L7: ## Overview
L8: 
L9: Minimal LÖVE2D game structured as three Lua modules: a configuration file, a game logic module, and the main entry point that wires LÖVE callbacks to the game module. All state lives in a single game state table managed by `game.lua`.
L10: 
L11: ## Components
L12: 
L13: ### Configuration
L14: 
L15: @path: conf.lua
L16: 
L17: LÖVE2D configuration callback. Sets window dimensions, title, and disables unused modules.
L18: 
L19: **Interface:**
L20: 
L21: ```lua
L22: -- Called by LÖVE before love.load
L23: function love.conf(t)
L24:     t.window.title = "Math Quest"
L25:     t.window.width = 1280
L26:     t.window.height = 720
L27:     t.window.resizable = false
L28:     t.modules.audio = true
L29:     t.modules.joystick = false
L30:     t.modules.physics = false
L31: end
L32: ```
L33: 
L34: **Depends on:** None
L35: 
L36: ### Game Logic
L37: 
L38: @path: game.lua
L39: 
L40: Core module managing all game state, problem generation, input handling, scoring, timer, audio, and rendering. Exports a table of functions called by main.lua. Loads audio assets (`correct.wav`, `wrong.ogg`) at startup and plays them in response to game events.
L41: 
L42: **Interface:**
L43: 
L44: ```lua
L45: local Game = {}
L46: 
L47: -- State: "title" | "playing" | "gameover"
L48: -- Managed internally via Game.state
L49: 
L50: function Game.load()           -- Initialize state, particles, fonts, load sound effects
L51: function Game.update(dt)       -- Update timer, particles, feedback flash
L52: function Game.draw()           -- Render current state (background, UI, problem)
L53: function Game.keypressed(key)  -- Handle Enter (start/submit/restart), Backspace; play correct/wrong sounds on answer
L54: function Game.textinput(t)     -- Handle digit input (0-9)
L55: 
L56: return Game
L57: ```
L58: 
L59: **Depends on:** None
L60: 
L61: ### Main Entry Point
L62: 
L63: @path: main.lua
L64: 
L65: Wires LÖVE2D callbacks to the Game module. Contains no logic of its own.
L66: 
L67: **Interface:**
L68: 
L69: ```lua
L70: local Game = require("game")
L71: 
L72: function love.load()           Game.load() end
L73: function love.update(dt)       Game.update(dt) end
L74: function love.draw()           Game.draw() end
L75: function love.keypressed(key)  Game.keypressed(key) end
L76: function love.textinput(t)     Game.textinput(t) end
L77: ```
L78: 
L79: **Depends on:** Game Logic
L80: 
L81: ## Data Models
L82: 
L83: ### Game State
L84: 
L85: ```lua
L86: -- Internal to game.lua, not exported
L87: state = {
L88:     mode = "title",        -- "title" | "playing" | "gameover"
L89:     score = 0,
L90:     lives = 3,
L91:     problem = {            -- Current problem
L92:         text = "12 + 34",  -- Display string
L93:         answer = 46,       -- Correct answer (integer)
L94:     },
L95:     input = "",            -- Player's typed digits
L96:     timer = 10.0,          -- Seconds remaining
L97:     feedback = nil,        -- { color = {r,g,b}, timer = 0.5 } or nil
L98:     particles = {},        -- List of background particle tables
L99:     sfx_correct = nil,     -- love.audio.Source ("static")
L100:     sfx_wrong = nil,       -- love.audio.Source ("static")
L101: }
L102: ```
L103: 
L104: ### Particle
L105: 
L106: ```lua
L107: -- Each particle in state.particles
L108: {
L109:     x = 400, y = 300,      -- Position
L110:     dx = 0.5, dy = -0.3,   -- Velocity (pixels/sec)
L111:     r = 0.4, g = 0.6, b = 1.0,  -- Color
L112:     alpha = 0.7,           -- Current opacity
L113:     life = 5.0,            -- Seconds remaining
L114:     max_life = 5.0,        -- Total lifespan (for fade calc)
L115:     radius = 4,            -- Circle radius
L116: }
L117: ```
L118: 
L119: ## Flow
L120: 
L121: ```
L122: love.load  → Game.load()  → init state, spawn particles, create fonts
L123: love.update(dt) → Game.update(dt) → update timer, particles, feedback
L124: love.draw  → Game.draw()  → draw particles, then draw state-specific UI
L125: love.keypressed → Game.keypressed(key) → state transitions, submit answer
L126: love.textinput  → Game.textinput(t) → append digit to input buffer
L127: ```
L128: 
L129: ## Dependencies
L130: 
L131: - LÖVE2D 11.x: Game framework (love.graphics, love.timer, love.math, love.audio)
L132: 
L133: ## Notes
L134: 
L135: All game state is held in a local table inside game.lua. No global variables. The particle system is hand-rolled (a simple table of particle structs updated each frame) — do not use love.graphics.newParticleSystem. Audio assets (`correct.wav`, `wrong.ogg`) are provided in the context directory and must be present in the output directory at runtime. Sound effects are loaded as static sources.