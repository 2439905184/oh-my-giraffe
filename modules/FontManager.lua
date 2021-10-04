local set = love.graphics.setFont

FontManager = class{
	init = function(self, directory)
		self.directory = directory or 'assets/fonts/'
		self.fonts = {}
		self.scaling = window.interface
	end,

	add = function(self, name, size, scaling)

		-- load a font
		local fonts = self.fonts
		local directory = self.directory
		local path = directory .. name

		local name = name or 'bpreplay-bold.otf'
		local scaling = scaling or 1
		local size = size and size * scaling or 0
		local filter = 'linear'

		local font = fonts[name] or Font(self, name, path, filter)
		fonts[name] = font

		local instance = font:load(size)

		return instance

	end,

	draw = function(self, name, size, string, ...)
		local scaling = self.scaling
		local size = size * scaling
		local instance = self:add(name, size)
		instance:draw(string, ...)
	end,

	batch = function(self, pool)
		for _,args in ipairs(pool) do
			local name, size, scaling = unpack(args)
			self:add(name, size, scaling)
			--print('batch loaded ' .. name .. ' at ' .. size)
		end
	end,
}

Font = class{

	init = function(self, manager, name, path, filter)

		-- load a font
		self.manager = manager
		self.name = name
		self.path = path
		self.filter = filter
		self.stack = {}
		self.instances = {}

		--print('Created a new font container: ' .. name)

	end,

	draw = function(self, size, string, ...)
		self:setFont(size)
		lg.print(string, ...)
	end,

	getWidth = function(self, size, string)
		local font = self:getFont(size)
		return font:getWidth(string)
	end,

	getHeight = function(self, size, string)
		local font = self:getFont(size)
		return font:getHeight(string)
	end,

	getSize = function(self, size, string)
		local font = self:getFont(size)
		return font:getSize(string)
	end,

	getFont = function(self, size)
		local stack = self.stack
		local font = stack[size]
		return font
	end,

	setFont = function(self, size)
		local font = self:getFont(size)
		lg.setFont(font)
	end,

	load = function(self, size)

		local stack = self.stack
		if not stack[size] then

			local path = self.path
			local font = lg.newFont(path, size)

			-- set scaling filter
			local filter = self.filter
			font:setFilter(filter, filter)

			-- add this size to the stack
			stack[size] = font

			-- hack to force iOS to load all the characters into memory
			local numbers = '0123456789'
			local lowercase = 'abcdefghijklmnopqrstuvwxyz'
			local symbols = '+!.,() '
			local chars = ("%s%s%s"):format(numbers, lowercase, symbols)
			local _, _ = self:getWidth(size, chars), self:getHeight(size, chars)

			--print('Created a new font data: ' .. self.name .. ', ' .. size)

		end

		-- create a new instance if one doesn't already exist
		local instances = self.instances
		local instance = instances[size] or FontInstance(self, size)
		instances[size] = instance
		
		-- return the instance to the caller, who can now use it to print
		return instance

	end,
}

FontInstance = class{
	init = function(self, font, size)

		self.font = font
		self.size = size
		self.cache = {
			width = {
				count = 0,
				cap = 128,
				pool = {},
				method = 'getWidth',
			},
			height = {
				count = 0,
				cap = 128,
				pool = {},
				method = 'getHeight'
			},
		}

		--print('Created a new font instance: ' .. self.font.name .. ', ' .. size)

	end,

	draw = function(self, string, ...)
		local size = self.size
		self.font:draw(size, string, ...)
	end,

	set = function(self)
		local size = self.size
		self.font:set(size)
	end,

	getWidth = function(self, string)
		return self:getDimension('width', string)
	end,

	getHeight = function(self, string)
		return self:getDimension('height', string)
	end,

	getSize = function(self, string)
		return self:getDimension('width', string), self:getDimension('height', string)
	end,

	getDimension = function(self, dimension, string)

		local string = tostring(string)
		local cache = self.cache[dimension]

		-- if the cache misses, compute the dimension and store it
		if not cache.pool[string] then

			local font = self.font
			local size = self.size

			-- add the computed dimension to the appropriate cache
			--cache.pool[string] = font[cache.method](font, size, string)
			cache.pool[string] = font[cache.method](font, size, string)
			cache.count = cache.count + 1

			-- if cache hits its limit, remove anything but the one we just added
			if cache.count > cache.cap then
				for key,val in pairs(cache.pool) do
					if key ~= string then
						cache.pool[key] = nil
						cache.count = cache.count - 1
						break
					end
				end
			end

		end

		local dimension = cache.pool[string]

		return dimension
	end,

}