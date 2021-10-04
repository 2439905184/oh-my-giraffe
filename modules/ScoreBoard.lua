ScoreBoard = class{
	init = function(self, middle, label, color, switch, action, icon, symbol, sx, sy)

		local position = {
			x = middle,
			y = 0,
		}

		local font = lg.newFont('assets/fonts/bpreplay-bold.otf', 81)
		local _, _ = font:getWidth('dummy-init'), font:getHeight('dummy-init')
		font:setFilter('linear', 'linear')
		local s = label or ''
		local w = font:getWidth(s)
		local h = font:getHeight(s)

		local size = {
			w = w,
			h = h,
		}

		local sizes = {}

		self.font = font
		self.string = s
		self.position = position
		self.size = size
		self.scale = 0

	end,

	update = function(self, dt)

		-- probably only ned to calculate this once...
		local scale = self.scale
		if scale > 0 then
			local font = self.font
			local s = comma_value(metrics:get('score'))
			local w = font:getWidth(s)
			local h = font:getHeight(s)

			local size = {
				w = w,
				h = h - 20,
			}
			self.size = size
			self.string = s
		end
	end,

	draw = function(self)

		local position, x, y
		position = self.position
		x = position.x
		y = position.y

		local scale = self.scale

		local a = self.alpha
		local r = 50 * scale

		local font, w, h, s
		font = self.font
		s = self.string
		w = self.size.w
		h = self.size.h

		lg.setFont(font)

		lg.setColor(82, 142, 151, a)
		lg.print(s, x, y + 6, 0, scale, scale, w*0.5, h*0.5)

		lg.setColor(255, 255, 255, a)
		lg.print(s, x, y, 0, scale, scale, w*0.5, h*0.5)

	end,

	getSize = function(self)
		return self.size
	end,

	report = function(self, data)
		self.data = data.score or self.data
	end,

	target = function(self, x, y, scale, alpha)
		self.position.x = x
		self.position.y = y
		self.scale = scale
		self.alpha = math.min(alpha, 255)
	end,

	inputpressed = function(self, id, x, y, mode)
	end,

	inputreleased = function(self, id, x, y, mode)
	end,
}