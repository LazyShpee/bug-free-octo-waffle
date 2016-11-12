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
   sprite = { -- this is temporarily hardcoded I swear
      name = "explosion", firstgid = 1,
      tilewidth = 96, tileheight = 96,
      spacing = 0, margin = 0,
      image = "explosion.png",
      imagewidth = 480,
      imageheight = 288,
      tileoffset = { x = 0, y = 0 },
      properties = {},
      terrains = {
	 {
	    name = "Nouveau terrain",
	    tile = -1,
	    properties = {}
	 }
      },
      tilecount = 16,
      tiles = {}
   }
   frame.widgets:insert(widgets.button(widgets.sprite(sprite)))
   frame.widgets:insert(widgets.button(widgets.sprite(deepcopy(sprite))))
   frame.widgets:insert(widgets.button(widgets.sprite(deepcopy(sprite))))
   frame.widgets:insert(widgets.button(widgets.sprite(deepcopy(sprite))))
end

function love.update(dt)
   frame = frame:update(dt)
end

function love.draw()
    love.graphics.push()
    love.graphics.scale(scale, scale)
    love.graphics.setBackgroundColor(100, 100, 100)
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
