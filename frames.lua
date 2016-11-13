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

   function menu.widgets:insert(item, callback)
      if not #self then
	 return
      end
      addToMetatable(item, "__call", function(item, self) return callback(self, item) end)
      table.insert(self, item)
      print(item.name.." loaded !")
      local ct = 0
      for i, v in ipairs(self) do
	 if i ~= 1 then
	    ct = ct + v.tileheight
	 end
      end
      local offset = (const.height - ct) / (#self)
      ct = 0
      for i, v in ipairs(self) do
	 if i ~= 1 then
	    v.x = (const.width - v.tilewidth) / 2
	    v.y = offset * (i - 1) + ct
	    ct = ct + v.tileheight
	 end
      end
      menu.cursor = math.floor((#self - 1) / 2) + 1
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
	 if v == self.widgets[self.cursor] then
	    glow.set(true)
	    v.draw()
	    glow.set(false)
	 end
      end
   end

   function menu:select()
      self.keys.select = const.keyup
      return self.widgets[self.cursor](self)
   end

   function menu:retour()
      love.event.quit()
   end

   function menu:haut()
      self.keys.haut = const.keyup
      if self.widgets[self.cursor - 2] then
	 self.cursor = self.cursor - 1
      end
   end

   function menu:bas()
      self.keys.bas = const.keyup
      if self.widgets[self.cursor + 1] then
	 self.cursor = self.cursor + 1
      end
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
   gameplay.enemies = require("assets/GAME_OVER_MENU").tilesets
   for _, v in ipairs(gameplay.enemies) do
      widgets.sprite(v)
   end
   local callback = function(self, name)
      for _, v in ipairs(self) do
	 if v.name == name then
	    return deepcopy(v)
	 end
      end
   end
   addToMetatable(gameplay.enemies, "__index", callback)
   gameplay.items = {}

   -- HUD
   gameplay.ui = require("ui")

   function gameplay:update(dt)
      -- update all entities
      for _, v in ipairs(self.items) do
         v.update(dt)
      end
      self.ui:update(dt, { score = 42/100, attention_derriere = 0.5, critiques = 42/100 })

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
      self.ui:draw()
   end


   function gameplay:retour() -- pause game and come back to menu
      self.keys.retour = const.keyup
      access.game = self
      if access.pause then
	 return access.pause
      else
	 local ret = frames.menu()
	 access.pause = ret
	 local bg, continue, pimp, leave = unpack(require("assets/MENU_PAUSE").tilesets)
	 local continuef = function(self)
	    access.pause = self
	    return access.game
	 end
	 ret.widgets:insert(widgets.button(widgets.sprite(bg)), ghost)
	 ret.widgets:insert(widgets.button(widgets.sprite(continue)), continuef)
	 ret.widgets:insert(widgets.button(widgets.sprite(pimp)), ghost)
	 ret.widgets:insert(widgets.button(widgets.sprite(leave)), function() love.event.quit() end)
	 return ret
      end
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
