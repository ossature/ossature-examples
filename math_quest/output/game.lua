local Game = {}

-- ─── Constants ────────────────────────────────────────────────────────────────
local SCREEN_W     = 1280
local SCREEN_H     = 720
local MAX_LIVES    = 3
local TIMER_MAX    = 10.0
local FEEDBACK_DUR = 0.5
local PARTICLE_COUNT = 80
local PARTICLE_SPAWN_RATE = 6  -- new particles per second

-- Soft colors: saturation ≤ 0.7, lightness 0.4–0.9 (pre-converted to RGB)
local PARTICLE_COLORS = {
    { 0.55, 0.75, 1.00 },  -- soft blue
    { 0.65, 1.00, 0.75 },  -- soft mint
    { 1.00, 0.80, 0.55 },  -- soft peach
    { 0.90, 0.65, 1.00 },  -- soft lavender
    { 1.00, 0.90, 0.55 },  -- soft yellow
    { 0.65, 0.90, 0.90 },  -- soft cyan
}

-- ─── Internal state ───────────────────────────────────────────────────────────
local state = {}

-- ─── Fonts ────────────────────────────────────────────────────────────────────
local font_huge   -- title / game-over headings  (~72px)
local font_large  -- problem text               (~56px)
local font_medium -- answer input / score/lives (~40px)
local font_small  -- general UI                 (~28px)

