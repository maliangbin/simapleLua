local tab_new = require "table.new"

local ngx = require "ngx"
local funs = require "helpers.functions"
local ngx_req = ngx.req
local request_type = ngx_req.get_method()

local _M = tab_new(50, 0)

local mt = setmetatable({}, {
    __index = _M
})

function _M:init()
    ngx.ctx._header = {}
    ngx.ctx._input = {}

    if request_type == "GET" then
        local args = ngx_req.get_uri_args()
        if not funs:is_empty(args) then
            for key, val in pairs(args) do
                if type(val) == "table" then
                    val = val[1]
                end

                ngx.ctx._input[key] = val
            end
        end
    end

    if request_type == "POST" then
        ngx_req.read_body()
        local args = ngx_req.get_post_args()
        if type(args) == "table" and (not funs:is_empty(args)) then
            for key, val in pairs(args) do
                if type(val) == "table" then
                    val = val[1]
                end

                ngx.ctx._input[key] = val
            end
        end
    end
end

return mt
