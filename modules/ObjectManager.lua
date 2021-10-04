ObjectManager = class{
	
	init = function(self)
		
		local objects = {}
		self.objects = objects
		self.recycling = {}
		self.validated = {}
		self.pool = {}
		self.layers = LayerManager(objects)

		observer:register('release', function(key) self:remove({key}) end)

		g.objects = self

	end,

	update = function(self, dt)

		local objects = self.objects
		local layers = self.layers

		for key = 1, #objects do
			local valid, pointer = self:validate(key)
			if valid then
				object = objects[key]
				local static = object.asset.static
				if not static then
					object:update(dt)
				end
			end
		end

		layers:sort()

	end,

	draw = function(self)
		local recycling = self.recycling
		for i,key in pairs(recycling) do
			--lg.setColor(255, 255, 0)
			--lg.print(key, 30, 15 + 20 * i)
		end
	end,
	
	add = function(self, object, sequence)

		local objects, recycling, key, drawable

		-- get the objects and the future key
		local objects = self.objects
		local recycling = self.recycling
		local pool = self.pool

		-- check for any available keys here...
		-- key = #objects + 1
		key, i = self:pop(sequence)
		table.remove(recycling, i)

		-- encapsulate the object as a drawable for camera projection and culling
		local drawable
		if #pool > 0 then
			drawable = table.remove(pool, 1)
			drawable:init(object, key)
		else
			drawable = Drawable(object, key)
		end

		object.drawable = drawable

		-- add the drawable to the objects list using the key
		-- using table.insert() here pushes around existing objects such that there is collision later on
		objects[key] = drawable

		-- register the key in the layer index
		self.layers:register(key)

		-- make sure the key validates
		self.validated[key] = {true}

		-- flush any existing collisions bound to this key
		observer:emit('flush', key)

		-- lastly init the objects's collision bindings
		drawable:register(key)

		return key

	end,

	remove = function(self, keys)

		if keys then

			-- cast input to a queue list
			local queue
			if (type(keys) == 'number') then
				queue = {keys}
			elseif (type(keys) == 'table') then
				queue = keys
			else
				error('malformed object removal format')
			end

			local pool = self.pool
			local objects = self.objects

			for i,key in pairs(queue) do

				if self:validate(key) then

					-- remove validation of key
					self.validated[key] = nil

					-- call destroy method if one exists
					local object = objects[key]
					object:destroy()
					table.insert(pool, object)

					-- set the object value to the key after the removal queue
					objects[key] = queue[#queue] + 1

					-- release the key from layer manager
					self.layers:release(key)

					-- add key to recycling
					self.recycling[#self.recycling + 1] = key

				else
					print('attemped to remove invalid key: ' .. tostring(key))
				end

			end

		end

	end,

	-- returns a sorted drawstack and object list
	get = function(self)

		-- sort the drawstack (is only invoked if layers has been flagged)
		local drawstack = self.layers:get()
		local objects = self.objects

		return drawstack, objects

	end,

	-- returns the number of objects in the drawstack
	count = function(self)

		return #self.layers:get(), #self.objects

	end,

	-- recycle a key or make a new one for object creation
	pop = function(self, sequence)

		local objects = self.objects
		local recycling = self.recycling

		local index = 1
		local key

		if sequence then
			local head = #objects + 1
			index = nil
			for i = 1, #recycling do
				if recycling[i] < head then
					head = recycling[i]
					index = i
				end
			end
			key = head
		else
			key = (#recycling > 0) and (recycling[index]) or (#objects + 1)
		end

		return key, index

	end,

	-- validates an object
	-- returns nil if no object, false if object is a pointer, and true if valid object

	-- I should do this once per frame per object, no more...
	validate = function(self, key)

		local validated = self.validated

		if validated[key] then
			return validated[key][1], validated[key][2]
		elseif (validated[key] == nil) then
			local object = self.objects[key]
			if object then
				local pointer
				local valid = (type(object) ~= 'number')
				if (type(object) == 'number') then
					pointer = key + 1
				end
				validated[key] = {valid, pointer}
				return self:validate(key)
			end
		end

	end,

	bounds = function(self, key)

		local valid

		valid = self:validate(key)
		if valid then

			local properties, bound, rectangle, position, offset

			properties, bound = self.objects[key]:get()
			
			rectangle = bound.rectangle

			local result = {
				left = rectangle.left + properties.position.x,
				right = rectangle.right + properties.position.x,
				top = rectangle.top + properties.position.y,
				bottom = rectangle.bottom + properties.position.y,
			}

			if not rectangle then
				--error('no bound rectangle')
			end

			return result

		end

	end,

	properties = function(self, key)

		return self.objects[key]:get()

	end,

	label = function(self, key)
		-- this could create an error if called on an invalid object
		local label = ''
		local object = self.objects[key]
		local valid = self:validate(key)
		if valid then
			local asset = object.asset
			label = asset.label
		end

		return label
	end,

	collide = function(self, key, ...)

		--local valid = self:validate(key)
		if key then
			local message = self.objects[key]:collide(...)
			return message
		end

	end,

	tell = function(self, key, message, ...)
		if key and message then
			self.objects[key]:tell(message, ...)
		end
	end,

}