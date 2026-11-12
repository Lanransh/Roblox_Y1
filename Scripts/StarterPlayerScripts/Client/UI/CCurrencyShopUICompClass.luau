-- 货币商店业务子类：配置驱动展示，钻石由服务端结算，Robux 交给平台收据。
local FX = _G.FX
local FXLoader = FX.Loader
local Text = FXLoader:RequireShared("Scripts/Game/Shared/Text")
local TranslationTexts = Text.Define("CurrencyShopUI", {
    Processing = "Payment completed. Waiting for your reward.",
    Training = "Training x{rate}",
    Capacity = "+{count:int} Carry Slot",
    CapacityDesc = "Permanently carry {count:int} collectibles.",
    Diamonds = "{value} Diamonds",
    RateMaxed = "You have reached the maximum training multiplier.",
})
FXLoader:RequireFromParent(script, "Generated/CCurrencyShopView")
local Shop = FXLoader:RequireShared("Scripts/Game/Shared/CurrencyShop")
local GameUtility = FXLoader:RequireShared("Scripts/Game/Shared/GameUtility")
local RockLevel = FXLoader:RequireShared("Scripts/Game/Shared/RockLevel")
local Fields = _G.PlayerDataConfig
local MarketplaceService = game:GetService("MarketplaceService")
local Component = FX.Class("CCurrencyShopUICompClass", "CCurrencyShopView")

-- 按商品含义选择渐变：优惠粉、周卡绿/紫，钻石包随档位使用青/橙/金。
local RobuxCardStyles = {
    [100] = "Pink", [111] = "Green", [112] = "Purple",
    [101] = "Cyan", [102] = "Orange", [103] = "Gold",
}

--- 主界面按此名称打开业务组件。
--- @return string 玩家内组件名称。
function Component:GetCompName()
    return "CCurrencyShopUIComp"
end

--- 复用生成类节点及事件；首次就绪保持关闭。
function Component:OnReady()
    Component.Super.OnReady(self)
    self.Root.ResetOnSpawn = false
    self.Root.DisplayOrder = 10
    self._commonUI = self:GetPlayerObject():RequireComponent("FCCommonUIComp")
    self._commonUI:RegisterTrainingClickModal(self.Root)
    self._localization = self._commonUI.Localization
    self._data = self:GetTable(Fields.CurrencyShopData)
    self._prices = {}
    self.Config = {products = {}}
    self.State = {tab = "Diamond", open = false}
    self:Hide()
    self:BindUIData()
    self:TrackConnection(self._localization.Changed:Connect(function()
        self:BuildProducts()
        self:RefreshUI()
    end))
    --- 平台弹窗关闭只恢复交互，不作为到账证据。
    --- @param userId number 平台提供的玩家 ID。
    --- @param productId number 真实 Developer Product ID。
    --- @param purchased boolean 平台是否完成支付，奖励仍等待收据与数据同步。
    self:TrackConnection(MarketplaceService.PromptProductPurchaseFinished:Connect(function(userId, productId, purchased)
        if userId == self:GetPlayerNode().UserId and productId == self._promptProductId then
            if not purchased then
                self:ReportPurchaseAnalytics("Cancel", self._purchaseGoodsId, self._purchaseAttemptId)
            end
            self._purchaseAttemptId = nil
            self._purchaseGoodsId = nil
            self._promptProductId = nil
            self._busy = false
            self.State.pending = nil
            if purchased then
                self._commonUI:ShowLocalizedTips(TranslationTexts.Processing)
            end
            self:RefreshUI()
        end
    end))
    --- 通行证弹窗关闭仅恢复交互，实际奖励由服务端平台事件核验。
    --- @param passId number 通行证 ID。
    --- @param purchased boolean 是否购买成功。
    FX.Network:RegServerMsgCallback("S2C_GamePassPromptFinished", function(passId, purchased)
        if passId == self._promptGamePassId then
            if not purchased then
                self:ReportPurchaseAnalytics("Cancel", self._purchaseGoodsId, self._purchaseAttemptId)
            end
            self._promptGamePassId = nil
            self._purchaseAttemptId = nil
            self._purchaseGoodsId = nil
            self._busy = false
            self.State.pending = nil
            if purchased then
                self._commonUI:ShowLocalizedTips(TranslationTexts.Processing)
            end
            self:RefreshUI()
        end
    end)
    self:LoadPrices()
end

--- 只查询尚未取得的报价，重新打开商店时重试失败商品，不重复启动正在进行的查询。
function Component:LoadPrices()
    if self._priceTask then
        return
    end
    self._priceTask = task.defer(function()
        for index, item in ipairs(_G.ShopConfig.MiniCoinData) do
            local goods = _G.GoodsConfig.GoodsData[item.DevGoodsId]
            local productId = goods and goods.RobloxProductId
            if type(productId) == "number" and productId > 0 and self._prices[item.DevGoodsId] == nil then
                local ok, info = pcall(function()
                    local infoType = goods.ProductType == "GamePass" and Enum.InfoType.GamePass or Enum.InfoType.Product
                    return MarketplaceService:GetProductInfoAsync(productId, infoType)
                end)
                if ok and type(info) == "table" and type(info.PriceInRobux) == "number" then
                    self._prices[item.DevGoodsId] = info.PriceInRobux
                    self:BuildProducts()
                    self:RefreshUI()
                end
            end
        end
        self._priceTask = nil
        self:BuildProducts()
        self:RefreshUI()
    end)
