TouchDraggable = class{
	
	init = function(self, x, y, invert)

		self.position = {
			x = x,
			y = y,
		}

		self.friction = 20
		self.touches = {}
		self.forces = {}
		self.inverted = invert

		self.source = function(index)
				local id, x, y, pressure = love.touch.getTouch(index)
				if window.flipped then
					x = math.abs(x - 1)
					y = math.abs(y - 1)
				end
				return id, x, y, pressure
			end

		local padding = 50
		local floor = window.height - world.floor - 30

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

	update = function(self, dt)

		-- get the coords for the active touch
		local count, touches, touching

		touches = self.touches
		count = love.touch and love.touch.getTouchCount() or 0
		touching = (count > 0)

		for index = 1, count do

			touching = true

			-- convert the current touch event's axis ratios to screenspace coords
			local id, x, y, pressure = self.source(index)

			local mx, my
			mx = window.width * x
    		my = window.height * y

    		-- test limiting
    		-- y = math.min(my, self.floor)

    		-- add the offset since last input to the controller's position, scaled by the zoom
    		-- limit to bound
    		local bound = self.bound
    		local px, py

			px = self.position.x + (mx - touches[id].input.x)
			py = self.position.y + (my - touches[id].input.y)

			--self.position.x = math.min(math.max(bound.left.limit, px), bound.right.limit)
			--self.position.y = math.min(math.max(bound.top.limit, py), bound.bottom.limit)
			self:set(px, py)

			touches[id].input.x, touches[id].input.y = mx, my

			-- store the input coordinates into self.cached for use with 
			table.insert(touches[id].cached, touches[id].input)

			-- only remember the last 60 inputs
			if (#touches[id].cached > 60) then
				table.remove(touches[id].cached, 1)
			end
		end

		if not touching then

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

		for k,v in pairs(self.forces) do

			local x, y

			x = self.position.x - (math.cos(v.angle) * v.magnitude) * dt
			y = self.position.y - (math.sin(v.angle) * v.magnitude) * dt

			self:set(x, y)

			local dampening = touching and 10 or 1
			v.magnitude = v.magnitude - (v.magnitude * self.friction * dt * dampening)

			if (v.magnitude < 1) then
				table.remove(self.forces, k)
			end

		end

		return self.position.x, self.position.y

	end,

	touchpressed = function(self, id, x, y)

		self.touches[id] = {
			input = {
				x = x,
				y = y,
			},
			cached = {},
		}


	end,

	touchreleased = function(self, id, x, y)

		local cache, cached, n, count

		-- this is really quite poorly done, using a fixed value
		n = 8
		count = love.touch.getTouchCount()
		cache = (self.touches[id]) and (self.touches[id].cached) or (nil)
		cached = (cache) and (cache[math.max(#cache - n, 1)]) or (nil)

		if cached and not (count > 0) then

			local angle, magnitude, decay, dt, delta

			decay = 0.5
			decay = 1

			dt = 1 / lt.getFPS()
			delta = {
				x = (x - cached.x) / dt,
				y = (y - cached.y) / dt,
			}

			angle = math.atan2(cached.y - y, cached.x - x)
			magnitude = math.sqrt(math.pow(delta.y, 2) + math.pow(delta.x, 2)) * 4

			table.insert(self.forces, {angle = angle, magnitude = magnitude, decay = decay})
			table.insert(self.forces, {angle = angle + math.pi,	magnitude = magnitude * 0.8, decay = decay - 0.2})

		end

		self.touches[id] = nil

	end,

	touchmoved = function(self, id, x, y)
	end,

	mousepressed = function(self, x, y, button)
	end,

	mousereleased = function(self, x, y, button)
	end,

	get = function(self)
		return self.position.x, self.position.y
	end,

	set = function(self, x, y)
		self.position.x = x
		self.position.y = y
	end,

}
