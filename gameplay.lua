require('lib/AnAL')
local newScroller = require('scroller')
local newEntity = require('entity')
local la = require('lib/la')
local game = {}

local sounds = {}

local roadSpeed = 200
local conf = { S = -1 }
conf.speed = {
    roadSpeed,
    roadSpeed * 1.2,
    roadSpeed * 1.4,
    roadSpeed * 1.8
}
conf.shaders = {
    nil, nil, nil, nil
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

local state, km, scrollIndex, enemyCooldown, music, ui, fails, score
local lvl = 1
local scroll = {}
local entities = {}
local scrollImg = {}
local notes = {}
local combatSprites = {}
local combatBar = {}
local combatDead

-- sprites(name): function returning the sprite name as an 'anim' type
function game:init(sprites)
    sounds.cri = {
        love.audio.newSource('SD/cris-001.wav'),
        love.audio.newSource('SD/cris-002.wav'),
        love.audio.newSource('SD/cris-003.wav'),
        love.audio.newSource('SD/cris-004.wav'),
        love.audio.newSource('SD/cris-005.wav'),
        love.audio.newSource('SD/cris-006.wav'),
        love.audio.newSource('SD/cris-007.wav'),
        love.audio.newSource('SD/cris-008.wav'),
    }

    sounds.punch = {
        love.audio.newSource('SD/punch 1.wav'),
        love.audio.newSource('SD/punch 2.wav')
    }

    sounds.saut = love.audio.newSource('SD/saut.wav')
    sounds.roule = love.audio.newSource('SD/roule.wav')
    sounds.roule:setLooping(true)

    ui = require('ui')
    --music
    music = love.audio.newSource('music/MusiqueV2.wav')
    music:setVolume(0.2)

    w, h = love.window.getMode()
    w = w / scale
    h = h /scale

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
        {'sprites/background.png'},
        {'sprites/background_lvl2.png'},
    }
    scrollImg.wall = {
        {'sprites/BATIMENT1.png', 'sprites/BATIMENT2.png', 'sprites/BATIMENT3.png', 'sprites/BATIMENT4.png', 'sprites/BATIMENT5.png'},
        {'sprites/BATIMENT_VIDE.png'},
        {'sprites/BATIMENT1.png', 'sprites/BATIMENT2.png', 'sprites/BATIMENT3.png', 'sprites/BATIMENT4.png', 'sprites/BATIMENT5.png'},
        {'sprites/BATIMENT_VIDE.png'},
    }
    scrollImg.road = {
        {'sprites/empty_road.png'},
        {'sprites/road_lvl2.png'},
        {'sprites/empty_road.png'},
        {'sprites/road_lvl2.png'},
        {'sprites/BATIMENT_VIDE.png'},
        {'sprites/BATIMENT_VIDE.png'}
    }
    scrollImg.tree = {
        {'sprites/tree.png'},
        {'sprites/BATIMENT_VIDE.png'},
        {'sprites/tree.png'},
        {'sprites/BATIMENT_VIDE.png'},
    }
    scrollImg.lamp = {
        {'sprites/lamp.png'},
        {'sprites/lamp.png'},
        {'sprites/lamp.png'},
        {'sprites/lamp.png'},
    }
    enemies = {
        clochard = love.graphics.newImage('sprites/clochard_avance.png'),
        policier = love.graphics.newImage('sprites/policier_avance.png'),
        vieille = love.graphics.newImage('sprites/vieux_avance.png'),
        trump = love.graphics.newImage('sprites/trump_avance.png'),
        racaille = love.graphics.newImage('sprites/racaille_avance.png')
    }

    enemies_dead = {
        clochard = love.graphics.newImage('sprites/clochard_mort.png'),
        policier = love.graphics.newImage('sprites/policier_mort.png'),
        vieille = love.graphics.newImage('sprites/vieux_mort.png'),
        trump = love.graphics.newImage('sprites/trump_mort.png'),
        racaille = love.graphics.newImage('sprites/racaille_mort.png')
    }

    combatSprites.down = love.graphics.newImage('sprites/COMBAT_BAS.png')
    combatSprites.up = love.graphics.newImage('sprites/COMBAT_HAUT.png')
    combatSprites.right = love.graphics.newImage('sprites/COMBAT_GAUCHE.png')
    combatSprites.d = love.graphics.newImage('sprites/COMBAT_D.png')
    combatBar.sprite = newEntity({hitbox = makeShape({343, 0, 343 + 2, 0, 343 + 2, 0 + 16, 343, 0 + 16}),x = -100, y = h / 2, type = 'combatBar', sprite = love.graphics.newImage('sprites/BARRE_COMBAT.png')})
    combatDead = newEntity({hitbox = makeShape({0,0,16,0,16,16,0,16}),x = 200, y = h / 2, type = 'deadZone', sprite = love.graphics.newImage('sprites/COMBAT_D.png')})
end

