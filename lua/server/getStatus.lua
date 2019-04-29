local baseRepos = require("baseRepos")
local json = require("cjson.safe")

-- 读取参数
local arg = ngx.req.get_uri_args()
local channel = arg['channel']
local data = {}

--跨域
ngx.header["Access-Control-Allow-Origin"] = "*"
--解析空表
json.encode_empty_table_as_object(false)

if channel then
    local status = json.decode(baseRepos.get(channel))
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