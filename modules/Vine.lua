Vine = class{

	init = function(self, position)

		self.position = {
			x = position.x,
			y = position.y,
			z = position.z + 0.0000000001,
		}

		self.initial = position.y
		self.ceiling = window.center.y
		self.graphic = Graphic('vine')

		local w = 4
		local h = position.y + self.ceiling

		self.size = {
			w = w,
			h = h,
		}

		self.offset = {
			x = w / 2,
			y = h,
		}

		self.color = {50, 123, 117}
		self.label = 'vine'
		self.snapped = false
		self.rate = window.height / 400

		self.timer = 0
		self.duration = 2
		self.method = easing.outCubic

		self.particles = psystem({50, 123, 117}, 5, 10)

		self.snapping = {
			timer = 0,
			duration = 0.02,
			snapped = false,
		}

		self.bend = {
			x = position.x,
			y = position.y,
		}

		self.pieces = {}
		self.static = false
		self.batched = true

	end,

	register = function(self, key)
		self.key = key
		observer:emit('collidable', key, {'mouth', 'horn'})
	end,

	update = function(self, dt)

		local pieces = self.pieces
		local snapped = self.snapped
		if snapped then
			local length = self.length
			local rate = self.rate
			--blocal dl = -length * rate * dt
			--self.length = clamp(length + dl, 0, 1)
			self.particles:update(dt)

			local method = self.method
			local duration = self.duration
			local timer = self.timer
			self.timer = math.min(timer + dt, duration)

			local t = method(timer, 1, -1.2, duration)

			self.position.y = -self.ceiling + (self.initial + self.ceiling) * t
			self.size.h = self.position.y + self.ceiling

			if (timer == duration) and (#pieces == 0) then
				self.inactive = true
				self.static = true
			end

		end

		if (self.snapping.timer > 0) then
			self.snapping.timer = math.max(self.snapping.timer - dt, 0)
			if (self.snapping.timer <= 0) then
				self:snap()
				self.edible:release()
			end
		end

		-- update pieces
		for _, strand in ipairs(pieces) do
			local gravity = 800
			strand.position.y = strand.position.y + gravity * dt
			strand.timer = math.min(strand.timer + dt, strand.duration)
			strand.h = easing.outCubic(strand.timer, strand.initial, -strand.initial, strand.duration)
			if (strand.timer == strand.duration) then
				table.remove(pieces, _)
				self.uncullable = false
			end
		end

	end,

	draw = function(self, projection, batch)

		local graphic = self.graphic
		local size = self.size
		local length = self.length
		local offset = self.offset
		local ceiling = self.ceiling
		local color = self.color

		local x, y = projection.x, projection.y
		lg.setColor(255, 255, 255)

		local r = 0
		local sx = 1.35
		local sy = size.h
		local ox = offset.x
		local oy = 1

		--graphic:add(batch, x, ceiling, 0, 1.2, y - ceiling, 2.4)

		batch:setColor(255, 255, 255)
		graphic:add(batch, x, y, r, sx, sy, ox, oy)

		-- particles
		local snapped, particles
		snapped = self.snapped
		particles = self.particles

		if snapped then
			particles:setPosition(x, y - 30)
			lg.draw(particles, 0, 0)
		end

		-- loose bits
		for _, strand in ipairs(self.pieces) do
			batch:setColor(255, 255, 255)
			local position = strand.position
			local h = strand.h
			local angle = strand.angle
			graphic:add(batch, position.x, position.y, angle, sx, h, offset.x)
		end


	end,

	snap = function(self)

		self.uncullable = true
		self.snapped = true
		self.static = false
		observer:emit('release_collidable', self.key)
		observer:emit('release_collider', self.key)
		self.particles:start()

	end,

	parent = function(self, parent)
		self.edible = parent
	end,

	collide = function(self, args)

		if (not self.snapped) then

			self:snap()
			self.edible:release()
			metrics:add('vines', 1)

			if not options.safemode then
				local strand = {
					position = {
						x = self.position.x,
						y = args.collider.top,
					},
					initial = self.position.y - args.collider.top,
					h = self.position.y - args.collider.top,
					angle = 0,
					timer = 0,
					duration = 0.6,
				}

				table.insert(self.pieces, strand)
			end

			self.position.y = args.collider.top
			self.initial = args.collider.top

		end

	end,

	destroy = function(self)
		local particles = self.particles
		if particles then
			recycle(particles)
		end
		self.particles = nil
	end,


	
}