local FX, FC = _G.FX, _G.FC
local UI = FX.Class("FCCommonUICompClass", "FCPlayerCompClass")
FC.CommonUICompClass = UI

local function Node(className, name, parent, properties)
    local node = Instance.new(className)
    node.Name = name
    for key, value in pairs(properties or {}) do
        node[key] = value
    end
    node.Parent = parent
    return node
end

local function Text(className, name, parent, properties)
    properties.Font = Enum.Font.Gotham
    properties.TextSize = 18
    properties.TextColor3 = Color3.fromRGB(240, 243, 250)
    properties.TextWrapped = true
    properties.BorderSizePixel = 0
    return Node(className, name, parent, properties)
end

function UI:Ctor(owner)
    UI.Super.Ctor(self, owner)
    self.Root = Node("ScreenGui", "FrameworkCommonUI", self:GetPlayerNode():WaitForChild("PlayerGui"), {
        ResetOnSpawn = false,
        DisplayOrder = 100,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    self.Tips = Text("TextLabel", "Tips", self.Root, {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.fromScale(0.5, 0.12),
        Size = UDim2.new(0.86, 0, 0, 64),
        BackgroundColor3 = Color3.fromRGB(28, 34, 48),
        BackgroundTransparency = 0.1,
        Visible = false,
        Text = "",
        ZIndex = 10,
    })
    Node("UISizeConstraint", "MaxWidth", self.Tips, { MaxSize = Vector2.new(600, 120) })
    Node("UICorner", "Corner", self.Tips, { CornerRadius = UDim.new(0, 12) })
    -- 全屏按钮消费遮罩区域的鼠标/触摸输入，避免弹窗后方的场景被点击。
    self.Modal = Text("TextButton", "Modal", self.Root, {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 0.4,
        AutoButtonColor = false,
        Modal = true,
        Selectable = false,
        Visible = false,
        Text = "",
    })
    local panel = Node("Frame", "Panel", self.Modal, {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(0.86, 0.65),
        BackgroundColor3 = Color3.fromRGB(28, 34, 48),
        BorderSizePixel = 0,
        Active = true,
    })
    Node("UISizeConstraint", "MaxSize", panel, { MaxSize = Vector2.new(520, 360) })
    Node("UICorner", "Corner", panel, { CornerRadius = UDim.new(0, 16) })
    local scroll = Node("ScrollingFrame", "Content", panel, {
        Position = UDim2.new(0, 20, 0, 16),
        Size = UDim2.new(1, -40, 1, -88),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 4,
    })
    self.Description = Text("TextLabel", "Description", scroll, {
        Size = UDim2.new(1, -8, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        TextYAlignment = Enum.TextYAlignment.Top,
        Text = "",
    })
    self.Cancel = Text("TextButton", "Cancel", panel, {
        Position = UDim2.new(0, 20, 1, -64),
        Size = UDim2.new(0.5, -30, 0, 44),
        BackgroundColor3 = Color3.fromRGB(64, 73, 92),
        Text = "取消",
    })
    self.Confirm = Text("TextButton", "Confirm", panel, {
        Position = UDim2.new(0.5, 10, 1, -64),
        Size = UDim2.new(0.5, -30, 0, 44),
        BackgroundColor3 = Color3.fromRGB(54, 104, 220),
        Text = "确定",
    })
    for _, button in ipairs({ self.Cancel, self.Confirm }) do
        Node("UICorner", "Corner", button, { CornerRadius = UDim.new(0, 10) })
    end
    self:TrackConnection(self.Confirm.Activated:Connect(function()
        self:_Finish(true)
    end))
    self:TrackConnection(self.Cancel.Activated:Connect(function()
        self:_Finish(false)
    end))
    self:SubscribeEvent("ShowTips", self.ShowTips)
end

function UI:GetCompName()
    return "FCCommonUIComp"
end

-- 后一次提示替换前一次；销毁组件时取消计时器。
function UI:ShowTips(message, duration)
    FX.Task:Cancel(self._tipTask)
    self.Tips.Text, self.Tips.Visible = tostring(message), true
    self._tipTask = task.delay(duration or 1.5, function()
        self._tipTask = nil
        self.Tips.Visible = false
    end)
end

-- 保留 Y3 参数：Desc、ConfirmBtnTxt、ConfirmCB；新增可选取消按钮与回调。
function UI:ShowTooltips(params)
    self:HideTooltips()
    local selection = game:GetService("GuiService")
    self._previousSelection = selection.SelectedObject
    self.Description.Text = params.Desc or ""
    self.Confirm.Text = params.ConfirmBtnTxt or "确定"
    self.Cancel.Text = params.CancelBtnTxt or "取消"
    self.Cancel.Visible = params.ShowCancel == true
    self._confirmCB, self._cancelCB = params.ConfirmCB, params.CancelCB
    self.Modal.Visible = true
    if game:GetService("UserInputService").GamepadEnabled then
        selection.SelectedObject = self.Confirm
    end
end

function UI:ShowConfirm(params)
    local options = table.clone(params)
    options.ShowCancel = true
    self:ShowTooltips(options)
end

function UI:_Finish(confirmed)
    if not self.Modal.Visible then
        return
    end
    local callback
    if confirmed then
        callback = self._confirmCB
    else
        callback = self._cancelCB
    end
    -- 先清空回调，避免重复点击，以及回调打开新弹窗后被旧弹窗关闭。
    self:HideTooltips()
    if callback then
        callback()
    end
end

function UI:HideTooltips()
    self._confirmCB, self._cancelCB = nil, nil
    self.Modal.Visible = false
    local selection = game:GetService("GuiService")
    local selected = selection.SelectedObject
    if selected and selected:IsDescendantOf(self.Modal) then
        local previous = self._previousSelection
        selection.SelectedObject = previous and previous.Parent and previous or nil
    end
    self._previousSelection = nil
end

function UI:Dtor()
    FX.Task:Cancel(self._tipTask)
    self:HideTooltips()
    UI.Super.Dtor(self)
    self.Root:Destroy()
end

return UI
