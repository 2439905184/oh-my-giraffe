MenuHint = class{
	init = function(self)
		local position = {x = 0, y = 0}
		local size = {w = 0, h = 0}
		self.position = position
		self.size = size
		self.graphic = Graphic('touch')
	end,

	update = function(self, dt)
	end,

	draw = function(self)
		local position = self.position
		local graphic = self.graphic
		--lg.print('do stuff', position.x, position.y)

		graphic:draw(position.x, position.y, 0, 1.5, 1.5)
	end,

	getSize = function(self)
		return self.size
	end,

	target = function(self, x, y, scale, alpha)
		self.position.x = x
		self.position.y = y - (window.height * 0.2)
		self.scale = scale
		self.alpha = math.min(alpha, 255)
	end,
}