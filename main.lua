local scroller = require('scroller')
local newAnim = require('lib/AnAL')

function love.load()
    love.graphics.setDefaultFilter('nearest')
    walls = {
        'sprites/wall1.png',
        'sprites/wall2.png'
    }
    wallProps = {
        love.graphics.newImage('sprites/trump.png')
    }
    scroll = scroller({sx = 1000})
    scroll.addImage(walls[1], walls[2])
    scroll2 = scroller({sx = 900, offset = 50})
    scroll2.addImage(walls[1], walls[2])
end

function love.update(dt)
    scroll.update(dt)
    scroll2.update(dt)
end

function love.draw()
    love.graphics.push()
    love.graphics.scale(4, 4)
    scroll.draw()
    scroll2.draw()
    love.graphics.pop()
end