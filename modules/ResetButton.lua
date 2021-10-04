ResetButton = class{
	init = function(self)

		local scaling = window.interface
		self.scaling = scaling
		self.padding = 30 * window.interface
		self.font = fonts:add('fontawesome.otf', 43, window.interface)

		-- change to  after resetting?
		-- but back to  once we've bid again?

		self.symbol = ''

		signals.register("leaderboard", function(e) self.reset = false end)
		signals.register('switch', function(state) self.active = state == "leaderboard" end)

		self.active = false
		self.reset = false
		self.timer = 0

	end,

	update = function(self, dt)
		local x, y = lm.getPosition()
		local down = self.down
		self.down = self:check(x, y)
		local active = self.active
		local timer = self.timer
		if active then
			self.timer = math.min(timer + dt * 5, 1)
		else
			self.timer = math.max(timer - dt * 5, 0)
		end
	end,

	draw = function(self)

		local reset = self.reset
		local string = reset and '' or ''
		local font = self.font
		local transition = (self.transition) or (0)
		
		local padding = self.padding
		local x = lg.getWidth() - padding
		local y = padding * transition

		local w = font:getWidth(string)
		local h = font:getHeight(string)

		local depressed = (self.down) and (self.pressed)
		local a = (depressed) and (190) or (140)
		a = a * transition

		local oy = (depressed) and (2) or (0)
		local sy = (depressed) and (1.05) or (1.1)
		local v = 255

		lg.setColor(82, 142, 151, a)
		font:draw(string, x, y + oy, 0, 1, sy, w, 0)

		lg.setColor(v, v, v, a)
		font:draw(string, x, y + oy, 0, 1, 1, w, 0)

	end,

	setTransition = function(self, transition)
		local timer = self.timer
		self.transition = easing.outCubic(timer, 0, 1, 1)
	end,

	mousepressed = function(self, x, y, button)
		if self:check(x, y) then
			self.pressed = true
			sound:emit('click', {pitch = {0.6, 0.8}})
		end
	end,

	mousereleased = function(self, x, y, button)
		if self:check(x, y) and (self.pressed) and (self.down) then
			local reset = self.reset
			if reset then
				sound:emit("drum")
				leaderboard:restore()
			else
				sound:emit("boo")
				observer:emit("shake")
				leaderboard:reset()
			end

			self.reset = not reset
			sound:emit('click')
		end
		self.pressed = false
	end,

	check = function(self, x, y)
		local string = ''
		local font = self.font
		local transition = self.transition or (0)

		if transition > 0.5 then

			local padding = 30

			local width = lg.getWidth()
			local w = font:getWidth(string)
			local h = font:getHeight(string)

			local left = width - w - padding * 2
			local right = width
			local top = 0
			local bottom = h + padding * 2

			local hit = (x < right) and (x > left) and (y < bottom) and (y > top)

			return hit
		end

	end,


}