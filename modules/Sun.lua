-- changes color based on time of day
Sun = class{

	init = function(self)

		self.radius = 35
		self.halo = 15
		self.color = {255, 255, 255}
		self.graphic = Graphic('sky')
		self.position = {x = 0, y = 0}

		-- todo
		-- resolve this curve for scaling

		local w, h, f, l
		w = window.width
		h = window.height
		f = world.floor-- * window.scaling
		l = (50 / 1024) * w

		-- TODO
		-- fix this scaling to be absolute since
		-- on really high dpi screens this path isn't correct
		local points = {
			l, h - f * 2,
			l, 0,
			w - l, 0,
			w - l, h - f * 2,
		}

		self.path = love.math.newBezierCurve(points)
		self.batched = true

		-- how do I want to model the colors changes for this and the skybox?

	end,

	update = function(self, dt)

		-- set color based on time
		-- set position based on time

		local time = self.time

		-- I will want to pause updating this or something when it's night time?
		-- how do I make this invalid for a bit

		local t = easing.inOutQuad(time, 0, 1, 1)
		local x, y = self.path:evaluate(t)
		self.position.x = x
		self.position.y = y

	end,

	draw = function(self, projection, batch)

		local position = self.position
		local radius = self.radius
		local halo = self.halo
		local color = self.color

		local x = projection.x + position.x
		local y = projection.y + position.y

		local graphic = self.graphic
		
		--lg.setColor(color[1], color[2], color[3], 60)
		--lg.rectangle('fill', x - ((radius + halo) * 0.5), y - ((radius + halo) * 0.5), radius + halo, radius + halo)

		--lg.setColor(color)
		--lg.rectangle('fill', x - (radius * 0.5), y- (radius * 0.5), radius, radius)

		batch:setColor(color[1], color[2], color[3], 60)
		graphic:add(batch, x, y, 0, radius + halo, radius + halo, 0.5, 0.5)

		batch:setColor(color)
		graphic:add(batch, x, y, 0, radius, radius, 0.5, 0.5)

	end,

	set = function(self, time)
		self.time = time
	end,

}