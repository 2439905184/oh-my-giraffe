GroupManager = class{
	
	init = function(self, objects)

		self.objects = objects
		self.groups = {}
		self.keys = {}

	end,

	build = function(self, group, chunk)

		local keys, variants, variant, template

		-- get the group templates
		variants = templates.groups[group]
		if variants then

			-- select a group template using a weighted choose
			variant = wchoose(variants)
			if variant then

				-- get the generation args for the group template
				template = variants[variant]

				-- if that worked out, call the template's method
				if template then
					keys = self[template.method](self, group, chunk, template)
				end

			end

		end

		return keys

	end,

	-- temporary destructive removal (but it is passed chunk.position and chunk.size)
	remove = function(self, chunk)

		local groups, keys, leftover, removed
		groups = self.groups
		keys = self.keys

		leftover = {}
		removed = {}

		-- if chunk has generated any objects outside of groups
		-- this will have them as well, so we need to remove only the ones groups is responsible for
		for j, key in ipairs(chunk.keys) do

			local metadata

			metadata = keys[key]
			if metadata then

				local span, depth, bound, viewport, alignment, contained

				span = groups[metadata.kind][key]
				depth = metadata.depth

				viewport = window.width
				alignment = math.max(viewport - (viewport / depth), 0)

				bound = self:project(depth, chunk)

				-- this works to resolve the removal bounds issues, but I'm almost 100% unsure why exactly
				if (depth > 1) then
					contained = (span.right < bound.right - alignment)
				else
					contained = (span.right < bound.right + alignment)
				end

				if contained then

					-- object is inside of bound, so remove it
					self.objects:remove(key)
					table.insert(removed, key)

				else

					-- if the object is not entirely inside of the bound then defer its removal
					table.insert(leftover, key)

				end

			else

				-- if the object isn't registered in groups, just delete it since it's what the chunk manager would do
				self.objects:remove(key)

			end

		end

		-- release any removed keys that were registered
		self:release(removed)

		-- return the keys that are still in the bounds of loaded chunks
		return leftover

	end,

	-- see if an object is allowed to spawn at a given location
	bid = function(self, kind, position, size)

		local groups, group, bound, neighbors, eligible

		groups = self.groups
		group = groups[kind]

		eligible = true

		bound = {
			left = position.x,
			right = position.x + size.w,
			top = position.y,
			bottom = position.y + size.h,
		}

		if group then
			for i, neighbor in pairs(group) do

				-- set eligible to false if bid intersects with existing neighbor
				eligible = (bound.left >= neighbor.right) or (bound.right <= neighbor.left)

				-- stop traversing neighbors if bid fails
				if not eligible then
					break
				end		

			end
		end

		return eligible

	end,

	-- shears a bound based on existing group entries
	shear = function(self, kind, bound)

		local groups, group, sheared
		groups = self.groups
		group = groups[kind]

		sheared = bound

		if group then
			for i, neighbor in pairs(group) do
				if (neighbor.right > sheared.left) then
					sheared.left = neighbor.right
				end
			end
		end

		-- check self.groups[group] for any entries inside of bound
		-- and shear the bound accordingly
		return bound

	end,

	loop = function(self, group, chunk, template)

		local populated, bound, step, keys, attempts

		-- this will store the keys this generates
		keys = {}

		-- project chunk bound based on depth and shear from existing group entries
		bound = self:shear(group, self:project(template.depth, chunk))

		-- start the generation at the bound left
		step = bound.left
		attempts = 0

		while not populated do

			local object, attr, size, w, h, name, buffer, position, key, available

			-- choose the object asset or event
			object, size, name, event = self:choose(template.asset, template.event)

			-- position the asset according to the bound bottom
			position = {
				x = step,
				y = bound.bottom - (size.h + template.bottom),
				z = template.depth,
			}

			buffer = template.buffer

			-- todo
			-- make sure that bid is only called if the position and size is inside of the bound...

			-- check to see if this position is already occupied
			available = self:bid(group, position, size) and (position.x <= bound.right)

			if available then

				-- spawn the object
				key = self:spawn(object, position, size, name, group, buffer, event)

				-- add the key to the batch for ChunkManager
				table.insert(keys, key)

				-- increment the position step by the width of the asset and buffer if there is one
				local buffer = (template.buffer) or 0
				step = (step + size.w) + (size.w * buffer / 2)

				-- stop generating assets if we leave the spawning bound
				if (step >= bound.right) then

					populated = true
					break

				end

			else

				attempts = attempts + 1

			end

			-- break spawning if we exceed a tolerance #
			if (attempts > 50) then

				--print('exceeded attempts while populating group')
				populated = true
				break

			end

		end

		return keys

	end,

	distribute = function(self, group, chunk, template)

		local populated, bound, keys, occupied, attempts

		-- this will store the keys this generates
		keys = {}

		occupied = {}
		attempts = 0

		-- project chunk bound based on depth and shear from existing group entries
		bound = self:shear(group, self:project(template.depth, chunk))

		while not populated do

			local object, attr, size, w, h, name, position, buffer, key, available, fertile

			-- choose the object
			object, size, name, event = self:choose(template.asset, template.event)

			-- position the asset according to the bound bottom
			position = {
				x = bound.left + (bound.right - bound.left) * math.random(),
				y = bound.bottom - (size.h + template.bottom),
				z = template.depth,
			}

			buffer = template.buffer

			fertile = true
			for i, zone in ipairs(occupied) do

				local left, right
				
				left = position.x + size.w < zone.position.x
				right = position.x > zone.position.x + zone.size.w

				if not (left and right) then
					fertile = false
				end

			end

			-- check to see if this position is already occupied
			available = self:bid(group, position, size) and (position.x <= bound.right) and fertile

			if available then

				-- roll for initiative!
				local spawn, roll

				roll = math.random()
				spawn = roll < template.density
	
				if spawn then

					-- spawn and register the object
					key = self:spawn(object, position, size, name, group, buffer, event)

					-- add the key to the batch for ChunkManager
					table.insert(keys, key)

					-- reset the attempts count so that all spawn have an equal chance
					attempts = 0

					-- check if the template has a maximum amount
					if template.max then

						-- stop spawning if enough objects have been generated
						if (#keys >= template.max) then

							populated = true
							break

						end

					end

				else

					table.insert(occupied, {position = position, size = size})

				end

				-- else
				-- add to occupied if fails

			else
				attempts = attempts + 1
			end

			if (attempts > 50) then
				populated = true
				break
			end

		end

		-- add a dummy marker so that nothing is spawned inside of this bound next time
		-- this is a bit of a hack, but it works!
		local key, dummy

		dummy = {
			position = {
				x = bound.right,
				y = bound.top,
				z = template.depth,
			},
			size = {
				w = 0,
				h = 0,
			}
		}

		key = self.objects:add(Dummy(dummy.position))
		table.insert(keys, key)

		-- register the dummy so that it actually offsets the next addition to this group
		self:register(group, key, dummy.position, dummy.size)

		return keys

	end,

	-- if no max is specified this will unfortunately attempt to spawn until the loop
	-- breaks from too many attempts
	absolute = function(self, group, chunk, template)

		local populated, bound, keys, occupied, attempts

		-- this will store the keys this generates
		keys = {}

		occupied = {}
		attempts = 0

		-- project chunk bound based on depth and shear from existing group entries
		bound = self:shear(group, self:project(template.depth, chunk))

		while not populated do

			local object, attr, size, w, h, name, position, buffer, key, available, fertile

			-- choose the object asset or event
			object, size, name, event = self:choose(template.asset, template.event)

			-- position the asset according to the bound bottom
			position = {
				x = bound.left + (bound.right - bound.left) * template.position,
				y = bound.bottom - (size.h + template.bottom),
				z = template.depth,
			}

			buffer = template.buffer

			fertile = true
			for i, zone in ipairs(occupied) do

				local left, right
				
				left = position.x + size.w < zone.position.x
				right = position.x > zone.position.x + zone.size.w

				if not (left and right) then
					fertile = false
				end

			end

			-- check to see if this position is already occupied
			available = self:bid(group, position, size) and (position.x <= bound.right) and fertile

			if available then

				-- roll for initiative!
				local spawn, roll

				roll = math.random()
				spawn = roll < template.density
	
				if spawn then

					-- spawn and register the object
					key = self:spawn(object, position, size, name, group, buffer, event)

					-- add the key to the batch for ChunkManager
					table.insert(keys, key)

					-- reset the attempts count so that all spawn have an equal chance
					attempts = 0

					-- check if the template has a maximum amount
					if template.max then

						-- stop spawning if enough objects have been generated
						if (#keys >= template.max) then

							populated = true
							break

						end

					end

				else

					table.insert(occupied, {position = position, size = size})

				end
			else
				attempts = attempts + 1
			end

			if (attempts > 50) then

				populated = true
				break

			end

		end

		-- add a dummy marker so that nothing is spawned inside of this bound next time
		-- this is a bit of a hack, but it works!
		local key, dummy

		dummy = {
			position = {
				x = bound.right,
				y = bound.top,
				z = template.depth,
			},
			size = {
				w = 0,
				h = 0,
			}
		}

		key = self.objects:add(Dummy(dummy.position))
		table.insert(keys, key)

		-- register the dummy so that it actually offsets the next addition to this group
		self:register(group, key, dummy.position, dummy.size)

		return keys

	end,

	-- register an object in self.groups with it's group kind, object key, and occupying bound
	-- create a new entry for self.groups if it does not already exist
	register = function(self, kind, key, position, size)

		local groups, group, keys, bound
		groups = self.groups
		group = groups[kind]

		-- if there isn't a table for this group kind yet, create one
		if not group then
			groups[kind] = {}
		end

		-- proceed with registering the bound with the object key
		bound = {
			left = position.x,
			right = position.x + size.w,
			top = position.y,
			bottom = position.y + size.h,
		}

		-- save the object bound by its group kind and key
		groups[kind][key] = bound


		if key then

			-- save the object group kind by its key (for easy releasing)
			keys = self.keys

			--keys[key] = kind
			keys[key] = {
				kind = kind,
				depth = position.z,
			}

		end

	end,

	release = function(self, batch)

		local groups, keys
		keys = self.keys
		groups = self.groups

		for i, key in ipairs(batch) do

			local kind

			-- retrieve the group kind by key
			kind = keys[key].kind

			-- remove the registered entries for both groups and keys for the key
			groups[kind][key] = nil
			keys[key] = nil

		end

	end,

	-- spawns an object and registers it
	spawn = function(self, asset, position, size, name, group, buffer, event)

		local prop, drawable, key, active, total

		active, total = self.objects:count()
		proposed = self.objects:pop()

		-- bind the position to the asset using a prop
		prop = Prop(proposed, asset, position, name, event)

		-- add the drawable to objects and store the key
		key = self.objects:add(prop)

		if key ~= proposed then
			error('key mismatch while spawning terrain prop: ' .. key .. ', ' .. proposed)
		end

		-- if spawned with a buffer, compensate position and size
		if buffer then

			local adjusted

			adjusted = {
				position = {
					x = position.x - (size.w * buffer / 2),
					y = position.y,
					z = position.z,
				},
				size = {
					w = size.w + (size.w * buffer),
					h = size.h,
				},
			}

			-- changing these isn't very good form
			position = adjusted.position
			size = adjusted.size

		end

		self:register(group, key, position, size)

		return key

	end,

	-- convert the chunk bounds to the groups depth level
	project = function(self, depth, chunk)

		local ratio, viewport, range, alignment

		ratio = (1 / depth)
		viewport = window.width
		alignment = math.max(viewport - (viewport * ratio), 0)

		bound = {
			left = (chunk.position.x) * ratio,
			right = (chunk.position.x + chunk.size.w) * ratio + alignment,
			top = (chunk.position.y),
			bottom = (chunk.position.y + chunk.size.h),
		}

		return bound

	end,

	choose = function(self, asset, event)

		local object, size, name, properties, chosen

		if asset then
			object = Graphic(asset)
			if object then

				-- this get is distinct from a Drawable:get()
				properties = object:get()
				size = {
					w = properties.size.w * options.terrain_scale,
					h = properties.size.h * options.terrain_scale,
				}
				name = properties.name

			end
		end

		return object, size, name, event

	end,

}