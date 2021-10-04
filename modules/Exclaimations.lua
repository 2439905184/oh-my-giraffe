--[[
manages a little queue of strings and makes angular space for them...
this might be a little involved but it also appears above the center of focus
during gameplay (plus it could be used by lions)

random slight arc around point is best

]]--

Exclaimations = class{
	init = function(self)
		local stack = {}
		self.stack = stack
		self.font = fonts:add('bpreplay-bold.otf', 50)
	end,

	update = function(self, dt)
		local stack = self.stack
		for i, remark in ipairs(stack) do
			local delta = dt * remark.rate
			remark.timer = (remark.active) and math.min(remark.timer + delta, remark.duration) or math.max(remark.timer - delta, 0)
			if (remark.timer == remark.duration) and (remark.active) then
				remark.show = remark.show - dt
			end
			if (remark.show <= 0) and (remark.active) then
				remark.active = false
			end
			if (not remark.active) and (remark.timer <= 0) then
				table.remove(stack, i)
			end
		end
	end,

	draw = function(self, position)
		local x, y = position.x, position.y
		y = y - 40
		x = x - 15
		local stack = self.stack
		for i = 1, #stack do
			local remark = stack[i]
			local rx = x + remark.x
			local ry = y + remark.y
			local angle = remark.angle + (math.pi / 64) * math.sin(remark.timer * math.pi * 4)
			local stretch = easing.outElastic(remark.timer, 0, 1, 1)

			local font = self.font
			local s = remark.string
			local w = font:getWidth(s)
			local h = font:getHeight(s)

			lg.setColor(82, 142, 151)
			font:draw(s, rx, ry + 4, angle, stretch, stretch, w*0.5, h)

			lg.setColor(255, 255, 255)
			font:draw(s, rx, ry, angle, stretch, stretch, w*0.5, h)
		end

		return true
	end,

	add = function(self, s)

		local stack = self.stack
		local string = s or '!'
		local attempts = 10
		local threshold = 0.2
		local permitted, roll

		while not permitted do
			roll = (#stack > 0) and (math.random()) or (0.3 + 0.2 * math.random())
			local valid = true
			-- make sure roll is far enough away from others?
			for i = 1, #stack do
				if (valid) and (math.abs(stack[i].roll - roll) < threshold) then
					valid = false
					attempts = attempts - 1
					break
				end
			end
			if valid or attempts <= 0 then
				permitted = true
			end
		end

		if permitted then
			local angle = math.sin(roll - 0.5) * 0.5
			local x = roll * 30
			local y = math.sin(roll * math.pi) * -6
			local remark
			remark = {
				string = string,
				roll = roll,
				x = x,
				y = y,
				angle = angle,
				timer = 0,
				show = 0.1,
				duration = 0.6,
				rate = 1,
				active = true,
			}
			table.insert(stack, remark)
		end
	end,

	destroy = function(self)
		local stack = self.stack
		for i = 1, #stack do
			local remark = stack[i]
			remark.active = false
			remark.rate = 2
		end
	end,
}