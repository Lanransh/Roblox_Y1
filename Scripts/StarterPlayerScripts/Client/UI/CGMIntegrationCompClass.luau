local FX = _G.FX
local FXLoader = FX.Loader
local Text = FXLoader:RequireShared("Scripts/Game/Shared/Text")
local TranslationTexts = Text.Define("GMUI", {
    InvalidItemInput = "Enter a valid item ID and a positive whole-number quantity.",
    InvalidValue = "Enter a valid whole number within the allowed range.",
    Unknown = "Something went wrong. Please try again.",
})
FXLoader:RequireFromParent(script, "Generated/CGMPanelView")
local Component = FX.Class("CGMIntegrationCompClass", "CGMPanelView")

--- 提供主界面打开 GM 面板的业务入口。
--- @return string GM 组件协作名。
function Component:GetCompName()
    return "CGMUIComp"
end

--- 构造时准备展示契约，避免首次打开读取空状态。
--- @param owner table 当前开发者玩家对象。
function Component:Ctor(owner)
    Component.Super.Ctor(self, owner)
    self.Config = {}
    self.State = {pending = false}
end

--- 开发者提前初始化面板，入口统一使用主界面按钮，Ready 回放时不重复绑定。
function Component:OnReady()
    if self._initialized then
        return
    end
    self._commonUI = self:GetPlayerObject():RequireComponent("FCCommonUIComp")
    Component.Super.OnReady(self)
    local root = self:GetRootNode()
    root.ResetOnSpawn = false
    root.DisplayOrder = 20
    self._commonUI:RegisterTrainingClickModal(root)
    self:BindUIData()
    self:Hide()
    self._initialized = true
end

--- 即使其他客户端组件直接调用，也只允许开发者显示面板。
function Component:Show()
    if FX.IsDeveloper(self:GetPlayerNode().UserId) then
        Component.Super.Show(self)
    end
end

--- 参数校验和重置确认交给展示类，业务层仅显示非法输入提示。
--- @param action string 展示类校验失败的 GM 操作。
function Component:OnInvalidInput(action)
    if action == "AddItem" then
        self._commonUI:ShowLocalizedTips(TranslationTexts.InvalidItemInput)
    else
        self._commonUI:ShowLocalizedTips(TranslationTexts.InvalidValue)
    end
end

--- 只提交操作及原始数值，身份和权限由服务端验证；请求中禁用操作。
--- @param action string 展示类的稳定动作名。
--- @param payload table 展示类校验后的输入，添加道具使用 itemId/count，数值动作使用 value。
function Component:OnUIAction(action, payload)
    if action == "Close" then
        self:Hide()
        return
    end
    if self.State.pending or not FX.IsDeveloper(self:GetPlayerNode().UserId) then
        return
    end
    self.State.pending = true
    self:RefreshUI()
    --- 网络失败也恢复按钮，保存结果只采用服务端返回值。
    self._requestTask = task.defer(function()
        --- 通过正式框架协议请求本人数据操作。
        --- @return table 服务端操作结果和提示 Key。
        local ok, result = pcall(function()
            local value = action == "AddItem" and payload.itemId or payload.value
            return FX.Network:InvokeServer("C2S_GMCommand", action, value, payload.count)
        end)
        self._requestTask = nil
        self.State.pending = false
        self:RefreshUI()
        self._commonUI:ShowLocalizedTips(
            ok and type(result) == "table" and result.key or TranslationTexts.Unknown,
            ok and type(result) == "table" and result.arguments or nil)
    end)
end

--- 离服取消等待任务，生成父类负责界面连接及适配清理。
function Component:Dtor()
    if self._requestTask then
        task.cancel(self._requestTask)
        self._requestTask = nil
    end
    Component.Super.Dtor(self)
end

return Component
