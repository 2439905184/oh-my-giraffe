-- onscreen score token that is turned into points upon completing a combo
-- now this needs to be styled, and needs to connect to its neicghbor
Orb = class{
	init = function(self, position)

		local sprite = Graphic('orb')
		self.sprite = sprite
		self.sprite_width = sprite:getWidth()
		self.sprite_height = sprite:getHeight()
		self.line = Graphic('pixel')
		self.label = 'orb'

		self.particles = sparkles(30)

		self.position = position
		self.position.z = 1.0000000002
		self.uncullable = true

		self.size = {
			w = 60,
			h = 60,
		}
		self.string = ''
		self.string_width = 0
		self.string_height = 0

		self.scale = 1

		self.offset = {
			x = 30,
			y = 30,
		}

		self.entry = 0
		self.entry_duration = 0.55
		self.color = {131, 76, 69}
		self.connector = {255, 255, 255}

		self.batched = true

	end,

	register = function(self, key)
		self.key = key
	end,

	update = function(self, dt)

		self.timer = self.timer + dt

		-- intro easing
		local entry = self.entry
		local entry_duration = self.entry_duration
		if (entry < entry_duration) then
			self.entry = math.min(entry + dt, entry_duration)
		end
		local delay = self.delay
		local fuse = self.fuse
		local particles = self.particles

		-- start by getting rid of delay
		if delay and (not fuse) then
			self.delay = delay - dt
			if (delay < 0) then
				self.duration = 0.2
				self.fuse = self.duration
				particles:start()
			end
		end


		-- trigger fuse
		if (fuse) then
			particles:update(dt)
			self.fuse = math.max(fuse - dt, 0)
		end

		-- compute colors
		local r, g, b, a
		r = 255
		g = 255
		b = 255
		a = 255

		local flash = self.flash
		if flash then
			self.flash = math.min(flash + dt, 0.1)
			local amount = self.flash / 0.1
			r = r - 100 * amount
			b = b - 100 * amount
		end

		local pulse = self.pulse
		if pulse then
			self.pulse = math.min(pulse + dt, 0.1)
			local amount = self.pulse / 0.1
			g = g - 70 * amount
			b = b - 70 * amount
		end

		self.color = {r, g, b, a}
		self.connector = {r, g, b, 100}

		-- oscilatation
		local rate = 50
		local t = self.timer * math.pi * 2

		if options.combos then
			self.position.y = self.position.y + math.sin(t) * dt * rate
			self.position.x = self.position.x + math.cos(t) * dt * rate
		end

		self.angle = t

		local cooldown = 1
		local magnitude = 0.3
		if self.cooldown then
			self.cooldown = math.max(self.cooldown - dt, 0)
			cooldown = self.cooldown / 0.5
		end
		local emphasis = magnitude + magnitude * math.sin(self.timer * math.pi * 4)
		self.scale = 1 + emphasis * cooldown

		-- I should compute all the stuff for the line and the parent here also!

	end,

	draw = function(self, projection, batch)

		
		-- TODO
		-- refactor this and move it into update!
		-- to improve performance

		local x = projection.x
		local y = projection.y

		local entry = self.entry
		local entry_duration = self.entry_duration
		local fuse = self.fuse
		local duration = self.duration
		local scale = self.scale

		-- deteremine this value in update
		local remaining = 1 * easing.outCubic(entry, 0, 1, entry_duration)

		-- shorten the token connector if in transition
		if fuse then
			remaining = (fuse / duration)
			remaining = easing.inCubic(remaining, 0, 1, 1)
		end

		-- draw the score token connector
		-- determine this position in update...
		local parent = self.parent
		if parent and (not parent.destroyed) then
			-- can do this during update instead?
			local position = parent.asset.position 
			local px = x + (position.x - x) * remaining
			local py = y + (position.y - y) * remaining
			local line = self.line
			local connector = self.connector
			local r = math.atan2(py - y, px - x) - math.pi * 0.5
			local l = math.sqrt((py - y)*(py - y) + (px - x)*(px - x))
			local w = 4

			batch:setColor(connector)
			line:add(batch, x, y, r, w, l, 0.5)
		end

		-- draw the score token sprite
		local sprite = self.sprite
		local color = self.color
		local value = self.value

		local w = self.sprite_width
		local h = self.sprite_height
		local angle = 0
		local size = 4
		size = size * remaining

		batch:setColor(color)
		sprite:add(batch, x, y, angle, size * scale, size * scale, w*0.5, h*0.5)

		-- determine this position in update
		-- draw the score points
		local s = self.string
		local sw = self.string_width
		local sh = self.string_height

		-- set this position in update
		local particles = self.particles
		if particles and fuse then
			particles:setPosition(x, y)
			lg.draw(particles)

			if parent and (not parent.destroyed) then
				local position = parent.asset.position
				local px = x + (position.x - x) * remaining
				local py = y + (position.y - y) * remaining
				particles:setPosition(px, py)
				lg.draw(particles)
			end

		end

	end,

	collect = function(self)
		self.flash = 0
	end,

	phase = function(self, phase)
		self.timer = phase
	end,

	score = function(self, value)
		self.value = value
	end,

	join = function(self, parent)
		self.parent = parent
		parent.child = self.drawable
	end,

	seperate = function(self, parent)
		self.parent = nil
	end,

	pop = function(self, delay)
		self.delay = delay
	end,

	time = function(self, duration)
		self.duration = duration
	end,

	tell = function(self, message, ...)
		if self[message] then
			self[message](self, ...)
		end
	end,

	destroy = function(self)
		local child = self.child
		if child then
			child:seperate()
		end
	end,


}