Ground = class{
	
	init = function(self, floor)
		self.position = {x = 0, y = floor, z = 1}
		self.size = {w = math.huge, h = math.huge}
		self.offset = {x = 0, y = 0}
		self.label = 'ground'
		self.inactive = true
		self.static = true
	end,

	register = function(self, key)
		self.key = key
		observer:emit('collider', key)
	end,

	set = function(self, dx, dy)
		self.position.x = dx
		self.position.y = dy
	end,

	move = function(self, dx, dy)
		self.position.x = self.position.x + dx
		self.position.y = self.position.y + dy
	end,

	get = function(self)
		local properties = {
			position = self.position,
			size = self.size,
		}
		return properties
	end,

}