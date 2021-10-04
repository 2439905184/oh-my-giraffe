local draw = love.graphics.draw

-- could I recycling graphics into here?
local pool = {}

Graphic = class{

	init = function(self, path, preselected)

		local group = templates.assets.quads[path]
		if group then

			-- check if we have this in the pool?

			local key = preselected or wchoose(group.variants)
			if key then

				local selected = group.variants[key]
				if selected then

					local atlas = g.atlas
					self.atlas = atlas
					self.variant = key

					local quad = selected.static
					local _, _, w, h  = quad:getViewport()
					local frames = 1
					if (selected.frames ~= nil) then

						frames = selected.frames
						local interval = selected.interval

						self.animated = true
						self.animation = Animation(atlas, quad, frames, interval)

					end

					self.quad = quad
					self.name = path
					self.size = {
						w = w / frames,
						h = h,
					}

				else error('entry ' .. key .. ' of ' .. path .. ' does not exist.') end
			else error('unable to select asset for ' .. path .. ': key not found.')	end
		else error(path .. ' does not exist in assets.lua')	end

	end,

	draw = function(self, ...)

		if self.animated then
			self.animation:draw(...)
		else
			local atlas = self.atlas
			local quad = self.quad
			draw(atlas, quad, ...)
		end

	end,

	add = function(self, batch, ...)

		if self.animated then
			self.animation:add(batch, ...)
		else
			local quad = self.quad
			batch:add(quad, ...)
		end
		
	end,

	update = function(self, dt)
		if self.animated then
			self.animation:update(dt)
		end
	end,

	get = function(self)

		return {
			sprite = self.quad,
			size = self.size,
			name = self.name,
			variant = self.variant,
		}

	end,

	getWidth = function(self)
		return self.size.w
	end,

	getHeight = function(self)
		return self.size.h
	end,

	getSize = function(self)
		return self.size.w, self.size.h
	end,

	getFrame = function(self)
		if self.animated then
			return self.animation:getFrame()
		end
	end,

	getColor = function(self)
		local quad = self.quad
		local atlas = self.atlas
		local x, y, w, h = quad:getViewport()
		local cx = x + math.floor(w*0.5)
		local cy = y + math.floor(h*0.5)
		local r, g, b = atlas:getData():getPixel(cx, cy)
		return r, g, b
	end,

	seek = function(self, n)
		if self.animated then
			self.animation:seek(n)
		end
	end,

	setRate = function(self, n)
		if self.animated then
			self.animation:setInterval(n)
		end
	end,
}
