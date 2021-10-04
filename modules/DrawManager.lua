DrawManager = class{
	
	init = function(self, manager)

		self.manager = manager
		self.screenspace = {window.center.x, window.center.y}
		self.queue = {}

		self.batch = g.batch

		self.flag = false

		g["renderer"] = self

	end,

	update = function(self)

		local manager = self.manager
		local screenspace = self.screenspace
		local keys, objects = manager:get()
		local queue = self.queue
		local length = #queue

		-- update the draw queue with any visible objects
		local index = 1
		for i = 1, #keys do
			local object = objects[keys[i]]
			if (type(object) ~= 'number') and (not object.asset.inactive) then
				local visible = object:projection(screenspace)
				if visible and object.draw then
					queue[index] = keys[i]
					index = index + 1
				end
			end
		end

		-- remove the extras if the previous draw queue was longer
		if index < length then
			for i = index, length do
				queue[i] = nil
			end
		end

		self.queue = queue

	end,

	draw = function(self, x, y)

		local draw = lg.draw

		-- draw scene
		local manager = self.manager
		local _, objects = manager:get()
		local queue = self.queue
		local batch = self.batch
		batch:bind()

		local count = 0
		local n = -1
		
		for i = 1, #queue do
			local object = objects[queue[i]]
			if (type(object) ~= 'number') then
				local batched = object.asset.batched
				
				-- interrupt the batch to preserve correct depth ordering
				if not batched then
					batch:unbind()
					if count ~= n then
						draw(batch)
					end
					batch:clear()
					count = count + 1
				end

				object:draw(batch)

				-- rebind the batch for faster updating
				if not batched then
					batch:bind()
				end
			end
		end

		-- finishing drawing all batched items before clearing
		batch:unbind()
		draw(batch)
		batch:clear()

	end,

	set = function(self, x, y)
		local screenspace = self.screenspace
		screenspace[1] = x and x - window.center.x or screenspace[1]
		screenspace[2] = y and y - window.center.y or screenspace[2]
	end,

}