Wind = class{
	init = function(self)

		local position = {
			x = 500,
			y = 500,
			z = 1,
		}
		local size = {
			w = 100,
			h = 100,
		}
		local strength = 1
		local gusts = {}

		self.position = position
		self.size = size
		self.strength = strength
		self.gusts = gusts
		local timer = 0
		self.timer = timer
		self.active = false
		self.throttle = 0
		self.label = 'wind'

		-- ideally this is managed by the audio manager, but i'm not sure how to provide continous hooks aside from tags

		-- TODO
		-- this doesn't sound very good anymore..
		local group = templates.assets.audio['wind']
		local source, key
		if group then
			key = wchoose(group.variants)
			if key then
				source = group.variants[key].source
			end
		end

		local audio = source

		audio:setLooping(true)
		audio:setVolume(0)
		audio:setPitch(1)
		audio:play()

		self.audio = audio
		self.volume = 0
		self.pitch = 1
		self.batched = true

		self.graphic = Graphic('sky')

    	observer:register('pause', function() self.audio:pause() end)
		observer:register('resume', function() self.audio:resume() end)

	end,

	update = function(self, dt)

		local active = self.active

		self.throttle = active and math.min(self.throttle + dt, 1) or math.max(self.throttle - dt, 0)
		self.timer = math.max(self.timer - dt, 0)

		if not options.safemode then
			if self.timer == 0 and self.throttle > 0 then
				local x = self.position.x
				local y = self.position.y
				self:add(x, y)
				self.timer = 0.015 + 0.1 * math.abs(self.throttle - 1)
			end
		end

		-- play and pause this if not set
		local fade = easing.inCubic(self.throttle, 0, 1, 1)
		self.volume = 2 * fade

		self.pitch = 0.6 + 3.5 * fade

		self.audio:setVolume(self.volume)
		self.audio:setPitch(self.pitch)

		local gusts = self.gusts
		for i,gust in ipairs(gusts) do
			gust.timer = gust.active and math.min(gust.timer + dt, gust.duration) or math.max(gust.timer - dt, 0)
			if gust.timer == gust.duration then
				gust.active = false
			end
			gust.to.x = gust.to.x - 500 * dt * gust.speed
			gust.from.x = gust.from.x + (gust.to.x - gust.from.x) * dt * 10
			gust.opacity = gust.timer / gust.duration
			if not gust.active and gust.timer == 0 then
				table.remove(gusts, i)
			end
		end
	end,

	draw = function(self, projection, batch)
	
		local x = projection.x
		local y = projection.y
		local size = self.size
		local throttle = self.throttle
		local gusts = self.gusts
		local graphic = self.graphic

		for i = 1, #gusts do
			local gust = gusts[i]
			local alpha = gust.opacity * 155 * throttle
			batch:setColor(255, 255, 255, alpha)
			graphic:add(batch, gust.from.x, gust.from.y, 0, gust.to.x - gust.from.x, 3, 0, 0.5)
		end

	end,

	add = function(self, x, y)

		local gusts = self.gusts
		local size = self.size
		
		local x = x + 300 * math.random()
		local y = window.height * math.random()
		local gust = {
			active = true,
			timer = 0,
			duration = 0.2,
			speed = 1 - 0.5 + 0.5 * math.random(),
			opacity = 0,
			from = {
				x = x,
				y = y,
			},
			to = {
				x = x - 60,
				y = y,
			},
		}
		gusts[#gusts + 1]  = gust

	end,

	set = function(self, position)
		self.position = position
	end,
}