-- ─── Particle helpers ─────────────────────────────────────────────────────────
local function new_particle(x, y)
    local col = PARTICLE_COLORS[love.math.random(#PARTICLE_COLORS)]
    local speed = love.math.random() * 40 + 10
    local angle = love.math.random() * math.pi * 2
    local life  = love.math.random() * 6 + 3
    return {
        x       = x  or love.math.random(0, SCREEN_W),
        y       = y  or love.math.random(0, SCREEN_H),
        dx      = math.cos(angle) * speed,
        dy      = math.sin(angle) * speed,
        r       = col[1],
        g       = col[2],
        b       = col[3],
        alpha   = 0.0,
        life    = life,
        max_life= life,
        radius  = love.math.random(2, 6),
    }
end

local function spawn_particles(n)
    for _ = 1, n do
        table.insert(state.particles, new_particle())
    end
end

-- ─── Problem generation ───────────────────────────────────────────────────────
local function generate_problem(score)
    -- Level increases every 5 points; caps at level 10
    local level = math.min(math.floor(score / 5) + 1, 10)

    -- Operand range grows with level
    local max_a = 5  + level * 5   -- 10..55
    local max_b = 3  + level * 3   -- 6..33

    -- Available operations: +, -, *  (division excluded per spec)
    local ops
    if level <= 2 then
        ops = { "+" }
    elseif level <= 4 then
        ops = { "+", "-" }
    else
        ops = { "+", "-", "*" }
    end

    local op  = ops[love.math.random(#ops)]
    local a, b, answer, text

    if op == "+" then
        a      = love.math.random(1, max_a)
        b      = love.math.random(1, max_b)
        answer = a + b
        text   = a .. " + " .. b .. " = ?"
    elseif op == "-" then
        a      = love.math.random(1, max_a)
        b      = love.math.random(1, math.min(a, max_b))  -- b <= a → answer >= 0
        answer = a - b
        text   = a .. " - " .. b .. " = ?"
    else  -- "*"
        -- Keep multiplication reasonable for children
        local max_m = math.min(level, 12)
        a      = love.math.random(1, max_m)
        b      = love.math.random(1, max_m)
        answer = a * b
        text   = a .. " × " .. b .. " = ?"
    end

    return { text = text, answer = answer }
end

-- ─── Submit answer (shared by Enter key and timer expiry) ─────────────────────
local function submit_answer()
    local correct

    if state.input == "" then
        correct = false
    else
        local typed = tonumber(state.input)
        correct = (typed == state.problem.answer)
    end

    if correct then
        state.score = state.score + 1
        state.feedback = { color = { 0.2, 0.9, 0.3 }, timer = FEEDBACK_DUR }
        love.audio.play(state.sfx_correct)
    else
        state.lives = state.lives - 1
        state.feedback = { color = { 0.9, 0.2, 0.2 }, timer = FEEDBACK_DUR }
        love.audio.play(state.sfx_wrong)
    end

    if state.lives <= 0 then
        state.mode = "gameover"
    end

    -- Clear input and generate next problem regardless (even on gameover the
    -- buffer should be clean for a potential restart)
    state.input   = ""
    state.timer   = TIMER_MAX
    state.problem = generate_problem(state.score)
end

-- ─── Game.load ────────────────────────────────────────────────────────────────
function Game.load()
    -- Fonts (scale default font via newFont with size)
    font_huge   = love.graphics.newFont(72)
    font_large  = love.graphics.newFont(56)
    font_medium = love.graphics.newFont(40)
    font_small  = love.graphics.newFont(28)

    -- Audio
    state.sfx_correct = love.audio.newSource("correct.wav", "static")
    state.sfx_wrong   = love.audio.newSource("wrong.ogg",   "static")

    -- Initial game state
    state.mode     = "title"
    state.score    = 0
    state.lives    = MAX_LIVES
    state.input    = ""
    state.timer    = TIMER_MAX
    state.feedback = nil
    state.problem  = generate_problem(0)

    -- Particles
    state.particles      = {}
    state.particle_accum = 0
    spawn_particles(PARTICLE_COUNT)
end

-- ─── Game.update ──────────────────────────────────────────────────────────────
function Game.update(dt)
    -- ── Particle update ──────────────────────────────────────────────────────
    local alive = {}
    for _, p in ipairs(state.particles) do
        p.x    = p.x + p.dx * dt
        p.y    = p.y + p.dy * dt
        p.life = p.life - dt

        if p.life > 0 then
            -- Fade in for first 20% of life, fade out for last 20%
            local frac = p.life / p.max_life
            if frac > 0.8 then
                p.alpha = (1 - frac) / 0.2 * 0.7
            elseif frac < 0.2 then
                p.alpha = frac / 0.2 * 0.7
            else
                p.alpha = 0.7
            end
            table.insert(alive, p)
        end
    end
    state.particles = alive

    -- Spawn new particles at steady rate
    state.particle_accum = state.particle_accum + PARTICLE_SPAWN_RATE * dt
    while state.particle_accum >= 1 do
        table.insert(state.particles, new_particle())
        state.particle_accum = state.particle_accum - 1
    end

    -- ── Feedback timer ───────────────────────────────────────────────────────
    if state.feedback then
        state.feedback.timer = state.feedback.timer - dt
        if state.feedback.timer <= 0 then
            state.feedback = nil
        end
    end

    -- ── Problem timer (playing mode only) ────────────────────────────────────
    if state.mode == "playing" then
        state.timer = state.timer - dt
        if state.timer <= 0 then
            state.timer = 0
            submit_answer()
        end
    end
end

-- ─── Drawing helpers ──────────────────────────────────────────────────────────
local function draw_particles()
    for _, p in ipairs(state.particles) do
        love.graphics.setColor(p.r, p.g, p.b, p.alpha)
        love.graphics.circle("fill", p.x, p.y, p.radius)
    end
end

local function draw_centered_text(font, text, y, r, g, b, a)
    love.graphics.setFont(font)
    love.graphics.setColor(r or 1, g or 1, b or 1, a or 1)
    local w = font:getWidth(text)
    love.graphics.print(text, (SCREEN_W - w) / 2, y)
end

local function draw_title_screen()
    draw_centered_text(font_huge,   "MATH QUEST",          220, 1.0, 0.85, 0.2)
    draw_centered_text(font_medium, "Press Enter to Start", 360, 0.9, 0.9,  1.0)
end

local function draw_gameover_screen()
    draw_centered_text(font_huge,   "GAME OVER",               200, 1.0, 0.3, 0.3)
    draw_centered_text(font_medium, "Final Score: " .. state.score, 320, 1.0, 1.0, 1.0)
    draw_centered_text(font_medium, "Press Enter to Restart",   410, 0.9, 0.9, 1.0)
end

local function draw_playing_screen()
    -- ── Score & Lives ─────────────────────────────────────────────────────────
    local lives_str = ""
    for i = 1, state.lives do
        lives_str = lives_str .. (i > 1 and "  " or "") .. "♥"
    end

    love.graphics.setFont(font_medium)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Score: " .. state.score, 40, 24)
    local lives_label = "Lives: " .. lives_str
    local lw = font_medium:getWidth(lives_label)
    love.graphics.print(lives_label, SCREEN_W - lw - 40, 24)

    -- ── Feedback flash overlay ────────────────────────────────────────────────
    if state.feedback then
        local fc = state.feedback.color
        local alpha = (state.feedback.timer / FEEDBACK_DUR) * 0.25
        love.graphics.setColor(fc[1], fc[2], fc[3], alpha)
        love.graphics.rectangle("fill", 0, 0, SCREEN_W, SCREEN_H)
    end

    -- ── Problem text ─────────────────────────────────────────────────────────
    draw_centered_text(font_large, state.problem.text, 260, 1.0, 1.0, 0.9)

    -- ── Input buffer ─────────────────────────────────────────────────────────
    local input_display = "[ " .. (state.input ~= "" and state.input or " ") .. " ]"
    draw_centered_text(font_medium, input_display, 370, 0.6, 1.0, 0.8)

    -- ── Timer bar ────────────────────────────────────────────────────────────
    local bar_w      = 400
    local bar_h      = 18
    local bar_x      = (SCREEN_W - bar_w) / 2
    local bar_y      = 470
    local frac       = math.max(0, state.timer / TIMER_MAX)

    -- Background track
    love.graphics.setColor(0.3, 0.3, 0.3, 0.8)
    love.graphics.rectangle("fill", bar_x, bar_y, bar_w, bar_h, 4, 4)

    -- Filled portion: green → yellow → red
    local r_bar = math.min(1, 2 * (1 - frac))
    local g_bar = math.min(1, 2 * frac)
    love.graphics.setColor(r_bar, g_bar, 0.1, 1)
    love.graphics.rectangle("fill", bar_x, bar_y, bar_w * frac, bar_h, 4, 4)

    -- Border
    love.graphics.setColor(0.6, 0.6, 0.6, 0.9)
    love.graphics.rectangle("line", bar_x, bar_y, bar_w, bar_h, 4, 4)
end

-- ─── Game.draw ────────────────────────────────────────────────────────────────
function Game.draw()
    -- Dark background
    love.graphics.clear(0.08, 0.08, 0.12, 1)

    -- Particle layer (behind everything)
    draw_particles()

    if state.mode == "title" then
        draw_title_screen()
    elseif state.mode == "playing" then
        draw_playing_screen()
    elseif state.mode == "gameover" then
        draw_gameover_screen()
    end

    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
end

-- ─── Game.keypressed ─────────────────────────────────────────────────────────
function Game.keypressed(key)
    if key == "minus" then
        -- Suppress minus/hyphen: consume event, do nothing
        return
    end

    if state.mode == "title" then
        if key == "return" or key == "kpenter" then
            state.mode    = "playing"
            state.score   = 0
            state.lives   = MAX_LIVES
            state.input   = ""
            state.timer   = TIMER_MAX
            state.feedback= nil
            state.problem = generate_problem(0)
        end

    elseif state.mode == "playing" then
        if key == "backspace" then
            if #state.input > 0 then
                state.input = state.input:sub(1, -2)
            end
        elseif key == "return" or key == "kpenter" then
            submit_answer()
        end

    elseif state.mode == "gameover" then
        if key == "return" or key == "kpenter" then
            state.mode    = "title"
            state.score   = 0
            state.lives   = MAX_LIVES
            state.input   = ""
            state.timer   = TIMER_MAX
            state.feedback= nil
            state.problem = generate_problem(0)
        end
    end
end

-- ─── Game.textinput ───────────────────────────────────────────────────────────
function Game.textinput(t)
    if state.mode ~= "playing" then return end
    -- Only accept digit characters
    if t:match("^%d$") then
        state.input = state.input .. t
    end
end

return Game
