-- debug outline
Outline = class{
	
	init = function(self, position, size, label, color)

		self.position = position
		self.size = size
		self.label = label

		if color then
			self.color = color
		else
			self.color = {255, 255, 255}
		end

		self.batched = true
		self.inactive = true

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