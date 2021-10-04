-- a clickable menu entry with a callback
-- has a 'down' state
MenuPill = class{
	init = function(self, middle, parts)

		local scaling = window.interface
		self.scaling = scaling

		local position = {
			x = middle,
			y = 0,
		}

		local entries = {}

		for i = 1, #parts do
			local values = parts[i]
			local label = values.label
			local switch = values.switch
			local action = values.action
			local toggle = values.toggle
			local symbol = values.symbol
			local icon = values.icon
			local color = values.color
			local sx = values.width or 1
			local sy = values.height or 1
			local variant = values.type or MenuEntry
			local entry = variant(middle, label, color, switch, action, toggle, icon, symbol, sx, sy)
			entries[#entries + 1] = entry
		end

		local size = {
			w = 300,
			h = entries[1].size.h + 20 * window.interface,
		}

		self.padding = 100 * window.interface
		self.gutter = 30 * window.interface
		self.offset = 0

		local alignment = {x = 0, y = 0.5}

		self.position = position
		self.size = size
		self.scale = 0
		self.input = {}
		self.entries = entries
		self.alignment = alignment

	end,

	propogate = function(self, method, ...)
		local entries = self.entries
		for i = 1, #entries do
			if entries[i][method] then
				entries[i][method](entries[i], ...)
			end
		end
	end,

	update = function(self, dt)

		local input = self.input
		self:propogate('update', dt)

	end,

	draw = function(self, batch)
		self:propogate('draw', batch)
	end,

	-- returns true if (x, y) is inside of the menu entry
	check = function(self, ix, iy)

	end,

	getSize = function(self)
		return self.size
	end,

	inputpressed = function(self, ...)
		self:propogate('inputpressed', ...)
	end,

	inputreleased = function(self, ...)
		self:propogate('inputreleased', ...)
	end,

	keypressed = function(self, key, code)
	end,

	keyreleased = function(self, key, code)
	end,

	target = function(self, x, y, scale, opacity)
		self.position.x = x
		self.position.y = y
		self.scale = scale
		self.opacity = math.min(opacity, 255)
		self:retarget()
	end,

	retarget = function(self)

		local entries = self.entries
		local padding = self.padding
		local gutter = self.gutter
		local offset = self.offset
		local scale = self.scale
		local opacity = self.opacity
		local middle = self.middle

		local alignment = self.alignment

		local h = lg.getHeight()
		local w = lg.getWidth()

		local n = #entries
		local region = w - (padding * 2)
		local span = 0
		local position = {}

		for i = 1, n do
			local entry = entries[i]
			local size = entry:getSize()
			position[i] = span + (size.w + gutter) * 0.5
			span = span + size.w + gutter
		end

		local push = offset * (span)
		local top = padding + (region / 2) - (span / 2)

		for i = 1, n do
			local entry = entries[i]
			local x = alignment.x * w + push + top + position[i]
			local y = self.position.y
			local delay = (i / n) - (i / n) * scale
			local s = scale - (scale * 0.2 * delay)
			entry:target(x, y, s, opacity)
		end

	end,

	origin = function(self, x)
		self.position.x = x
	end,
}