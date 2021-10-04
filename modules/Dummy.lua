-- dummy object used as a hack for resolving offset issues during terrain generation
Dummy = class{
	
	init = function(self, position)

		self.position = position
		self.label = 'spacer'
		self.size = {
			w = 0,
			h = 0,
		}
		self.static = true
		self.inactive = true

	end,

	get = function(self)

		local properties = {
			position = self.position,
			size = self.size,
		}

		return properties

	end,
}
