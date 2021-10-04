InputManager = class{
	init = function(self, position, invert)

		local origin = position
		local args = {origin.x, origin.y, invert}

		-- this is messy and unmaintainable!
		local touch = love.touch
		self.input = (touch) and TouchDraggable(unpack(args)) or Draggable(unpack(args))
		self.previous = {x = origin.x, y = origin.y}

		-- this is a very hacky way to get the head to floor on the ground, but maybe the only way
		-- avoid desync of input and controller without skips
		self.floor = (window.height - world.floor)
		self.started = false
		self.triggered = false
		self.input.contained = true

		self.hungry = 0
		self.timer = 0
		self.danger = 0

		signals.register('start', function()
				self.triggered = true
				self.started = true
				self.timer = 0
				self.hungry = 0
				self.danger = 2
			end)

		observer:register('burst', function()
				self.timer = 0
			end)

	end,

	update = function(self, dt)

		local hungry = self.hungry
		local timer = self.timer
		local started = self.started
		if started then
			timer = timer + dt
			if timer > 3 then
				local t = math.max(math.min((timer - 3) / 3, 1), 0)
				hungry = hungry + dt * 50 * t
			else
				hungry = hungry - hungry * dt * 2
			end

			if timer > 6 then
				local danger = self.danger
				danger = math.max(danger - dt, 0)
				if danger == 0 then
					observer:emit('attack')
					danger = 1 + 1 * math.random()
				end
				self.danger = danger
			end

			self.timer = timer
			self.hungry = hungry
		end

		local scaling = window.scaling
		local px, py = self:get()

		local previous = self.previous
		local dx = previous.x - px
		local dy = previous.y - py
		local vy = (dy / dt) / lg.getHeight()
		self.vy = vy
		if vy > 4 then
			-- todo: make this trigger more cleanly
			observer:emit('jump', vy)
		end

		self.previous = {
			x = px,
			y = py,
		}

		local started = self.started
		local triggered = self.triggered
		if not started then
			if (px > window.width * 0.8) then
				signals.emit('start')
			elseif (px > window.width * 0.55) and (not triggered) then
				signals.emit('switch', 'close')
				self.triggered = true
			elseif (px < window.width * 0.5) and (triggered) and (not started) then
				signals.emit('switch', 'root')
				self.triggered = false
			end
		end

		self.input:update(dt, scaling)

	end,

	get = function(self)

		local hungry = self.hungry
		local x, y = self.input:get()
		-- this is the only components resolving desync of input
		x = x - hungry
		y = math.min(y, self.floor)

		return x, y

	end,

	draw = function(self)

		local x, y = self:get()
		lg.setColor(255, 0, 0, 200)
		lg.circle('line', x, y, 6)

		lg.setColor(255, 255 ,255)
		lg.print(self.vy, 15, 400)

	end,

	delta = function(self)

		local x, y = self:get()
		local previous = self.previous
		local dx = (x - previous.x)
		local dy = (y - previous.y)
		return dx, dy

	end,

	mousepressed = function(self, x, y, button)
		self.input:mousepressed(x, y, button)
	end,

	mousereleased = function(self, x, y, button)
		self.input:mousereleased(x, y, button)
	end,

	touchpressed = function(self, id, x, y, pressure)
		if self.input.touchpressed then
			self.input:touchpressed(id, x, y, pressure)
		end
	end,

	touchreleased = function(self, id, x, y, pressure)
		if self.input.touchreleased then
			self.input:touchreleased(id, x, y, pressure)
		end
	end,

	touchmoved = function(self, id, x, y, pressure)
		if self.input.touchmoved then
			self.input:touchmoved(id, x, y, pressure)
		end
	end,

	keypressed = function(self, key, code)
	end,

	keyreleased = function(self, key, code)
	end,
}
