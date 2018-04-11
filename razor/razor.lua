local logger = require "rspamd_logger"
local tcp = require "rspamd_tcp"

local N = "razor"
local symbol_razor = "RAZOR"
local opts = rspamd_config:get_all_opt(N)

-- Default settings
local cfg_host = "127.0.0.1"
local cfg_port = 9192

local function check_razor(task)
    local function cb(err, data)
        if err then
            logger.errx(task, "request error: %s", err)
            return
        end
        local resp = tostring(data)
        if resp == "spam" then
            task:insert_result(symbol_razor, 1.0)
            logger.debugm(N, task, "spam")
        elseif resp == "ham" then
            logger.debugm(N, task, "ham")
        else
            logger.errx(task, "unknown response from razorsocket: %s", resp)
        end
    end

    tcp.request({
        task = task,
        host = cfg_host,
        port = cfg_port,
        shutdown = true,
        data = task:get_content(),
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
        name = symbol_razor,
        callback = check_razor,
    })
else
    logger.infox("%s module not configured", N)
end
