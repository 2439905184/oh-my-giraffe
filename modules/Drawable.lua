local bound = get_bound

Drawable = class{

	init = function(self, object, key)

		self.asset = object
		self.key = key

		local bound = get_bound(object)

		self.properties = object
		self.bound = bound
		self.projected = nil
		self.destroyed = false

	end,

	register = function(self, key)

		-- init event registrations
		if self.asset.register then
			self.asset:register(key)
		end

	end,

	update = function(self, dt)

		local object = self.asset
		object:update(dt)
		local dynamic = object.rotates
		if dynamic then
			self.bound = bound(object)
		end

	end,

	draw = function(self, batch)

		local object = self.asset
		local projection = self.projected
		
		object:draw(projection, batch)

		if settings.outlines then

			local bound = self.bound
			local rectangle = bound.rectangle
			local x = projection.x + rectangle.left
			local y = projection.y + rectangle.top
			local w = rectangle.right - rectangle.left
			local h = rectangle.bottom - rectangle.top

			local label = self.asset.label
			local key = self.asset.key

			lg.setColor(255, 255, 255)
			lg.setLineWidth(1)
			lg.rectangle('line', x, y, w, h)

			fonts:draw('inconsolata.otf', 14, tostring(key), x + 10, y + 10)

		end

	end,

	project = function(self, screenspace, properties)

		local position = self.asset.position
		local depth = (position) and (position.z) or (1)

		local projected

		if (depth > 0) and (position) then
			local inverse = (1 / depth)
			local x = position.x + (screenspace[1] - screenspace[1] * inverse)
			local y = position.y + (screenspace[2] - screenspace[2] * inverse)
			projected = {
				x = x,
				y = y,
			}
		else
			print('attempted to solve projection for a drawable without a position')
		end

		return projected

	end,

	projection = function(self, screenspace)

		local object, bound = self.asset, self.bound
		local rectangle = bound.rectangle
		local projection = self:project(screenspace, object)
		self.projected = projection

		local culled
		if (projection) and (object.draw) then
			-- normalize the bounding rectangle to the world coords and then do a
			-- simple culling check of object's bound and the screenspace in world space
			culled = (rectangle.right + projection.x < screenspace[1])
				or (rectangle.left + projection.x > screenspace[1] + window.width)
				or (rectangle.top + projection.y > screenspace[2] + window.height)
				or (rectangle.bottom + projection.y < screenspace[2])

			local uncullable = object.uncullable
			culled = culled and not uncullable

		end

		local visible = (not culled or not settings.culling) and object.draw

		return visible

	end,

	get = function(self)

		local asset = self.asset
		local bound = self.bound

		return asset, bound

	end,

	collide = function(self, ...)

		local message
		local asset = self.asset
		
		if (asset.collide) then
			message = asset:collide(...)
		end

		return message
	end,

	tell = function(self, message, ...)
		if (self.asset.tell) then
			self.asset:tell(message, ...)
		end
	end,

	-- call destroy method before removing it
	destroy = function(self)
		if (self.asset.destroy) then
			local graphics = self.asset:destroy()
		end
		self.asset = nil
		self.projected = nil
		self.bound = nil
		self.destroyed = true
	end,



}
