-- 仅作为正常 Script 在 Studio 内存存档试玩中运行。
local FS = _G.FS
local Config = require(game.ReplicatedStorage.Shared.Config.FrameworkConfig)
assert(game:GetService("RunService"):IsStudio())
assert(require(game.ServerScriptService.Server.Config.StorageConfig).StudioMemory)
local id = game.Players:GetPlayers()[1].UserId
local player = FS.PlayerManager:GetPlayerObject(id)
local db = FS.PlayerKVDataManager._playerDBMap[id]
local results = {}
--- @param name string 检查名称。
--- @param body function 检查过程。
local function Check(name, body)
    local ok, err = pcall(body)
    table.insert(results, { name = name, passed = ok, error = not ok and tostring(err) or nil })
end
local field = { Type = "number", Key = "MigrationReward", DefVal = 0, KVTable = "PlayerData", Sync = false }
local product = 987654322
local originalSave = db.Save
Config.Goods[product] = { BuyHandler = "MigrationFailure" }
local handler = {
    CanBuy = function()
        return true
    end,
}
_G.Provider.BuyHandlers.MigrationFailure = handler
--- @return table 每次生成不同的模拟凭证，绝不触发平台扣费。
local function Receipt()
    return {
        PlayerId = id,
        ProductId = product,
        PurchaseId = "migration-" .. game:GetService("HttpService"):GenerateGUID(false),
    }
end
Check("shop-failed-handler-rolls-back-persistent-reward", function()
    player:SetNumber(field, 7)
    handler.Buy = function()
        player:SetNumber(field, 99)
        return false
    end
    local receipt = Receipt()
    assert(FS.ShopService:ProcessReceipt(receipt) == Enum.ProductPurchaseDecision.NotProcessedYet)
    assert(player:GetNumber(field) == 7)
    assert(not db._data.PurchaseReceipts[receipt.PurchaseId])
    assert(FS.ShopService._busy[id] == nil)
end)
Check("shop-yielding-handler-is-cancelled-and-rolled-back", function()
    handler.Buy = function()
        player:SetNumber(field, 99)
        task.wait(0.05)
        player:SetNumber(field, 100)
        return true
    end
    assert(FS.ShopService:ProcessReceipt(Receipt()) == Enum.ProductPurchaseDecision.NotProcessedYet)
    task.wait(0.1)
    assert(player:GetNumber(field) == 7)
end)
Check("shop-save-failure-retry-does-not-repeat-reward", function()
    local count = 0
    handler.Buy = function()
        count += 1
        player:AddNumber(field, 3)
        return true
    end
    local receipt = Receipt()
    -- 显式注入保存失败；这不是云端故障实测。
    db.Save = function()
        return false
    end
    local decision = FS.ShopService:ProcessReceipt(receipt)
    db.Save = originalSave
    assert(decision == Enum.ProductPurchaseDecision.NotProcessedYet)
    assert(player:GetNumber(field) == 10)
    assert(FS.ShopService:ProcessReceipt(receipt) == Enum.ProductPurchaseDecision.PurchaseGranted)
    assert(count == 1 and player:GetNumber(field) == 10)
end)
db.Save = originalSave
Config.Goods[product], _G.Provider.BuyHandlers.MigrationFailure = nil, nil
Check("player-table-copy-default-and-periodic-reset", function()
    local definition =
        { Type = "table", Key = "MigrationTable", DefVal = { enabled = false }, KVTable = "PlayerData", Sync = false }
    local source = { enabled = true }
    player:SetTable(definition, source)
    source.enabled = false
    assert(player:GetTable(definition).enabled)
    local copy = player:GetTable(definition)
    copy.enabled = false
    assert(player:GetTable(definition).enabled)
    player:SetTable(definition, nil)
    assert(player:GetTable(definition).enabled == false)
    for _, period in ipairs({ "Daily", "Weekly", "Monthly" }) do
        definition.KVResetType = period
        player:SetTable(definition, { enabled = true })
        db:GetKVTable("PlayerData"):SetDeep("MigrationTable.LastSaveTime", 1)
        assert(player:_ResetExpiredKVData(definition, os.time()))
        assert(player:GetTable(definition).enabled == false)
        assert(not player:_ResetExpiredKVData(definition, os.time()))
    end
    db:GetKVTable("PlayerData"):Set("MigrationTable", nil)
end)
db:GetKVTable("PlayerData"):Set("MigrationReward", nil)
return results
