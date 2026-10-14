-- 每日礼盒的离服结算，在框架保存存档之前补齐最后一秒在线时间。
local FX = _G.FX
local Component = FX.Class("SGiftCompClass", "FSPlayerCompClass")

--- 返回每日礼盒的玩家组件协作名称。
--- @return string 礼盒组件名。
function Component:GetCompName()
    return "SGiftComp"
end

--- 在玩家存档保存前结清在线时间，重进延续当天进度。
function Component:OnPlayerLogout()
    _G.SGiftDropService.UpdateTime(self:GetPlayerObject(), os.time())
end

return Component
