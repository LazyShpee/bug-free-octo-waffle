require('lib/AnAL')
const = require('const')
require('utils')
local menu = require('menu')
local gameplay = require('gameplay')

local frame = {}

function love.load()
   frame = gameplay:new();
end

function love.update(dt)
   frame:update(dt)
end

function love.draw()
   frame:draw()
end

function love.keypressed(key, scancode, isrepeat)
   frame.keys[getIndex(scancode)] = const.keydown + int(isrepeat)
   -- should be const.keydown or const.keyrepeat
end

function love.keyreleased(key, scancode)
   frame.keys[getIndex(scancode)] = const.keyup
end
