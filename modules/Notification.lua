-- + this needs to ease in the bottom
-- it needs to support a graphic icon
-- + it needs to support a string

Notification = class{
	init = function(self, duration, message, graphic, scale)


		local scaling = window.interface
		self.scaling = scaling

		local string = message


		local font = fonts:add('bpreplay-bold.otf', 50, window.interface)

		local w = font:getWidth(message)
		local h = font:getHeight(message)
		local gw = 0
		local gh = 0


		local scale = 2 * scaling
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
			x = lg.getWidth()*0.5 - ox,
			y = lg.getHeight() + 40 * window.interface,
		}

		self.position = position
		self.timer = 0

		self.duration = duration
		self.entry = 0.5
		self.exit = 0.2
		self.offset = -140 * window.interface



		self.active = true
		self.size = size
		self.string = string
		self.font = font
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

	draw = function(self, batch)
		local string = self.string
		local notification_font = self.font
		local position = self.position
		local size = self.size
		local x = position.x
		local y = position.y

		local offset = self.offset
		local oy = self.interpolated * offset
		local ox = size.w*0.5
		ox = 0
		local scale = self.scale
		local graphic = self.graphic
		local scaling = self.scaling
		local font = self.font

		lg.setColor(82, 142, 151)
		font:draw(string, x + ox + size.gw, y + 4 * scaling + oy, 0, 1, 1, ox, size.h*0.5)

		lg.setColor(255, 255, 255)
		font:draw(string, x + ox + size.gw, y + oy, 0, 1, 1, ox, size.h*0.5)

		if graphic then

			batch:setColor(0, 0, 0, 30)
			graphic:add(batch, x - ox, y + oy + 4 * scaling, 0, scale, scale, 0, size.gh*0.5)

			batch:setColor(255, 255, 255)
			graphic:add(batch, x - ox, y + oy, 0, scale, scale, 0, size.gh*0.5)

		end
	end,
}