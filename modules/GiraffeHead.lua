GiraffeHead = class{
	
	init = function(self, position, mouth, horn, ear, wind)

		self.position = position

		local default = Graphic('giraffe_head')
		local blinking = Graphic('giraffe_head_blink')

		self.default = default
		self.blinking = blinking
		self.state = 'default'
		self.uncullable = true
		self.prioritize = true
		self.size = {
			w = default:getWidth(),
			h = default:getHeight(),
		}

		self.offset = {
			x = self.size.h / 2,
			y = self.size.h / 2,
		}

		self.velocity = {
			x = 0,
			y = 0,
		}

		self.label = 'head'

		self.floor = window.height - world.floor - self.size.h
		self.timer = 0

		self.wiggle = 0

		-- wobble
		self.wobble = {
			x = {
				target = 0,
				progress = 0,
				amount = 0,
				angle = 0,
			},
			y = {
				target = 0,
				progress = 0,
				amount = 0,
				angle = 0,
			},
		}

		self.angle = 0

		-- hacky spin variation
		local flip = math.random()
		local spin
		if (flip < 0.95) then
			spin = 2
		else
			spin = 3
		end

		-- flipping
		self.gravity = 2500
		self.flipped = false
		self.flipping = {
			jolted = false,
			target = -math.pi * 3 + math.pi/2,
			timer = 0,
			duration = 0.9,
		}

		self.turn = 1
		self.turning = false
		self.turned = 0.2

		-- blinking
		self.blink = {
			duration = 0.1,
			gap = 1,
			timer = 0.8,
			toggle = true,
		}

		self.color = {255, 255, 255}
		self.mouth = mouth
		self.horn = horn
		self.ear = ear

		self.elasticity = 16
		self.stiffness = 10

		self.remarks = Exclaimations()

		self.batched = true

	end,

	startle = function(self)
		if not self.flipped then
			self.remarks:add('!')
			self.blink.timer = 0.1
			self.blink.toggle = true
			self.state = 'blinking'
			if math.random() < 0.2 then
				self:look()
			end
		end
	end,

	warn = function(self)
		if not self.flipped then
			self.blink.timer = 0.1
			self.blink.toggle = true
			self.state = 'blinking'
			self:look()
			self.remarks:add('...')
			self.mouth:chew()
			sound:emit('honk', {volume = {0.3, 0.3}, delay = 0.05})
		end
	end,

	register = function(self, key)
		observer:emit('collidable', key, {'ground'})
		observer:emit('collider', key)
		self.key = key
	end,

	update = function(self, dt)

		if self.turning then
			self.turn = math.max(self.turn - dt * 20, -1)
			if self.turn == -1 then
				self.turned = math.max(self.turned - dt, 0)
				if self.turned == 0 then
					self.turning = false
					self.turned = 0.3
				end
			end
		else
			if self.turn ~= 1 then
				self.turn = math.min(self.turn + dt * 15, 1)
			end
		end

		local flipped = self.flipped
		local flipping = self.flipping
		local grounded = self.grounded
		if grounded then
			self.velocity.x = self.velocity.x - (self.velocity.x * 10 * dt)
		end
		if flipped then
			self.velocity.y = (not grounded) and (self.velocity.y + self.gravity * dt) or (0)
			local dx, dy
			dx = self.velocity.x * dt
			dy = self.velocity.y * dt
			local t = math.min(flipping.timer / flipping.duration, 1)
			self.position.x = self.position.x + dx
			self.position.y = self.position.y + dy * t
		end

		if not flipped then
			local blink = self.blink
			self.blink.timer = self.blink.timer - dt
			if (self.blink.timer <= 0) then
				self.blink.toggle = not self.blink.toggle
				self.state = (self.blink.toggle) and ('blinking') or ('default')
				self.blink.timer = (self.blink.toggle) and (self.blink.duration) or (self.blink.gap + self.blink.gap * math.random())
			end
		end

		self.timer = self.timer + dt
		local progress, amount, target, angle
		local size = self.size
		
		local elasticity = self.elasticity
		local stiffness = options.safemode and 50 or self.stiffness

		local ty = self.wobble.y.target / (dt * 10)
		local py = self.wobble.y.progress
		local ay = self.wobble.y.amount

		py = py + (ty - py) * dt * elasticity
		ay = ay + (py - ay) * dt * elasticity

		-- gosh this is hacky
		local ry = -math.atan2(ay / stiffness, size.w)

		self.wobble.y.progress = py
		self.wobble.y.amount = ay
		self.wobble.y.angle = ry

		local tx = self.wobble.x.target / (dt * 10)
		local px = self.wobble.x.progress
		local ax = self.wobble.x.amount

		px = px + (tx - px) * dt * elasticity
		ax = ax + (px - ax) * dt * elasticity

		-- gosh this is hacky
		local rx = -math.atan2(size.h, ax / stiffness * 1.5) + (math.pi / 2)

		self.wobble.x.progress = px
		self.wobble.x.amount = ax
		self.wobble.x.angle = rx


		local wiggle = (math.sin(self.timer * math.pi * 4)) * (math.pi / 32) * self.wiggle
		local idle = math.cos(self.timer * math.pi + 1) *  (math.pi / 45) * math.abs(self.wiggle - 1)

		self.angle = rx + ry + wiggle + idle

		--self.position.x = self.position.x + (math.sin(self.timer * math.pi * 4 - 0.3)) * (30 * dt) * self.wiggle

		-- flipping
		local flipped = self.flipped
		local flipping = self.flipping

		if flipped then
			self.flipping.timer = math.min(self.flipping.timer + dt, self.flipping.duration)
			local angle = easing.inOutCubic(flipping.timer, 0, flipping.target, flipping.duration)
			self.angle = self.angle + angle
		end

		if not flipped then
			self.position.y = self.position.y + math.cos(self.timer * math.pi + 0.5) *  (5 * dt) * math.abs(self.wiggle - 1)
		end

		if self.snores then
			self.snores:update(dt)
		end
		
		self.remarks:update(dt)
	
		local a = self.angle
		local x = self.position.x 
		local y = self.position.y

		local turn = self.turn

		local w = size.w * turn
		local ox = self.offset.x * turn
		local oy = self.offset.y

		local shear = rx + ry

		local horn = vector(-ox, -oy):rotated(a)
		local mouth = vector(-ox + w, -oy):rotated(a)
		local ear = vector(-ox / 2, -4):rotated(a)

		self.horn:set(x + horn.x, y + horn.y, a, shear, turn)
		self.mouth:set(x + mouth.x, y + mouth.y, a, shear, turn)
		self.ear:set(x + ear.x, y + ear.y, a, shear, turn)

	end,

	set = function(self, x, y)

		-- how can I actually set the direction here?...

		local position = self.position.x

		self.wobble.x.target = (x) and (x - self.position.x) or (self.wobble.x.target)
		self.wobble.y.target = (y) and (y - self.position.y) or (self.wobble.y.target)
		
		self.position.x = (x) or (self.position.x)
		self.position.y = (y) or (self.position.y)

	end,

	move = function(self, dx, dy)

		local x, y = self.position.x + dx, self.position.y + dy
		self:set(x, y)

	end,

	draw = function(self, projection, batch)

		local size, wobble, angle, offset, x, y

		size = self.size
		wobble = self.wobble

		angle = wobble.y.angle
		angle = angle + wobble.x.angle
		angle = self.angle

		offset = self.offset

		x, y = projection.x, projection.y

		local sprite = self[self.state]
		local color = self.color
		local turn = self.turn
		batch:setColor(color)
		sprite:add(batch, x, y, angle, 1 * turn, 1, offset.x, offset.y)

		if self.snores then
			self.snores:draw(projection)
		end

		self.remarks:draw(projection)

	end,

	get = function(self)

		local position, size, angle, offset

		position = self.position
		size = self.size
		angle = self.angle
		offset = self.offset

		local properties = {
			position = position,
			size = size,
			angle = angle,
			offset = offset
		}

		return properties
	end,

	attach = function(self)

		local properties, position, size, anchor, angle, offset

		properties = self:get()
		position, size, angle, offset = properties.position, properties.size, properties.angle, properties.offset

		local flipped = self.flipped
		if flipped then
			angle = angle % (math.pi * 2)
		end

		anchor = {
			x = position.x,
			y = position.y,
			a = angle,
		}

		return anchor

	end,

	setWiggle = function(self, n)
		self.wiggle = n
	end,

	look = function(self)
		if not self.flipped then
			self.turning = true
		end
	end,

	flip = function(self)

		if not self.flipped then
			
			local wobble = self.wobble
			local vx = -400
			local vy = wobble.y.amount - 600
			self.velocity.x = vx
			self.velocity.y = vy
			self.rotates = true
			self.flipped = true
			self.remarks:destroy()

			local horn = self.horn
			if horn.active then
				horn:deactivate()
			end

		end
	end,

	collide = function(self, args)

		local collider = args.labels.collider

		if (collider == 'ground') then

			local collider = args.collider
			local collidable = args.collidable
			local dy =  collider.top - collidable.bottom

			self:move(0, dy)

			local flipped = self.flipped
			local flipping = self.flipping

			if flipped and not (self.grounded) then
				if (flipping.timer ~= flipping.duration) then
					self.grounded = false
					self.velocity.y = 0
				else
					self.velocity.y = 0
					self.grounded = true
					self.state = 'blinking'
					self.snores = Snores(3)
					observer:emit('finish')
					score:emit('disrupt', 'fail')
					score:emit('lock')
					sound:emit('step_right')
					sound:emit('thud', {pitch = {1.6, 1.6}, volume = {0.45, 0.45}})
					sound:emit('skid')
					--sound:emit('howl', {pitch = {1, 1}, volume = {0.4, 0.4}})
					--self.mouth:chew()
				end
			end
		end
	end,

	setColor = function(self, color)
		self.color = color
		self.horn:setColor(color)
		self.mouth:setColor(color)
		self.ear:setColor(color)
	end

}

