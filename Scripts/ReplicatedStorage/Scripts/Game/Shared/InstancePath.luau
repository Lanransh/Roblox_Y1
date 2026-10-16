-- 配置实例路径：只解析节点名称，不执行 Lua 表达式。
local InstancePath = {}

--- 完整解析 game 开头的路径，括号内的点号和斜杠保留为节点名。
--- @param path string 完整实例路径，支持点号、斜杠和单双引号索引，不支持转义。
--- @return {string}? 路径各级节点名，格式无效时返回 nil。
local function parse(path)
    if type(path) ~= "string" or string.sub(path, 1, 4) ~= "game" then
        return nil
    end
    local names = {}
    local remaining = string.sub(path, 5)
    while remaining ~= "" do
        local name, nextIndex = string.match(remaining, '^[%./]([^%./%[%]]+)()')
        if not name then
            name, nextIndex = string.match(remaining, '^%["([^"\\]+)"%]()')
        end
        if not name then
            name, nextIndex = string.match(remaining, "^%['([^'\\]+)'%]()")
        end
        if not name then
            return nil
        end
        table.insert(names, name)
        remaining = string.sub(remaining, nextIndex)
    end
    if #names == 0 then
        return nil
    end
    return names
end

--- 查找可选或动态实例；路径无效或任一级尚不存在时返回 nil。
--- @param path string 配置中的完整实例路径。
--- @return Instance? 当前存在的实例。
function InstancePath.Find(path)
    local names = parse(path)
    if not names then
        return nil
    end
    local current = game
    for index, name in ipairs(names) do
        current = current:FindFirstChild(name)
        if not current then
            return nil
        end
    end
    return current
end

--- 等待必需配置资源，每级默认等待 10 秒；缺失时报告完整路径和节点名。
--- @param path string 可信配置中的完整实例路径，不接受客户端指定资源。
--- @return Instance 已加载的实例。
function InstancePath.Wait(path)
    local names = parse(path)
    assert(names, "Invalid instance path: " .. tostring(path))
    local current = game
    for index, name in ipairs(names) do
        current = current:WaitForChild(name, 10)
        assert(current, "Missing instance '" .. name .. "' in path: " .. path)
    end
    return current
end

return InstancePath
