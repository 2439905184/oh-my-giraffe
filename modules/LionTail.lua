LionTail = class{
	init = function(self)

		self.position = {
			x = 0,
			y = 0,
			z = 1,
		}

		local running = Graphic('lion_tail')
		local state = 'running'

		local w = running:getWidth()
		local h = running:getHeight()
		local size = {
			w = w,
			h = h,
		}
		local scale = 6

		local offset = {
			x = size.w,
			y = size.h / 2,
		}

		self.state = state
		self.running = running
		self.size = size
		self.offset = offset
		self.angle = 0
		self.scale = scale
		self.shear = 0
		self.color = {255, 255, 255}

		self.batched = true

	end,

	update = function(self, dt)
		self[self.state]:update(dt)
	end,

	draw = function(self, projection, batch)
		local graphic = self[self.state]
		batch:setColor(self.color)
		graphic:add(batch, projection.x, projection.y, self.angle, self.scale, self.scale, self.offset.x, self.offset.y, self.shear)
	end,

	set = function(self, x, y, angle, shear)
		self.position.x = x
		self.position.y = y
		self.angle = angle
		self.shear = shear
	end,

	getWidth = function(self)
		return self[self.state]:getWidth()
	end,

	getHeight = function(self)
		return self[self.state]:getHeight()
	end,

	setState = function(self, state)
		self.state = state
	end,

	setRate = function(self, n)
		self[self.state]:setRate(n)
	end,

	setColor = function(self, color)
		self.color = color
	end,

}