-- VIP 商品业务接入：通用介绍窗负责展示，资格只使用服务端同步数据。
local FX = _G.FX
local FXLoader = FX.Loader
local Text = FX.Text
local GameUtility = FXLoader:RequireShared("Scripts/Game/Shared/GameUtility")
FXLoader:RequireFromParent(script, "Generated/CPurchaseIntroView")
local MarketplaceService = game:GetService("MarketplaceService")
local Fields = _G.PlayerDataConfig
local Component = FX.Class("CVipPurchaseUICompClass", "CPurchaseIntroView")

local TranslationTexts = Text.Define("VipPurchase", {
    Title = "VIP",
    Name = "2× Loot Sale Value",
    Category = "VIP BENEFIT",
    Description = "Unlock VIP to sell your loot for twice the value.",
})

--- 主界面通过此协作名称打开 VIP 商品介绍。
--- @return string 玩家内组件名称。
function Component:GetCompName()
    return "CVipPurchaseUIComp"
end

--- 父类只绑定展示节点；业务准备配置和权威订阅，初始保持关闭。
function Component:OnReady()
    Component.Super.OnReady(self)
    self._goods = _G.GoodsConfig.GoodsData[1]
    self._commonUI = self:GetPlayerObject():RequireComponent("FCCommonUIComp")
    local root = self:GetRootNode()
    root.ResetOnSpawn = false
    self._commonUI:RegisterTrainingClickModal(root)
    self.Config = {
        itemId = tostring(self._goods.DevGoodsId),
        title = TranslationTexts.Title,
        name = TranslationTexts.Name,
        category = TranslationTexts.Category,
        description = TranslationTexts.Description,
        icon = "rbxassetid://104326662511955",
        currency = "Robux",
    }
    self.State = {status = "Ready", pending = false}
    self:Hide()
    self:BindUIData()
    --- 语言切换由通用展示层重新求值文案定义。
    self:TrackConnection(self._commonUI.Localization.Changed:Connect(function()
        self:RefreshUI()
    end))
    --- 平台取消恢复按钮；已付款继续等待服务端同步，不据此授予 VIP。
    --- @param userId number 平台提供的购买玩家 ID。
    --- @param productId number 平台商品 ID。
    --- @param purchased boolean 是否完成支付。
    self:TrackConnection(MarketplaceService.PromptProductPurchaseFinished:Connect(function(userId, productId, purchased)
        if userId == self:GetPlayerNode().UserId and productId == self._goods.RobloxProductId then
            self.State.pending = purchased and self.State.status ~= "Purchased"
            self:RefreshUI()
        end
    end))
end

--- 资格变化直接使用同步字段，父展示层决定已拥有状态和购买许可。
function Component:BindUIData()
    --- 首次订阅立即回放存档状态，后续只接受服务端同步的 VIP 资格。
    --- @param isVip boolean 服务端同步的永久 VIP 标记。
    self:WatchDataChanged(Fields.Vip, function(isVip)
        self.State.status = isVip and "Purchased" or "Ready"
        if isVip then
            self.State.pending = false
        end
        self:RefreshUI()
    end)
end

--- 打开前重查失败报价；已拥有时不再展示购买入口。
function Component:Open()
    if self:GetFlag(Fields.Vip) then
        return
    end
    self:LoadPrice()
    self:Show()
end

--- 实时平台报价成功后才启用购买，不拿本地配置价代替玩家实际价格。
function Component:LoadPrice()
    if self._priceTask or self.Config.price ~= nil then
        return
    end
    self._priceTask = task.defer(function()
        --- 平台查询属于外部边界，失败保留无报价状态，重开可重试。
        --- @return table 平台商品信息。
        local ok, info = pcall(function()
            return MarketplaceService:GetProductInfoAsync(self._goods.RobloxProductId, Enum.InfoType.Product)
        end)
        self._priceTask = nil
        if ok and type(info) == "table" and type(info.PriceInRobux) == "number" and info.IsForSale ~= false then
            self.Config.price = info.PriceInRobux
        end
        self:RefreshUI()
    end)
end

--- 价格沿用项目统一数量格式。
--- @param value number 平台报价。
--- @return string 展示价格。
function Component:FormatNumber(value)
    return GameUtility.NumberToText(value)
end

--- 购买复用现有服务端预检和平台窗口，客户端不发放权益。
--- @param action string 通用介绍窗发送的 Buy 或 Close。
--- @param payload table Buy 携带当前稳定 itemId，Close 不使用参数。
function Component:OnUIAction(action, payload)
    if action == "Close" then
        self:Hide()
    elseif action == "Buy" and payload.itemId == self.Config.itemId
        and not self:GetFlag(Fields.Vip) and not self.State.pending and self.Config.price ~= nil then
        self.State.pending = true
        self:RefreshUI()
        self._requestTask = task.defer(function()
            --- 预检拒绝或平台调用失败时恢复交互，真实奖励仍由收据处理。
            --- @return boolean 是否已发起平台购买。
            local ok, prompted = pcall(function()
                return self._commonUI:ShowDeveloperBuyUI(self._goods.RobloxProductId)
            end)
            self._requestTask = nil
            if not ok or not prompted then
                self.State.pending = false
                self._commonUI:ShowLocalizedTips(self.BaseViewTranslationTexts.Unavailable)
                self:RefreshUI()
            end
        end)
    end
end

--- 取消自有异步任务，节点监听和适配由父类释放。
function Component:Dtor()
    if self._priceTask then
        task.cancel(self._priceTask)
    end
    if self._requestTask then
        task.cancel(self._requestTask)
    end
    Component.Super.Dtor(self)
end

return Component
