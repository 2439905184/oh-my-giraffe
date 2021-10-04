local draw = love.graphics.draw

Animation = class{
	init = function(self, atlas, quad, frames, interval)

		local aw, ah = atlas:getWidth(), atlas:getHeight()
		local x, y, w, h = quad:getViewport()
		local frames = frames or 1
		local interval = interval or 0.25

		local clock = 0
		local frame = 1
		local fw = w / frames
		local fh = h
		local quads = {}
		for i = 1, frames do
			local ox = (i - 1) * fw
			local panel = lg.newQuad(x + ox, y, fw, fh, aw, ah)
			quads[#quads + 1] = panel
		end

		self.atlas = atlas
		self.quad = quad
		self.quads = quads
		self.frames = frames
		self.frame = frame
		self.clock = clock
		self.interval = interval
		self.speed = 1


	end,

	update = function(self, dt)
		local dt = dt * self.speed
		local max = self.interval
		self.clock = math.min(self.clock + dt, max)
		if self.clock == max then
			self.frame = self.frame % self.frames + 1
			self.clock = 0
		end
	end,

	draw = function(self, ...)
		local atlas = self.atlas
		local quads = self.quads
		local frame = self.frame
		local quad = quads[frame]
		draw(atlas, quad, ...)
	end,

	add = function(self, batch, ...)
		local quads = self.quads
		local frame = self.frame
		local quad = quads[frame]
		batch:add(quad, ...)
	end,

	seek = function(self, n)
		-- set current frame to n
		-- reset timer
		self.frame = n or self.frame
		self.clock = 0
	end,

	setInterval = function(self, n)
		self.speed = n or self.speed
	end,

	getFrame = function(self)
		return self.frame
	end,
}