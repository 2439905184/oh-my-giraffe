-- + this needs to ease in the bottom
-- it needs to support a graphic icon
-- + it needs to support a string

Warning = class{
	init = function(self, duration, message, notification_font, graphic, scale)

		local string = message

		local w = notification_font:getWidth(message)
		local h = notification_font:getHeight(message)
		local gw = 0
		local gh = 0


		local scale = 2
		local graphic = Graphic('lion_icon')
		if graphic then
			gw = graphic:getWidth()*scale + 15
			gh = graphic:getHeight()
		end
		local size = {
			w = w,
			h = h,
			gw = gw,
			gh = gh,
		}

		local ox = (w + 15 + gw) * 0.5
		local position = {
			x = -100,
			y = lg.getHeight()*0.5 - h*0.5,
		}

		self.position = position
		self.timer = 0

		self.duration = duration
		self.entry = 0.5
		self.exit = 0.2
		self.offset = 140



		self.active = true
		self.size = size
		self.string = string
		self.font = notification_font
		self.value = 0
		self.interpolated = 0

		self.graphic = graphic
		self.scale = scale

	end,

	update = function(self, dt)

		-- i'm just going to hardcode this in an incredibly terrible way

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

		self.interpolated = interpolated
		self.value = value

	end,

	draw = function(self)
		local string = self.string
		local notification_font = self.font
		local position = self.position
		local size = self.size
		local x = position.x
		local y = position.y

		lg.setFont(notification_font)

		local offset = self.offset
		local interpolated = self.interpolated
		local oy = size.h*0.5
		local ox = interpolated * offset
		local scale = self.scale
		local graphic = self.graphic

		lg.setColor(82, 142, 151)
		lg.print(string, x + ox + size.gw, y + 4 + oy, 0, 1, 1, 0, size.h*0.5)

		lg.setColor(255, 255, 255)
		lg.print(string, x + ox + size.gw, y + oy, 0, 1, 1, 0, size.h*0.5)

		if graphic then
			lg.setColor(0, 0, 0, 30)
			graphic:draw(x + ox, y + oy + 4, 0, scale, scale, 0, size.gh*0.5)

			lg.setColor(255, 255, 255)
			graphic:draw(x + ox, y + oy, 0, scale, scale, 0, size.gh*0.5)
		end
	end,
}