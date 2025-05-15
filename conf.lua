function love.conf(t)
    t.title = "Color Swap Game"        -- The title of the window
    t.version = "11.3"                 -- The LÖVE version this game was made for
    t.window.width = 1280              -- Game window width
    t.window.height = 720              -- Game window height
    
    -- For debugging
    t.console = true                   -- Enable console output
    
    -- Modules
    t.modules.audio = true             -- Enable the audio module
    t.modules.graphics = true          -- Enable the graphics module
    t.modules.image = true             -- Enable the image module
    t.modules.keyboard = true          -- Enable the keyboard module
    t.modules.math = true              -- Enable the math module
    t.modules.mouse = true             -- Enable the mouse module
    t.modules.physics = false          -- Disable the physics module (not used)
    t.modules.sound = true             -- Enable the sound module
    t.modules.system = true            -- Enable the system module
    t.modules.timer = true             -- Enable the timer module
    t.modules.window = true            -- Enable the window module
end
