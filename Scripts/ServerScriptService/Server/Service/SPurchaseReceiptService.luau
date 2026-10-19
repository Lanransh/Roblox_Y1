local FX, FS = _G.FX, _G.FS
local MarketplaceService = game:GetService("MarketplaceService")
local Service = {}

--- 项目只包装框架收据结果，不改写发奖、回滚与保存逻辑；保存成功后才提示到账。
function Service.Init()
    --- 在购买串行锁内捕获首付，元数据随同奖励和收据保存。
    --- @param player table 当前权威玩家对象。
    --- @param receipt table Roblox 官方收据。
    --- @param receipts table 档案内既有收据记录。
    --- @return table 待保存的分析快照。
    FS.ShopService.CaptureReceiptAnalytics = function(player, receipt, receipts)
        return player:RequireComponent("SAnalyticsComp"):CapturePurchase(receipt, receipts)
    end
    --- 框架仅在本笔新结算保存成功后尝试一次，平台异常不影响收据决定。
    --- @param player table 保存完成且仍属于同一会话的玩家对象。
    --- @param snapshot table 保存前捕获的不可变分析快照。
    FS.ShopService.OnReceiptAnalyticsSaved = function(player, snapshot)
        player:RequireComponent("SAnalyticsComp"):ReportPurchase(snapshot)
    end
    local notified = setmetatable({}, {__mode = "k"})
    --- 平台收据仍交给框架处理，返回决定不受提示发送结果影响。
    --- @param receipt table Roblox 提供的购买凭证。
    --- @return Enum.ProductPurchaseDecision 框架保存后的支付决定。
    MarketplaceService.ProcessReceipt = function(receipt)
        local player = FS.PlayerManager:GetPlayerObject(receipt.PlayerId)
        local analytics = player and player:GetComponent("SAnalyticsComp")
        if not analytics or not analytics:IsSessionActive() then
            return Enum.ProductPurchaseDecision.NotProcessedYet
        end
        local decision = FS.ShopService:ProcessReceipt(receipt)
        -- 保存会 yield，离服或重进后不能向新会话发送旧购买结果。
        if decision ~= Enum.ProductPurchaseDecision.PurchaseGranted or not player
            or FS.PlayerManager:GetPlayerObject(receipt.PlayerId) ~= player then
            return decision
        end
        local purchases = notified[player]
        if not purchases then
            purchases = {}
            notified[player] = purchases
        end
        if purchases[receipt.PurchaseId] then
            return decision
        end
        purchases[receipt.PurchaseId] = true
        -- 提示异常不能改变已保存的支付结果，也不能触发再次发奖。
        local ok, message = pcall(function()
            local goods = _G.Provider:GetGoodsConfig(receipt.ProductId)
            if not goods then
                return
            end
            if goods.BuyHandler == "AddGem" then
                player:ShowLocalizedTips("CurrencyShop.DiamondsReceived", {value = goods.NumberArray[1]})
            elseif goods.BuyHandler == "SkipRebirth" then
                player:ShowLocalizedTips("Rebirth.Success")
            elseif goods.BuyHandler == "AddItem" then
                player:ShowLocalizedTips("CurrencyShop.ItemReceived", {
                    itemKey = "Welfare.Item." .. goods.KVTable.ItemId, count = goods.KVTable.Count,
                })
            end
        end)
        if not ok then
            warn("[PurchaseReceipt] reward notification failed", message)
        end
        return decision
    end
end

return Service
