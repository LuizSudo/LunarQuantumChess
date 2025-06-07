-- conf.lua - LÖVE2D Configuration for Lunar Quantum Chess

function love.conf(t)
    -- Game identity
    t.identity = "lunar-quantum-chess"
    t.appendidentity = false
    t.version = "11.4"
    
    -- Console (Windows only)
    t.console = false
    
    -- Accelerometer (mobile devices)
    t.accelerometerjoystick = false
    
    -- Externally accessible files
    t.externally_accessible = false
    
    -- Game metadata
    t.gammacorrect = false
    
    -- Audio configuration
    t.audio.mic = false
    t.audio.mixwithsystem = true
    
    -- Window configuration
    t.window.title = "Lunar Quantum Chess"
    t.window.icon = nil
    t.window.width = 800
    t.window.height = 600
    t.window.borderless = false
    t.window.resizable = true
    t.window.minwidth = 640
    t.window.minheight = 480
    t.window.fullscreen = false
    t.window.fullscreentype = "desktop"
    t.window.vsync = 1
    t.window.msaa = 0
    t.window.depth = nil
    t.window.stencil = nil
    t.window.display = 1
    t.window.highdpi = false
    t.window.usedpiscale = true
    t.window.x = nil
    t.window.y = nil
    
    -- Modules to load
    t.modules.audio = true      -- Audio module (sound effects, music)
    t.modules.data = true       -- Data module (compression, base64)
    t.modules.event = true      -- Event module (required)
    t.modules.font = true       -- Font module (text rendering)
    t.modules.graphics = true   -- Graphics module (required for rendering)
    t.modules.image = true      -- Image module (loading images)
    t.modules.joystick = false  -- Joystick module (gamepad support)
    t.modules.keyboard = true   -- Keyboard module (required for input)
    t.modules.math = true       -- Math module (random, noise)
    t.modules.mouse = true      -- Mouse module (required for input)
    t.modules.physics = false   -- Physics module (Box2D - not needed)
    t.modules.sound = true      -- Sound module (audio playback)
    t.modules.system = true     -- System module (OS info, clipboard)
    t.modules.thread = true     -- Thread module (for networking)
    t.modules.timer = true      -- Timer module (deltaTime, FPS)
    t.modules.touch = false     -- Touch module (mobile devices)
    t.modules.video = false     -- Video module (not needed)
    t.modules.window = true     -- Window module (required)
end