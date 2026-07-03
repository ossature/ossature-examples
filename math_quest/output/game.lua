local Game = {}

-- Local state variables as dictated by architecture guidelines
local state = {
    mode = "title",        -- "title" | "playing" | "gameover"
    score = 0,
    lives = 3,
    problem = {            -- Current problem
        text = "",
        answer = 0,
    },
    input = "",            -- Player's typed digits
    timer = 10.0,          -- Seconds remaining
    feedback = nil,        -- { r=r, g=g, b=b, timer=0.5, type="correct"|"wrong" } or nil
    particles = {},        -- List of background particle tables
    sfx_correct = nil,     -- love.audio.Source
    sfx_wrong = nil,       -- love.audio.Source
}

-- Expose state table reference to external modules
Game.state = state

-- Fonts cache
local fonts = {}

-- Utility: HSL to RGB conversion helper (returns values in range [0, 1])
local function hsl_to_rgb(h, s, l)
    local c = (1 - math.abs(2 * l - 1)) * s
    local x = c * (1 - math.abs((h / 60) % 2 - 1))
    local m = l - c / 2
    local r, g, b = 0, 0, 0
    if 0 <= h and h < 60 then
        r, g, b = c, x, 0
    elseif 60 <= h and h < 120 then
        r, g, b = x, c, 0
    elseif 120 <= h and h < 180 then
        r, g, b = 0, c, x
    elseif 180 <= h and h < 240 then
        r, g, b = 0, x, c
    elseif 240 <= h and h < 300 then
        r, g, b = x, 0, c
    elseif 300 <= h and h < 360 then
        r, g, b = c, 0, x
    end
    return r + m, g + m, b + m
end

-- Utility: Spawn a single particle
local function spawn_particle(init_random_life)
    local max_life = love.math.random(8, 15)
    local life = init_random_life and (love.math.random() * max_life) or max_life
    local angle = love.math.random() * math.pi * 2
    local speed = love.math.random(10, 40) -- slow drift velocity in pixels/sec
    
    -- Generate soft decorative colors (saturation <= 0.7, lightness [0.4, 0.9])
    local h = love.math.random(0, 359)
    local s = love.math.random(30, 70) / 100
    local l = love.math.random(40, 90) / 100
    local r, g, b = hsl_to_rgb(h, s, l)
    
    table.insert(state.particles, {
        x = love.math.random(0, 1280),
        y = love.math.random(0, 720),
        dx = math.cos(angle) * speed,
        dy = math.sin(angle) * speed,
        r = r, g = g, b = b,
        alpha = 0,                 -- Starts at 0, faded in dynamically
        life = life,
        max_life = max_life,
        radius = love.math.random(2, 6),
    })
end

-- Utility: Progressive arithmetic generator based on player's current score
local function generate_problem(score)
    local op = "+"
    local a, b = 0, 0
    
    if score < 5 then
        -- Level 1: Single digit additions (1 to 9)
        a = love.math.random(1, 9)
        b = love.math.random(1, 9)
        op = "+"
    elseif score < 10 then
        -- Level 2: Two-digit addition or subtraction
        local choice = love.math.random(1, 2)
        if choice == 1 then
            a = love.math.random(10, 30)
            b = love.math.random(1, 15)
            op = "+"
        else
            a = love.math.random(10, 30)
            b = love.math.random(1, a) -- Guaranteed non-negative result
            op = "-"
        end
    elseif score < 15 then
        -- Level 3: Mix of Addition, Subtraction, and Single-digit Multiplication
        local choice = love.math.random(1, 3)
        if choice == 1 then
            a = love.math.random(2, 9)
            b = love.math.random(2, 9)
            op = "x"
        elseif choice == 2 then
            a = love.math.random(15, 60)
            b = love.math.random(10, 50)
            op = "+"
        else
            a = love.math.random(15, 60)
            b = love.math.random(1, a) -- Guaranteed non-negative result
            op = "-"
        end
    else
        -- Level 4: Complex Addition, Subtraction, Multiplication range [2-12], or Division
        local choice = love.math.random(1, 4)
        if choice == 1 then
            a = love.math.random(15, 99)
            b = love.math.random(15, 99)
            op = "+"
        elseif choice == 2 then
            a = love.math.random(15, 99)
            b = love.math.random(1, a) -- Guaranteed non-negative result
            op = "-"
        elseif choice == 3 then
            a = love.math.random(2, 12)
            b = love.math.random(2, 12)
            op = "x"
        else
            -- Division designed to never have remainder
            b = love.math.random(2, 11)
            local quotient = love.math.random(2, 10)
            a = quotient * b
            op = "/"
        end
    end

    local text = ""
    local answer = 0
    if op == "+" then
        text = string.format("%d + %d", a, b)
        answer = a + b
    elseif op == "-" then
        text = string.format("%d - %d", a, b)
        answer = a - b
    elseif op == "x" then
        text = string.format("%d x %d", a, b)
        answer = a * b
    elseif op == "/" then
        text = string.format("%d / %d", a, b)
        answer = a / b
    end

    return { text = text, answer = answer }
