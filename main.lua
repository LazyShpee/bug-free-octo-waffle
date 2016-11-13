require("lib/AnAL")		-- anal complement to love

const = require("const")	-- global constants variables

la = require("lib/la")		-- lazyapi complement to lua
require("lib/utils")		-- ironapi complement to lua

frames = require("frames")	-- frame based engine complement to love
widgets = require("widgets")	-- widget complement to frames
local newScroller = require('scroller')
access = { game = require('gameplay') }
scale = 1			-- adapt to high resolutions
menuMusic = love.audio.newSource('music/MusiqueMenuV1.wav')

local frame = {}

function love.load()
    menuMusic:play()
    menuMusic:setVolume(0.2)
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

    -- main menu loading
    access.menu = frames.menu()
    local bg, start, pimp, leave = unpack(widgets.import("assets/MENU_PRINCIPAL"))
    local startf = function(self) menuMusic:pause() access.game.reset() return access.game end
    local pimpf = function(self) return access.pimp end
    access.menu.widgets:insert(widgets.button(bg))
    access.menu.widgets:insert(widgets.button(start), startf)
    access.menu.widgets:insert(widgets.button(pimp), pimpf)
    access.menu.widgets:insert(widgets.button(leave), function() love.event.quit() end)
    frame = access.menu

    -- entities loading
    -- OMG ICI JE LOAD LE MENU GAME OVER MAIS FAUT METTRE LE .LUA DES ENTITIES
    local entities = widgets.import("assets/GAME_OVER_MENU")
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

    -- pimp menu loading
    access.pimp = frames.menu()
    local pimp = widgets.import("assets/PIMP")[1]
    access.pimp.widgets:insert(widgets.button(pimp))

    -- game over loading
    access.lose = frames.menu()
    local bg, retry, pimp, menu = unpack(widgets.import("assets/GAME_OVER_MENU"))
    local retryf = function(self) menuMusic:pause() access.game.reset() return access.game end
    local menuf = function(self) menuMusic:play() access.game.stop() return access.menu end
    access.lose.widgets:insert(widgets.button(bg))
    access.lose.widgets:insert(widgets.button(retry), retryf)
    access.lose.widgets:insert(widgets.button(pimp), pimpf)
    access.lose.widgets:insert(widgets.button(menu), menuf)
end

function love.update(dt)
    frame = frame:update(dt) or frame
end

function love.draw()
    love.graphics.push()
    love.graphics.scale(scale)
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
