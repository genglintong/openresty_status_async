local redis = require "redis/baseReposV2"
local bit = require "bit"

local _M = {}

-- 端口配置列表
-- 使用位操作计算 建议配置2的幂次
local port = {
    6379,
    6380,
    6381,
    6382
}

-- 使用CRC 该key所在数据库实例
local function getSlot(key)
    local num = ngx.crc32_long(key)
    local slot = bit.band(num, 0x03)

    ngx.log(ngx.ERR,"getNum",slot)
    ngx.log(ngx.ERR,"getSlot",port[slot])
    
    return port[slot]
end

-- 执行数据库操作
function _M.get(key)
    local port = getSlot(key)
    return redis.get(key,port)
end

-- 执行数据库操作
function _M.set(key, data)
    local port = getSlot(key)
    return redis.set(key, data, port)
end

return _M



