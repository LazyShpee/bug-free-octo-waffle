local menu = {}

function menu.new()
   local menu = {}

   function menu:init()
      self.keys = {}
      for i in pairs(const.keys) do
	 self.keys[i] = 0
      end
      self.widgets = {}
   end

   function menu:update(dt)
      if not self.widgets then
	 self:init()
      end
   end

   function menu:draw()
   end

   return menu
end

return menu
