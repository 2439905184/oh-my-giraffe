TimeManager = class{
	init = function(self)

		local time, duration
		duration = options.day_length
		time = options.start_time * duration

		self.time = time
		self.duration = duration
		self.day = 0
		self.daytime = true

		self.started = false
		self.elapsed = 0

		g["time"] = self

	end,

	update = function(self, dt)
		local time = self.time
		local duration = self.duration

		if options.time then
			self.time = time + dt
		end

		local day = self.daytime
		local t = time / duration
		if (day) and (t >= 0.85 or t < 0.15) then
			self.daytime = false
			observer:emit('evening')
			-- this belongs in the musicmanager
			music.target = 1
			sound:emit('wolf')
		elseif (not day) and (t < 0.85 and t >= 0.15) then
			self.daytime = true
			observer:emit('morning')
			music.target = 0
			sound:emit('chirp')
		end

		if (time > duration) then
			self.time = 0
			self.day = self.day + 1
			metrics:add('days', 1)
		end

		-- emit signals for day and night time?

		local started = self.started
		if started then
			local elapsed = self.elapsed
			self.elapsed = elapsed + dt
			metrics:set('elapsed', elapsed)
		end

		metrics:set('time', self.time / self.duration)
	end,

	draw = function(self)
		--lg.print(self.day, 100, 100)
	end,

	get = function(self)
		return self.elapsed
	end,

	start = function(self)
		self.started = true
		self.elapsed = 0
	end,

}