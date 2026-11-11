--[[
通用商品购买介绍接入契约

职责：
  复用单件购买窗的布局，展示项目提供的商品内容与完整购买状态。
  展示层不包含特定商品、VIP 资格或平台支付逻辑。
  游戏提供商品配置、权威状态、实时报价及购买请求，不重绑事件或覆盖 Render。

Config（以下除 price 外均必填，无默认值）：
  itemId: string，稳定商品配置 ID，不是 Roblox 商品 ID。
  title: string | TextDefinition，窗口标题。
  name: string | TextDefinition，商品名称或主要权益。
  category: string | TextDefinition，商品分类。
  description: string | TextDefinition，完整介绍，可含换行。
    四种文案：字符串用于配置原文，按 Text.TrSource 翻译；
    TextDefinition 为项目 Text.Define 返回的单项，按 Text.Tr 翻译；
    不传入已经翻译的文字，避免二次翻译。
  icon: string，Roblox Image 地址；空字符串显示问号占位图，标题与商品图共用。
  currency: "Robux" | "Diamond"，币种；分别显示紫色或绿色购买按钮与对应货币图标。
  price: number?，可选，省略 nil；平台或权威配置价格，非负。nil 表示无有效报价。

State（完整快照）：
  status: "Ready" | "Purchased"，必填，无默认值；待购买或已拥有。
  pending: boolean?，可选，省略 false；请求或平台窗口进行中。

状态与动作：
  Purchased 显示 Owned；其次 pending 显示 Buying...；
  无 price 显示 Unavailable；其余显示 {price} · Buy。
  仅 Ready、非 pending 且 price 非 nil 时启用购买；无报价不猜测价格。
  货币图标仅在显示价格时出现。关闭始终可用，不取消未完成购买。
  Buy -> {itemId: string}，对应 Config.itemId，不提交价格或资格。
  Close -> {}，接入调用 Hide()。
  购买完成状态必须来自权威结果，不能仅凭平台窗口关闭事件发奖。

接口清单：
  必需 OnUIAction(action:string, payload:table) -> 无返回值：
    接入购买、取消、失败和关闭，不调用父实现。
  必需 OnReady() -> 无返回值：
    先 Super.OnReady(self)，准备完整 Config/State，再 BindUIData()；
    依业务初始 Hide() 或 Show()，订阅仅建立一次。
  必需 GetCompName() -> string：返回游戏组件协作名。
  条件覆写 BindUIData() -> 无返回值：
    读取真实状态、建立订阅并 RefreshUI；父实现仅刷新一次。
  可选 FormatNumber(value:number) -> string：使用项目统一数量格式。
  条件覆写 Ctor(owner:table) / Dtor() -> 无返回值：
    Ctor 先父构造；Dtor 先取消自有请求，再父析构。
  继承 GetUIConfig() / GetUIState() -> table：分别读取 Config/State；
    动态配置可覆写 GetUIConfig()，但每次返回完整配置。
  继承 OnShow() -> 无返回值：每次打开刷新，不重复注册事件。
  仅调用 BindUIData、RefreshUI、Show、Hide、TrackConnection；
    不覆盖 Render、EmitUIAction、SetButtonEnabled 或已有事件绑定。

项目接入步骤：
  1. Generated 外创建继承 CPurchaseIntroView 的业务类，创建玩家前加载并挂载。
  2. 提供真实商品配置与状态；异步报价未完成时 price=nil，不伪造报价。
  3. 父 OnReady 绑定节点后建立数据与语言订阅，首次刷新，依业务决定显隐。
  4. Buy 时核对 itemId、资格及 pending，pending=true 并刷新，再请求真实购买。
  5. 请求失败或取消后恢复 pending=false；成功根据权威结果更新 Purchased。
     平台支付完成但服务端尚未到账时可保持 pending，等待权威数据同步。
  6. 切换商品同时替换完整 Config/State；异步旧结果须由业务按商品身份隔离。
  7. 语言变化重新 RefreshUI；取消自有任务，托管连接交父析构清理。

最小完整数据：
  self.Config = {
      itemId = "product_1",
      title = "Confirm Purchase",
      name = "Product Name",
      category = "PRODUCT",
      description = "Product benefits.",
      icon = "",
      currency = "Robux",
      price = nil,
  }
  self.State = {
      status = "Ready",
      pending = false,
  }
]]
local FX = _G.FX
local FXLoader = FX.Loader
local Text = FXLoader:RequireShared("Scripts.Game.Shared.Text")
local CPurchaseIntroView = FX.Class("CPurchaseIntroView", "CUIView")

local TranslationTexts = Text.Define("PurchaseIntroUI", {
    Buy = "{price} · Buy",
    Buying = "Buying...",
    Owned = "Owned",
    Unavailable = "Unavailable",
})
CPurchaseIntroView.BaseViewTranslationTexts = TranslationTexts

--- 配置原文与项目文案定义分别沿用对应翻译接口，译文不作为输入。
--- @param value string | table 配置原文或 Text.Define 的单项定义。
--- @return string 当前语言下的完整文案。
local function Translate(value)
    if type(value) == "string" then
        return Text.TrSource(value)
    end
    return Text.Tr(value)
