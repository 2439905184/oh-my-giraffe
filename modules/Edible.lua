Edible = class{
	init = function(self, graphic, position, vine)

		local size, scale, label, offset, angle



		size = graphic.size
		label = graphic.name

		scale = 5.5 + (math.random() * 0.75)
		local special = graphic.variant == 3
		self.special = special
		if special then
			scale = 6.85
			self.pulse = math.pi * 2 * math.random()
		end
		angle = 0

		offset = {
			x = size.w / 2,
			y = 0,
		}

		local consumed = false
		local attached = true
		local attributes = {
			threshold = 0.75 * scale,
			rate = {
				eating = 4 * scale,
				popping = 20,
			},

		}

		local variation = 80
		local r, g, b = graphic:getColor()
		local color = {255 - (variation / 2) * math.random(), 255 - variation * math.random(), 255 - (variation / 2) * math.random()}

		local particle_size = 7
		local particle_amount = 30

		-- TODO
		-- switch the psystem color to the actual edible color...
		local particles = psystem({r, g, b}, particle_size, particle_amount)
		local shade = {255 - 45 * math.random(), 255 - 65 * math.random(), 255 - 45 * math.random()}

		if special then
			shade = {255, 220, 255}
		end

		r = r * (color[1] / 255)
		g = g * (color[2] / 255)
		b = b * (color[3] / 255)

		local velocity = {
			x = 0,
			y = 0,
		}

		local rate = (1300 / 640) * window.height
		local gravity = {
			pull = 0,
			rate = rate,
		}

		local wobbling = {
			timer = 0,
			duration = 0.25,
			amount = 0.5,
		}

		self.fruit_color = {r, g, b}
		self.vine = vine
		self.label = 'edible'
		self.sprite = sprite
		self.graphic = graphic
		self.position = position
		self.position.z = 1.0000000001
		self.size = size
		self.scale = scale
		self.original = scale
		self.offset = offset
		self.angle = angle
		self.attributes = attributes
		self.consumed = consumed
		self.consume = consumed
		self.snapped = false
		self.bounced = false
		self.squashed = false
		self.particles = particles
		self.velocity = velocity
		self.rotation = 0
		self.attached = attached
		self.grounded = false
		self.gravity = gravity
		self.color = shade
		self.wobbling = wobbling
		self.cooldown = 0
		self.static = true
		self.batched = true

		if special then
			self.batched = false
			self.static = false
		end

		metrics:add('spawned', 1)

	end,

	register = function(self, key)

		-- TODO
		-- CRITICAL
		-- registering this with the mouth causes a lot of performance problems on iOS
		observer:emit('collidable', key, {'mouth', 'net'})
		self.key = key
	end,

	update = function(self, dt)

		local squashed
		squashed = self.squashed

		self.particles:update(dt)

		local special = self.special
		if special then
			--local glow = self.glow
			--glow:update(dt)
			local pulse = self.pulse
			self.pulse = pulse + dt
		end


		if self.cooldown > 0 then
			self.cooldown = math.max(self.cooldown - dt, 0)
		end

		if not squashed then

			local scale = self.scale
			if (scale > 0) then

				local grounded
				local consume = self.consume
				local consumed = self.consumed
				local threshold = self.attributes.threshold
				local eating = self.attributes.rate.eating
				local popping = self.attributes.rate.popping

				local attached = self.attached
				local grounded = self.grounded
				local snapped = self.snapped

				-- called once when passes scale threshold
				-- problem code is in here...

				-- if flagged for consumption, reduce the size
				if (consume) then
					local multiplier = (not attached) and (4) or (1)
					self:resize(-eating * dt * multiplier)
				end


				-- if popping, then resize until scale == 0
				if (consumed) and (scale > 0) then
					local scale = self.original
					local delta = -popping * dt * (scale / 6)
					self:resize(delta)
				end

				-- called once when vine snaps halfway through popping
				if ((scale < threshold / 2) or (not attached)) and (not snapped) then

					self.vine:snap()
					self.snapped = true
					-- set CG to middle for correct rotation
					if (not attached) then
						self:shift(0, self.size.h / 2)
					end

				end

				-- deattachement (while in air)
				if (not attached) and (not grounded) then
					
					-- increase the pull of gravity (this should be blended with velocity.y)
					self.gravity.pull = self.gravity.pull + self.gravity.rate * dt

					-- move edible using velocity if not attached
					local dx, dy
					dx = (self.velocity.x) * dt
					dy = (self.velocity.y + self.gravity.pull) * dt
					self:move(dx, dy)

					-- rotate by the spin angle
					self.angle = self.angle + self.rotation * dt

					-- called once when impacting ground
					if (grounded ~= self.grounded) then
						-- maybe spawn a splat here so long as we haven't hit the giraffe or lion body?
						self.gravity.pull = 0
						--print('hit')
					end

				end

				-- if on the ground
				if (grounded) and (self.scale > 0) then

					local drag = 20
					self.velocity.x = self.velocity.x - (self.velocity.x) * dt * drag
					self.rotation = self.rotation - (self.rotation) * dt * drag
					self:resize(-popping * dt * 2)
					self.velocity.y = 0

				end

				self.consume = false

			else
				-- there's no need to update the bound polygon while 
				self.rotates = false
				self.squashed = true
				observer:emit('release_collidable', self.key)

			end


			local wobbling = self.wobbling
			if (wobbling.timer > 0) then
				wobbling.timer = math.max(wobbling.timer - dt, 0)
			end

		end


		-- deactivate this...
		if self.particles and (not self.static) and (self.squashed) then
			if self.particles:getCount() == 0 then
				self.static = true
				self.inactive = true
				observer:emit('release_collider', self.key)
			end
		end

	end,

	draw = function(self, projection, batch)

		local sprite = self.sprite
		local angle = self.angle
		local scale = self.scale
		local offset = self.offset

		-- scale oscillation
		local wobbling = self.wobbling
		if (wobbling.timer > 0) then
			local wobble = math.sin(wobbling.timer * (math.pi * 2) / wobbling.duration) * wobbling.amount * (wobbling.timer / wobbling.duration)
			scale = scale + (scale * wobble)
		end

		local color = self.color
		local graphic = self.graphic
		local special = self.special
		if special then
			lg.setColor(color)
			graphic:draw(projection.x, projection.y, angle, scale, scale, offset.x, offset.y)
			local pulse = self.pulse
			local amplitude = 0.05
			local t = amplitude + amplitude * math.sin(pulse * math.pi * 2)
			lg.setColor(255, 255, 255, 255 * t)
			lg.setBlendMode("additive")
			graphic:draw(projection.x, projection.y, angle, scale, scale, offset.x, offset.y)
			lg.setBlendMode("alpha")
		else
			batch:setColor(color)
			graphic:add(batch, projection.x, projection.y, angle, scale, scale, offset.x, offset.y)
		end

		-- draw particles
		local particles = self.particles
		if particles then
			particles:setPosition(projection.x, projection.y)
			lg.setColor(255, 255, 255)
			lg.draw(particles, 0, 0)
		end

		local x = projection.x
		local y = projection.y

		local glow = self.glow
		if glow then
			local gx = x
			local gy = y + offset.y + 40
			local s = math.min(scale / self.original, 1)
			glow:setPosition(gx, gy)
		end

	end,

	resize = function(self, n)

		local scale = math.max(self.scale + n, 0)

		if (self.scale == 0) and (self.consume) then
			self.vine:snap()
			self.snapped = true
		end

		if (self.consume) and (not self.consumed) then
			local threshold = self.attributes.threshold
			if (scale <= threshold) and (self.scale > threshold) then
				self:pop()
				observer:emit('avoid', self.position.y)
				observer:emit('burst')

				local position = self.position
				local offset = self.offset
				local token = {x = position.x, y = position.y + offset.y, z = position.z}
				score:emit('report', token, self.variant, self.fruit_color)
				metrics:add('eaten', 1)
				sound:emit('pop', {delay = 0.05})

				local special = self.special
				if special then
					-- only if we're not flipped
					-- puff of particles?
					local horn = g["horn"]
					horn:activate()
				end

				if not attached and (math.abs(self.angle) > 0.05) or (self.gravity.pull > 30) then
					metrics:add('caught', 1)
				end
			end
		end
		self.scale = scale
	end,

	pop = function(self)

		self.consumed = true
		self.particles:start()

		

	end,

	-- shift the offset but keep the same position and angle
	shift = function(self, dx, dy)

		-- this does not correctly solve the angle
		-- when shifting the point of rotation
		-- but that may be alright

		local offset, position, scale, angle, pre

		offset = self.offset
		position = self.position
		scale = self.scale
		angle = self.angle

		pre = {x = position.x, y = position.y}

		if dx then
			offset.x = offset.x + dx
			position.x = position.x + dx * scale
			pre.x = dx * scale
		end

		if dy then
			offset.y = offset.y + dy
			position.y = position.y + dy * scale
			pre.y = dy * scale
		end

	end,

	move = function(self, dx, dy)

		local x, y

		x = (dx) and (self.position.x + dx) or (nil)
		y = (dy) and (self.position.y + dy) or (nil)

		self:set(x, y)

	end,

	-- weird I just copy pasted this?
	set = function(self, x, y)

		local floor, size, offset

		--floor = self.floor
		floor = window.height - world.floor

		-- uuh this is bad...
		size = self.size
		offset = self.offset

		self.position.x = (x) and (x) or (self.position.x)
		--self.position.y = (y) and (y) or (self.position.y)
		self.position.y = (y) and math.min(y, floor - size.h) or (self.position.y)

		if (self.position.y == floor - size.h) then
			--self.grounded = true
		end

	end,
	
	release = function(self)

		if (self.attached) then

			self.velocity.y = -100
			self.velocity.x = 10
			self.rotation = (math.pi / 16) + (math.pi / 16) * math.random()
			self.attached = false
			self.rotates = true
			self.static = false

			observer:emit('collidable', self.key, {'lion', 'lion_head', 'body', 'ground'})
			--score:emit('disrupt', 'collect')

		end

	end,

	spin = function(self, spin)
		self.rotation = self.rotation + spin
	end,

	collide = function(self, args, key)

		local message
		local source = args.labels.collider

		-- this is probably the wrong term for this, maybe self.dynamic?
		self.rotates = true

		if (source == 'ground') then
			if not self.grounded then
				self.particles:start()
				sound:emit('squash')
				sound:emit('pop', {volume = {0.1, 0.2}})
			end
			self.grounded = true
		end

		if (source == 'mouth') then

			self.consume = true
			self.static = false
			self.particles:start()
		end

		if (source == 'lion') and (not self.attached) then

			--self.consumed = true

			local hit = self.hit
			local collider = args.collider
			local collidable = args.collidable

			if (self.scale > 0 ) then


				-- tell the lion to flip
				message = self

				-- start particles and jelly wobble
				self.particles:start()
				self:wobble()

				sound:emit('bounce')

				local above = ((collidable.top + collidable.bottom) * 0.5 <= collider.top)
				if above then
					self.rotation = clamp(-self.rotation * 2, math.pi * -4, math.pi * 4)
					self.gravity.pull = 0
					self.hit = true
				end

			end

		end

		if (source == 'lion_head') and (not self.attached) then

			local hit = self.hit
			local collider = args.collider
			local collidable = args.collidable

			if (self.scale > 0 ) then

				local w = (collidable.right - collidable.left)
				local h = (collidable.bottom - collidable.top)
				local mx = collidable.left + w * 0.5
				local my = collidable.top + h * 0.5

				-- is this registering popular?
				local hit = (mx - w*0.3) <= collider.right
					and (mx + w*0.3) >= collider.left
					and (my + h*0.3) >= collider.top
					and (my - h*0.3) <= collider.bottom

				if hit then

					-- tell the lion to flip
					message = self
					sound:emit('bounce')

					-- start particles and jelly wobble
					self.particles:start()
					self:wobble()

					self.rotation = clamp(-self.rotation * 2, math.pi * -4, math.pi * 4)
					self.gravity.pull = 0
					self.hit = true
				end

			end

		end

		if (source == 'body') then
			local bounced = self.bounced

			-- I should really scope these bound sides 

			local collider = args.collider
			local collidable = args.collidable

			local cooldown = self.cooldown
			local valid = (collider.top <= collidable.bottom)
				and ((collidable.left + collidable.right) * 0.5 >= collider.left)
				and ((collidable.left + collidable.right) * 0.5 <= collider.right)
				and ((collidable.top + collidable.bottom) * 0.5 <= collider.top)

			local valid = valid and (cooldown == 0)

			if (valid) then

				-- I can use a message for this instead
				sound:emit('bounce')
				message = 'jolt'
				self.cooldown = 0.5

				-- this controls how much intertia the edible retains upon bouncing
				-- lower values make the game easier
				local bounce = 0.7 + 0.1 * math.random()
				local spin = 4

				self.velocity.x = -10
				self.velocity.y = -self.gravity.pull * bounce
				self.rotation = -self.rotation * spin
				self.gravity.pull = 0

				self:wobble()

			end

		end

		if (source == 'net') then
			if (not self.missed) and (self.attached) then
				self.missed = true
				observer:emit('missed')
				metrics:add('missed', 1)
			end
		end

		return message

	end,

	wobble = function(self)
		self.wobbling.timer = self.wobbling.duration
	end,

	destroy = function(self)
		local particles = self.particles
		if particles then
			recycle(particles)
		end
		self.particles = nil
	end,


}