end

-- Utility: Play audio safely via a clone or restart mechanism
local function play_sound(source)
    if source then
        local success, clone = pcall(function() return source:clone() end)
        if success and clone then
            clone:play()
        else
            source:play()
        end
    end
end

-- Utility: Submit current buffer or process time expiry
local function evaluate_submission(is_expiry)
    local ans = tonumber(state.input)
    local is_correct = false
    
    if ans ~= nil then
        is_correct = (ans == state.problem.answer)
    end

    if is_correct then
        state.score = state.score + 1
        play_sound(state.sfx_correct)
        state.feedback = { r = 0.1, g = 0.8, b = 0.1, timer = 0.5, type = "correct" }
    else
        state.lives = state.lives - 1
        play_sound(state.sfx_wrong)
        state.feedback = { r = 0.8, g = 0.1, b = 0.1, timer = 0.5, type = "wrong" }
    end

    if state.lives <= 0 then
        state.mode = "gameover"
        state.feedback = nil -- Clear feedback overlay if we transition directly to gameover
    end
end

-- Utility: Start/Initiate a new gameplay loop
local function start_game()
    state.score = 0
    state.lives = 3
    state.input = ""
    state.feedback = nil
    state.timer = 10.0
    state.problem = generate_problem(0)
    state.mode = "playing"
end

-- Exported LÖVE callbacks

function Game.load()
    -- Initialize state characteristics
    state.mode = "title"
    state.score = 0
    state.lives = 3
    state.input = ""
    state.timer = 10.0
    state.feedback = nil
    state.particles = {}

    -- Load built-in default font scaled up appropriately
    fonts.title = love.graphics.newFont(64)
    fonts.problem = love.graphics.newFont(48)
    fonts.input = love.graphics.newFont(36)
    fonts.ui = love.graphics.newFont(24)

    -- Pre-populate continuous background particles with randomized lifespans
    for i = 1, 80 do
        spawn_particle(true)
    end

    -- Attempt to load SFX assets
    local ok_correct, correct_src = pcall(love.audio.newSource, "correct.wav", "static")
    if ok_correct then
        state.sfx_correct = correct_src
    end

    local ok_wrong, wrong_src = pcall(love.audio.newSource, "wrong.ogg", "static")
    if ok_wrong then
        state.sfx_wrong = wrong_src
    end
end

function Game.update(dt)
    -- 1. Continuous Background Particle Updates (Must run independent of screen mode or flash pauses)
    for i = #state.particles, 1, -1 do
        local p = state.particles[i]
        p.life = p.life - dt
        if p.life <= 0 then
            table.remove(state.particles, i)
        else
            p.x = p.x + p.dx * dt
            p.y = p.y + p.dy * dt
            
            -- Keep boundary within viewport limits (wrap gently if needed, or rely on normal lifespans)
            if p.x < -20 then p.x = 1300 end
            if p.x > 1300 then p.x = -20 end
            if p.y < -20 then p.y = 740 end
            if p.y > 740 then p.y = -20 end

            -- Soft fade in/out alpha calculations
            local elapsed = p.max_life - p.life
            local alpha = 0.5
            if elapsed < 1.0 then
                alpha = alpha * (elapsed / 1.0)
            elseif p.life < 1.0 then
                alpha = alpha * (p.life / 1.0)
            end
            p.alpha = alpha
        end
    end

    -- Keep total background particles populated to 80
    while #state.particles < 80 do
        spawn_particle(false)
    end

    -- 2. Gameplay state update
    if state.mode == "playing" then
        if state.feedback then
            -- Pause countdown timer and updates during the feedback flash
            state.feedback.timer = state.feedback.timer - dt
            if state.feedback.timer <= 0 then
                state.feedback = nil
                state.input = ""
                state.problem = generate_problem(state.score)
                state.timer = 10.0
            end
        else
            -- Process the 10-second countdown timer standardly
            state.timer = state.timer - dt
            if state.timer <= 0 then
                evaluate_submission(true)
            end
        end
    end
end

