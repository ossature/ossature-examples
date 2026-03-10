local Game = {}

-- Window dimensions
local W = 1280
local H = 720

-- Internal state
local state

-- Fonts
local font_problem  -- 48px for problem text
local font_input    -- 36px for input text
local font_title    -- 64px for titles
local font_ui       -- 28px for score/lives/timer

-- Particle colors: soft colors with saturation <= 0.7, lightness 0.4-0.9 (HSL)
-- Pre-converted to RGB
local PARTICLE_COLORS = {
    {0.6, 0.8, 1.0},   -- light blue
    {1.0, 0.7, 0.7},   -- soft pink
    {0.7, 1.0, 0.7},   -- soft green
    {1.0, 0.9, 0.6},   -- soft yellow
    {0.8, 0.7, 1.0},   -- soft purple
    {1.0, 0.8, 0.6},   -- soft orange
    {0.6, 1.0, 0.9},   -- soft teal
}

-- Track if minus was pressed this frame (to suppress in textinput)
local suppress_textinput = false

---------------------------------------------------------------------------
-- Particle helpers
---------------------------------------------------------------------------

local function spawn_particle()
    local col = PARTICLE_COLORS[math.random(#PARTICLE_COLORS)]
    local max_life = 3 + math.random() * 4  -- 3-7 seconds
    return {
        x = math.random() * W,
        y = math.random() * H,
        dx = (math.random() * 60 - 30),  -- -30 to 30 px/s
        dy = (math.random() * 60 - 30),
        r = col[1], g = col[2], b = col[3],
        alpha = 0.0,
        life = max_life,
        max_life = max_life,
        radius = 2 + math.random() * 4,
    }
end

local function update_particles(dt)
    -- Spawn new particles at a steady rate (~10/sec)
    local spawn_count = dt * 10
    -- Use accumulator approach: fractional spawning
    state.particle_accum = (state.particle_accum or 0) + spawn_count
    while state.particle_accum >= 1 do
        state.particle_accum = state.particle_accum - 1
        table.insert(state.particles, spawn_particle())
    end

    -- Update existing particles
    local i = 1
    while i <= #state.particles do
        local p = state.particles[i]
        p.life = p.life - dt
        if p.life <= 0 then
            -- Remove dead particle (swap with last)
            state.particles[i] = state.particles[#state.particles]
            state.particles[#state.particles] = nil
        else
            p.x = p.x + p.dx * dt
            p.y = p.y + p.dy * dt

            -- Wrap around screen edges
            if p.x < -10 then p.x = W + 10 end
            if p.x > W + 10 then p.x = -10 end
            if p.y < -10 then p.y = H + 10 end
            if p.y > H + 10 then p.y = -10 end

            -- Fade in/out based on life ratio
            local ratio = p.life / p.max_life
            if ratio > 0.8 then
                -- Fading in (last 20% of max_life = first 20% of actual time)
                p.alpha = (1.0 - ratio) / 0.2 * 0.5
            elseif ratio < 0.2 then
                -- Fading out
                p.alpha = ratio / 0.2 * 0.5
            else
                p.alpha = 0.5
            end

            i = i + 1
        end
    end
end

local function draw_particles()
    for _, p in ipairs(state.particles) do
        love.graphics.setColor(p.r, p.g, p.b, p.alpha)
        love.graphics.circle("fill", p.x, p.y, p.radius)
    end
end

---------------------------------------------------------------------------
-- Problem generation
---------------------------------------------------------------------------

local function get_level(score)
    -- Level increases every 5 points
    return math.floor(score / 5) + 1
end

local function generate_problem(score)
    local level = get_level(score)

    -- Determine max operand range based on level
    local max_val
    if level <= 1 then
        max_val = 10
    elseif level <= 2 then
        max_val = 20
    elseif level <= 3 then
        max_val = 50
    else
        max_val = 100
    end

    -- Determine available operations based on level
    local ops = {"+"}
    if level >= 2 then
        ops[#ops + 1] = "-"
    end
    if level >= 3 then
        ops[#ops + 1] = "*"
    end

    local op = ops[math.random(#ops)]
    local a, b, answer

    if op == "+" then
        a = math.random(1, max_val)
        b = math.random(1, max_val)
        answer = a + b
    elseif op == "-" then
        a = math.random(1, max_val)
        b = math.random(1, a) -- ensure a >= b for non-negative result
        answer = a - b
    elseif op == "*" then
        -- Keep multiplication operands smaller
        local mult_max = math.min(max_val, 12)
        a = math.random(1, mult_max)
        b = math.random(1, mult_max)
        answer = a * b
    end

    return {
        text = a .. " " .. op .. " " .. b .. " = ?",
        answer = answer,
    }
end

---------------------------------------------------------------------------
-- State management
---------------------------------------------------------------------------

local function init_state()
    state = {
        mode = "title",
        score = 0,
        lives = 3,
        problem = nil,
        input = "",
        timer = 10.0,
        feedback = nil,
        particles = {},
        particle_accum = 0,
        sfx_correct = nil,
        sfx_wrong = nil,
    }

    -- Pre-populate some particles so the screen isn't empty at start
    for _ = 1, 50 do
        local p = spawn_particle()
        -- Randomize their life so they're at various stages
        p.life = math.random() * p.max_life
        local ratio = p.life / p.max_life
        if ratio > 0.8 then
            p.alpha = (1.0 - ratio) / 0.2 * 0.5
        elseif ratio < 0.2 then
            p.alpha = ratio / 0.2 * 0.5
        else
            p.alpha = 0.5
        end
        table.insert(state.particles, p)
    end
end

local function start_game()
    state.mode = "playing"
    state.score = 0
    state.lives = 3
    state.input = ""
    state.feedback = nil
    state.problem = generate_problem(0)
    state.timer = 10.0
end

local function submit_answer()
    local correct = false

    if state.input ~= "" then
        local player_answer = tonumber(state.input)
        if player_answer and player_answer == state.problem.answer then
            correct = true
        end
    end
    -- Empty input is treated as incorrect

    if correct then
        state.score = state.score + 1
        state.feedback = { color = {0, 0.8, 0}, timer = 0.5 }  -- green
        state.sfx_correct:stop()
        love.audio.play(state.sfx_correct)
    else
        state.lives = state.lives - 1
        state.feedback = { color = {0.8, 0, 0}, timer = 0.5 }  -- red
        state.sfx_wrong:stop()
        love.audio.play(state.sfx_wrong)
    end

    -- Clear input before next problem
    state.input = ""

    -- Check for game over
    if state.lives <= 0 then
        state.mode = "gameover"
        return
    end

    -- Generate next problem
    state.problem = generate_problem(state.score)
    state.timer = 10.0
end

---------------------------------------------------------------------------
-- Game module functions
---------------------------------------------------------------------------

function Game.load()
    math.randomseed(os.time())

    init_state()

    -- Load fonts
    font_problem = love.graphics.newFont(48)
    font_input = love.graphics.newFont(36)
    font_title = love.graphics.newFont(64)
    font_ui = love.graphics.newFont(28)

    -- Load sound effects
    state.sfx_correct = love.audio.newSource("correct.wav", "static")
    state.sfx_wrong = love.audio.newSource("wrong.ogg", "static")
end

function Game.update(dt)
    -- Always update particles
    update_particles(dt)

    -- Reset suppress flag each frame
    suppress_textinput = false

    -- Update feedback flash timer
    if state.feedback then
        state.feedback.timer = state.feedback.timer - dt
        if state.feedback.timer <= 0 then
            state.feedback = nil
        end
    end

    -- Update game timer during playing state
    if state.mode == "playing" then
        state.timer = state.timer - dt
        if state.timer <= 0 then
            state.timer = 0
            -- Timer expired: auto-submit
            submit_answer()
        end
    end
end

function Game.draw()
    -- Dark background
    love.graphics.clear(0.1, 0.1, 0.15, 1)

    -- Draw particles behind everything
    draw_particles()

    -- Feedback flash overlay
    if state.feedback then
        local c = state.feedback.color
        local alpha = (state.feedback.timer / 0.5) * 0.25
        love.graphics.setColor(c[1], c[2], c[3], alpha)
        love.graphics.rectangle("fill", 0, 0, W, H)
    end

    -- Draw state-specific UI
    if state.mode == "title" then
        Game.draw_title()
    elseif state.mode == "playing" then
        Game.draw_playing()
    elseif state.mode == "gameover" then
        Game.draw_gameover()
    end

    love.graphics.setColor(1, 1, 1, 1)
end

function Game.draw_title()
    -- Title
    love.graphics.setFont(font_title)
    love.graphics.setColor(1, 1, 0.3, 1)
    local title = "MATH QUEST"
    local tw = font_title:getWidth(title)
    love.graphics.print(title, (W - tw) / 2, H / 2 - 80)

    -- Subtitle
    love.graphics.setFont(font_input)
    love.graphics.setColor(1, 1, 1, 0.8)
    local sub = "Press Enter to Start"
    local sw = font_input:getWidth(sub)
    love.graphics.print(sub, (W - sw) / 2, H / 2 + 20)
end

function Game.draw_playing()
    -- Score and Lives
    love.graphics.setFont(font_ui)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Score: " .. state.score, 40, 30)

    -- Lives as hearts/Xs
    local lives_str = "Lives: "
    for i = 1, state.lives do
        lives_str = lives_str .. "♥ "
    end
    local lw = font_ui:getWidth(lives_str)
    love.graphics.setColor(1, 0.3, 0.3, 1)
    love.graphics.print(lives_str, W - lw - 40, 30)

    -- Problem text
    love.graphics.setFont(font_problem)
    love.graphics.setColor(1, 1, 1, 1)
    local pt = state.problem.text
    local ptw = font_problem:getWidth(pt)
    love.graphics.print(pt, (W - ptw) / 2, H / 2 - 80)

    -- Input display
    love.graphics.setFont(font_input)
    love.graphics.setColor(0.8, 0.9, 1.0, 1)
    local input_display = "[ " .. state.input .. " ]"
    local iw = font_input:getWidth(input_display)
    love.graphics.print(input_display, (W - iw) / 2, H / 2 + 10)

    -- Timer bar
    local bar_width = 400
    local bar_height = 20
    local bar_x = (W - bar_width) / 2
    local bar_y = H / 2 + 80
    local fill_ratio = math.max(0, state.timer / 10.0)

    -- Background
    love.graphics.setColor(0.3, 0.3, 0.3, 1)
    love.graphics.rectangle("fill", bar_x, bar_y, bar_width, bar_height, 4, 4)

    -- Fill
    local fill_r, fill_g, fill_b
    if fill_ratio > 0.5 then
        fill_r, fill_g, fill_b = 0.2, 0.8, 0.2
    elseif fill_ratio > 0.25 then
        fill_r, fill_g, fill_b = 0.9, 0.7, 0.1
    else
        fill_r, fill_g, fill_b = 0.9, 0.2, 0.2
    end
    love.graphics.setColor(fill_r, fill_g, fill_b, 1)
    love.graphics.rectangle("fill", bar_x, bar_y, bar_width * fill_ratio, bar_height, 4, 4)
end

function Game.draw_gameover()
    -- Game Over title
    love.graphics.setFont(font_title)
    love.graphics.setColor(1, 0.3, 0.3, 1)
    local go = "GAME OVER"
    local gow = font_title:getWidth(go)
    love.graphics.print(go, (W - gow) / 2, H / 2 - 100)

    -- Final score
    love.graphics.setFont(font_problem)
    love.graphics.setColor(1, 1, 1, 1)
    local fs = "Final Score: " .. state.score
    local fsw = font_problem:getWidth(fs)
    love.graphics.print(fs, (W - fsw) / 2, H / 2 - 10)

    -- Restart prompt
    love.graphics.setFont(font_input)
    love.graphics.setColor(1, 1, 1, 0.8)
    local rs = "Press Enter to Restart"
    local rsw = font_input:getWidth(rs)
    love.graphics.print(rs, (W - rsw) / 2, H / 2 + 70)
end

function Game.keypressed(key)
    if key == "minus" then
        -- Consume minus key, set flag to suppress textinput
        suppress_textinput = true
        return true
    end

    if state.mode == "title" then
        if key == "return" or key == "kpenter" then
            start_game()
        end
    elseif state.mode == "playing" then
        if key == "return" or key == "kpenter" then
            submit_answer()
        elseif key == "backspace" then
            state.input = state.input:sub(1, -2)
        end
    elseif state.mode == "gameover" then
        if key == "return" or key == "kpenter" then
            start_game()
        end
    end
end

function Game.textinput(t)
    -- Suppress if minus was pressed this frame
    if suppress_textinput then
        return
    end

    if state.mode == "playing" then
        -- Only accept digits 0-9
        if t:match("^%d$") then
            state.input = state.input .. t
        end
    end
end

return Game
