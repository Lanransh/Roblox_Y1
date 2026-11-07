-- 处理器名与 GoodsConfig.GoodsData[productId].BuyHandler 对应。
-- CanBuy(context) 只做判断；Buy(context) 无 yield，奖励和购买回执由框架一起保存。
local Fields = _G.PlayerDataConfig
local Handlers = {AddGem = {}, AddItem = {}, SkipRebirth = {}, UnlockVip = {}}

--- 预检与收据结算共同校验永久限购，记录按业务 ID 保存。
--- @param context table 框架提供的已认证购买上下文。
--- @return boolean 是否仍有购买额度。
local function CanBuy(context)
    local goods = context.goodsConfig
    local data = context.playerObject:GetTable(Fields.CurrencyShopData)
    local count = data.robuxBought[tostring(goods.DevGoodsId)] or 0
    return context.num == 1 and (not goods.BuyLimit or count < goods.BuyLimit)
end

--- 奖励成功后登记次数，框架将其与 PurchaseId 一并保存。
--- @param context table 平台收据对应的购买上下文。
local function RecordPurchase(context)
    local data = context.playerObject:GetTable(Fields.CurrencyShopData)
    local id = tostring(context.goodsConfig.DevGoodsId)
    data.robuxBought[id] = (data.robuxBought[id] or 0) + 1
    context.playerObject:SetTable(Fields.CurrencyShopData, data)
end

--- 钻石奖励通过统一接口校验有限数值；预检不发奖。
--- @param context table 框架购买上下文。
--- @return boolean 是否允许购买。
function Handlers.AddGem:CanBuy(context)
    context.extraData = {{Type = "Money", Currency = "Diamonds", Count = context.goodsConfig.NumberArray[1]}}
    return CanBuy(context) and context.playerObject:RequireComponent("FSRewardComp"):CanAddRewards(context.extraData)
end

--- 由收据结算或服务端核验通行证后调用；不依赖客户端购买完成通知发奖。
--- @param context table 框架购买上下文。
--- @return boolean 奖励是否已写入档案。
function Handlers.AddGem:Buy(context)
    if not self:CanBuy(context)
        or not context.playerObject:RequireComponent("FSRewardComp"):AddRewards(context.extraData) then
        return false
    end
    RecordPurchase(context)
    return true
end

--- 周卡先进入原生背包，实际使用时沿用活动系统激活规则。
--- @param context table 框架购买上下文。
--- @return boolean 背包能否容纳整份奖励。
function Handlers.AddItem:CanBuy(context)
    local item = context.goodsConfig.KVTable
    context.extraData = {{Type = "Item", ItemId = item.ItemId, Count = item.Count}}
    return CanBuy(context) and context.playerObject:RequireComponent("FSRewardComp"):CanAddRewards(context.extraData)
end

--- 整份周卡发放成功后才登记购买次数。
--- @param context table 框架购买上下文。
--- @return boolean 奖励是否完整发放。
function Handlers.AddItem:Buy(context)
    if not self:CanBuy(context)
        or not context.playerObject:RequireComponent("FSRewardComp"):AddRewards(context.extraData) then
        return false
    end
    RecordPurchase(context)
    return true
end

--- 档位由购买入口预检；已支付收据不因玩家跨档而拒绝结算。
--- @param context table 框架提供的已认证购买上下文。
--- @return boolean 购买数量、限购与组件就绪条件是否满足。
function Handlers.SkipRebirth:CanBuy(context)
    local player = context.playerObject
    local misc = player:GetComponent("SMiscComp")
    return CanBuy(context) and misc ~= nil and misc._levelStat ~= nil
end

--- 仅由平台收据增加重生次数，保留训练值和等级，由框架保存与去重。
--- @param context table 平台收据对应的购买上下文。
--- @return boolean 重生是否已写入玩家档案。
function Handlers.SkipRebirth:Buy(context)
    if not self:CanBuy(context) then
        return false
    end
    context.playerObject:AddNumber(Fields.RebirthCount, 1)
    RecordPurchase(context)
    return true
end

--- 已支付的不同收据均需可结算，永久资格重复写入仍保持幂等。
--- @param context table 已认证的平台购买上下文。
--- @return boolean 是否允许发起购买。
function Handlers.UnlockVip:CanBuy(context)
    return context.num == 1
end

--- 仅由平台收据解锁永久 VIP，随框架收据一起保存并去重。
--- @param context table 平台收据购买上下文。
--- @return boolean 永久资格是否已写入。
function Handlers.UnlockVip:Buy(context)
    if context.num ~= 1 then
        return false
    end
    context.playerObject:SetFlag(Fields.Vip, true)
    return true
end

return Handlers
