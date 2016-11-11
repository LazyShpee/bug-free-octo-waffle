local gameplay = {}

function gameplay.new()
   local gameplay = {}
   local img  = love.graphics.newImage("explosion.png")
   gameplay.anim = newAnimation(img, 96, 96, 0.1, 0)
   gameplay.entities = {}

   function gameplay:update(dt, keys)
      -- Updates the animation. (Enables frame changes)
      self.anim:update(dt)

      if bool(keys.retour) then -- pause game and come back to menu
	 keys.retour = const.keyup
	 frameList.paused = self
	 return frameList.menu
      end
      return self
   end

   function gameplay:draw()
      -- Draw the animation at (100, 100).
      self.anim:draw(100, 100)
   end

   return gameplay
end

return gameplay
