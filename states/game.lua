game = {}

local active, stack, scene, ui, menu, tasks

function game:enter(self)

	math.randomseed(os.time())
	game:config()

	-- set world parameters (this doesn't really belong here)
	-- global!

	world = {
		floor = 80,
		color = {255, 255, 255},
		sky = {0, 0, 0},
	}

	lg.setBackgroundColor(options.background)

	-- clear previous signal registrations
	signals.clear_pattern('.*')

    -- load a list of fonts here so that no lag is caused during runtime

    fonts = FontManager('assets/fonts/')
    fonts:batch{
        {'bpreplay-bold.otf', 34},
        {'bpreplay-bold.otf', 50},
        {'bpreplay-bold.otf', 40},
        {'bpreplay-bold.otf', 50, window.interface},
        {'bpreplay-bold.otf', 62, window.interface},
        {'bpreplay-bold.otf', 72, window.interface},
        {'bpreplay-bold.otf', 81, window.interface},
        {'bpreplay-bold.otf', 44, window.interface},
        {'fontawesome.otf', 43, window.interface},
    }

    local atlas = lg.newImage('assets/images/atlas.png')
	local batch = lg.newSpriteBatch(atlas, 400, 'stream')
	g.atlas = atlas
	g.batch = batch
	g.pixel = lg.newImage('assets/images/pixel.png')
	g.neck = lg.newImage('assets/images/mesh.png')
	g.spot = lg.newImage('assets/images/spot.png')
	
	-- game state bools
	paused = false
	focused = true

	tasks = {}

	audio = AudioManager()
	music = MusicManager()
	menu = MenuManager()

	-- check if omg.dat exists
	-- and if it does we want to use it as a fallback
	-- until we have leaderboards populated
	analytics = Analytics()

	leaderboard = Leaderboard()

	-- register signals for controlling game state
	signals.register('resume', function() game:resume() end)
	signals.register('pause', function() game:pause() end)
	signals.register('toggle', function() game:toggle() end)
	signals.register('start', function() game:start() end)
	signals.register('retry', function() game:retry() end)
	signals.register('restart', function() game:restart() end)
	signals.register('destroy', function(callback) game:destroy(callback) end)
	signals.register('create', function() game:create() end)
	signals.register('exit', function() game:exit() end)
	signals.register('quit', function() le.quit() end)
	signals.register('flip_orientation', function() window.flipped = not window.flipped end)
	signals.register('vsync', function() game:vsync() end)
	signals.register('metrics', function() options.metrics = not options.metrics end)
	signals.register('erase', function() save:commit(0) end)
	signals.register('fullscreen', function()  game:fullscreen() end)
	signals.register('reset_leaderboard', function() leaderboard:reset() end)
	signals.register('delay', function(time, callback)
		local task = {
			timer = time,
			callback = callback,
		}
		tasks[#tasks + 1] = task
	end)

	stack = {}

	-- create new scene and add it to the stack
	local task = {
		timer = 0.3,
		callback = function()
			local scene = stack[active]
			if scene and (not scene.started) then
				signals.emit('switch', 'root')
			end
		end
	}
	tasks[#tasks + 1] = task

	local task = {
		timer = 1,
		callback = function()
			analytics:authenticate()
		end
	}
	tasks[#tasks + 1] = task

	game:create()

end

function game:restart(callback)
   game:resume()
   local scene = stack[active]
   scene:retry(false)
end

function game:start()
	game:propogate('start')
end

function game:retry()
	local scene = stack[active]
	scene:retry(true)
end

-- create a new scene and push it to the top of the stack
function game:create(delay)
	paused = false
	stack = stack or {}
	local scene = SceneManager()
	stack[#stack + 1] = scene
	active = #stack
end

function game:exit(callback)
	local scene = stack[active]
	if scene then
		scene:exit(function() signals.emit('destroy', callback) end)
	end
end

-- destroy the last scene on the stack
function game:destroy(callback)
	local skip
	if callback then
		skip = true
	end
	stack[#stack] = SceneManager(skip)
	paused = false
end

-- switch the game scene
function game:switch(n)
	local scene = stack[n]
	if scene then
		active = n
	end
end

function game:update(dt)

	local rate = 1
	if (settings.slowmo) and (not paused) then
		rate = (1/5)
	end

	game:propogate('update', dt*rate, dt)
	menu:update(dt)
	music:update(dt)
	audio:update(dt)

	window.uptime = window.uptime + dt

	for i,task in ipairs(tasks) do
		task.timer = math.max(task.timer - dt, 0)
		if task.timer == 0 then
			task.callback()
			table.remove(tasks, i)
		end
	end

	if options.loader then
		if loading > 0 then
			loading = loading - dt
			if loading <= 0 and not active then
				loading = 0
				if options.loader then
					signals.emit('switch', 'root')
				end
				game:create()
			end
		elseif not active then
			game:create()
		end
	end

	analytics:update(dt)

end

function game:draw()

	local scene = stack[active]
	local ui = scene.ui

	scene:draw()
	menu:draw()
	ui:draw()

end

function game:toggle()
	if paused then
		game:resume()
	else
		game:pause()
	end
end

function game:pause()
	local scene = stack[active]
	if scene then
		if scene.active then
			paused = true
			signals.emit('switch', 'pause')
		end
		music:pause()
		scene:mute()
	end
end

function game:resume()
	local scene = stack[active]
	if scene then
		if scene.started then
			paused = false
			signals.emit('switch', 'close')
		end
		music:resume()
		scene:unmute()
	end
end


-- TODO make this mute audio correctly
function game:focus(f)

	focused = f

	if (not focused) then
		music:pause()
		if (not paused) then
			game:pause()
			local scene = stack[active]
			if scene then
				scene:mute()
			end
		end
		audio:mute()
	end

	if (focused) then
		local scene = stack[active]
		if scene then
			if (not paused) then
				scene:unmute()
				music:resume()
			end
		end
		audio:unmute()
	end

end

function game:visible(v)

	visible = v

	if (not visible) then

		if (not paused) then
			game:pause()
		end

		audio:mute()
		music:pause()

		local scene = stack[active]
		if scene then
			scene:mute()
		end

	end
end

-- I would if I can do my axis inversion here?
function game:touchpressed(id, x, y, pressure)

	x = (window.width * x)
	y = (window.height * y)

	if window.flipped then
		local w, h = window.width, window.height
		x = math.abs(x - w)
		y = math.abs(y - h)
	end
	
	game:propogate('touchpressed', id, x, y, pressure)
	menu:touchpressed(id, x, y, pressure)

end

function game:touchreleased(id, x, y, pressure)

	x = (window.width * x)
	y = (window.height * y)

	if window.flipped then
		local w, h = window.width, window.height
		x = math.abs(x - w)
		y = math.abs(y - h)
	end

	game:propogate('touchreleased', id, x, y, pressure)
	menu:touchpressed(id, x, y, pressure)

end

function game:touchmoved(id, x, y, pressure)

	game:propogate('touchmoved', id, x, y, pressure)

end

-- pass the input callbacks along
function game:mousepressed(x, y, button)

	if window.flipped then
		local w, h = lg.getWidth(), lg.getHeight()
		x = math.abs(x - w)
		y = math.abs(y - h)
	end

	game:propogate('mousepressed', x, y, button)
	menu:mousepressed(x, y, button)

end

function game:mousereleased(x, y, button)

	if window.flipped then
		local w, h = lg.getWidth(), lg.getHeight()
		x = math.abs(x - w)
		y = math.abs(y - h)
	end

	game:propogate('mousereleased', x, y, button)
	menu:mousereleased(x, y, button)

end

function game:keypressed(key, code)
	--game:propogate('keypressed', key, code)
	--menu:keypressed(key, code)
	--audio:keypressed(key, code)
end

function game:keyreleased(key, code)
	--menu:keyreleased(key, code)
end

-- call a function on the active scene
function game:propogate(method, ...)
	if active then
		local scene = stack[active]
		if scene then
			scene[method](scene, ...)
		end
	end
end

function game:fullscreen()
	local width, height, flags = lw.getMode()
	local w = lg.getWidth()
	local h = lg.getHeight()
	if flags.fullscreen then
		lw.setMode(width, height, {fullscreen = not flags.fullscreen})
	else
		lw.setMode(w, h, {fullscreen = not flags.fullscreen})
	end
end

function game:vsync()
	local width, height, flags = lw.getMode()
	lw.setMode(width, height, {vsync = not flags.vsync})
end

function game:resize(w, h)
	game:config(w, h, density)
end

function game:config(w, h, density)

	local w = w or lg.getWidth()
	local h = h or lg.getHeight()
	local density = density or lw.getPixelScale()

	-- using w, h, and scale, find the correct point in config

	-- return the nearest numerical key in a table
	local function nearest(table, value)

		-- return early if we were not passed a valid value to search for
		local value = tonumber(value)
		if not value or type(table) ~= 'table' then
			return
		end

		-- if there's an exact match there's no need to continue
		if table[value] ~= nil then
			return table[value], value
		end

		-- sort the keys
		local keys = {}
		for key,_ in spairs(table) do
			-- ignore non-numerical keys
			if tonumber(key) then
				keys[#keys + 1] = key
			end
		end

		-- default to returning the lowest numerical result
		local result = keys[#keys]

		-- return the first key that is equal to or smaller
		for _,key in pairs(keys) do
			if value >= key then
				result = key
				break
			end
		end

		return table[result], result

	end

	local device_name = ('Device(%s,%s,%s,%s)'):format(love._os, w, h, density)
	local profile, profile_index = nearest(config.devices, density)
	local profile_name = ('Profile(%s'):format(profile_index)

	-- start with the defaults found in there
	local interface_scaling = profile and profile.defaults.interface or 1
	local world_scaling = profile and profile.defaults.world or 1

	local width_profile, width_index = nearest(profile.width, w)
	if width_profile then
		local profile_name = profile_name .. ',' .. width_index
		interface_scaling = width_profile.interface and interface_scaling * width_profile.interface or interface_scaling
		world_scaling = width_profile.world and world_scaling * width_profile.world or world_scaling
		local height_profile, height_index = nearest(width_profile.height, h)
		if height_profile then
			local profile_name = profile_name .. ',' .. height_index
			interface_scaling = height_profile.interface and interface_scaling * height_profile.interface or interface_scaling
			world_scaling = height_profile.world and world_scaling * height_profile.world or world_scaling
		end
	end

	profile_name = profile_name .. ')'

	-- maintain proportions using a base width of 1024
	local interface = options.interface_scaling * interface_scaling
	local scaling = options.world_scaling * (w / 1024) * world_scaling

	options.interface_scaling = interface

	window = {
		version = "1.1.0",
		width = w * (1 / scaling),
		height = h * (1 / scaling),
		padding = 64,
		uptime = 0,

		-- these kind of belong in another global...
		profile = profile_name,
		device = device_name,
		density = density,
		scaling = scaling,
		interface = interface,
		flipped = false,
		center = {
			x = w / (2 * scaling),
			y = h / (2 * scaling),
		}
	}

end