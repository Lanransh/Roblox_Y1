local FX = _G.FX
local FXLoader = FX.Loader
local Localization = FXLoader:Require(script.Parent.Parent, "Localization")
local ButtonHover = FXLoader:RequireFromParent(script, "ButtonHover")
local UI = FX.Class("CCommonUICompClass", "FCCommonUICompClass")

--- 将通用提示接入项目设计画布，随画布等比缩放。
--- @param owner table 所属客户端玩家对象。
function UI:Ctor(owner)
    UI.Super.Ctor(self, owner)
    self.Localization = Localization.New(self:GetPlayerNode())
    self._confirmKey, self._cancelKey = "Common.Confirm", "Common.Cancel"
    for index, node in ipairs({self.Tips, self.Description, self.Confirm, self.Cancel}) do
        node.AutoLocalize = false
    end
    --- 语言变化后刷新已显示的翻译文案。
    self:TrackConnection(self.Localization.Changed:Connect(function()
        self:RefreshLocalization()
    end))
    FX.Network:RegServerMsgCallback("S2C_ShowLocalizedTips", self.ShowLocalizedTips, self)
    self:RefreshLocalization()
    local playerGui = self:GetPlayerNode():WaitForChild("PlayerGui")
    -- 全屏输入遮罩不参与按钮缩放，避免连带放大弹窗内容。
    self.Modal:SetAttribute("HoverEnabled", false)
    self._buttonHover = ButtonHover.New(playerGui)
    local canvas = FXLoader:Here(playerGui, "ScreenGui/Canvas")
    self.Tips.TextSize = 28
    self.Tips.Parent = canvas
end

--- 保留原有字符串提示入口，替换提示时清除旧 Key，避免语言变化恢复旧提示。
--- @param message string 已准备好的提示内容。
--- @param duration number? 显示时长，单位为秒。
function UI:ShowTips(message, duration)
    self._tipKey, self._tipArguments = nil, nil
    UI.Super.ShowTips(self, message, duration)
end

--- 服务端和客户端共用 Key 提示入口，显示时才按玩家语言格式化。
--- @param key string 本地文案表中的提示 Key。
--- @param arguments table? 提示模板参数。
--- @param duration number? 显示时长，单位为秒。
function UI:ShowLocalizedTips(key, arguments, duration)
    self:ShowTips(self.Localization:FormatByKey(key, arguments), duration)
    self._tipKey, self._tipArguments = key, arguments
end

--- 弹窗支持文案 Key，同时兼容框架现有的文本和按钮回调参数。
--- @param params table 可选 DescKey/Arguments/ConfirmKey/CancelKey；其余沿用框架参数。
function UI:ShowTooltips(params)
    self._descriptionKey, self._descriptionArguments = params.DescKey, params.Arguments
    self._confirmKey = params.ConfirmKey or (not params.ConfirmBtnTxt and "Common.Confirm")
    self._cancelKey = params.CancelKey or (not params.CancelBtnTxt and "Common.Cancel")
    local options = table.clone(params)
    if self._descriptionKey then
        options.Desc = self.Localization:FormatByKey(self._descriptionKey, self._descriptionArguments)
    end
    if self._confirmKey then
        options.ConfirmBtnTxt = self.Localization:FormatByKey(self._confirmKey)
    end
    if self._cancelKey then
        options.CancelBtnTxt = self.Localization:FormatByKey(self._cancelKey)
    end
    UI.Super.ShowTooltips(self, options)
    self.TooltipParams = params
end

--- 清除当前弹窗来源，防止语言变化时恢复已关闭或被替换的弹窗。
function UI:HideTooltips()
    self.TooltipParams = nil
    UI.Super.HideTooltips(self)
end

--- 翻译加载完成或玩家切换语言时更新当前文案，不重置提示关闭计时。
function UI:RefreshLocalization()
    if self._tipKey and self._tipLabel then
        self._tipLabel.Text = self.Localization:FormatByKey(self._tipKey, self._tipArguments)
    end
    if self._descriptionKey then
        self.Description.Text = self.Localization:FormatByKey(self._descriptionKey, self._descriptionArguments)
    end
    if self._confirmKey then
        self.Confirm.Text = self.Localization:FormatByKey(self._confirmKey)
    end
    if self._cancelKey then
        self.Cancel.Text = self.Localization:FormatByKey(self._cancelKey)
    end
end

--- 提示已移出框架根节点，需要单独释放，保留项目共享画布。
function UI:Dtor()
    self._buttonHover:Destroy()
    FX.Network:UnRegServerMsgCallback("S2C_ShowLocalizedTips")
    self.Localization:Destroy()
    UI.Super.Dtor(self)
    self.Tips:Destroy()
end

return UI
