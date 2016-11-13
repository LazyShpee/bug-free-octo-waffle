require('lib/AnAL')
local newScroller = require('scroller')
local newEntity = require('entity')
local la = require('lib/la')
local game = {}

local conf = { S = -1 }
conf.enemies = {
    phasesSample = { 0, 1, 5, 10 },
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
    velXRedux = function(x) return x - 0.02 end
}

local roadSpeed = 200

local state, km, scrollIndex, enemyCooldown
local lvl = 1
local scroll = {}
local entities = {}
local scrollImg = {}

-- sprites(name): function returning the sprite name as an 'anim' type
function game:init(sprites)
    -- scrollers
    scrollIndex = {bg = 0, wall = 10, road = 20, tree = 30, lamp = 40} -- z-order, 0 furthest, inf nearest
    scroll.bg = newScroller({sx = roadSpeed / 4 * 3})
    scroll.wall = newScroller({sx = roadSpeed})
    scroll.road = newScroller({offset = 10, sx = roadSpeed})
    scroll.tree = newScroller({sx = roadSpeed, margin = 50, offset = 130, rngX = {0,100}, rngY = {0,20}})
    scroll.lamp = newScroller({sx = roadSpeed * 1.02, margin = 100, offset = 200})
    -- load sprites, can be either path or AnAL 'anim'
    scrollImg.bg = {
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
    local ent = newEntity({hitbox = makeShape({0,0,0,0,0,0}),x = w, y = math.random(conf.player.minY, conf.player.maxY), type = name, sprite = newAnimation(enemies[name], 64, 64, 0.1, 0)})
    table.insert(entities, ent)
end

function game.reset()
    entities = {
        player = newEntity({
            sprite = newAnimation(love.graphics.newImage('sprites/trot.png'), 64, 64, 0.1, 1),
            hitbox = makeShape({0, 0}), --, 20, 0, 20, 20, 20, 40, 10, 20, 0, 40}),
            y = conf.player.startY,
            x = conf.player.maxX
        })
    }
    entities.player.addSprite(newAnimation(love.graphics.newImage('sprites/trot.png'), 64, 64, 0.1, 0), 'run')
    entities.player.velY = 0
    entities.player.height = 0
    entities.player.distance = 0
    enemyCooldown = conf.enemies.coolDown
    lvl = 1
    game.changeLvl()
    state = 'game'
end

function game.changeLvl()
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
                local index = conf.enemies.order[v.type]
                v.x = v.x + (conf.S + conf.enemies.speed[index]) * roadSpeed * dt
            end
        end
    end
    enemyCooldown = enemyCooldown - dt
    if enemyCooldown <= 0 then
        enemyCooldown = conf.enemies.coolDown
        game.makeEnemy()
    end
    if state == 'game' then
        if entities.player.x < conf.player.deadX then
            state = 'gameover'
        else
            if love.keyboard.isDown('right') and entities.player.x < conf.player.maxX then
                entities.player.x = entities.player.x + dt * conf.player.speedY
                entities.player.changeState('run')
            else
                entities.player.changeState('idle')
            end
                entities.player.x = entities.player.x + dt * conf.S * conf.player.speedY / 2
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
    love.graphics.scale(scale, scale)
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
        v.draw()
    end
    love.graphics.print(#entities.."-"..entities.player.x.." - "..entities.player.lowY(), 100, 1)
end

function game:keypressed(key)
    if key == 'x' then
        if (lvl < 4) then
            lvl = lvl + 1
            game.changeLvl(lvl)
        end
    end
end

return game