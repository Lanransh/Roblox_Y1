local FX = _G.FX
local Manager = FX.Class("SPlayerObjectManagerClass", "FSPlayerObjectManagerClass")
_G.SPlayerObjectManagerClass = Manager

--- 使用项目玩家类构建服务端管理器，并统一注册背包与石头掉落协议。
function Manager:Ctor()
    Manager.Super.Ctor(self, "SPlayerObjectClass")
    self:RegForwardFrameworkClientMsg()
    self:RegRockDropMsg()
end

--- 按引擎认证身份转发掉落请求，未登录或已离服的请求直接忽略。
function Manager:RegRockDropMsg()
    --- 只查请求者自身组件，石头状态和请求参数由组件校验。
    --- @param userId number 引擎认证的玩家身份。
    --- @param key string 客户端观察到已击破的格号。
    local function requestDrop(userId, key)
        local player = self:GetPlayerObject(userId)
        local rocks = player and player:GetComponent("SRockLevelComp")
        if rocks then
            rocks:RequestDrop(key)
        end
    end
    FX.Network:RegClientMsgCallback("C2S_RequestRockDrop", requestDrop)
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
