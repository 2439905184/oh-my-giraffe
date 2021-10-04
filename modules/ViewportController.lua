ViewportController = class{

	init = function(self, enter, focus)

		-- init controller position and zoom level
		self.input = input
		self.position = enter
		self.focus = focus

		self.forces = {}
		self.velocity = {
			x = 0,
			y = 0,
		}

		self.friction = 20
		self.throw = 0.2
		self.elasticity = 1
		self.throttle = 0
		self.locked = not options.skip_start

		observer:register('shake', function() self:shake() end)
		observer:register('jiggle', function() self:jiggle() end)
		observer:register('pulse', function() self:pulse() end)

		viewport = self.position

		self.shaking = {
			amplitude = 1,
			duration = 1,
			timer = 0,
		}

		self.jiggling = {
			amplitude = 0.25,
			duration = 0.6,
			timer = 0,
		}

	end,

	update = function(self, dt)

		if (self.input) and (not self.locked) then

			self.throttle = math.min(self.throttle + dt, 1)

			local velocity, delta, throw
			local dx, dy, x, y = self.input:get()

			self.position.x = self.position.x + dx
			self.position.y = self.position.y + dy

			velocity = self.velocity

			self.velocity = {
				x = dx / dt,
				y = dy / dt,
			}

			throw = self.throw
			delta = {
				x = self.velocity.x - velocity.x,
				y = self.velocity.y - velocity.y,
			}

			self.position.x = self.position.x - delta.x * throw * self.throttle
			self.position.y = self.position.y - delta.y * throw * self.throttle

			

			-- ease to actual position gently
			local gap, elasticity

			elasticity = self.elasticity
			gap = {
				x = x - self.position.x,
				y = y - self.position.y,
			}
			
			self.position.x = self.position.x + gap.x * elasticity * dt
			self.position.y = self.position.y + gap.y * elasticity * dt

		else
			self.throttle = math.max(self.throttle - dt, 0)
		end

		-- shaking
		local shaking = self.shaking
		shaking.timer = (shaking.timer > 0) and math.max(shaking.timer - dt, 0) or (0)
		local dy = math.sin(shaking.timer * math.pi * 6) * (window.height * shaking.amplitude) * dt * (shaking.timer / shaking.duration)
		
		-- jiggling
		local jiggling = self.jiggling
		jiggling.timer = (jiggling.timer > 0) and math.max(jiggling.timer - dt, 0) or (0)
		dy = dy + math.sin(jiggling.timer * math.pi * 6) * (window.height * jiggling.amplitude) * dt * (jiggling.timer / jiggling.duration)
		self.position.y = self.position.y + dy

		if (self.locked) and (self.focus) then

			local x = self.focus.x
			local y = self.focus.y

			local elasticity = self.elasticity * 3.5
			local gap = {
				x = x - self.position.x,
				y = y - self.position.y,
			}

			if options.safemode and false then
				self.position.y = y
			else
				self.position.y = self.position.y + gap.y * elasticity * dt
			end

			self.position.x = self.position.x + gap.x * elasticity * dt

		end

		viewport = self.position

		--print(viewport.x)

		return self.position

	end,

	target = function(self, input)
		if input then
			self.input = input
		end
	end,

	start = function(self)
		self.locked = false
	end,

	-- returns controller position (x, y, z)
	get = function(self)

		local position = self.position
		return position.x, position.y, position.z

	end,

	shake = function(self)
		self.shaking.timer = self.shaking.duration
	end,

	jiggle = function(self)
		self.jiggling.timer = self.jiggling.duration
	end,

	pulse = function(self)
		self.position.z = 1.2
	end,

	zoom = function(self, n)
		self.position.z = math.max(self.position.z + n, 0.005)
	end,

	mousepressed = function(self, x, y, button)
	end,

	mousereleased = function(self, x, y, button)
	end,

	keypressed = function(self, key, code)
	end,

	keyreleased = function(self, key, code)
	end,

	touchpressed = function(self, id, x, y, pressure)
	end,

	touchreleased = function(self, id, x, y, pressure)
	end,

	touchmoved = function(self, id, x, y, pressure)
	end

}