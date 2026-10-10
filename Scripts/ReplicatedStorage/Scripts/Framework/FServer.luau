local root = script.Parent:WaitForChild("Server")
require(root.FSEvents)
require(root.PlayerKV.FSPlayerKVDataManager)
require(root.Ranking.FSRankingManager)
require(root.FSObjectManagerClass)
for _, name in ipairs({
    "FSPlayerObjectClass",
    "FSPlayerCompClass",
    "FSInventoryCompClass",
    "FSRewardCompClass",
    "FSTutorialGuideCompClass",
    "FSPlayerObjectManagerClass",
}) do
    require(root.Player:WaitForChild(name))
end

require(root.SItemClass)
require(root.Modules.FSRankingServiceClass)
require(root.Modules.FSShopService)
require(root.Modules.FSFriendService)

local FX, FS = _G.FX, _G.FS
local Players = game:GetService("Players")

FS.PlayerKVDataManager:Init()
FS.RankingManager:Init()
FS.ShopService:Init()
FS.FriendService:Init()

--- 存档加载失败时终止当前玩家会话，禁止使用空档继续游戏。
--- @param id number 存档加载失败的玩家 ID。
FS.Events.OnPlayerDataLoadFailed.Event:Connect(function(id)
    local player = Players:GetPlayerByUserId(id)
    if player then
        player:Kick("存档加载失败或仍在其他服务器，请稍后重试")
    end
end)

--- @param player Player 新进入服务器、需要加载存档的玩家。
Players.PlayerAdded:Connect(function(player)
    FS.PlayerKVDataManager:PlayerAdded(player)
end)

--- @param player Player 离开服务器、需要保存并释放存档的玩家。
Players.PlayerRemoving:Connect(function(player)
    FS.PlayerKVDataManager:PlayerRemoving(player)
end)

for _, player in ipairs(Players:GetPlayers()) do
    FS.PlayerKVDataManager:PlayerAdded(player)
end

--- 关服时等待在线玩家保存完成，释放各自的存档会话锁。
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

--- 使用 Roblox 同步时钟，供客户端计算服务端时间。
--- @return number 服务端当前时间，单位为秒。
FX.Network:RegClientMsgCallback("C2S_GetServerTime", function()
    return workspace:GetServerTimeNow()
end)

print("[Roblox_Y1] 服务端框架已启动")

return _G.FS
