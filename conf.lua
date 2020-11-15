function lovr.conf(t)
    -- t = {
    --     version = '0.14.0',
    --     identity = 'default',
    --     saveprecedence = true,
    --     modules = {
    --       audio = true,
    --       data = true,
    --       event = true,
    --       graphics = true,
    --       headset = true,
    --       math = true,
    --       physics = true,
    --       thread = true,
    --       timer = true
    --     },
    --     graphics = {
    --       debug = false
    --     },
    --     headset = {
    --       drivers = { 'openxr', 'oculus', 'vrapi', 'pico', 'openvr', 'webxr', 'desktop' },
    --       offset = 1.7,
    --       msaa = 4
    --     },
    --     math = {
    --       globals = true
    --     },
    --     window = {
    --       width = 1080,
    --       height = 600,
    --       fullscreen = false,
    --       resizable = true,
    --       msaa = 0,
    --       title = 'Little Neemit',
    --       icon = nil,
    --       vsync = 0
    --     }
    -- }
    t.window.width = 1280
    t.window.height = 720
    t.window.resizable = true 
    t.window.msaa = 0
    t.window.vsync = 0
    t.window.title = 'Little Neemit'

end