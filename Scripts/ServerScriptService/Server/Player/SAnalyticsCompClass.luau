-- 项目行为口径与会话计时；购买 GUID 仅用于官方漏斗会话，不作为自定义字段。
local FX, FS = _G.FX, _G.FS
local AnalyticsService = game:GetService("AnalyticsService")
local Players = game:GetService("Players")
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
-- 所有业务分析共用一分钟滑动窗口，留出平台额度余量；失败调用也计入预算。
local requestTimes = {}
local requestHead, requestTail = 1, 0

--- 当前服务器统一限额低于官方 120 + 20 * CCU，不给重试额外额度。
--- @return boolean 当前是否还能发出一次请求。
local function TakeRequestBudget()
    local now = os.clock()
    while requestHead <= requestTail and now - requestTimes[requestHead] >= 60 do
        requestTimes[requestHead] = nil
        requestHead += 1
    end
    if requestHead > requestTail then
        requestHead, requestTail = 1, 0
    end
    local limit = 100 + 15 * #Players:GetPlayers()
    if requestTail - requestHead + 1 >= limit then
        return false
    end
    requestTail += 1
    requestTimes[requestTail] = now
    return true
end

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
    self._analyticsSessionId = FX.GenObjectID()
    self._enabled = Config.AnalyticsEnabled and not FX.IsDeveloper(self:GetPlayerId())
        and not table.find(Config.AnalyticsExcludedUserIds, self:GetPlayerId())
    local purchases = self:GetTable(Fields.PurchaseAnalytics)
    self._readyPurchases = {}
    self._purchaseRetryAt = {}
    self._eventRetryAt = {}
    for purchaseId in pairs(purchases.pending) do
        self._readyPurchases[purchaseId] = true
    end
    self._retryAt = os.clock() + 30
    self:WatchDataChanged(Fields.RebirthCount, self.RecordGrowth, self)
    self:WatchDataChanged(Fields.MaxTrainingLevel, self.RecordGrowth, self)
    self:RecordGuide(self:GetTable(Fields.Guide))
    self:RecordGrowth()
    self:FlushEvents()
    self:FlushPurchases()
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

--- 每秒分批消费队列；平台失败等待三十秒，引导和成长也每三十秒重试。
--- @param serverTime number 框架时间；计时使用同一单调时钟。
function Component:OnUpdate(serverTime)
    self:AccountTime()
    if not self:IsSessionActive() then
        return
    end
    if os.clock() >= self._retryAt then
        self._retryAt = os.clock() + 30
        self:RecordGuide(self:GetTable(Fields.Guide))
        self:RecordGrowth()
    end
    self:FlushEvents()
    self:FlushPurchases()
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

--- 持久化待报目标，成功调用后只在会话内去重；重登依赖平台去重恢复漏报。
--- @param data table 已提交的权威引导数据。
function Component:RecordGuide(data)
    if not self._startedAt or self._ended then
        return
    end
    local step = self:GetGuideStep(data)
    local previous = self:GetNumber(Fields.FirstLootV2Step)
    if step then
        local target = math.max(previous, step)
        if target > previous then
            self:SetNumber(Fields.FirstLootV2Step, target)
        end
        if target > (self._reportedGuideStep or 0) and self:Funnel(GUIDE_VERSION, "LifetimeV2", target,
            STEPS[target], {GUIDE_VERSION, "CompletedActions", VERSION}) then
            self._reportedGuideStep = target
        end
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
--- @return boolean? 本地调用结果；nil 表示暂缓发送，不代表后台入库确认。
function Component:Funnel(name, sessionId, step, stepName, fields)
    return self:SendEvent({kind = "Funnel", name = name, sessionId = sessionId,
        step = step, stepName = stepName, fields = fields})
end

--- 所有漏斗、自定义和经济事件共用预算，不直接绕过框架过滤和异常隔离。
--- @param event table 服务端构造的分析事件。
--- @return boolean? true 为本地调用成功，false 为调用失败，nil 为预算不足。
function Component:SendEvent(event)
    if not self._enabled then
        return false
    end
    if not TakeRequestBudget() then
        return nil
    end
    if event.kind == "Funnel" then
        return FS.AnalyticsManager:Call(self._node, function()
            AnalyticsService:LogFunnelStepEvent(self._node, event.name, event.sessionId, event.step, event.stepName, {
                [Enum.AnalyticsCustomFieldKeys.CustomField01.Name] = event.fields[1],
                [Enum.AnalyticsCustomFieldKeys.CustomField02.Name] = event.fields[2],
                [Enum.AnalyticsCustomFieldKeys.CustomField03.Name] = event.fields[3],
            })
        end)
    elseif event.kind == "Custom" then
        return FS.AnalyticsManager:Custom(self._node, event.name, event.value, event.fields)
    end
    return FS.AnalyticsManager:Economy(self._node, Enum.AnalyticsEconomyFlowType.Sink,
        event.currency, event.amount, event.balance, Enum.AnalyticsEconomyTransactionType.Shop.Name, event.sku)
