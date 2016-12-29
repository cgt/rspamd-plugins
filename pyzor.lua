--[[
Copyright (c) 2016, Christoffer G. Thomsen <chris@cgt.name>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]--

local ucl = require "ucl"
local logger = require "rspamd_logger"
local tcp = require "rspamd_tcp"

local N = "pyzor"
local symbol_pyzor = "PYZOR"
local opts = rspamd_config:get_all_opt(N)

-- Default settings
local cfg_host = "localhost"
local cfg_port = 5953

--{"PV": "2.1", "Code": "200", "WL-Count": "0", "Count": "53", "Thread": "53416", "Diag": "OK"}

local function check_pyzor(task)
	local function cb(err, data)
		if err then
			logger.errx("request error: %s", err)
			return
		end
		logger.infox('err: %1, data: %2', err, tostring(data))

		local parser = ucl.parser()
		local ok, err = parser:parse_string(tostring(data))
		if not ok then
			logger.errx("error parsing response: %s", err)
			return
		end

		local resp = parser:get_object()
		local whitelisted = tonumber(resp["WL-Count"])
		local reported = tonumber(resp["Count"])

		logger.infox("count=%s wl=%s", reported, whitelisted)

		if reported >= 5 then
			task:insert_result(symbol_pyzor, 1.0, reported)
		end
	end

	local request = {
		"CHECK\n",
		task:get_content(),
	}

	logger.debugm(N, task, "sending to pyzor")

	tcp.request({
		task = task,
		host = opts["host"],
		port = opts["port"],
		shutdown = true,
		data = request,
		callback = cb,
	})
end

if opts then
	if opts.host then
		cfg_host = opts.host
	end
	if opts.port then
		cfg_port = opts.port
	end

	rspamd_config:register_symbol({
		name = symbol_pyzor,
		callback = check_pyzor,
	})
else
	logger.infox("%s module not configured", N)
end
