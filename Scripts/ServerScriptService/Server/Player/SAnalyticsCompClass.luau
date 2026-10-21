-- 项目行为口径与会话计时；购买 GUID 仅用于官方漏斗会话，不作为自定义字段。
local FX, FS = _G.FX, _G.FS
local AnalyticsService = game:GetService("AnalyticsService")
local Fields = _G.PlayerDataConfig
local Config = _G.GameConfig.CommonConfig
local Component = FX.Class("SAnalyticsCompClass", "FSPlayerCompClass")
local VERSION = "V1"
local GUIDE_VERSION = "FirstLootV2"
local GROWTH_STEPS = {"GuideCompleted", "FirstRebirth", "World2Unlocked", "World3Unlocked"}
local PURCHASE_STEPS = {"ShopOpened", "ProductSelected", "PromptRequested", "PurchaseGranted"}
local STEPS = {
    "GuideStarted", "TwoItemsCollected", "LootDeposited", "LootSold",
    "TrainingRatePurchased", "StrongerWeaponEquipped", "GuideFinished",
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
    self._purchaseFlows = {}
    self:WatchDataChanged(Fields.RebirthCount, self.RecordGrowth, self)
    self:WatchDataChanged(Fields.MaxTrainingLevel, self.RecordGrowth, self)
    self:RecordGuide(self:GetTable(Fields.Guide))
    self:RecordGrowth()
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

--- 在业务组件清理前结束；重复登出不重复累计在线时间。
function Component:EndSession()
    if not self._startedAt or self._ended then
        return
    end
    self:AccountTime()
    self._ended = true
end

--- 引导进入下一步才表示上一动作完成；三段计时提醒只保留装备完成点。
--- @param data table 权威引导数据。
--- @return number? 可上报的漏斗步骤。
function Component:GetGuideStep(data)
    local first = data.guideMap and data.guideMap.FirstLootGuide
    if first and first.state == "Finished" then
        return 7
    end
    if first and first.state == "Running" then
        return math.min(first.stepIndex, 6)
    end
    return nil
end

--- 从开始点记录已完成动作，持久进度去重；未建立新版流程的测试档不补报。
--- @param data table 已提交的权威引导数据。
function Component:RecordGuide(data)
    if not self._startedAt or self._ended then
        return
    end
    local step = self:GetGuideStep(data)
    local previous = self:GetNumber(Fields.FirstLootV2Step)
    if step and step > previous and (previous > 0 or step == 1) then
        self:SetNumber(Fields.FirstLootV2Step, step)
        self:Funnel(GUIDE_VERSION, "LifetimeV2", step, STEPS[step],
            {GUIDE_VERSION, "CompletedActions", VERSION})
    end
    if step == 7 then
        self:RecordGrowth()
    end
end

--- 项目专用通用漏斗沿用框架的开关、Studio 过滤与异常隔离。
--- @param name string 稳定漏斗名。
--- @param sessionId string 官方漏斗会话标识，不作为自定义维度。
--- @param step number 从 1 开始的步骤。
--- @param stepName string 稳定步骤名。
--- @param fields table 三个字符串字段。
function Component:Funnel(name, sessionId, step, stepName, fields)
    if self._enabled then
        FS.AnalyticsManager:Call(self._node, function()
            AnalyticsService:LogFunnelStepEvent(self._node, name, sessionId, step, stepName, {
                [Enum.AnalyticsCustomFieldKeys.CustomField01.Name] = fields[1],
                [Enum.AnalyticsCustomFieldKeys.CustomField02.Name] = fields[2],
                [Enum.AnalyticsCustomFieldKeys.CustomField03.Name] = fields[3],
            })
        end)
    end
end

--- 从权威持久进度恢复最高里程碑；后续步骤由平台自动计入前序完成。
function Component:RecordGrowth()
    if not self:IsSessionActive() then
        return
    end
    local guideStep = self:GetGuideStep(self:GetTable(Fields.Guide))
    local step = guideStep == 7 and 1 or 0
    if self:GetNumber(Fields.RebirthCount) > 0 then
        step = 2
    end
    local level = self:GetNumber(Fields.MaxTrainingLevel)
    for index = 2, 3 do
        if level >= _G.GameEnum.WorldTransferConfig[index].NeedTrainingLevel then
            step = index + 1
        end
    end
    if step > (self._growthStep or 0) then
        self._growthStep = step
        self:Funnel("GrowthV1", "LifetimeV1", step, GROWTH_STEPS[step], {VERSION, "Progression", "Lifetime"})
    end
end

--- 余额区间固定为低基数维度，精确余额通过独立数值事件查看。
--- @param diamonds number 服务端钻石余额。
--- @return string 进入商店时的余额区间。
local function DiamondBucket(diamonds)
    if diamonds <= 0 then
        return "0"
    elseif diamonds < 50 then
        return "1-49"
    elseif diamonds < 200 then
        return "50-199"
    end
    return "200+"
end

--- 按阶段发送流程事件及服务端余额；同一流程每步最多一次。
--- @param flow table 当前购买流程。
--- @param step number 购买步骤 1 到 4。
--- @param diamonds number 该步骤的权威钻石余额。
function Component:RecordPurchaseStep(flow, step, diamonds)
    if step <= flow.step then
        return
    end
    flow.step = step
    self:Funnel("RobuxPurchaseV1", flow.id, step, PURCHASE_STEPS[step], {flow.bucket, "CurrencyShop", VERSION})
    self:Custom("RobuxPurchaseDiamonds", diamonds,
        {PURCHASE_STEPS[step], flow.product or "None", flow.bucket})
end

--- 新开页面或上次流程结束后，建立独立的商店曝光流程。
--- @return table 当前仅到达商店曝光步骤的流程。
function Component:OpenPurchaseFlow()
    local flow = self._shopFlow
    if not flow or flow.step >= 2 then
        local diamonds = self:GetNumber(Fields.Diamonds)
        flow = {id = FX.GenObjectID(), bucket = DiamondBucket(diamonds), step = 0}
        self._shopFlow = flow
        self:RecordPurchaseStep(flow, 1, diamonds)
    end
    return flow
end

--- 只接收货币商店的有限动作；身份、余额、商品范围和频率均在服务端确定。
--- @param action any Open、Close、Select、PromptRequested 或 Cancel。
--- @param productId any Select/PromptRequested 使用的真实产品 ID。
--- @param attemptId any 客户端本次点击标识，仅用于匹配取消与弹窗动作。
function Component:RecordShopAction(action, productId, attemptId)
    if not self:IsSessionActive() then
        return
    end
    if action == "Close" then
        self._shopFlow = nil
        return
    elseif action == "Open" then
        local now = os.clock()
        if not self._lastShopOpen or now - self._lastShopOpen >= 1 then
            self._lastShopOpen = now
            self:OpenPurchaseFlow()
        end
        return
    end
    if action ~= "Select" and action ~= "PromptRequested" and action ~= "Cancel" then
        return
    end
    if type(attemptId) ~= "string" or #attemptId == 0 or #attemptId > 64 then
        return
    end
    if type(productId) ~= "number" or productId ~= productId or productId % 1 ~= 0 or productId <= 0 then
        return
    end
    local goods = _G.Provider:GetGoodsConfig(productId)
    if not goods then
        return
    end
    local inShop = false
    for index, item in ipairs(_G.ShopConfig.MiniCoinData) do
        if item.DevGoodsId == goods.DevGoodsId then
            inShop = true
            break
        end
    end
    if not inShop then
        return
    end
    local flow = self._purchaseFlows[productId]
    if action == "Cancel" then
        self:CancelPurchaseFlow(productId, attemptId)
    elseif action == "Select" then
        local now = os.clock()
        if flow or (self._lastShopSelect and now - self._lastShopSelect < 1) then
            return
        end
        self._lastShopSelect = now
        flow = self:OpenPurchaseFlow()
        flow.product = tostring(goods.DevGoodsId)
        flow.attemptId = attemptId
        self._purchaseFlows[productId] = flow
        self:RecordPurchaseStep(flow, 2, self:GetNumber(Fields.Diamonds))
    elseif flow and flow.attemptId == attemptId and flow.step == 2 then
        self:RecordPurchaseStep(flow, 3, self:GetNumber(Fields.Diamonds))
    end
end

--- 取消、预检失败或弹窗异常后结束对应尝试；已支付流程保留等待收据。
--- @param productId number 平台产品 ID。
--- @param attemptId string 本次点击标识，不允许重试取消清理上一笔流程。
function Component:CancelPurchaseFlow(productId, attemptId)
    local flow = self._purchaseFlows and self._purchaseFlows[productId]
    if flow and flow.attemptId == attemptId then
        self._purchaseFlows[productId] = nil
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
    local flow = self._purchaseFlows[receipt.ProductId]
    self._purchaseFlows[receipt.ProductId] = nil
    return {
        first = first, playtime = self:AccountTime(), product = tostring(goods.DevGoodsId),
        flow = flow and table.clone(flow), diamonds = self:GetNumber(Fields.Diamonds),
    }
end

--- 仅消费保存成功前取得的快照，不在保存后重新推断首付。
--- @param snapshot table 与收据一起持久化的元数据。
function Component:ReportPurchase(snapshot)
    if snapshot.flow then
        self:RecordPurchaseStep(snapshot.flow, 4, snapshot.diamonds)
    elseif snapshot.diamonds ~= nil then
        self:Custom("RobuxPurchaseDiamonds", snapshot.diamonds,
            {"PurchaseGranted", snapshot.product, "Unattributed"})
    end
    if snapshot.first then
        self:Custom("FirstPurchasePlaytime", snapshot.playtime,
            {snapshot.product, "OnlineSinceFirstLogin", VERSION})
    end
end

return Component
