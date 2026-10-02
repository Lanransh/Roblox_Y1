local FX = _G.FX
local Manager = FX.Class("SPlayerObjectManagerClass", "FSPlayerObjectManagerClass")
_G.SPlayerObjectManagerClass = Manager

--- 使用项目玩家类构建服务端玩家管理器。
function Manager:Ctor()
    Manager.Super.Ctor(self, "SPlayerObjectClass")
    self:RegForwardFrameworkClientMsg()
end

function Manager:GetInventory(playerId)
    local player = self:GetPlayerObject(playerId)
    return player and player:GetComponent("FSInventoryComp")
end

--- 只接受原生 Tool 使用请求，物品归属由服务端背包组件校验。
function Manager:RegForwardFrameworkClientMsg()
    FX.Network:RegClientMsgCallback("C2S_ActivateTool", function(id, tool)
        local inv = self:GetInventory(id)
        if inv then
            return inv:ActivateTool(tool)
        end
        return false
    end)
end

return Manager
