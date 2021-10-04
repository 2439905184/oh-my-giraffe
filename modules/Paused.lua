Paused = class{
	init = function(self, middle, label, color, switch, action, icon, symbol, sx, sy)


		local sprite = Graphic('orb')
		local position = {
			x = middle,
			y = 0,
		}



		local size = sprite:get().size


		self.sprite = sprite
		self.position = position
		self.size = size
		self.scaling = 4

		self.timer = 0
		self.period = 2
		self.amplitude = 2
	end,

	update = function(self, dt)
		self.timer = self.timer + dt
	end,

	draw = function(self)
		local position, x, y
		position = self.position
		x = position.x
		y = position.y

		local scale = self.scale
		local scaling = self.scaling

		local a = self.alpha
		local s = scaling * scale
		local sprite = self.sprite

		local size = self.size
		local w = size.w
		local h = size.h

		local timer = self.timer
		local amplitude = self.amplitude
		local period = self.period

		local ox = math.cos(timer * math.pi * 2 / period) * amplitude
		x = x + ox

		local oy = math.sin(timer * math.pi * 2 / period) * amplitude
		y = y + oy

		y = y

		lg.setColor(255, 255, 255, a)
		sprite:draw(x, y, 0, s, s, w*0.5, h*0.5)

	end,

	getSize = function(self)
		return self.sprite:get().size
	end,

	target = function(self, x, y, scale, alpha)
		self.position.x = x
		self.position.y = y
		self.scale = scale
		self.alpha = math.min(alpha, 255)
	end,

	inputpressed = function(self, id, x, y, mode)
	end,

	inputreleased = function(self, id, x, y, mode)
	end,
}