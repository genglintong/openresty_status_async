-- V2 版本 使用多个redis实例

local config = {
    host='127.0.0.1', -- ip
    port=6379,  -- port 端口
    db_index=0, -- 数据库索引 选0
    password=nil, -- 数据库密码
    timeout=2000, -- 连接超时时间 默认1s
    keepalive=60000, -- 默认 60s
    pool_size=1000, -- 默认 100
}
local redis = require "resty.redis-util"

-- 定义模块
_M = {}

-- 私有函数 连接数据库
local function conn(host, port)
    config.host = host or config.host
    config.port = port or config.port

    local red = redis:new(config)
    return red
end


-- 获取数据
function _M.get(key, port, host)
    local red = conn(host, port)
    local res, err = red:get(key)
    -- 数据错误
    if err then
        ngx.log(ngx.ERR,"failed to get data",err)
        return nil
    end 

    return res
end

-- 写入数据
function _M.set(key, data, port, host)
    local red = conn(host, port)
    local res, err = red:set(key, data)
    -- 数据错误
    if err then
        ngx.log(ngx.ERR,"failed to set data",err)
        return nil
    end

    return res
end

return _M