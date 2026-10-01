-- 仅通过 Studio MCP 在内存存档的试玩服务器中执行；不进入默认 Rojo 构建。
local FX, FS = _G.FX, _G.FS
local Players = game:GetService("Players")
local Config = require(game.ReplicatedStorage.Shared.Config.FrameworkConfig)
assert(game:GetService("RunService"):IsStudio(), "Studio only")
assert(require(game.ServerScriptService.Server.Config.StorageConfig).StudioMemory, "Memory storage required")
local player = Players:GetPlayers()[1]
assert(player, "A test client must be connected")
local object = FS.PlayerManager:GetPlayerObject(player.UserId)
assert(object, "Client/server handshake must complete first")
local results = {}

--- @param label string 可追踪的测试行为。
--- @param body function 抛出断言即视为失败。
local function Check(label, body)
    local ok, err = pcall(body)
    table.insert(results, { name = label, passed = ok, error = not ok and tostring(err) or nil })
end

Check("duplicate-ready-does-not-recreate-player", function()
    FS.PlayerManager:SetPlayerReady(player.UserId, true)
    FS.PlayerManager:SetPlayerReady(player.UserId, false)
    assert(FS.PlayerManager:GetPlayerObject(player.UserId) == object)
end)

local publicFlag = { Type = "boolean", Key = "MigrationTestFlag", DefVal = true, Sync = true }
local privateFlag = { Type = "boolean", Key = "MigrationPrivateFlag", DefVal = false, Sync = false }
Check("false-value-and-private-field", function()
    object:SetFlag(publicFlag, false)
    object:SetFlag(privateFlag, true)
    assert(object:GetFlag(publicFlag) == false)
    assert(object:GetFlag(privateFlag) == true)
    assert(object._pendingSyncData[privateFlag.Key] == nil)
    FX.SyncManager:SetFlag(publicFlag, false)
    assert(FX.SyncManager:GetFlag(publicFlag) == false)
    object:SyncData()
end)

local inv = object:RequireComponent("FSInventoryComp")
local oldInventory = object:GetTable(Config.PlayerData.Inventory)
local testId = 987654321
local previousItem = Config.Items[testId]
Config.Items[testId] = { Id = testId, Type = "MigrationTest", MaxStack = 10, UseHandler = "MigrationTest" }
local used = 0
_G.Provider.ItemHandlers.MigrationTest = {
    CanUse = function()
        return true
    end,
    Use = function(contextSelf, context)
        used += context.consumeCount
        return true
    end,
}

Check("inventory-stack-swap-remove-use-and-reject-invalid", function()
    inv:ClearAll()
    assert(inv:AddItems({ FS.ItemClass.New(testId, 8), FS.ItemClass.New(testId, 5) }))
    assert(inv:GetGridData(1).stackCount == 10)
    assert(inv:GetGridData(2).stackCount == 3)
    assert(inv:SwapGridData(2, 58))
    assert(inv:GetGridData(2) == nil and inv:GetGridData(58).stackCount == 3)
    assert(object:GetTable(Config.PlayerData.Inventory)["58"].stackCount == 3)
    assert(not inv:CanUseItem(58, -1))
    assert(not inv:CanUseItem(0 / 0, 1))
    assert(not inv:CanUseItem(58, math.huge))
    assert(inv:UseItem(58, 1))
    assert(used == 1 and inv:GetGridData(58).stackCount == 2)
    assert(inv:RemoveItemById(testId, 10))
    assert(inv:GetItemCountById(testId) == 2)
end)

Check("inventory-capacity-check-is-atomic", function()
    inv:ClearAll()
    local data = {}
    for i = 1, inv:GetTotalCapacity() do
        data[i] = { itemId = testId, stackCount = 10 }
    end

    data[1].stackCount = 9
    inv:_SetData(data)
    assert(not inv:CanAddItems({ FS.ItemClass.New(testId, 1), FS.ItemClass.New(testId, 1) }))
    assert(inv:GetGridData(1).stackCount == 9)
end)

object:SetTable(Config.PlayerData.Inventory, oldInventory)
inv:SendInventoryDataToClient()
_G.Provider.ItemHandlers.MigrationTest = nil
Config.Items[testId] = previousItem

