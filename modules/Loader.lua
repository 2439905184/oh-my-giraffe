Loader = class{
	init = function(self, middle, label, color, switch, action, icon, symbol, sx, sy)

		local sprite = Graphic('orb')
		local position = {
			x = middle,
			y = 0,
		}

		local size = sprite:get().size

		self.sprite = sprite
		self.position = position
		self.size = size
		self.scaling = 4

		self.timer = 0
		self.period = 2
		self.amplitude = 150

		self.fscale = 8
		self.fruit = Graphic('edible')

		local font = fonts:add('bpreplay-bold.otf', 50, window.interface)
		local string = 'loading your giraffe'
		self.font = font
		self.string = string
		self.sw = font:getWidth(string)
		self.sh = font:getHeight(string)

	end,

	update = function(self, dt)
		self.timer = self.timer + dt

		if (self.timer >= 2) and (not self.complete) then
			--signals.emit('switch', 'root')
			--signals.emit('create')
			self.complete = true
		end
	end,

	draw = function(self)

		local position = self.position
		local x = position.x
		local y = position.y

		local scale = self.scale or 0
		local scaling = self.scaling

		local a = self.alpha
		local s = scaling * scale
		local sprite = self.sprite

		local size = self.size
		local w = size.w
		local h = size.h

		local timer = self.timer
		local amplitude = self.amplitude
		local period = self.period

		local ox = math.cos(timer * math.pi * 2 / period) * amplitude
		x = x + ox

		local oy = math.sin(timer * math.pi * 2 / period) * amplitude
		y = y + oy

		lg.setColor(255, 255, 255, a)
		sprite:draw(x, y, 0, s, s, w*0.5, h*0.5)

		local fruit = self.fruit

		local fx, fy, fscale
		fx = lg.getWidth() * 0.5
		fy = lg.getHeight() * 0.5

		local fsize, fw, fh
		fsize = fruit:get().size
		fw = fsize.w
		fh = fsize.h

		local fscale = self.fscale
		fscale = fscale * scale
		local oy = math.cos(timer * math.pi * 2 / period + period * 0.5) * 5
		fy = fy + oy

		lg.setColor(255, 255, 255, a)
		fruit:draw(fx, fy, 0, fscale, fscale, fw*0.5, fh*0.5)

		local font = self.font
		local string = self.string
		lg.setColor(82, 142, 151, a)
		font:draw(string, position.x, lg.getHeight() - 70, 0, scale, scale, self.sw*0.5, self.sh*0.5)

	end,

	getSize = function(self)
		return self.sprite:get().size
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