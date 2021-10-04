Flash = class{
	init = function(self, duration)

		local sprite = Graphic('flash')

		local w = sprite:getWidth()
		local h = sprite:getHeight()

		local size = {
			w = h,
			h = w,
		}
		local scale = {
			x = 1.5,
			y = lg.getWidth() / h,
		}
		local position = {
			x = 0,
			y = 0,
		}
		local offset = {
			x = 0,
			y = 0,
		}

		local angle = 0

		self.sprite = sprite
		self.position = position
		self.size = size
		self.scale = scale
		self.offset = offset
		self.angle = angle
		self.timer = 0
		self.duration = duration
		self.active = true
	end,

	update = function(self, dt)
		local timer = self.timer
		local duration = self.duration
		if timer < duration then
			self.timer = math.min(timer + dt, duration)
		else
			self.active = false
		end
	end,

	draw = function(self)
		local sprite = self.sprite
		local position = self.position
		local size = self.size
		local scale = self.scale
		local offset = self.offset
		local angle = self.angle

		local timer = self.timer
		local duration = self.duration
		local t = math.sin(timer * math.pi / duration) * (timer/duration)
		local a = t * 100
		local sx = scale.x

		lg.setBlendMode('additive')
		lg.setColor(255, 255, 255, a * 0.4)
		sprite:draw(position.x + offset.x, position.y + offset.y, angle, sx, scale.y, offset.x, offset.y)
		lg.setBlendMode('alpha')
		lg.setColor(255, 255, 255, a)
		sprite:draw(position.x + offset.x, position.y + offset.y, angle, sx, scale.y, offset.x, offset.y)
	end,
}