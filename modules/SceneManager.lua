SceneManager = class{
	
	init = function(self, skip)

		local objects, renderer, controller, terrain, collisions, player, edibles, scoring, ui, danger, time, difficulty

		-- this is a bit hacky, I'd prefer to know the bound of the player, but I haven't created them yet
		-- why does this get inverted on re-init?
		local focus = {
			x = window.width * 0.75,
			y = window.center.y - window.height * 0.5,
			z = 1 * (window.scaling),
		}

		local target = {
			x = window.width * 0.75,
			y = window.center.y,
			z = 1 * (window.scaling),
		}

		-- I should have an initial input for the vierestartwport controller for where I want to look + transition
		lg.setLineWidth(4)

		-- set viewport in global namespace, used for clipping objects that should be removed
		viewport = focus
		
		-- scene-specific namespace for observer pattern
		observer = signals.new()

		-- scene-specific global metric recorder
		metrics = Metrics()

		-- object manager updates and draws all world-space objects
		objects = ObjectManager()

		-- manages time and updates stage
		time = TimeManager()

		-- collision manager checks all objects which are registered to it for intersections
		collisions = CollisionManager(objects)

		-- player manager controls a giraffe rig using an input manager and a platform controller
		player = PlayerManager(objects)

		-- danger manager controls lion addition and pace
		danger = DangerManager(objects, time)

		-- score manager handles combos and worldspace score tokens
		scoring = ScoreManager(objects)

		-- viewport controller follows a target
		controller = ViewportController(focus, target)
		controller:target(player)

		-- viewport renderer recieves a drawstack from object manager and draws it according to
		-- the viewport controller's position
		renderer = ViewportRenderer(objects, controller)

		-- edible manager spawns edibles based on the viewport controller position
		edibles = EdibleManager(objects, controller)

		-- terrain manager spawns and destroys terrain props for the viewport controller
		terrain = TerrainManager(objects, controller)

		-- ui instance for this scene
    	ui = InterfaceManager(scoring)

		-- manages difficulty over time
		difficulty = DifficultyManager(time, scoring, player, danger, edibles)

		-- store all of these so we can update them or send them input callbacks
		self.objects = objects
		self.time = time
		self.difficulty = difficulty
		self.player = player
		self.danger = danger
		self.scoring = scoring
		self.metrics = metrics
		self.controller = controller
		self.renderer = renderer
		self.terrain = terrain
		self.edibles = edibles
		self.collisions = collisions
		self.ui = ui 
		self.strikes = 0
		self.started = false
		self.active = false

		if (not skip) then
			self.delay = 0.3
			self.action = function()
				if not self.started then
					--signals.emit('switch', 'root')
				end
				-- menu entrance sound?
			end
		else
			self.delay = nil
		end

		observer:register('finish', function() self:finish() end)

		local best = leaderboard:best()
		metrics:set('best', best)


	end,

	update = function(self, dt, rdt)

		local delay = self.delay
		if (delay) then
			self.delay = self.delay - dt
			if (self.delay <= 0) then
				local cancelled = self.started
				self.action(cancelled)
				self.delay = nil
			end
		end

		if not paused then
			self.time:update(dt)
			self.difficulty:update(dt)
			self.player:update(dt)
			self.danger:update(dt)
			self.controller:update(dt)
			self.terrain:update(dt)
			self.edibles:update(dt)
			self.objects:update(dt)
			self.collisions:update(dt)
		end

		self.ui:update(rdt)
		self.renderer:update(rdt)
		
	end,

	draw = function(self, transition)

		self.renderer:draw(transition)
		self.ui:draw(transition)
		self.metrics:draw()

	end,

	start = function(self)
		local started = self.started
		if (not started) then
			self.started = true
			self.active = true
			self.time:start()
			self.controller:start()
			self.player:start()
			self.danger.locked = false
			self.difficulty:clear()

			self.ui.locked = false
			self.ui:enter()
			self.scoring.started = true
			score:emit('unlock')
		end
	end,

	finish = function(self)

		self.scoring.started = false
		self.active = false
		self.danger.locked = true
		self.ui:exit()

		local session = metrics:dump()

		local score = session.score
		local elapsed = session.elapsed
		local combo = session.combo
		local flipped = session.lions_flipped

		local best = leaderboard:best()
		local previous = leaderboard:previous()
		local placed, displacing, index = leaderboard:bid(session)

		local threshold, from, to

		local threshold = best
		local from = "best score * %s"
		local to = "new best score"

		signals.emit("placed", index)

		if placed and displacing ~= best then
			threshold = displacing
			from = "high score * %s"
			to = "new high score"
		elseif previous and (not displacing) then
			threshold = previous.score
			from = "previous score * %s"
			local gained = comma_value(score - threshold)
			to = ("* %s more than last run"):format(gained)
		end

		signals.emit('gameover', score, threshold, from, to, flipped, combo)

		local strike
		local n = 1

		if (flipped == 0) and (elapsed < 40) then
			strike = true
		end

		if (elapsed < 15) then
			strike = true
			n = n + 1
		end

		if (flipped < 4) and (elapsed < 30) then
			strike = true
		end

		local strikes = self.strikes
		if strike then
			self.strikes = strikes + n
		elseif strikes > 0 then
			self.strikes = math.max(strikes - 0.5, 0)
		end

		local hint
		local tolerance = 3
		if self.strikes >= tolerance then
			hint = true
			self.strikes = 1
		end

		if placed then
			metrics:set('best', score)
		end

		-- keep track of our strikes per session
		session.strikes = strikes
		session.highscore = placed

		-- send analytics and store the session here
		local event = {
			type = "session",
			report = session,
		}
		analytics:report(event)
		
		sound:emit('hiscore', {delay = 0.15})

		if hint then
			signals.emit('switch', 'learning')
		else
			signals.emit('switch', 'gameover')
		end

	end,

	enter = function(self, callback)
		self.renderer:enter(callback)
	end,

	exit = function(self, callback)
		self.renderer:exit(callback)
		self.ui:exit()
	end,

	mousepressed = function(self, x, y, button)
		self.player:mousepressed(x, y, button)
		self.controller:mousepressed(x, y, button)
		self.ui:mousepressed(x, y, button)
	end,

	mousereleased = function(self, x, y, button)
		self.player:mousereleased(x, y, button)
		self.ui:mousereleased(x, y, button)
	end,

	touchpressed = function(self, id, x, y, pressure)
		self.player:touchpressed(id, x, y, pressure)
	end,

	touchreleased = function(self, id, x, y, pressure)
		self.player:touchreleased(id, x, y, pressure)
	end,

	touchmoved = function(self, id, x, y, pressure)
	end,

	keypressed = function(self, key, code)

		if key == 'escape' or key == 'p' then
			signals.emit('toggle')
		end

		if key == 'r' then
			signals.emit('restart')
		end
		
		if key == " " then
			self.player:flip()
		end

	end,

	keyreleased = function(self, key, code)
		self.controller:keyreleased(key, code)
	end,

	retry = function(self, skip)

		local offset = window.width * 1.6
		local x = viewport.x + offset

		self.controller.focus = {x = x, y = window.center.y, z = 1}
		self.controller.started = false
		self.controller.locked = true
		self.started = false
		self.active = false

		self.player.rig.body.wind.audio:pause()

		-- set a new edge
		self.edibles.edge = x - 300		

		-- let go of the last player
		local previous = self.player
		previous:release()

		-- i need to position this player...
		local start = x - window.width + 250
		if skip then
			start = x - window.center.x - 100
		end

		-- create a new giraffe
		local objects = self.objects
		local player = PlayerManager(objects, start)
		self.player = player

		-- lock the ui state
		self.ui:exit()
		self.ui.locked = true		

		self.controller:target(player)

		signals.emit('switch', 'close')

		-- call any pending callbacks that may exist
		if self.delay then
			self.action()
		end

		self.scoring:clear()

		self.ui.notes:dismiss()
		self.ui.started = false

		--self.danger:flip(true)
		self.danger:clear()

		self.delay = 0.7
		self.action = function(cancelled)

			-- remove the previous giraffe
			previous:destroy()

			if not cancelled then

				metrics:clear()
				metrics:set('best', leaderboard:best())
				
				-- quick retry
				if skip then
					signals.emit('start')
					self.ui:enter()
					player.input.started = true
					player.input.triggered = true
					self.scoring.started = true
				end
			end

			if (not skip) then
				signals.emit('switch', 'root')
				player.input.started = false
				player.input.triggered = false
				self.ui.locked = false
				self.scoring.started = false
			end
		end

	end,

	mute = function(self)
		observer:emit('pause')
	end,

	unmute = function(self)
		observer:emit('resume')
	end,

}