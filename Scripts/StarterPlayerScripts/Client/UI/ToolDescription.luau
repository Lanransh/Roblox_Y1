-- 道具说明展示：挂在力量栏下方，继承主界面分组的屏幕适配。
local ToolDescription = {}
ToolDescription.__index = ToolDescription
local TextService = game:GetService("TextService")

--- 创建组件拥有的展示节点，统一设置属性后再挂载。
--- @param className string Roblox 节点类型。
--- @param parent Instance 父节点。
--- @param properties table 节点属性。
--- @return Instance 新建节点。
local function Node(className, parent, properties)
    local node = Instance.new(className)
    for key, value in pairs(properties) do
        node[key] = value
    end
    node.Parent = parent
    return node
end

--- 与力量栏同级挂载，避免关卡隐藏力量栏时连带隐藏道具说明。
--- @param strength GuiObject 主界面的力量栏。
--- @return table 可复用的道具说明展示对象。
function ToolDescription.New(strength)
    local self = setmetatable({}, ToolDescription)
    local position, size, anchor = strength.Position, strength.Size, strength.AnchorPoint
    self._root = Node("Frame", strength.Parent, {
        Name = "ToolDescription", AnchorPoint = Vector2.new(0.5, 0),
        Position = position + UDim2.new(
            size.X.Scale * (0.5 - anchor.X), size.X.Offset * (0.5 - anchor.X),
            size.Y.Scale * (1 - anchor.Y), size.Y.Offset * (1 - anchor.Y) + 10),
        Size = UDim2.fromOffset(220, 72),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false,
    })
    self._root:SetAttribute("BlocksTrainingClick", true)
    Node("UICorner", self._root, {CornerRadius = UDim.new(0, 12)})
    Node("UIStroke", self._root, {
        Name = "OuterOutline", ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = Color3.fromRGB(23, 17, 12), Thickness = 3,
    })
    local smoke = Node("Frame", self._root, {
        Name = "Smoke", Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(48, 38, 30), BackgroundTransparency = 0.22,
        BorderSizePixel = 0, ZIndex = 1,
    })
    Node("UICorner", smoke, {CornerRadius = UDim.new(0, 12)})
    Node("UIStroke", smoke, {
        Name = "CardBorder", ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = Color3.fromRGB(209, 182, 130), Thickness = 2, Transparency = 0.18,
    })
    local glow = Node("Frame", smoke, {
        Name = "WarmMist", Position = UDim2.fromScale(0, 0.04), Size = UDim2.fromScale(1, 0.44),
        BackgroundColor3 = Color3.fromRGB(144, 109, 66), BackgroundTransparency = 0.8,
        BorderSizePixel = 0,
    })
    Node("UICorner", glow, {CornerRadius = UDim.new(0, 12)})
    Node("UIGradient", glow, {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.35, 0.2),
            NumberSequenceKeypoint.new(0.65, 0.2), NumberSequenceKeypoint.new(1, 1),
        }),
    })
    self._icon = Node("ImageLabel", self._root, {
        Name = "Icon", Position = UDim2.fromOffset(12, 12), Size = UDim2.fromOffset(48, 48),
        BackgroundTransparency = 1, ScaleType = Enum.ScaleType.Fit, Image = "", ZIndex = 2,
    })
    self._content = Node("Frame", self._root, {
        Name = "Content", Position = UDim2.fromOffset(72, 10), Size = UDim2.new(1, -88, 0, 0),
        BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 2,
    })
    Node("UIPadding", self._content, {PaddingBottom = UDim.new(0, 12)})
    -- 标题和描述按实际换行高度向下排列，保持大字号而不互相遮挡。
    Node("UIListLayout", self._content, {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder})
    self._title = Node("TextLabel", self._content, {
        Name = "Title", Size = UDim2.new(1, 0, 0, 32), LayoutOrder = 1,
        BackgroundTransparency = 1, AutoLocalize = false, Font = Enum.Font.GothamBlack,
        TextSize = 26, TextColor3 = Color3.fromRGB(255, 243, 215), TextXAlignment = Enum.TextXAlignment.Left,
        TextScaled = false, TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y, Text = "", ZIndex = 2,
    })
    self._description = Node("TextLabel", self._content, {
        Name = "Description", Size = UDim2.new(1, 0, 0, 0), LayoutOrder = 2,
        BackgroundTransparency = 1, AutoLocalize = false, Font = Enum.Font.GothamBold,
        TextSize = 22, TextColor3 = Color3.fromRGB(250, 247, 237),
        TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true, TextScaled = false, AutomaticSize = Enum.AutomaticSize.Y, Text = "", ZIndex = 2,
    })
    for index, label in ipairs({self._title, self._description}) do
        Node("UIStroke", label, {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
            Color = Color3.fromRGB(23, 17, 12), Transparency = 0,
            Thickness = label == self._title and 2 or 1.5,
        })
    end
    return self
end

--- 按当前图标和文案计算宽度；短描述收窄，长描述在最大宽度内换行撑高。
--- @param tool Tool? 当前装备的原生道具；nil 时隐藏。
--- @param description string? 已通过项目本地化入口处理的描述。
function ToolDescription:SetTool(tool, description)
    self._root.Visible = tool ~= nil
    if not tool then
        return
    end
    local hasIcon = tool.TextureId ~= ""
    self._icon.Image = tool.TextureId
    self._icon.Visible = hasIcon
    local left = hasIcon and 72 or 16
    self._title.Text = tool.Name
    self._description.Text = description or tool.ToolTip
    local titleSize = TextService:GetTextSize(self._title.Text, self._title.TextSize, self._title.Font, Vector2.new(10000, 10000))
    local descriptionSize = TextService:GetTextSize(self._description.Text, self._description.TextSize, self._description.Font, Vector2.new(10000, 10000))
    local width = math.clamp(math.ceil(math.max(titleSize.X, descriptionSize.X)) + left + 22, 220, 420)
    self._root.Size = UDim2.fromOffset(width, 72)
    self._content.Position = UDim2.fromOffset(left, 10)
    self._content.Size = UDim2.new(1, -left - 16, 0, 0)
end

--- 只销毁当前展示对象创建的节点，保留主界面力量栏。
function ToolDescription:Destroy()
    self._root:Destroy()
end

return ToolDescription
