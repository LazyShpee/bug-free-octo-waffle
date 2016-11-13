require('lib/AnAL')
local newScroller = require('scroller')
local newEntity = require('entity')
local la = require('lib/la')
local game = {}

local roadSpeed = 200
local conf = { S = -1 }
conf.speed = {
    roadSpeed,
    roadSpeed * 1.2,
    roadSpeed * 1.4,
    roadSpeed * 1.8
}
conf.phasesTime = { 0, 45.179 - 5, 76.957 - 5, 102.412 - 5}
conf.enemies = {
    order = {
        clochard = 1,
        policier = 2,
        vieille = 3,
        trump = 4,
        racaille = 5
    },
    speed = {
        conf.S * 0.1,
        conf.S * 0.3,
        conf.S * 0.05,
        conf.S * 0.25,
        conf.S * 0.31
    },
    freq = {
        {7, 0, 7, 2, 0},
        {5, 3, 5, 2, 20},
        {3, 5, 3, 3, 1},
        {1, 5, 1, 2, 6}
    },
    coolDown = 0.3
}

conf.player = {
    minY = 325,
    maxY = 405,
    startY = 355,
    speedY = 80,
    deadX = 0,
    maxX = 270,
    velYRedux = function(x) return x - 0.1 end,
    velY = 4
}

local state, km, scrollIndex, enemyCooldown, music, ui
local lvl = 1
local scroll = {}
local entities = {}
local scrollImg = {}

-- sprites(name): function returning the sprite name as an 'anim' type
function game:init(sprites)
   ui = require('ui')
    --music
    music = love.audio.newSource('music/MusiqueV2.wav')

    -- scrollers
    scrollIndex = {bg = 0, wall = 10, road = 20, tree = 30, lamp = 40} -- z-order, 0 furthest, inf nearest
    scroll.bg = newScroller({sx = roadSpeed / 4 * 3})
    scroll.wall = newScroller({sx = roadSpeed})
    scroll.road = newScroller({offset = 10, sx = roadSpeed})
    scroll.tree = newScroller({sx = roadSpeed, margin = 50, offset = 130, rngX = {0,100}, rngY = {0,20}})
    scroll.lamp = newScroller({sx = roadSpeed * 1.02, margin = 100, offset = 200})
    -- load sprites, can be either path or AnAL 'anim'
    scrollImg.bg =
       {
        {'sprites/background.png'},
        {'sprites/background_lvl2.png'},
        {},
        {}
    }
    scrollImg.wall = {
       {'sprites/BATIMENT1.png', 'sprites/BATIMENT2.png', 'sprites/BATIMENT3.png'},
       {},
       {},
       {}
    }
    scrollImg.road = {
        {'sprites/empty_road.png'},
        {'sprites/road_lvl2.png'},
        {},
        {}
    }
    scrollImg.tree = {
        {'sprites/tree.png'},
        {},
        {},
        {}
    }
    scrollImg.lamp = {
        {'sprites/lamp.png'},
        {'sprites/lamp.png'},
        {},
        {}
    }
    enemies = {
        clochard = love.graphics.newImage('sprites/enemy_generic_idle.png'),
        policier = love.graphics.newImage('sprites/enemy_generic_idle.png'),
        vieille = love.graphics.newImage('sprites/enemy_generic_idle.png'),
        trump = love.graphics.newImage('sprites/enemy_generic_idle.png'),
        racaille = love.graphics.newImage('sprites/enemy_generic_idle.png')
    }
    w, h = love.window.getMode()
    w = w / 2
    game.reset()
end

function game.makeEnemy()
    local rng = conf.enemies.freq[lvl]
    local tot, sel = 0, 0
    for _, v in ipairs(rng) do tot = tot + v end
    local rand = math.random(tot)
    for i, v in ipairs(rng) do rand = rand - v if rand <= 0 then sel = i break end end
    local name
    for i, v in pairs(conf.enemies.order) do if v == sel then name = i break end end
    local ent = newEntity({hitbox = makeShape({33,44,33+27,44,33+27,44+12,33,44+12}),x = w, y = math.random(conf.player.minY, conf.player.maxY), type = name, sprite = newAnimation(enemies[name], 64, 64, 0.1, 0)})
    table.insert(entities, ent)
end

function game.reset()
    music:stop()
    music:play()
    entities = {
        player = newEntity({
            sprite = newAnimation(love.graphics.newImage('sprites/trot.png'), 64, 64, 0.1, 1),
            hitbox = makeShape({38, 52, 38+13, 52, 38+13, 52+4, 38, 52+4}),
            y = conf.player.startY,
            x = conf.player.maxX
        })
    }
    entities.player.addSprite(newAnimation(love.graphics.newImage('sprites/trot.png'), 64, 64, 0.1, 0), 'run')
    entities.player.velY = 0
    entities.player.jump = 0
    entities.player.distance = 0
    enemyCooldown = 3
    levelDelay = -1
    lvl = 1
    game.changeLvl()
    state = 'game'