end

--- 普通事件最多积压二百五十六条，满时淘汰最旧记录，避免客户端动作撑大支付档案。
--- 付款成功快照使用独立队列，不参与此处淘汰。
--- @param event table 服务端构造且尚未发送的事件。
function Component:QueueEvent(event)
    local data = self:GetTable(Fields.AnalyticsEvents)
    local count, oldest = 0, nil
    for eventId in pairs(data.pending) do
        count += 1
        if oldest == nil or tonumber(eventId) < tonumber(oldest) then
            oldest = eventId
        end
    end
    if count >= 256 then
        data.pending[oldest] = nil
        self._eventRetryAt[oldest] = nil
        if not self._queueOverflowWarned then
            self._queueOverflowWarned = true
            warn("[Analytics] ordinary event queue full; oldest event discarded", self:GetPlayerId())
        end
    end
    data.nextId += 1
    data.pending[tostring(data.nextId)] = event
    self:SetTable(Fields.AnalyticsEvents, data)
end

--- 按入队顺序每次处理至多四条，成功才删除；失败只延后本条，不阻塞其他事件。
function Component:FlushEvents()
    if not self._enabled or not self:IsSessionActive() or self._flushingEvents then
        return
    end
    self._flushingEvents = true
    local keys = {}
    for eventId in self:GetTableView(Fields.AnalyticsEvents).pending do
        table.insert(keys, eventId)
    end
    --- 按持久序号排序，避免字典遍历改变步骤发送顺序。
    --- @param left string 左侧事件序号。
    --- @param right string 右侧事件序号。
    --- @return boolean 左侧是否先入队。
    table.sort(keys, function(left, right)
        return tonumber(left) < tonumber(right)
    end)
    local processed = 0
    for index, eventId in ipairs(keys) do
        if processed >= 4 then
            break
        end
        if os.clock() < (self._eventRetryAt[eventId] or 0) then
            continue
        end
        local data = self:GetTable(Fields.AnalyticsEvents)
        local result = self:SendEvent(data.pending[eventId])
        if result == nil then
            break
        end
        processed += 1
        if result then
            data = self:GetTable(Fields.AnalyticsEvents)
            data.pending[eventId] = nil
            self:SetTable(Fields.AnalyticsEvents, data)
            self._eventRetryAt[eventId] = nil
        else
            self._eventRetryAt[eventId] = os.clock() + 30
        end
    end
    self._flushingEvents = false
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
    if step > (self._growthStep or 0) and self:Funnel("GrowthV1", "LifetimeV1", step,
        GROWTH_STEPS[step], {VERSION, "Progression", "Lifetime"}) then
        self._growthStep = step
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

--- 每个阶段的漏斗与余额各自入队；步骤表示已入队，不假定已发送。
--- @param flow table 当前购买流程。
--- @param step number 购买步骤 1 到 4。
--- @param diamonds number 该步骤的权威钻石余额。
function Component:RecordPurchaseStep(flow, step, diamonds)
    if step <= flow.step then
        return
    end
    local stepName = step == 1 and flow.source == "QuickPurchase" and "QuickPurchaseStarted" or PURCHASE_STEPS[step]
    self:QueueEvent({kind = "Funnel", name = flow.funnel, sessionId = flow.id, step = step,
        stepName = stepName, fields = {flow.bucket, flow.source, VERSION}})
    self:QueueEvent({kind = "Custom", name = "RobuxPurchaseDiamonds", value = diamonds,
        fields = {stepName, flow.product or "None", flow.bucket}})
    flow.step = step
end

