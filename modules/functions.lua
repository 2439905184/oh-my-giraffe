-- sorts by key value in reverse
function spairs(t, order)
	-- collect the keys
	local keys = {}
	for k in pairs(t) do keys[#keys+1] = k end

	-- if order function given, sort by it by passing the table and keys a, b,
	-- otherwise just sort the keys 
	if order then
		table.sort(keys, function(a,b) return order(t, a, b) end)
	else
		table.sort(keys)
	end

	-- return the iterator function
	local i = #keys+1
	return function()
		i = i - 1
		if keys[i] then
			return keys[i], t[keys[i]]
		end
	end
end

-- weighted choose
-- accepts a table of elements with a numerical entry.weight and returns a choice
function wchoose(options)

	if options then

		local sum, atlas = 0, {}
		for k, entry in ipairs(options) do

			local weight = (entry.weight) or (1)
			sum = sum + weight
			table.insert(atlas, {
					key = k,
					weight = sum,
				})

		end

		local random = math.random()
		local bid = sum * random
		local key

		for k, entry in ipairs(atlas) do
			if bid <= entry.weight then
				key = entry.key
				break
			end
		end

		return key

	else
		print('attempted to index a nil set of options')
	end

end

function midpoint(primary, secondary)

	local middle

	if (type(primary) == 'table' and type(secondary) == 'table') then

		middle = {
				x = (primary.x + secondary.x) / 2,
				y = (primary.y + secondary.y) / 2
			}

	else
		middle = (primary + secondary) / 2
	end

	return middle

end

function fracpoint(p1x, p1y, p2x, p2y, n)

	local dx = p2x - p1x
	local dy = p2y - p1y

	local point = {
		p1x + dx * n,
		p1y + dy * n,
	}

	return point
end


function boverlap(primary, secondary, dt)

	if primary and secondary then

		local collider, collidable

		local seperated

		-- can these be optimized?
		seperated = (primary.left > secondary.right)
			or (primary.right < secondary.left)
			or (primary.top > secondary.bottom)
			or (primary.bottom < secondary.top)

		-- if they overlap, why not calculate the intersection rectangle
		if not seperated then

			local centers, intersection, bump

			-- if I reduce table creation here that would be excellent

			centers = {
				{
					(primary.left + primary.right) * 0.5,
					(primary.top + primary.bottom) * 0.5,
				},
				{
					(secondary.left + secondary.right) * 0.5,
					(secondary.top + secondary.bottom) * 0.5,
				},
			}

			-- use 'collider' and 'collidable'
			bump = {
				subject = primary,
				emitted = secondary,
				centers = centers,
			}

			local max, min = math.max, math.min

			intersection = {
				left = max(primary.left, secondary.left),
				right = min(primary.right, secondary.right),
				top = max(primary.top, secondary.top),
				bottom = min(primary.bottom, secondary.bottom),
			}

			return not seperated, intersection, bump

		end

	end

end

-- I need to figure out how i'll add things to this instead
local pool = {}

function recycle(system)
	pool[#pool + 1] = system
end

function psystem(color, size, quantity)

	local image = colorToImg(color)
	local system
	if #pool > 0 then
		system = table.remove(pool, 1)
		system:setTexture(image)
		system:setBufferSize(quantity)
	else
		system = love.graphics.newParticleSystem(image, quantity)
	end

	system:setEmissionRate(quantity)
	system:setSpeed(150, 180)
	system:setSizes(size, size)
	local from = {255, 255, 255, 255}
	local to = {255, 255, 255, 0}
	system:setColors(
		from[1], from[2], from[3], from[4],
		from[1], from[2], from[3], from[4],
		from[1], from[2], from[3], from[4],
		to[1], to[2], to[3], to[4])
	system:setEmitterLifetime(0.2)
	system:setParticleLifetime(0.3)
	system:setDirection(0)
	system:setSpread(math.pi * 2)
	system:setSpin(math.pi / 2)
	system:setLinearAcceleration(0, 500, 0, 900)
	system:stop()

	return system

end

function sparkles(quantity, size)

	local size = size or 6
	local image = colorToImg({155, 255, 155, 170})

	local system
	if #pool > 0 then
		system = table.remove(pool, 1)
		system:setTexture(image)
		system:setBufferSize(quantity)
	else
		system = love.graphics.newParticleSystem(image, quantity)
	end

	system:setEmissionRate(quantity)
	system:setSpeed(150, 200)
	system:setSizes(size, size)
	local color1 = {255, 255, 255, 255}
	local color2 = {255, 255, 255, 155}
	system:setColors(
		color1[1], color1[2], color1[3], color1[4],
		color2[1], color2[2], color2[3], color2[4]
		)
	system:setEmitterLifetime(0.1)
	system:setParticleLifetime(0.4)
	system:setDirection(0)
	system:setSpread(math.pi * 2)
	system:setSpin(math.pi / 2)
	--system:setLinearAcceleration(0, 500, 0, 900)
	system:stop()

	return system

end

local memoized = {}
function colorToImg(color)
	local r, g, b, a = color[1], color[2], color[3], color[4]
	r = r or 255
	g = g or 255
	b = b or 255
	a = a or 255
	local serial = ("%s%s%s%s"):format(r, g, b, a)
	if memoized[serial] then
		return memoized[serial]
	elseif color ~= nil then
        local data = love.image.newImageData(1, 1)
        local r = clamp(color[1], 0, 255)
        local g = clamp(color[2], 0, 255)
        local b = clamp(color[3], 0, 255)
        local alpha = 255
        if color[4] ~= nil then
            alpha = color[4]
        end
        data:setPixel(0, 0, r, g, b, alpha)
        local img = love.graphics.newImage(data)
        memoized[serial] = img
        return img
    end
end

function clamp(val, l, u)
	local min, max = math.min, math.max
	return (l and u) and min(max(val, l), u) or (val)
end

-- get the length of a table
function table.length(t)
	local c = 0
	for k,v in pairs(t) do
		c = c+1
	end
	return c
end

function comma_value(n) -- credit http://richard.warburton.it
	local num = tostring(n)
	if num then
		local left,num,right = string.match(num,'^([^%d]*%d)(%d*)(.-)$')
		local formatted = left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
		return formatted
	end
	return num
end

function round(num, idp)
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

function rounded_rectangle(x, y, w, h, r, n)
	n = n or 20  -- Number of points in the polygon.
	if n % 4 > 0 then n = n + 4 - (n % 4) end  -- Include multiples of 90 degrees.
	local pts, c, d, i = {}, {x + w / 2, y + h / 2}, {w / 2 - r, r - h / 2}, 0
	while i < n do
		local a = i * 2 * math.pi / n
		local p = {r * math.cos(a), r * math.sin(a)}
		for j = 1, 2 do
			table.insert(pts, c[j] + d[j] + p[j])
			if p[j] * d[j] <= 0 and (p[1] * d[2] < p[2] * d[1]) then
				d[j] = d[j] * -1
				i = i - 1
			end
		end
		i = i + 1
	end
	return pts
end

function CrossingsMultiplyTest(pgon, tx, ty)
    local i, yflag0, yflag1, inside_flag
    local vtx0, vtx1
    
    local numverts = #pgon

    vtx0 = pgon[numverts]
    vtx1 = pgon[1]

    -- get test bit for above/below X axis
    yflag0 = ( vtx0.y >= ty )
    inside_flag = false
    
    for i=2,numverts+1 do
        yflag1 = ( vtx1.y >= ty )
    
        --[[ Check if endpoints straddle (are on opposite sides) of X axis
         * (i.e. the Y's differ); if so, +X ray could intersect this edge.
         * The old test also checked whether the endpoints are both to the
         * right or to the left of the test point.  However, given the faster
         * intersection point computation used below, this test was found to
         * be a break-even proposition for most polygons and a loser for
         * triangles (where 50% or more of the edges which survive this test
         * will cross quadrants and so have to have the X intersection computed
         * anyway).  I credit Joseph Samosky with inspiring me to try dropping
         * the "both left or both right" part of my code.
         --]]
        if ( yflag0 ~= yflag1 ) then
            --[[ Check intersection of pgon segment with +X ray.
             * Note if >= point's X; if so, the ray hits it.
             * The division operation is avoided for the ">=" test by checking
             * the sign of the first vertex wrto the test point; idea inspired
             * by Joseph Samosky's and Mark Haigh-Hutchinson's different
             * polygon inclusion tests.
             --]]
            if ( ((vtx1.y - ty) * (vtx0.x - vtx1.x) >= (vtx1.x - tx) * (vtx0.y - vtx1.y)) == yflag1 ) then
                inside_flag =  not inside_flag
            end
        end

        -- Move to the next pair of vertices, retaining info as possible.
        yflag0  = yflag1
        vtx0    = vtx1
        vtx1    = pgon[i]
    end

    return  inside_flag
end

function get_bound(properties)

	-- todo
	-- add a better name for this
	-- + optimize this for non angled objects
	-- split scale in scale.x and scale.y (I probably don't want to do this for now since I can't imagine a use case besides weird easing effects)
	-- replace instances of this giant list of assignments whereever possible

	local position, size, angle, offset, scale, shear, corners, points

	position = (properties.position) and (properties.position) or ({x = 0, y = 0, z = 1})
	size = (properties.size) and (properties.size) or {w = 0, h = 0}
	angle = (properties.angle) and (properties.angle) or (0)
	offset = (properties.offset) and (properties.offset) or {x = 0, y = 0}
	scale = (properties.scale) and (properties.scale) or (1)
	shear = (properties.shear) and (properties.shear) or {x = 0, y = 0}

	local ox, oy, w, h

	ox = -offset.x
	oy = -offset.y
	w = size.w
	h = size.h

	local sin, cos
	sin = math.sin(angle)
	cos = math.cos(angle)

	-- only bother with rotating the vectors if there's actual rotation!
	if (angle ~= 0) then

		corners = {
			{(ox)*cos - (oy)*sin, (ox)*sin + (oy)*cos},
			{(w + ox)*cos - (oy)*sin, (w + ox)*sin + (oy)*cos},
			{(w + ox)*cos - (h + oy)*sin, (w + ox)*sin + (h + oy)*cos},
			{(ox)*cos - (h + oy)*sin, (ox)*sin + (h + oy)*cos},
		}

	else

		corners = {
			{ox, oy},
			{w + ox, oy},
			{w + ox, h + oy},
			{ox, h + oy},
		}

	end

	points = {}

	local rectangle, left, right, top, bottom, bound, min, max
	max = math.max
	min = math.min

	for i = 1, (#corners) do

		points[#points + 1] = corners[i][1] * scale
		points[#points + 1] = corners[i][2] * scale

		left = (left) and min(left, corners[i][1]) or (corners[i][1])
		right = (right) and max(right, corners[i][1]) or (corners[i][1])
		top = (top) and min(top, corners[i][2]) or (corners[i][2])
		bottom = (bottom) and max(bottom, corners[i][2]) or (corners[i][2])

	end

	rectangle = {
		left = left * scale,
		right = right * scale,
		top = top * scale,
		bottom = bottom * scale,
	}

	bound = {
		points = points,
		vectors = corners,
		rectangle = rectangle
	}

	return bound

end