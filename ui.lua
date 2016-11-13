local ui = {}

ui.sprites = {}
ui.empty_score, ui.full_score = unpack(widgets.import('assets/bar'))
local x, y = ui.empty_score.tileheight, const.height - ui.empty_score.tileheight * 2
ui.empty_score.x, ui.full_score.x = x, x
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
