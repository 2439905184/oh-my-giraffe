-- renders a DrawManager in camera space with an external controller
-- this should have its own intro/exit methods or a controller to do so from scenemanager
ViewportRenderer = class{

	init = function(self, manager, controller)

		self.controller = controller
		self.camera = camera()

		self.manager = manager
		self.renderer = DrawManager(manager)
		self.graphic = Graphic('pixel')

		self.transitions = {
			enter = {
				timer = 0,
				duration = 1.8,
				active = false,
				callback = nil,
			},
			exit = {
				timer = 0,
				duration = -0.5,
				active = false,
				callback = nil,
			}
		}

		self.fade = {0, 0, 0, 255}
		--self.fade = {113, 183, 193, 255}
		self.scale = 1
		self.timer = 0
		self.active = true
		self:enter()
		
	end,

	enter = function(self, callback)
		if not self.transitions.enter.active then
			self.transitions.enter.timer = self.transitions.enter.duration
			self.transitions.enter.callback = callback
			self.transitions.enter.active = true
		end
	end,

	exit = function(self, callback)
		if not self.transitions.enter.active then
			self.transitions.exit.timer = self.transitions.exit.duration
			self.transitions.exit.callback = callback
			self.transitions.exit.active = true
		end
	end,

	update = function(self, dt)

		local multiplier

		-- compute own scale
		for _,state in pairs(self.transitions) do
			state.timer = (state.timer > 0) and math.max(state.timer - dt, 0) or math.min(state.timer + dt, 0)
			if (state.active) then
				if (state.timer > 0) then
					multiplier = easing.inCubic(state.timer, 0, state.duration, state.duration) / state.duration
				elseif (state.timer < 0) then
					multiplier = easing.outCubic(state.timer, -state.duration, state.duration, state.duration) / math.abs(state.duration)
				end
			end
			if (state.timer == 0) and (state.active) then
				state.active = false
				if _ == 'exit' then
					self.active = false
				end
				if state.callback and (not state.threshold) then
					state.callback()
				end
			end
		end

		local scale = (multiplier) and (1 + 0.3 * multiplier) or (1)
		self.scale = scale

		local fade = (multiplier) and math.abs(1 - multiplier) or (1)
		local color = world.color

		if options.loader then
			color = {world.color[1], world.color[2], world.color[3], 255 * fade}
		else
			color = {world.color[1] * fade, world.color[2] * fade, world.color[3] * fade, 255 * fade}
		end

		color = {world.color[1], world.color[2], world.color[3], 255}
		
		self.color = color or world.color
		self.fade[4] = 255 * math.abs(1 - fade) * math.abs(1 - fade)
		
		-- bind camera and renderer to controller
		local x, y, z = self.controller:get()
		z = z * scale
		self.camera:set(x, y, z)

		-- project all the objects into screenspace here
		if not paused then
			self.renderer:set(x, y)
			self.renderer:update(dt)
		end


	end,

	draw = function(self, transition)

		local shaders = self.shaders
		local controller = self.controller
		local renderer = self.renderer
		local camera = self.camera

		local x, y, z = controller:get()
		local w, h = lg.getWidth(), lg.getHeight()
		local color = self.color or world.color
		local fade = self.fade
		local graphic = self.graphic

		-- draw scene
		camera:attach()
		renderer:draw(x, y, z)
		camera:detach()

		-- draw color overlay
		lg.setColor(color)
		lg.setBlendMode('multiplicative')
		-- this is only an overlay...
		-- so what I really want is to fade from the background color full opacity to 
		-- to this, and then fade from the background color what opacity? uuuh
		graphic:draw(0, 0, 0, w, h)
		lg.setBlendMode('alpha')

		-- need to draw the fade seperately, actually
		lg.setColor(fade)
		graphic:draw(0, 0, 0, w, h)


		-- draw debug info
		if settings.debug then
			self:debug()
		end

	end,

	debug = function(self)

		local x, y, z = self.controller:get()
		local stack, count = self.manager:count()
		local w, h = lg.getWidth(), lg.getHeight()
		local outline = {
			'line',
			w * (1 - (z / window.scaling)) / 2,
			h * (1 - (z / window.scaling)) / 2,
			w * (z / window.scaling),
			h * (z / window.scaling)
		}

		lg.setColor(255, 255, 255)
		lg.rectangle(unpack(outline))
		fonts:draw('inconsolata.otf', 14, tostring(stack) .. ' objects in stack\n' .. tostring(count) .. ' in manager', 15, 15)

	end,

}