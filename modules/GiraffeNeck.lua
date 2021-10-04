GiraffeNeck = class{
	
	init = function(self)

		self.position = {x = 0, y = 0, z = 1}
		self.size = {w = 26, h = 10}
		self.timer = 0
		self.label = 'neck'
		self.color = {255, 255, 255}
		self.uncullable = true
		self.prioritize = true
		self.wobble = {
			target = 0,
			progress = 0,
			amount = 0,
			angle = 0,
		}
		self.control = {
			targets = {
				head = {
					x = nil,
					y = nil,
				},
				body = {
					x = nil,
					y = nil,
				},
			},
			positions = {
				head = {
					x = nil,
					y = nil,
				},
				body = {
					x = nil,
					y = nil,
				},
			},
		}

		self.wiggle = 0
		self.segments = 12
		self.gulps = {}

		-- I should use a tell for this?
		observer:register('burst', function() self:gulp() end)

		-- spots

		local identity = {}
		local last = nil
		for i = 2, (self.segments - 1) do

			local n = (math.random() > 0.8) and (2) or (1)

			for j = 1, n do

				local valid
				local h, w
				while not valid do

					local roll = math.random(1, 4)
					local h = (roll % 2 > 0) and (0.25) or (0.75)
					local w = (roll > 2) and (0.25) or (0.75)
					valid = h ~= last
					if valid then
						last = h
						identity[i] = {h, w}
						identity[i] = roll
						break
					end

				end

			end
		end

		self.identity = identity
		self.spot = Graphic('giraffe_spot')
		self.polygons = {}

		-- don't need to remake this
		local texture = g["neck"]
		self.texture = texture

	end,

	update = function(self, dt)

		self.timer = self.timer + dt

		-- store some globals
		local sin = math.sin
		local cos = math.cos
		local atan2 = math.atan2
		local max = math.max
		local min = math.min
		local abs = math.abs
		local sqrt = math.sqrt
		local pow = math.pow
		local pi = math.pi

		-- head control point pendulum wobbling

		local target = self.wobble.target / (dt * 10)
		local progress = self.wobble.progress
		local amount = self.wobble.amount

		local elasticity = 16

		local progress = progress + (target - progress) * dt * elasticity
		amount = amount + (progress - amount) * dt * elasticity

		local angle = atan2(50, -amount / 5)

		self.wobble.progress = progress
		self.wobble.amount = amount
		self.wobble.angle = atan2(50, -amount / 5)

		-- bezier control points

		local anchor = self.anchor

		-- blend the pendulum angle with the head angle
		--angle = angle + (anchor.head.a % (math.pi*2))
		angle = angle + anchor.head.a

		-- solve for the head proximity ratio
		local proximity, threshold
		threshold = 600
		proximity = sqrt(pow(anchor.head.x - anchor.body.x, 2) + pow(anchor.head.y - anchor.body.y, 2))
		proximity = easing.inCubic(abs(clamp(proximity / threshold, 0, 1) - 1), 0, 1, 1)

		-- solve for the vertical and horizontal ratios
		local pitch, yaw
		pitch = easing.outCubic(clamp((anchor.head.y - anchor.body.y) / 85, 0, 1), 0, 1, 1) -- vertical ratio
		yaw = easing.outCubic(clamp((anchor.body.x - anchor.head.x + 50) / 100, 0, 1), 0, 1, 1) -- horizontal ratio

		proximity = proximity * yaw

		local weight
		weight = easing.inOutCubic(clamp((anchor.body.y - anchor.head.y - 200) / 400, 0, 1), 0, 1, 1)

		-- head control point
		angle = angle + (math.pi / 2) * (pitch) + (math.pi / 8) * (proximity)

		local length
		length = 150 + (50) * (proximity) + (200 * weight)

		-- body control point
		local theta
		theta = (angle / 2) - math.pi * (3 / 4) - (math.pi / 4) * (pitch * yaw)

		local magnitude
		magnitude = easing.linear(clamp(max(anchor.body.x - anchor.head.x, 0) / 900, 0, 1), 0, 1, 1)

		-- add to this if the head is far past the body
		magnitude = magnitude * (200 + (100 * pitch)) + (100) * (pitch + proximity)

		-- todo
		-- add wobbling based on "speed"

		local angular_wiggle = (sin(self.timer * pi * 4) * pi / 45) * self.wiggle
		local amplitude_wiggle = (sin(self.timer * pi * 4) * 0.05 ) * self.wiggle
		local idle_angular_wiggle = ((sin(self.timer * pi) - 1) * pi / 50) * abs(self.wiggle - 1)

		local pendulum_angle = angle + angular_wiggle + idle_angular_wiggle
		local pendulum_magnitude = length - (length * amplitude_wiggle)

		local root_magnitude = magnitude + (magnitude * amplitude_wiggle)
		local root_angle = theta - angular_wiggle - idle_angular_wiggle

		local targets = self.control.targets or {}

		targets['head'][1] = anchor.head.x + cos(pendulum_angle) * pendulum_magnitude
		targets['head'][2] = min(anchor.head.y + sin(pendulum_angle) * pendulum_magnitude, window.height - world.floor)

		targets['body'][1] = anchor.body.x + cos(root_angle) * root_magnitude
		targets['body'][2] = min(anchor.body.y + sin(root_angle) * root_magnitude - 1, window.height - world.floor - 13)

		-- ease targets to positions for buttery smooth transitions
		self.control.targets = targets

		local control, snappiness = self.control, 24

		-- I could add in the body speed here if I had a way to access it. that would get rid of some undesirably neck bends
		-- I should just set these immidiately without snapping on init

		local step = dt * snappiness

		local phx = control.positions.head.x or 0
		local phy = control.positions.head.y or 0

		local pbx = control.positions.body.x or 0
		local pby = control.positions.body.y or 0

		local chx, chy, cbx, cby

		if options.safemode then
			chx = targets.head[1]
			chy = targets.head[2]

			cbx = targets.body[1]
			cby = targets.body[2]
		else
			chx = phx + (targets.head[1] - phx) * step
			chy = phy + (targets.head[2] - phy) * step

			cbx = pbx + (targets.body[1] - pbx) * step
			cby = pby + (targets.body[2] - pby) * step
		end

		control.positions.head.x = (control.positions.head.x) and (chx) or (targets.head[1])
		control.positions.head.y = (control.positions.head.y) and (chy) or (targets.head[2])

		control.positions.body.x = (control.positions.body.x) and (cbx) or (targets.body[1])
		control.positions.body.y = (control.positions.body.y) and (cby) or (targets.body[2])

		local positions = self.control.positions

		local points = self.points or {}
		points[1] = anchor.head.x
		points[2] = anchor.head.y
		points[3] = positions.head.x
		points[4] = positions.head.y
		points[5] = positions.body.x
		points[6] = positions.body.y
		points[7] = anchor.body.x
		points[8] = anchor.body.y
		self.points = points

		-- neck segments and spots

		local curve, derivative
		curve = self.curve or love.math.newBezierCurve(points)
		if (curve) then
			for i = 1, #points, 2 do
				curve:setControlPoint((i + 1) / 2, points[i], points[i + 1])
			end

		end
		self.curve = curve

		-- I may need to get this every frame
		derivative = curve:getDerivative()

		local samples = self.samples or {}
		local n = self.segments

		for i = 0, n do

			local sample = samples[i + 1] or {}
			-- ease this to balance the segment density
			-- average the quadratic ease because it overcompensates
			local step = (easing.inQuad(i / n, 0, 1, 1) + (i / n)) * 0.5

			local x, y = curve:evaluate(step)
			local dx, dy = derivative:evaluate(step)
			local normal = atan2(dy, dx) + (pi / 2)

			sample[1] = x
			sample[2] = y
			sample[3] = normal
			samples[i + 1] = sample

		end

		self.samples = samples

		local polygons = self.polygons
		local spots = {}
		local girth = (self.size.w / 2)
		local identity = self.identity
		local base = self.color
		local br = (base[1] / 255)
		local bg = (base[2] / 255)
		local bb = (base[3] / 255)

		local fp = fracpoint


		local mesh = self.mesh or g["mesh"]
		local mesh_vertices = {}

		-- how can I reuse these tables?
		for i = #samples - 1, 1, -1 do

			local index = math.abs(i - #samples)

			local x1 = samples[i][1]
			local y1 = samples[i][2]
			local n1 = samples[i][3]

			local x2 = samples[i + 1][1]
			local y2 = samples[i + 1][2]
			local n2 = samples[i + 1][3]

			local ox1 = cos(n1) * girth
			local oy1 = sin(n1) * girth
			local ox2 = cos(n2) * girth
			local oy2 = sin(n2) * girth

			local v1 = x1 + ox1
			local v2 = y1 + oy1
			local v3 = x1 - ox1
			local v4 = y1 - oy1
			local v5 = x2 - ox2
			local v6 = y2 - oy2
			local v7 = x2 + ox2
			local v8 = y2 + oy2

			-- use these to set triangles in a mesh instead?
			local t = easing.inOutCubic(i / #samples, 0, 1, 1)
			local r = (255) * br
			local g = (255 - (255 - (215/255) * 255) * t) * bg
			local b = (255 - (255 - (100/140) * 255) * t) * bb

			local c1, c2, c3, c4 = 0, 0, 0, 0
			local spot = identity[i]
			local mapping = {
				{0, 0.5, 0, 0.5},
				{0.5, 1, 0, 0.5},
				{0.5, 1, 0.5, 1},
				{0, 0.5, 0.5, 1},
			}
			if spot then
				-- set the texture coords using mapping
				c1, c2, c3, c4 = unpack(mapping[spot])
			end

			local t1v1 = {v7, v8, c1, c3, r, g, b}
			local t1v2 = {v3, v4, c2, c4, r, g, b}
			local t1v3 = {v5, v6, c1, c4, r, g, b}
			local t2v1 = {v7, v8, c1, c3, r, g, b}
			local t2v2 = {v3, v4, c2, c4, r, g, b}
			local t2v3 = {v1, v2, c1, c4, r, g, b}

			if mesh then
				local start = math.abs(i - #samples) * 6 - 5
				mesh:setVertex(start + 5, v7, v8, c1, c3, r, g, b)
				mesh:setVertex(start + 4, v3, v4, c2, c4, r, g, b)
				mesh:setVertex(start + 3, v5, v6, c1, c4, r, g, b)
				mesh:setVertex(start + 2, v7, v8, c1, c3, r, g, b)
				mesh:setVertex(start + 1, v3, v4, c2, c4, r, g, b)
				mesh:setVertex(start + 0, v1, v2, c1, c4, r, g, b)
			else
				mesh_vertices[#mesh_vertices + 1] = t1v1
				mesh_vertices[#mesh_vertices + 1] = t1v2
				mesh_vertices[#mesh_vertices + 1] = t1v3
				mesh_vertices[#mesh_vertices + 1] = t2v1
				mesh_vertices[#mesh_vertices + 1] = t2v2
				mesh_vertices[#mesh_vertices + 1] = t2v3
			end

		end

		local texture = self.texture
		if mesh then
			self.mesh = mesh
		else
			local mesh = lg.newMesh(mesh_vertices, texture, 'triangles') 
			self.mesh = mesh
			g["mesh"] = mesh
		end
		--self.mesh = mesh or lg.newMesh(mesh_vertices, self.texture, 'triangles')

		local gulps = self.gulps
		for i,g in ipairs(gulps) do

			local gulp, progress

			gulp = gulps[i]
			gulp.elapsed = min(gulp.elapsed + dt, gulp.duration)

			if (gulp.elapsed < gulp.duration) then

				progress = clamp(easing.inOutCubic(gulp.elapsed / gulp.duration, 0, 1, 1), 0, 1)

				local x, y, dx, dy, normal, gradient

				x, y = curve:evaluate(progress)
				dx, dy = derivative:evaluate(progress)
				normal = atan2(dy, dx) + (pi / 2)

				-- this should match the neck segments, but they should probably use the variables for easy config
				gradient = 40 * progress

				local position, radius, color
				local offset = girth / (1.5)
				
				radius = clamp(1 - easing.inCubic(gulp.elapsed / gulp.duration, 0, 1, 1), 0, 1) * girth
				local r = (255) * br
				local g = (255 - gradient) * bg
				local b = (140 - gradient) * bb
				color = {r, g, b}
				position = {
					x = x - cos(normal) * offset,
					y = y - sin(normal) * offset,
				}

				gulp.radius = radius
				gulp.color = color
				gulp.position = position

				if options.player_growth then
					if gulp.elapsed / gulp.duration > 0.8 and (not gulp.grown) then
						observer:emit('grow')
						gulp.grown = true
					end
				end

			else
				table.remove(gulps, i)
			end

		end

	end,

	draw = function(self)

		local polygons = self.polygons
		local spots = self.spots
		local girth = (self.size.w / 2)

		-- draw body anchor
		-- could we do all of these circles as a mesh?
		--[[
		local base = self.color
		local br = base[1] / 255
		local bg = base[2] / 255
		local bb = base[3] / 255

		lg.setColor(255*br, 215*bg, 100*bb)
		lg.circle('fill', self.anchor.body.x, self.anchor.body.y, girth)

		

		lg.setColor(255*br, 255*bg, 140*bb)
		lg.circle('fill', self.anchor.head.x, self.anchor.head.y, girth)
		]]--

		local gulps = self.gulps

		for i = 1, #gulps do
			local gulp = gulps[i]
			local color = gulp.color
			lg.setColor(color)
			lg.circle('fill', gulp.position.x, gulp.position.y, gulp.radius)
		end

		local mesh = self.mesh
		lg.setColor(255, 255, 255)
		lg.draw(mesh)

	end,

	get = function(self)

		-- i might not need this?
		local properties = {
			position = self.position,
			size = self.size,
		}
		return properties
		
	end,

	set = function(self, anchor)
		self.wobble.target = (anchor and self.anchor) and ((anchor.head.x - anchor.body.x) - (self.anchor.head.x - self.anchor.body.x)) or (self.wobble.target)
		self.anchor = anchor
		self.position = anchor.body
	end,

	setColor = function(self, color)
		self.color = color
	end,

	setWiggle = function(self, n)
		self.wiggle = n
	end,

	gulp = function(self)
			
		local gulps, gulp
		gulps = self.gulps

		gulp = {
			position = {
				x = self.anchor.head.x,
				y = self.anchor.head.y,
			},
			color = {255, 0, 0},
			duration = 2,
			elapsed = 0,
			radius = 10,
		}

		table.insert(gulps, gulp)

	end,

}