require('lib/AnAL')
const = require('const')
require('utils')
menu = require('menu')

local frame = {}

function love.load()
   local img  = love.graphics.newImage("explosion.png")
   anim = newAnimation(img, 96, 96, 0.1, 0)
   frame = menu.new();
end

function love.update(dt)
   frame.update(dt)
   -- Updates the animation. (Enables frame changes)
   anim:update(dt)
end

function love.draw()
   frame:draw()
   -- Draw the animation at (100, 100).
   anim:draw(100, 100)
end

function love.keypressed(key, scancode, isrepeat)
   frame.keys[getIndex(scancode)] = const.keydown + int(isrepeat)
   -- should be const.keydown or const.keyrepeat
end

function love.keyreleased(key, scancode)
   frame.keys[getIndex(scancode)] = const.keyup
end
