ProgressManager = class{
	
	init = function(self, location, length)

		self.location = location
		self.progress = location
		self.target = location
		self.length = length

		local base = options.player_speed
		local boost = function(n) return easing.inCubic(n, 0, 1, 1) * options.player_boost end

		self.max = options.player_max
		self.cap = options.player_cap
		self.base = base
		self.acceleration = 0
		self.boost = boost
		self.min = 0

		self:broadcast()

	end,

	update = function(self, dt)

		local previous = self.location
		local delta = self.throttle * dt

		local resistance = 2
		local elasticity = 8

		-- double-lerp the location from the target
		self.target = self.target - (self.target) * delta
		self.progress = self.progress + (self.target - self.progress) * resistance * delta
		self.location = self.location + (self.progress - self.location) * elasticity * delta

		-- save the change in location
		self.delta = self.location - previous

		self.base = math.min(self.base + self.acceleration * dt, self.cap)
		self:broadcast()
		-- update the game speed global (I really don't like this approach)

	end,

	draw = function(self)

		lg.setColor(150, 200, 200)
		lg.circle('line', window.width * self.location, window.height - world.floor, 15)
		lg.circle('line', window.width * self.progress, window.height - world.floor, 25)
		lg.circle('line', window.width * self.target, window.height - world.floor, 35)

	end,

	bound = function(self, n)
		self:set(n)
	end,

	limit = function(self, n)
		local min = self.min
		self.throttle = clamp(n, min, 1)
	end,

	move = function(self, n)
		local resistance = 2
		self:set(self.target + n * resistance)
	end,

	set = function(self, n)
		local min = self.min
		self.target = clamp(n, min, 1)
	end,

	get = function(self)
		local dx, dy = self.delta * self.length, 0
		return dx, dy
	end,

	broadcast = function(self)
		local base = self.base
		local boost = self.boost
		local max = self.max
		local location = self.location
		player_speed = math.min(base + boost(location), max)
	end,

	setAcceleration  = function(self, n)
		self.acceleration = n
	end,

}