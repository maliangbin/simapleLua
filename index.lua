local ngx = require "ngx"
local request = require "core.request"
local response = require "core.response"
local table = require "table"
local table_unpack = table.unpack
ngx.header['Content-Type'] = "application/json;charset=UTF-8"

-- 初始化輸入
request:init()

-- 执行事件定义
local run = function(route)
    local status, res
    if type(route.route) == 'function' then
        status, res = pcall(route.route, table_unpack(route.params))
    else
        status, res = pcall(require, route.route)
        if status then
            status, res = pcall(res[route.method], res, table_unpack(route.params))
        end
    end
    return status, res
end

local Route = require("core.route")

local route = Route:get_route()

if route == nil then
    ngx.exit(ngx.HTTP_NOT_FOUND)
end

local status, res = run(route)

response:send(status, res)

ngx.exit(ngx.HTTP_OK)
