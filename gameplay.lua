local gameplay = {}

function gameplay.new()
   local gameplay = {}

   function gameplay:init()
      self.keys = {}
      for i in pairs(const.keys) do
	 self.keys[i] = 0
      end
      local img  = love.graphics.newImage("explosion.png")
      self.anim = newAnimation(img, 96, 96, 0.1, 0)
      self.entities = {}
   end

   function gameplay:update(dt)
      if not self.entities then
	 self:init()
      end
      -- Updates the animation. (Enables frame changes)
      self.anim:update(dt)
   end

   function gameplay:draw()
      -- Draw the animation at (100, 100).
      self.anim:draw(100, 100)
   end

   return gameplay
end

return gameplay
