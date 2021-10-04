Draggable = class{
	
	init = function(self, x, y, invert)

		self.position = {
			x = x,
			y = y,
		}

		self.input = {
			x = x,
			y = y,
		}

		self.inverted = invert
		self.friction = 20
		self.forces = {}
		self.cached = {}
		self.contained = true

		self.source = function()
				local x, y = lm.getPosition()
				if window.flipped then
					local w, h = lg.getWidth(), lg.getHeight()
					x = math.abs(x - w)
					y = math.abs(y - h)
				end
				return x, y
			end

		-- how do I get the player head height here besides making the player head origin different?
		-- oh god this is horrible
		local floor = window.height - world.floor - 30
		local padding = 50

		self.bound = {
			left = {
				edge = padding,
				limit = -padding*2,
				angle = math.pi,
			},
			right = {
				edge = window.width - padding,
				limit  = window.width + padding*2,
				angle = 0,
			},
			top = {
				edge = padding,
				limit = -padding*2,
				angle = 3 * math.pi / 2,
			},
			bottom = {
				edge = window.height,
				limit = window.height,
				angle = math.pi / 2,
			}
		}

		self.floor = floor

	end,

	update = function(self, dt, zoom)

		local sign = self.inverted and 1 or -1

		if lm.isDown('l') then

			local bound = self.bound
			local mx, my = self.source()

			local x, y

			x = self.position.x + (mx - self.input.x) / zoom * sign
			y = self.position.y + (my - self.input.y) / zoom * sign

			self:set(x, y)
			self.input.x, self.input.y = mx, my

			-- store the input coordinates into self.cached for use with 
			table.insert(self.cached, {
					x = mx,
					y = my,
				})

		end

		local rate = 500 / zoom

		for k,v in pairs(self.forces) do

			local sign, x, y

			sign = self.inverted and 1 or -1

			x = self.position.x - (math.cos(v.angle) * v.magnitude) * dt * sign
			y = self.position.y - (math.sin(v.angle) * v.magnitude) * dt * sign

			self:set(x, y)

			local dampening = 1
			if lm.isDown('l') then
				dampening = 1
			end

			v.magnitude = v.magnitude - (v.magnitude * self.friction * dt * dampening * v.decay)

			if (v.magnitude < 1) then
				table.remove(self.forces, k)
			end

		end


		if options.gamepad then
			-- test joystick
			local sensitivity = 750
			local joysticks = love.joystick.getJoysticks()
			for i, joystick in ipairs(joysticks) do
				local gamepad = joystick:isGamepad()
				if gamepad then
					local s = joystick:getName()
					local count = joystick:getAxisCount()
					love.graphics.print(s, 10, i * 20)

					local filter = 5
					local dx = joystick:getAxis(3) * filter
					local dy = joystick:getAxis(4) * filter

					dx = dx > 0 and math.floor(dx) or math.ceil(dx)
					dy = dy > 0 and math.floor(dy) or math.ceil(dy)

					dx = dx * 1 / filter
					dy = dy * 1 / filter * 1.3

					local x = self.position.x + (sensitivity * dx) * dt
					local y = self.position.y + (sensitivity * dy) * dt
					self:set(x, y)
					
				end
			end
		end


		-- this is not going to work just like that, I need it have a rate or only trigger once...
		if not lm.isDown('l') then

			local forces, magnitude, decay, bound, x, y, anchor, angles

			x, y = self.position.x, self.position.y
			forces = self.forces
			bound = self.bound

			magnitude = 10000
			amplification = 1
			decay = 0.8

			anchor = math.atan2(y - (window.height / 2), x - (window.width / 2))
			angles = {}

			local contained = self.contained

			if contained then
				if x < bound.left.edge then
					table.insert(angles, bound.left.angle)
					if x < bound.left.limit then
						amplification = amplification + 5
					end
				end

				if x > bound.right.edge then
					table.insert(angles, bound.right.angle)
					if x > bound.right.limit then
						amplification = amplification + 5
					end
				end

				if y < bound.top.edge then
					table.insert(angles, bound.top.angle)
					if y < bound.top.limit then
						amplification = amplification + 5
					end
				end

				if y > bound.bottom.edge then
					table.insert(angles, bound.bottom.angle)
					if y > bound.bottom.limit then
						amplification = amplification + 5
					end
				end

				magnitude = magnitude * amplification * dt

				for i, angle in ipairs(angles) do
					table.insert(forces, {angle = angle, magnitude = magnitude * 1.5, decay = decay})
					table.insert(forces, {angle = angle + math.pi, magnitude = magnitude * 0.8, decay = decay - 0.25})
					table.insert(forces, {angle = anchor, magnitude = magnitude * 0.5, decay = decay - 0.1})
				end
			end

		end

		return self.position.x, self.position.y

	end,

	mousepressed = function(self, x, y, button)

		self.input.x, self.input.y = self.source()
		self.cached = {}

	end,

	mousereleased = function(self, x, y, button)

		if (#self.cached > 0) then

			local n = 5
			local cached = self.cached[math.max(#self.cached - n, 1)]

			if cached then

				--local amplification = math.min(math.max(#self.cached - n, 1), 10) * 5
				local decay = 1
				local angle = math.atan2(cached.y - y, cached.x - x)

				local dt = 1 / lt.getFPS()
				local delta = {
					x = (x - cached.x) / dt,
					y = (y - cached.y) / dt,
				}

				local magnitude = math.sqrt(math.pow(delta.y, 2) + math.pow(delta.x, 2)) * 0.25

				table.insert(self.forces, {angle = angle, magnitude = magnitude, decay = decay})
				table.insert(self.forces, {angle = angle + math.pi, magnitude = magnitude * 0.6, decay = decay - 0.2})

			end

		end

	end,

	get = function(self)

		local position
		position = self.position

		--return self.position.x, self.position.y
		return position.x, position.y

	end,

	set = function(self, x, y)
		self.position.x = x
		self.position.y = y
	end,

}

DirectionalController = class{
	
	init = function(self, x, y)

		self.position = {
			x = x,
			y = y,
		}

		self.input = {
			x = x,
			y = y,
		}

		self.friction = 5.99
		self.forces = {}
		self.cached = {}
		self.moving = true

	end,

	update = function(self, dt)

		local rate = 800

		if lk.isDown('d') then
			self.position.x = self.position.x + rate * dt
		end

		if lk.isDown('a') then
			self.position.x = self.position.x - rate * dt
		end

		if lk.isDown('w') then
			self.position.y = self.position.y - rate * dt
		end

		if lk.isDown('s') then
			self.position.y = self.position.y + rate * dt
		end

		if lk.isDown('f') then
			self.position.x = self.position.x + (50000) * dt
		end

		-- temp static velocity of 200 units

		local velocity = 230

		self.position.x = self.moving and self.position.x + velocity * dt or self.position.x

		table.insert(self.cached, {x = self.position.x, y = self.position.y})
		if (#self.cached > 60) then
			table.remove(self.cached, 1)
		end

	end,

	get = function(self)
		local dx, dy, cached, x, y

		cached = self.cached[math.max(#self.cached - 1, 1)]
		if cached then
			dx, dy = self.position.x - cached.x, self.position.y - cached.y
		else
			dx, dy = 0, 0
		end

		x, y = self.position.x, self.position.y


		return dx, dy, x, y
	end,

	mousepressed = function(self, x, y, button)
	end,

	mousereleased = function(self, x, y, button)
	end,

	keypressed = function(self, key, code)
		if key == 'h' then
			self.moving = not self.moving
		end
	end,

}