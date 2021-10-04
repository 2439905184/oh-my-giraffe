-- changes color based on time of day
Moon = class{

	init = function(self)

		self.radius = 35
		self.halo = 15
		self.color = {255, 255, 224}

		-- todo
		-- resolve this curve for scaling

		local w, h, f, l
		w = window.width
		h = window.height
		f = world.floor * window.scaling
		l = (50 / 1024) * w

		local points = {
			l, h - f * 2,
			l, 0,
			w - l, 0,
			w - l, h - f * 2,
		}

		self.path = love.math.newBezierCurve(points)

		-- how do I want to model the colors changes for this and the skybox?

	end,

	update = function(self, dt)

		-- set color based on time
		-- set position based on time

		local time = self.time

		-- I will want to pause updating this or something when it's night time?
		-- how do I make this invalid for a bit

		local t = (time + 0.5) % 1
		t = easing.inOutQuad(t, 0, 1, 1)
		local x, y = self.path:evaluate(t)

		self.position = {
			x = x,
			y = y,
		}

	end,

	draw = function(self, projection)

		local position, radius, halo, color

		position = self.position
		radius = self.radius
		halo = self.halo
		color = self.color

		local x, y
		x = projection.x + position.x
		y = projection.y + position.y
		
		lg.setColor(color[1], color[2], color[3], 60)
		lg.rectangle('fill', x - ((radius + halo) * 0.5), y - ((radius + halo) * 0.5), radius + halo, radius + halo)

		lg.setColor(color)
		lg.rectangle('fill', x - (radius * 0.5), y- (radius * 0.5), radius, radius)

	end,

	set = function(self, time)
		self.time = time
	end,

}