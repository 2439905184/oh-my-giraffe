EdibleManager = class{
	
	init = function(self, objects, controller)

		self.objects = objects
		self.controller = controller
		self.zones = {}
		self.recycling = {}
		self.voided = {}
		self.limbo = {}

		local net = Region({x = 0, y = 0, z = 1}, {w = window.padding*0.5, h = window.height}, {x = -window.padding*0.5, y = 0}, 'net')
		observer:emit('collider', objects:add(net))
		self.net = net

		self.density = options.edible_density
		self.n = 0
		self.e = 0
		self.avoid = 0
		self.difficulty = 0
		self.active = true
		self.edge = 0

		observer:register('void', function(range) self:void(range) end)
		observer:register('burst', function() self.e = math.max(self.e + 1, 0) end)
		observer:register('missed', function() self.e = math.max(self.e - 1, 0) end)
		observer:register('avoid', function(y) self.avoid = y end)

	end,

	draw = function(self)
		lg.setColor(0, 200, 255)
		lg.line(0, self.avoid, window.width, self.avoid)
	end,

	update = function(self, dt)

		-- get the viewport position and dimensions
		local x, y, z, w, h, bound, padding
		x, y, z = self.controller:get()
		w, h, padding = window.width, window.height, window.padding

		-- set the bound for zone trimming and appending
		bound = {
			left = x - window.center.x,
			right = x + (w / 2) + padding,
		}

		if options.edible_enabled then
			self:append(bound.right)
			self:truncate(bound.left)
		end

		local voided
		voided = self.voided
		for i = 1, #voided do
			local range = voided[i]
			if range then
				if (range.right < bound.left) then
					table.remove(voided, i)
				end
			end
		end

		local limbo
		limbo = self.limbo
		for i = 1, #limbo do

			local key = limbo[i]

			-- get the object position
			-- check it against bound.left
			-- delete it if it is outside
			local bound = self.objects:bounds(key)
			if bound then

				-- if removable
				if (bound.right < region.left) then
					self.objects:remove(key)
					table.remove(limbo, i)
					--print('removed an edible from limbo')
				end

			end

		end

		-- update the net position
		self.net:set(bound.left, 0)

		-- the edible density should be set here using a difficulty value
		--self.density = math.max(options.edible_density - difficulty * 10, options.edible_density * 0.5)
		--self.density = options.edible_density - (options.edible_density * difficulty * 0.5)

	end,

	-- add a new zone after the last one
	add = function(self)

		-- todo
		-- set the position and size parameters of these zones somewhere else!
		-- incoperate a stress modifier

		local objects, zones, zone, previous, position, size, keys
		zones = self.zones
		objects = self.objects

		local edge = self.edge
		local previous = zones[self.previous]

		-- this height should also be proportional to the window.height
		if (not previous) or (type(previous) ~= 'table') then
			local x = edge
			local y = (50 / 640) * window.height
			local z = 1
			previous = {
				position = {
					x = x,
					y = y,
					z = z,
				},
				size = {
					w = 0,
					h = 0,
				},
			}
		end

		local x = math.max(previous.position.x, edge)

		position = {
			x = x + previous.size.w,
			y = previous.position.y,
			z = previous.position.z,
		}

		-- this height should be proportional to the screensize
		size = {
			w = 256,
			h = (300 / 640) * window.height,
		}

		zone = {
			position = position,
			size = size,
			keys = {},
		}

		-- don't spawn if the zone intersects with a voided range
		local intersecting, voided

		voided = self.voided
		if (#voided > 0) then
			local bound = {
				left = position.x,
				right = position.x + size.w,
				top = position.y,
				bottom = position.y + size.h
			}
			for i = 1, #voided do
				intersecting = boverlap(voided[i], bound)
				if intersecting then
					break
				end
			end
		end

		local density, padding, stock, cache

		density = math.floor(self.density)

		-- a little quirky, but this is an interesting way of attenuating the edible amounts
		-- since eating the fruits quicker on the right side of the screen causes the density to grow larger
		-- than just barely getting by, with a little adjustment and the correct base value it could
		-- be a good estimate of approximate skill

		local amplification = 0.2
		local cap = 0.8


		if (self.n > 0) then
			--density = density - math.floor(self.density) * math.min((self.e / self.n) * amplification, cap)
			--print(density .. ': ' .. self.n .. ' / ' .. self.e)
		end

		padding = options.edible_padding
		stock = (not intersecting) and (size.w / density) or 0
		cache = {}

		local failures = 0

		--[[
		-- add the previous zone's edibles to the proximity cache
		-- I probably don't need to do this, and it is bit faster to not check previous edibles.
		if previous.keys then
			for j,k in pairs(previous.keys) do
				local pos, dim, entry
				pos, dim = objects:properties(k)
				entry = {
					position = pos,
					size = dim,
				}
				-- curiously this causes weird patterns
				cache[#cache + 1] = entry
			end
		end
		]]--

		for i = 1, stock do

			-- todo
			-- make the edible y favor the center of the spawning zone
				-- if I do add this I'll want it to be terrible subtle

			local proposal, key
			proposal = {
				x = zone.position.x + zone.size.w * math.random(),
				y = zone.position.y + zone.size.h * math.random(),
				z = zone.position.z,
			}

			-- check proposed edible for adequate proximity to other edibles
			local spawn = true
			local pow = math.pow
			if (padding > 0) then
				for k = 1, #cache do
					local entry, distance, radius
					entry = cache[k]
					distance = pow(entry.position.x - proposal.x, 2) + pow(entry.position.y - proposal.y, 2)
					radius = pow(entry.size.h * padding, 2)
					if spawn and (distance < radius) then
						spawn = false
					end
				end
			end

			local avoid = self.avoid
			if math.abs(avoid - proposal.y - 30) < 60 then
				spawn = false
			end

			-- spawn the edible
			if spawn then

				local vine = Vine(proposal)

				local graphic

				local horn = g["horn"]
				local time = metrics:get("time")
				local elapsed = metrics:get("elapsed")
				local special = (not horn.active) and (elapsed > 0)
				if special then
					graphic = Graphic('edible')
				else
					while not graphic do
						local attempt = Graphic('edible')
						if attempt.variant ~= 3 then
							graphic = attempt
							break
						end
					end
				end

				local edible = Edible(graphic, proposal, vine)
				
				local edible_key = objects:add(edible)
				local vine_key = objects:add(vine)

				vine:parent(edible)

				local properties = objects:properties(edible_key)

				-- this entry is just useds for eliminating spawning next to another, I think
				-- so the fact that the position may change is not important here
				local entry = {
					position = {
						x = properties.position.x + (properties.size.w / 2),
						y = properties.position.y + (properties.size.h / 2),
					},
					size = properties.size,
				}

				cache[#cache + 1] = entry

				-- add edible and vine key to current zone list for removal when out of bounds
				table.insert(zone.keys, edible_key)
				table.insert(zone.keys, vine_key)

				self.n = self.n + 1

			else
				failures = failures + 1
			end

		end

		-- temporary marker
		--local key = self.objects:add(Region(zone.position, zone.size))
		--zone.keys[#zone.keys + 1] = key

		self.previous = self:recycle()
		zones[self.previous] = zone

	end,

	remove = function(self, key)

		local zones, zone
		zones = self.zones

		zone = zones[key]
		if self:validate(key) then

			-- get the viewport position and dimensions
			local x, y, z, w, h, bound, padding
			x, y, z = self.controller:get()
			w, h, padding = window.width, window.height, window.padding

			-- get the region for zone trimming and appending (I should actually just have a getter for this)
			region = {
				left = x - (w / 2) - padding,
				right = x + (w / 2) + padding,
			}

			-- curiously this cannot be passed as an array
			for i,k in ipairs(zone.keys) do

				-- if this object is still in frame, add it to limbo and check it outside of the zone?
				local bound = self.objects:bounds(k)
				if bound then

					-- if removable
					if (bound.right < region.left) then
						self.objects:remove(k)
					else
						table.insert(self.limbo, k)
					end

					-- this is only use for attenuation so if a fruit is on the floor
					-- it shouldn't really count against that
					self.n = math.max(self.n - 1, 0)
					self.e = math.max(self.e - 1, 0)

				else
					print('edible did not return a bound')
				end

			end
			--self.objects:remove(zone.keys)

			-- add the key to recycling
			self.recycling[#self.recycling + 1] = key

			-- nil the zone data using it's integer key
			zone = nil
			zones[key] = key

		end

	end,

	recycle = function(self)

		local zones, recyling, key
		zones = self.zones
		recycling = self.recycling
		key = (#recycling > 0) and recycling[#recycling] or (#zones + 1)
		table.remove(recycling, #recycling)
		return key

	end,

	-- add edibles up to edge point, excluding void points
	append = function(self, edge)

		local active = self.active
		local zones = self.zones
		local populated

		-- todo
		-- retrieve voided areas
		-- exclude voided areas

		while not populated and active do
			local void
			for key = 1, #zones do
				if self:validate(key) then
					local position
					position = zones[key].position
					size = zones[key].size
					if (edge < position.x + size.w) then
						void = true
					end
				end
			end
			if not void then
				self:add()
			else
				break
			end
		end

	end,

	-- trim edibles up to edge point
	truncate = function(self, edge)

		local zones, zone, key
		zones = self.zones

		for key = 1, #zones do
			local valid, pointer = self:validate(key)
			if valid then
				zone = zones[key]
				if (edge > zone.position.x + zone.size.w) then
					self:remove(key)
				end
			end
		end

	end,

	-- void a range from spawning edibles
	void = function(self, range)
		table.insert(self.voided, range)
	end,

	validate = function(self, key)
		local zone, pointer
		zone = self.zones[key]
		if zone then
			if type(zone) == 'number' then
				pointer = zone
			end
			return (type(zone) ~= 'number'), pointer
		end
	end,

	setDensity = function(self, n)
		self.density = n
	end,

}