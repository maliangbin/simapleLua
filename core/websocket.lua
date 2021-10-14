local table_new = require "table.new"

local server = require("resty.websocket.server")
local funs = require "helpers.functions"

local _M = table_new(20, 0)

local mt = {
    __index = _M
}

function _M:connect()
    local wb, err = server:new{
        timeout = 10000,
        max_payload_len = 65535
    }

    if not wb then
        ngx.log(ngx.ERR, "failed to new websocket: ", err)
        return nil
    end

    self.wb = wb

    return setmetatable({
        wb = wb,
        _reqs = nil
    }, mt)
end

function _M:send_text(data)
    local bytes, err = self.wb:send_text(data)
    return bytes, err
end

function _M:close()
    if not funs:is_empty(self.wb) then
        self.wb:send_close()
    end
    return
end

return _M
