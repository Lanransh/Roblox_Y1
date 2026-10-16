-- 处理器名与 GoodsConfig.GoodsData[productId].BuyHandler 对应。
-- CanBuy(context) 只做判断；Buy(context) 无 yield，奖励和购买回执由框架一起保存。
local FX = _G.FX
local Rebirth = FX.Loader:RequireShared("Scripts/Game/Shared/Rebirth")
local Fields = _G.PlayerDataConfig
local Handlers = {AddGem = {}, AddItem = {}, SkipRebirth = {}}

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

--- 仅收据处理器调用；不依赖客户端购买完成通知发奖。
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

--- 预检和收据均按服务端当前次数校验分档，拒绝使用低价商品跨档重生。
--- @param context table 框架提供的已认证购买上下文。
--- @return boolean 当前次数是否适用于该商品且组件已经就绪。
function Handlers.SkipRebirth:CanBuy(context)
    local player = context.playerObject
    local misc = player:GetComponent("SMiscComp")
    return CanBuy(context) and misc ~= nil and misc._levelStat ~= nil
        and Rebirth.GetSkipGoods(player:GetNumber(Fields.RebirthCount)) == context.goodsConfig
end

--- 仅由平台收据跳过等级要求；沿用普通重生重置并由框架保存与去重。
--- @param context table 平台收据对应的购买上下文。
--- @return boolean 重生是否已写入玩家档案。
function Handlers.SkipRebirth:Buy(context)
    if not self:CanBuy(context) then
        return false
    end
    context.playerObject:RequireComponent("SMiscComp"):ApplyRebirth()
    RecordPurchase(context)
    return true
end

return Handlers
