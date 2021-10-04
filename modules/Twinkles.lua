Twinkles = class{
	init = function(self, n)

		local duration = math.pi
		local quantity = n or 3
		local parts = {}

		for i = 1, quantity do
			local index = (quantity - i) / quantity
			local start = index * duration
			parts[i] = {
				string = '*',
				timer = start,
			}
		end

		self.duration = duration
		self.parts = parts
		self.transitions = {
			value = 0,
			duration = 1,
			active = true,
		}

	end,

	update = function(self, dt)

		local transitions = self.transitions

		if (transitions.value ~= 0) or (transitions.value ~= transitions.duration) then
			if transitions.active then
				transitions.value = math.min(transitions.value + dt, transitions.duration)
			else
				transitions.value = math.max(transitions.value - dt, 0)
			end
		end

		local parts = self.parts
		local duration = self.duration

		for i = 1, #parts do
			parts[i].timer = parts[i].timer + dt
			if (parts[i].timer > duration) then
				parts[i].timer = 0
			end
		end

	end,

	draw = function(self, position)

		local parts = self.parts
		local duration = self.duration

		local transitions = self.transitions
		local transition = easing.outExpo(transitions.value, 0, 1, 1)
		local alpha = 255 * transition

		lg.setColor(255, 255, 255, alpha)
		local offset = 30
		local slope = 1.2
		local amplitude = 4

		for i = 1, #parts do
			
			local stagger = (i - 1) * 25 * transition
			local scale = 1 + 0.05 * math.sin(parts[i].timer * math.pi * 2 / duration)

			local x = position.x + stagger * slope + amplitude * -math.cos(parts[i].timer * math.pi * 2 / duration)
			local y = position.y - stagger + amplitude * math.sin(parts[i].timer * math.pi * 2 / duration)
			y = y - offset * 2
			x = x + offset

			local x = position.x
			local y = position.y

			local t = parts[i].timer / duration
			t = t * math.pi * 2
			local ox = math.cos(t)
			local oy = math.sin(t)

			x = x + ox * 30
			y = y + oy * 5

			local s = parts[i].string
			local w = font:getWidth(s)
			local h = font:getHeight(s)

			-- draw the snore components
			lg.print(s, x, y, 0, scale, scale, w, h)

		end

	end,

	enter = function(self)
		self.transitions.active = true
	end,

	exit = function(self)
		self.transitions.active = false
	end,
}