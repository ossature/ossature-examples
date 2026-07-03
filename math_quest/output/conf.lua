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
