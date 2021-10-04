ScoreBreakdown = class{
	init = function(self, middle, label, color, switch, action, icon, symbol, sx, sy)
		self.position = {x = middle, y = 0}

		local font = fonts:add('bpreplay-bold.otf', 81, window.interface)

		self.font = font
		self.small_font = fonts:add('bpreplay-bold.otf', 44, window.interface)

		self.active = false
		self.timer = 0
		self.duration = 2.2
		self.interpolated = 0
		self.score = 0
		self.best = 0
		self.string = ''

		self.highscore = false
		self.pulsed = false

		self.shake = 0
		self.oscillations = 7
		self.amplitude = 40
		self.angle = 0

		local length = font:getWidth(comma_value(self.score))
		self.length = length

		self.rows = {}
		self.details = 0

		self.pulsing = {
			active = false,
			timer = 0,
			duration = 0,
			amplitude = 0,
			interpolated = 0,
		}

		self.unit = {
			w = font:getWidth('0'),
			h = font:getHeight('0'),
			sw = font:getWidth('0'),
			sh = font:getHeight('0'),
		}

		self.w = self.unit.w

		local subtitle = MenuSubtitle(middle, "")
		subtitle.magnitude = 3
		subtitle:clear()
		self.subtitle = subtitle

		local subtitle_size = subtitle:getSize()

		local padding = 100 * window.interface
		-- todo: add in details height
		self.size = {w = 50, h = self.unit.h + subtitle_size.h + padding}

		self.lion = Graphic("lion_icon")
		self.orb = Graphic("orb")

		signals.register('gameover', function(score, best, from, to, lions, combo)
				self.score = score
				self.best = best
				self.from = from
				self.to = to
				self:clear()
				self:format(lions, combo)
			end)

	end,

	update = function(self, dt)

		local pulsing = self.pulsing
		local active = self.active

		local fireworks = self.fireworks
		if fireworks then
			fireworks:update(dt)
		end

		-- i should put these into their own namespace
		if self.active then


			local duration = self.duration
			self.timer = math.min(self.timer + dt, duration)
			if self.timer == self.duration then
				self.active = false
			end


			local score = self.score
			local best = self.best
			local pulsed = self.pulsed
			local t = easing.outCubic(self.timer, 1, -1, duration)
			local interpolated = easing.outQuint(self.timer, 0, self.score, duration)
			local string = math.ceil(interpolated)
			
			if (self.timer > self.duration * 0.625) and (not pulsed) and (score < best) then
				self.pulsed = true
				sound:emit('pop')
				observer:emit('jiggle')
			end

			if (not self.highscore) and (string == score) and (score > self.best) then
				
				self.highscore = true
				self.pulsed = true
				self:pulse()

				local subtitle = self.subtitle
				local to = self.to
				subtitle.string = to
				subtitle.magnitude = 10
				subtitle:clear()

				sound:emit('pop')
				observer:emit('shake')

				self.fireworks:start()

				-- TODO: 
				--sound:emit('celebration', {delay = 1.175})

				-- sound effect!

			end

			self.string = comma_value(string)
			self.shake = math.sin(self.timer * math.pi * 2 / self.duration * self.oscillations) * self.amplitude * t
		end

		if pulsing.active then
			pulsing.timer = math.min(pulsing.timer + dt, pulsing.duration)
			if pulsing.timer == pulsing.duration then
				pulsing.active = false
			end
			local t = easing.outCubic(pulsing.timer, 1, -1, pulsing.duration)
			local interpolated = math.sin(pulsing.timer * math.pi / pulsing.duration) * pulsing.amplitude
			pulsing.interpolated = interpolated * t
		end


		-- centering
		local length = self.length
		self.w = self.w + (length - self.w) * dt * 7

		self.subtitle:update(dt)

		local rows = self.rows
		for index,row in ipairs(rows) do
			for i,col in ipairs(row) do
				local rate = 0.4 + 0.1 * (index / #rows) + 1.4 * (i / #row)
				local timer = math.min(col.timer + dt * rate, 1)
				col.timer = timer
			end
		end

		local pulsed = self.pulsed
		local details = self.details
		if pulsed then
			-- increment transition for details row
			self.details = math.min(details + dt * 1, 1)
		end

		local base_height = self.base_height
		local size = self.size
		local t = easing.outElastic(details, 0, 1, 1)
		size.h = base_height + (100 + 160 * t) * window.interface

	end,

	format = function(self, lion, combo)

		local font = self.small_font
		local sessions = {
			{
				lions = lion or 0,
				combo = combo or 0,
			}
		}

		local rows = {}
		local columns = {
			"lions",
			"combo",
		}

		local map = {
			lions = {
				graphic = "lion_icon",
				scale = 1.2 * window.interface,
				process = function(v) return comma_value(v) end,
			},
			combo = {
				graphic = "orb",
				scale = 4 * window.interface,
				process = function(v) return comma_value(v) end,
			},
		}

		local gutter = 45 * window.interface
		local spacing = 10 * window.interface
		local margin = 15 * window.interface

		local widest = {}
		local tallest = 0

		local lion = self.lion
		local orb = self.orb

		-- init whatever we need and get sizes
		for index,session in ipairs(sessions) do
			local row = {}
			for i,component in ipairs(columns) do

				local width = 0
				local height = 0

				local data = map[component]
				local process = data.process
				local scale = data.scale

				local preselected

				-- try to reuse this
				local graphic
				if component == "lions" then
					graphic = lion
				elseif component == "combo" then
					graphic = orb
				else
					graphic = Graphic(data.graphic, preselected)
				end

				local gw, gh = graphic:getSize()
				local string = process(session[component])
				local sw, sh = font:getSize(string)
				local value = {
					string = string,
				}

				local icon = {
					graphic = graphic,
				}

				icon.x = 0
				icon.y = 0

				value.x = 0
				value.y = 0

				local col = {
					name = component,
					icon = icon,
					value = value,
					scale = scale,
					timer = 0,
				}
				-- i want dynamic data here too, like timers and dimensions of the content
				row[#row + 1] = col

				width = gw * scale + sw
				if i ~= #columns then
					width = width + margin
				end
				height = math.max(gh * scale, sh) + spacing

				widest[component] = widest[component] and math.max(widest[component], width) or width
				tallest = math.max(tallest, height)

			end
			rows[#rows + 1] = row
		end

		-- determine row and col offsets using widest and tallest
		local w = 0
		for _,value in pairs(widest) do
			w = w + value
		end
		local h = tallest * #rows

		self.height = h + spacing * 2

		local x = w * -0.5
		local y = h * -0.5 + spacing * 3

		for index,row in ipairs(rows) do

			-- start the row coordinates
			local rx = x - gutter * 0.5
			local ry = y + tallest * (index - 1)

			for i,col in ipairs(row) do
				-- set graphic and value position
				local component = col.name
				local length = widest[component]
				
				local value = col.value

				local icon = col.icon
				local graphic = icon.graphic
				local gw, gh = graphic:getSize()

				icon.x = rx
				icon.y = ry

				local string = value.string
				local sw, sh = font:getSize(string)

				value.x = rx + gw * col.scale * 0.5 + margin + sw*0.5
				value.y = ry

				rx = rx + length + gutter
			end

		end

		-- we want to calculate the max width for each col and use that for spacing instead

		self.rows = rows


	end,

	draw = function(self, batch)
		local position = self.position
		local font = self.font
		local string = self.string
		local shake = self.shake
		local pulsing = self.pulsing
		local alpha = self.alpha

		local x = self.position.x
		local y = self.position.y + shake

		local angle = self.angle
		local scale = self.scale + pulsing.interpolated

		local unit = self.unit
		local len = string:len()
		local w = self.w
		local h = unit.h

		-- draw particles?
		local fireworks = self.fireworks
		if fireworks then
			fireworks:draw(x, y)
		end

		lg.setColor(82, 142, 151, alpha)
		font:draw(string, x, y + 6 * window.interface, angle, scale, scale, w*0.5, h*0.5)

		lg.setColor(255, 255, 255, alpha)
		font:draw(string, x, y, angle, scale, scale, w*0.5, h*0.5)

		local subtitle = self.subtitle
		subtitle.scale = subtitle.scale - pulsing.interpolated * 2
		subtitle:draw(batch)
		local subtitle_size = subtitle:getSize()

		local details = self.details
		local rows = self.rows
		local font = self.small_font
		for index,row in ipairs(rows) do
			local cols = #row

			local x = x
			local y = y + (h + subtitle_size.h + 20 * window.interface)
			local scale = scale * easing.outElastic(details, 0, 1, 1)
			local expand = scale
			if index == focus then
				x = x + 4 * (math.cos(timer * tau) + 0.5)
			end

			for i,col in ipairs(row) do
				
				local name = col.name
				local value = col.value
				local icon = col.icon
				local graphic = icon.graphic
				local ti = col.timer
				local t = easing.outElastic(ti, 0, 1, 1, 0.5, 5.5)
				local a = alpha * easing.outCubic(ti, 0, 1, 1)

				local offset = 3 * window.interface

				if icon then
					local w, h = graphic:getSize()
					local gx, gy = icon.x, icon.y
					local s = col.scale * scale
					gy = gy * expand * t

					batch:setColor(0, 0, 0, 30 * (a / 255))
					graphic:add(batch, x + gx, y + gy + offset, 0, s, s, w*0.5, h*0.5)

					batch:setColor(255, 255, 255, a)
					graphic:add(batch, x + gx, y + gy, 0, s, s, w*0.5, h*0.5)
				end

				if value then
					local string = value.string
					local w, h = font:getSize(string)
					local sx, sy = value.x, value.y
					local s = scale * expand
					sy = sy * expand * t

					lg.setColor(82, 142, 151, a)
					font:draw(string, x + sx, y + sy + offset * 2, 0, s, s, w*0.5, h*0.5)

					lg.setColor(255, 255, 255, a)
					font:draw(string, x + sx, y + sy, 0, s, s, w*0.5, h*0.5)
				end
			end
		end

	end,

	getSize = function(self)
		return self.size
	end,

	pulse = function(self)
		local pulsing = self.pulsing
		pulsing.timer = 0
		pulsing.duration = 0.45
		pulsing.amplitude = 1
		pulsing.active = true
	end,

	target = function(self, x, y, scale, alpha)
		self.position.x = x
		self.position.y = y
		self.scale = scale
		self.alpha = math.min(alpha, 255)

		self.subtitle:target(x, y + self.unit.h*0.85, scale, alpha)
	end,

	clear = function(self)
		self.timer = 0
		self.active = true
		self.highscore = false
		self.pulsed = false
		self.details = 0
		self.pulsing = {
			active = false,
			timer = 0,
			duration = 0,
			amplitude = 0,
			interpolated = 0,
		}

		local subtitle = self.subtitle
		local from = self.from
		local best = self.best
		local score = self.score
		subtitle.string = 'high score  * ' .. comma_value(best)
		subtitle.string = (from):format(comma_value(best))
		subtitle.magnitude = 3
		subtitle:clear()
		self.subtitle = subtitle
		local subtitle_size = subtitle:getSize()
		local font = self.font
		self.length = font:getWidth(comma_value(score))

		local details = self.details
		local padding = 100

		self.base_height = self.unit.h + subtitle_size.h

		local size = {w = 50, h = self.unit.h + subtitle_size.h + (100 + 160 * details) * window.interface}
		self.size = size

		self.fireworks = Fireworks(w, h)
	end,

	inputpressed = function(self, id, x, y, mode)
		local active = self.active
		if not active then

			local fireworks = self.fireworks
			if fireworks then
				fireworks:start()
			end
			self:pulse()
			sound:emit('pop')
			observer:emit('jiggle')
		end
	end,

	inputreleased = function(self, id, x, y, mode)
	end,
}