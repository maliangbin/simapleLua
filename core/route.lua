local tab_new = require "table.new"

local routes = require("conf.routes")
local funs = require("helpers.functions")
local str_find = string.find
local str_byte = string.byte
local DOT_BYTE = str_byte(':', 1)
local request_method = ngx.var.request_method
local uri = ngx.var.uri

local _M = tab_new(50, 0)

local mt = setmetatable({}, {
    __index = _M
})

function _M:get_route()
    if funs:is_empty(request_method) or funs:is_empty(uri) then
        return nil
    end

    for i, val in ipairs(routes) do
        local res, param_val = self:method_and_uri_is_macth(request_method, uri, val[1], val[2])
        if res then
            return {
                route = val[3],
                method = val[4],
                params = param_val or {}
            }
        end
    end
end

function _M:method_and_uri_is_macth(method_req, uri_req, method_config, uri_config)
    if method_config == "*" or method_config == method_req then
        if uri_req == uri_config then
            return true
        elseif str_find(uri_config, ':') then
            local path_tab, uri_tab = funs:explode("/", uri_req), funs:explode("/", uri_config)
            local path_len, uri_len = #path_tab, #uri_tab
            if path_len == uri_len then
                local matched, pattern, pattern_val, param_k = 0, 0, tab_new(10, 0), 1
                for i, v in pairs(uri_tab) do
                    if str_byte(v, 1) == DOT_BYTE then
                        pattern = pattern + 1
                        pattern_val[param_k] = path_tab[i]
                        param_k = param_k + 1
                    elseif v == path_tab[i] then
                        matched = matched + 1
                    end
                end

                if path_len == matched + pattern then
                    return true, pattern_val
                end
            end
        end
    end

    return false
end

return mt
