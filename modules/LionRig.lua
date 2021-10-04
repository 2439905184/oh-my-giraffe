Lion = class{
	init = function(self, start, head, forelegs, hindlegs, tail)

		local sprite, label, position, size, offset
		label = 'lion'

		head.body = self

		-- todo this should probably be an animation
		sprite = Graphic('lion_body')
		local scale = 1.9
		local range = 0.5
		local scale = 2 - (range) + (range * 2) * math.random()
		local scale = options.lion_scale * 2 + 0.05 * math.random()

		size = {
			w = sprite:getWidth(),
			h = sprite:getHeight() + forelegs:getHeight() * (4 / scale),
		}

		offset = {
			x = size.w / 2,
			y = size.h / 4,
		}

		-- I could also just set y -> window.height and let the ground collision push it up
		local x, y
		x = start - (size.w - offset.x)

		y = -(size.h - offset.y)
		--y = (world.floor) and (window.height - world.floor + y) or (window.height / 2 + y)
		y = window.height - world.floor + y - 100
		--y = 500

		position = {
			x = x,
			y = y,
			z = 1,
		}

		velocity = {
			x = vx,
			y = 0,
		}

		boost = {
			x = 0.9,
			y = 0,
		}

		angle = 0
		gravity = 1600

		self.head = head
		self.forelegs = forelegs
		self.hindlegs = hindlegs
		self.tail = tail
		self.scale = scale

		self.sprite = sprite
		self.label = label
		self.position = position
		self.velocity = velocity
		self.size = size
		self.offset = offset
		self.angle = angle
		self.gravity = gravity
		self.boost = boost
		self.rotation = 0
		self.difficulty = difficulty

		-- should be 'dynamic?'
		self.rotates = false
		self.grounded = false
		self.flipped = false
		self.sleeping = false

		local r = 255 - math.random() * 15
		local g = 255 - math.random() * 30
		local b = 255 - math.random() * 30

		local shade = math.random() * 20
		r = r - shade
		g = g - shade
		b = b - shade



		self.color = {r, g, b}
		self.shade = {r, g, b}

		-- temp color pulse
		self.pulse = {
			timer = 0.4,
			duration = 0.4,
			default = self.color,
			target = {self.color[1], self.color[2] - 125, self.color[3] - 125},
		}


		self.oscilation = {
			timer = (math.pi) * math.random(),
			period = 1,
			amplitude = 0.1,
		}

		self.bobble = {
			timer = 0,
			amount = 0,
		}

		self.leaping = {
			timer = 0.55,
			duration = 0.3,
		}

		self.resting = {
			timer = 0,
			duration = 0.8,
		}


		self.throttle = 1
		
		self.target = {
			active = false,
			from = 0,
			to = -math.pi,
			timer = 0,
			duration = 1.2,
			method = easing.outBack,
		}

		self:chase()

		self.batched = true

	end,

	register = function(self, key)
		self.key = key
		observer:emit('collider', key)
		local colliders = {'ground', 'body', 'tail', 'horn'}
		observer:emit('collidable', key, {'ground', 'body', 'tail'})
	end,

	update = function(self, dt)

		local x, y

		local delay = self.delay
		if delay then
			delay[1] = delay[1] - dt
			if delay[1] <= 0 then
				delay[2]()
			end
		end


		if self.head.attacking then
			self:strike()
			self.head.attacking = false
		end

		if self.snores then
			self.snores:update(dt)
		end
		
		if (self.leaping.timer > 0) then
			self.leaping.timer = math.max(self.leaping.timer - dt, 0)
			-- called once after lion has finished a strike attempt
			if (self.leaping.timer == 0) then

				-- if the lion is still colliding with the giraffe
				-- then this flag will trigger it to flip
				self.attacking = true

				-- TODO: this causes the score token text to dissappear momentarily...
				-- something to do with culling?
				if not self.sleeping then
					observer:emit('jiggle')
				end


			end
		else
			self.attacking = false
		end


		-- this is a kind of hacky way to implementing stagnation of the body sprite (I should set states of the assets instead)
		--if (not self.flipped) then
			self.sprite:update(dt)
		--end

		-- pulse the lion red when the timer has been armed
		local pulse = self.pulse
		local color = self.shade
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

		-- so, velocity.y never actually stops increasing
		-- which is probably what causes these problems?
		--self.velocity.y = (not self.grounded) and (self.velocity.y + (self.gravity * dt)) or (self.velocity.y)

		local grounded = self.grounded
		local flipped = self.flipped
		if (flipped) and (not grounded) then
			self.forelegs:setState('sleeping_fore')
			self.hindlegs:setState('sleeping_hind')
		elseif (flipped) and (grounded) then
			self.forelegs:setState('leaping_hind')
			self.hindlegs:setState('leaping_hind')
		elseif (not grounded) then
			self.forelegs:setState('leaping_fore')
			self.hindlegs:setState('sleeping_hind')
		else
			self.forelegs:setState('running')
			self.hindlegs:setState('running')
		end

		self.velocity.y = self.velocity.y + self.gravity * dt
		y = self.position.y + self.velocity.y * dt

		if (self.flipped) then
			-- decelerate x velocity once flipped
			--self.velocity.x = self.velocity.x - (self.velocity.x * dt)
			-- stop rotation and x velocity rapidly once grounded
			if self.velocity.y == 0 then
				self.velocity.x = self.velocity.x - (self.velocity.x * dt * 10)
			end
		end


		local target = self.target
		if target.active then
			target.timer = math.min(target.timer + dt, target.duration)
			local angle = target.method(target.timer, target.from, target.to - target.from, target.duration, 1)
			self.angle = angle
			if (target.timer == target.duration) then
				target.active = false
			end
		end

		self.angle = self.angle + self.rotation * dt

		local dx = self.velocity.x
		local boost = self.boost
		if boost.x > 0 then
			boost.x = math.max(boost.x - dt, 0)
			dx = dx + dx * boost.x
		elseif boost.x < 0 then
			boost.x = math.min(boost.x + dt, 0)
			dx = dx + dx * boost.x
		end

		local throttle = (dx / 300)

		-- clunky positional oscilation
		local period = (math.pi / self.oscilation.period)
		-- update the timer
		self.oscilation.timer = self.oscilation.timer + dt

		local t = self.oscilation.timer * period
		local oscilation = (math.sin(t) * dx * self.oscilation.amplitude) * throttle
		--self.position.x = self.position.x + oscilation * dt
		x = self.position.x + (dx + oscilation) * dt

		-- head bobble
		self.bobble.timer = self.bobble.timer + dt
		self.bobble.amount = (math.sin(self.bobble.timer * (math.pi * 2) / (0.6)) + 1) * 8

		self:set(x, y)

	end,

	draw = function(self, projection, batch)

		local graphic = self.sprite
		batch:setColor(self.shade)
		graphic:add(batch, projection.x, projection.y, self.angle, self.scale, self.scale, self.offset.x, self.offset.y)
		
	end,

	set = function(self, x, y)

		self.position.x = (x) and (x) or (self.position.x)
		self.position.y = (y) and (y) or (self.position.y)

		-- set attachement positions
		-- why do these not work at low fps?

		local x = self.position.x
		local y = self.position.y
		local scale = self.scale
		local angle = self.angle
		local w = self.sprite:getWidth() * scale
		local h = self.sprite:getHeight() * scale
		local ox = self.offset.x * scale
		local oy = self.offset.y * scale


		local bobble = self.bobble.amount
		local extension = 23

		local flipped = self.flipped
		if flipped then
			local target = self.target
			local blend = target.method(target.timer, 1, -1, target.duration)
			bobble = bobble * blend
		end

		local head = self.head
		local forelegs = self.forelegs
		local hindlegs = self.hindlegs
		local tail = self.tail

		local headx = ox - extension
		local heady = -oy + bobble
		local forelegsx = -ox + w
		local forelegsy = -oy + h
		local hindlegsx = -ox
		local hindlegsy = -oy + h
		local tailx = -ox
		local taily = -oy + 8 * scale

		if angle ~= 0 then
			local headv = vector(ox - extension, -oy + bobble):rotated(angle)
			headx = headv.x
			heady = headv.y
			local forelegsv = vector(-ox + w, -oy + h):rotated(angle)
			forelegsx = forelegsv.x
			forelegsy = forelegsv.y
			local hindlegsv = vector(-ox, -oy + h):rotated(angle)
			hindlegsx = hindlegsv.x
			hindlegsy = hindlegsv.y
			local tailv = vector(-ox, -oy + 8 * scale):rotated(angle)
			tailx = tailv.x
			taily = tailv.y
		end

		head:set(x + headx, y + heady, angle, 0)
		forelegs:set(x + forelegsx, y + forelegsy, angle, 0)
		hindlegs:set(x + hindlegsx, y + hindlegsy, angle, 0)
		tail:set(x + tailx, y + taily, angle, 0)

		local shade = self.shade

		head:setColor(shade)
		forelegs:setColor(shade)
		hindlegs:setColor(shade)
		tail:setColor(shade)

	end,

	move = function(self, dx, dy)
		self:set(self.position.x + dx, self.position.y + dy)
	end,

	get = function(self)
		return self.position, self.size
	end,

	enter = function(self)
	end,

	leave = function(self)
	end,

	chase = function(self)

		local difficulty = metrics:get('danger_difficulty')
		local velocity, gravity, angle, boost
		local base = player_speed * 1.08
		local vx = base + (window.width / difficulty)
		self.difficulty = difficulty
		self.velocity.x = vx

	end,

	jolt = function(self)
		self.velocity.y = -700
		self.grounded = false
	end,

	hop = function(self)
		self.velocity.y = -400
		self.grounded = false
	end,

	strike = function(self)
		local allowed = (self.leaping.timer == 0)
			and (not self.flipped)
			and (not self.attacked)
		if allowed then
			self.grounded = false
			self.leaping.timer = self.leaping.duration
			if (self.velocity.y == 0) or (self.grounded) then
				self.velocity.y = -600
			end
			sound:emit('roar')
		end
	end,

	flip = function(self, silently, award)
		local flipped = self.flipped
		local sleeping = self.sleeping
		local rotates = self.rotates
		local grounded = self.grounded
		local avoiding = self.avoiding

		if avoiding then
			return
		end

		if (not flipped) then

			self.target = {
				active = false,
				from = 0,
				to = -math.pi,
				timer = 0,
				duration = 1.2,
				method = easing.outBack,
			}

			local variation = math.random()
			self.velocity.y = -(500 + 300 * variation)
			self.velocity.x = -self.velocity.x * 0.5 * variation

			self.target.active = true

			-- set the grounded flag
			self.grounded = false

			-- set the lion to flipped
			self.flipped = true

			-- remove the lion's collider
			-- I do actually need to do this...
			self:release()

			-- should be renamed to 'dynamic'
			self.rotates = true

			-- start a color pulse
			self.pulse.timer = 0

			-- how can i avoid 
			if (not silently) then
				metrics:add('lions_flipped', 1)
				sound:emit('squash')
				sound:emit('whimper')
				sound:emit('hit')
				sound:emit('bounce')
				sound:emit('thud', {pitch = {1.7, 1.7}, volume = {0.3, 0.3}})
				observer:emit('jiggle')
			end

			-- use position to make a score popup
			local horn = g["horn"]
			local objects = g["objects"]
			local score = g["score"]
			local combo = score.combo

			-- I want to know if we got hit by a fruit that has already hit a few lions
			-- so maybe we can look up that object?

			if (combo > 0) and (not silently) and (horn.active) and (award) then
				metrics:add('lions_headbutted', 1)
				local x, y = self.position.x, self.position.y
				local points = Points({x = x, y = y - 150})
				local value = combo * 10
				local angle = -math.pi / 2 + math.cos(math.random() * math.pi * 2) * (math.pi / 16)
				local speed = 70 + 70 * math.random()
				points:set(value, speed, angle)
				local key = objects:add(points)
				score.points = score.points + value
			end

		else
			self:wake()
		end

	end,

	sleep = function(self)

		if not self.sleeping then

			-- make the lion sleep!
			self.flipped = true
			self.velocity.x = 0
			self.target.active = true
			self.rotates = true

			--self.target.timer = self.target.duration
			self.attacked = true
			self.sleeping = true

			self.head:sleep()
			self.head.snores = Snores(3)
			
		end

	end,

	wake = function(self)
		local sleeping = self.sleeping
		if sleeping then

			self.pulse.timer = 0

			self.target.timer = 0
			self.target.active = true
			self.target.from = -math.pi
			self.target.to = 0

			self.grounded = false
			self.rotates = true
			self.flipped = false
			self.sleeping = false

			self.attacked = false
			self.attacking = true
			self.leaping.timer = 0

			self.gravity = 1600

			self.boost.x = -1.5

			self.head:wake()
			self:hop()
			self:jolt()
			self:chase()

			sound:emit('roar')
			observer:emit('startle')
			metrics:add('lions_awoken', 1)

			self.avoiding = true

			self.delay = {1.2, function()
				self.avoiding = false
				self.resting.timer = 0
				self.sleeping = false
			end}

		end

	end,

	collide = function(self, args)

		local message
		local source = args.labels.collider

		-- this code could potentially be abstracted for general gravity-based falling
		if (source == 'ground') then

			local collider = args.collider
			local collidable = args.collidable
			local dy = (collider.top - collidable.bottom) - 0.1

			-- set the collidable's lower bound to collider's upper bound
			-- so now this gets called a rather lot
			self:move(0, dy)
			self.grounded = true
			self.velocity.y = 0

			if (self.flipped) and (self.target) then
				self.head:sleep()
				if math.abs(self.target.to  - self.angle) < 0.05 then
					self.grounded = true
					self.gravity = 0
					sound:emit('skid')
				else
					self.grounded = false
				end
				self.grounded = false
			end
			
		end

		if (source == 'body') or (source == 'tail') then

			local attacking = self.attacking
			local attacked = self.attacked

			if not attacked then
				if attacking then

					-- we use a short grace period
					-- and disabled the tail while the horn powerup is active
					local horn = g["horn"]
					if horn.active and source == 'tail' then
						self.leaping.timer = 0.2
					elseif horn.cooldown <= 0 then
						observer:emit('flip')
						self.attacked = true
						self.leaping.timer = 0
					else
						self.leaping.timer = 0.2
					end

				else
					self:strike()
				end
			end

			--self.attacking = false

		end

		if (source == 'horn') then
			local sleeping = self.sleeping
			local flipped = self.flipped
			local horn = g["horn"]
			local active = horn.active
			if (not sleeping) and (active) then
				self:flip(false, true)
			end
		end

		return message

	end,

	tell = function(self, message)

		if message.label == "edible" then
			local sleeping = self.sleeping
			local avoiding = self.avoiding
			if sleeping or avoiding then
				message:pop()
			end
			if (not avoiding) then
				self:flip()
			end
		end

	end,

	release = function(self)
		observer:emit('release_collider', self.key, self.label)
		observer:emit('release_collider', self.head.key, self.head.label)
	end,

}