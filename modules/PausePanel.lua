PausePanel = class{
	init = function(self)

		local scaling = window.interface
		self.scaling = scaling
		self.padding = 30 * window.interface
		self.font = fonts:add('fontawesome.otf', 43, window.interface)

	end,

	update = function(self, dt)
		local x, y = lm.getPosition()
		local down = self.down
		self.down = self:check(x, y)
	end,

	draw = function(self)

		local string = ''
		local font = self.font
		local transition = (self.transition) or (0)
		
		local padding = self.padding
		local x = padding
		local y = padding * transition

		local w, h
		local w = font:getWidth(string)
		local h = font:getHeight(string)

		local depressed = (self.down) and (self.pressed)
		local a = (depressed) and (190) or (140)
		a = a * transition

		local oy = (depressed) and (2) or (0)
		local sy = (depressed) and (1.1) or (1.15)
		local v = 255

		lg.setColor(82, 142, 151, a)
		font:draw(string, x, y + oy, 0, 1, sy, 0, 0)

		lg.setColor(v, v, v, a)
		font:draw(string, x, y + oy, 0, 1, 1, 0, 0)

	end,

	setTransition = function(self, transition)
		self.transition = transition
	end,

	mousepressed = function(self, x, y, button)
		if self:check(x, y) then
			self.pressed = true
			sound:emit('click', {pitch = {0.6, 0.8}})
		end
	end,

	mousereleased = function(self, x, y, button)
		if self:check(x, y) and (self.pressed) and (self.down) then
			signals.emit('pause')
			sound:emit('click')
		end
		self.pressed = false
	end,

	check = function(self, x, y)
		local string = ''
		local font = self.font
		local transition = self.transition or (0)

		if transition > 0.5 then

			local padding
			padding = 30

			local w, h
			w = font:getWidth(string)
			h = font:getHeight(string)

			local left = 0
			local right = w + padding * 2
			local top = 0
			local bottom = h + padding * 2

			local hit = (x < right) and (x > left) and (y < bottom) and (y > top)

			return hit
		end

	end,


}