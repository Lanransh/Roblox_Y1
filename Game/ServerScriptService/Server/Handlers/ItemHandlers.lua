-- 处理器名与 FrameworkConfig.Items[itemId].UseHandler 对应，仅由服务端加载。
local ItemHandlers = {}

ItemHandlers.DemoTool = {}

--- 测试方块可重复使用，测试球沿用背包传入的消耗数量。
--- @param context table 框架道具上下文，包含道具及消耗数量。
--- @return boolean 是否允许使用。
function ItemHandlers.DemoTool:CanUse(context)
    if context.itemObject:GetItemId() == 1001 then
        context.consumeCount = 0
    end
    return true
end

--- 使用成功后向当前玩家显示道具名称，消耗由框架背包提交。
--- @param context table 框架道具上下文，包含玩家及道具配置。
--- @return boolean 是否使用成功。
function ItemHandlers.DemoTool:Use(context)
    context.playerObject:ShowTips("使用了" .. context.itemDataConfig.Name)
    return true
end

return ItemHandlers
