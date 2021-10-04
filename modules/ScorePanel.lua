ScorePanel = class{
	init = function(self)

		self.scaling = window.interface

		self.points = 0
		self.value = 0
		self.string = ''
		self.elapsed = 0
		self.symbol = symbol
		self.color = {255, 255, 255, 0}
		self.position = {x = 0, y = 0}
		self.size = {w = 0, h = 0}

		local padding = 30 * window.interface
		local sections = {
			list = {},
			w = 0,
			h = 0,
			padding = padding,
		}

		local sf = function() return comma_value(math.ceil(self.value)) end
		local score = ScorePanelSection(sf, nil, Graphic('edible', 1), 5)
		score.type = 'score'

		local cf = function() return comma_value(math.ceil(metrics:get('combo'))) end
		local combo = ScorePanelSection(cf, nil, Graphic('orb'), 5, true)
		combo.type = 'combo'

		sections.list[#sections.list + 1] = combo
		sections.list[#sections.list + 1] = score

		for i,section in ipairs(sections.list) do
			local w = section:getWidth()
			sections.w = sections.w + w
			if i ~= #sections.list then
				sections.w = sections.w + sections.padding
			end
			local h = section:getHeight()
			sections.h = math.max(sections.h, h)
		end

		self.sections = sections
		self.padding = padding
		self.offset = 0

		self.warning = 0
		self.duration = 2
		self.entry = 0.8
		self.exit = 0.8
		self.active = false

		observer:register('warn', function(duration) self:warn(duration) combo:rumble(duration) end)
		observer:register('dismiss', function() self:dismiss() end)
		observer:register('rumble', function(duration) combo:rumble(duration) end)

	end,

	update = function(self, dt)

		-- TODO!!
		-- this causes all of the performance problems

		-- ease to output to points
		local score = metrics:get('score')
		if options.safemode then
			self.value = score
		else
			self.value = self.value + (score - self.value) * dt * 15
		end

		local transition = self.transition or (0)

		local padding = 30 * window.interface
		local x = lg.getWidth()*0.5
		local y = padding * transition
		local a = 255 * transition

		local warning = self.warning
		local duration = self.duration
		local active = self.active
		if active then
			self.warning = math.min(warning + dt, duration)
			if self.warning == duration then
				self.active = false
			end
		end

		local scaling = self.scaling
		local sections = self.sections
		local entry = self.entry
		local exit = self.exit
		local expansion = 0
		local length = 180 * scaling
		
		--length = 0
		if warning < entry then
			expansion = warning / entry
			expansion = easing.outElastic(expansion, 0, 1, 1, 1, 1.2)
		elseif warning > duration - exit then
			--expansion = math.abs(warning / exit - 1)
			expansion = math.abs((warning - (duration - exit)) / exit - 1)
			expansion = easing.inQuint(expansion, 0, 1, 1)
		elseif active then
			expansion = 1
		end

		sections.padding = (self.padding * 3 - self.padding * transition * 2) + expansion * length

		local position = {
			x = x,
			y = y,
		}

		local size = {
			w = w,
			h = h,
		}

		local r = 255
		local g = 255
		local b = 255
		local color = {r, g, b, a}

		self.position = position
		self.size = size
		self.color = color
		self.string = string

		local padding = sections.padding
		local sections = self.sections
		local offset = 0
		
		for i,section in ipairs(sections.list) do
			section:update(dt)
			local w = section:getWidth()
			offset = offset + w
			if i ~= #sections.list then
				offset = offset + padding
			end

			-- this is pretty hard coded but whatever
			if (i / #sections.list == 0.5) or (i / #sections.list + (i + 1) / #sections.list) / 2 == 0.5 then
				self.offset = -offset + padding * 0.5
			end
		end

		--self.offset = -offset * 0.5

	end,

	draw = function(self, batch)

		local position = self.position
		local color = self.color
		local alpha = color[4]

		local sections = self.sections
		local padding = sections.padding
		local offset = self.offset
		for i,section in ipairs(sections.list) do
			local w = section:getWidth()
			local x = position.x + offset
			local y = position.y

			section:draw(batch, {x = x, y = y}, alpha)

			offset = offset + w
			if i ~= #sections.list then
				offset = offset + padding
			end
		end

	end,

	setTransition = function(self, transition)
		self.transition = transition
	end,

	warn = function(self, duration)
		self.active = true
		self.warning = 0
		self.duration = duration + 0.8
	end,

	dismiss = function(self)	
		if self.active and (self.warning < self.duration - self.exit) then
			self.warning = self.duration - self.exit - 0.3
		end
	end,

	clear = function(self)
		self.value = 0
	end,
}

ScorePanelSection = class{
	init = function(self, value, icon, graphic, scale, oscillate)

		local scaling = window.interface
		self.scaling = scaling

		local font = fonts:add('bpreplay-bold.otf', 50, window.interface)
		self.font = font
		self.value = value
		self.padding = 15 * scaling
		self.graphic = graphic
		self.scale = scale
		self.interpolated = 0
		self.rumbling = 0
		self.duration = 0
		self.period = 18

		self.string = '0'

		local unit = {
			w = font:getWidth('0'),
			h = font:getHeight('0'),
		}

		local gw = graphic:getWidth() * scale *  scaling
		local gh = graphic:getHeight() * scale * scaling
		local sw = unit.w
		local sh = unit.h

		local w = gw + 15 + sw
		local h = math.max(gh, sh)

		local size = {
			w = w,
			h = h,
			gw = gw,
			gh = gh,
			sw = sw,
			sh = sh,
		}

		if oscillate then
			self.timer = 0
		end

		self.unit = unit
		self.size = size

		--self:compute()

	end,

	update = function(self, dt)

		self:compute()

		self.timer = self.timer and self.timer + dt or nil
		self.interpolated = self.interpolated + (self.size.w - self.interpolated) * dt * 2

		if self.duration > 0 then
			self.rumbling = math.min(self.rumbling + dt, self.duration)
			if self.rumbling == self.duration then
				self.rumbling = 0
				self.duration = 0
			end
		end

	end,

	draw = function(self, batch, position, alpha)

		local scaling = self.scaling
		local x = position.x
		local y = position.y + 25 * scaling
		local size = self.size
		local padding = self.padding

		-- hacky fix to font related stutters
		local string = math.random()
		if alpha > 0 then
			string = self.string
		end
		local font = self.font
		local rumbling = self.rumbling
		local duration = self.duration
		local period = self.period

		local ox = size.gw + padding
		local oy = 0
		local flash = 0
		if duration > 0 then
			local amplitude = 10 * scaling
			oy = oy + math.sin(rumbling * math.pi * period / duration) * amplitude * math.abs(1 - rumbling / duration)
			flash = 40 * (math.sin(rumbling * math.pi * period / duration) + 1) * 0.5 * math.abs(1 - rumbling / duration)
		end

		lg.setColor(82, 142, 151, alpha)
		font:draw(string, x + ox, y + oy + 5*scaling, 0, 1, 1, 0, size.sh*0.5)

		lg.setColor(255, 255 - flash, 255 - flash, alpha)
		font:draw(string, x + ox, y + oy, 0, 1, 1, 0, size.sh*0.5)

		local graphic = self.graphic
		local scaling = self.scaling
		local scale = self.scale * scaling
		local timer = self.timer

		if graphic then

			local ox, oy = 0, 0
			local radius = 3
			local p = 1

			if timer then
				ox = math.cos(timer * math.pi * 2 * p) * radius
				oy = math.sin(timer * math.pi * 2 * p) * radius
			end

			batch:setColor(0, 0, 0, 30 * (alpha / 255))
			graphic:add(batch, x + ox, y + oy + 4*scaling, 0, scale, scale, 0, size.gh*0.5/scale)

			batch:setColor(255, 255, 255, alpha)
			graphic:add(batch, x + ox, y + oy, 0, scale, scale, 0, size.gh*0.5/scale)

		end

	end,

	compute = function(self)

		local previous = self.string or ''
		local string = self.value()
		self.string = string
		local length = string:len()

		if previous:len() ~= length then

			local unit = self.unit
			local sw = unit.w * length
			local sh = unit.h

			-- i probably don't need to recalculate this every frame either....
			local gw = self.size.gw
			local padding = self.padding
			local w = gw + padding + sw

			local size = self.size
			size.w = w
			size.sw = sw
			size.sh = sh
			self.size = size
		end

		--self.string = string
	end,

	getWidth = function(self)
		return self.interpolated
	end,

	getHeight = function(self)
		return self.size.h
	end,

	flash = function(self)
	end,

	pulse = function(self)
	end,

	rumble = function(self, duration)
		self.rumbling = 0
		self.duration = duration
	end,
}