function Game.draw()
    -- Clear surface with a sleek near-black background
    love.graphics.clear(0.06, 0.06, 0.08)

    -- Draw continuous animated background particles
    for _, p in ipairs(state.particles) do
        love.graphics.setColor(p.r, p.g, p.b, p.alpha)
        love.graphics.circle("fill", p.x, p.y, p.radius)
    end

    -- Draw interfaces depending on state pattern
    if state.mode == "title" then
        -- Title Rendering
        love.graphics.setFont(fonts.title)
        love.graphics.setColor(1, 0.85, 0.3) -- Golden title color
        love.graphics.printf("MATH QUEST", 0, 150, 1280, "center")

        love.graphics.setFont(fonts.ui)
        love.graphics.setColor(0.9, 0.9, 0.9)
        love.graphics.printf("Test your arithmetic speed and mathematical limits!", 0, 260, 1280, "center")
        love.graphics.printf("Complete dynamically escalating addition, subtraction, multiplication & division problems.", 0, 300, 1280, "center")
        love.graphics.printf("A wrong answer or a 10s countdown expiry costs 1 life. You have 3 lives total.", 0, 340, 1280, "center")
        love.graphics.printf("Input numbers with number keys, use Backspace to edit, and press Enter to submit.", 0, 380, 1280, "center")

        love.graphics.setFont(fonts.problem)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Press [ ENTER ] to Start!", 0, 480, 1280, "center")

    elseif state.mode == "playing" then
        -- Gameplay Hud Rendering
        love.graphics.setFont(fonts.ui)
        love.graphics.setColor(0.9, 0.9, 0.9)
        love.graphics.printf("SCORE: " .. state.score, 50, 30, 400, "left")
        love.graphics.printf("LIVES: " .. state.lives .. " / 3", -50, 30, 1280, "right")

        -- Timer Bar Graphic
        love.graphics.setColor(0.15, 0.15, 0.2, 0.8)
        love.graphics.rectangle("fill", 390, 80, 500, 16)
        
        local timer_ratio = math.max(0, math.min(1, state.timer / 10.0))
        local tb_r, tb_g, tb_b = 0.2, 0.8, 0.2
        if timer_ratio < 0.3 then
            tb_r, tb_g, tb_b = 0.8, 0.2, 0.2
        elseif timer_ratio < 0.6 then
            tb_r, tb_g, tb_b = 0.8, 0.8, 0.2
        end
        love.graphics.setColor(tb_r, tb_g, tb_b, 0.9)
        love.graphics.rectangle("fill", 390, 80, 500 * timer_ratio, 16)

        -- Digital seconds printout
        love.graphics.setFont(fonts.ui)
        love.graphics.setColor(0.9, 0.9, 0.9)
        love.graphics.printf(string.format("%.1fs", state.timer), 0, 105, 1280, "center")

        -- Current mathematical challenge (font min 48px)
        love.graphics.setFont(fonts.problem)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(state.problem.text, 0, 260, 1280, "center")

        -- Current typed input buffer (font min 36px)
        love.graphics.setFont(fonts.input)
        love.graphics.setColor(0.9, 0.8, 0.3)
        love.graphics.printf("[ " .. state.input .. " ]", 0, 380, 1280, "center")

        -- 0.5s visual correct/incorrect feedback flash overlay
        if state.feedback then
            local flash_alpha = 0.35 * (state.feedback.timer / 0.5)
            love.graphics.setColor(state.feedback.r, state.feedback.g, state.feedback.b, flash_alpha)
            love.graphics.rectangle("fill", 0, 0, 1280, 720)
        end

    elseif state.mode == "gameover" then
        -- Game Over Screen Rendering
        love.graphics.setFont(fonts.title)
        love.graphics.setColor(0.9, 0.2, 0.2, 1)
        love.graphics.printf("GAME OVER", 0, 180, 1280, "center")

        love.graphics.setFont(fonts.problem)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf("Final Score: " .. state.score, 0, 310, 1280, "center")

        love.graphics.setFont(fonts.ui)
        love.graphics.setColor(0.5, 0.8, 1)
        love.graphics.printf("Press [ ENTER ] to Try Again!", 0, 440, 1280, "center")
    end
end

function Game.keypressed(key)
    if state.mode == "title" then
        if key == "return" or key == "kpenter" then
            start_game()
        end

    elseif state.mode == "playing" then
        -- Keypress editing inputs should be entirely ignored during the answer feedback flash
        if state.feedback then return end

        if key == "backspace" then
            state.input = string.sub(state.input, 1, -2)
        elseif key == "return" or key == "kpenter" then
            -- Submission ignored under empty buffer
            if state.input ~= "" then
                evaluate_submission(false)
            end
        end

    elseif state.mode == "gameover" then
        if key == "return" or key == "kpenter" then
            start_game()
        end
    end
end

function Game.textinput(t)
    -- Accept only digits for maths input buffer
    if state.mode ~= "playing" then return end
    if state.feedback then return end -- paused during visual feedback/flash animation

    if t:match("^%d$") then
        state.input = state.input .. t
    end
end

return Game
