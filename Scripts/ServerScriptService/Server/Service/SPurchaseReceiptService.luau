local FX, FS = _G.FX, _G.FS
local FXLoader = FX.Loader
local Text = FXLoader:RequireShared("Scripts/Game/Shared/Text")
local TranslationTexts = Text.Define("PurchaseReceipt", {
    DiamondsReceived = "Purchase received! +{value} Diamonds.",
    RebirthSuccess = "Rebirth complete!",
    VipUnlocked = "VIP unlocked! Free double selling is now available.",
    ItemReceived = "Purchase received! {item} x{count:int} added to your inventory.",
})
local GameUtility = FX.Loader:RequireShared("Scripts/Game/Shared/GameUtility")
local MarketplaceService = game:GetService("MarketplaceService")
local Service = {}

--- 项目区分购买预检与收据结算，沿用框架发奖、回滚与保存逻辑。
function Service.Init()
    local canBuy = FS.ShopService.CanBuy
    --- 重生已改为钻石购买；关闭旧平台购买入口，已支付收据仍沿用原处理器结算。
    --- @param playerId number 服务端认证的玩家 ID。
    --- @param productId number 待购买的 Developer Product ID。
    --- @return boolean 是否允许展示该商品的购买窗口。
    function FS.ShopService:CanBuy(playerId, productId)
        if not canBuy(self, playerId, productId) then
            return false
        end
        local goods = _G.Provider:GetGoodsConfig(productId)
        return goods.BuyHandler ~= "SkipRebirth"
    end

    --- 在购买串行锁内捕获首付；独立业务待报字段与奖励共同保存，收据仍只保存去重标记。
    --- @param player table 当前权威玩家对象。
    --- @param receipt table Roblox 官方收据。
    --- @return table 保存成功后用于唤醒持久待报记录的购买标识。
    FS.ShopService.CaptureReceiptAnalytics = function(player, receipt)
        return player:RequireComponent("SAnalyticsComp"):CapturePurchase(receipt)
    end
    --- 保存成功才唤醒待报记录，后续本地失败由分析组件重试，不改变收据决定。
    --- @param player table 保存完成且仍属于同一会话的玩家对象。
    --- @param snapshot table 保存前捕获的购买标识。
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
                player:ShowLocalizedTips(TranslationTexts.DiamondsReceived, {value = GameUtility.NumberToText(goods.NumberArray[1])})
            elseif goods.BuyHandler == "SkipRebirth" then
                player:ShowLocalizedTips(TranslationTexts.RebirthSuccess)
            elseif goods.BuyHandler == "UnlockVip" then
                player:ShowLocalizedTips(TranslationTexts.VipUnlocked)
            elseif goods.BuyHandler == "AddItem" then
                player:ShowLocalizedTips(TranslationTexts.ItemReceived, {
                    itemSource = _G.ItemConfig.Display[goods.KVTable.ItemId].Name, count = goods.KVTable.Count,
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
