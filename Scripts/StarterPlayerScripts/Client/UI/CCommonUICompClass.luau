local FX, FC = _G.FX, _G.FC
local FXLoader = FX.Loader
local TranslationTexts = {
    ["Loot.LuckyTooltip"] = { Key = "CCommonUICompClass.Loot.LuckyTooltip", Source = "{item} · Lucky ×{rate} · {price} Coins" },
    ["Loot.Tooltip"] = { Key = "CCommonUICompClass.Loot.Tooltip", Source = "{item} · {price} Coins" },
}
local ButtonHover = FXLoader:RequireFromParent(script, "ButtonHover")
local ToolDescription = FXLoader:RequireFromParent(script, "ToolDescription")
local Text = FXLoader:RequireShared("Scripts/Game/Shared/Text")
local GameUtility = FXLoader:RequireShared("Scripts/Game/Shared/GameUtility")
local ItemConfig = FXLoader:RequireShared("Scripts/Game/Configs/ItemConfig")
local UI = FX.Class("CCommonUICompClass", "FCCommonUICompClass")

--- 使用项目英文提示与通用高层浮窗，避免被业务弹窗遮挡。
--- @param owner table 所属客户端玩家对象。
function UI:Ctor(owner)
    UI.Super.Ctor(self, owner)
    self.Localization = FC.Localization
    self._toolDescription = ToolDescription.New(FXLoader:PlayerGui("MainUI/TopCenter/Strength"))
    self._selectedToolConnections = {}
    for index, node in ipairs({self.Tips, self.Description}) do
        node.AutoLocalize = false
    end
    --- 语言变化后刷新已显示的翻译文案。
    self:TrackConnection(self.Localization.Changed:Connect(function()
        self:RefreshLocalization()
    end))
    FX.Network:RegServerMsgCallback("S2C_ShowLocalizedTips", self.ShowLocalizedTips, self)
    self:RefreshLocalization()
    --- 新复制或在角色与背包之间移动的 Tool 按当前语言更新显示名。
    --- @param node Instance 玩家子树中新复制的节点，包含 Backpack 内的 Tool。
    self:TrackConnection(self:GetPlayerNode().DescendantAdded:Connect(function(node)
        if node:IsA("Tool") then
            self:LocalizeTool(node)
        end
    end))
    --- 角色不在 Player 子树内，装备时需单独监听其 Tool。
    --- @param character Model 引擎创建的当前玩家角色。
    self:TrackConnection(self:GetPlayerNode().CharacterAdded:Connect(function(character)
        self:BindCharacterTools(character)
    end))
    --- 角色整体移除时不保证逐个移出 Tool，因此主动清空旧角色说明。
    self:TrackConnection(self:GetPlayerNode().CharacterRemoving:Connect(function()
        self:SetSelectedTool(nil)
    end))
    if self:GetPlayerNode().Character then
        self:BindCharacterTools(self:GetPlayerNode().Character)
    end
    local playerGui = self:GetPlayerNode():WaitForChild("PlayerGui")
    self._trainingClickModals = {}
    self:RegisterTrainingClickModal(self.Modal)
    -- 出售界面目前只有可选模板，登记其显示状态，避免主界面依赖弹窗名称。
    local lootSellUI = playerGui:FindFirstChild("LootSellUI")
    if lootSellUI then
        self:RegisterTrainingClickModal(lootSellUI)
    end
    self.Tips:SetAttribute("BlocksTrainingClick", true)
    -- 全屏输入遮罩不参与按钮缩放，避免连带放大弹窗内容。
    self.Modal:SetAttribute("HoverEnabled", false)
    self._buttonHover = ButtonHover.New(playerGui)
    self.Tips.TextSize = 28
    -- 提示保留在通用高层浮窗中，不能移到低层画布被出售等弹窗遮住。
end

