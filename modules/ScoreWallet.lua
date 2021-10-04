ScoreWallet = class{
	init = function(self)
		self.wallet = 0
		self.output = 0
		self.duration = 0.2
		self.elapsed = 0

		-- ScoreManager can draw this to screen perhaps?
		-- or it can use the score slot/signal and be decoupled to the ui module
		-- so that it can be removed at the same time as other ui elements
	end,
	
	shake = function(self)
	end,

	update = function(self, dt)
		-- ease to output to points
	end,

	draw = function(self)
		-- draw output to screen
	end,

	add = function(self, n)
		self.points = self.points + n
	end,
}