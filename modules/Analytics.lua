Analytics = class{
	init = function(self)

		self.server = "http://api.ohmygiraffe.com"
		self.authenticated = false
		self.threads = {}
		self.performance = {
			timer = 0,
			samples = 1,
			value = 0,
			source = function() return lt.getFPS() end
		}

		self.reset = false

	end,

	authenticate = function(self)
		-- fetch our id and secret
		local version = window.version
		local profile = window.profile
		local device = window.device

		self.version = version
		self.profile = profile
		self.device = device

		local secret_file = FileManager('secret')
		local secret = secret_file:get()

		local identity_file = FileManager('identity')
		local id = identity_file:get()

		local registered = id ~= nil and id ~= ""
		if registered then
			self.id = id
			self.secret = secret
		else
			self:register()
		end
		
	end,

	-- create a new player profile
	-- if the user is not connected when this happens, we'll never register the player
	-- but we will still get it in other analytics reports
	-- so as long as we don't need a secure handshake using its secret
	-- we will be OK
	register = function(self)

		-- create a new profile and register it with the server
		local secret_file = FileManager('secret')
		local identity_file = FileManager('identity')

		-- create a new secret
		local device = self.device
		local secret = ("%s-%s-%s"):format(device, os.time(), 500000 + math.floor(math.random() * 500000))
		secret_file:commit(secret)

		-- generate a new id
		local device = window.device
		local salted = secret .. device
		local hash = sha1(salted)
		local id = hash
		identity_file:commit(id)

		self.id = id
		self.secret = secret

		local endpoint = "register"
		local data = {
			secret = secret,
		}

		self:report(data, endpoint)

		-- create our profile and pass the server our secret for now
		-- we do not have to bother authenticating for analytics alone
		-- unless our db begins to get polluted

		-- todo: send our secret and id to the api
		-- so that we can do authentication handshakes (?)

	end,

	update = function(self, dt)

		local performance = self.performance
		performance.timer = math.max(performance.timer - dt, 0)
		if performance.timer == 0 then
			performance.timer = 0.1
			local ratio = 1 / performance.samples
			local new = performance.source()
			local value = performance.value * math.abs(ratio - 1) + new * ratio
			performance.value = value
			if window.uptime > 3 then
				local low = performance.low or new
				performance.low = math.min(low, new)
			end
			performance.samples = math.min(performance.samples + 1, 10)
			if metrics then
				metrics:set('fps', value)
			end
		end

	end,

	report = function(self, data, endpoint)

		-- we don't have to do this if the thread exists (?)
		local channel = love.thread.getChannel('analytics')
		local using
		local threads = self.threads
		for _,thread in ipairs(threads) do
			if not thread:isRunning() then
				using = thread
				break
			end
		end

		local performance = self.performance
		local version = window.version
		local w = lg.getWidth()
		local h = lg.getHeight()
		local density = lw.getPixelScale()
		local resolution = ("%s,%s,%s"):format(w, h, density)
		local os = os_string
		local id = self.id
		local fps = math.floor(performance.value)
		local low = performance.low or fps
		local low = math.floor(low)
		local uptime = math.floor(window.uptime)

		data.user = id
		data.version = version
		data.os = os
		data.uptime = uptime
		data.resolution = resolution
		data.fps = fps
		data.low = low

		if not using then
			local thread = love.thread.newThread('thread.lua')
			table.insert(threads, thread)
			using = thread
		end

		using:start(channel)

		-- data should be in json
		local blob = json.encode(data, {indent = true})
		local endpoint = endpoint or "event"
		local server = self.server
		local url = ("%s/analytics/%s"):format(server, endpoint)
		channel:push(url)
		channel:push(blob)

		-- we have to keep a reference to the thread or else it will break!
		self.channel = channel

	end,

	wait = function(self)
		local threads = self.threads
		for _,thread in ipairs(threads) do
			if thread:isRunning() then
				thread:wait()
			end
		end
	end,
}