end

--- 价格开放格式化接口，供游戏使用统一数量工具。
--- @param value number 当前币种下的商品价格。
--- @return string 展示价格。
function CPurchaseIntroView:FormatNumber(value)
    return tostring(value)
end

--- 绑定一次节点与事件，点击读取当前完整状态和稳定商品 ID。
function CPurchaseIntroView:OnReady()
    local root = FXLoader:PlayerGui("PurchaseIntroUI")
    self.TitleTxt = FXLoader:Here(root, "TitleBox.TitleTxt")
    self.TitleIconImg = FXLoader:Here(root, "TitleBox.TitleIconImg")
    self.ItemIconImg = FXLoader:Here(root, "PopupPanelImg.ItemSurfaceImg.ItemIconImg")
    self.ItemNameTxt = FXLoader:Here(root, "PopupPanelImg.ItemNameTxt")
    self.CategoryTxt = FXLoader:Here(root, "PopupPanelImg.CategoryTxt")
    self.DescriptionTxt = FXLoader:Here(root, "PopupPanelImg.DescriptionTxt")
    self.BuyBtn = FXLoader:Here(root, "PopupPanelImg.BuyBtn")
    self.ButtonTxt = FXLoader:Here(self.BuyBtn, "ButtonTxt")
    self.RobuxIconTxt = FXLoader:Here(self.BuyBtn, "RobuxIconTxt")
    self.DiamondIconImg = FXLoader:Here(self.BuyBtn, "DiamondIconImg")
    self.ButtonEdgeImg = FXLoader:Here(self.BuyBtn, "BottomEdgeImg")
    local closeBtn = FXLoader:Here(root, "TitleBox.CloseSurfaceImg.CloseBtn")
    -- 动作只提交当前商品身份，不携带客户端价格或资格。
    self:TrackConnection(self.BuyBtn.Activated:Connect(function()
        local state = self:GetUIState()
        if state.status == "Ready" and not state.pending and self:GetUIConfig().price ~= nil then
            self:EmitUIAction("Buy", {itemId = self:GetUIConfig().itemId})
        end
    end))
    -- 显隐与未完成请求的处理交给游戏业务。
    self:TrackConnection(closeBtn.Activated:Connect(function()
        self:EmitUIAction("Close", {})
    end))
end

--- 打开时刷新最新商品和状态，不重复绑定按钮。
function CPurchaseIntroView:OnShow()
    self:RefreshUI()
end

--- 内容由配置提供，币种决定付费按钮样式，状态决定文案和点击许可。
--- @param state table 文件头定义的完整商品购买状态。
function CPurchaseIntroView:Render(state)
    local config = self:GetUIConfig()
    self.TitleTxt.Text = Translate(config.title)
    self.ItemNameTxt.Text = Translate(config.name)
    self.CategoryTxt.Text = Translate(config.category)
    self.DescriptionTxt.Text = Translate(config.description)
    local image = config.icon
    if image == "" then
        image = "rbxassetid://86795093617566"
    end
    self.TitleIconImg.Image = image
    self.ItemIconImg.Image = image
    local showPrice = state.status == "Ready" and not state.pending and config.price ~= nil
    if state.status == "Purchased" then
        self.ButtonTxt.Text = Text.Tr(TranslationTexts.Owned)
    elseif state.pending then
        self.ButtonTxt.Text = Text.Tr(TranslationTexts.Buying)
    elseif config.price == nil then
        self.ButtonTxt.Text = Text.Tr(TranslationTexts.Unavailable)
    else
        self.ButtonTxt.Text = Text.Tr(TranslationTexts.Buy, {
            price = self:FormatNumber(config.price),
        })
    end
    local isRobux = config.currency == "Robux"
    self.RobuxIconTxt.Visible = showPrice and isRobux
    self.DiamondIconImg.Visible = showPrice and not isRobux
    if isRobux then
        self.BuyBtn.BackgroundColor3 = Color3.fromRGB(208, 59, 242)
        self.ButtonEdgeImg.BackgroundColor3 = Color3.fromRGB(105, 21, 130)
    else
        self.BuyBtn.BackgroundColor3 = Color3.fromRGB(103, 237, 20)
        self.ButtonEdgeImg.BackgroundColor3 = Color3.fromRGB(34, 90, 7)
    end
    if showPrice then
        self.ButtonTxt.Position = UDim2.fromOffset(66, 0)
        self.ButtonTxt.Size = UDim2.new(1, -76, 1, 0)
    else
        self.ButtonTxt.Position = UDim2.fromOffset(10, 0)
        self.ButtonTxt.Size = UDim2.new(1, -20, 1, 0)
    end
    self:SetButtonEnabled(self.BuyBtn, showPrice)
end

--- 游戏接入负责真实购买和关闭，展示层不修改拥有状态或余额。
--- @param action string Buy 或 Close。
--- @param payload table Buy 为 itemId，Close 为空表。
function CPurchaseIntroView:OnUIAction(action, payload)
    error("Purchase introduction integration must implement OnUIAction: " .. tostring(action))
end

CPurchaseIntroView.ScreenGuiName = "PurchaseIntroUI"
return CPurchaseIntroView
