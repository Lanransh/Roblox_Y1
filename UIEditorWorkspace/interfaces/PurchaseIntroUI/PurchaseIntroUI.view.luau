--[[
VIP 专属介绍窗接入契约

职责：
  固定展示 VIP 图标、双倍战利品出售收益和永久权益。
  窗口不接受其他商品的文案或币种，真实支付与资格由业务接入负责。
  保留 PurchaseIntroUI / CPurchaseIntroView 身份以更新原有窗口。

Config：
  itemId: string，VIP 稳定配置 ID。
  price: number?，平台 Robux 报价，nil 表示尚无有效报价。

State：
  status: "Ready" | "Purchased"，服务端权威 VIP 状态。
  pending: boolean，购买请求或平台窗口是否进行中。

展示与动作：
  Purchased 优先显示 Owned，其次 pending 显示 Buying...。
  无报价显示 Unavailable，其余仅显示 Robux 图标和格式化价格。
  仅 Ready、非 pending 且有报价时允许购买。
  Buy -> {itemId: string}；Close -> {}，关闭不取消未完成购买。

项目接口：
  必需 GetCompName() -> string，返回玩家组件协作名称。
  必需 OnReady() -> 无返回值：
    先调用 Super.OnReady(self)，提供完整 Config/State，再 BindUIData()。
    初始 Hide()，建立一次数据和语言订阅。
  条件覆写 BindUIData() -> 无返回值：
    读取服务端 VIP 资格并 RefreshUI()；父实现只刷新。
  必需 OnUIAction(action:string, payload:table) -> 无返回值：
    Buy 核对 itemId、资格和 pending 后发起真实购买。
    Close 调用 Hide()；不调用父实现。
  可选 FormatNumber(value:number) -> string，使用项目价格格式化。
  条件覆写 Dtor() -> 无返回值：
    取消业务异步任务，再调用父析构。
  继承 OnShow()、GetUIConfig()、GetUIState()。
  仅调用 Show/Hide、RefreshUI、TrackConnection；不覆盖 Render、
  EmitUIAction 或重新绑定按钮。

接入顺序：
  1. 在 Generated 外继承本 View，在玩家创建前加载并挂载。
  2. 首次刷新前准备 itemId、price 和完整状态。
  3. 购买时 pending=true 并刷新；取消或失败恢复 pending=false。
  4. 成功后等待服务端同步 Purchased，不凭平台回调授予权益。
  5. 语言变化 RefreshUI，销毁时取消任务并交父类释放连接。
]]
local FX = _G.FX
local FXLoader = FX.Loader
local Text = FXLoader:RequireShared("Scripts.Game.Shared.Text")
local CPurchaseIntroView = FX.Class("CPurchaseIntroView", "CUIView")

local TranslationTexts = Text.Define("PurchaseIntroUI", {
    Buying = "Buying...",
    Owned = "Owned",
    Unavailable = "Unavailable",
})
CPurchaseIntroView.BaseViewTranslationTexts = TranslationTexts

--- 业务子类负责使用项目统一工具格式化平台报价。
--- @param value number 平台 Robux 报价。
--- @return string 价格展示文字。
function CPurchaseIntroView:FormatNumber(value)
    return tostring(value)
end

--- 只绑定 VIP 窗口的购买和关闭动作，不在展示层发放权益。
function CPurchaseIntroView:OnReady()
    local root = FXLoader:PlayerGui("PurchaseIntroUI")
    self.BuyBtn = FXLoader:Here(root, "PopupPanelImg.BuyBtn")
    self.ButtonTxt = FXLoader:Here(self.BuyBtn, "ButtonTxt")
    self.RobuxIconTxt = FXLoader:Here(self.BuyBtn, "RobuxIconTxt")
    local closeBtn = FXLoader:Here(root, "TitleBox.CloseSurfaceImg.CloseBtn")
    -- 只提交 VIP 稳定配置 ID，平台报价和资格不作为客户端凭据。
    self:TrackConnection(self.BuyBtn.Activated:Connect(function()
        local state = self:GetUIState()
        if state.status == "Ready" and not state.pending and self:GetUIConfig().price ~= nil then
            self:EmitUIAction("Buy", {itemId = self:GetUIConfig().itemId})
        end
    end))
    -- 关闭始终可用，业务继续接收未完成购买的权威结果。
    self:TrackConnection(closeBtn.Activated:Connect(function()
        self:EmitUIAction("Close", {})
    end))
end

--- 重新打开时刷新报价和资格，不重复建立监听。
function CPurchaseIntroView:OnShow()
    self:RefreshUI()
end

--- 静态 VIP 内容保存在设计节点中，这里只映射平台购买状态。
--- @param state table 包含 status 和 pending 的完整购买状态。
function CPurchaseIntroView:Render(state)
    local config = self:GetUIConfig()
    local canBuy = state.status == "Ready" and not state.pending and config.price ~= nil
    if state.status == "Purchased" then
        self.ButtonTxt.Text = Text.Tr(TranslationTexts.Owned)
    elseif state.pending then
        self.ButtonTxt.Text = Text.Tr(TranslationTexts.Buying)
    elseif config.price == nil then
        self.ButtonTxt.Text = Text.Tr(TranslationTexts.Unavailable)
    else
        self.ButtonTxt.Text = self:FormatNumber(config.price)
    end
    self.RobuxIconTxt.Visible = canBuy
    if canBuy then
        self.ButtonTxt.Position = UDim2.fromOffset(112, 0)
        self.ButtonTxt.Size = UDim2.new(1, -136, 1, 0)
        self.ButtonTxt.TextXAlignment = Enum.TextXAlignment.Left
    else
        self.ButtonTxt.Position = UDim2.fromOffset(12, 0)
        self.ButtonTxt.Size = UDim2.new(1, -24, 1, 0)
        self.ButtonTxt.TextXAlignment = Enum.TextXAlignment.Center
    end
    self:SetButtonEnabled(self.BuyBtn, canBuy)
end

--- 游戏业务负责真实购买和关闭，不以客户端操作授予 VIP。
--- @param action string Buy 或 Close。
--- @param payload table Buy 携带 itemId，Close 为空表。
function CPurchaseIntroView:OnUIAction(action, payload)
    error("VIP introduction integration must implement OnUIAction: " .. tostring(action))
end

CPurchaseIntroView.ScreenGuiName = "PurchaseIntroUI"
return CPurchaseIntroView