GiraffeHorn = class{
	
	init = function(self, position)

		local graphic = Graphic('giraffe_horn') 
		self.graphic = graphic

		self.position = {
			x = 0,
			y = 0,
			z = 1,
		}
		self.size = {
			w = graphic:getWidth(),
			h = graphic:getHeight(),
		}
		self.offset = {
			x = 0,
			y = self.size.h,
		}

		self.label = 'horn'
		self.shear = 0
		self.angle = 0
		self.static = false
		self.batched = true
		self.prioritize = true
		self.color = {255, 255, 255}
		self.turn = 1

		g["horn"] = self

		self.timer = 0
		self.pulse = 0
		self.stretch = 1

		self.cooldown = 0

		self.poll = 0

	end,

	register = function(self, key)
		observer:emit('collider', key)
		self.key = key
	end,

	update = function(self, dt)
		
		local active = self.active

		local pulse = self.pulse
		local stretch = self.stretch
		local length = 1.2
		if active then
			local p = math.min(pulse + dt, 1)
			self.pulse = p
			self.stretch = easing.outElastic(p, 1, length, 1)
		else
			local p = math.max(pulse - dt, 0)
			self.pulse = p
			self.stretch = easing.inElastic(p, 1, length, 1)
		end

		if pulse ~= 0 then

			local timer = self.timer
			self.timer = timer + dt

			local poll = self.poll
			local trail = self.trail
			self.poll = math.max(poll - dt, 0)
			if poll == 0 then
				self.poll = 0.1
				local position = self.position
				local x = position.x
				local y = position.y
			end

			local duration = options.powerup_duration
			if active and timer > duration then
				self:deactivate()
			end

		end

		local cooldown = self.cooldown
		if cooldown > 0 then
			self.cooldown = cooldown - dt
		end

	end,

	draw = function(self, projection, batch)


		local x = projection.x
		local y = projection.y
		local shear = clamp(-self.shear, -0.5, 0.5)
		local graphic = self.graphic
		local color = self.color
		local turn = self.turn
		local angle = self.angle
		local offset = self.offset
		local ox = offset.x
		local oy = offset.y

		local size = self.size
		local w = size.w
		local h = size.h

		
		local pulse = self.pulse

		-- todo, gradually shrink
		local stretch = self.stretch
		local active = self.active
		if pulse ~= 0 then
		
			lg.setColor(color)
			graphic:draw(x, y, angle, turn, stretch, ox, oy, shear, 0)

			local mode = lg.getBlendMode()

			local pulse = self.pulse
			local timer = self.timer
			local t = 0.5 + (math.sin(timer * math.pi * 4) + 1) * 0.5 * 0.5
			local alpha = 255 * easing.outCubic(pulse, 0, 1, 1) * t

			lg.setBlendMode("additive")
			lg.setColor(255, 255, 255, alpha)
			lg.setColor(255, 255, 255, alpha)

			graphic:draw(x, y, angle, turn, stretch, ox, oy, shear, 0)


			lg.setBlendMode(mode)

		else
			batch:setColor(color)
			graphic:add(batch, x, y, angle, turn, stretch, ox, oy, shear, 0)
		end

	end,

	set = function(self, x, y, angle, shear, turn)

		self.position.x = x
		self.position.y = y
		self.angle = angle
		self.shear = shear
		self.turn = turn

	end,

	setColor = function(self, color)
		self.color = color
	end,

	activate = function(self)

		local active = self.active
		if active then
			return
		end

		sound:emit("powerup")

		self.timer = 0
		self.active = true
		self.batched = false
		self.particles = particles

	end,

	deactivate = function(self)
		self.active = false
		self.batched = true
		self.cooldown = 0.1
		sound:emit("boo")
	end,

}

