PlayerController = class{
	
	init = function(self, x, y)
		self.position = {
			x = x,
			y = y,
		}
		self.difficulty = 0
		self.friction = 0.85
		self.forces = {}
		self.cached = {}
		self.throttle = 0
		self.moving = false

	end,

	update = function(self, dt)

		local velocity = player_speed
		local drag = self.friction
		self.throttle = self.moving and math.min(self.throttle + dt * drag, 1) or math.max(self.throttle - dt * drag*2, 0)
		velocity = velocity * easing.inOutQuad(self.throttle, 0, 1, 1)
		
		-- update the controller position
		self.position.x = (velocity > 0) and (self.position.x + velocity * dt) or (self.position.x)

		metrics:add('distance', velocity * dt)

		table.insert(self.cached, {x = self.position.x, y = self.position.y})
		if (#self.cached > 60) then
			table.remove(self.cached, 1)
		end

		--print(self.position.x)

	end,

	get = function(self)


		local cached = self.cached[math.max(#self.cached - 1, 1)]
		local dx, dy
		if cached then
			dx, dy = self.position.x - cached.x, self.position.y - cached.y
		else
			dx, dy = 0, 0
		end
		local x, y = self.position.x, self.position.y
		local throttle = self.throttle

		return dx, dy, x, y, throttle

	end,

	mousepressed = function(self, x, y, button)
	end,

	mousereleased = function(self, x, y, button)
	end,

	keypressed = function(self, key, code)
	end,

	start = function(self)
		self.moving = true
	end,

	stop = function(self)
		self.moving = false
	end,

	slide = function(self)
		self.moving = false
		self.friction = 0.2
	end,

}