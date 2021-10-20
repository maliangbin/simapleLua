local tab_new = require "table.new"

local funs = require "helpers.functions"

local _M = tab_new(50, 0)

local mt = setmetatable({}, {
    __index = _M
})

local switch = {
    ['nil'] = function()
    end,
    ['string'] = function(res)
        _M:plain(res)
    end,
    ['table'] = function(res)
        _M:json(res)
    end
}

function _M:plain(text)
    ngx.print(text)
end

function _M:json(arr)
    ngx.print(funs:json_encode(arr))
end

function _M:success(data)
    local result = {
        ['code'] = 200,
        ['msg'] = 'success',
        ['data'] = data or {}
    }

    return result
end

function _M:error(code, msg, data)
    local result = {
        ['code'] = code,
        ['msg'] = msg,
        ['data'] = data or {}
    }

    return result
end

function _M:send(status, res)
    if status then
        local case = switch[type(res)]
        if case then
            case(res)
        else
            self:plain(res)
        end
    else
        if res ~= nil then
            ngx.log(ngx.ERR, res)
        end
    end
end

return mt
