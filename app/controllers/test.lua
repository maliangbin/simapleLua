local test = {}

function test:index()
    ngx.say(555)
end

function test:info(id, device_token)
    ngx.say(id)
    ngx.say(device_token)
    ngx.say(22222)
end

return test