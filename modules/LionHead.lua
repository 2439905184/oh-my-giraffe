LionHead = class{
	init = function(self)

		self.position = {
			x = 0,
			y = 0,
			z = 1,
		}

		-- have to decide on gender here in order to change head version, unless I have an override method
		local running, unconscious
		local offset
		local roll = math.random()
		local threshold = 0.65
		if roll > threshold then
			running = Graphic('lioness_head')
			unconscious = Graphic('lioness_head_sleeping')
		else
			running = Graphic('lion_head')
			unconscious = Graphic('lion_head_sleeping')
		end

		local variant = running.variant

		local state = 'running'

		local w = running:getWidth()
		local h = running:getHeight()
		local size = {
			w = w,
			h = h,
		}
		local scale = 1.5
		local girth = 15

		if roll > threshold then
			offset = {
				x = size.w - 17 - girth,
				y = size.h - 12,
			}
		else
			offset = {
				x = size.w - 24 - girth,
				y = size.h - 12,
			}
		end

		self.state = state
		self.running = running
		self.unconscious = unconscious
		self.size = size
		self.offset = offset
		self.angle = 0
		self.twist = 0
		self.scale = scale
		self.shear = 0
		self.color = {255, 255, 255}
		self.label = 'lion_head'

		self.batched = true

		self.target = {
			active = false,
			from = 0,
			to = math.pi / 2,
			timer = 0,
			duration = 1.2,
			method = easing.outElastic,
		}

	end,

	register = function(self, key)
		self.key = key
		observer:emit('collider', key)
		local colliders = {'tail', 'ground', 'horn', 'head'}
		observer:emit('collidable', key, colliders)
	end,

	update = function(self, dt)

		self[self.state]:update(dt)
		local target = self.target

		local flipped = self.flipped
		if target.active then

			target.timer = math.min(target.timer + dt, target.duration)

			local to = target.to
			local from = target.from
			local angle = target.method(target.timer, from, to - from, target.duration, 0.2)
			self.twist = options.safemode and 0 or angle

			local blend = target.method(target.timer, 1, -1, target.duration)
			--self.offset.y  = self.size.h - 12 * blend
		end

		if target.timer == target.duration then
			target.active = false
		end

		local snores = self.snores
		if snores then
			snores:update(dt)
		end

	end,

	draw = function(self, projection, batch)

		local graphic = self[self.state]
		batch:setColor(self.color)
		graphic:add(batch, projection.x, projection.y, self.angle, self.scale, self.scale, self.offset.x, self.offset.y, self.shear)

		local snores = self.snores
		if snores then
			snores:draw({x = projection.x - self.size.w * 1.5, y = projection.y})
		end

	end,

	set = function(self, x, y, angle, shear)
		local twist = self.twist
		self.position.x = x
		self.position.y = y
		self.angle = angle + twist
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

	wake = function(self)
		local sleeping = self.sleeping
		if sleeping then
			self.sleeping = false
			self.target.active = true
			self.target.from = math.pi / 2
			self.target.to = 0
			self.target.timer = 0
			self.snores.transitions.active = false
			self.state = 'running'
		end
	end,

	sleep = function(self)
		local sleeping = self.sleeping
		if not sleeping then
			self.sleeping = true
			self.state = 'unconscious'
			self.rotates = true
			self.target.active = true
		end
	end,

	collide = function(self, args)
		local source = args.labels.collider

		if (source == 'tail') then
			self.attacking = true
		end

		if (source == 'ground') then
			--self.twisting = true
			if not self.target.active then
				self.target.active = true
			end
		end

		if (source == 'horn') or (source == 'head') then
			local sleeping = self.sleeping
			local horn = g["horn"]
			local active = horn.active
			if (not sleeping) and (active) then
				local body = self.body
				body:flip(false, true)
			end
		end
		
	end,

	tell = function(self, message)
		local body = self.body
		body:tell(message)
	end,
}