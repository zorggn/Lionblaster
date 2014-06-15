function love.conf(t)
    t.identity = 'lionblaster'         -- The name of the save directory (string)
    t.version = "0.9.1"                -- The LÖVE version this game was made for (string)
    t.console = true                   -- Attach a console (boolean, Windows only)

    t.window = false                   -- Do not load the window module before we read in the user settings for window scaling
    --[[
    t.window.title = "LionBlaster"     -- The window title (string)
    t.window.icon = nil                -- Filepath to an image to use as the window's icon (string)
    t.window.width = 256               -- The window width (number)
    t.window.height = 224              -- The window height (number)
    t.window.borderless = false        -- Remove all border visuals from the window (boolean)
    t.window.resizable = false         -- Let the window be user-resizable (boolean)
    t.window.minwidth = 256            -- Minimum window width if the window is resizable (number)
    t.window.minheight = 224           -- Minimum window height if the window is resizable (number)
    t.window.fullscreen = false        -- Enable fullscreen (boolean)
    t.window.fullscreentype = "normal" -- Standard fullscreen or desktop fullscreen mode (string)
    t.window.vsync = false             -- Enable vertical sync (boolean)
    t.window.fsaa = 0                  -- The number of samples to use with multi-sampled antialiasing (number)
    t.window.display = 1               -- Index of the monitor to show the window in (number)
    --]]

    t.modules.audio = true             -- Enable the audio module (boolean)
    t.modules.event = true             -- Enable the event module (boolean)
    t.modules.graphics = true          -- Enable the graphics module (boolean)
    t.modules.image = true             -- Enable the image module (boolean)
    t.modules.joystick = true          -- Enable the joystick module (boolean)
    t.modules.keyboard = true          -- Enable the keyboard module (boolean)
    t.modules.math = true              -- Enable the math module (boolean)

    -- until i can move a borderless window via dragging, this stays off
    t.modules.mouse = false            -- Enable the mouse module (boolean)

    t.modules.physics = false          -- Enable the physics module (boolean)
    t.modules.sound = true             -- Enable the sound module (boolean)
    t.modules.system = true            -- Enable the system module (boolean)
    t.modules.timer = true             -- Enable the timer module (boolean)
    t.modules.window = true            -- Enable the window module (boolean)
end