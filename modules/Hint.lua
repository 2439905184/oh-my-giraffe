Hint = class{
	init = function(self, middle, label)

		local position = {
			x = middle,
			y = 0,
		}

		local size = {w = 400, h = 300 * window.interface}
		self.position = position
		self.size = size

		self.cycles = {}

		self.lion = HintLion()
		self.fruit = HintFruit()







		-- ideally there is some motion to the lion as it gets hit
		--[[

			vine
			fruit
			lion 


		what is the best way to sequence this?
		I want to be able to tweak the timings without a lot of pain, so maybe... hmm...

		]]--

	end,

	update = function(self, dt)

		self.lion:update(dt)
		self.fruit:update(dt)

	end,

	draw = function(self)

		local position = self.position
		local x = position.x
		local y = position.y
		local size = self.size
		local w = size.w
		local h = size.h

		local graphic = self.lion
		local scale = self.scale * window.interface
		local alpha = self.alpha

		self.lion:draw(x, y + h*0.2, scale, alpha)
		self.fruit:draw(x, y - h*0.4, scale, alpha)


		--[[
		local graphics = self.graphics

		local lion = graphics.lion


		-- i should really know the top of this entry

		local ly = y + w*0.15
		
		lg.setColor(255, 255, 255, alpha)
		lion.graphic:draw(x, ly, 0, scale * lion.scaling, scale * lion.scaling, lion.w*0.5, lion.h*0.5)

		local fruit = graphics.fruit

		local timer = self.timer

		local fy = y - w*0.5 + (w*0.5) * timer

		fruit.graphic:draw(x, fy, 0, scale*fruit.scaling, scale*fruit.scaling, fruit.w*0.5, fruit.h*0.5)

		]]--

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
		
	end,

	trigger = function(self)

		local cycle = {}


	end,

	inputpressed = function(self, id, x, y, mode)
	end,

	inputreleased = function(self, id, x, y, mode)
	end,
}