ScoreTiles = class{
	init = function(self, middle, label, color, switch, action, icon, symbol, sx, sy)

		local position = {
			x = middle,
			y = 0,
		}

		local font, w, h, s
		font = lg.newFont('assets/fonts/bpreplay-bold.otf', 42)
		local _, _ = font:getWidth('dummy-init'), font:getHeight('dummy-init')
		font:setFilter('linear', 'linear')
		s = label or ''
		w = font:getWidth(s)
		h = font:getHeight(s)

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
		self.data = data.eaten or self.data
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