function game.makeNotes(n)
    local names = {"down", "up", "right", "d"}
    local lastX = 300
    for i=1,n do
        lastX = lastX + math.random(20, 40)
        local name = names[math.random(#names)]
        table.insert(notes, newEntity({
            sprite = combatSprites[name],
            x = lastX, y = h / 2, type = name,
            hitbox = makeShape({-5,0,16,0,16,16,-5,16})
        }))
    end
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
    ent.addSprite(newAnimation(enemies_dead[name], 64, 64, 0.1, 0), 'dead', true)
    table.insert(entities, ent)
end

function game.reset()
    score = 0
    fails = 0
    music:stop()
    music:play()
    entities = {
        player = newEntity({
            sprite = newAnimation(love.graphics.newImage('sprites/trot.png'), 64, 64, 0.1, 1),
            hitbox = makeShape({23, 51, 23, 51+6, 23+12, 51+6, 23+12, 51}),
            y = conf.player.startY,
            x = conf.player.maxX
        })
    }
    entities.player.addSprite(newAnimation(love.graphics.newImage('sprites/trot.png'), 64, 64, 0.1, 0), 'run')
    entities.player.addSprite(newAnimation(love.graphics.newImage('sprites/trot_tail.png'), 80, 64, 0.05, 0), 'tailwhip', true)
    entities.player.velY = 0
    entities.player.jump = 0
    entities.player.distance = 0
    enemyCooldown = 3
    levelDelay = -1
    lvl = 1
    game.changeLvl()
    state = 'game'
end

function game.stop()
        music:stop()
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
                if entities.player.jump == 0 and state == 'game' and conf.enemies.order[v.type] and not v.hit and (v + entities.player) then
                    v.hit = true
                    state = 'combat'
                    enemy = v
                    game.makeNotes(4)
                end
                local index = conf.enemies.order[v.type]
                if not(state == 'combat' and v == enemy) then
                    v.x = v.x + (conf.S + conf.enemies.speed[index]) * conf.speed[lvl] * dt
                end
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

    if state == 'game' or state == 'combat' then
        score = score + dt
        ui:update(dt, { vitesse = lvl / 4, score = math.floor(score * 10), attention_derriere = 1 - entities.player.x / conf.player.maxX, critiques = 42/100 })
        if entities.player.x < conf.player.deadX then
            state = 'gameover'
            game.reset()
            game.stop()
            menuMusic:play()
            return access.lose
        elseif state == 'game' then
            if entities.player.jump > 0 then entities.player.velY = conf.player.velYRedux(entities.player.velY) end
                entities.player.jump = entities.player.jump + entities.player.velY
            if entities.player.jump < 0 then entities.player.jump = 0 end

            if entities.player.jump <= 0 and love.keyboard.isDown('right') and entities.player.x < conf.player.maxX then
                entities.player.x = entities.player.x + dt * conf.player.speedY
                entities.player.changeState('run')
                sounds.roule:play()
            else
                sounds.roule:pause()
                if (entities.player.jump <= 0 and entities.player.state ~= 'tailwhip') then
                    entities.player.changeState('idle')
                end
            end
            -- entities.player.x = entities.player.x + dt * conf.S * conf.player.speedY / 2
            if love.keyboard.isDown('up') and entities.player.lowY() > conf.player.minY then
                entities.player.y = entities.player.y - dt * conf.player.speedY
            end
            if love.keyboard.isDown('down') and entities.player.lowY() < conf.player.maxY then
                entities.player.y = entities.player.y + dt * conf.player.speedY
            end
        elseif state == 'combat' then
            if #notes == 0 then
                state = 'game'
                sounds.cri[math.random(#sounds.cri)]:play()
                enemy.state = 'dead'
                entities.player.sprites['tailwhip']:reset()
                entities.player.sprites['tailwhip']:play()
                entities.player.state = 'tailwhip'
            else
                for i, v in pairs(notes) do
                    v.x = v.x - conf.speed[lvl] / 3 * dt
                    if v + combatDead then
                        notes = {}
                        entities.player.x = entities.player.x - 10 * fails
                        fails = fails + 1
                        state = 'game'
                    end
                end
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
    if (state == 'combat') then
        love.graphics.push()
        love.graphics.scale(3)
        love.graphics.translate(-140, -150)
        combatBar.sprite.draw()
        for i, v in pairs(notes) do
            v.draw()
        end
        --combatDead.draw()
        love.graphics.pop()
    end
    ui:draw()
    --love.graphics.print(lvl.." - "..state.." - "..entities.player.jump.." - "..entities.player.velY.." - "..music:tell(), 100, 1)
end

function game:keypressed(key, scancode)
    if state == 'game' and key == 'space' then
        if entities.player.jump <= 0 then entities.player.velY = conf.player.velY sounds.saut:play() end
    elseif state == 'combat' then
        local where, which
        for i, v in pairs(notes) do
            if v + combatBar.sprite then
                which = v
                where = i
                break
            end
        end
        if which and which.type == key then
            table.remove(notes, where)
            sounds.punch[math.random(2)]:play()
        end
    end
    if scancode == const.keys.retour then
        music:pause()
        menuMusic:play()
        access.game = self
        if access.pause then
	        return access.pause
        else
            local ret = frames.menu()
            access.pause = ret
            local bg, continue, pimp, leave = unpack(require("assets/MENU_PAUSE").tilesets)
            local continuef = function(self)
                access.pause = self
                music:play()
                menuMusic:pause()
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
