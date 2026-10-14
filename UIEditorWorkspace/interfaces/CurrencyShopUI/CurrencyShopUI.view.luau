--[[
商店接入契约
Config.products: 必填数组；顺序为展示顺序，可为空。
每项 { id: string 稳定商品 ID（全列表唯一）, currency: "Diamond"|"Robux",
title: string, description: string, price: number 非负对应货币数量,
icon: string 可选真实 Roblox Image ID，省略或空字符串显示问号占位,
cardStyle: string 可选 Green|Gold|Cyan|Orange|Purple|Pink，选择可编辑渐变原型；
省略时 Diamond 使用 Green，Robux 使用 Gold。
cardColor: string 旧配置兼容字段，本版不再读取 }。
卡片使用设计原型的鲜艳竖向渐变，游戏可逐商品选择 cardStyle。
商品配置不覆盖卡片底色，购买按钮、文字和描边仍由设计节点定义。
State: 完整输入，非增量：
tab: "Diamond"|"Robux" 必填；open: boolean 必填；
pending: 字典[id]=boolean 可选，省略视为无请求；
数据须在首次 Show 前准备，GetUIConfig/GetUIState 默认读取 self.Config/self.State；
接入 OnReady 先调用父方法，再 BindUIData、Show。更新完整 State 后 RefreshUI。
最小示例：
self.Config = { products = { { id = "speed", currency = "Diamond",
title = "Speed Potion", description = "Boost your movement speed", price = 100,
cardStyle = "Green" } } }
self.State = { tab = "Diamond", open = true }
动作：SelectTab { tab: "Diamond"|"Robux" }；
Purchase { productId: string, currency: "Diamond"|"Robux" }；Close {}。
必需覆写 OnUIAction(action, payload)，无返回值；无其他页面专用覆写。
购买接入按 productId 查询真实商品并验证价格、余额和支付结果；
请求期间 pending[id]=true，完成后更新状态再刷新；商店内不显示结果提示。
Render 不扣款或发奖。图标取 Config.products[].icon；
钻石价格按钮的 DiamondIcon 使用静态资源 rbxassetid://123110249883616，可在设计节点中替换。
空图清除上一商品图并显示问号占位，正式图标需由业务配置提供。
Templates 隐藏原型供两列动态列表克隆，按稳定 ID 更新、排序、删除和清理连接。
空分组清理条目并保持列表空白；异步未就绪时提供 products={}。
]]
local FX = _G.FX
local FXLoader = FX.Loader
local CCurrencyShopView = FX.Class("CCurrencyShopView", "CUIView")

-- 绑定已有节点与页签事件；每张商品卡只连接一次。
function CCurrencyShopView:OnReady()
    local root = FXLoader:PlayerGui("CurrencyShopUI")
    self.Root = root
    self.List = FXLoader:Here(root, "PopupPanelImg.ProductListBox")
    self.ContentTitle = FXLoader:Here(root, "PopupPanelImg.ProductsContentImg.ProductsTitleTxt")
    self.DiamondTab = FXLoader:Here(root, "PopupPanelImg.DiamondTabBtn")
    self.RobuxTab = FXLoader:Here(root, "PopupPanelImg.RobuxTabBtn")
    self.Templates = {}
    for currencyIndex, currency in ipairs({ "Diamond", "Robux" }) do
        self.Templates[currency] = {}
        for styleIndex, style in ipairs({ "Green", "Gold", "Cyan", "Orange", "Purple", "Pink" }) do
            self.Templates[currency][style] = FXLoader:Here(root, "Templates." .. currency .. style .. "CardImg")
        end
    end
    self.Cards = {}
    -- 页签动作仅提交目标货币。
    self:TrackConnection(self.DiamondTab.Activated:Connect(function()
        self:EmitUIAction("SelectTab", { tab = "Diamond" })
    end))
    self:TrackConnection(self.RobuxTab.Activated:Connect(function()
        self:EmitUIAction("SelectTab", { tab = "Robux" })
    end))
    local close = FXLoader:Here(root, "TitleBox.CloseSurfaceImg")
    -- 关闭动作交给接入层记录显隐状态。
    self:TrackConnection(close.Activated:Connect(function()
        self:EmitUIAction("Close", {})
    end))
