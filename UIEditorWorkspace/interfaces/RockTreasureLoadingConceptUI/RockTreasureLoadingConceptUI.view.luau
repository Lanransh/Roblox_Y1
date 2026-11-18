--[[
加载页文案展示接入契约

职责边界：
  View 管理加载状态翻译、进度文字与填充；静态文案由节点自动翻译。
  项目提供真实进度；本类不加载资源、不判断进入游戏条件。

Config：
  无。

State（完整输入）：
  status: string，可选，Loading / Waiting / Failed；缺省 Loading。失败时保留页面并提示重新加入。
  current: number，可选，已准备数量；与 target 同单位。
  target: number，可选，总数量；大于 0 时显示进度。
  skipRequested: boolean，可选，默认 false；请求跳过后按钮禁用，显示等待入场。
  Failed 优先禁用按钮；跳过只取消资源等待，进入条件由项目检查。
  任一进度字段缺失或 target <= 0：空条、清空数字。
  状态文字由 status 选择预定义译文，不依据数字判断加载完成。

初始化与刷新：
  GetUIState() 默认读取 self.State，RefreshUI() 调用 Render(GetUIState())。
  首次显示前准备 State；后续替换完整 State 再 RefreshUI()。
  OnShow 刷新当前状态，项目按真实准备结果调用 Hide()。

展示与交互规则：
  填充比例限制在 0 到 1，数字保留实际输入的整数显示。
  SkipBtn 非 Failed 且未请求跳过时发送 Skip -> {}，不直接关闭页面。
  OnShow 播放 24 张出售同款钞票的循环下落；OnHide/Dtor 停止并清理。
  钞票层位于前景文字和按钮下方，不接收输入。

接口实现清单：
  必须实现的生命周期：
    OnReady() -> 无返回值；先父 OnReady 绑定节点，再准备订阅、刷新和 Show。
    Ctor(owner: table) -> 无返回值；如覆写，先父 Ctor 再准备 State。
  按条件覆写：
    Dtor() -> 无返回值；有未托管资源时先清理自身资源，再父 Dtor。
  继承无需重写：
    GetUIState() -> table，读取 self.State。
    GetUIConfig() -> table，本页不消费。
    OnShow() -> 无返回值，刷新状态。
  仅调用：
    RefreshUI() / Show() / Hide() -> 无返回值。
    TrackConnection(connection) -> 原连接，托管项目订阅。
  展示层内部，不得覆盖：
    Render(state: table) -> 无返回值，管理状态文字、进度文字和填充。
  必须覆写 OnUIAction(action: string, payload: table) -> 无返回值，处理 Skip -> {}。
  OnHide、StartMoneyRain、ClearMoneyRain、UpdateMoneyRain 为展示内部方法，不得覆盖。

项目接入步骤：
  1. 在 Generated 外继承本 View；初始化完成后加载并挂载游戏子类。
  2. 父构造后准备 State；父 OnReady 后订阅真实加载数据并托管连接。
  3. 首次刷新并 Show；每次数据变化后更新完整 State，再 RefreshUI。
  4. 沿用游戏已有翻译刷新机制，在语言就绪或改变后 RefreshUI。
  5. 真实资源及进入条件由项目检查，完成后 Hide；重新 Show 会读取最新状态。
  6. 收到 Skip 时设置 skipRequested=true 并刷新，停止前台资源等待；保留必要进入检查。
  7. 销毁时父类清理托管连接和钞票动画，项目清理自己的后台任务。

最小完整状态示例（接入 Ctor 的父构造之后）：
  self.State = {
      current = 0,
      target = 100,
  }
]]
local FX = _G.FX
local FXLoader = FX.Loader
local Text = FXLoader:RequireShared("Scripts.Framework.Shared.Core.FXText")
local CRockTreasureLoadingConceptView = FX.Class("CRockTreasureLoadingConceptView", "CUIView")

local TranslationTexts = Text.Define("RockTreasureLoading", {
    Loading = "Finding a path to treasure...",
    Waiting = "Preparing your adventure...",
    Skip = "Skip",
    Skipping = "Entering game...",
    Failed = "Unable to prepare your adventure. Please rejoin.",
})
CRockTreasureLoadingConceptView.BaseViewTranslationTexts = TranslationTexts

-- 全屏加载页立即显示，不使用弹窗缩放、模糊或相机效果。
CRockTreasureLoadingConceptView.OpenAnimation = false

-- 全屏背景铺满可用区域；前景单独等比缩放，避免宽屏露出游戏场景。
CRockTreasureLoadingConceptView.ScreenAdaptation = false

