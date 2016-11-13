local ui = {}

ui.sprites = {}
ui.empty_score, ui.full_score = unpack(require('assets/bar').tilesets)
ui.empty_score, ui.full_score = widgets.sprite(ui.empty_score), widgets.sprite(ui.full_score)
local y = const.height - ui.empty_score.tileheight
ui.empty_score.y, ui.full_score.y = y, y
ui.x = 0

function ui:update(dt, opt)
   -- opt.score: distance totale parcourue
   -- opt.attention_derriere: distance par rapport à la horde
   -- opt.combo: combo lol
   self.x = opt.attention_derriere * self.empty_score.tilewidth
   ui.full_score.update(dt)
end

function ui:draw()
   ui.empty_score.draw()
   love.graphics.setScissor(scale * ui.empty_score.x,
			    scale * ui.empty_score.y,
			    scale * (ui.empty_score.x + self.x),
			    scale * const.height)
   ui.full_score.draw()
   love.graphics.setScissor()
end

return ui
