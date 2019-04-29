local _M = {}

-- 对输入参数逐个校验，不是数字类型，则返回 false

function _M.is_number(...)
    local arg = {...}

    local num
    for _,v in ipairs(arg) do
        num = tonumber(v)
        if nil == num then
            return false
        end
    end

    return true
end

return _M
