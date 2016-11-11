const = require('const')
require('utils')

local namespace = {}

function namespace.new()
   local menu = {}

   function menu:init()
      self.keys = {}
      for i in pairs(const.keys) do
	 self.keys[i] = 0
      end
      self.widgets = {}
   end

   menu.update = function (self, dt)
      print(self)
      if not self.widgets then
	 self:init()
      end
   end

   function menu:draw()
      
   end

   return menu
end

return namespace
