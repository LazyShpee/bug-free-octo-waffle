require("lib/AnAL")		-- anal complement to love

const = require("const")	-- global constants variables

la = require("lib/la")		-- lazyapi complement to lua
require("lib/utils")		-- ironapi complement to lua

frames = require("frames")	-- frame based engine complement to love
widgets = require("widgets")	-- widget complement to frames
local newScroller = require('scroller')
access = { game = require('gameplay') }
scale = 1			-- adapt to high resolutions

local frame = {}

function love.load()
   local width, height = love.window.getDesktopDimensions()
   scale = 1
   while width > const.width * (scale + 1) or height > const.height * (scale + 1) do
      scale = scale + 1
   end
   print(width, const.width, const.width * scale)
   print(height, const.height, const.height * scale)
   love.graphics.setDefaultFilter("nearest")
   love.window.setMode(const.width * scale, const.height * scale)
   love.window.setTitle(const.title)

   access.menu = frames.menu()
   local bg, start, pimp, leave = unpack(require("assets/MENU_PRINCIPAL").tilesets)
   local startf = function(self) return access.game end
   access.menu.widgets:insert(widgets.button(widgets.sprite(bg)), ghost)
   access.menu.widgets:insert(widgets.button(widgets.sprite(start)), startf)
   access.menu.widgets:insert(widgets.button(widgets.sprite(pimp)), ghost)
   access.menu.widgets:insert(widgets.button(widgets.sprite(leave)), function() love.event.quit() end)
   frame = access.menu

   -- OMG ICI JE LOAD LE MENU GAME OVER MAIS FAUT METTRE LE .LUA DES ENTITIES
   local entities = require("assets/GAME_OVER_MENU").tilesets
   for _, v in ipairs(entities) do
      widgets.sprite(v)
   end
   local callback = function(self, name)
      for _, v in ipairs(self) do
	 if v.name == name then
	    return deepcopy(v)
	 end
      end
   end
   addToMetatable(entities, "__index", callback)
   access.game.init(entities)

   access.lose = frames.menu()
   local bg, retry, pimp, menu = unpack(require("assets/GAME_OVER_MENU").tilesets)
   local retryf = function(self) return access.game end
   local menuf = function(self) return access.menu end
   access.lose.widgets:insert(widgets.button(widgets.sprite(bg)))
   access.lose.widgets:insert(widgets.button(widgets.sprite(retry)), retryf)
   access.lose.widgets:insert(widgets.button(widgets.sprite(pimp)), ghost)
   access.lose.widgets:insert(widgets.button(widgets.sprite(menu)), menuf)
end

function love.update(dt)
    frame = frame:update(dt) or frame
end

function love.draw()
    love.graphics.push()
    -- love.graphics.scale(scale)
    frame:draw()
    love.graphics.pop()
end

function love.keypressed(...)
    if (frame.keypressed) then
        frame = frame:keypressed(...) or frame
    end
end

function love.keyreleased(...)
    if (frame.keyreleased) then
        frame = frame:keyreleased(...) or frame
    end
end
