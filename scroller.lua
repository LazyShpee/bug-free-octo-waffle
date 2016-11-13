local la = require('lib/la')

return function(opt)
    opt = opt or {}
    local sx, sy = opt.sx or 100, opt.sy or 0
    local offset = opt.offset or 0
    local margin = opt.margin or 0
    local rngX = opt.rngX or {0, 0}
    local rngY = opt.rngY or {0, 0}

    local imagePool = {}
    local scroller = {}

    local fill = function()
        if #imagePool == 0 then return end
        if #scroller == 0 then
            table.insert(scroller,
            {
                ['x'] = math.random(unpack(rngX)),
                ['y'] = offset + math.random(unpack(rngY)),
                ['img'] = imagePool[math.random(#imagePool)]
            })
        end
        local w = love.window.getMode()
        local last = scroller[#scroller]
        local limit = 0
	print(la.variable.type(last.img))
        while (limit < 100 and last.x + last.img:getWidth() + margin < w) do
            table.insert(scroller,
            {
                ['x'] = last.x + last.img:getWidth() + margin + math.random(unpack(rngX)),
                ['y'] = offset + math.random(unpack(rngY)),
                ['img'] = imagePool[math.random(#imagePool)]
            })
            last = scroller[#scroller]
            limit = limit + 1
        end
    end

    return la.variable.setType({
        setSpeed = function(sp) sx = sp end,
        index = opt.index or 1,
        flushPool =
        function()
            imagePool = {}
        end,
        update =
        function(dt)
            for i, item in ipairs(scroller) do
                if (item.img:getWidth() + item.x < 0) then
                    table.remove(scroller, i)
                end
                if (la.variable.type(item.img) == 'sprite') then
                    img:update(dt)
                end
                item.x, item.y = item.x - dt * sx, item.y - dt * sy
            end
            local tmp = {}
            for i, v in ipairs(scroller) do if v then table.insert(tmp, v) end end
            scroller = tmp
            fill()
        end,

        draw =
        function()
            for i, item in ipairs(scroller) do
                if (la.variable.type(item.img) == 'userdata') then
                    love.graphics.draw(item.img, item.x, item.y)
                elseif (la.variable.type(item.img) == 'anim') then
                    item.img:draw(item.x, item.y)
                end
            end
        end,

        addImage =
        function(...)
            local arg = {...}
            for i, img in ipairs(arg) do
                if (la.variable.type(img) == 'string') then
                    table.insert(imagePool, love.graphics.newImage(img))
                elseif (la.variable.type(img) == 'sprite') then
                    table.insert(imagePool, img)
                elseif (la.variable.type(img) == 'userdata') then
                    table.insert(imagePool, img)
                end
            end
        end
    }, 'scroller')
end