--- 登记需要暂停空白区域点击的弹窗根节点，实际隐藏后才解除禁点。
--- @param root ScreenGui|GuiObject 弹窗根节点；节点销毁时自动移除登记。
function UI:RegisterTrainingClickModal(root)
    if self._trainingClickModals[root] then
        return
    end
    self._trainingClickModals[root] = true
    --- 弹窗根节点销毁后不再参与显示状态查询。
    self:TrackConnection(root.Destroying:Connect(function()
        self._trainingClickModals[root] = nil
    end))
end

--- 按登记节点及祖先的实际显示状态判断，支持多个弹窗与关闭动画。
--- @return boolean 是否有可见弹窗暂停训练点击。
function UI:IsTrainingClickBlocked()
    local playerGui = self:GetPlayerNode().PlayerGui
    for root in pairs(self._trainingClickModals) do
        local visible = true
        local node = root
        while node and node ~= playerGui do
            if (node:IsA("ScreenGui") and not node.Enabled)
                or (node:IsA("GuiObject") and not node.Visible) then
                visible = false
                break
            end
            node = node.Parent
        end
        if visible then
            return true
        end
    end
    return false
end

--- 保留原有字符串提示入口，替换提示时清除旧 Key，避免语言变化恢复旧提示。
--- @param message string 已准备好的提示内容。
--- @param duration number? 显示时长，单位为秒。
function UI:ShowTips(message, duration)
    self._tipKey, self._tipArguments = nil, nil
    UI.Super.ShowTips(self, message, duration)
end

--- 共用提示入口保留定义与参数供语言刷新；参数由调用方按文案语义准备。
--- @param key table Key/Source 文案定义。
--- @param arguments table? 提示模板参数。
--- @param duration number? 显示时长，单位为秒。
function UI:ShowLocalizedTips(key, arguments, duration)
    Text.ValidateDefinition(key)
    self:ShowTips(Text.Tr(key, arguments), duration)
    self._tipKey, self._tipArguments = key, arguments
end

--- 弹窗保存文案定义以便刷新；其余沿用框架文本和回调参数。
--- @param params table DescKey/ConfirmKey/CancelKey 为文案定义；Arguments 为模板参数。
function UI:ShowTooltips(params)
    self._descriptionKey, self._descriptionArguments = params.DescKey, params.Arguments
    self._confirmKey = params.ConfirmKey
    self._cancelKey = params.CancelKey
    local options = table.clone(params)
    if self._descriptionKey then
        options.Desc = Text.Tr(self._descriptionKey, self._descriptionArguments)
    end
    self.Confirm.AutoLocalize = self._confirmKey == nil
    self.Cancel.AutoLocalize = self._cancelKey == nil
    if self._confirmKey then
        options.ConfirmBtnTxt = Text.Tr(self._confirmKey)
    end
    if self._cancelKey then
        options.CancelBtnTxt = Text.Tr(self._cancelKey)
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
    for index, node in ipairs(self:GetPlayerNode():GetDescendants()) do
        if node:IsA("Tool") then
            self:LocalizeTool(node)
        end
    end
    local character = self:GetPlayerNode().Character
    if character then
        for index, node in ipairs(character:GetChildren()) do
            if node:IsA("Tool") then
                self:LocalizeTool(node)
            end
        end
    end
    if self._tipKey and self._tipLabel then
        self._tipLabel.Text = Text.Tr(self._tipKey, self._tipArguments)
    end
    if self._descriptionKey then
        self.Description.Text = Text.Tr(self._descriptionKey, self._descriptionArguments)
    end
    if self._confirmKey then
        self.Confirm.Text = Text.Tr(self._confirmKey)
    end
    if self._cancelKey then
        self.Cancel.Text = Text.Tr(self._cancelKey)
    end
    self:RefreshSelectedTool()
end

--- 仅显示道具表中的框架道具；镐子等表外特殊工具不显示说明框。
function UI:RefreshSelectedTool()
    local tool = self._selectedTool
    local itemId = tool and tool:GetAttribute("FrameworkItemId")
    if not itemId or not ItemConfig.Data[itemId] then
        self._toolDescription:SetTool(nil)
        return
    end
    local description = Text.TrSource(ItemConfig.Display[itemId].Desc)
    self._toolDescription:SetTool(tool, description)
