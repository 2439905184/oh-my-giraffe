function love.load()

	love.graphics.setBackgroundColor(0, 0, 0)
	love.graphics.clear()
	love.graphics.present()

	-- declare shorthand framework names
	lg = love.graphics
	li = love.image
	la = love.audio
	lm = love.mouse
	lk = love.keyboard
	lt = love.timer
	le = love.event
	ls = love.system
	lw = love.window
	lf = love.filesystem

	-- make a global table
	local g = {}
	_G["g"] = g

	-- get the os type 
	os_string = ls.getOS()

	-- set image scaling filter method
	lg.setDefaultFilter('nearest', 'nearest', 1)
	lg.setLineStyle('rough')

	-- import named libaries
	state = require 'lib/gamestate'
	class = require 'lib/class'
	camera = require 'lib/camera'
	easing = require 'lib/easing'
	signals = require 'lib/signal'
	vector = require 'lib/vector'
	json = require 'lib/dkjson'
	sha1 = require 'lib/sha1'
	tserial = require 'lib/Tserial'
	inspect = require 'lib/inspect'

	-- import unnamed libraries
	local lib = {
		'slam',
	}
	for k,r in ipairs(lib) do require ('lib/' .. r) end

	-- import settings
	settings = require 'settings'
	options = require 'options'
	
	-- import modules
	local modules = {
		'functions',
		'Analytics',
		'Animation',
		'AudioManager',
		'CollisionManager',
		'ComboPanel',
		'DangerManager',
		'DifficultyManager',
		'Disruption',
		'Draggable',
		'DrawManager',
		'Drawable',
		'Dummy',
		'Edible',
		'EdibleManager',
		'Exclaimations',
		'FileManager',
		'Fireworks',
		'Flash',
		'FontManager',
		'GiraffeBody',
		'GiraffeHead',
		'GiraffeNeck',
		'GiraffeRig',
		'Graphic',
		'Ground',
		'GroupManager',
		'Hint',
		'HintLion',
		'HintFruit',
		'Horizon',
		'InputManager',
		'InterfaceButton',
		'InterfaceManager',
		'LayerManager',
		'Leaderboard',
		'LeaderboardView',
		'LeaderboardButton',
		'LionHead',
		'LionLegs',
		'LionRig',
		'LionTail',
		'Loader',
		'MenuEntry',
		'MenuHeader',
		'MenuHint',
		'MenuManager',
		'MenuPanel',
		'MenuPill',
		'MenuSubtitle',
		'Metrics',
		'Moon',
		'MusicManager',
		'Notification',
		'NotificationManager',
		'ObjectManager',
		'Outline',
		'Orb',
		'Overlay',
		'Panel',
		'Paused',
		'PausePanel',
		'PlayerController',
		'PlayerManager',
		'Points',
		'ProgressManager',
		'Region',
		'ResetButton',
		'SceneManager',
		'ScoreBoard',
		'ScoreBreakdown',
		'ScorePanel',
		'ScoreManager',
		'Seperator',
		'SkyManager',
		'Snores',
		'StageManager',
		'Stars',
		'Sun',
		'TerrainManager',
		'TerrainProp',
		'TimeManager',
		'TouchDraggable',
		'Twinkles',
		'ViewportController',
		'ViewportRenderer',
		'Vine',
		'Warning',
		'Wind',
	}
	for k,r in ipairs(modules) do
		require ('modules/' .. r)
	end

    -- import templates
    templates = {
        assets = {
            audio = require 'templates/audio',
        },
        chunks = require 'templates/chunks',
        groups = require 'templates/groups',
        menus = require 'templates/menus',
    }

    config = require 'templates/scaling'

    templates.assets['quads'] = require 'templates/graphics'

	-- import game states
	local states = {
		'game',
	}
	for k,r in ipairs(states) do
		require ('states/' .. r)
	end

	-- set seed from os time
	seed = os.time()

	-- init game state
	state.registerEvents()
	state.switch(game)

end

function love.run()

	local min = math.min
	if love.math then
		love.math.setRandomSeed(os.time())
		for i = 1, 3 do love.math.random() end
	end

	if love.event then
		love.event.pump()
	end

	if love.load then love.load(arg) end

	-- We don't want the first frame's dt to include time taken by love.load.
	if love.timer then love.timer.step() end

	local dt = 0
	local min = math.min

	-- Main loop time.
	while true do
		-- Process events.
		if love.event then
			love.event.pump()
			for e,a,b,c,d in love.event.poll() do
				if e == "quit" then
					if not love.quit or not love.quit() then
						if love.audio then
							love.audio.stop()
						end
						return
					end
				end
				love.handlers[e](a,b,c,d)
			end
		end

		-- Update dt, as we'll be passing it to update
		if love.timer then
			love.timer.step()
			-- at most, simulate 1/20 of a second
			dt = min(love.timer.getDelta(), 0.05)
		end

		-- Call update and draw
		if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled

		if love.window and love.graphics and love.window.isCreated() then
			love.graphics.clear()
			love.graphics.origin()
			if love.draw then love.draw() end
			love.graphics.present()
		end

		if love.timer then love.timer.sleep(0.001) end
	end

end