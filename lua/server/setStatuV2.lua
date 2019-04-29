local baseRepos = require("redisRepos")
local json = require("cjson.safe")

-- 读取参数 GET
local arg = ngx.req.get_uri_args()
local channel = arg['channel']
local status = arg['data']
local data = {}

-- 业务逻辑
if channel and status then
    local stat = baseRepos.set(channel, status)
    if stat == nil then
        stat = ''
    end

    data['errcode']  = 0
    data['msg']  = 'successful'
    data['data'] = stat
else
    data['errcode']  = -1
    data['msg']  = 'params error!'
    data['data'] = ''
end

local ret = json.encode(data)

ngx.say(ret)