end

--- 装备变化时替换道具属性监听，避免旧道具继续覆盖当前说明。
--- @param tool Tool? 当前角色持有的道具。
function UI:SetSelectedTool(tool)
    for index, connection in ipairs(self._selectedToolConnections) do
        connection:Disconnect()
    end
    table.clear(self._selectedToolConnections)
    self._selectedTool = tool
    if tool then
        for index, property in ipairs({"Name", "ToolTip", "TextureId"}) do
            table.insert(self._selectedToolConnections, tool:GetPropertyChangedSignal(property):Connect(function()
                self:RefreshSelectedTool()
            end))
        end
        table.insert(self._selectedToolConnections, tool:GetAttributeChangedSignal("FrameworkItemId"):Connect(function()
            self:RefreshSelectedTool()
        end))
    end
    self:RefreshSelectedTool()
end

--- 原生背包不依赖自动文本采集，显示名与查找属性、存档模板名分离。
--- @param tool Tool 服务器通过 DisplayNameSource 提供配置原文的背包或装备道具。
function UI:LocalizeTool(tool)
    local source = tool:GetAttribute("DisplayNameSource")
    if not source then
        return
    end
    tool.Name = Text.TrSource(source)
    local price = tool:GetAttribute("Price")
    if price then
        local arguments = {item = tool.Name, price = GameUtility.NumberToText(price)}
        if tool:GetAttribute("IsLucky") == true then
            arguments.rate = GameUtility.NumberToText(tool:GetAttribute("LuckRate") or 1)
            tool.ToolTip = Text.Tr(TranslationTexts["Loot.LuckyTooltip"], arguments)
        else
            tool.ToolTip = Text.Tr(TranslationTexts["Loot.Tooltip"], arguments)
        end
    else
        tool.ToolTip = tool.Name
    end
end

--- 每次重生替换角色监听，确保云端加载前后及装备切换都能刷新道具文案。
--- @param character Model 当前玩家的角色，旧角色的连接在重新绑定时释放。
function UI:BindCharacterTools(character)
    if self._characterToolConnection then
        self._characterToolConnection:Disconnect()
    end
    if self._characterToolRemovedConnection then
        self._characterToolRemovedConnection:Disconnect()
    end
    self:SetSelectedTool(nil)
    --- Tool 已由服务器设置文案属性后才复制到角色。
    --- @param node Instance 角色新增的直接子节点。
    self._characterToolConnection = character.ChildAdded:Connect(function(node)
        if node:IsA("Tool") then
            self:LocalizeTool(node)
            self:SetSelectedTool(node)
        end
    end)
    --- 收起、消耗或销毁当前道具后立即隐藏，也覆盖角色死亡的清理过程。
    --- @param node Instance 从角色移出的直接子节点。
    self._characterToolRemovedConnection = character.ChildRemoved:Connect(function(node)
        if node == self._selectedTool then
            self:SetSelectedTool(character:FindFirstChildOfClass("Tool"))
        end
    end)
    for index, node in ipairs(character:GetChildren()) do
        if node:IsA("Tool") then
            self:LocalizeTool(node)
            self:SetSelectedTool(node)
        end
    end
end

--- 清理项目监听与翻译资源，提示和浮窗节点由父类统一释放。
function UI:Dtor()
    if self._characterToolConnection then
        self._characterToolConnection:Disconnect()
    end
    if self._characterToolRemovedConnection then
        self._characterToolRemovedConnection:Disconnect()
    end
    self:SetSelectedTool(nil)
    self._toolDescription:Destroy()
    self._buttonHover:Destroy()
    FX.Network:UnRegServerMsgCallback("S2C_ShowLocalizedTips")
    self.Localization:Destroy()
    FC.Localization = nil
    UI.Super.Dtor(self)
end

return UI
