-- debug outline
Region = class{
	
	init = function(self, position, size, offset, label, color)

		self.position = position
		self.size = size
		self.offset = offset
		self.label = label

	end,

	set = function(self, dx, dy)

		self.position.x = dx
		self.position.y = dy

	end,

	move = function(self, dx, dy)
		self.position.x = self.position.x + dx
		self.position.y = self.position.y + dy
	end,

	update = function(self, dt)

	end,

	get = function(self)

		local properties = {
			position = self.position,
			size = self.size,
		}

		return properties

	end,

}