-- 绑定现有节点，保留设计中的插画大小与位置。
function CRockTreasureLoadingConceptView:OnReady()
    local root = FXLoader:PlayerGui("RockTreasureLoadingConceptUI")
    local fitScale = FXLoader:Here(root, "ContentBox.FitScale")
    -- 可用尺寸改变时只缩放前景，保留全屏背景。
    local function updateLayout()
        local size = root.AbsoluteSize
        if size.X > 0 and size.Y > 0 then
            fitScale.Scale = math.min(size.X / 1280, size.Y / 720)
        end
    end
    self:TrackConnection(root:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateLayout))
    updateLayout()
    if game then
        FXLoader:Here(root, "InputBlockBox").Active = true
    end
    self.SkipBtn = FXLoader:Here(root, "ContentBox.SkipBtn")
    self.SkipTxt = FXLoader:Here(self.SkipBtn, "ButtonTxt")
    self.MoneyRainBox = FXLoader:Here(root, "MoneyRainBox")
    self.MoneyTemplate = FXLoader:Here(root, "Templates.MoneyImg")
    self:TrackConnection(self.SkipBtn.Activated:Connect(function()
        local state = self:GetUIState()
        if state.status ~= "Failed" and not state.skipRequested then
            self:EmitUIAction("Skip", {})
        end
    end))
    self.LoadingStatusTxt = FXLoader:Here(root, "ContentBox.LoadingStatusTxt")
    self.ProgressTxt = FXLoader:Here(root, "ContentBox.ProgressBarImg.ProgressTxt")
    self.ProgressFillImg = FXLoader:Here(root, "ContentBox.ProgressBarImg.ProgressFillImg")
end

-- 显示时重新求值翻译和当前进度。
function CRockTreasureLoadingConceptView:OnShow()
    self:RefreshUI()
    self:StartMoneyRain()
end

-- 只消费完整展示状态，不负责加载或完成判定。
-- @param state table，current/target 可选，详见文件头契约
function CRockTreasureLoadingConceptView:Render(state)
    self:SetButtonEnabled(self.SkipBtn, state.status ~= "Failed" and not state.skipRequested)
    self.SkipTxt.Text = Text.Tr(state.skipRequested and TranslationTexts.Skipping or TranslationTexts.Skip)
    self.LoadingStatusTxt.Text = Text.Tr(TranslationTexts[state.status or "Loading"])
    local current = state.current
    local target = state.target
    if current == nil or target == nil or target <= 0 then
        self.ProgressTxt.Text = ""
        self.ProgressFillImg.Size = UDim2.fromScale(0, 1)
        return
    end
    self.ProgressTxt.Text = string.format("%.0f / %.0f", current, target)
    self.ProgressFillImg.Size = UDim2.fromScale(math.clamp(current / target, 0, 1), 1)
end


--- 复用出售钞票素材与24张错落旋转下落的轨迹，循环直到页面关闭。
function CRockTreasureLoadingConceptView:StartMoneyRain()
    self:ClearMoneyRain()
    self._moneyRain = {}
    for index = 1, 24 do
        local icon = self.MoneyTemplate:Clone()
        icon.Name = "LoadingMoney"
        icon.Visible = true
        icon.Parent = self.MoneyRainBox
        table.insert(self._moneyRain, {
            icon = icon, x = math.random(), phase = math.random(),
            duration = math.random(150, 250) / 100,
            size = 64 * math.random(65, 115) / 100,
            rotation = math.random(-45, 45), spin = math.random(-240, 240),
            drift = math.random(-100, 100),
        })
    end
    self:UpdateMoneyRain(0)
    if game then
        self._moneyRainConnection = game:GetService("RunService").RenderStepped:Connect(function(deltaTime)
            self:UpdateMoneyRain(deltaTime)
        end)
    end
end

--- 按当前屏幕计算下落位置，尺寸变化不新增动画和节点。
--- @param deltaTime number 距上一帧秒数。
function CRockTreasureLoadingConceptView:UpdateMoneyRain(deltaTime)
    local area = self.MoneyRainBox.AbsoluteSize
    local scale = math.min(area.X / 1280, area.Y / 720)
    for index, entry in ipairs(self._moneyRain) do
        entry.phase = (entry.phase + deltaTime / entry.duration) % 1
        local progress = entry.phase * entry.phase
        entry.icon.Position = UDim2.fromOffset(
            entry.x * (area.X - 80 * scale) + 40 * scale + entry.drift * scale * progress,
            -80 * scale + (area.Y + 180 * scale) * progress)
        entry.icon.Size = UDim2.fromOffset(entry.size * scale, entry.size * scale)
        entry.icon.Rotation = entry.rotation + entry.spin * progress
    end
end

--- 隐藏或销毁时断开动画并释放克隆，保留设计原型。
function CRockTreasureLoadingConceptView:ClearMoneyRain()
    if self._moneyRainConnection then
        self._moneyRainConnection:Disconnect()
        self._moneyRainConnection = nil
    end
    for index, entry in ipairs(self._moneyRain or {}) do
        entry.icon:Destroy()
    end
    self._moneyRain = nil
end

--- 页面关闭立即停止飘钞票。
function CRockTreasureLoadingConceptView:OnHide()
    self:ClearMoneyRain()
end

--- 先清理页面动画，再交给父类释放连接。
function CRockTreasureLoadingConceptView:Dtor()
    self:ClearMoneyRain()
    CRockTreasureLoadingConceptView.Super.Dtor(self)
end

return CRockTreasureLoadingConceptView
