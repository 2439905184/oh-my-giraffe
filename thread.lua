channel = love.thread.getChannel('analytics')

local http = require('socket.http')
local ltn12 = require('ltn12')

local method = "POST"
local url = channel:pop()
local body = channel:pop()
local source = ltn12.source.string(body)
local headers = {
	["content-type"] = "application/json",
	["content-length"] = tostring(#body),
}

-- we don't really need to know if this succeeds until
-- our request does something user facing
-- if we are authenticating something we will want to know the response, I think?
--local result, code, header = http.request{method = method, url = url, headers = headers, source = source}
http.request{method = method, url = url, headers = headers, source = source}