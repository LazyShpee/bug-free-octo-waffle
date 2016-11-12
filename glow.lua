local glow = {}

function glow.init()
    glow.shader = love.graphics.newShader( "shaders/outline.glsl" )
    glow.thick = 5/1300
    glow.rgb = {23, 45, 110}
end

function glow.set(state)
    if state == true then
        glow.shader:send( "stepSize", {glow.thick, glow.thick})
        glow.shader:send( "colors", glow.rgb)
        love.graphics.setShader(glow.shader)
    elseif state == false then
        love.graphics.setShader()
    elseif type(state) == 'number' then
        glow.thick = state
    elseif type(state) == 'table' then
        glow.rgb = state
    end
end

return glow