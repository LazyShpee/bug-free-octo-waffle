local frames = {}
local glow = require('glow')
glow.init()
glow.set({64, 224, 208})

function frames.menu()
   local menu = {}
   menu.name = "menu"
   menu.keys = {}
   for i in pairs(const.keys) do
      menu.keys[i] = const.keyup
   end
   menu.widgets = {}

   function menu.widgets:insert(item)
      table.insert(self, item)
      local ct = 0
      for i, v in ipairs(self) do
	 ct = ct + v.tileheight
      end
      local offset = (const.height - ct) / (#self + 1)
      ct = 0
      for i, v in ipairs(self) do
	 v.x = (const.width - v.tilewidth) / 2
	 v.y = offset * i + ct
	 ct = ct + v.tileheight
      end
   end

   function menu:update(dt)
      -- execute frame handled callbacks
      for i, v in pairs(self.keys) do
	 local ret = (bool(v) and self[i]) and self[i](self) or nil
	 if ret then return ret end
      end

      -- update all widgets
      for _, v in ipairs(self.widgets) do
	 v.update(dt)
      end
      return self
   end

   function menu:draw()
      -- draw all widgets
      for _, v in ipairs(self.widgets) do
	 v.draw()
      glow.set(true)
	 v.draw()
      glow.set(false)
      end
   end

   function menu:play()
      self.keys.play = const.keyup
      -- create gameplay frame or restore paused frame
      if self.freezed then
	 return self.freezed
      else
	 local ret = frames.gameplay()
	 ret.freezed = self
	 return ret
      end
   end

   function menu:retour()
      love.event.quit()
   end
   return menu
end

function frames.gameplay()
   local gameplay = {}
   gameplay.name = "game"
   gameplay.keys = {}
   for i in pairs(const.keys) do
      gameplay.keys[i] = const.keyup
   end

   -- entities
   gameplay.player = require("player")
   gameplay.hhh = {}
   gameplay.enemies = {}
   gameplay.items = {}

   function gameplay:update(dt)
      -- update all entities
      for _, v in ipairs(self.items) do
	 v.update(dt)
      end

      -- execute frame handled callbacks
      for i, v in pairs(self.keys) do
	 local ret = (bool(v) and self[i]) and self[i](self) or nil
	 if ret then return ret end
      end

      -- execute player handled callbacks
      for i, v in pairs(self.keys) do
	 if bool(v) and self.player[i] then
	    self.player[i](self.player)
	 end
      end
      return self
   end

   function gameplay:draw()
      -- draw all entities
      for _, v in ipairs(self.items) do
	 v.draw()
      end
   end


   function gameplay:retour() -- pause game and come back to menu
      self.keys.retour = const.keyup
      self.freezed.freezed = self
      return self.freezed
   end

   function gameplay.hhh:insert(item)
      table.insert(self, item)
   end

   function gameplay.enemies:insert(item)
      table.insert(self, item)
   end

   function gameplay.items:insert(item)
      table.insert(self, item)
   end

   return gameplay
end

return frames
