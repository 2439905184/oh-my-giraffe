LeaderboardView = class{
	init = function(self, middle, label)

		local position = {
			x = middle,
			y = 0,
		}

		local size = {w = 400, h = 400 * window.interface}
		self.position = position
		self.size = size
		self.scale = 0
		self.alpha = 0
		self.font = fonts:add('bpreplay-bold.otf', 44, window.interface)
		self.timer = 0

		self.label = label
		self.lion = Graphic("lion_icon")
		self.orb = Graphic("orb")
		self.pixel = Graphic("pixel")

		signals.register("leaderboard", function(sessions) self:format(sessions) end)
		signals.register("placed", function(index) self:pulse(index) end)

		self.expanded = false

		-- todo: spritebatch these images

		self.focus = 1
		self.active = false

		g["leaderboard"] = self

	end,

	format = function(self, sessions)

		local font = self.font

		local cap = 5

		local clipboard = self.clipboard
		local expanded = self.expanded

		if #sessions == 0 then
			local focus = self.focus
			self.clipboard = focus
			self.focus = nil
		elseif clipboard then
			self.focus = clipboard
			self.clipboard = nil
		end

		while #sessions < cap do
			local session = {
					score = 0,
					lions_flipped = 0,
					combo = 0,
				}
			table.insert(sessions, session)
		end

		self.sessions = sessions

		local rows = {}
		local columns = {
			"score",
			"lions_flipped",
			"combo",
		}

		--[[
		if expanded then
			table.insert(columns, "distance")
		end
		]]--

		local now = os.time()
		local map = {
			score = {
				graphic = "edible",
				scale = 4 * window.interface,
				process = function(v) return comma_value(v) end,
			},
			lions_flipped = {
				graphic = "lion_icon",
				scale = 1.2 * window.interface,
				process = function(v) return comma_value(v) end,
			},
			combo = {
				graphic = "orb",
				scale = 4 * window.interface,
				process = function(v) return comma_value(v) end,
			},
			distance = {
				graphic = "pixel",
				scale = 0,
				process = function(v)
					local v = v and (v / window.width * 0.05) or 0
					local v = round(v, 1)
					local meters = ("%s km"):format(v)
					return meters
				end,
			},
			time = {
				graphic = "pixel",
				scale = 0,
				process = function(v)
					local difference = now - v
					local date = os.date("*t", difference)
					local since = ("%s minutes ago"):format(math.ceil(difference / 60))
					return since
				end,
			},
		}

		local gutter = 60 * window.interface
		local spacing = 10 * window.interface
		local margin = 15 * window.interface

		if expanded then
			gutter = 45 * window.interface
		end

		local widest = {}
		local tallest = 0

		local lion = self.lion
		local pixel = self.pixel
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
				if component == "score" then
					if index == 1 then
						preselected = 3
					elseif index == 2 then
						preselected = 2
					else
						preselected = 1
					end
				end

				-- try to reuse this
				local graphic
				if component == "lions_flipped" then
					graphic = lion
				elseif component == "distance" or component == "time" then
					graphic = pixel
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

				width = gw * scale + margin + sw
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

		self.size = {w = w, h = h + spacing * 2}
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

	update = function(self, dt)
		-- I can increment timers here for fancier transitions

		local rows = self.rows
		for index,row in ipairs(rows) do
			for i,col in ipairs(row) do
				local rate = 0.4 + 0.1 * (index / #rows) + 1.4 * (i / #row)
				local timer = math.min(col.timer + dt * rate, 1)
				col.timer = timer
			end
		end

		local height = self.height
		local scale = self.scale
		local size = self.size
		size.h = height * easing.outCubic(scale, 0, 1, 1)

		self.timer = self.timer + dt

	end,

	draw = function(self, batch)

		local position = self.position
		local x = position.x
		local y = position.y
		local size = self.size
		local w = size.w
		local h = size.h

		local scale = self.scale
		local alpha = self.alpha

		local timer = self.timer
		local focus = self.focus

		local pi = math.pi
		local tau = pi * 2

		local rows = self.rows
		local font = self.font
		for index,row in ipairs(rows) do
			local cols = #row

			local x = x
			local scale = scale
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
					local s = col.scale
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
					font:draw(string, x + sx, y + sy + offset, 0, s, s, w*0.5, h*0.5)

					lg.setColor(255, 255, 255, a)
					font:draw(string, x + sx, y + sy, 0, s, s, w*0.5, h*0.5)
				end
			end
		end

	end,

	pulse = function(self, index)
		self.focus = index
	end,

	getSize = function(self)
		return self.size
	end,

	target = function(self, x, y, scale, alpha)
		self.position.x = x
		self.position.y = y
		self.scale = scale
		self.alpha = math.min(alpha, 255)

		-- only set this if we're on the pause panel version...
		-- oh my good grief this is horrible
		-- how can I indicate if this is up or not?
		-- tell the button to be visible?
	end,

	trigger = function(self)
	end,

	inputpressed = function(self, id, x, y, mode)
	end,

	inputreleased = function(self, id, x, y, mode)
	end,
}