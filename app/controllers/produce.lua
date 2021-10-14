local table_new = require "table.new"

local funs = require "helpers.functions"
local response = require "core.response"
local ldas_conf = require "conf.ldas"
local websocket = require "core.websocket"
local table_concat = table.concat
local json = require "cjson"
local ngx = require "ngx"
local redis = require "core.db.redis"
local ngx_ctx = ngx.ctx
local red = redis:new()

local _M = table_new(20, 0)

local mt = setmetatable({}, {
    __index = _M
})

function _M:pcontent(client_type, customer_id, device_token)
    if funs:is_empty(client_type) or funs:is_empty(customer_id) or funs:is_empty(device_token) then
        return response:error(80, "params not enough")
    end

    local secret = ngx_ctx._input['secret']
    if funs:is_empty(ldas_conf.secret[secret]) then
        return response:error(57, "NOT AUTH")
    end

    local socket = websocket:connect()
    if not socket.wb then
        return response:error(36, "连接socket失败")
    end

    while true do
        if not socket.wb then
            socket = websocket:connect()
        end

        local data, typ, err = socket.wb:recv_frame()

        -- 如果连接损坏 退出
        if socket.wb.fatal then
            return self:wb_close(socket, err, 64)
        end

        if not data then
            local bytes, err = socket.wb:send_ping()
            if not bytes then
                return self:wb_close(socket, err, 71)
            end
        elseif typ == "close" then
            return self:wb_close(socket, err, 0)
        elseif typ == "ping" then
            local bytes, err = socket.wb:send_pong()
            if not bytes then
                return self:wb_close(socket, err, 80)
            end
        elseif typ == "pong" then
            ngx.log(ngx.INFO, "client ponged")
        elseif typ == "text" then
            -- 验证数据是否json数据
            local status, content = pcall(json.decode, data)
            if not status or type(content) ~= 'table' or funs:is_empty(content) then
                self:wb_send_text(socket, {
                    text = "数据格式有误，解析出错"
                })
                goto continue
            end

            -- 跳出本次循环
            ::continue::
        end
    end
end

function _M:switch(content_type, content)
    local switch = {
        ["content"] = function(content_type)
            return _M:produce_content(content)
        end,
        ["live"] = function(content_type)
            return _M:produce_live(content)
        end
    }

    local case = switch[content_type]

    if case then
        return case(content_type)
    end

    return false
end

function _M:produce_content(content)
    return red:lpush('ldas:dolist:content', json.encode(content))
end

function _M:produce_live(content)
    return red:lpush('ldas:dolist:live', json.encode(content))
end

function _M:wb_close(socket, err, code)
    local error = err or ""
    ngx.log(ngx.INFO, table_concat({"关闭连接：", json.encode(error), code}, " "))
    socket:close()
    return response:error(code, err)
end

function _M:wb_send_text(socket, text)
    return socket:send_text(json.encode(text))
end

return mt
