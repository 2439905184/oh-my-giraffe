-- a clickable menu entry with a callback
-- has a 'down' state
MenuEntry = class{
	init = function(self, middle, label, color, switch, action, toggle, icon, symbol, sx, sy)


		local scaling = window.interface
		self.scaling = scaling

		local position = {
			x = middle,
			y = 0,
		}

		local size = {
			w = 300 * sx * scaling,
			h = 100 * sy * scaling,
		}

		local font = (sx > 1) and (fonts:add('bpreplay-bold.otf', 62, window.interface)) or (fonts:add('bpreplay-bold.otf', 44, window.interface))

		self.label = MenuLabel(label, font, icon, symbol)
		self.buffer = 70 * scaling
		size.w = math.max(size.w, self.label:getWidth() + self.buffer)
		self.color = color or {255, 255, 255}
		self.position = position
		self.size = size
		self.scale = 0
		self.switch = switch
		self.action = action
		self.toggle = toggle
		self.source = function()
				local x, y = lm.getPosition()
			    local w, h = lg.getWidth(), lg.getHeight()
			    if window.flipped then
    				x = math.abs(x - w)
    				y = math.abs(y - h)
    			end
    			return x, y
    		end

		self.input = {}
		self.graphic = Graphic('pixel')

	end,

	update = function(self, dt)

		local input = self.input

		local state
		for id,mode in pairs(input) do

			-- for touches, I'll want to get the x, y in here
			-- I need to use the mode to determine what to use for this...
			local x, y = self.source()
			local hit = self:check(x, y)
			if hit then
				state = 'down'
			end
		end

		if self.state == 'down' and state ~= self.state then
			sound:emit('click')
		end

		if state == 'down' and state ~= self.state then
			sound:emit('click', {pitch = {0.6, 0.8}})
		end

		self.state = state

	end,

	draw = function(self, batch)

		local state = self.state
		local down = (state == 'down')

		local mode = (down) and ('fill') or ('fill')

		local position = self.position
		local x = position.x
		local y = position.y

		local scale = self.scale
		local opacity = self.opacity

		-- compute text size
		local size = self.size
		local w = size.w * scale
		local h = size.h * scale
		local ox = 0

		local height = 7 * window.interface
		local inset = (height*0.5) * scale
		local depress = (height*0.5) * scale
		local depth = height * scale

		local oy = (down) and (depress) or (0)
		local extrude = (state == 'down') and (depth - depress) or (depth)

		local r = self.color[1]
		local g = self.color[2]
		local b = self.color[3]

		local color = (down) and {r-40*r/255, g-30*g/255, b-25*b/255, opacity} or {r, g, b, opacity}
		local color_shadow = (down) and {r-173, g-113, b-104, opacity} or {r-163, g-103, b-94, opacity}
		local color_shadow_darker = (down) and {r-193, g-133, b-124, opacity} or {r-183, g-123, b-114, opacity}

		local nx = x - (w/2) + ox
		local ny = y - (h/2) + oy

		local graphic = self.graphic

		batch:setColor(color_shadow)
		graphic:add(batch, nx + inset, ny + extrude, 0, w - inset*2, h)
		graphic:add(batch, nx, ny + inset + extrude, 0, w, h - inset*2)

		batch:setColor(color)
		graphic:add(batch, nx + inset, ny, 0, w - inset*2, h)
		graphic:add(batch, nx, ny + inset, 0, w, h - inset*2)

		batch:unbind()
		lg.draw(batch)
		batch:clear()
		batch:bind()

		-- entry label
		local color_text = (state == 'down') and {70, 70, 70, opacity} or {100, 100, 100, opacity}
		self.label:setColor(color_text)
		self.label:draw(x + ox, y + oy, scale)

	end,

	-- returns true if (x, y) is inside of the menu entry
	check = function(self, ix, iy)

		local size = self.size
		local position = self.position
		local w = size.w
		local h = size.h
		local x = position.x - (w / 2)
		local y = position.y - (h / 2)

		local missed = (ix > x + w) or (ix < x) or (iy > y + h) or (iy < y)
		return not missed

	end,

	getSize = function(self)
		return self.size
	end,

	inputpressed = function(self, id, x, y, mode)
		local input = self.input
		local hit = self:check(x, y)
		if hit then
			input[id] = 'down'
		end
	end,

	inputreleased = function(self, id, x, y, mode)
		local input = self.input
		local hit = self:check(x, y)
		if hit and input[id] then

			-- switch to the designated menu
			-- examples of not needing a switch would be:
			-- volume toggle
			-- rotation toggle

			-- emit an action if the entry has one
			local action = self.action
			if action then
				signals.emit(action)
			end

			local toggle = self.toggle
			if toggle then
				toggle = not toggle
			end

			local label = self.label
			if label then
				-- problem code
				label:toggle()
			end

			local switch = self.switch
			if switch then
				--print('menu item triggered switch to ' .. switch)
				signals.emit('switch', switch)
			end

		end

		-- remove the input reference
		input[id] = nil
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
	end,

	origin = function(self, x)
		self.position.x = x
	end,
}

