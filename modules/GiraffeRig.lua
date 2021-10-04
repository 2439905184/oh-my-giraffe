Giraffe = class{
	
	init = function(self, body, head, neck)

		self.head = head
		self.body = body
		self.neck = neck

		-- I shouldn't really need this flag here, but it doesn't matter much
		self.flipped = false

		self.position = {x = 0, y = 0, z = 1}
		self.size = {w = 0, h = 0}
		self.label = 'rig'

	end,

	update = function(self, dt)

		local head, body, neck

		head = self.head
		body = self.body
		neck = self.neck
		
		local anchors = {
			head = head:attach(),
			body = body:attach(),
		}

		neck:set(anchors)

		local color = body.color
		head:setColor(color)
		neck:setColor(color)
		
		--self.anchors = anchors

	end,

	draw = function(self)
	end,

	jolt = function(self)
		self.body:jolt()
	end,

	jump = function(self)
		self.body:jump()
	end,

	wake = function(self)
	end,

	sleep = function(self)
	end,

	flip = function(self)
		if (not self.flipped) then
			self.body:flip()
			self.head:flip()
			self.flipped = true
			observer:emit('lock')
			observer:emit('jiggle')
			sound:emit('bounce', {pitch = {0.6, 0.8}})
		end
	end,

	setWiggle = function(self, n)
		if not options.safemode then
			self.neck:setWiggle(n)
			self.head:setWiggle(n)
			self.body:setWiggle(n)
		end
	end,

}

