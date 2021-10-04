ScoreManager = class{
	init = function(self, objects)

		-- global signal namespace
		score = signals.new()
		score:register('report', function(...) self:report(...) end)
		score:register('disrupt', function(method) self:disrupt(method) end)
		score:register('lock', function() self.locked = true end)
		score:register('unlock', function() self.locked = false end)

		self.points = 0
		self.locked = true
		self.started = false
		self.tokens = {}
		self.inactive = {}
		self.objects = objects
		self.combo = options.combo_start
		self.wallet = 0
		self.phase = 0

		self.scorepanel = ScorePanel()

		self.timer = 0
		self.duration = options.combo_leeway
		self.warned = false

		self.rate = 0.07
		self.record = 0
		self.leaking = false

		g["score"] = self

	end,

	update = function(self, dt)

		local objects = self.objects
		local tokens = self.tokens
		local inactive = self.inactive

		local left = viewport.x - window.center.x
		local limit = viewport.x - window.width
		local warn

		for i,key in ipairs(tokens) do
			local bound = objects:bounds(key)
			if (bound.right < left) then
				if (#tokens ~= 1) then

					-- put it into inactive
					local object = objects.objects[key]
					--objects:tell(key, 'pop', 0)
					--objects:tell(key, 'collect')

					inactive[#inactive + 1] = key
					table.remove(tokens, i)
					


				else
					warn = true
				end
			end
		end


		for i,key in ipairs(inactive) do
			local bound = objects:bounds(key)
			if (bound.right < left - window.center.x) then
				-- remove the actual object
				objects:remove(key)
				table.remove(inactive, i)
			end
		end

		if (warn) and (not self.locked) and (not self.warned) then
			--self:reset()
			self.warned = true
			self.leaking = true
			self.rate = (self.duration + 1.1) / self.combo

			observer:emit('warn', self.duration)
			sound:emit('boo', {delay = 1})
			sound:emit('roll', {delay = 0.15})

			if self.combo == 1 then
				self.rate = self.duration / 2
			end
			-- start the thing
		end

		if self.warned then
			self.timer = math.min(self.timer + dt, self.duration)
			if self.timer == self.duration then
				self:reset()
			end
		end

		if self.leaking then
			self.timer = math.min(self.timer + dt, self.rate)
			if self.timer == self.rate then
				self.combo = math.max(self.combo - 1, 0)
				self.timer = 0
				--sound:emit('click', {volume = {0.1, 0.2}})
			end
			if self.combo == 0 then
				self.leaking = false
				self.timer = 0
				local key = tokens[#tokens]

				--objects:remove(key)
				table.remove(tokens, #tokens)
				table.insert(inactive, key)

				if self.warned or false then
					observer:emit('dismiss')
					self.timer = 0
					self.warned = false
				end
			end
		end

		local points = self.points
		local combo = self.combo

		local started = self.started
		if started then
			metrics:set('score', points)
			metrics:set('combo', combo)
			metrics:bid('best_combo', combo)
		end

		self.scorepanel:update(dt)

	end,

	draw = function(self, batch)
		self.scorepanel:draw(batch)
	end,

	-- report the position of a new score panel
	-- add a new token

	-- TODO
	-- this causes a lot of lag on iOS!
	report = function(self, ...)

		-- don't accept this until the game has started
		local locked = self.locked
		if not locked then
			
			local objects = self.objects
			local tokens = self.tokens
			local combo = self.combo
			local phase = self.phase
			local points = self.points

			local value = combo + 1
			local token = Orb(...)
			local points = Points(...)
			-- seperate scoretoken into score orb and points

			token:phase(phase)
			points:set(value)
			
			local parent = objects.objects[tokens[#tokens]]
			if parent then
				token:join(parent)
				parent.asset.child = token
				parent.asset.cooldown = 0.5
			end

			local key = objects:add(token)
			table.insert(tokens, key)

			objects:add(points)

			self.combo = value
			self.points = self.points + value

			self.phase = phase + (0.25)
			self.record = math.max(value, self.record)
			self:dismiss()

		else
			-- start game
			-- this causes a bug which dismisses the retry button
			if not self.started then
				signals.emit('start')
				self.locked = false
				self:report(...)
			end
		end

	end,

	-- disrupt a combo
	-- break tokens
	disrupt = function(self, method)
		local objects, tokens
		objects = self.objects
		tokens = self.tokens

		local method = method or 'collect'

		if (#tokens > 0) then

			observer:emit('flash')
			observer:emit('jiggle')

			local duration = (0.6 / #tokens)

			-- trigger all the active tokens to pop and be removed upon completion
			for i, key in spairs(tokens) do
				local step = duration * (i - 1)
				objects:tell(tokens[i], 'pop', step)
				objects:tell(tokens[i], method)
				tokens[i] = nil
			end

			if method == 'collect' then
				self.locked = true
				self:reset()
			end
			
		end
	end,

	dismiss = function(self)

		local warned = self.warned
		if self.warned then
			observer:emit('dismiss')
			self.timer = 0
			self.warned = false
		end
		if self.leaking then
			self.timer = 0
			self.leaking = false
		end
		
	end,

	reset = function(self)
		-- reset the combo
		--self.combo = 0
		--self.wallet = 0
		self.leaking = true
		self.timer = 0
	end,

	check = function(self, key)

	end,

	get = function(self)
		return self.points, self.combo
	end,

	setTransition = function(self, transition)
		self.scorepanel:setTransition(transition)
	end,

	clear = function(self)

		self.points = 0
		self.combo = 0
		self.timer = 0
		self.warned = false
		self.leaking = false
		self.scorepanel:clear()
		observer:emit('dismiss')

		metrics:set("best_combo", 0)
		metrics:set('score', 0)
		metrics:set('combo', 0)

		-- remove any score tokens
		local objects = self.objects
		local tokens = self.tokens
		for i,key in pairs(tokens) do
			objects:remove(key)
			table.remove(tokens, i)
		end
		self.tokens = {}
	end,

}
