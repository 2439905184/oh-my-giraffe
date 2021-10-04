Leaderboard = class{
	init = function(self)
		self.cutoff = 5
		self.history = 50
		self.sessions = {}
		self.clipboard = {}
		self:load()
	end,

	bid = function(self, session)

		local entries = self.entries
		local cutoff = self.cutoff
		local history = self.history
		local placed
		local displacing = 0
		if #entries > 0 then
			for index,entry in ipairs(entries) do
				if entry.score < session.score and index <= cutoff then
					placed = index
					displacing = entry.score
					break
				end
			end
			-- still populating our leaderboards for the first time
			if (not placed) and  (#entries < cutoff) then
				placed = #entries + 1
			end
		else
			placed = 1
		end

		-- currently, sessions are not saved beyond the history
		-- however this will be able to give us the last one
		local sessions = self.sessions
		table.insert(sessions, session)

		-- todo: don't send analytics for this until we've bid a session that isn't in the clipboard
		local clipboard = self.clipboard
		if #clipboard > 0 then
			local repopulating
			for _,entry in ipairs(clipboard) do
				if entry == session then
					repopulating = true
					break
				end
			end
			if not repopulating then
				-- now we actually forget what those sessions were...
				local event = {
					type = "reset",
					report = clipboard,
				}
				analytics:report(event)
				self.clipboard = {}
			end
		end

		if placed then
			table.insert(entries, placed, session)
			if #entries > history then
				table.remove(entries, history)
			end
			self:broadcast()
			self:save()
			return true, displacing, placed
		end

	end,

	best = function(self)
		local query = self:get(1)
		if #query > 0 then
			local session = query[1]
			local score = session.score
			return score
		end
		return 0
	end,

	previous = function(self)
		local sessions = self.sessions or {}
		local session = sessions[#sessions]
		return session
	end,

	get = function(self, n)
		local request = {}
		local entries = self.entries
		for i = 1, n do
			table.insert(request, entries[i])
		end
		return request
	end,

	load = function(self)
		local file = FileManager('leaderboard')
		self.file = file
		local serialized = file:get()
		local entries = serialized and tserial.unpack(serialized) or {}
		self.entries = entries
		self:broadcast()
	end,

	save = function(self)
		local file = self.file
		local entries = self.entries
		local serialized = tserial.pack(entries)
		file:commit(serialized)

	end,

	restore = function(self)
		-- send this to analytics
		local entries = self.entries

		local clipboard = self.clipboard
		for _,session in ipairs(clipboard) do
			self:bid(session)
		end
		self.clipboard = {}
	end,

	reset = function(self)
		-- send this to analytics
		local entries = self.entries
		self.clipboard = entries

		local entries = {}
		self.entries = entries
		self:save()
		self:broadcast()
	end,

	migrate = function(self)
		local path = "omg.dat"
		local legacy = lf.exists(path)
		if legacy then
			local score = lf.read(path)
			local session = {
				score = score,
			}
			self:bid(session)
			lf.remove(path)
		end
	end,

	broadcast = function(self)
		local cutoff = self.cutoff
		local abbriviated = self:get(cutoff)
		signals.emit('leaderboard', abbriviated)
	end,
}