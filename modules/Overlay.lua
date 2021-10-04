Overlay = class{
	init = function(self, middle, label)

		local position = {
			x = middle,
			y = 0,
		}

		local size = {w = 0, h = 0}
		self.position = position
		self.size = size
		self.alpha = 0
		self.graphic = Graphic('pixel')
		self.w = lg.getWidth()
		self.h = lg.getHeight()

	end,

	update = function(self, dt)
	end,

	draw = function(self, batch)
		local a = self.alpha * 0.45
		local graphic = self.graphic
		local w, h = self.w, self.h
		batch:setColor(0, 0, 0, a)
		graphic:add(batch, 0, 0, 0, w, h)
		batch:unbind()
		lg.draw(batch)
		batch:clear()
		batch:bind()
	end,

	getSize = function(self)
		return self.size
	end,

	target = function(self, x, y, scale, alpha)
		self.position.x = x
		self.position.y = y
		self.scale = scale
		self.alpha = math.min(alpha, 255)
	end,

	clear = function(self)
	end,

	inputpressed = function(self, id, x, y, mode)
	end,

	inputreleased = function(self, id, x, y, mode)
	end,
}