--- 只在真实打开 Robux 页面时建立曝光，同一次页面访问复用一个漏斗会话。
--- @return table 当前仅到达商店曝光步骤的流程。
function Component:OpenPurchaseFlow()
    local flow = self._shopFlow
    if not flow then
        local diamonds = self:GetNumber(Fields.Diamonds)
        flow = {id = FX.GenObjectID(), bucket = DiamondBucket(diamonds), step = 0,
            funnel = "RobuxPurchaseV2", source = "CurrencyShop"}
        self._shopFlow = flow
        self:RecordPurchaseStep(flow, 1, diamonds)
    end
    return flow
end

--- 只接收货币商店的有限动作；身份、余额、商品范围和频率均在服务端确定。
--- @param action any Open、Close、Select、PromptRequested 或 Cancel。
--- @param goodsId any Select/PromptRequested/Cancel 使用的业务商品 ID，兼容两种平台商品。
--- @param attemptId any 客户端本次点击标识，仅用于匹配取消与弹窗动作。
function Component:RecordShopAction(action, goodsId, attemptId)
    if not self:IsSessionActive() or not self._enabled then
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
    if type(goodsId) ~= "number" or goodsId ~= goodsId or goodsId % 1 ~= 0 or goodsId <= 0 then
        return
    end
    local goods = _G.GoodsConfig.GoodsData[goodsId]
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
    local data = self:GetTable(Fields.PurchaseAnalytics)
    local key = tostring(goodsId)
    local flow = data.flows[key]
    if action == "Cancel" then
        self:CancelPurchaseFlow(goodsId, attemptId)
    elseif action == "Select" then
        local now = os.clock()
        if (flow and flow.ownerSession == self._analyticsSessionId)
            or (self._lastShopSelect and now - self._lastShopSelect < 1) then
            return
        end
        self._lastShopSelect = now
        -- 重登后允许重试未付款商品；有旧尝试时收据无法区分来源，保守取消漏斗归因。
        local ambiguous = flow ~= nil
        flow = self._shopFlow
        if flow then
            -- 页面只保留曝光步骤；每次选择独立推进，取消后重选仍记录商品和余额。
            flow = table.clone(flow)
        else
            local diamonds = self:GetNumber(Fields.Diamonds)
            flow = {id = FX.GenObjectID(), bucket = DiamondBucket(diamonds), step = 0,
                funnel = "RobuxQuickPurchaseV1", source = "QuickPurchase"}
            self:RecordPurchaseStep(flow, 1, diamonds)
        end
        flow.product = tostring(goods.DevGoodsId)
        flow.attemptId = attemptId
        flow.ownerSession = self._analyticsSessionId
        flow.ambiguous = ambiguous
        self:RecordPurchaseStep(flow, 2, self:GetNumber(Fields.Diamonds))
        data.flows[key] = flow
        self:SetTable(Fields.PurchaseAnalytics, data)
    elseif flow and flow.attemptId == attemptId then
        self:RecordPurchaseStep(flow, 3, self:GetNumber(Fields.Diamonds))
        data.flows[key] = flow
        self:SetTable(Fields.PurchaseAnalytics, data)
    end
end

--- 取消、预检失败或弹窗异常后结束对应尝试；已支付流程保留等待收据。
--- @param goodsId number 业务商品 ID。
--- @param attemptId string 本次点击标识，不允许重试取消清理上一笔流程。
function Component:CancelPurchaseFlow(goodsId, attemptId)
    local data = self:GetTable(Fields.PurchaseAnalytics)
    local key = tostring(goodsId)
    local flow = data.flows[key]
    if flow and flow.attemptId == attemptId then
        data.flows[key] = nil
        self:SetTable(Fields.PurchaseAnalytics, data)
    end
end

--- 项目统计开关统一覆盖自定义事件。
--- @param name string 稳定事件名。
--- @param value number 原始数值。
--- @param fields table 三个稳定维度。
--- @return boolean? 平台本地调用结果；nil 表示预算不足，等待后续重试。
function Component:Custom(name, value, fields)
    return self:SendEvent({kind = "Custom", name = name, value = value, fields = fields})
end

--- 业务结算成功后调用一次，零成本解锁不计货币消费。
--- @param currency string Money 或 Diamonds。
--- @param amount number 实际扣款。
--- @param balance number 本笔结算后的余额。
--- @param sku string 稳定商品 SKU。
function Component:Sink(currency, amount, balance, sku)
    if self._enabled and amount > 0 then
        self:QueueEvent({kind = "Economy", currency = currency, amount = amount, balance = balance, sku = sku})
    end
end

