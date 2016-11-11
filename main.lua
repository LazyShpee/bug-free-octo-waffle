require('lib/AnAL')

function love.load()
    local img  = love.graphics.newImage("explosion.png")
    anim = newAnimation(img, 96, 96, 0.1, 0)
end

function love.update(dt)
    -- Updates the animation. (Enables frame changes)
    anim:update(dt)
end

function love.draw()
    -- Draw the animation at (100, 100).
    anim:draw(100, 100)
end