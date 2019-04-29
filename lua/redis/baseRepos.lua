local config = {
    host='127.0.0.1', -- ip
    port=6379,  -- port 端口
    db_index=0, -- 数据库索引 选0
    password=nil, -- 数据库密码
    timeout=2000, -- 连接超时时间 默认1s
    keepalive=60000, -- 默认 60s
    pool_size=1000, -- 默认 100
}

-- 定义模块
baseRepos = {}
local redis = require "resty.redis-util"

local red = redis:new(config)
local pre = "pre:"

-- 获取数据
function baseRepos.get(key)
    key = pre..key
    local res, err = red:get(key)
    -- 数据错误
    if err then
        ngx.log(ngx.ERR,"failed to get data",err)
        return nil
    end

    return res
end

-- 写入数据
function baseRepos.set(key, data)
    key = pre..key
    local res, err = red:set(key, data)
    -- 数据错误
    if err then
        ngx.log(ngx.ERR,"failed to set data",err)
        return nil
    end

    return res
end

return baseRepos