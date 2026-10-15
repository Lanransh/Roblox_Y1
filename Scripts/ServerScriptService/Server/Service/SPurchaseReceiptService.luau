local FX, FS = _G.FX, _G.FS
local MarketplaceService = game:GetService("MarketplaceService")
local Service = {}

--- 项目只包装框架收据结果，不改写发奖、回滚与保存逻辑；保存成功后才提示到账。
function Service.Init()
    local notified = setmetatable({}, {__mode = "k"})
    --- 平台收据仍交给框架处理，返回决定不受提示发送结果影响。
    --- @param receipt table Roblox 提供的购买凭证。
    --- @return Enum.ProductPurchaseDecision 框架保存后的支付决定。
    MarketplaceService.ProcessReceipt = function(receipt)
        local player = FS.PlayerManager:GetPlayerObject(receipt.PlayerId)
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
