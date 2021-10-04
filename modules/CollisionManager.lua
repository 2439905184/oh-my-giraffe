-- add support for having multiple keys per collider label
-- i need that for danger

CollisionManager = class{
	init = function(self, objects)

		self.objects = objects
		self.colliders = {}
		self.collidables = {}

		-- clear the patterns we are about to register
		-- this breaks having multiple scenes active, however
		-- a better solution would be to use a scene specific prefix
		-- or an isolated namespace

		-- when using multiple scenes, this causes a lot of trouble
		observer:register('collider',
			function(key)
				if key then
					self:register_collider(key)
				end
			end)

		observer:register('collidable',
			function(key, colliders)
				if key and colliders then
					self:register_collidable(key, colliders)
				end
			end)

		observer:register('release_collider',
			function(key, label)
				if key and label then
					self:release_collider(key, label)
				end
			end)

		observer:register('release_collidable',
			function(key)
				if key then
					self:release_collidable(key)
				end
			end)

		observer:register('flush', function(key) self:flush(key) end)

		self.count = 0

	end,

	-- debug output
	draw = function(self)
	
		lg.setColor(255, 255, 255)
		local colliders = self.colliders

		local i = 1
		lg.print('{colliders}', 150, 20)

		local colliders_string = ''
		for label, keys in pairs(colliders) do
			local s = table.concat(keys, ", ", 1, #keys)

			colliders_string = colliders_string .. label .. '( ' .. #keys .. ' ) : [' .. s .. ']' .. '\n'
			--lg.print(label .. ': [' .. s .. ']', 150, 20 + 15 * i)
			i = i + 1
		end

		lg.print(colliders_string, 15, 15)

		local collidables = self.collidables

		local blacklist = {'event', 'vine', 'edible'}
		blacklist = {}

		local list = {'{collidables}'}
		local collidables_string = ''
		for k, v in pairs(collidables) do
			if (#v > 0) then
				local s = table.concat(v, ", ", 1, #v)
				local label = self.objects:label(k)

				local continue = true

				for i = 1, #blacklist do
					if blacklist[i] == label then
						continue = false
						break
					end
				end

				if continue then
					local s = '\'' .. label .. '\' (' .. k .. "): [" .. s .. ']'
					collidables_string = collidables_string .. s .. '\n'
					--list[#list + 1] = output
				end

			end
		end

		for i = 1, #list do
			--lg.print(list[i], 700, 5 + 15 * i)
		end

		lg.print(collidables_string, 400, 15)

		lg.print('collision checks: ' .. self.count, 400, 20)

	end,

	update = function(self, dt)

		self.count = 0

		local objects = self.objects
		local colliders = self.colliders
		local collidables = self.collidables

		local colliders_cache = {}

		for collidable_key, collidable in pairs(collidables) do
			local valid = objects:validate(collidable_key)
			if valid then
				-- get collidable bound and label
				local collidable_bound = objects:bounds(collidable_key)
				local collidable_label = objects:label(collidable_key)

				-- get the collidable bound and label here
				for i, collider_label in ipairs(collidable) do
					if (colliders[collider_label]) then

						-- build cache for these colliders if there isnt one
						if (not colliders_cache[collider_label]) then
							colliders_cache[collider_label] = {}
							for j, collider_key in pairs(colliders[collider_label]) do
								local valid = objects:validate(collider_key)
								local label = objects:label(collider_key)
								local void
								if label ~= collider_label then
									void = true
								else
									if valid then
										colliders_cache[collider_label][j] = objects:bounds(collider_key)
									else
										-- remove this collider from colliders
										void = true
									end
								end
								if void then
									table.remove(colliders[collider_label], j)
								end
							end
						end
						-- check each collider_bound for collisions with the collidable_bound
						for j, collider_bound in ipairs(colliders_cache[collider_label]) do
							local collision = self:collide(dt, collider_bound, collidable_bound, collider_label, collidable_label)
							if collision then
								local collider_key = colliders[collider_label][j]
								-- tell objects about the collision
								local collidable_message = objects:collide(collider_key, collision, collidable_key)
								local collider_message = objects:collide(collidable_key, collision, collider_key)
								-- tell objects their respective responses
								objects:tell(collider_key, collider_message)
								objects:tell(collidable_key, collidable_message)
							end
						end
					end
				end
			else
				-- collidable_key is invalid, so remove it
				collidables[collidable_key] =  nil
			end

		end

	end,

	flush = function(self, key)

		local objects = self.objects
		local colliders = self.colliders
		
		for i, label in pairs(colliders) do
			for j = 1, #label do
				if label[j] == key then
					table.remove(label, j)
					break
				end
			end
		end


		local collidables = self.collidables
		collidables[key] = nil

	end,

	register_collider = function(self, key)

		local objects = self.objects
		local valid = objects:validate(key)
		if valid then
			local colliders = self.colliders
			local label = objects:label(key)
			if label then
				colliders[label] = colliders[label] or {}
				colliders[label][#colliders[label] + 1] = key
			end
		end

	end,

	register_collidable = function(self, key, colliders)

		local objects = self.objects
		local valid = objects:validate(key)
		if valid then
			local collidables = self.collidables
			if (not collidables[key]) then
				collidables[key] = colliders
			else
				for i = 1, #colliders do
					table.insert(collidables[key], colliders[i])
				end
			end
		end

	end,

	release_collidable_collider = function(self, key, voided)

		local collidables = self.collidables
		local collidable_colliders = collidables[key]
		
		-- remove colliders that are voided
		if collidable_colliders then
			for i, collider in pairs(collidable_colliders) do
				for j, void in pairs(voided) do
					if (collider == voided[j]) then
						table.remove(collidable_colliders, i)
						table.remove(voided, j)
					end
				end
			end
		end

	end,

	release_collidable = function(self, key)

		local collidables = self.collidables
		collidables[key] = nil

	end,

	release_collider = function(self, key, label)

		local colliders = self.colliders
		local search = colliders[label]

		if search then
			for i = 1, #search do
				if (search[i] == key) then
					table.remove(colliders[label], i)
					break
				end
			end
		end

	end,

	-- test two objects for collision and emit their respective functions if they do
	--collide = function(self, dt, subject, collider, target)
	collide = function(self, dt, collider, collidable, collider_label, collidable_label)

		self.count = self.count + 1

		local seperated, colliding, bump

		seperated = (collider.left > collidable.right)
			or (collider.right < collidable.left)
			or (collider.top > collidable.bottom)
			or (collider.bottom < collidable.top)

		if (not seperated) then

			local collision = {
				collider = collider,
				collidable = collidable,
				labels = {
					collider =  collider_label,
					collidable = collidable_label,
				},
			}

			return collision

		end

	end,

	clear = function(self)
		-- force lion colliders to be cleared on reset
		-- this should fix the collider cleanup issue
		local colliders = self.colliders
		colliders['lion'] = nil
		colliders['lion_head'] = nil
	end,
}