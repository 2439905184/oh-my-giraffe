-- should be responsible for keeping track of time and cycles
-- passes time to skymanager
SkyManager = class{
	
	init = function(self)

		self.position = {x = 0, y = 0, z = math.huge}
		self.size = {w = window.width, h = window.height}

		local start = options.start_time
		local length = options.day_length
		local time = start * length

		self.time = time
		self.length = length
		self.graphic = Graphic('sky')
		self.sun = Sun()
		self.stars = Stars()
		self.horizon = Horizon()
		self.label = 'sky'
		self.batched = true

		-- changes sky color based on time
		-- sets sun to correct time
		-- returns value for world objects (perhaps based on depth???)

		-- how do I want to model the color shifts for the skybox?
		-- how about for the world?
		-- how about fading in starts?

		-- tweak the color model...
		-- add a color model for the sun
		-- add a color model for the world

		
		local skybox = {
			[0] = {83, 153, 173},
			[20] = {113, 183, 193},
			[80] = {113, 183, 193},
			[100] = {83, 153, 173},
		}

		self.skybox = skybox

		local night = {200, 180, 255}
		local night = {120, 140, 255}
		local world = {
			[0] = night,
			[25] = {255, 255, 255},
			[75] = {255, 255, 255},
			[100] = night,
		}

		self.world = world

		self.sleeping = false

		observer:register('sleep', function() self.sleeping = true end)


	end,

	update = function(self, dt)

		-- update time

		local sleeping = self.sleeping

		if options.time then
			self.time = self.time + dt
		end
		
		local t = (self.time / self.length) % 1
		local sky = self:hue(self.skybox, t)
		local cast = self:hue(self.world, t)
		world.color = cast
		world.sky = sky
		self.sky = sky

		self.stars:set(t)
		self.sun:set(t)
		self.horizon:set(t)

		self.stars:update(dt)
		self.sun:update(dt)
		self.horizon:update(dt)

	end,

	draw = function(self, projection, batch)

		--lg.setBackgroundColor(self.sky)
		local graphic = self.graphic
		lg.setColor(self.sky)
		graphic:draw(projection.x - 1, projection.y - 1, 0, window.width + 2, window.height + 2)

		--lg.rectangle('fill', projection.x, projection.y, window.width, window.height)
		--graphic:draw(projection.x, projection.y, 0, 600, 400)

		lg.setColor(255, 0, 0, 100)
		--graphic:draw(projection.x, projection.y, 0, 200, 200)

		lg.setColor(255, 0, 0)
		--graphic:draw(projection.x, projection.y, 0, 15, 15)

		lg.setColor(0, 255, 0)
		graphic:draw(projection.x + window.width - 15, projection.y + window.height - 15, 0, 15, 15)



		self.stars:draw(projection)
		self.horizon:draw(projection, batch)
		self.sun:draw(projection, batch)

	end,

	hue = function(self, model, t)

		-- use a color model to blend smoothly based on t (0 .. 1)

		local percent = math.floor(t * 100)
		local lower, upper
		local index = percent

		while (not lower) do
			local node = model[index]
			if (node) then
				lower = index
			else
				index = index - 1
			end
		end

		local index = percent

		while (not upper) do
			local node = model[index]
			if (node) then
				upper = index
			else
				index = index + 1
			end
		end

		local index = percent

		local blend, collow, collup, color

		blend = (upper ~= lower) and ((t * 100) - lower) / (upper - lower) or (0)
		blend = easing.inOutQuad(blend, 0, 1, 1)

		collow = model[lower]
		colupp = model[upper]

		color = {
			collow[1] + (colupp[1] - collow[1]) * blend,
			collow[2] + (colupp[2] - collow[2]) * blend,
			collow[3] + (colupp[3] - collow[3]) * blend,
		}

		return color

	end,

}