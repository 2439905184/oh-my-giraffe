MusicManager = class{
	init = function(self)
		
		-- hmm, how do I capture the observer?
		-- since that happens inside of the scene?...
		-- I can just call this directly inside of the time manager...

		local delay = 0.7
		--local theme = audio:process('theme', {loop = true, volume = {0.25, 0.25}, delay = delay})

		local birds = audio:process('birds', {loop = true, volume = {0, 0}})
		local crickets = audio:process('crickets', {loop = true, volume = {0, 0}})

		local modes = {
			day = function() end,
			night = function() end,

		}

		local tracks = {
			{
				task = birds,
				volume = function() return math.abs(self.slider - 1) end,
				amplification = 0.1,
			},
			{
				task = crickets,
				volume = function() return self.slider end,
				amplification = 2,
			}
		}

		self.modes = modes
		self.tracks = tracks
		self.slider = 0
		self.target = 0
		self.master = 0

	end,

	update = function(self, dt)

		self.master = math.min(self.master + dt, 1)
		self.slider = self.slider + (self.target - self.slider) * dt * 1

		local master = self.master
		local tracks = self.tracks
		for _,track in ipairs(tracks) do
			local volume = track.volume() * track.amplification * master
			track.task.source:setVolume(volume)
		end
		
	end,

	draw = function(self)
	end,

	switch = function(self, theme)
	end,

	pause = function(self)
		local tracks = self.tracks
		for _,track in pairs(tracks) do
			track.task.source:pause()
		end
	end,

	resume = function(self)
		local tracks = self.tracks
		for _,track in pairs(tracks) do
			-- attempt at fixing iOS bug where audio sources are loudly unpaused
			track.task.source:setVolume(0)
			track.task.source:resume()
		end
	end,
}