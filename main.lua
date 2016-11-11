require('lib/AnAL')		-- anal complement to love

const = require('const')	-- global constants variables

la = require('LuW4ENiF')	-- lazyapi complement to lua
u = require('utils')		-- ironapi complement to lua

frames = require('frames')	-- frame based engine complement to love
widgets = require('widgets')	-- widget complement to frames
local frame = {}

function love.load()
   frame = frames.menu()
   sprite = { -- this is temporary hardcoded I swear
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
   table.insert(frame.widgets, widgets.button(widgets.sprite(sprite)))
end

function love.update(dt)
   frame = frame:update(dt)
end

function love.draw()
   frame:draw()
end

function love.keypressed(_, scancode, isrepeat)
   print(scancode)
   for i, v in pairs(frame.keys) do print(i, v) end
   frame.keys[getIndex(scancode)] = const.keydown + int(isrepeat)
   print()
   for i, v in pairs(frame.keys) do print(i, v) end
end

function love.keyreleased(_, scancode)
   print(scancode)
   for i, v in pairs(frame.keys) do print(i, v) end
   frame.keys[getIndex(scancode)] = const.keyup
   print()
   for i, v in pairs(frame.keys) do print(i, v) end
end
