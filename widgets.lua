local widgets = {}
local assets_dir = "assets"

function widgets.sprite(t)
   local sprite = la.variable.setType(t, "sprite")
   sprite.anim = la.variable.setType(
      newAnimation(
	 love.graphics.newImage(assets_dir.."/"..sprite.image),
	 sprite.tilewidth, sprite.tileheight,
	 const.delay, 0
      ), "sprite"
   )
   sprite.update = function(dt) sprite.anim:update(dt) end
   sprite.draw = function() sprite.anim:draw(sprite.x, sprite.y) end
   sprite.getWidth = function(...) sprite.anim:getWidth(...) end
   sprite.x, sprite.y = 0, 0
   return sprite
end

function widgets.label()
   local label = la.variable.setType({}, "label")
   
   return label
end

widgets.button = la.newFunctionOverLoad()

widgets.button.addFunction({ "sprite" },
   function(sprite)
      return la.variable.setType(sprite, "button")
   end
)

widgets.button.addFunction({ "label" },
   function(label)
      local button = la.variable.setType(label, "button")
      
      return button
   end
)

function widgets.import(name)
   local ret = require(name).tilesets
   for _, v in ipairs(ret) do
      widgets.sprite(v)
   end
   return ret
end

return widgets
