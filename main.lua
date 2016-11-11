require('lib/AnAL')
const = require('const')
require('utils')
local menu = require('menu')
gameplay = require('gameplay')

frameList = {}
local frame = {}
local keys = {}

function love.load()
   for i in pairs(const.keys) do
      keys[i] = 0
   end
   frameList.menu = menu:new()
   frame = frameList.menu
end

function love.update(dt)
   frame = frame:update(dt, keys)
end

function love.draw()
   frame:draw()
end

function debug(scancode)
   print(scancode)
   for i, v in pairs(keys) do print(i, v) end
   print()
end

function love.keypressed(_, scancode, isrepeat)
   debug(scancode)
   keys[getIndex(scancode)] = const.keydown + int(isrepeat)
   debug(scancode)
   -- should be const.keydown or const.keyrepeat
end

function love.keyreleased(_, scancode)
   debug(scancode)
   keys[getIndex(scancode)] = const.keyup
   debug(scancode)
end
