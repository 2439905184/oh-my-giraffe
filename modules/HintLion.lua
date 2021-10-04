HintLion = class{
	init = function(self)

		local position = {
			x = 0,
			y = 0
		}

		local velocity = {
			x = 0,
			y = 0,
		}

		local graphic = Graphic('lion_icon')
		local w = graphic:getWidth()
		local h = graphic:getHeight()
		local size = {w = w, h = h}

		self.position = position
		self.graphic = graphic
		self.size = size
		self.scaling = 3

		self.velocity = velocity
		self.rotation = 0
		self.direction = 0
		self.angle = 0
		self.flipped = false
		self.gravity = 0
		self.flash = 0

		self.entry = 0
		self.exit = 1

		self.timer = 0
		self.duration = 2.4

		local keyframes = {
			[46] = {
				triggered = false,
				callback = function()
					self.flipped = true
					self.velocity.y = -250 * window.interface
					self.velocity.x = 70 * window.interface
					self.direction = 3
					self.hit = true
					sound:emit('whimper', {volume = {0.5, 0.5}})
				end,
			},

			[58] = {
				triggered = false,
				callback = function()
					self.hit = false
				end,
			}
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
			-- rotate
			-- move

		end

		local hit = self.hit
		if hit then
			self.flash = math.min(self.flash + 500 * dt, 120)
		else
			self.flash = math.max(self.flash - 700 * dt, 0)
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

		local x = cx + position.x - 20
		local y = cy + position.y
		local a = self.angle
		local w = size.w
		local h = size.h

		local entry = self.entry
		local exit = self.exit

		local alpha = alpha * exit

		local scaling = self.scaling
		local scale = scale * scaling * entry * exit

		local flash = self.flash
		local r, g, b = 255, 255 - flash, 255 - flash

		lg.setColor(r, g, b, alpha)
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
		self.flash = 0
		self.angle = 0
		self.entry = 0
		local keyframes = self.keyframes
		for _,keyframe in pairs(keyframes) do
			keyframe.triggered = false
		end
	end,
}