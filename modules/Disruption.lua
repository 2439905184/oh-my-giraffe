Disruption = class{
	init = function(self, duration, message)

		local w = 160 * window.interface
		local h = 25 * window.interface
		local gw = 0
		local gh = 0
		--local graphic = Graphic('orb')
		local scale = 6
		if graphic then
			gw = graphic:getWidth() * scale + 20
			gh = graphic:getHeight()
		end
		local size = {
			w = w,
			h = h,
			gw = gw,
			gh = gh,
		}

		self.offset = 55 * window.interface

		local ox = w * 0.5
		if gw > 0 then
			ox = ox + (15 + gw) * 0.5
		end

		local position = {
			x = lg.getWidth()*0.5 - ox,
			y = 0,
		}

		self.position = position
		self.timer = 0

		local entry = 1.2
		local exit = 0.3
		self.duration = duration
		self.entry = math.min(entry / duration, duration * (entry) / (entry + exit))
		self.exit = math.min(exit / duration, duration * (exit) / (entry + exit))		

		self.type = 'warning'
		self.active = true
		self.size = size
		self.string = string
		self.font = font
		self.value = 0
		self.interpolated = 0

		self.graphic = Graphic('pixel')
		self.scale = scale
	end,

	update = function(self, dt)

		self.timer = math.min(self.timer + dt, self.duration)
		self.active = self.timer ~= self.duration

		local timer = self.timer
		local duration = self.duration
		local entry = duration * self.entry
		local exit = duration * self.exit
		local value, interpolated = 0, 0
		if timer < entry then
			value = timer / entry
			interpolated = easing.outElastic(value, 0, 1, 1, 2, entry*0.5)
		elseif timer > (duration - exit) then
			value = math.abs((timer - (duration - exit)) / exit - 1)
			interpolated = easing.outCubic(value, 0, 1, 1)
		else
			value = 1
			interpolated = 1
		end

		if self.dismissing then
			self.expire = math.min(self.expire + dt, exit)
			-- increment dismiss timer
			interpolated = interpolated - interpolated * easing.inElastic(self.expire, 0, 1, exit, 1, 0.5)
			if self.expire == exit then
				self.active = false
			end
		end
		self.interpolated = interpolated

		self.value = value

	end,

	dismiss = function(self)
		self.expire = 0
		self.dismissing = true
	end,

	draw = function(self, batch)

		local position = self.position
		local size = self.size
		local offset = self.offset
		local x = position.x
		local y = position.y
		local interpolated = self.interpolated
		local value = self.value

		local oy = interpolated * offset
		local ox = 0--size.w*0.5
		local scale = self.scale
		local graphic = self.graphic
		local timer = self.timer
		local duration = self.duration

		local length = size.w
		local height = size.h
		local progress = length - length * easing.linear(timer / duration, 0, 1, 1)

		-- this could be pixel images instead of rectangles to reduce drawcalls!
		
		batch:setColor(82, 142, 151)
		graphic:add(batch, x + ox, y + oy - height*0.5, 0, length, height + 4)

		batch:setColor(92, 152, 161)
		graphic:add(batch, x + ox, y + oy - height*0.5, 0, length, height)

		local b = 210
		local v =  -60 * (math.cos(timer * math.pi * 6) + 1) * 0.5

		batch:setColor(b + 45, b + v, b, 100)
		graphic:add(batch, x + ox, y + oy - height*0.5, 0, progress, height + 4) 

		batch:setColor(b + 45, b + v, b + v, 200)
		graphic:add(batch, x + ox, y + oy - height*0.5, 0, progress, height)

	end,
}