Horizon = class{
	init = function(self)

		local dawn = Graphic('dawn')
		local dusk = Graphic('dusk')

		self.dawn = dawn
		self.dusk = dusk

		local w = dawn:getWidth()
		local h = dawn:getHeight()

		local size = {
			w = w,
			h = h,
		}

		self.size = size
		self.dawnq = dawnquad
		self.duskq = duskquad

		self.batched = true

	end,

	update = function(self, dt)

		local dawn = self.dawn
		local dusk = self.dusk
		local size = self.size
		local w = size.w * window.width
		local h = size.h

		local time = self.time
		local phase = (math.pi / 8)

		-- should this be scaled according to anything?
		-- this should be fixed, not proportional!
		-- todo, solve this!!!
		-- definitely don't use window.scaling...
		local scale = 8
		

		local a = (math.sin((time * math.pi * 2) + math.pi - phase) + 1) * 255 * 0.5

		local dawn_scale = (math.sin(time * math.pi * 2) + 1) * scale
		local dawn_color = {255, 255, 255}

		local dusk_scale = (math.sin((time * math.pi * 2) + (math.pi*0.7)) + 1) * scale * 0.8
		local dusk_color = {255, 255, 255, a * 0.7}

		self.dawn_scale = dawn_scale
		self.dawn_color = dawn_color

		self.dusk_scale = dusk_scale
		self.dusk_color = dusk_color

	end,

	draw = function(self, projection, batch)

		local size = self.size
		local dawn = self.dawn
		local dusk = self.dusk
		local dawn_scale = self.dawn_scale
		local dusk_scale = self.dusk_scale
		local dawn_color = self.dawn_color
		local dusk_color = self.dusk_color

		batch:setColor(dawn_color)
		dawn:add(batch, projection.x, projection.y + window.height, 0, window.width, dawn_scale, 0, size.h)

		batch:setColor(dusk_color)
		dusk:add(batch, projection.x, projection.y + window.height, 0, window.width, dusk_scale, 0, size.h)

	end,

	set = function(self, time)
		self.time = time
	end,
}