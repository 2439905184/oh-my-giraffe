function love.conf(t)
    --io.stdout:setvbuf("no")
    t.window.orientations = {
        portrait = false,
        portraitupsidedown = false,
        landscapeleft = true,
        landscaperight = true,
    }
    t.identity = "giraffe"
    t.version = "0.9.1"
    t.console = false
    t.window.title = "oh my giraffe"
    t.window.icon = nil
    t.window.width = 1024
    t.window.height = 640
    t.window.borderless = false
    t.window.fullscreen = false
    t.window.immersive = false
    t.window.vsync = true
    t.window.fsaa = 0
    t.window.display = 1
    t.window.highdpi = true
    t.modules.audio = true
    t.modules.event = true
    t.modules.graphics = true
    t.modules.image = true
    t.modules.joystick = false
    t.modules.keyboard = true
    t.modules.math = true
    t.modules.mouse = true
    t.modules.physics = false
    t.modules.sound = true
    t.modules.system = true
    t.modules.timer = true
    t.modules.window = true
    t.modules.thread = true
end
