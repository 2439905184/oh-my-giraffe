StageManager = class{
	init = function(self)
		self.stage = 0
		self:broadcast()
		observer:register('advance_stage', function() self:advance() end)
	end,

	update = function(self, dt)
	end,

	draw = function(self)
		--lg.print(self.stage, 100, 130)
	end,

	advance = function(self)
		self.stage = self.stage + 1
		self:broadcast()
	end,

	broadcast = function(self)
		local n = self.stage
		local cap = 5
		difficulty = easing.inQuad(n/cap, 0, 1, 1)
		print('advanced to stage ' .. self.stage)
	end,
}