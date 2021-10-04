LionLegs = class{
	init = function(self, variant)

		self.position = {
			x = 0,
			y = 0,
			z = 1,
		}

		local running = Graphic('lion_legs')
		--local flipped = Graphic('lion_legs_flipped')
		local leaping_fore = Graphic('lion_legs_leaping_fore')
		local leaping_hind = Graphic('lion_legs_leaping_hind')
		local sleeping_fore = Graphic('lion_legs_sleeping_fore')
		local sleeping_hind = Graphic('lion_legs_sleeping_hind')

		local state = 'running'


		local scale = 4
		local rate = 0.07

		local w = running:getWidth()
		local h = running:getHeight()
		local size = {
			w = w,
			h = h,
		}

		local label, offset

		if (variant == 'forelegs') then
			label = 'forelegs'
			offset = {
				x = size.w - 4,
				y = 0,
			}
		else
			label = 'hindlegs'
			running:seek(6)
			offset = {
				x = 4,
				y = 0,
			}
		end

		self.running = running
		self.leaping_fore = leaping_fore
		self.leaping_hind = leaping_hind
		self.sleeping_fore = sleeping_fore
		self.sleeping_hind = sleeping_hind
		self.jumping = jumping
		self.resting = resting
		self.flipped = flipped

		self.batched = true

		self.skidding = skidding
		self.state = state
		self.offset = offset
		self.label = label
		self.rate = rate
		self.scale = scale
		self.size = size
		self.angle = 0
		self.shear = 0
		self.color = {255, 255, 255}

	end,

	update = function(self, dt)
		self[self.state]:update(dt)
	end,

	draw = function(self, projection, batch)

		local graphic = self[self.state]
		batch:setColor(self.color)
		graphic:add(batch, projection.x, projection.y, self.angle, self.scale, self.scale, self.offset.x, self.offset.y, self.shear)
		
	end,

	set = function(self, x, y, angle, shear)
		self.position.x = x
		self.position.y = y
		self.angle = angle
		self.shear = shear
	end,

	getWidth = function(self)
		return self[self.state]:getWidth()
	end,

	getHeight = function(self)
		return self[self.state]:getHeight()
	end,

	setState = function(self, state)
		self.state = state
	end,

	setRate = function(self, n)
		self[self.state]:setRate(n)
	end,

	setColor = function(self, color)
		self.color = color
	end,
}