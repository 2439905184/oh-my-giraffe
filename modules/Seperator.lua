Seperator = class{
	init = function(self)
		-- this is wildly hacky but it can be used to seperate sections in the batching
		self.position = {x = 0, y = 0, z = 1.0000001}
		self.size = {w = 0, h = 0}
		self.label = 'seperator'
	end,

	update = function(self)
		self.position.x = viewport.x
		self.position.y = viewport.y
	end,

	draw = function(self)
	end,
}