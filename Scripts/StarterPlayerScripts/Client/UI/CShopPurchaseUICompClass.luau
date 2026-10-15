-- 钻石单件购买业务：复用生成页面，余额与升级资格始终由服务端结算。
local FX = _G.FX
local FXLoader = FX.Loader
FXLoader:RequireFromParent(script, "Generated/CShopPurchaseView")
local GameUtility = FXLoader:RequireShared("Scripts/Game/Shared/GameUtility")
local Component = FX.Class("CShopPurchaseUICompClass", "CShopPurchaseView")

--- 主商店通过此名称打开单件购买页。
--- @return string 玩家内组件名称。
function Component:GetCompName()
    return "CShopPurchaseUIComp"
end

--- 绑定生成节点和本地化监听，未选择商品前保持关闭。
function Component:OnReady()
    Component.Super.OnReady(self)
    self._rootNode = self:GetRootNode()
    self._rootNode.ResetOnSpawn = false
    self._rootNode.DisplayOrder = 20
    self._commonUI = self:GetPlayerObject():RequireComponent("FCCommonUIComp")
    self._commonUI:RegisterTrainingClickModal(self._rootNode)
    self._localization = self._commonUI.Localization
    self:Hide()
    self:TrackConnection(self._localization.Changed:Connect(function()
        if self._product then
            self:RefreshUI()
        end
    end))
end

--- 余额不足时转到钻石充值页，否则叠加购买页；购买中不允许切换目标。
--- @param product table 主商店生成的钻石商品，包含稳定 goodsId 与展示信息。
function Component:OpenProduct(product)
    if self.State and self.State.pending then
        return
    end
    if self:GetNumber(_G.PlayerDataConfig.Diamonds) < product.price then
        self:Hide()
        local shop = self:GetPlayerObject():RequireComponent("CCurrencyShopUIComp")
        shop.State.tab = "Robux"
        shop:Show()
        shop:RefreshUI()
        self._commonUI:ShowLocalizedTips("CurrencyShop.NeedDiamonds")
        return
    end
    self._product = product
    self.State = {status = "Ready", pending = false}
    self:BindUIData()
    self:Show()
end

--- 根据当前语言重建商品文案，沿用主商店的配置和权威进度。
--- @param state table 当前购买状态。
function Component:Render(state)
    local shop = self:GetPlayerObject():RequireComponent("CCurrencyShopUIComp")
    shop:BuildProducts()
    local product = self._product
    for index, candidate in ipairs(shop.Config.products) do
        if candidate.goodsId == product.goodsId and candidate.currency == "Diamond" then
            product = candidate
            break
        end
    end
    self.Config = {itemId = tostring(self._product.goodsId), name = product.title,
        category = self._localization:FormatByKey("ShopPurchase.Category"),
        description = product.description,
        price = self._product.price, icon = self._product.icon}
    Component.Super.Render(self, state)
    for index, label in ipairs({self.ItemNameTxt, self.CategoryTxt, self.DescriptionTxt, self.ButtonTxt}) do
        label.AutoLocalize = false
    end
    if state.pending then
        self.ButtonTxt.Text = self._localization:FormatByKey("ShopPurchase.Buying")
    else
        self.ButtonTxt.Text = self._localization:FormatByKey("ShopPurchase.Price", {
            value = GameUtility.NumberToText(self.Config.price),
        })
    end
end

--- 购买只提交固定商品 ID；成败均提示，收益只使用服务端实际结算结果。
--- @param action string 生成页面提供的 Buy 或 Close。
--- @param payload table Buy 携带稳定 itemId，Close 为空表。
function Component:OnUIAction(action, payload)
    if action == "Close" then
        self:Hide()
    elseif action == "Buy" and payload.itemId == self.Config.itemId
        and self.State.status == "Ready" and not self.State.pending then
        local goodsId = self._product.goodsId
        self.State = {status = "Ready", pending = true}
        self:RefreshUI()
        self._requestTask = task.defer(function()
            local ok, result = pcall(function()
                return FX.Network:InvokeServer("C2S_BuyCurrencyShopGoods", goodsId)
            end)
            self._requestTask = nil
            if ok and type(result) == "table" then
                if result.success then
                    local shop = self:GetPlayerObject():RequireComponent("CCurrencyShopUIComp")
                    shop._data = result.data
                    shop:RefreshUI()
                    self.State = {status = "Ready", pending = false}
                    self._commonUI:ShowLocalizedTips(result.key, result.arguments)
                    self:Hide()
                    return
                end
                self.State = {status = "Ready", pending = false}
                self._commonUI:ShowLocalizedTips(result.key, result.arguments)
            else
                self.State = {status = "Ready", pending = false}
                self._commonUI:ShowLocalizedTips("Common.Unknown")
            end
            self:RefreshUI()
        end)
    end
end

--- 取消组件拥有的请求任务，基类清理节点监听与弹窗动画。
function Component:Dtor()
    if self._requestTask then
        task.cancel(self._requestTask)
    end
    Component.Super.Dtor(self)
end

return Component
