local la = require('lib/la')
require('lib/collide')

return function (opt)
    opt = opt or {}
    local sprites = {idle = opt.sprite or error('sprite not set')}
    local hitbox = opt.hitbox or error('hitbox not set')

    local o, mt= {}, {}

    function o.getHeight()
        return sprites[o.state] and sprites[o.state]:getHeight() or 0
    end

    function o.addSprite(sprite, label)
        label = label or 'idle'
        sprites[label] = sprite
    end

    o.x = opt.x or 0
    o.y = opt.y - opt.sprite:getHeight() or 0
    o.type = opt.type or 'generic'
    o.state = opt.state or 'idle'
    setmetatable(o, mt)

    function mt.__add(e1, e2)
        if la.variable.type(e1) ~= 'entity' or la.variable.type(e2) ~= 'entity' then return false end
        for i, pt in ipairs(e1.getHitbox()) do
            if PointWithinShape(e2.getHitbox(), pt.x, pt.y) then
                return true
            end
        end
        for i, pt in ipairs(e2.getHitbox()) do
            if PointWithinShape(e1.getHitbox(), pt.x, pt.y) then
                return true
            end
        end
        return false
    end

    function o.lowY(y)
        return o.y + sprites[o.state]:getHeight()
    end

    function o.getHitbox()
        local _hitbox = {}
        for i, v in ipairs(hitbox) do
            table.insert(_hitbox, {x = v.x + o.x, y = v.y + o.y})
        end
        return _hitbox
    end

    function o.changeState(state)
        state = state or 'idle'
        if state ~= o.state and sprites[state] and la.variable.type(sprites[state]) == 'sprite' then
            sprites[state]:reset()
        end
        o.state = state
    end

    function o.update(dt)
        if la.variable.type(sprites[o.state]) == 'sprite' or
       la.variable.type(sprites[o.state]) == 'sprite' then
            sprites[o.state]:update(dt)
        end
    end

    function o.draw(offX, offY)
        offX, offY = offX or 0, offY or 0
        if la.variable.type(sprites[o.state]) == 'sprite' then
            sprites[o.state]:draw(o.x + offX, o.y + offY)
        else
            love.graphics.draw(sprites[o.state], o.x + offX, o.y + offY)
        end
        if (#hitbox >= 3) then
            love.graphics.polygon("fill", unpack(makePoints(o.getHitbox())))
        end
    end

    return la.variable.setType(o, 'entity')
end
