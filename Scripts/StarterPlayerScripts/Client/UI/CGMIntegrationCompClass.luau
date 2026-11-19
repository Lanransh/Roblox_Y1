local FX = _G.FX
local FXLoader = FX.Loader
local Text = FX.Text
local Players = game:GetService("Players")
local PickupPrompt = FXLoader:Require(script.Parent.Parent, "PickupPrompt")
local TranslationTexts = Text.Define("GMUI", {
    InvalidItemInput = "Enter a valid item ID and a positive whole-number quantity.",
    InvalidValue = "Enter a valid whole number within the allowed range.",
    InvalidLootScale = "Enter a loot size multiplier from 0.1 to 20. Use 1 to restore the original size.",
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
    self.State = {
        pending = false,
        playerStatsHidden = false,
        pickupPromptsHidden = false,
    }
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
    elseif action == "SetLootScale" then
        self._commonUI:ShowLocalizedTips(TranslationTexts.InvalidLootScale)
    else
        self._commonUI:ShowLocalizedTips(TranslationTexts.InvalidValue)
    end
end

--- 切换本机看到的力量和重生次数两行，恢复时保留各自原有的可见性。
--- @param hidden boolean 是否隐藏这两个头顶浮标。
function Component:_SetPlayerStatsHidden(hidden)
    if not hidden then
        self._playerStatsConnection:Disconnect()
        self._playerStatsConnection = nil
        for billboard, enabled in pairs(self._playerStatsVisibility) do
            if billboard.Parent then
                billboard.Enabled = enabled
            end
        end
        self._playerStatsVisibility = nil
        return
    end

    local visibility = setmetatable({}, { __mode = "k" })
    self._playerStatsVisibility = visibility

    --- 仅接管 SMiscCompClass 放在角色头部的两行浮标。
    --- @param node Instance 已有或刚进入客户端场景的节点。
    local function HideStat(node)
        if node.Name ~= "StrengthBillboard" and node.Name ~= "RebirthBillboard" then
            return
        end
        local head = node.Parent
        if self._playerStatsVisibility == visibility and node:IsA("BillboardGui")
            and head and head.Name == "Head" and visibility[node] == nil then
            visibility[node] = node.Enabled
            node.Enabled = false
        end
    end

    -- 只在隐藏期间监听，覆盖重生、晚加入和流式加载的浮标。
    self._playerStatsConnection = workspace.DescendantAdded:Connect(HideStat)
    for index, player in ipairs(Players:GetPlayers()) do
        local character = player.Character
        local head = character and character:FindFirstChild("Head")
        if head then
            for childIndex, node in ipairs(head:GetChildren()) do
                HideStat(node)
            end
        end
    end
end

--- GM 入口显隐和拍照设置在本地执行；数据命令走服务端鉴权，请求中禁用操作。
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
    if action == "ToggleGMButton" then
        self:GetPlayerObject():RequireComponent("CMainUIComp"):ToggleGMButtonVisuals()
        return
    end
    if action == "SetLootScale" then
        self:GetPlayerObject():RequireComponent("CRockLevelComp"):SetLootDisplayScale(payload.value)
        return
    end
    if action == "TogglePlayerStats" then
        self.State.playerStatsHidden = not self.State.playerStatsHidden
        self:_SetPlayerStatsHidden(self.State.playerStatsHidden)
        self:RefreshUI()
        return
    end
    if action == "TogglePickupPrompts" then
        self.State.pickupPromptsHidden = not self.State.pickupPromptsHidden
        PickupPrompt.SetHidden(self.State.pickupPromptsHidden)
        self:RefreshUI()
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

--- 析构时恢复本地隐藏设置并取消等待任务，父类负责界面连接及适配清理。
function Component:Dtor()
    if self.State.playerStatsHidden then
        self:_SetPlayerStatsHidden(false)
    end
    if self.State.pickupPromptsHidden then
        PickupPrompt.SetHidden(false)
    end
    if self._requestTask then
        task.cancel(self._requestTask)
        self._requestTask = nil
    end
    Component.Super.Dtor(self)
end

return Component
