local ui = {}

ui.sprites = {}
ui.empty_v, ui.full_v, ui.empty_ad, ui.full_ad
   = unpack(widgets.import('assets/bar'))
local x, y = ui.empty_v.tileheight, const.height - ui.empty_v.tileheight * 2
ui.empty_v.x, ui.full_v.x = x, x
ui.empty_v.y, ui.full_v.y = y, y

y = const.height - ui.empty_v.tileheight * 2.3
ui.empty_ad.y, ui.full_ad.y = y, y
ui.empty_ad.x = const.width - ui.empty_ad.tilewidth - ui.empty_v.x

ui.score = 0
ui.v = 0

love.graphics.setFont(love.graphics.newImageFont("assets/hud/numbers.png", "0123456789"))

function ui:update(dt, opt)
   -- opt.score: distance totale parcourue
   -- opt.attention_derriere: distance par rapport à la horde
   -- opt.combo: combo lol
   -- opt.vitesse: vitesse du scroll

   opt.vitesse = 0
   opt.attention_derriere = 1
   ui.score = opt.score
   ui.full_ad.x = ui.empty_ad.x +
      opt.attention_derriere * (self.empty_ad.tilewidth - self.full_ad.tilewidth)
   -- ui.empty_combo.opt = opt.combo * self.empty_combo.tilewidth
   ui.v = opt.vitesse * self.empty_v.tilewidth
   ui.full_v.update(dt)
   ui.full_ad.update(dt)
end

function ui:draw()
   love.graphics.print(ui.score, 0, 0)
   ui.empty_v.draw()
   ui.empty_ad.draw()
   ui.full_ad.draw()
   love.graphics.setScissor(scale * ui.empty_v.x,
			    scale * ui.empty_v.y,
			    scale * ui.v,
			    scale * const.height)
   ui.full_v.draw()
   love.graphics.setScissor()
end

return ui
