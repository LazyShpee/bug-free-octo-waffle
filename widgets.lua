local widgets = {}

function widgets.sprite(t)
   local sprite = la.variable.setType(t, "sprite")
   sprite.anim = la.variable.setType(
      newAnimation(
	 love.graphics.newImage(sprite.image),
	 sprite.tilewidth, sprite.tileheight,
	 const.delay, 0
      ), "anim"
   )
   sprite.update = function(dt) sprite.anim:update(dt) end
   sprite.draw = function() sprite.anim:draw(sprite.x, sprite.y) end
   return sprite
end

function widgets.label()
   local label = la.variable.setType({}, "label")
   
   return label
end

widgets.button = la.newFunctionOverLoad()

widgets.button.addFunction({ "sprite" },
   function(sprite)
      local button = sprite
      return button
   end
)

widgets.button.addFunction({ "label" },
   function(label)
      local button = {}
      
      return button
   end
)

return widgets
