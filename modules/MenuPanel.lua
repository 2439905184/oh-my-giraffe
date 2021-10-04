-- manages a set of menu entries
MenuPanel = class{
	init = function(self, template)

		local entries = {}

		local title = template.title
		local speed = template.speed or 1
		local scaling = template.scaling or 1
		local middle = template.position

		-- todo add scaling

		-- use these values to set the alignment of the menu...
		local ox = template.ox or 0.5
		local oy = template.oy or 0
		local alignment = {x = ox, y = oy}

		local w = lg.getWidth()

		for i = 1, #template do

			local values = template[i]
			local args

			if values.multiple then
				args = {ox * w, values.multiple}
			else
				local label = values.label
				local switch = values.switch
				local action = values.action
				local toggle = values.toggle
				local symbol = values.symbol
				local icon = values.icon
				local color = values.color
				local sx = values.width or 1
				local sy = values.height or 1
				local size = values.size
				args = {ox * w, label, color, switch, action, toggle, icon, symbol, sx, sy, size}
			end

			local variant = values.type or MenuEntry
			local entry = variant(args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11])
			entries[#entries + 1] = entry

		end

		self.title = title
		self.speed = speed
		self.scaling = scaling
		self.middle = middle
		self.entries = entries
		self.alignment = alignment
		self.padding = 100 * window.interface
		self.gutter = 30 * window.interface
		self.offset = 0
		self.opacity = 255
		self.scale = 1

		self.transition = {
			active = false,
			callbacks = {},
			timer = 0,
			target = 0,
			enter = 0.3,
			exit = 0.3,
		}

	end,

	enter = function(self, callback)

		local transition = self.transition

		-- solve pop bug where a rapidly opened and closed menu will derail
		-- from the correct state and not appear for a cycle
		if (#transition.callbacks > 0) then
			if (transition.target == transition.enter + transition.exit) then
				transition.timer = 0
				local index = 1
				transition.callbacks[index]()
				table.remove(transition.callbacks, index)
			end
		end

		transition.target = transition.enter
		transition.active = true

		if callback then
			table.insert(transition.callbacks, callback)
		end

		-- tell our entries that we're live
		local entries = self.entries
		for _,entry in ipairs(entries) do
			entry.active = true
		end

	end,

	exit = function(self, callback)

		local transition = self.transition

		transition.target = transition.enter + transition.exit
		transition.active = true

		if callback then
			if (#transition.callbacks > 0) then
				local index = 1
				transition.callbacks[index]()
				table.remove(transition.callbacks, index)
			end
			table.insert(transition.callbacks, callback)
		end

		local entries = self.entries
		for _,entry in ipairs(entries) do
			entry.active = false
		end

	end,

	destroy = function(self)
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

		self:propogate('update', dt)

		local transition = self.transition
		if (transition.timer ~= transition.target) and (transition.active) then

			-- linearly transition timer to target
			local lower = transition.timer < transition.target
			local increase = math.min(transition.timer + dt, transition.target)
			local decrease = math.max(transition.timer - dt, transition.target)
			transition.timer = (lower) and (increase) or (decrease)

			-- finish this transition stage and pop and call any pending callbacks
			if (transition.timer == transition.target) then
				transition.active = false
				if (transition.target == transition.enter + transition.exit) then
					transition.timer = 0
					transition.target = 0
				end
				if (#transition.callbacks > 0) then
					local index = 1
					transition.callbacks[index]()
					table.remove(transition.callbacks, index)
				end
			end

		end

		local progress
		local opacity, offset, gutter, scale
		local entering = transition.timer <= transition.enter

		-- normalize progress to appropriate stage and ease transition values
		if entering then
			progress = transition.timer / transition.enter
			local inverse = math.abs(1 - progress)

			-- interpolate eased values
			opacity = 255 * easing.outCubic(progress, 0, 1, 1)

			offset = inverse
			offset = -easing.inQuad(offset, 0, 1, 1)
			offset = offset * 0.4

			gutter = inverse
			gutter = easing.inQuad(gutter, 0, 1, 1)
			gutter = 30 - 70 * gutter * window.interface

			scale = progress
			scale = easing.outCubic(scale, 0, 1, 1)
		else
			progress = (transition.timer - transition.enter) / transition.exit
			local inverse = math.abs(1 - progress)

			-- interpolate eased values
			opacity = 255 * inverse

			offset = progress
			offset = easing.inCubic(offset, 0, 1, 1)
			offset = offset * 0.3

			gutter = progress
			gutter = easing.inCubic(gutter, 0, 1, 1)
			gutter = 30 - 170 * gutter * window.interface

			scale = inverse
			scale = easing.outCubic(scale, 0, 1, 1)
		end

		self.opacity = opacity
		self.offset = offset
		self.gutter = gutter
		self.scale = scale

		self:retarget()
	end,

	draw = function(self, batch)
		self:propogate('draw', batch)
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
		local region = h - (padding * 2)
		local span = 0
		local position = {}

		-- test if the entry is inline, which case we want to shift it over instead?

		for i = 1, n do
			local entry = entries[i]
			local size = entry:getSize()
			position[i] = span + (size.h + gutter) * 0.5
			if entry.inline then
				-- skip forward until we figure out how far to budge it over?
			else
				span = span + size.h + gutter
			end
		end

		local push = offset * (span)
		local top = padding + (region / 2) - (span / 2)

		for i = 1, n do
			local entry = entries[i]
			local x = alignment.x * w
			local y = alignment.y * h + push + top + position[i]
			local delay = (i / n) - (i / n) * scale
			local s = scale - (scale * 0.2 * delay)
			entry:target(x, y, s, opacity)
		end

	end,

	-- call right before being popped from the stack
	clear = function(self)
		local entries = self.entries
		for i = 1, #entries do
			if entries[i].clear then
				entries[i]:clear()
			end
		end
	end,

	-- input handlers (passed on to active menu entries)
	mousepressed = function(self, x, y, button)
		self:propogate('inputpressed', button, x, y)
	end,

	mousereleased = function(self, x, y, button)
		self:propogate('inputreleased', button, x, y)
	end,

	touchpressed = function(self, id, x, y, pressure)
	end,

	touchreleased = function(self, id, x, y, pressure)
	end,

	keypressed = function(self, key, code)
		self:propogate('keypressed', key, code)
	end,

	keyreleased = function(self, key, code)
		self:propogate('keyreleased', key, code)
	end,
}