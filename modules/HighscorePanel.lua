-- TODO
-- make this display the current highscore
-- clicking it allows you to reset it?

HighscorePanel = class{
	init = function(self)
		self.font = symbols
		self:set(n)
	end,

	update = function(self, dt)
		self.component:update(dt)
	end,

	draw = function(self)

		--self.component:draw()

	end,

	setTransition = function(self, transition)
		self.transition = transition
		self.component.position.y = lg.getHeight() - 70 * transition
		self.component.alpha = 255 * transition
	end,

	mousepressed = function(self, x, y, button)
	end,

	mousereleased = function(self, x, y, button)
	end,

	set = function(self, n)
		local n = n or 0
		local value = comma_value(n)
		self.component = MenuSubtitle(500, 'high score  * ' .. value)
		self.component.scale = 1
		self.component.magnitude = 0
		self.component:clear()
	end,

}