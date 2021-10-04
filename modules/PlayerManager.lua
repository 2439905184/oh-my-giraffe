PlayerManager = class{
	init = function(self, objects, offset)

		--[[
		this is set up in a truly horrific way
		it makes me very sad
		]]--

		local position, input, length, start, range, padding
		local controller, danger, progress
		local offset = offset or 0

		-- errr, hard coded body  length
		local padding = (window.padding / 2)

		-- why can i ignore body length here?
		local length = window.width - padding * 2
		local start = 0.37
		
		local position = {
			x = window.width / 2,
			y = window.height / 2,
			z = 1,
		}

		local origin = {
			x = position.x - 70,
			y = position.y - 150,
			z = position.z
		}

		local body_position = {
			x = offset + padding + length * start,
			y = window.height - world.floor - 90,
			z = 1
		}

		-- init giraffe rig

		local wind = Wind()
		local horn = GiraffeHorn(position)
		local ear = GiraffeEar(position)
		local mouth = GiraffeMouth(position)
		local head = GiraffeHead({x = origin.x + offset, y = origin.y, z = origin.z}, mouth, horn, ear)
		local forelegs = GiraffeLegs('forelegs')
		local hindlegs = GiraffeLegs('hindlegs')
		local tail = GiraffeTail()
		local body = GiraffeBody(body_position, forelegs, hindlegs, tail, wind)
		local neck = GiraffeNeck()

		-- init the head anchors
		local anchors = {
			head = head:attach(),
			body = body:attach(),
		}
		neck:set(anchors)

		-- init managers
		local input = InputManager(origin, true)
		local progress_offset = offset / (window.width - padding * 2)
		local progress = ProgressManager(start, length)
		local controller = PlayerController(position.x + offset, position.y)

		local rig = Giraffe(body, head, neck)

		local sequence = true

		-- this is really bad, I should use a signal to remember this key rather than declare it as a global

		local keys = {}
		if options.player_enabled then

			local rig_key = objects:add(rig, sequence)
			local ear_key = objects:add(ear, sequence)
			local mouth_key = objects:add(mouth, sequence)
			local head_key = objects:add(head, sequence)
			local horn_key = objects:add(horn, sequence)
			local neck_key = objects:add(neck, sequence)
			local body_key = objects:add(body, sequence)
			local forelegs_key = objects:add(forelegs, sequence)
			local hindlegs_key = objects:add(hindlegs, sequence)
			local tail_key = objects:add(tail, sequence)
			local wind_key = objects:add(wind, sequence)

			keys = {
				ear_key,
				mouth_key,
				horn_key,
				head_key,
				neck_key,
				body_key,
				forelegs_key,
				hindlegs_key,
				tail_key,
				wind_key,
				rig_key,
			}

		end

		-- doing this clears the ui from using these signals...
		

		observer:register('bounce', function() self.rig:jolt() end)
		observer:register('flip', function() self:flip() end)

		-- TODO add the giraffe head reactions here
		observer:register('warn', function() self.rig.head:warn() end)
		observer:register('startle', function() self.rig.head:startle() end)
		observer:register('turn', function() self.rig.head:look() end)

		-- save a reference for all the components
		self.rig = rig
		self.keys = keys
		self.objects = objects
		self.input = input
		self.controller = controller
		self.progress = progress
		self.danger = danger
		self.slowmo = {
			enter = 0,
			exit = 0,
		}

	end,

	update = function(self, dt)

		self.controller:update(dt)
		self.input:update(dt)

		local dx, dy, x, y, throttle = self.controller:get()
		local ix, iy = self.input:delta()

		self.rig:setWiggle(throttle)

		-- this probably doesn't work retina/alternate dpi
		local offset = (-50 / window.width)
		local floor = (self.input:get() / window.width) + offset

		self.progress:bound(floor)
		self.progress:limit(throttle)
		self.progress:update(dt)
		local px, py = self.progress:get()

		-- move the body and head
		local rig = self.rig
		local flipped = self.flipped
		rig.body:move(dx + px, dy + py)
		rig.head:move(dx, dy)
		if not flipped then
			rig.head:move(ix, iy)
		end

		-- slowmo transitions
		local slowmo = self.slowmo
		self.slowmo.enter = slowmo.enter - dt
		self.slowmo.exit = slowmo.exit - dt

		if (slowmo.enter < 0) then
			self.slowmo.enter = 0
			settings.slowmo = true
			audio:enterSlowmo()
		end

		if (slowmo.exit < 0) then
			self.slowmo.exit = 0
			settings.slowmo = false
			audio:exitSlowmo()
		end

	end,

	start = function(self)
		self.controller.throttle = 0.5
		self.controller:start()
		self.progress.min = 0.05
		self.rig:jolt()
		signals.emit('switch', 'close')
	end,

	flip = function(self)
		if not self.flipped then
			self.rig:flip()
			self.controller:slide()
			self.progress.min = 0
			self.flipped = true
			self.slowmo.enter = 0.2
			self.slowmo.exit = 0.5

			observer:emit('jiggle')
			observer:emit('dismiss')
			sound:emit('drum')
			
		end
	end,

	setSpeed = function(self, n)
		self.controller:setSpeed(n)
	end,

	get = function(self)
		return self.controller:get()
	end,

	draw = function(self)
		self.input:draw()
		self.progress:draw()	
	end,

	mousepressed = function(self, x, y, button)
		self.input:mousepressed(x, y, button)
	end,

	mousereleased = function(self, x, y, button)
		self.input:mousereleased(x, y, button)
	end,

	keypressed = function(self, key, code)
		self.controller:keypressed(key, code)

		if key == 'j' then
			self.rig:jolt()
		end

		if key == 'f' then
			observer:emit('flip')
		end

	end,

	keyreleased = function(self, key, code)
		self.controller:keyreleased(key, code)
	end,

	touchpressed = function(self, id, x, y, pressure)
		self.input:touchpressed(id, x, y, pressure)
	end,

	touchreleased = function(self, id, x, y, pressure)
		self.input:touchreleased(id, x, y, pressure)
	end,

	touchmoved = function(self, id, x, y, pressure)
		self.input:touchmoved(id, x, y, pressure)
	end,

	setAcceleration = function(self, n)
		self.progress:setAcceleration(n)
	end,

	destroy = function(self)
		local keys = self.keys
		local objects = self.objects
		for i = 1, #keys do
			objects:remove(keys[i])
		end
	end,

	release = function(self)
		local keys = self.keys
		local objects = self.objects
		for i = 1, #keys do
			local label = objects.objects[keys[i]].asset.label
			if label then
				observer:emit('release_collider', keys[i], label)
			end
		end
		observer:clear('bounce')
		observer:clear('flip')
		observer:clear('warn')
		observer:clear('startle')
		observer:clear('turn')
		self.rig.static = true
		self.rig.neck.static = true
		self.rig.head.static = true
		self.rig.body.static = true
		self.rig.body.forelegs.static = true
		self.rig.body.hindlegs.static = true
	end,

}