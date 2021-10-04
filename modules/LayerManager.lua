LayerManager = class{
	
	init = function(self, objects)

		-- create hook for objects so that they can be validated when sorting
		self.objects = objects

		-- init table for object layers
		self.layers = {}

		-- init table for drawstack
		self.stack = {}

		-- init depth index table
		self.index = {}

		-- priority whitelist
		self.prioritized = {}

		-- layers are empty on init, so they are already sorted
		self.sorted = true

	end,

	-- add an object to the layer manager
	register = function(self, key)

		local layers = self.layers
		local prioritized = self.prioritized
		local indices = self.index
		local depth, priority = self:depth(key)

		if depth then

			-- check if this object has priority?

			layers[depth] = (layers[depth]) and (layers[depth]) or ({})
			local i = #layers[depth] + 1
			layers[depth][i] = key
			indices[key] = {
				depth = depth,
				index = i,
			}

			if priority then
				prioritized[key] = true
			end 

			self.sorted = false

		end

	end,

	-- release an object from the layer manager
	release = function(self, key)

		local index = self.index
		local layers = self.layers
		local prioritized = self.prioritized

		local i = index[key].index
		local depth = index[key].depth

		index[key] = nil
		layers[depth][i] = nil
		prioritized[key] = nil

		-- set sorted to false so that the key is not passed into the drawstack
		self.sorted = false
		
	end,

	-- return the drawstack ordered by object depth (deepest first)
	sort = function(self, keys)

		local prioritized = self.prioritized

		if (not self.sorted) then

			-- removing this seems to solve my problem
			if keys then
				for i = 1, (#keys) do
					--self:release(keys[i])
					--self:register(keys[i])
				end
			end

			local stack = {}
			for k, layer in spairs(self.layers) do

				-- using spairs here, while less performant, causes earlier
				-- objects to appear over later ones
				-- which is probably the behaviour I'd like...

				local priority = {}

				for i, key in spairs(layer) do
					local prioritize = prioritized[key]
					if prioritize then
						priority[#priority + 1] = key
					else
						-- skip for now if has priority
						stack[#stack + 1] = key
					end
				end

				for i, key in ipairs(priority) do
					stack[#stack + 1] = key
				end

			end

			self.stack = stack
			self.sorted = true

		end

	end,

	-- get a list of properly sequenced object keys for drawing
	get = function(self)

		return self.stack

	end,

	flag = function(self)
		self.sorted = false
	end,

	depth = function(self, key)

		local depth, prioritize
		local object = self.objects[key]
		if not (type(object) == 'number') then

			-- hmm
			local asset = object:get()
			depth = (asset.position.z) and (asset.position.z) or (1)
			prioritize = asset.prioritize

			-- change the name of this function and also get priority here

		end

		return depth, prioritize

	end,
}