end

function game.changeLvl()
    local newSpeed = conf.speed[lvl]
    scroll.bg.setSpeed(newSpeed / 4 * 3)
    scroll.wall.setSpeed(newSpeed)
    scroll.road.setSpeed(newSpeed)
    scroll.tree.setSpeed(newSpeed)
    scroll.lamp.setSpeed(newSpeed * 1.02)
    for i, v in pairs(scroll) do
        v.flushPool()
        v.addImage(unpack(scrollImg[i][lvl]))
    end
end

function game:update(dt)
    for i, v in pairs(scroll) do
        v.update(dt)
    end
    for i, v in pairs(entities) do
        v.update(dt)
        if (type(i) == 'number') then
            if v.x < -100 then
                table.remove(entities, i)
            else
                if conf.enemies.order[v.type] and not v.hit and (v + entities.player) then
                    entities.player.x = entities.player.x - 25
                    v.hit = true
                    -- START COMBAT
                end
                local index = conf.enemies.order[v.type]
                v.x = v.x + (conf.S + conf.enemies.speed[index]) * conf.speed[lvl] * dt
            end
        end
    end
    enemyCooldown = enemyCooldown - dt
    if enemyCooldown <= 0 then
        enemyCooldown = conf.enemies.coolDown
        game.makeEnemy()
    end


    ----- Sync music time with phases
    local newLvl = lvl
    local soundPos = music:tell()
    for i, v in ipairs(conf.phasesTime) do
        if (soundPos >= v) then
            newLvl = i
        end
    end
    if (newLvl ~= lvl) then
        lvl = newLvl
        game.changeLvl(lvl)
        enemyCooldown = 5
    end
    -------------------------


    if state == 'game' then
       ui:update(dt, { score = 42/100, attention_derriere = 0.5, critiques = 42/100 })
        if entities.player.x < conf.player.deadX then
	   state = 'gameover'
	   game.reset()
	   return access.lose
        else
            if entities.player.jump > 0 then entities.player.velY = conf.player.velYRedux(entities.player.velY) end
            entities.player.jump = entities.player.jump + entities.player.velY
            if entities.player.jump < 0 then entities.player.jump = 0 end

            if entities.player.jump <= 0 and love.keyboard.isDown('right') and entities.player.x < conf.player.maxX then
                entities.player.x = entities.player.x + dt * conf.player.speedY
                entities.player.changeState('run')
            else
                entities.player.changeState('idle')
            end
            -- entities.player.x = entities.player.x + dt * conf.S * conf.player.speedY / 2
            if love.keyboard.isDown('up') and entities.player.lowY() > conf.player.minY then
                entities.player.y = entities.player.y - dt * conf.player.speedY
            end
            if love.keyboard.isDown('down') and entities.player.lowY() < conf.player.maxY then
                entities.player.y = entities.player.y + dt * conf.player.speedY
            end
        end
    end
end

function game:draw()
    love.graphics.push()
    love.graphics.translate(-600, 0)
    for i, v in la.table.pairsKeySorted(scroll, function (a, b) return scrollIndex[a] < scrollIndex[b] end) do
        v.draw()
    end
    love.graphics.pop()
    for i, v in la.table.pairsKeySorted(entities,
        function (a, b)
            return entities[a].y + entities[a].getHeight() < entities[b].y + entities[b].getHeight()
        end) do
        v.draw(0, type(i) ~= 'number' and -entities.player.jump or 0)
    end
    ui:draw()
    love.graphics.print(entities.player.jump.." - "..entities.player.velY.." - "..music:tell(), 100, 1)
end

function game:keypressed(key, scancode)
    if key == 'x' then
        if (lvl < 4) then
            lvl = lvl + 1
            game.changeLvl(lvl)
            enemyCooldown = 5
        end
    end
    if state == 'game' and key == 'space' then
       if entities.player.velY <= 0 then entities.player.velY = conf.player.velY end
    end
    if scancode == const.keys.retour then
       access.game = self
       if access.pause then
	  return access.pause
       else
	  local ret = frames.menu()
	  access.pause = ret
	  local bg, continue, pimp, leave = unpack(require("assets/MENU_PAUSE").tilesets)
	  local continuef = function(self)
	     access.pause = self
	     return access.game
	  end
	  ret.widgets:insert(widgets.button(widgets.sprite(bg)), ghost)
	  ret.widgets:insert(widgets.button(widgets.sprite(continue)), continuef)
	  ret.widgets:insert(widgets.button(widgets.sprite(pimp)), ghost)
	  ret.widgets:insert(widgets.button(widgets.sprite(leave)), function() love.event.quit() end)
	  return ret
       end
    end
end

return game
