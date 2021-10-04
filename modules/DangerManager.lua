DangerManager = class{
	init = function(self, objects)

		self.objects = objects
		self.lions = {}
		self.queue = {}
		self.locked = true

		observer:register('attack', function() self:add() end)
		observer:register('lock', function() self.locked = true end)

		-- this should use a globally exposed var 'lion_frequency'
		self.started = false
		self.frequency = 1
		self.spawner = {
			timer = options.lion_delay,
			duration = function() return (1 + 5 * math.random()) * self.frequency end,
		}

		observer:register('evening', function()
			self.dormant = true
			if (not self.locked) then
				local message = 'night night'
				local graphic = self.graphic
				observer:emit('notify', message, graphic)
			end
		end)

		observer:register('morning', function()
			self.dormant = false
			if (not self.locked) then
				local message = 'good morning'
				local graphic = self.graphic
				observer:emit('notify', message, graphic)
			end
		end)

		self.graphic = Graphic('lion_icon')

	end,

	update = function(self, dt)

		local queue = self.queue
		for _,callback in ipairs(queue) do
			callback.delay = math.min(callback.delay + dt, callback.duration)
			if callback.delay == callback.duration then
				callback.task()
				table.remove(queue, _)
			end
		end

		local locked = self.locked
		if (not locked) then
			local spawner = self.spawner
			spawner.timer = (spawner.timer) and (spawner.timer - dt) or (spawner.duration())
			if spawner.timer < 0 then
				spawner.timer = spawner.duration()
				self:add()
				if (not self.started) and (not self.dormant) then
					self.started = true
					observer:emit('turn')
				end
			end
		end

		local objects = self.objects
		local lions = self.lions

		local edge = {
			(viewport.x - window.center.x - window.padding),
			(viewport.x + window.center.x + window.padding * 6),
		}

		for i, lion in pairs(lions) do
			-- check if lion is flipped and behind viewport.x
			local bound = objects:bounds(lion.key)
			if (bound.right < edge[1]) then
				if lion.rig.flipped then
					self:remove(i)
				end
			end
			-- lion moves past the viewport right edge
			if (bound.left > edge[2]) then
				self:remove(i)
			end
		end

	end,

	draw = function(self)

		lg.setColor(255, 0, 0)
		--local x
		lg.print(self.spawner.timer, 15, 15)
		--x = window.width * self.progress
		--lg.line(x, 0, x, window.height)

	end,

	add = function(self)

		local locked = self.locked
		if locked then
			return
		end
		
		local objects = self.objects
		local lions = self.lions
		local dormant = self.dormant
		local span = 500

		-- TODO set this value in Difficulty Manager
		local quantity = math.ceil(self.quantity * math.random())
		local n = (not dormant) and quantity or 1
		n = (options.lion_enabled) and n or 0


		for i = 1, n do

			local callback = function()

				local offset = window.padding + (window.padding * i / n) * math.random()

				-- time of day placement
				-- hidious but life goes on
				local start
				if dormant then
					start = viewport.x + window.center.x + window.padding * 6
				else
					start = (viewport.x - window.center.x - offset)
				end

				local head = LionHead()
				local forelegs = LionLegs('forelegs')
				local hindlegs = LionLegs('hindlegs')
				local tail = LionTail()
				local rig = Lion(start, head, forelegs, hindlegs, tail)
				
				-- add all the lion bits to the object manager
				local head_key = objects:add(head)
				local forelegs_key = objects:add(forelegs)
				local hindlegs_key = objects:add(hindlegs)
				local tail_key = objects:add(tail)
				local rig_key = objects:add(rig)

				local lion = {
					rig = rig,
					key = rig_key,
					children = {head_key, forelegs_key, hindlegs_key, tail_key},
				}

				-- keep track of this lion
				table.insert(lions, lion)

				-- startle the player
				if dormant then
					rig:sleep()
				else
					rig:hop()
					observer:emit('startle')
					sound:emit('roar')
				end

			end

			--local duration = 1 * (i - 1 / n) + 0.3 * math.sin(math.random() * math.pi * 2)
			local duration = 0.6 * (i-1) * (1/n)
			duration = n > 1 and duration or 0

			self.queue[#self.queue + 1] = {
				delay = 0,
				duration = duration,
				task = callback,
			}

		end

	end,

	remove = function(self, index)
		local objects = self.objects
		local lions = self.lions
		local lion = lions[index]
		if lion then

			-- release the colliders
			lion.rig:release()

			-- remove the rig
			objects:remove(lion.key)

			-- remove the rig's components
			for i = 1, #lion.children do
				objects:remove(lion.children[i])
			end

			-- remove the reference in the index
			table.remove(lions, index)
		end
	end,

	toggle = function(self)
		self.locked = not self.locked
	end,

	setDifficulty = function(self, difficulty)
		self.difficulty = difficulty
	end,

	setQuantity = function(self, n)
		self.quantity = n
	end,

	setFrequency = function(self, n)
		self.frequency = n
	end,

	clear = function(self)

		local objects = self.objects
		local lions = self.lions

		local edge = {
			(viewport.x - window.center.x),
			(viewport.x + window.center.x),
		}

		for _,lion in pairs(lions) do
			objects:remove(lion.key)
			for i = 1, #lion.children do
				objects:remove(lion.children[i])
			end
			table.remove(lions, _)
		end

		self.frequency = 1
		self.spawner = {
			timer = options.lion_delay,
			duration = function() return (1 + 5 * math.random()) * self.frequency end,
		}

	end,

	flip = function(self, silently)
		local lions = self.lions
		for _,lion in pairs(lions) do
			lion.rig:flip(silently)
		end
	end,
}