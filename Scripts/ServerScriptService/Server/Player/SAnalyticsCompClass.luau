-- 项目行为口径与会话计时，不向报表发送玩家 ID、收据 ID 或会话 GUID。
local FX, FS = _G.FX, _G.FS
local Fields = _G.PlayerDataConfig
local Config = _G.GameConfig.CommonConfig
local Component = FX.Class("SAnalyticsCompClass", "FSPlayerCompClass")
local VERSION = "V1"
local GUIDE_VERSION = "FirstLootV1"
local STEPS = {
    "CollectTwoItems", "DepositLoot", "SellLoot", "BuyTrainingRate", "EquipStrongerWeapon",
    "TimedTrainingReminder", "TimedEncouragement", "TimedRewardReminder", "Completed",
}

--- @return string 玩家内协作名称。
function Component:GetCompName()
    return "SAnalyticsComp"
end

--- 收据可能早于业务登录完成到达，需等待明确的会话起点。
--- @return boolean 是否已完成项目登录且尚未离服。
function Component:IsSessionActive()
    return self._startedAt ~= nil and not self._ended
end

--- 登录完成后明确启动，不依赖组件遍历顺序；测试账号仍正常记账但不发送。
function Component:StartSession()
    if self._startedAt then
        return
    end
    self._startedAt = os.clock()
    self._accountedAt = self._startedAt
    self._node = self:GetPlayerNode()
    self._enabled = Config.AnalyticsEnabled and not FX.IsDeveloper(self:GetPlayerId())
        and not table.find(Config.AnalyticsExcludedUserIds, self:GetPlayerId())
    local data = self:GetTable(Fields.AnalyticsData)
    self._sessionKind = data.started and "ReturningSession" or "FirstSession"
    data.started = true
    self:SetTable(Fields.AnalyticsData, data)
    self:Custom("SessionStarted", 1, {GUIDE_VERSION, self._sessionKind, VERSION})
    self:RecordGuide(self:GetTable(Fields.Guide))
end

--- 同一单调服务器时钟按经过秒数记账，离服与首付共用此方法补齐尾差。
--- @return number 累计在线秒数。
function Component:AccountTime()
    if self._startedAt and not self._ended then
        local now = os.clock()
        self:AddNumber(Fields.TrainingPlaytime, math.max(0, now - self._accountedAt))
        self._accountedAt = now
    end
    return self:GetNumber(Fields.TrainingPlaytime)
end

--- 使用框架每秒更新，仅记账，不逐秒发送事件。
--- @param serverTime number 框架时间；计时使用同一单调时钟。
function Component:OnUpdate(serverTime)
    self:AccountTime()
end

--- 在业务组件清理前结束；重复登出不重复累计和上报。
function Component:EndSession()
    if not self._startedAt or self._ended then
        return
    end
    self:AccountTime()
    self._ended = true
    local stage = self:GetGuideStage(self:GetTable(Fields.Guide))
    self:Custom("SessionEndedDuration", self._accountedAt - self._startedAt,
        {stage, self._sessionKind, VERSION})
end

--- 已完成时 stepIndex 为零，必须先判断 Finished。
--- @param data table 权威引导数据。
--- @return string 当前阶段。
--- @return number? 可上报的漏斗步骤。
function Component:GetGuideStage(data)
    local first = data.guideMap and data.guideMap.FirstLootGuide
    if first and first.state == "Finished" then
        return "Completed", 9
    end
    if first and first.state == "Running" and STEPS[first.stepIndex] then
        return "Step" .. first.stepIndex, first.stepIndex
    end
    return "NotStarted", nil
end

--- 由引导统一提交点调用，包含计时推进；同一会话仅发送新到达的进度。
--- @param data table 已提交的权威引导数据。
function Component:RecordGuide(data)
    if not self._startedAt or self._ended then
        return
    end
    local stage, step = self:GetGuideStage(data)
    if step and (not self._lastStep or step > self._lastStep) then
        self._lastStep = step
        if self._enabled then
            FS.AnalyticsManager:Onboarding(self._node, step, STEPS[step], {GUIDE_VERSION})
        end
    end
end

--- 项目统计开关统一覆盖自定义事件。
--- @param name string 稳定事件名。
--- @param value number 原始数值。
--- @param fields table 三个稳定维度。
function Component:Custom(name, value, fields)
    if self._enabled then
        FS.AnalyticsManager:Custom(self._node, name, value, fields)
    end
end

--- 业务结算成功后调用一次，零成本解锁不计货币消费。
--- @param currency string Money 或 Diamonds。
--- @param amount number 实际扣款。
--- @param balance number 本笔结算后的余额。
--- @param sku string 稳定商品 SKU。
function Component:Sink(currency, amount, balance, sku)
    if self._enabled and amount > 0 then
        FS.AnalyticsManager:Economy(self._node, Enum.AnalyticsEconomyFlowType.Sink,
            currency, amount, balance, Enum.AnalyticsEconomyTransactionType.Shop.Name, sku)
    end
end

--- 首付资格直接来自权威收据记录，不维护另一个可能脱节的已首付布尔值。
--- @param receipt table 官方收据。
--- @param receipts table 同一档案的已发奖收据，尚未加入本笔。
--- @return table 本笔随收据保存的上报快照。
function Component:CapturePurchase(receipt, receipts)
    local first = next(receipts) == nil
    local goods = _G.Provider:GetGoodsConfig(receipt.ProductId)
    return {
        first = first, playtime = self:AccountTime(), product = tostring(goods.DevGoodsId),
        category = goods.BuyHandler, spent = receipt.CurrencySpent,
    }
end

--- 仅消费保存成功前取得的快照，不在保存后重新推断首付。
--- @param snapshot table 与收据一起持久化的元数据。
function Component:ReportPurchase(snapshot)
    self:Custom("RobuxPurchase", snapshot.spent,
        {snapshot.product, snapshot.category, snapshot.first and "FirstPurchase" or "RepeatPurchase"})
    if snapshot.first then
        self:Custom("FirstPurchasePlaytime", snapshot.playtime,
            {snapshot.product, "OnlineSinceFirstLogin", VERSION})
    end
end

return Component
