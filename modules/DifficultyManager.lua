DifficultyManager = class{
	init = function(self, time, scoring, player, danger, edibles)
		self.time = time
		self.scoring = scoring
		self.player = player
		self.danger = danger
		self.edibles = edibles
		self.output = ''
	end,

	update = function(self, dt)

		-- set updated values on player, danger, edibles
		local player = self.player
		local danger = self.danger
		local edibles = self.edibles

		local time = self.time:get()
		-- use time to increment:
			-- player speed (very slightly)

		local t = time / options.day_length
		local points, combo = self.scoring:get()
		
		-- use combo # to increment:
			-- edible density (slight, modified by time)

		local soft_cap = options.edible_density * 0.05
		local hard_cap = options.edible_density * 0.05
		local edible_density = options.edible_density + math.min(math.min(easing.inQuad(combo / 300, 0, 1, 1), 1) * soft_cap, soft_cap)
		edible_density = edible_density + math.min(math.min(easing.inQuad(combo / 300, 0, 1, 1), 1) * hard_cap, hard_cap)
		edible_density = edible_density + (edible_density * 0.05 * (math.sin(t * math.pi * 2 + 1) + 1))
		if combo > 300 then
			edible_density = edible_density + options.edible_density * 0.2 * (combo - 300) / 1000
		end

		local danger_frequency = math.abs(1 - math.min(easing.inQuad(combo / 300, 0, 1, 1), 0.6))
		local danger_difficulty = 11 - 2.5 * math.min(easing.inQuad(combo / 120, 0, 1, 1), 1)
		local danger_quantity = 1 + math.min(math.floor(combo / 300), 1) * 2
		danger_difficulty = danger_difficulty - 3 * math.min(easing.inQuad(combo / 220, 0, 1, 1), 1)

		-- TODO danger frequency shouldn't go down lower than its been before in this session

		local df = self.danger_frequency
		local dd = self.danger_difficulty

		if df and df < danger_frequency then
			danger_frequency = df
		end

		if dd and dd < danger_difficulty then
			danger_difficulty = dd
		end

		danger:setFrequency(danger_frequency)
		danger:setDifficulty(danger_difficulty)
		danger:setQuantity(danger_quantity)
		edibles:setDensity(edible_density)

		metrics:set('danger_frequency', danger_frequency)
		metrics:set('danger_difficulty', danger_difficulty)
		metrics:set('danger_quantity', danger_quantity)
		metrics:set('edible_density', edible_density)

		self.output = danger_difficulty
		self.danger_frequency = danger_frequency
		self.danger_difficulty = danger_difficulty

	end,

	clear = function(self)
		self.danger_frequency = nil
		self.danger_difficulty = nil
	end,

	draw = function(self)
	end,
}