local FX, FS = _G.FX, _G.FS
local Players = game:GetService("Players")
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
    FX.Network:RegClientMsgCallback("C2S_GetServerTime", function()
        return workspace:GetServerTimeNow()
    end)

    FX.Network:RegClientMsgCallback("C2S_ActivateTool", function(id, tool)
        local inv = self:GetInventory(id)
        if inv then
            return inv:ActivateTool(tool)
        end
        return false
    end)
end

--- 所有服务完成注册后，再连接玩家事件并开始处理已在线玩家。
function Manager:Start()
    table.insert(self._connections, FS.Events.OnPlayerDataLoadFailed.Event:Connect(function(id)
        local player = Players:GetPlayerByUserId(id)
        if player then
            player:Kick("存档加载失败或仍在其他服务器，请稍后重试")
        end
    end))

    table.insert(self._connections, Players.PlayerAdded:Connect(function(player)
        FS.PlayerKVDataManager:PlayerAdded(player)
    end))

    table.insert(self._connections, Players.PlayerRemoving:Connect(function(player)
        FS.PlayerKVDataManager:PlayerRemoving(player)
    end))

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

return Manager
