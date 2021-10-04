NotificationManager = class{
	init = function(self)

		local notes = {}
		self.notes = notes

		observer:register('notify', function(message, graphic, scale) self:add(Notification, duration, message, graphic, scale) end)
		observer:register('warn', function(duration) self:add(Disruption, duration) end)
		observer:register('alert', function(duration, message) self:add(Warning, duration, message) end)
		observer:register('dismiss', function() self:dismiss() end)
		
	end,

	update = function(self, dt)
		local notes = self.notes
		for i,note in ipairs(notes) do
			note:update(dt)
			if not note.active then
				note = nil
				table.remove(notes, i)
			end
		end
	end,

	draw = function(self, batch)
		local notes = self.notes
		for i = 1, #notes do
			notes[i]:draw(batch)
		end
	end,

	add = function(self, handler, duration, message, graphic, scale)
		local notes = self.notes
		local font = self.font
		local duration = duration or 2.4
		local message = message or 'good night'
		local note = handler(duration, message, graphic, scale)
		notes[#notes + 1] = note
	end,

	setTransition = function(self, n)
	end,

	dismiss = function(self)
		local notes = self.notes
		for i,note in ipairs(notes) do
			if note.type == 'warning' then
				note:dismiss()
			end
		end
	end,
}