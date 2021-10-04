GiraffeBody = class{
	
	init = function(self, position, forelegs, hindlegs, tail, wind)

		self.position = position
		self.forelegs = forelegs
		self.hindlegs = hindlegs
		self.tail = tail
		self.wind = wind

		local sprite = Graphic('giraffe_body')
		local w , h

		w = sprite:getWidth()
		h = sprite:getHeight()

		local scale = options.player_scale

		-- I should get this value from the forelegs/hindlegs, not just hardcode it in...
		local size = {
			w = w,
			h = h + forelegs:getHeight() * (4 / scale),
		}

		self.sprite = sprite
		self.size = size
		self.label = 'body'
		self.scale = scale

		-- this anchor point should be passed during the creation of this part

		self.offset = {
			x = w*0.5,
			y = h*0.5,
		}

		self.velocity = {
			x = 0,
			y = 0,
		}

		self.prioritize = true

		self.gravity = 0
		self.angle = 0
		self.rotates = true
		self.timer = 0
		self.color = {255, 255, 255}

		local amount = 105
		local duration = 0.35
		self.pulse = {
			timer = duration,
			duration = duration,
			default = self.color,
			target = {self.color[1], self.color[2] - amount, self.color[3] - amount},
		}

		-- experimental delta for controlling animation
		self.dx = 0

		-- spot generation

		local spot_image
		local global = _G["g"]
		local memoized_spots = global["memoized_spots"] or {}
		if #memoized_spots > 3 then
			local index = math.min(math.floor(#memoized_spots * math.random()) + 1, #memoized_spots)
			spot_image = memoized_spots[index]
		else
			local spotdata = li.newImageData(w, h)

			-- I should make some variants here
			local spot = global["spot"]
			local data = spot:getData()

			-- keep track of pained areas for proximity checking
			local spots = {}

			-- n needs to be determined by the total area being populated
			-- if I was willing to place these each frame
			-- I could implement growing
			local n = 100
			local padding = 4
			local buffer = 18 * (1 / scale)
			local density = 25 * (scale)
			n = ((w - padding * 2) * (h - padding * 2)) / density

			local r, g, b, a = data:getPixel(0, 0)

			for i = 1, n do
				local spawn = true
				local x, y
				local selected = spot
				local sw = selected:getWidth() * (1 / scale)
				local sh = selected:getHeight() * (1 / scale)
				x = clamp(padding + math.floor((w - padding * 2 - sw) * math.random()) , 0, w)
				y = clamp(padding + math.floor((h - padding * 2 - sh) *  math.random()), 0, h)
				-- move the spots to the nearest 4th
				x = x - (x % 4)
				y = y - (y % 4)
				local spacing = (math.random() > 0.9) and (buffer * 0.8) or (buffer)
				for j = 1, #spots do
					local distance = math.pow(x - spots[j].x, 2) + math.pow(y - spots[j].y, 2)
					spawn = (spawn) and (distance > spacing * spacing)
				end
				if (x + selected:getWidth() > w - buffer) and (y < buffer) then
					spawn = false
				end
				if spawn then
					for k = 0, sw - 1 do
						for j = 0, sh - 1 do
							--local r, g, b, a = data:getPixel(k, j)
							spotdata:setPixel(x + k, y + j, r, g, b, a)
						end
					end
					table.insert(spots, {x = x, y = y})
				end
			end

			spot_image = lg.newImage(spotdata)
			table.insert(memoized_spots, spot_image)
			global["memoized_spots"] = memoized_spots
		end



		self.spots = spot_image



		self.wiggle = 0

		-- leg shearing
		-- speed shearing
		self.shearing = {
			output = 0,
			interpolated = 0,
			input = 0,
		}

		-- jump shearing
		self.flapping = {
			timer = 0,
			period = 0.8,
			amplitude = 0.1,
			output = 0,
		}

		-- flipping
		self.flipped = false
		self.flipping = {
			jolted = false,
			shaken = false,
			target = math.pi,
			timer = 0,
			duration = 0.75,
		}

		observer:register('warn', function() self:jolt() end)
		observer:register('grow', function() self:grow() end)
		observer:register('jump', function(force) self:jump(force) end)

		self.spurts = {}

	end,

	register = function(self, key)
		observer:emit('collider', key)
		observer:emit('collidable', key, {'ground'})
	end,

	resize = function(self)
		local scale = self.scale
		local sprite = self.sprite
		local forelegs = self.forelegs
		local h = sprite:getHeight() + forelegs:getHeight() * (4 / scale)
		self.scale = scale
		self.size.h = h
	end,

	grow = function(self)
		local scale = self.scale
		local max = options.player_max_scale
		local rate = math.abs((scale / max) - 1) * options.player_growth_rate
		local n = 0.1
		local spurt = {
			timer = 0,
			duration = 1,
			interpolated = 0,
			amount = n,
		}
		local spurts = self.spurts
		spurts[#spurts + 1] = spurt
	end,

	update = function(self, dt)

		-- todo, get player controller velocity and use it for these shearing and interval ratios!
		self.timer = self.timer + dt
		local spurts = self.spurts
		for i,spurt in ipairs(spurts) do
			spurt.timer = math.min(spurt.timer + dt, spurt.duration)
			local interpolated = easing.outElastic(spurt.timer, 0, spurt.amount, spurt.duration)
			local delta = interpolated - spurt.interpolated
			spurt.interpolated = interpolated
			self.scale = self.scale + delta
			if spurt.timer == spurt.duration then
				table.remove(self.spurts, i)
			end
		end

		if #spurts > 0 then
			self:resize()
		end

		local grounded = self.grounded
		local position = self.position
		local velocity = self.velocity
		local gravity = 1200
		local y = position.y
		local angle = self.angle

		-- velocity should be a vector
		if (velocity.y > 0) then
			self.velocity.y = self.velocity.y - gravity * dt
			y = y - self.velocity.y * dt * 2
			self.grounded = false
		end

		if (not self.grounded) then
			self.gravity = math.min(self.gravity + gravity * dt * 2, gravity)
			y = y + self.gravity * dt
		end

		-- flipping
		local flipped, flipping
		flipped = self.flipped
		flipping = self.flipping

		if flipped then
			-- goes from 0 to 1 when self.flipped
			self.flipping.timer = math.min(self.flipping.timer + dt, self.flipping.duration)
			-- set the angle using some easing
			angle = easing.inOutSine(flipping.timer, 0, flipping.target, flipping.duration)
		end

		-- color pulse
		local pulse = self.pulse
		local color = {255, 255, 255}
		if (pulse.timer ~= pulse.duration) then
			local half = pulse.duration / 2
			local progress = (pulse.timer > half) and math.abs(1 - ((pulse.timer - half) / half)) or (pulse.timer / half)
			for i = 1, #pulse.default do
				local v = pulse.default[i] + (pulse.target[i] - pulse.default[i]) * progress
				color[i] = v
			end

			pulse.timer = math.min(pulse.timer + dt, pulse.duration)
		end
		self.color = color

		self.forelegs:setColor(color)
		self.hindlegs:setColor(color)
		self.tail:setColor(color)

		-- attachment states
		local dx = self.dx
		local speed = (dx / dt) / player_speed
		local interval = easing.outExpo(speed, 0, 2, 2.5)

		-- interpolate output for smooth skewing
		-- currently has no input and no effect
		local elasticity = 2
		self.shearing.interpolated = self.shearing.interpolated + (self.shearing.input - self.shearing.interpolated) * dt * elasticity
		self.shearing.output = self.shearing.output + (self.shearing.interpolated - self.shearing.output) * dt * elasticity * 2

		if (velocity.y > 0) then
			self.forelegs:setState('jumping')
			self.hindlegs:setState('jumping')
		elseif (dx < 0) then
			self.forelegs:setState('skidding')
			self.hindlegs:setState('skidding')
			self.tail:setState('resting')
		elseif (dx / dt < 2) then
			self.forelegs:setState('resting')
			self.hindlegs:setState('resting')
			self.tail:setState('resting')
		else
			self.forelegs:setState('running')
			self.hindlegs:setState('running')
			self.tail:setState('running')
			self.forelegs:setRate(interval)
			self.hindlegs:setRate(interval)
			self.tail:setRate(interval)
		end

		if self.flipped then
			self.forelegs:setState('running')
			self.hindlegs:setState('running')
		end

		if self.flipping.jolted then
			self.forelegs:setState('flipped')
			self.hindlegs:setState('jumping')
			self.tail:setState('flipped')
		end

		if (dx / dt) > 315 then
			self.wind.active = true
			self.wind:set(self.position)
		else
			self.wind.active = false
		end

		self:set(nil, y, angle)

	end,

	set = function(self, x, y, r)

		self.dx = (x) and (self.dx + x - self.position.x) or (self.dx)

		self.position.x = x and x or self.position.x
		self.position.y = y and y or self.position.y
		self.angle = (r) and (r % (math.pi * 2)) or self.angle

		-- set attachments
		local forelegs, hindlegs, tail, x, y, a

		a = self.angle
		x = self.position.x 
		y = self.position.y

		local scale, w, h, ox, oy
		scale = self.scale
		w = self.sprite:getWidth() * scale
		h = self.sprite:getHeight() * scale
		ox = self.offset.x * scale
		oy = self.offset.y * scale

		hindlegs = vector(-ox, -oy + h):rotated(a)
		forelegs = vector(-ox + w, -oy + h):rotated(a)
		tail = vector(-ox, -oy + 8 * scale):rotated(a)

		local shear = clamp(-(self.shearing.output) / 5, -0.5, 0.5) + self.flapping.output

		self.forelegs:set(x + forelegs.x, y + forelegs.y, a, shear)
		self.hindlegs:set(x + hindlegs.x, y + hindlegs.y, a, shear)
		self.tail:set(x + tail.x, y + tail.y, a, 0)

	end,

	move = function(self, dx, dy)
		self:set(self.position.x + dx, self.position.y + dy)
	end,

	draw = function(self, projection)

		-- cannot be batched because the spots are procedural and not in the texture atlas
		-- reset the dx value here because of update order/collision bug
		self.dx = 0
		
		-- draw body and spots
		local size = self.size
		local offset = self.offset
		local angle = self.angle
		local scale = self.scale
		local spots = self.spots
		local sprite = self.sprite
		local color = self.color

		lg.setColor(color)
		sprite:draw(projection.x, projection.y, angle, scale, scale, offset.x, offset.y)
		lg.draw(spots, projection.x, projection.y, angle, scale, scale, offset.x, offset.y)

	end,

	attach = function(self)

		local scale = self.scale
		local position = self.position
		local x = position.x
		local y = position.y

		local size = self.size
		local w = size.w * scale
		local h = size.h * scale


		local offset = self.offset
		local ox = offset.x * scale
		local oy = offset.y * scale

		local angle = self.angle
		local inset = 13

		local point = vector(-ox + w - inset, -oy + inset):rotated(angle)

		local anchor = {
			x = x + point.x,
			y = y + point.y,
		}

		return anchor

	end,

	jolt = function(self)
		local flipped = self.flipped
		if not flipped then
			if self.velocity.y == 0 then
				self.velocity.y = 320
			else
				self.velocity.y = self.velocity.y + 100
			end
		end
	end,

	jump = function(self, force)
		local flipped = self.flipped
		if not flipped and (self.velocity.y < 50) then
			self.velocity.y = 200 + math.min(30 * force, 400)
			local delay = 0.3 + 0.15 * math.min(30 * force, 400) / 400
			local callback = function()
				observer:emit('jiggle')
				sound:emit('thud2', {volume = {0.15, 0.2}, pitch = {1.2, 1.4}})
			end
			signals.emit('delay', delay, callback)
			sound:emit('bounce')
		end
	end,

	flash = function(self)
		self.pulse.timer = 0
	end,

	flip = function(self)
		if not self.flipped then
			self.flipped = true
			self.velocity.y = 740
			self.rotates = true
			self:flash()
			-- TODO change this name holy crap
			sound:emit('thud2')
			sound:emit('honk', {delay = 0.025, volume = {0.6, 0.6}, pitch = {0.9, 0.95}})
		end
	end,

	setWiggle = function(self, n)
		self.wiggle = n
	end,

	collide = function(self, args)

		local subject = args.labels.collider
		local message

		if (subject == 'ground') then

			local collider = args.collider
			local collidable = args.collidable
			local dy =  collider.top - collidable.bottom - (0.1)

			self:move(0, dy)
			self.gravity = 0
			self.velocity.y = 0
			self.grounded = true

			local flipped = self.flipped
			local flipping = self.flipping
			if flipped then
				if (flipping.timer ~= flipping.duration) then
					self.grounded = false
				end
				if not flipping.jolted then
					--self:jolt()
					self.flipping.jolted = true
					observer:emit('shake')
					sound:emit('thud2', {pitch = {1.5, 1.6}, volume = {0.5, 0.5}})
					sound:emit('step_left')
					sound:emit('thump')
					sound:emit('skid')
				end
			end

		end

		return message

		--print('giraffe body being emmited by ' .. subject)
	end,

	tell = function(self, message)
		if self[message] then
			self[message](self)
		end
	end,

}


-- maybe rename to GiraffeLeg and add a GiraffeLegs manager for GiraffeLeg?
GiraffeLegs = class{
		init = function(self, variant)

		local running, jumping, skidding, sitting, resting, flipped, state, scale, rate, w, h, size, offset, label

		running = Graphic('legs')
		jumping = Graphic('legs_jumping')
		skidding = Graphic('legs_skidding')
		resting = Graphic('legs_resting')
		flipped = Graphic('legs_flipped')

		state = 'resting'

		scale = 4
		rate = 0.07

		w = running:getWidth()
		h = running:getHeight()
		size = {
			w = w,
			h = h,
		}

		local sounds = {}
		if (variant == 'forelegs') then
			label = 'forelegs'
			offset = {
				x = size.w - 5,
				y = 0,
			}
		else
			resting = Graphic('legs_resting_hind')
			label = 'hindlegs'
			running:seek(6)
			skidding:seek(2)
			offset = {
				x = 6,
				y = 0,
			}
		end

		sounds[2] = {'running', 'step_right'}
		sounds[6] = {'running', 'step_left'}
		sounds[2] = {'skidding', 'skid'}

		self.running = running
		self.jumping = jumping
		self.resting = resting
		self.flipped = flipped
		self.skidding = skidding
		self.state = state
		self.sounds = sounds
		self.offset = offset
		self.label = label
		self.rate = rate
		self.scale = scale
		self.size = size
		self.angle = 0
		self.shear = 0
		self.rate = rate
		self.timer = 0
		self.batched = true
		self.prioritize = true
		self.color = {255, 255, 255}

		-- i'm not sure I even need to pass a position?
		self.position = {
			x = 0,
			y = 0,
			z = 1,
		}

	end,

	update = function(self, dt)
		local sounds = self.sounds
		local state = self.state
		local active = self[state]
		local previous = active:getFrame()
		active:update(dt)
		local frame = active:getFrame()
		if previous ~= frame and sounds[frame] ~= nil and sounds[frame][1] == state then
			sound:emit(sounds[frame][2])
		end

	end,

	draw = function(self, projection, batch)

		local target = self[self.state]
		local color = self.color
		batch:setColor(color)
		target:add(batch, projection.x, projection.y, self.angle, self.scale, self.scale, self.offset.x, self.offset.y, self.shear)

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
		self.rate = n
	end,

	setColor = function(self, color)
		self.color = color
	end,

}

GiraffeTail = class{
		init = function(self, position)

		self.running = Graphic('giraffe_tail_running')
		self.resting = Graphic('giraffe_tail_resting')
		self.flipped = Graphic('giraffe_tail_flipped')
		self.batched = true
		self.prioritize = true
		self.position = {
			x = 0,
			y = 0,
			z = 1,
		}
		self.size = {
			w = self.running:getWidth(),
			h = self.running:getHeight(),
		}
		self.offset = {
			x = self.size.w,
			y = self.size.h / 2,
		}

		self.state = 'running'
		self.color = {255, 255, 255}
		self.scale = 5

		self.label = 'tail'

		self.angle = 0
		self.shear = 0

	end,

	register = function(self, key)
		observer:emit('collider', key)
	end,

	update = function(self, dt)

		self[self.state]:update(dt)
	end,

	draw = function(self, projection, batch)

		local target = self[self.state]
		local color = self.color
		batch:setColor(color)
		target:add(batch, projection.x, projection.y, self.angle, self.scale, self.scale, self.offset.x, self.offset.y)

	end,

	set = function(self, x, y, angle, shear)

		self.position.x = x
		self.position.y = y
		self.angle = angle
		self.shear = shear

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