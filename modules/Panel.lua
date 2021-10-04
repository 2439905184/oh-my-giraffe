Panel = class{
	
	draw = function(self)

		local state = self.state
		local down = (state == 'down')

		local position = self.position
		local x = position.x
		local y = position.y

		local scale = self.scale
		local alpha = self.alpha

		-- compute size in update loop
		local size = self.size
		local w = size.w * scale
		local h = size.h * scale

		local inset = 5 * scale
		local depress = 3 * scale
		local depth = 10 * scale

		local oy = (down) and (depress) or (0)
		local ox = 0
		local extrude = (state == 'down') and (depth - depress) or (depth)

		-- build the colors
		local r, g, b
		r = self.color[1]
		g = self.color[2]
		b = self.color[3]

		local color = (down) and {r-30, g-30, b-30, alpha} or {r, g, b, alpha}
		local color_shadow = (down) and {r-125, g-125, b-125, alpha} or {r-85, g-85, b-85, alpha}
		local color_shadow_darker = (down) and {r-145, g-145, b-145, alpha} or {r-105, g-105, b-105, alpha}

		local nx, ny
		nx = x - (w/2) + ox
		ny = y - (h/2) + oy

		local taller = {'fill', nx + (inset), ny, w - (inset*2), h}
		local wider = {'fill', nx, ny + (inset), w, h - (inset*2)}
		local taller_shadow = {'fill', nx + (inset), ny + extrude, w - (inset*2), h}
		local wider_shadow = {'fill', nx, ny + (inset) + extrude, w, h - (inset*2)}

		-- draw the panel itself
		-- panel shadow
		lg.setColor(color_shadow)
		lg.rectangle(unpack(wider_shadow))
		lg.setColor(color_shadow_darker)
		lg.rectangle(unpack(taller_shadow))

		-- panel body
		lg.setColor(color)
		lg.rectangle(unpack(wider))
		lg.rectangle(unpack(taller))
	end,

	set = function(self, state)
		for key, entry in pairs(state) do
			self[key] = entry
		end
	end,
	
}