end

-- 打开时刷新完整数据。
function CCurrencyShopView:OnShow()
    self:RefreshUI()
end

-- 创建原型副本并记录当前商品身份。
-- @param product table Config.products 中的商品
-- @param style string 已选择的渐变原型名称
-- @return table 卡片节点、连接与清理函数
function CCurrencyShopView:CreateCard(product, style)
    local node = self.Templates[product.currency][style]:Clone()
    node.Name = "Product_" .. product.id
    node.Parent = self.List
    node.Visible = true
    local card = {
        node = node,
        title = FXLoader:Here(node, "ProductTitleTxt"),
        description = FXLoader:Here(node, "ProductDescriptionTxt"),
        icon = FXLoader:Here(node, "ProductIconImg"),
        button = FXLoader:Here(node, "PurchaseBtn"),
        price = FXLoader:Here(node, "PurchaseBtn.ButtonTxt"),
        currency = product.currency,
        style = style,
    }
    -- 点击读取稳定 ID，货币由当前配置关联。
    local connection = card.button.Activated:Connect(function()
        self:EmitUIAction("Purchase", {
            productId = product.id,
            currency = card.currency,
        })
    end)
    card.release = self:TrackCleanup(function()
        connection:Disconnect()
        node:Destroy()
    end)
    return card
end

-- 用完整状态刷新两列商品，复用已有 ID 并清理已移除条目。
-- @param state table 文件头定义的完整 State
function CCurrencyShopView:Render(state)
    self.Root.Enabled = state.open
    local diamondSelected = state.tab == "Diamond"
    self.ContentTitle.Text = diamondSelected and "DIAMOND SHOP" or "ROBUX SHOP"
    local diamondColor = Color3.fromHex("638079")
    local robuxColor = Color3.fromHex("638079")
    if diamondSelected then
        diamondColor = Color3.fromHex("67ED14")
    else
        robuxColor = Color3.fromHex("249CB5")
    end
    self.DiamondTab.BackgroundColor3 = diamondColor
    self.RobuxTab.BackgroundColor3 = robuxColor
    local diamondEdge = FXLoader:Here(self.DiamondTab, "BottomEdgeImg")
    local robuxEdge = FXLoader:Here(self.RobuxTab, "BottomEdgeImg")
    diamondEdge.BackgroundColor3 = diamondSelected and Color3.fromHex("225A07") or Color3.fromHex("263E36")
    robuxEdge.BackgroundColor3 = diamondSelected and Color3.fromHex("263E36") or Color3.fromHex("105464")
    local kept = {}
    local count = 0
    for index, product in ipairs(self:GetUIConfig().products) do
        if product.currency == state.tab then
            count = count + 1
            local style = product.cardStyle or (product.currency == "Diamond" and "Green" or "Gold")
            local card = self.Cards[product.id]
            if card and (card.currency ~= product.currency or card.style ~= style) then
                card.release()
                card = nil
            end
            if not card then
                card = self:CreateCard(product, style)
                self.Cards[product.id] = card
            end
            kept[product.id] = true
            card.node.Position = UDim2.fromOffset(((count - 1) % 2) * 374, math.floor((count - 1) / 2) * 192)
            card.title.Text = product.title
            card.description.Text = product.description
            card.icon.Image = product.icon or ""
            card.price.Text = tostring(product.price)
            self:SetButtonEnabled(card.button, not (state.pending and state.pending[product.id]))
        end
    end
    for id, card in pairs(self.Cards) do
        if not kept[id] then
            card.release()
            self.Cards[id] = nil
        end
    end
    self.List.CanvasSize = UDim2.fromOffset(732, math.max(386, math.ceil(count / 2) * 192 - 12))
end

-- 游戏与模拟接入必须处理声明的动作。
-- @param action string SelectTab、Purchase 或 Close
-- @param payload table 文件头定义的动作参数
function CCurrencyShopView:OnUIAction(action, payload)
    error("Currency shop integration must implement OnUIAction")
end

return CCurrencyShopView
