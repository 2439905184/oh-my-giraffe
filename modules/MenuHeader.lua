MenuHeader = class{
	init = function(self, middle, label, color, switch, action, toggle, icon, symbol, sx, sy, size)

		local position = {
			x = middle,
			y = 0,
		}

		local size = size or 72
		local offset = size * 0.08 * window.interface
		local font = fonts:add('bpreplay-bold.otf', size, window.interface)
		local s = label or ''
		local w = font:getWidth(s)
		local h = font:getHeight(s)
		local size = {
			w = w,
			h = h,
		}

		self.font = font
		self.string = s
		self.scale = 0
		self.alpha = 0
		self.position = position
		self.offset = offset
		self.size = size
		self:clear()

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

	draw = function(self)
		
		local position = self.position
		local x = position.x
		local y = position.y
		local scale = self.scale
		local a = self.alpha
		local r = 50 * scale

		local font = self.font
		local s = self.string
		local w = self.size.w
		local h = self.size.h

		local offset = self.offset

		local index = self.index
		for i = 1, #index do

			local ease = easing.outCubic(index[i].timer, 1, -1, index[i].duration)
			local alpha = a * easing.outCubic(index[i].timer, 0, 1, index[i].duration)

			local ox = index[i].w * 0.5
			local oy = index[i].h * 0.5
			oy = oy + math.ceil(100 * ease)

			local ix = x + index[i].x - (w*0.5) + ox
			local iy = y - (h*0.5) + oy
			iy = iy + math.sin(index[i].oscillate * math.pi * 2 / index[i].period) * index[i].magnitude

			local s = scale * easing.outCubic(index[i].timer, 0, 1, index[i].duration)

			local string = index[i].string

			lg.setColor(82, 142, 151, alpha)
			font:draw(string, ix, iy + offset, 0, s, s, ox, oy)

			lg.setColor(255, 255, 255, alpha)
			font:draw(string, ix, iy, 0, s, s, ox, oy)
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

		local index = {}
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
				oscillate = 0,
				period = 2,
				magnitude = 8,
			}
			index[#index + 1] = component
			total = total + w
			count = count + 1
		end

		self.index = index
	end,

	inputpressed = function(self, id, x, y, mode)
	end,

	inputreleased = function(self, id, x, y, mode)
	end,
}