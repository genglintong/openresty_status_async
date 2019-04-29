local baseRepos = require("redisRepos")
local json = require("cjson.safe")

-- 读取参数
local arg = ngx.req.get_uri_args()
local channel = arg['channel']
local data = {}

if channel then
    json.encode_empty_table_as_object(false)
    local result = baseRepos.get(channel)
    local status = json.decode(result)
    
    -- 非空判断
    if status == nil then
        status = {}
    end

    data['errcode']  = 0
    data['msg']  = 'successful'
    data['data'] = status
else
    data['errcode']  = -1
    data['msg']  = 'params error!'
    data['data'] = ''
end

local ret = json.encode(data)

ngx.log(ngx.ERR,'channe:'..channel, ret)
ngx.say(ret)