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
    SoldOut = "Sold Out",
    Unavailable = "Unavailable",
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
        self:RefreshUI()
    end))
    --- 平台弹窗关闭只恢复交互，不作为到账证据。
    --- @param userId number 平台提供的玩家 ID。
    --- @param productId number 真实 Developer Product ID。
    --- @param purchased boolean 平台是否完成支付，奖励仍等待收据与数据同步。
    self:TrackConnection(MarketplaceService.PromptProductPurchaseFinished:Connect(function(userId, productId, purchased)
        if userId == self:GetPlayerNode().UserId and productId == self._promptProductId then
            if not purchased then
                self:ReportPurchaseAnalytics("Cancel", productId, self._purchaseAttemptId)
            end
            self._purchaseAttemptId = nil
            self._promptProductId = nil
            self._busy = false
            self._messageKey = purchased and TranslationTexts.Processing or nil
            self:RefreshUI()
        end
    end))
    --- 从平台读取当前玩家看到的价格，未能读取的付费商品暂不开放。
    self._priceTask = task.defer(function()
        for index, item in ipairs(_G.ShopConfig.MiniCoinData) do
            local goods = _G.GoodsConfig.GoodsData[item.DevGoodsId]
            local productId = goods and goods.RobloxProductId
            if type(productId) == "number" and productId > 0 then
                local ok, info = pcall(function()
                    return MarketplaceService:GetProductInfoAsync(productId, Enum.InfoType.Product)
                end)
                if ok and type(info.PriceInRobux) == "number" then
                    self._prices[item.DevGoodsId] = info.PriceInRobux
                end
            end
        end
        self._priceTask = nil
        self:RefreshUI()
    end)
end

--- 购买和重登后的服务端数据驱动限购与下一档展示。
function Component:BindUIData()
    --- 闭包已捕获组件，不传 owner，保证首个参数为同步数据。
    --- @param data table 服务端同步的 CurrencyShopData。
    self:WatchDataChanged(Fields.CurrencyShopData, function(data)
        self._data = data
        self._messageKey = nil
        self:RefreshUI()
    end)
end

