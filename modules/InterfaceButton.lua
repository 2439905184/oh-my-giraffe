InterfaceButton = class{
	
	init = function(self, label, callback, output, fixed, destroy)
		self.label = label
		self.callback = callback
		self.output = output
		self.fixed = fixed
		self.destroy = destroy
		self.destroyed = false
	end,

	update = function(self, dt)

	end,

	draw = function(self)

		--lg.setLineWidth(1)

		if (settings.menu or self.fixed) and (not self.destroyed) then

			local label, w, h, font
			
			label = self.label
			w = self.size.w
			h = self.size.h

			if self.output then
				label = label .. ': ' .. tostring(self.output())
			end

			font = lg.getFont()
			self.size.w = font:getWidth(label) + self.padding.x * 2
			self.size.h = font:getHeight(label) + self.padding.y * 2

			-- draw the backdrop
			lg.setColor(100, 100, 100, 255)
			lg.rectangle('fill', self.position.x, self.position.y, w, h)

			-- draw the label
			lg.setColor(255, 255, 255)
			lg.print(label, self.position.x + self.padding.x, self.position.y + self.padding.y)

		end

		--lg.setLineWidth(4)

	end,

	mousepressed = function(self, x, y, button)

		if settings.menu or self.fixed then

			-- return something if x, y, colides
			if not ((x < self.position.x)
					or (x > self.position.x + self.size.w)
					or (y < self.position.y)
					or (y > self.position.y + self.size.h)) then

				if self.callback then
					self.callback()
					if self.destroy then
						self.destroyed = true
					end
				end

			end

		end

	end,

	set = function(self, x, y, margin)

		local font, w, h, padding

		self.position = {
			x = x + margin,
			y = y + margin,
		}

		font = lg.getFont()
		w = font:getWidth(self.label)
		h = font:getHeight(self.label)
		padding = 75

		self.padding = {
			x = padding / 4,
			y = padding / 4,
		}

		self.size = {
			w = w + self.padding.x * 2,
			h = h + self.padding.y * 2,
		}

	end,

	get = function(self)

	-- return bottom
		return self.position.y + self.size.h

	end,

	destroy = function(self)

	end,

}