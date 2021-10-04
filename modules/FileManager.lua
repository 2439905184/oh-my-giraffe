FileManager = class{

	init = function(self, path)

		local path = path or 'generic'
		self.path = path
		
		local exists = lf.exists(path)
		if exists then
			local data = lf.read(path)
			self.data = data
		end
	end,

	commit = function(self, data)
		--print('saving: ' .. data)
		local data = data or ""
		local path = self.path
		local attempts = 3
		local finished, success
		while not finished do
			local file = lf.newFile(path)
			file:open('w')
			success = file:write(data)
			file:close()
			if success then
				finished = true
				self.data = data
				break
			else
				attempts = attempts - 1
			end
			if attempts <= 0 then
				finished = true
				break
			end
		end

		return success
		
	end,

	get = function(self)
		return self.data
	end,

	delete = function(self)
		self:commit()
	end,

}