--- 开发者商品仍沿用收据回调；业务待报记录与奖励处于同一个事务。
--- @param receipt table 官方收据。
--- @return table 本笔保存成功后唤醒上报的购买标识。
function Component:CapturePurchase(receipt)
    local goods = _G.Provider:GetGoodsConfig(receipt.ProductId)
    return self:CaptureGrantedPurchase(goods, receipt.PurchaseId)
end

--- 两类商品在发奖事务内共用首付资格和持久待报快照，不发送平台事件。
--- @param goods table 已核验并发奖的商品配置。
--- @param purchaseId string 收据 ID 或通行证的稳定业务标识。
--- @param playtime number? 服务端确认本次通行证购买时的累计在线秒数。
--- @return table 保存成功后用于唤醒上报的标识。
function Component:CaptureGrantedPurchase(goods, purchaseId, playtime)
    local data = self:GetTable(Fields.PurchaseAnalytics)
    local key = tostring(goods.DevGoodsId)
    local first = not data.hasPurchase
    data.hasPurchase = true
    if self._enabled then
        data.pending[purchaseId] = {
            first = first, playtime = playtime or self:AccountTime(), product = key,
            flow = data.flows[key], diamonds = self:GetNumber(Fields.Diamonds),
        }
    end
    data.flows[key] = nil
    self:SetTable(Fields.PurchaseAnalytics, data)
    return {purchaseId = purchaseId}
end

--- 历史通行证补发只恢复已付费资格，不推断购买时间或完成当前点击的漏斗。
--- @param goods table 已核验所有权的历史通行证配置。
function Component:RecordHistoricalPurchase(goods)
    local data = self:GetTable(Fields.PurchaseAnalytics)
    data.hasPurchase = true
    data.flows[tostring(goods.DevGoodsId)] = nil
    self:SetTable(Fields.PurchaseAnalytics, data)
end

--- 仅保存成功的购买可以发送；加载时持久待报记录也已满足此条件。
--- @param snapshot table 发奖事务返回的购买标识。
function Component:ReportPurchase(snapshot)
    self._readyPurchases[snapshot.purchaseId] = true
    self:FlushEvents()
    self:FlushPurchases()
end

--- 本地失败保留待报事件；成功清理走正常存档，崩溃重发的漏斗由平台去重。
function Component:FlushPurchases()
    if not self._enabled or not self:IsSessionActive() or self._flushingPurchases then
        return
    end
    self._flushingPurchases = true
    local processed = 0
    for purchaseId in pairs(self._readyPurchases) do
        if processed >= 4 then
            break
        end
        if os.clock() < (self._purchaseRetryAt[purchaseId] or 0) then
            continue
        end
        processed += 1
        local data = self:GetTable(Fields.PurchaseAnalytics)
        local snapshot = data.pending[purchaseId]
        if snapshot then
            if not snapshot.funnelReported then
                local flow = snapshot.flow
                snapshot.funnelReported = not flow or flow.ambiguous or self:Funnel(flow.funnel, flow.id, 4,
                    PURCHASE_STEPS[4], {flow.bucket, flow.source, VERSION})
            end
            if not snapshot.balanceReported then
                snapshot.balanceReported = self:Custom("RobuxPurchaseDiamonds", snapshot.diamonds,
                    {"PurchaseGranted", snapshot.product,
                        snapshot.flow and not snapshot.flow.ambiguous and snapshot.flow.bucket or "Unattributed"})
            end
            if not snapshot.firstReported then
                snapshot.firstReported = not snapshot.first or self:Custom("FirstPurchasePlaytime", snapshot.playtime,
                    {snapshot.product, "OnlineSinceFirstLogin", VERSION})
            end
            -- 平台调用若发生等待，重新取字段，避免覆盖其间其他购买或界面动作。
            data = self:GetTable(Fields.PurchaseAnalytics)
            if snapshot.funnelReported and snapshot.balanceReported and snapshot.firstReported then
                data.pending[purchaseId] = nil
                self._readyPurchases[purchaseId] = nil
                self._purchaseRetryAt[purchaseId] = nil
            else
                data.pending[purchaseId] = snapshot
                self._purchaseRetryAt[purchaseId] = os.clock() + 30
            end
            self:SetTable(Fields.PurchaseAnalytics, data)
        else
            self._readyPurchases[purchaseId] = nil
        end
    end
    self._flushingPurchases = false
end

return Component
