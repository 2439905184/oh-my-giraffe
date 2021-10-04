	Prop = class{

	init = function(self, key, asset, position, label, event)

		self.key = key
		self.label = label
		self.asset = asset
		self.position = position
		self.size = asset:get().size
		self.event = event
		self.scale = options.terrain_scale
		self.velocity = {
			x = 0,
			y = 0,
		}
		self.static = true
		self.batched = true
		self.cold = true

		if (label == 'cloud') then
			self.velocity.x = -5
			self.static = false
		end

		self.color = {255, 255, 255}

		if not options.terrain_enabled then
			self.inactive = true
		end

	end,

	update = function(self, dt)
		if not self.static then
			self.position.x = self.position.x + self.velocity.x * dt
		end
	end,

	draw = function(self, projection, batch)

		local scale = self.scale
		local asset = self.asset
		local color = self.color

		batch:setColor(color)
		asset:add(batch, projection.x, projection.y, 0, scale, scale)
		
	end,

	-- this is probably only used during creation 
	get = function(self)

		local properties

		properties = {
			position = self.position,
			size = self.asset:get().size,
			label = self.label,
		}

		return properties

	end,

	-- where do I use this method?
	child = function(self)

		local asset = self.asset:get()
		return asset

	end,

	collide = function(self, args)

		local event, fired
		-- this seems like a pretty ugly way to handle emits, I should instead use "collide"
		event = self.event
		triggered = self.triggered

		if (event) and (not triggered) then
			observer:emit(event.trigger)
			self.triggered = true
		end

	end,
	
}