--[[
i may need to refactor this system a bit!
the easiest way to fix sounds might be to prototype in a seperate file
]]--
AudioManager = class{
	init = function(self)

		sound = signals.new()

		local sounds = templates.assets.audio
		for label, file in pairs(sounds) do
			sound:register(label, function(options) self:process(label, options) end)
			local tags = file.tags or {}
			for _,variant in ipairs(file.variants) do
				variant.source:addTags('all')
				variant.source:addTags(unpack(tags))
			end
		end

		self.queue = {}
		self.instances = {}

		self.selected = {}

		self.volume = 1
		self.pitch = 1
		self.volume_target = 1
		self.pitch_target = 1
		
	end,

	update = function(self, dt)

		local resolution = 50
		local interpolated_volume = self.volume + (self.volume_target - self.volume) * dt * 5
		local interpolated_pitch = self.pitch + (self.pitch_target - self.pitch) * dt * 5

		self:setVolume(interpolated_volume)
		self:setPitch(interpolated_pitch)

		local master_volume = self.volume
		local master_pitch = self.pitch
		local instances = self.instances
		local queue = self.queue
		for i,task in ipairs(queue) do
			task.delay = math.max(task.delay - dt, 0)
			task.sustained = math.max(task.sustain - dt, 0)
			if task.delay == 0 then
				task.source:setLooping(task.loop)
				if task.method == 'play' then

					-- todo
					-- account for global pitch and volume modulation by tag
					local volume = task.volume[1] + (task.volume[2] - task.volume[1]) * math.random()
					volume = volume * master_volume
					task.source:setVolume(volume)

					local pitch = task.pitch[1] + (task.pitch[2] - task.pitch[1]) * math.random()
					pitch = pitch * master_pitch
					task.source:setPitch(pitch)

					instances[#instances + 1] = task

				end

				local instance = task.source[task.method](task.source)

				if (task.sustain > 0) then
					local task = {
						source = instance,
						volume = task.volume,
						pitch = task.pitch,
						method = 'stop',
						delay = task.sustain,
						sustain = 0,
						loop = false,
					}
					queue[#queue + 1] = task
 				end
				table.remove(queue, i)
			end
		end

		for i,task in ipairs(instances) do
			-- set new pitches based on their parameters
			-- need to know how long these will play for...
		end
	end,

	process = function(self, label, options)

		local selected = self.selected

		local group = templates.assets.audio[label]
		local source, key
		if group then

			-- TODO:
			-- never choose what was last chosen
			-- just remember the key for this label
			local previous = selected[label]
			if previous and #group.variants > 1 then
				local attempts = 3
				for i = 1, attempts do
					key = wchoose(group.variants)
					if key ~= previous then
						break
					end
				end	
			else
				key = wchoose(group.variants)
			end
			if key then
				local asset = group.variants[key].source
				selected[label] = key
				source = asset
			end
		end

		if source then

			local queue = self.queue
			local options = options or {}

			local volume = options.volume or {1, 1}
			local volume_preset = group.variants[key].volume or {1, 1}
			volume[1] = volume[1] * volume_preset[1]
			volume[2] = volume[2] * volume_preset[2]

			local pitch = options.pitch or {1, 1}
			local pitch_preset = group.variants[key].pitch or {1, 1}
			pitch[1] = pitch[1] * pitch_preset[1]
			pitch[2] = pitch[2] * pitch_preset[2]

			local sustain = options.sustain or 0
			local loop = options.loop
			local delay = options.delay or 0
			local task = {
				source = source,
				method = 'play',
				volume = volume,
				pitch = pitch,
				delay = delay,
				sustain = sustain,
				loop = loop or sustain > 0,
			}
			queue[#queue + 1] = task

			return task

		end

	end,

	draw = function(self)
		--lg.setFont(font_large)
		--lg.setColor(255, 255, 255)
		--lg.print(self.volume, 15, 15)
	end,

	keypressed = function(self, key, code)
		if key == '1' then
			self:mute()
		end
		if key == '2' then
			self:unmute()
		end
	end,

	keyreleased = function(self, key, code)
	end,

	easeVolume = function(self, target)
		self.volume_target = target
	end,

	easePitch = function(self, target)
		--self.pitch_target = target
	end,

	setVolume = function(self, value)
		self.volume = value
		--la.tags.all.setVolume(value)
		-- can i use a built in solution for this?
		if focused then
			love.audio.setVolume(value)
		end
	end,

	setPitch = function(self, value)
		-- i may need to interate through each audio source...
		-- adjust playing instances
		-- maybe select something other than all?

		
		--self.pitch = value
		--local value = tonumber(value) or 1
		--la.tags.bendable.setPitch(value)
	end,

	enterSlowmo = function(self)
		self:easePitch(0.15)
	end,

	exitSlowmo = function(self)
		self:easePitch(1)
	end,

	mute = function(self)
		self.volume_target = 0
	end,

	unmute = function(self)
		self.volume_target = 1
	end,
}