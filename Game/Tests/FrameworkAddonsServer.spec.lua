-- Studio Server；仅内存存档模式；无真实付费操作，执行后恢复临时数据。
local FX, FS = _G.FX, _G.FS
assert(game:GetService("RunService"):IsStudio(), "Studio only")
assert(require(game.ServerScriptService.Server.Config.StorageConfig).StudioMemory, "Memory storage required")
local Config = require(game.ReplicatedStorage.Shared.Config.FrameworkConfig)
local player = game:GetService("Players"):GetPlayers()[1]
local object = player and FS.PlayerManager:GetPlayerObject(player.UserId)
assert(object, "Handshake required")
local reward = object:RequireComponent("FSRewardComp")
local inventory = object:RequireComponent("FSInventoryComp")
local itemId = 987654320
local field = { Type = "number", Key = "AddonTestCoins", DefVal = 0, Sync = false }
local oldBag = object:GetTable(Config.PlayerData.Inventory)
local oldItem = Config.Items[itemId]
local oldField, oldCurrency = Config.PlayerData.AddonTestCoins, Config.RewardCurrencies.AddonTest
local oldTemp = object._tempDataMap[field.Key]
local results = {}

local function Check(name, body)
    local ok, err = pcall(body)
    table.insert(results, { name = name, passed = ok, error = not ok and tostring(err) or nil })
end

Config.Items[itemId] = { Id = itemId, Type = "AddonTest", MaxStack = 10 }
Config.PlayerData.AddonTestCoins, Config.RewardCurrencies.AddonTest = field, "AddonTestCoins"
Check("reward attached and real inventory mutation is all prechecked", function()
    inventory:ClearAll()
    object:SetNumber(field, 20)
    assert(reward:AddRewards({ { Type = "Item", ItemId = itemId, Count = 12 } }))
    assert(inventory:GetItemCountById(itemId) == 12)
    assert(not reward:ConsumeRewards({
        { Type = "Money", Currency = "AddonTest", Count = 11 },
        { Type = "Money", Currency = "AddonTest", Count = 11 },
        { Type = "Item", ItemId = itemId, Count = 1 },
    }))
    assert(object:GetNumber(field) == 20 and inventory:GetItemCountById(itemId) == 12)
    assert(reward:ConsumeRewards({
        { Type = "Money", Currency = "AddonTest", Count = 3 },
        { Type = "Item", ItemId = itemId, Count = 12 },
    }))
    assert(object:GetNumber(field) == 17 and inventory:GetItemCountById(itemId) == 0)
end)

-- 恢复不依赖断言是否成功。
object:SetTable(Config.PlayerData.Inventory, oldBag)
inventory:OnAllChanged()
Config.Items[itemId] = oldItem
Config.PlayerData.AddonTestCoins, Config.RewardCurrencies.AddonTest = oldField, oldCurrency
object._tempDataMap[field.Key] = oldTemp
Check("friend state uses native platform result or explicit unavailable status", function()
    local state = FS.FriendService:GetState(player.UserId)
    assert(state.status == "Ready" or state.status == "Loading" or state.status == "Unavailable")
    assert(type(state.ids) == "table" and type(state.revision) == "number")
    for _, id in ipairs(state.ids) do
        assert(id ~= player.UserId and game.Players:GetPlayerByUserId(id))
    end

    if state.status ~= "Ready" then
        assert(FS.FriendService:GetFriendCountInRoom(player.UserId) == nil)
    end
end)

return results
