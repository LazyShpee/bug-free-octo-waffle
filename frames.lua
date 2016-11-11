local frames = {}

function frames.menu()
   local menu = {}
   menu.keys = {}
   for i in pairs(const.keys) do
      menu.keys[i] = const.keyup
   end

   menu.widgets = {}

   function menu:update(dt)
      -- check frame changes
      if bool(self.keys.play) then
	 self.keys.play = const.keyup
	 -- create gameplay frame or restore paused frame
	 if self.freezed then
	    return self.freezed
	 else
	    local ret = frames.gameplay()
	    ret.freezed = self
	    return ret
	 end
      elseif bool(self.keys.retour) then
	 love.event.quit()
      end

      -- update all widgets
      for _, v in ipairs(self.widgets) do
	 v.update(dt)
      end
      return self
   end

   function menu:draw()
      for _, v in ipairs(self.widgets) do
	 v.draw()
      end
   end

   return menu
end

function frames.gameplay()
   local gameplay = {}
   gameplay.keys = {}
   for i in pairs(const.keys) do
      gameplay.keys[i] = const.keyup
   end

   local img  = love.graphics.newImage("explosion.png")
   gameplay.anim = newAnimation(img, 96, 96, 0.1, 0)
   gameplay.entities = {}

   function gameplay:update(dt)
      -- Updates the animation. (Enables frame changes)
      self.anim:update(dt)

      if bool(self.keys.retour) then -- pause game and come back to menu
	 self.keys.retour = const.keyup
	 self.freezed.freezed = self
	 return self.freezed
      end
      return self
   end

   function gameplay:draw()
      -- Draw the animation at (100, 100).
      self.anim:draw(100, 100)
   end

   return gameplay
end

return frames