end

--- 购买和重登后的服务端数据驱动限购与下一档展示。
function Component:BindUIData()
    --- 闭包已捕获组件，不传 owner，保证首个参数为同步数据。
    --- @param data table 服务端同步的 CurrencyShopData。
    self:WatchDataChanged(Fields.CurrencyShopData, function(data)
        self:ApplyShopData(data)
    end)
end

--- 数据订阅和购买回包共用同一更新入口，避免其他组件直接写私有快照。
--- @param data table 服务端权威商店进度。
function Component:ApplyShopData(data)
    self._data = data
    self:BuildProducts()
    self:RefreshUI()
end

--- 读取已准备的钻石商品，供确认页复用当前语言和进度。
--- @param goodsId number 钻石商品配置 ID。
--- @return table? 当前展示商品；未展示的独立商品返回 nil。
function Component:GetProduct(goodsId)
    for index, product in ipairs(self.Config.products) do
        if product.currency == "Diamond" and product.goodsId == goodsId then
            return product
        end
    end
    return nil
end

--- 将配置与权威进度转换为渐变卡片，训练倍率显示不超过钻石升级上限。
function Component:BuildProducts()
    local products, groups = {}, {}
    for index, item in ipairs(_G.ShopConfig.GemCoinData) do
        if not groups[item.Group] then
            groups[item.Group] = true
            local nextItem = Shop.GetNextGemGoods(item.Group, self._data)
            local display = nextItem or item
            local goods = _G.GoodsConfig.GemGoodsData[display.GemGoodsId]
            local title, description
            if goods.BuyHandler == "TrainingRateLevel" then
                local level = nextItem and self._data.trainingLevel + 1 or self._data.trainingLevel
                title = Text.Tr(TranslationTexts.Training, {
                    rate = GameUtility.NumberToText(math.min(_G.GameConfig.TrainingRateConfig[level].Rate, Shop.MaxTrainingRate)),
                })
                description = goods.Desc
            else
                title = Text.Tr(TranslationTexts.Capacity, {count = goods.NumberArray[1]})
                description = Text.Tr(TranslationTexts.CapacityDesc, {
                    count = RockLevel.LootCapacity + self._data.capacity + (nextItem and goods.NumberArray[1] or 0),
                })
            end
            table.insert(products, {id = "group_" .. item.Group, currency = "Diamond",
                goodsId = display.GemGoodsId, title = "",
                description = goods.BuyHandler == "TrainingRateLevel" and description or "",
                titleText = title,
                descriptionText = goods.BuyHandler ~= "TrainingRateLevel" and description or nil,
                price = goods.Price, icon = display.IconId, soldOut = nextItem == nil,
                allowSoldOutAction = item.Group == 1,
                cardStyle = goods.BuyHandler == "TrainingRateLevel" and "Orange" or "Cyan"})
        end
    end
    for index, item in ipairs(_G.ShopConfig.MiniCoinData) do
        local goods = _G.GoodsConfig.GoodsData[item.DevGoodsId]
        local title, description
        if goods.BuyHandler == "AddGem" then
            title = Text.Tr(TranslationTexts.Diamonds, {
                value = GameUtility.NumberToText(goods.NumberArray[1]),
            })
            description = goods.Desc
        else
            local itemId = goods.KVTable.ItemId
            title = _G.ItemConfig.Display[itemId].Name
            description = _G.ItemConfig.Display[itemId].Desc
        end
        local count = self._data.robuxBought[tostring(item.DevGoodsId)] or 0
        table.insert(products, {id = "robux_" .. item.DevGoodsId, currency = "Robux",
            goodsId = item.DevGoodsId, productId = goods.RobloxProductId, productType = goods.ProductType,
            title = goods.BuyHandler == "AddGem" and "" or title, description = description, icon = item.IconId,
            titleText = goods.BuyHandler == "AddGem" and title or nil,
            cardStyle = RobuxCardStyles[item.DevGoodsId],
            price = self._prices[item.DevGoodsId] or goods.Price,
            unavailable = self._prices[item.DevGoodsId] == nil,
            soldOut = goods.BuyLimit ~= nil and count >= goods.BuyLimit})
    end
    self.Config.products = products
end

--- 向展示类提供全局购买锁，不维护无法显示的消息字段。
--- @return table 完整商店展示状态。
function Component:GetUIState()
    self.State.busy = self._busy == true
    return self.State
end

--- 钻石和 Robux 价格沿用项目统一数值格式。
--- @param value number 原始价格。
--- @return string 展示价格。
function Component:FormatNumber(value)
    return GameUtility.NumberToText(value)
end

--- 打开时刷新商品页并重试未取得的报价，不重复绑定事件。
function Component:OnShow()
    self.State.open = true
    if self.State.tab == "Robux" then
        self:ReportPurchaseAnalytics("Open")
    end
    self:RefreshUI()
    self:LoadPrices()
