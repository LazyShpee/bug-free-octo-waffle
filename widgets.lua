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
   -- sprite.anim:setMode("bounce")
   sprite.update = function(dt) sprite.anim:update(dt) end
   sprite.draw = function() sprite.anim:draw() end
   return sprite
end

function widgets.label()
   local label = la.variable.setType({}, "label")
   
   return label
end

widgets.button = la.newFunctionOverLoad()

widgets.button.addFunction({ "sprite" },
   function(sprite)
      local button = {}
      button.sprite = sprite
      button.update = function(dt) sprite.update(dt) end
      button.draw = function() sprite.draw() end
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
