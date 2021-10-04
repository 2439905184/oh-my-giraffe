HintFruit = class{
	init = function(self)

		local position = {
			x = 0,
			y = 0
		}

		local velocity = {
			x = 0,
			y = 0,
		}

		local graphic = Graphic('edible')
		local w = graphic:getWidth()
		local h = graphic:getHeight()
		local size = {w = w, h = h}

		self.position = position
		self.graphic = graphic
		self.size = size
		self.scaling = 5

		self.velocity = velocity
		self.rotation = 0
		self.direction = 0
		self.angle = 0
		self.flipped = false
		self.gravity = 0
		self.jiggle = 1
		self.jiggling = 0

		self.entry = 0
		self.exit = 1

		self.timer = 0
		self.duration = 2.4

		local keyframes = {
			[0] = {
				triggered = false,
				callback = function()
					sound:emit('pop', {delay = 0.05})
				end,
			},
			[25] = {
				triggered = false,
				callback = function()
					self.falling = true
				end,
			},
			[46] = {
				triggered = false,
				callback = function()
					sound:emit('bounce')
					self.flipped = true
					self.falling = false
					self.velocity.y = -300 * window.interface
					self.velocity.x = -60 * window.interface
					self.direction = -5
					self.gravity = 0
				end,
			},
		}

		self.keyframes = keyframes

	end,

	update = function(self, dt)

		self.timer = math.min(self.timer + dt, self.duration)

		self.entry = easing.outElastic(math.min(self.timer / (0.4 * self.duration), 1), 0, 1, 1, 0.3, 0.3)
		self.exit = easing.outCubic(math.max((self.timer - (0.8 * self.duration)) / (0.2 * self.duration), 0), 1, -1, 1)

		local playhead = 100 * (self.timer / self.duration)

		local keyframes = self.keyframes
		for percent,keyframe in spairs(keyframes) do
			if (playhead >= percent) and (not keyframe.triggered) then
				keyframe.triggered = true
				keyframe.callback()
			end
		end

		if self.timer == self.duration then
			self:reset()
		end

		-- update the actual lion!

		local position = self.position
		local velocity = self.velocity
		local flipped = self.flipped
		if flipped then
			self.gravity = self.gravity + 1800 * dt * window.interface
			self.velocity.y = self.velocity.y + self.gravity * dt * 2
			self.velocity.x = self.velocity.x - self.velocity.x * dt * 0.2
			self.rotation = self.rotation + dt * self.direction
			self.jiggling = self.jiggling + dt
			self.jiggle = 1 + 0.5 * math.sin(-self.jiggling * math.pi * 4) * math.abs(math.min(self.jiggling / 0.4, 1) - 1)
			-- rotate
			-- move
		end

		local falling = self.falling
		if falling then
			self.gravity = self.gravity + 1800 * dt * window.interface
			self.velocity.y = self.velocity.y + self.gravity * dt * 2
			self.rotation = self.rotation + dt * self.direction
		end

		local rotation = self.rotation
		local angle = self.angle

		position.y = position.y + velocity.y * dt
		position.x = position.x + velocity.x * dt
		self.angle = angle + rotation * dt

	end,

	-- I could also pass scale and opacity here
	-- though it is pretty hacky
	draw = function(self, cx, cy, scale, alpha)

		local graphic = self.graphic
		local position = self.position
		local size = self.size

		local x = cx + position.x
		local y = cy + position.y
		local a = self.angle
		local w = size.w
		local h = size.h

		local entry = self.entry
		local exit = self.exit

		local scaling = self.scaling
		local jiggle = self.jiggle
		local scale = scale * scaling * entry * exit * jiggle

		local alpha = alpha * exit

		lg.setColor(255, 255, 255, alpha)
		graphic:draw(x, y, a, scale, scale, w*0.5, h*0.5)

	end,

	reset = function(self)
		self.timer = 0
		self.flipped = false
		self.position.x = 0
		self.position.y = 0
		self.velocity.x = 0
		self.velocity.y = 0
		self.gravity = 0
		self.rotation = 0
		self.direction = 0
		self.angle = 0
		self.entry = 0
		self.jiggle = 1
		self.jiggling = 0
		self.graphic = Graphic('edible')
		local keyframes = self.keyframes
		for _,keyframe in pairs(keyframes) do
			keyframe.triggered = false
		end
	end,
}