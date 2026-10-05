local FX = _G.FX
local Manager = FX.Class("SPlayerObjectManagerClass", "FSPlayerObjectManagerClass")
_G.SPlayerObjectManagerClass = Manager

--- 使用项目玩家类构建服务端管理器，并统一注册玩家业务协议。
function Manager:Ctor()
    Manager.Super.Ctor(self, "SPlayerObjectClass")
    self:RegForwardFrameworkClientMsg()
    self:RegMiscMsg()
    self:RegRockDropMsg()
end

--- 简单玩家请求直接转发到杂项组件，不在管理器内执行结算。
function Manager:RegMiscMsg()
    --- 只操作引擎认证玩家自身的数据，忽略未加载或已离服的玩家。
    --- @param userId number 引擎认证的玩家身份。
    local function rebirth(userId)
        local player = self:GetPlayerObject(userId)
        local misc = player and player:GetComponent("SMiscComp")
        if misc then
            misc:HandleRebirth()
        end
    end
    FX.Network:RegClientMsgCallback("C2S_Rebirth", rebirth)
end

--- 按引擎认证身份转发命中、开奖和轮次请求，未登录或已离服时忽略。
function Manager:RegRockDropMsg()
    --- 只查请求者自身组件，石头状态和请求参数由组件校验。
    --- @param userId number 引擎认证的玩家身份。
    --- @param key string 客户端观察到已击破的格号。
    --- @param round number 客户端当前关卡轮次。
    local function requestDrop(userId, key, round)
        local player = self:GetPlayerObject(userId)
        local rocks = player and player:GetComponent("SRockLevelComp")
        if rocks then
            rocks:RequestDrop(key, round)
        end
    end
    FX.Network:RegClientMsgCallback("C2S_RequestRockDrop", requestDrop)
    --- 服务端只记录通过边界校验的命中，回包用于撤销客户端无效预测。
    --- @param userId number 引擎认证的玩家身份。
    --- @param key string 客户端命中的格号。
    --- @param round number 客户端当前关卡轮次。
    local function rockHit(userId, key, round)
        local player = self:GetPlayerObject(userId)
        local rocks = player and player:GetComponent("SRockLevelComp")
        if rocks then
            local accepted = rocks:RecordHit(key, round)
            FX.Network:SendMsgToClient(userId, "S2C_RockHitResult", key, round, accepted)
        end
    end
    FX.Network:RegClientMsgCallback("C2S_RockHit", rockHit)
    --- 客户端加载与重生后主动获取轮次，避免依赖早于组件就绪的通知。
    --- @param userId number 引擎认证的玩家身份。
    local function requestRound(userId)
        local player = self:GetPlayerObject(userId)
        local rocks = player and player:GetComponent("SRockLevelComp")
        if rocks then
            rocks:SendRockRound()
        end
    end
    FX.Network:RegClientMsgCallback("C2S_RequestRockRound", requestRound)
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
