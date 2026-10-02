local FX, FS = _G.FX, _G.FS
local MarketplaceService = game:GetService("MarketplaceService")
local Shop = { _busy = {} }
FS.ShopService = Shop

--- 商品处理器不得 yield，防止同一档案在结算中交叉修改。
--- @param callback function 无 yield 的业务操作。
--- @return boolean 操作是否成功。
local function Immediate(callback)
    local thread = coroutine.create(callback)
    local ok, result = coroutine.resume(thread)
    if coroutine.status(thread) ~= "dead" then
        task.cancel(thread)
        return false
    end

    return ok and result == true
end

--- 框架可先于业务管理器初始化，玩家尚未就绪时拒绝购买预检。
--- @param playerId number 服务端认证的玩家 ID。
--- @param productId number 已登记的 Developer Product ID。
--- @return boolean 是否允许展示购买窗口；不授予任何奖励。
function Shop:CanBuy(playerId, productId)
    if type(productId) ~= "number" or productId % 1 ~= 0 then
        return false
    end

    local player = FS.PlayerManager and FS.PlayerManager:GetPlayerObject(playerId)
    if not player or not _G.Provider:GetGoodsConfig(productId) then
        return false
    end

    return Immediate(function()
        return FX.BuyContextClass.New(player, productId, 1):CanBuy()
    end)
end

--- 只接受 Roblox ProcessReceipt 的购买凭证；去重标记与奖励位于同一玩家档案。
--- 管理器尚未创建时保留凭证，等待 Roblox 后续重试。
--- @param receipt table Roblox 提供的已支付凭证。
--- @return Enum.ProductPurchaseDecision 保存完成后才确认购买。
function Shop:ProcessReceipt(receipt)
    local id = receipt.PlayerId
    local player = FS.PlayerManager and FS.PlayerManager:GetPlayerObject(id)
    local db = FS.PlayerKVDataManager._playerDBMap[id]
    local retry = Enum.ProductPurchaseDecision.NotProcessedYet
    if not player or not db or not db:IsLoadFinished() or db._leaving or self._busy[id] then
        return retry
    end

    self._busy[id] = true
    local ok, decision = pcall(function()
        local receipts = db._data.PurchaseReceipts or {}
        db._data.PurchaseReceipts = receipts
        if not receipts[receipt.PurchaseId] then
            local context = FX.BuyContextClass.New(player, receipt.ProductId, 1)
            if not Immediate(function()
                return context:CanBuy()
            end) then
                return retry
            end

            -- 处理器必须不 yield，且奖励只能修改当前玩家档案；失败则恢复档案。
            local before = FX.Table:DeepCopy(db._data)
            local pendingBefore = FX.Table:DeepCopy(player._pendingSyncData)
            if not Immediate(function()
                return context:Buy()
            end) then
                for name in pairs(db._data) do
                    if before[name] == nil then
                        db._data[name] = nil
                    end
                end

                for name, values in pairs(before) do
                    if db._data[name] then
                        table.clear(db._data[name])
                        for key, value in pairs(values) do
                            db._data[name][key] = value
                        end
                    else
                        db._data[name] = values
                    end
                end

                player._pendingSyncData = pendingBefore
                local inventory = player:GetComponent("FSInventoryComp")
                if inventory then
                    inventory:OnAllChanged()
                end

                return retry
            end

            receipts[receipt.PurchaseId] = true
        end

        if not db:Save(false) then
            return retry
        end

        return Enum.ProductPurchaseDecision.PurchaseGranted
    end)

    self._busy[id] = nil
    if not ok then
        warn("[Shop] receipt failed", decision)
        return retry
    end

    return decision
end

--- 项目中只应有一个 ProcessReceipt 所有者。
function Shop:Init()
    MarketplaceService.ProcessReceipt = function(receipt)
        return self:ProcessReceipt(receipt)
    end

    FX.Network:RegClientMsgCallback("C2S_BuyCheck", function(id, productId)
        return self:CanBuy(id, productId)
    end)
end

return Shop
