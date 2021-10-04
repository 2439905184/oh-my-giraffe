-- singleton that manages transitions between menu panels

MenuManager = class{
	init = function(self)

		-- build the menus from the template file
		local menus = {}
		local stack = {}
		local index = {}
		local queue = {}

		local template = templates.menus
		for key, entry in pairs(template) do
			-- this is the template list of panel entries
			local entries = template[key]
			-- create the panel object using the template
			local panel = MenuPanel(entries)
			-- add the panel object to the managers list
			menus[#menus + 1] = panel
			-- store the list position using its key
			index[key] = #menus
		end

		self.menus = menus
		self.stack = stack
		self.index = index
		self.queue = {}

		-- register hooks for changing menu state
		signals.register('switch', function(state) self:switch(state) end)
		signals.register('set', function(state) self:set(state) end)
		signals.register('pop', function(n) self:pop(n) end)
		signals.register('close', function() self:close() end)

	end,

	active = function(self)
		local stack = self.stack
		if (#stack > 0) then
			return stack[#stack]
		end
	end,

	update = function(self, dt)
		self:propogate('update', dt)
	end,

	draw = function(self)
		local batch = g.batch
		batch:bind()
		self:propogate('draw', batch)
		batch:unbind()
		lg.draw(batch)
		batch:clear()
	end,

	remove = function(self, state)
		local active = self:active()
		local index = self.index
		if active then
			table.remove(self.stack, active)
		end
	end,

	-- switch to the state arg, handling the transition
	switch = function(self, state)
		local stack, index, menus
		stack = self.stack
		index = self.index
		menus = self.menus

		if state then
			self:close()
			self:set(state)
		end

	end,

	set = function(self, state)
		local stack = self.stack
		local index = self.index
		local menus = self.menus
		if (state ~= 'close') then
			local title = index[state]
			menus[title]:enter()
			stack[#stack + 1] = state
		end
	end,

	pop = function(self, n)
		local stack = self.stack
		local menus = self.menus
		local index = self.index
		if stack[n] then
			menus[index[stack[n]]]:clear()
			table.remove(stack, n)
		end
	end,

	close = function(self)
		local stack, index, menus
		stack = self.stack
		index = self.index
		menus = self.menus
		local closing = stack[#stack]
		if closing then
			menus[index[closing]]:exit(function() signals.emit('pop', 1) end)
		end
	end,

	-- propogate a method to all menu panels in the active stack
	propogate = function(self, method, ...)
		local menus = self.menus
		local stack = self.stack
		local index = self.index
		for i,label in ipairs(stack) do
			local key = index[label]
			if not key then
				error('tried to switch to a menu that does not exist: ' .. label)
			end
			menus[key][method](menus[key], ...)
		end
	end,

	mousepressed = function(self, ...)
		self:propogate('mousepressed', ...)
	end,

	mousereleased = function(self, ...)
		self:propogate('mousereleased', ...)
	end,

	touchpressed = function(self, ...)
		self:propogate('touchpressed', ...)
	end,

	touchreleased = function(self, ...)
		self:propogate('touchreleased', ...)
	end,

	keypressed = function(self, ...)
		self:propogate('keypressed', ...)
	end,

	keyreleased = function(self, ...)
		self:propogate('keyreleased', ...)
	end,
}