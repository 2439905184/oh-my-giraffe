Fireworks = class{
	init = function(self, w, h)

		-- create a lot of pretty particle systems
		local systems = {}
		local color = {155, 255, 155, 170}

		-- pick better colors here
		local alpha = 210
		local colors = {
			{251, 227, 56, alpha},
			{235, 111, 135, alpha},
			{5, 180, 199, alpha},
			{193, 248, 225, alpha}
		}

		for j = 1, 3 do
			for i = 1, #colors do
				local color = colors[i]
				local system = self:add(w, h, color)
				systems[#systems + 1] = system
			end
		end

		self.systems = systems
		self.expansion = {
			active = false,
			timer = 0,
			duration = 0.1,
		}

	end,

	update = function(self, dt)

		local expansion = self.expansion
		if expansion.active then
			expansion.timer = math.min(expansion.timer + dt, expansion.duration)
			if expansion.timer == expansion.duration then
				expansion.active = false
			end
		end

		local systems = self.systems
		for i = 1, #systems do
			local system = systems[i]
			local particles = system.particles
			particles:update(dt)
			if system.active then
				system.delay = math.max(system.delay - dt, 0)
				if system.delay == 0 then
					particles:start()
					system.active = false
				end
			end
		end

	end,

	draw = function(self, x, y)

		-- draw them around x, y
		local systems = self.systems
		local expansion = self.expansion
		local expand = (expansion.timer / expansion.duration)
		expand = easing.outExpo(expand, 0, 1, 1)
		for i = 1, #systems do
			local system = systems[i]
			local particles = system.particles
			local ox, oy = unpack(system.position)

			ox = ox * expand
			oy = oy * expand

			lg.draw(particles, x + ox, y + oy)
		end

	end,

	start = function(self)

		-- start all the particle systems
		-- maybe have a delay?
		local systems = self.systems
		for i = 1, #systems do
			local system = systems[i]
			local particles = system.particles
			system.active = true
		end

		local expansion = self.expansion
		expansion.active = true

	end,

	add = function(self, w, h, color)

		local size = 8 * window.interface
		local quantity = 50

		local image = colorToImg(color)
		local system = love.graphics.newParticleSystem(image, quantity)
		
		local color1 = {255, 255, 255, 255}
		local color2 = {255, 255, 255, 100}
		
		system:setEmissionRate(quantity)
		system:setSizes(size, size*0.8)
		system:setColors(color1[1], color1[2], color1[3], color1[4], color2[1], color2[2], color2[3], color2[4])
		system:setSpeed(400, 100)
		system:setEmitterLifetime(0.1)
		system:setParticleLifetime(0.45)
		system:setDirection(0)
		system:setSpread(math.pi * 2)
		system:setSpin(math.pi)
		system:setLinearAcceleration(0, 600, 0, 600)
		system:stop()

		local entry = {
			active = false,
			delay = 0.1 * math.random(),
			particles = system,
			position = {-w*0.5 + w * math.random(), -h*0.5 + h * math.random()},
		}

		return entry

	end,
}