MenuLabel = class{
	init = function(self, label, font, icons, symbol)
		self.label = label
		self.font = font
		self.icon = icons and MenuIcon(icons)
		self.symbol = symbol and MenuSymbol(symbol)

	end,

	update = function(self, dt)
	end,

	draw = function(self, x, y, scale)
		local w, h
		w = self:getWidth()
		h = self:getHeight()

		local span = w

		local icon = self.icon
		if icon then
			
			local iw, ih
			iw = icon:getWidth()
			ih = icon:getHeight()

			local padding = 15
			span = span + iw + padding

			local ix, iy
			ix = x + (iw/2) - span/2
			iy = y + (ih/2)

			--lg.setColor(255, 255, 255)
			icon:draw(ix, iy, 0, scale, scale, iw/2, ih)

			--lx = lx + (iw/2) + padding

		end

		lg.setColor(self.color)

		local symbol = self.symbol
		if symbol then

			local iw, ih
			iw = symbol:getWidth()
			ih = symbol:getHeight()

			local padding = 10
			span = span + (iw/2) + padding

			local ix, iy
			-- do I want this on the other side?
			ix = x - (iw) + (span/2) + (padding/2)
			iy = y + 6

			--lg.setColor(255, 255, 255)
			symbol:draw(ix, iy, 0, scale, scale, iw/2, ih/2)

			--lx = lx - (iw) - padding/2
			lx = lx

		end

		local lx, ly
		lx = x + (w/2) - (span/2)
		ly = y

		lg.setColor(self.color)
		local font = self.font
		font:draw(self.label, lx, ly, 0, scale, scale, w/2, h/2)
	end,

	getWidth = function(self)
		local w = self.font:getWidth(self.label)
		local icon = self.icon
		w = (icon) and (w + icon:getWidth()) or w
		local symbol = self.symbol
		w = (symbol) and (w + symbol:getWidth()) or w
		return w
	end,

	getHeight = function(self)
		return self.font:getHeight(self.label)
	end,

	setColor = function(self, color)
		self.color = color
	end,

	toggle = function(self)
		local icon = self.icon
		if icon then
			icon:toggle()
		end
		local symbol = self.symbol
		if symbol then
			symbol:toggle()
		end
	end,
}

MenuIcon = class{
	init = function(self, icons)
		self.icons = {}
		for label,icon in pairs(icons) do
			self.icons[label] = Graphic(icon)
		end
		self.state = 'default'
	end,

	update = function(self, dt)
		self.icons[self.state]:update(dt)
	end,

	draw = function(self, ...)
		self.icons[self.state]:draw(...)
		lg.setFont(symbols)
		--local symbol = string.utf8unicode('&#xf13e;')
		--lg.setColor(100, 100, 100)
		--lg.print('      ', ...)
	end,

	cycle = function(self)
		-- go between the icons...

	end,

	toggle = function(self)
		local state = self.state
		local last
		for label,icon in pairs(self.icons) do
			last = (label ~= state) and (label) or (last)
			if last then break end
		end
		if last then
			self.state = last
		end
	end,

	setState = function(self, state)
		self.state = self.icons[state] and state or self.state
	end,

	getWidth = function(self)
		return self.icons[self.state]:getWidth()
	end,

	getHeight = function(self)
		return self.icons[self.state]:getHeight()
	end,
}

MenuSymbol = class{
	init = function(self, states)
		self.stack = {}
		for key,state in pairs(states) do
			self.stack[key] = state
		end
		self.state = 'default'
		self.font = fonts:add('fontawesome.otf', 43, window.interface)
	end,

	update = function(self, dt)
		self.stack[self.state]:update(dt)
	end,

	draw = function(self, ...)
		local font = self.font
		font:draw(self.stack[self.state], ...)
	end,

	toggle = function(self)
		local state = self.state
		local last
		for label,icon in pairs(self.stack) do
			last = (label ~= state) and (label) or (last)
			if last then break end
		end
		self.state = last and last or state
	end,

	getWidth = function(self)
		local font = self.font
		return font:getWidth(self.stack['default'])
	end,

	getHeight = function(self)
		local font = self.font
		return font:getHeight(self.stack['default'])
	end,
}