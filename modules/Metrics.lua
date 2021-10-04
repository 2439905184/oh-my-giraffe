-- keeps track of various score related metrics
Metrics = class{
	init = function(self)
		if options.metrics then
			self.font = lg.newFont('assets/fonts/inconsolata.otf', 32)
		end
		self.score = 0
		self.combo = 0
		self.lions_awoken = 0
		self.lions_headbutted = 0
		self.lions_flipped = 0
		self.eaten = 0
		self.spawned = 0
		self.vines = 0
		self.best = 0
		self.best_combo = 0
		self.caught = 0
		self.missed = 0
		self.distance = 0
		self.days = 0
		self.time = 0
		self.elapsed = 0
		self.fps = 0
		self.danger_frequency = 0
		self.danger_difficulty = 0
		self.danger_quantity = 0
		self.edible_density = 0
	end,

	draw = function(self)
		if options.metrics then
			local font = self.font
			lg.setFont(font)
			lg.setColor(255, 255, 255)
			local _, _, flags = lw.getMode()
			local s = 'development build - ' .. lt.getFPS() .. 'fps'
			s = flags.vsync and s .. ' [v]' or s
			local w = font:getWidth(s)
			local h = font:getHeight(s)
			lg.print(s, lg.getWidth() - 15, 15, 0, 1, 1, w)
			local count = 0
			for key,val in pairs(self) do
				if type(val) == 'number' then
					local s = key .. ': ' .. val
					local w = font:getWidth(s)
					local h = font:getHeight(s)
					lg.print(s, lg.getWidth() - 15, 55 + 40 * count, 0, 1, 1, w)
					count = count + 1
				end
			end
		end
	end,

	set = function(self, label, value)
		if type(self[label]) == 'number'then
 			self[label] = value
 		end
	end,

	add = function(self, label, n)
		if type(self[label]) == 'number' then
 			self[label] = self[label] + n
 		end
 	end,

 	bid = function(self, label, value, order)
 		if type(self[label]) == 'number' then
 			local order = order or function(a, b) return a > b end
 			self[label] = order(value, self[label]) and (value) or (self[label])
 		end
 	end,

	get = function(self, label)
		return self[label]
	end,

	clear = function(self)
		for _,key in pairs(self) do
			if type(key) ~= 'function' and _ ~= 'font' then
				self[_] = 0
			end
		end
	end,

	-- create a session table
	dump = function(self)
		local session = {
			score = self.score,
			combo = self.best_combo,
			lions_flipped = self.lions_flipped,
			lions_headbutted = self.lions_headbutted,
			lions_awoken = self.lions_awoken,
			vines_spawned = self.vines,
			fruit_eaten = self.eaten,
			fruit_spawned = self.spawned,
			fruit_caught = self.caught,
			fruit_missed = self.missed,
			distance = self.distance,
			elapsed = self.elapsed,
			days = self.days,
			fps = self.fps,
			time = os.time(),
			version = window.version,
		}
		return session
	end,
}