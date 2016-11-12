require("lib/AnAL")		-- anal complement to love

const = require("const")	-- global constants variables

la = require("lib/la")	-- lazyapi complement to lua
u = require("lib/utils")		-- ironapi complement to lua

frames = require("frames")	-- frame based engine complement to love
widgets = require("widgets")	-- widget complement to frames
local frame = {}

scale = 1			-- adapt to high resolutions

function love.load()
   local width, height = love.window.getDesktopDimensions()
   if width >= const.width * 2 or height >= const.height * 2 then
      scale = 2
   end
   love.graphics.setDefaultFilter("nearest")
   love.window.setMode(const.width * scale, const.height * scale)
   love.window.setTitle(const.title)
   frame = frames.menu()
   assets = require("test").tilesets
   for _, sprite in ipairs(assets) do
      frame.widgets:insert(widgets.button(widgets.sprite(sprite)))
   end
end

function love.update(dt)
   frame = frame:update(dt)
end

function love.draw()
    love.graphics.push()
    love.graphics.scale(scale, scale)
    -- love.graphics.setBackgroundColor(100, 100, 100)
    frame:draw()
    love.graphics.pop()
end

function love.keypressed(_, scancode, isrepeat)
   -- print(scancode)
   -- for i, v in pairs(frame.keys) do print(i, v) end
   frame.keys[getIndex(scancode)] = const.keydown + int(isrepeat)
   -- print()
   -- for i, v in pairs(frame.keys) do print(i, v) end
end

function love.keyreleased(_, scancode)
   -- print(scancode)
   -- for i, v in pairs(frame.keys) do print(i, v) end
   frame.keys[getIndex(scancode)] = const.keyup
   -- print()
   -- for i, v in pairs(frame.keys) do print(i, v) end
end
