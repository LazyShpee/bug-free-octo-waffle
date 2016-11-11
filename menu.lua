local menu = {}

function menu.new()
   local menu = {}
   menu.widgets = {}

   function menu:update(dt, keys)
      if bool(keys.play) then -- create gameplay frame or restore paused frame
	      keys.play = const.keyup
	      return frameList.paused and frameList.paused or gameplay:new()
      elseif bool(keys.retour) then
	      love.event.quit()
      end
      return self
   end

   function menu:draw()
   end

   return menu
end

return menu
