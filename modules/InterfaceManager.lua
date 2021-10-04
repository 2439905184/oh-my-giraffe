
-- i should refactor this complete
-- interface manager contains interface groups
-- interface groups contain interface panels
-- interface panels are: pause/play, timer, score, multplier


InterfaceManager = class{
	init = function(self, scoring)
	
		-- control the scoreboard
			-- displays SCORE and COMBO
		-- control the pause button
			-- pause button should toggle between || and >
		-- controls pause overlay
			-- eases in and out during pause (200ms)

		local transition = {
			timer = -0.5,
			duration = 0.5,
			value = 0,
			active = false,
		}

		local overlay = {
			fade = 0,
			interpolated = {0, 0, 0, 0},
			timer = 0,
			duration = 0.3,
		}

		self.transition = transition
		self.overlay = overlay
		self.pause = PausePanel()
		self.reset = ResetButton()
		self.scoring = scoring
		self.notes = NotificationManager()
		self.flashes = {}
		self.locked = false

		observer:register('warn', function() self:flash() end)

	end,

	update = function(self, dt)

		local transition = self.transition
		if transition.active then
			transition.timer = math.min(transition.timer + dt, transition.duration)
			local timer = math.max(transition.timer, 0)
			local value = easing.outCubic(timer, 0, 1, transition.duration)
			transition.value = value
		else
			transition.timer = math.max(transition.timer - dt, 0)
			local timer = math.max(transition.timer, 0)
			local value = easing.outCubic(timer, 0, 1, transition.duration)
			transition.value = value
		end

		local overlay = self.overlay
		if paused then
			overlay.timer = math.min(overlay.timer + dt, overlay.duration)
			local interpolated = easing.outCubic(overlay.timer, 0, 1, overlay.duration)
			local fade = interpolated
			overlay.fade = fade
		else
			overlay.timer = math.max(overlay.timer - dt, 0)
			local interpolated = easing.inCubic(overlay.timer, 0, 1, overlay.duration)
			local fade = interpolated
			overlay.fade = fade
		end

		local pauseTransition = transition.value
		pauseTransition = pauseTransition * math.abs(overlay.fade - 1)
		self.pause:setTransition(pauseTransition)
		self.pause:update(dt)

		self.reset:setTransition()
		self.reset:update(dt)

		if not paused then

			local scoreTransition = transition.value
			self.scoring:setTransition(scoreTransition)
			self.scoring:update(dt)

			self.notes:setTransition(scoreTransition)
			self.notes:update(dt)

			local flashes = self.flashes
			for i,flash in ipairs(flashes) do
				flash:update(dt)
				if not flash.active then
					flash = nil
					table.remove(flashes, i)
				end
			end
		end

	end,

	draw = function(self)

		local batch = g.batch
		batch:bind()

		local flashes = self.flashes
		for i,flash in ipairs(flashes) do
			flash:draw()
		end

		self.pause:draw()
		self.reset:draw()

		self.notes:draw(batch)
		self.scoring:draw(batch)

		batch:unbind()
		lg.draw(batch)
		batch:clear()

	end,

	mousepressed = function(self, x, y, button)
		self.pause:mousepressed(x, y, button)
		self.reset:mousepressed(x, y, button)
	end,

	mousereleased = function(self, x, y, button)
		self.pause:mousereleased(x, y, button)
		self.reset:mousereleased(x, y, button)
	end,

	keypressed = function(self, key, code)
		if key == 'n' then
			observer:emit('warn', options.combo_leeway)
		end
	end,

	keyreleased = function(self, key, code)
	end,

	add = function(self, part)
	end,

	flash = function(self, duration)
		local flashes = self.flashes
		local duration = 0.4
		local flash = Flash(duration)
		flashes[#flashes + 1] = flash
	end,

	enter = function(self)
		if not self.locked then
			self.transition.active = true
		end
	end,

	exit = function(self)
		if not self.locked then
			self.transition.active = false
		end
	end,

}