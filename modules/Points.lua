-- onscreen score token that is turned into points upon completing a combo
-- now this needs to be styled, and needs to connect to its neicghbor
Points = class{
	init = function(self, position)

		self.font = fonts:add('bpreplay-bold.otf', 40)
		self.value = 1

		local x = position.x
		local y = position.y - 32
		self.position = {x = x, y = y}
		self.position.z = 1.0000000001
		self.uncullable = true

		self.string = ''
		self.string_width = 0
		self.string_height = 0

		self.scale = 0

		self.entry = 0
		self.entry_duration = 0.55

		self.exit = 0
		self.exit_duration = 0.2

		self.timer = 0
		self.duration = 1.15
		self.prompt = 1

		self.angle = -math.pi / 2
		self.rotation = 0
		self.speed = 70

		self.batched = true

	end,

	register = function(self, key)
		self.key = key
	end,

	update = function(self, dt)

		local timer = self.timer
		local duration = self.duration
		self.timer = math.min(timer + dt, duration)

		if timer == duration then
			local objects = g["objects"]
			local key = self.key
			objects:remove(key)
			return
		end


		-- intro easing
		local entry = self.entry
		local entry_duration = self.entry_duration
		if (entry < entry_duration) then
			self.entry = math.min(entry + dt, entry_duration)
		end

		local entrance = easing.outElastic(entry, 0, 1, entry_duration, 1, 0.4)
		
		-- todo: ease out
		local exit = 1
		local t = timer / duration
		local exit = (t > 0.85) and math.abs((t - 0.85) / -0.15) or (0)
		local scale = entrance - easing.inOutCubic(exit, 0, 1, 1)

		local speed = self.speed
		local angle = self.angle

		local position = self.position
		local x, y = position.x, position.y
		x = x + math.cos(angle) * speed * dt
		y = y + math.sin(angle) * speed * dt

		position.x = x
		position.y = y

		local angle = self.angle
		self.angle = angle

		self.scale = scale

	end,

	draw = function(self, projection, batch)

		local x = projection.x
		local y = projection.y
		local scale = self.scale

		local font = self.font
		local angle = self.angle
		local s = self.string
		local size = self.size
		local w, h = size.w, size.h
		lg.setColor(255, 255, 255)
		font:draw(s, x, y, 0, scale, scale, w*0.5 + 6, h*0.75)

	end,

	set = function(self, value, speed, angle, rotation)

		self.value = value
		local font = self.font
		local string = '+ ' .. comma_value(value)
		local w = font:getWidth(string)
		local h = font:getHeight(string)
		self.string = string
		self.size = {w = w, h = h}

		self.speed = speed or self.speed
		self.angle = angle or self.angle
		self.rotation = rotation or self.rotation

	end,

	join = function(self, parent)
		self.parent = parent
	end,

	tell = function(self, message, ...)
		if self[message] then
			self[message](self, ...)
		end
	end,


}