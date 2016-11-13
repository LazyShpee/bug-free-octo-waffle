require("lib/AnAL")		-- anal complement to love

const = require("const")	-- global constants variables

la = require("lib/la")	-- lazyapi complement to lua
u = require("lib/utils")		-- ironapi complement to lua
local newScroller = require('scroller')

local gameFrame = require('gameplay')
local frame = gameFrame

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
    gameFrame.init()
end

function love.update(dt)
    frame = frame:update(dt) or frame
end

function love.draw()
    frame:draw()
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
