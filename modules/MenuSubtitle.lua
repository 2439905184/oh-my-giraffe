MenuSubtitle = class{
	init = function(self, middle, label)

		local position = {
			x = middle,
			y = 0,
		}

		local font = fonts:add('bpreplay-bold.otf', 44, window.interface)

		s = label or ''
		w = font:getWidth(s)
		h = font:getHeight(s)
		
		local size = {
			w = w,
			h = h,
		}

		self.font = font
		self.string = s
		self.position = position
		self.size = size
		self:clear()
		self.scale = 0
		self.magnitude = 7
		self.scaling = window.interface

		self.graphic = Graphic('edible', 1)

	end,

	update = function(self, dt)
		local index = self.index
		for i = 1, #index do
			if index[i].delay > 0 then
				index[i].delay = math.max(index[i].delay - dt, 0)
			end
			if index[i].delay == 0 then
				index[i].timer = index[i].timer + dt
				index[i].timer = math.min(index[i].timer, index[i].duration)
			end
			index[i].oscillate = index[i].oscillate - dt
		end
	end,

	draw = function(self, batch)
		
		local position = self.position
		local x = position.x
		local y = position.y

		local scale = self.scale
		local scaling = self.scaling

		local a = self.alpha or 0
		local r = 50 * scale

		local font = self.font
		local s = self.string
		local w = self.size.w
		local h = self.size.h

		local index = self.index
		for i,char in ipairs(index) do

			local ease = easing.outCubic(char.timer, 1, -1, char.duration)
			local alpha = a * easing.outCubic(char.timer, 0, 1, char.duration)
			local ox = char.w * 0.5
			local oy = char.h * 0.5
			oy = oy + math.ceil(100 * ease)
			local ix = x + char.x - (w*0.5) + ox
			local iy = y - (h*0.5) + oy

			iy = iy + math.sin(char.oscillate * math.pi * 2 / char.period) * char.magnitude

			local s = scale * easing.outCubic(char.timer, 0, 1, char.duration)
			local string = char.string
			if string ~= '*' then

				lg.setColor(82, 142, 151, alpha)
				font:draw(char.string, ix, iy + 5 * window.interface, 0, s, s, ox, oy)

				lg.setColor(255, 255, 255, alpha)
				font:draw(char.string, ix, iy, 0, s, s, ox, oy)

			else

				local graphic = self.graphic
				local w = graphic:getWidth()
				local h = graphic:getHeight()
				local scale = 4 * scaling
				local gx = ix - ox + 6 * scaling
				local gy = iy - oy + 4 * scaling
				local gs = s*scale
				local gox = w*0.5/scale


				batch:setColor(0, 0, 0, 30 * (alpha / 255))
				graphic:add(batch, gx, gy + 4, 0, gs, gs, gox)

				batch:setColor(255, 255, 255, alpha)
				graphic:add(batch, gx, gy, 0, gs, gs, gox)

			end
		end

	end,

	getSize = function(self)
		return self.size
	end,

	target = function(self, x, y, scale, alpha)
		self.position.x = x
		self.position.y = y
		self.scale = scale
		self.alpha = math.min(alpha, 255)
	end,

	clear = function(self)
		local font = self.font
		local s = self.string
		local width = font:getWidth(s)
		local index = {}
		local magnitude = self.magnitude or 7
		local total = 0
		local count = 0
		local period = 0.2
		for letter in s:gmatch(".") do
			local w = font:getWidth(letter)
			local h = font:getHeight(letter)
			local component = {
				string = letter,
				w = w,
				h = h,
				x = total,
				delay = (count / #s) * period,
				timer = 0,
				duration = 0.6,
				oscillate = (count / #s) * 2,
				period = 2,
				magnitude = magnitude,
			}
			index[#index + 1] = component
			total = total + w
			count = count + 1
		end

		self.index = index
		self.size.w = width
	end,

	inputpressed = function(self, id, x, y, mode)
	end,

	inputreleased = function(self, id, x, y, mode)
	end,
}