GiraffeMouth = class{
	
	init = function(self, position)

		self.state = 'chewing'

		self.chewing = Graphic('chewing')
		self.default = Graphic('mouth')

		self.position = {
			x = 0,
			y = 0,
			z = 1,
		}
		self.size = {
			w = self.default:getWidth(),
			h = self.default:getHeight(),
		}
		self.offset = {
			x = 0,
			y = 0,
		}

		self.scale = 3.25

		self.timer = 0
		self.color = {255, 255, 255}

		self.label = 'mouth'
		self.shear = 0
		self.angle = 0
		self.turn = 1
		self.rotates = true
		self.batched = true
		self.prioritize = true

	end,

	register = function(self, key)
		observer:emit('collider', key)
		self.key = key
	end,

	update = function(self, dt)

		self.timer = math.max(self.timer - dt, 0)
		self.state = (self.timer > 0) and ('chewing') or ('default')
		self[self.state]:update(dt)

	end,

	draw = function(self, projection, batch)

		local shear = clamp(self.shear / 4, -0.5, 0.5)
		local graphic = self[self.state]
		local color = self.color
		local turn = self.turn
		batch:setColor(color)
		graphic:add(batch, projection.x, projection.y, self.angle, self.scale * turn, self.scale, self.offset.x, self.offset.y, 0, shear)

	end,

	set = function(self, x, y, angle, shear, turn)

		self.position.x = x
		self.position.y = y
		self.angle = angle
		self.shear = shear
		self.turn = turn

	end,

	collide = function(self, args)
		-- differentiate between vines and fruits where using args.labels.collidable
		local source = args.labels.collidable
		if self.state ~= 'chewing' then
			self:chew()
			if source == 'vine' then
				sound:emit('nibble', {delay = 0.05, volume = {0.4, 0.4}})
			elseif source == 'edible' then
				sound:emit('chew', {delay = 0.05, volume = {0.15, 0.2}})
				sound:emit('nibble', {delay = 0.025, volume = {1, 1}})
			end
		end
	end,

	chew = function(self)
		if self.state ~= 'chewing' then
			self.timer = self.timer + 0.2
			self.chewing:seek(1)
		end
	end,

	setColor = function(self, color)
		self.color = color
	end,

}

GiraffeEar = class{
	
	init = function(self, position)

		local graphic = Graphic('giraffe_ear')
		self.graphic = graphic
		self.position = {
			x = 0,
			y = 0,
			z = 1,
		}
		self.size = {
			w = graphic:getWidth(),
			h = graphic:getHeight(),
		}
		self.offset = {
			x = self.size.w,
			y = self.size.h / 2,
		}

		self.label = 'ear'
		self.color = {255, 255, 255}
		self.angle = 0
		self.shear = 0
		self.turn = 1
		self.static = true
		self.batched = true
		self.prioritize = true

	end,

	update = function(self, dt)
	end,

	draw = function(self, projection, batch)

		local graphic = self.graphic
		local color = self.color
		local angle = self.angle - self.shear
		local turn = self.turn
		batch:setColor(color)
		graphic:add(batch, projection.x, projection.y, angle, 1 * turn, 1, self.offset.x, self.offset.y)

	end,

	set = function(self, x, y, angle, shear, turn)

		self.position.x = x
		self.position.y = y
		self.angle = angle
		self.shear = shear
		self.turn = turn

	end,

	setColor = function(self, color)
		self.color = color
	end

}