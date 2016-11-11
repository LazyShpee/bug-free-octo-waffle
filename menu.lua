local menu = {}

function menu.new()
   local menu = {}
   menu.widgets = {}

   function menu:update(dt, keys)
      if bool(keys.play) then -- create gameplay frame or restore paused frame
	 return frameList.paused and frameList.paused or gameplay:new()
      end
      return self
   end

   function menu:draw()
   end

   return menu
end

return menu
