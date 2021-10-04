Stars = class{
	init = function(self)
		local w = window.width
		local h = window.height
		local size = math.floor(math.max(w, h)) * 1.3
		local batch = self:populate(size)
		local scale = 1
		self.graphic = batch
		self.dimension = size
		self.starfield = starfield
		self.angle = 0
		self.label = 'starfield'
		self.position = {
			x = w*0.5,
			y = h*0.75,
			z = math.huge,
		}
		self.scale = scale
		self.alpha = 0
		self.time = 0
		self.size = {
			w = w,
			h = h,
		}
		self.offset = {
			x = size*0.5,
			y = size*0.5,
		}

	end,

	update = function(self, dt)
		self.angle = self.angle + dt * 0.1
		local time = self.time
		local span = 0.4
		if (time > 1 - span*0.5) or (time < span*0.5) then

			local t
			if (time < span*0.5) then
				t = time
			elseif (time > 1 - span*0.5) then
				t = time - 1
			end

			t = t + (span*0.5)
			t = t / span
			t = t * math.pi
			t = math.sin(t)

			local a = 255 * t
			
			self.alpha = a

		else
			self.alpha = 0
		end
	end,

	draw = function(self, projection)
		local angle = self.angle
		local scale = self.scale
		local offset = self.offset
		local alpha = self.alpha

		local x = projection.x + window.center.x
		local y = projection.y + window.center.y
		local dimension = self.dimension
		local graphic = self.graphic

		lg.setColor(255, 255, 255, alpha)
		lg.draw(graphic, x, y, angle, scale, scale, offset.x, offset.x)

	end,

	set = function(self, time)
		self.time = time
	end,	

	populate = function(self, size)

		local w, h = size, size
		local threshold = 227
		local step = 15
		local scale = 5

		local texture = g["pixel"]
		local batch = lg.newSpriteBatch(texture, 2000, 'static')

		local cx = w*0.5
		local cy = h*0.5
		local sq = math.max(cx, cy) * math.max(cx, cy)
		local pi = math.pi

		local data = {}
		for x = 1, w, step do
			for y = 1, h, step do
				local distance = math.pow(cx - x, 2) + math.pow(cy - y, 2)
				local inside = distance < sq
				if inside then
					local value = love.math.noise(math.random(), math.random(), math.random()) * 255
					if (value > threshold) then
						local angle = math.atan2(cy - y, cx - x) + pi*0.5
						batch:add(x, y, angle, scale, scale, scale*0.5, scale*0.5)
					end
				end
			end
		end

		return batch
	end,
}