--- 将配置与权威进度转换为渐变卡片，每组只显示下一档或完成态。
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
                    rate = GameUtility.NumberToText(_G.GameConfig.TrainingRateConfig[level].Rate),
                })
                description = Text.TrSource(goods.Desc)
            else
                title = Text.Tr(TranslationTexts.Capacity, {count = goods.NumberArray[1]})
                description = Text.Tr(TranslationTexts.CapacityDesc, {
                    count = RockLevel.LootCapacity + self._data.capacity + (nextItem and goods.NumberArray[1] or 0),
                })
            end
            table.insert(products, {id = "group_" .. item.Group, currency = "Diamond",
                goodsId = display.GemGoodsId, title = title, description = description,
                price = goods.Price, icon = display.IconId, soldOut = nextItem == nil,
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
            description = Text.TrSource(goods.Desc)
        else
            local itemId = goods.KVTable.ItemId
            title = Text.TrSource(_G.ItemConfig.Display[itemId].Name)
            description = Text.TrSource(_G.ItemConfig.Display[itemId].Desc)
        end
        local count = self._data.robuxBought[tostring(item.DevGoodsId)] or 0
        table.insert(products, {id = "robux_" .. item.DevGoodsId, currency = "Robux",
            goodsId = item.DevGoodsId, productId = goods.RobloxProductId,
            title = title, description = description, icon = item.IconId,
            cardStyle = RobuxCardStyles[item.DevGoodsId],
            price = self._prices[item.DevGoodsId] or goods.Price,
            unavailable = self._prices[item.DevGoodsId] == nil,
            soldOut = goods.BuyLimit ~= nil and count >= goods.BuyLimit})
    end
    self.Config.products = products
end

--- 创建卡片时拆出 Robux 字符图标，独立放大并随卡片统一销毁。
--- @param product table 当前商品配置。
--- @param style string 当前卡片渐变样式。
--- @return table 生成类创建的卡片与清理句柄。
function Component:CreateCard(product, style)
    local card = Component.Super.CreateCard(self, product, style)
    if product.currency == "Robux" then
        FXLoader:Here(card.button, "RobuxIcon").Visible = false
        local icon = card.price:Clone()
        icon.Name = "RobuxGlyph"
        icon.Position = UDim2.fromOffset(8, 0)
        icon.Size = UDim2.new(0, 32, 1, 0)
        icon.TextScaled = false
        icon.TextSize = 32
        icon.Text = utf8.char(0xE002)
        icon.Parent = card.button
        card.price.Position = UDim2.fromOffset(44, 0)
        card.price.Size = UDim2.new(1, -52, 1, 0)
    end
    return card
end

--- 保留生成类多色列表布局，补充本地化、数量缩写及业务禁用状态。
--- @param state table 完整界面状态。
function Component:Render(state)
    self:BuildProducts()
    state.message = self._messageKey and Text.Tr(self._messageKey) or ""
    Component.Super.Render(self, state)
    for index, product in ipairs(self.Config.products) do
        local card = self.Cards[product.id]
        if card then
            local key = product.soldOut and TranslationTexts.SoldOut
                or (product.unavailable and TranslationTexts.Unavailable)
            card.price.Text = key and Text.Tr(key)
                or GameUtility.NumberToText(product.price)
            if product.currency == "Robux" then
                card.price.TextSize = key and 20 or 24
            end
            local explainMaxRate = product.id == "group_1" and product.soldOut
            self:SetButtonEnabled(card.button, not self._busy and not product.unavailable
                and (not product.soldOut or explainMaxRate))
        end
    end
end

--- 打开时刷新数据与商品页，不重复绑定事件。
function Component:OnShow()
    self.State.open = true
    if self.State.tab == "Robux" then
        self:ReportPurchaseAnalytics("Open")
    end
    self:RefreshUI()
end

--- 数据同步后仍保留关闭状态。
function Component:OnHide()
    self.State.open = false
    self:ReportPurchaseAnalytics("Close")
end

--- 统计单向发送并隔离失败，不参与界面、购买资格或发奖。
--- @param action string Open、Close、Select、PromptRequested 或 Cancel。
--- @param productId number? 平台产品 ID。
--- @param attemptId string? 本次点击标识，防止同商品重试覆盖旧流程。
function Component:ReportPurchaseAnalytics(action, productId, attemptId)
    pcall(function()
        FX.Network:SendMsgToServer("C2S_RobuxPurchaseAnalytics", action, productId, attemptId)
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

--- Robux 预检或取消支付时恢复交互，奖励仍由平台收据处理。
--- @param product table 所选 Robux 商品快照，包含平台 productId。
function Component:Purchase(product)
    if self._busy then
        return
    end
    self._busy = true
    self._messageKey = nil
    self:RefreshUI()
    self._requestTask = task.defer(function()
        local attemptId = FX.GenObjectID()
        self._purchaseAttemptId = attemptId
        self:ReportPurchaseAnalytics("Select", product.productId, attemptId)
        local ok, result = pcall(function()
            self._promptProductId = product.productId
            return self._commonUI:ShowDeveloperBuyUI(product.productId)
        end)
        self._requestTask = nil
        if not ok or not result then
            self:ReportPurchaseAnalytics("Cancel", product.productId, attemptId)
            self._purchaseAttemptId = nil
            self._busy = false
            self._promptProductId = nil
            self._messageKey = TranslationTexts.Unavailable
        else
            self:ReportPurchaseAnalytics("PromptRequested", product.productId, attemptId)
        end
        self:RefreshUI()
    end)
end

--- 取消组件拥有的请求任务，基类释放卡片和事件连接。
function Component:Dtor()
    if self._requestTask then
        task.cancel(self._requestTask)
    end
    if self._priceTask then
        task.cancel(self._priceTask)
    end
    Component.Super.Dtor(self)
end

return Component
