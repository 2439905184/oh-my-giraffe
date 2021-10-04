ComboPanel = class{
	init = function(self)
	end,

	update = function(self, dt)
	end,

	draw = function(self)

		local font = font_large
		local x, y, padding
		padding = 30
		x = screen.width() * 0.5
		y = screen.height() - padding
		
		local combo = tostring(self.combo) .. 'x'
		local w, h
		w = font:getWidth(combo)
		h = font:getHeight(combo)

		lg.setFont(font)
		lg.setColor(255, 255, 255)
		--lg.print(combo, x, y, 0, 1, 1, w*0.5, h)
		
	end,

	set = function(self, combo)
		self.combo = combo
	end,

	-- hint that the combo is about to be lost
	alert = function(self, token)
	end,

	-- reset the combo
	reset = function(self)
	end,
}