local FX, FS = _G.FX, _G.FS
local Players = game:GetService("Players")
local root = script.Parent.Parent
local Service = {}
--- @param value number 外部输入。
--- @param min number 最小值。
--- @param max number 最大值。
--- @return boolean 是否为范围内的有限整数。
local function Integer(value, min, max)
    return type(value) == "number" and value == value and value % 1 == 0 and value >= min and value <= max
end
--- @param id number 已认证的玩家 ID。
--- @return table 玩家背包组件，未就绪返回 nil。
local function Inventory(id)
    local player = FS.PlayerManager:GetPlayerObject(id)
    return player and player:GetComponent("FSInventoryComp")
end
--- 显式注册协议；禁止客户端指定玩家身份、组件名或任意方法。
function Service:Init()
    require(root.Player.SPlayerObjectClass)
    FS.PlayerManager = FS.PlayerMgrClass.New("SPlayerObjectClass")
    FS.PlayerKVDataManager:Init()
    FS.RankingManager:Init()
    require(root.Framework.Modules.FSShopService):Init()
    require(root.Framework.Modules.FSFriendService):Init()
    local rankings = FS.RankingServiceClass.New()
    FX.Network:RegClientMsgCallback("C2S_GetServerTime", function()
        return workspace:GetServerTimeNow()
    end)
    FX.Network:RegClientMsgCallback("C2S_SetHeldGridIndex", function(id, index)
        local inv = Inventory(id)
        if inv and (index == nil or Integer(index, 1, inv:GetTotalCapacity())) then
            inv:SetHandItemGridIndex(index)
        end
    end)
    FX.Network:RegClientMsgCallback("C2S_SwapGrid", function(id, a, b)
        local inv = Inventory(id)
        if inv and Integer(a, 1, inv:GetTotalCapacity()) and Integer(b, 1, inv:GetTotalCapacity()) then
            return inv:SwapGridData(a, b)
        end
        return false
    end)
    FX.Network:RegClientMsgCallback("C2S_CanUseItem", function(id, index, count)
        local inv = Inventory(id)
        if not inv or not Integer(index, 1, inv:GetTotalCapacity()) or not Integer(count, 1, 100000000) then
            return false
        end
        local allowed = inv:CanUseItem(index, count)
        return allowed == true
    end)
    FX.Network:RegClientMsgCallback("C2S_UseItem", function(id, index, count)
        local inv = Inventory(id)
        if inv and Integer(index, 1, inv:GetTotalCapacity()) and Integer(count, 1, 100000000) then
            return inv:UseItem(index, count)
        end
        return false
    end)
    FX.Network:RegClientMsgCallback("C2S_RankingData", function(id, scope, kind, first, last)
        if
            not FS.PlayerManager:GetPlayerObject(id)
            or not Integer(scope, 1, 2)
            or not Integer(kind, 1, #_G.Provider:GetRankingEnum())
            or not Integer(first, 1, 100)
            or not Integer(last, first, 100)
        then
            return nil
        end
        return rankings:GetRankingData(id, scope, kind, first, last)
    end)
    FS.Events.OnPlayerDataLoadFailed.Event:Connect(function(id)
        local player = Players:GetPlayerByUserId(id)
        if player then
            player:Kick("存档加载失败或仍在其他服务器，请稍后重试")
        end
    end)
    Players.PlayerAdded:Connect(function(player)
        FS.PlayerKVDataManager:PlayerAdded(player)
    end)
    Players.PlayerRemoving:Connect(function(player)
        FS.PlayerKVDataManager:PlayerRemoving(player)
    end)
    for _, player in ipairs(Players:GetPlayers()) do
        FS.PlayerKVDataManager:PlayerAdded(player)
    end
    game:BindToClose(function()
        local pending = 0
        for _, player in ipairs(Players:GetPlayers()) do
            pending += 1
            task.spawn(function()
                FS.PlayerKVDataManager:PlayerRemoving(player)
                pending -= 1
            end)
        end
        while pending > 0 do
            task.wait()
        end
    end)
    game.ReplicatedStorage.Framework.Network:SetAttribute("ServerReady", true)
end
return Service