end

--- 数据同步后仍保留关闭状态。
function Component:OnHide()
    self.State.open = false
    self:ReportPurchaseAnalytics("Close")
end

--- 统计单向发送并隔离失败，不参与界面、购买资格或发奖。
--- @param action string Open、Close、Select、PromptRequested 或 Cancel。
--- @param goodsId number? 业务商品 ID，两种平台商品使用同一命名空间。
--- @param attemptId string? 本次点击标识，防止同商品重试覆盖旧流程。
function Component:ReportPurchaseAnalytics(action, goodsId, attemptId)
    pcall(function()
        FX.Network:SendMsgToServer("C2S_RobuxPurchaseAnalytics", action, goodsId, attemptId)
    end)
end

--- 满级训练倍率只提示原因；可购买商品沿用钻石确认页或平台窗口。
--- @param action string SelectTab、Purchase 或 Close。
--- @param payload table 生成类提供的页签或稳定商品 ID。
function Component:OnUIAction(action, payload)
    if action == "Close" then
        self:Hide()
    elseif action == "SelectTab" then
        if payload.tab ~= self.State.tab then
            self:ReportPurchaseAnalytics(payload.tab == "Robux" and "Open" or "Close")
        end
        self.State.tab = payload.tab
        self:RefreshUI()
    elseif action == "Purchase" and not self._busy then
        for index, product in ipairs(self.Config.products) do
            if product.id == payload.productId and product.id == "group_1" and product.soldOut then
                self._commonUI:ShowLocalizedTips(TranslationTexts.RateMaxed)
                return
            end
            if product.id == payload.productId and not product.soldOut and not product.unavailable then
                if product.currency == "Diamond" then
                    self:GetPlayerObject():RequireComponent("CShopPurchaseUIComp"):OpenProduct(product)
                else
                    self:Purchase(product)
                end
                return
            end
        end
    end
end

--- 主界面快捷入口复用商店商品、限购判断和同一购买锁，不需要先打开商店。
--- @param goodsId number Robux 商品配置 ID。
function Component:PurchaseGoods(goodsId)
    local product = self:GetRobuxProduct(goodsId)
    if not product or product.soldOut then
        return
    end
    if product.unavailable then
        self:LoadPrices()
        self._commonUI:ShowLocalizedTips(self.BaseViewTranslationTexts.Unavailable)
        return
    end
    self:Purchase(product)
end

--- 向快捷入口提供平台报价；各组件 OnReady 无固定顺序，商店未就绪时返回 nil。
--- @param goodsId number Robux 商品配置 ID。
--- @return table? 当前 Robux 商品；未展示时返回 nil。
function Component:GetRobuxProduct(goodsId)
    if not self.Config then
        return nil
    end
    for index, product in ipairs(self.Config.products) do
        if product.currency == "Robux" and product.goodsId == goodsId then
            return product
        end
    end
    return nil
end

--- 按商品类型进行服务端预检，通行证已拥有时由服务端补发，其他商品沿用收据。
--- @param product table 所选 Robux 商品快照，包含平台 productId。
function Component:Purchase(product)
    if self._busy then
        return
    end
    self._busy = true
    self.State.pending = product.id and {[product.id] = true} or nil
    self:RefreshUI()
    self._requestTask = task.defer(function()
        local attemptId = FX.GenObjectID()
        local isGamePass = product.productType == "GamePass"
        self._purchaseAttemptId = attemptId
        self._purchaseGoodsId = product.goodsId
        self:ReportPurchaseAnalytics("Select", product.goodsId, attemptId)
        local ok, result = pcall(function()
            if isGamePass then
                local status = FX.Network:InvokeServer("C2S_CheckGamePassPurchase", product.goodsId)
                if status == "Prompt" then
                    self._promptGamePassId = product.productId
                    MarketplaceService:PromptGamePassPurchase(self:GetPlayerNode(), product.productId)
                    return true
                end
                return status == "Owned" and "Owned" or false
            end
            self._promptProductId = product.productId
            return self._commonUI:ShowDeveloperBuyUI(product.productId)
        end)
        self._requestTask = nil
        if not ok or not result or result == "Owned" then
            self:ReportPurchaseAnalytics("Cancel", product.goodsId, attemptId)
            self._purchaseAttemptId = nil
            self._purchaseGoodsId = nil
            self._busy = false
            self.State.pending = nil
            self._promptProductId = nil
            self._promptGamePassId = nil
            if result ~= "Owned" or not ok then
                self._commonUI:ShowLocalizedTips(self.BaseViewTranslationTexts.Unavailable)
            end
        else
            self:ReportPurchaseAnalytics("PromptRequested", product.goodsId, attemptId)
        end
        self:RefreshUI()
    end)
end

--- 取消组件拥有的请求任务，基类释放卡片和事件连接。
function Component:Dtor()
    FX.Network:UnRegServerMsgCallback("S2C_GamePassPromptFinished")
    if self._requestTask then
        task.cancel(self._requestTask)
    end
    if self._priceTask then
        task.cancel(self._priceTask)
    end
    Component.Super.Dtor(self)
end

return Component