Check("guide-start-advance-complete", function()
    local original = object:GetTable(Config.PlayerData.Guide)
    Config.GuideGroups.MigrationTest = {
        startEvent = "MigrationStart",
        steps = {
            { finishEvent = "MigrationStep", target = { type = "Test" } },
        },
    }

    object:SetTable(Config.PlayerData.Guide, Config.PlayerData.Guide.DefVal)
    object:PublishEvent("MigrationStart")
    assert(object:GetTable(Config.PlayerData.Guide).activeGuideId == "MigrationTest")
    object:PublishEvent("MigrationStep")
    assert(object:GetTable(Config.PlayerData.Guide).guideMap.MigrationTest.state == "Finished")
    assert(object:GetTable(Config.PlayerData.Guide).target.type == "None")
    object:SetTable(Config.PlayerData.Guide, original)
    Config.GuideGroups.MigrationTest = nil
end)

Check("ranking-native-cache-and-historical-high", function()
    local kind =
        { Name = "MigrationTest", Ascending = false, MaxCount = 10, DefaultValue = 0, UseHistoricalHighScore = true }
    local rank = FS.RankingClass.New(kind)
    rank:LoadRankingData()
    assert(rank:UpdatePlayerScore(player.UserId, 15))
    rank:UpdateRankingData()
    rank:LoadRankingData()
    assert(rank:GetGlobalRankingData()[1].rankScore == 15)
    rank:UpdatePlayerScore(player.UserId, 5)
    assert(rank:GetPlayerScore(player.UserId) == 15)
    FS.PlayerKVDataManager:GetKVTable(player.UserId, Config.RankingDataStore):Set("MigrationTest", nil)
end)

Check("shop-unregistered-product-cannot-grant", function()
    assert(not FS.ShopService:CanBuy(player.UserId, -1))
    assert(FS.ShopService:ProcessReceipt({
        PlayerId = player.UserId,
        ProductId = -1,
        PurchaseId = "migration-unregistered",
    }) == Enum.ProductPurchaseDecision.NotProcessedYet)
end)

Check("shop-receipt-is-idempotent", function()
    Config.Goods[testId] = { BuyHandler = "MigrationTest" }
    local grants = 0
    _G.Provider.BuyHandlers.MigrationTest = {
        CanBuy = function()
            return true
        end,
        Buy = function()
            grants += 1
            return true
        end,
    }

    local receipt = {
        PlayerId = player.UserId,
        ProductId = testId,
        PurchaseId = "migration-" .. game:GetService("HttpService"):GenerateGUID(false),
    }

    assert(FS.ShopService:ProcessReceipt(receipt) == Enum.ProductPurchaseDecision.PurchaseGranted)
    assert(FS.ShopService:ProcessReceipt(receipt) == Enum.ProductPurchaseDecision.PurchaseGranted)
    assert(grants == 1)
    Config.Goods[testId], _G.Provider.BuyHandlers.MigrationTest = nil, nil
end)

Check("storage-lock-save-release-reload", function()
    local id = -987654321
    local db = FS.PlayerKVDBClass.New(id)
    db:LoadAsync()
    task.wait(0.1)
    assert(db:IsLoadFinished())
    db:GetKVTable("PlayerData"):Set("Probe", { ["58"] = false })
    assert(db:Save(false))
    local competing = FS.PlayerKVDBClass.New(id)
    competing:LoadAsync()
    task.wait(0.1)
    assert(not competing:IsLoadFinished())
    assert(db:Save(true))
    local restored = FS.PlayerKVDBClass.New(id)
    restored:LoadAsync()
    task.wait(0.1)
    assert(restored:IsLoadFinished())
    assert(restored:GetKVTable("PlayerData"):Get("Probe")["58"] == false)
    assert(restored:Save(true))
end)

Check("class-event-component-removal", function()
    local name = "MigrationTestComponent"
    local Class = FX.GetClass(name) or FX.Class(name, "FXCompBaseClass")

    function Class:GetCompName()
        return "MigrationAlias"
    end

    local owner = FX.BaseObject.New()
    local component = owner:AddComponent(name)
    local count = 0
    component:SubscribeEvent("Probe", function(self, value)
        count += value
    end)

    owner:PublishEvent("Probe", 2)
    assert(count == 2)
    assert(owner:RemoveComponent("MigrationAlias"))
    assert(owner:GetComponent(name) == nil)
    owner:Dtor()
end)

player:SetAttribute("FrameworkServerTestsDone", true)
return results
