local FX = _G.FX
local FXLoader = FX.Loader
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local GameUtility = FXLoader:RequireShared("Scripts/Game/Shared/GameUtility")
local Component = FX.Class("CLeaderboardUICompClass", "FCUICompClass")

-- 测试名次与力量不是这些账号的真实成绩；UserId 仅用于 Roblox 原生头像。
local TestUsers = {
    {Id = 1, Name = "Builder"}, {Id = 156, Name = "StarRunner"},
    {Id = 261, Name = "RockMaster"}, {Id = 48103520, Name = "PowerHero"},
    {Id = 1237666, Name = "GoldenEgg"},
}
local Gold = Color3.fromRGB(255, 194, 46)
local Cream = Color3.fromRGB(255, 237, 198)

--- 创建本组件拥有的节点，先设置属性再加入父级。
--- @param className string 原生实例类型。
--- @param parent Instance 父节点。
--- @param properties table 本次布局属性。
--- @return Instance 新节点。
local function Create(className, parent, properties)
    local node = Instance.new(className)
    for key, value in pairs(properties) do
        node[key] = value
    end
    node.Parent = parent
    return node
end

--- 统一榜单字体；文字由项目翻译入口赋值，关闭二次自动翻译。
--- @param parent Instance 父节点。
--- @param text string 英文兜底或数字。
--- @param position UDim2 列位置。
--- @param size UDim2 列尺寸。
--- @return TextLabel 文字节点。
local function Label(parent, text, position, size)
    return Create("TextLabel", parent, {
        BackgroundTransparency = 1, Position = position, Size = size,
        Text = text, TextColor3 = Cream, TextSize = 36,
        Font = Enum.Font.FredokaOne, AutoLocalize = false,
        TextStrokeTransparency = 0.65, TextTruncate = Enum.TextTruncate.AtEnd,
    })
end

--- 返回玩家内的排行榜协作名称。
--- @return string 组件名称。
function Component:GetCompName()
    return "CLeaderboardUIComp"
end

--- UI 留在 PlayerGui；仅通过 Adornee 绑定已存在的模型面板。
function Component:OnReady()
    self._localization = self:GetPlayerObject():RequireComponent("FCCommonUIComp").Localization
    local panel = FXLoader:Workspace("BlockMeshs/世界1/Base/排行榜1/橙木空白排行榜/空白深色面板")
    self._panel = panel
    self._gui = Create("SurfaceGui", self:GetPlayerNode():WaitForChild("PlayerGui"), {
        Name = "StrengthLeaderboard", Adornee = panel, Face = Enum.NormalId.Back,
        SizingMode = Enum.SurfaceGuiSizingMode.FixedSize, CanvasSize = Vector2.new(720, 912),
        AlwaysOnTop = false, LightInfluence = 0, Active = true,
        ResetOnSpawn = false, MaxDistance = 180, ZOffset = 0.02,
    })
    self._rootNode = Create("Frame", self._gui, {
        Name = "Panel", Size = UDim2.fromScale(1, 1), BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(39, 27, 27),
    })
    self._title = Label(self._rootNode, "Strength Leaderboard", UDim2.fromScale(0.03, 0.025), UDim2.fromScale(0.94, 0.065))
    self._title.TextSize = 46
    self._title.Name = "Title"
    self._rankHeader = Label(self._rootNode, "Rank", UDim2.fromScale(0.03, 0.1), UDim2.fromScale(0.13, 0.045))
    self._playerHeader = Label(self._rootNode, "Player", UDim2.fromScale(0.26, 0.1), UDim2.fromScale(0.43, 0.045))
    self._strengthHeader = Label(self._rootNode, "Strength", UDim2.fromScale(0.70, 0.1), UDim2.fromScale(0.27, 0.045))
    self._rankHeader.Name = "RankHeader"
    self._playerHeader.Name = "PlayerHeader"
    self._strengthHeader.Name = "StrengthHeader"
    self._rankHeader.TextSize = 32
    self._playerHeader.TextSize = 32
    self._strengthHeader.TextSize = 32
    self._list = Create("ScrollingFrame", self._rootNode, {
        Name = "RankList", Position = UDim2.fromScale(0.03, 0.16), Size = UDim2.fromScale(0.94, 0.66),
        BackgroundTransparency = 1, BorderSizePixel = 0, Active = true,
        CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y, ScrollBarThickness = 8,
        ScrollBarImageColor3 = Gold,
    })
    Create("UIListLayout", self._list, {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)})
    for rank = 1, 20 do
        local user = TestUsers[(rank - 1) % #TestUsers + 1]
        self:CreateRow(self._list, rank, user.Id, user.Name, 35000000 / rank ^ 2, false)
    end
    local player = self:GetPlayerNode()
    local personal = self:CreateRow(self._rootNode, 101, player.UserId, "You", 6320, true)
    personal.Position = UDim2.fromScale(0.03, 0.835)
    personal.Size = UDim2.fromScale(0.94, 0.075)
    self._personalName = personal.PlayerName
    self._refresh = Create("TextButton", self._rootNode, {
        Name = "Refresh", Position = UDim2.fromScale(0.03, 0.915), Size = UDim2.fromScale(0.61, 0.055),
        BackgroundColor3 = Color3.fromRGB(68, 46, 32), BorderSizePixel = 0,
        TextColor3 = Cream, TextSize = 22, Font = Enum.Font.FredokaOne,
        AutoLocalize = false, AutoButtonColor = true, Text = "Refresh",
    })
    self._testLabel = Label(self._rootNode, "Test Data", UDim2.fromScale(0.66, 0.915), UDim2.fromScale(0.31, 0.055))
    self._testLabel.TextSize = 20
    self._testLabel.Name = "TestData"
    self._boards = {{Panel = panel, Gui = self._gui}}
    local worldPaths = {"BlockMeshs/世界2/世界2/Base/排行榜1", "BlockMeshs/世界3/世界3/Base/排行榜1"}
    self._refreshAt = os.time() + 60
    for index, board in ipairs(self._boards) do
        self:TrackConnection(board.Gui.Panel.Refresh.Activated:Connect(function()
            -- 三个世界共用同一测试榜与刷新时刻，各自保留滚动位置。
            board.Gui.Panel.RankList.CanvasPosition = Vector2.zero
            self._refreshAt = os.time() + 60
            self:RefreshLocalization()
        end))
    end
    self:TrackConnection(self._localization.Changed:Connect(function()
        self:RefreshLocalization()
    end))
    self:BindCameraView()
    self:RefreshLocalization()
    self._boardTasks = {}
    for index, path in ipairs(worldPaths) do
        self._boardTasks[index] = task.defer(function()
            self:AttachWorldBoard(path, index + 1)
            self._boardTasks[index] = nil
        end)
    end
end

--- 其他世界异步等待复制完成，不能阻塞首个榜单的按钮与输入初始化。
--- @param path string 已核对的世界排行榜模型路径。
--- @param worldIndex number 世界编号，用于界面节点名。
function Component:AttachWorldBoard(path, worldIndex)
    local model = workspace
    for segment in string.gmatch(path, "[^/]+") do
        model = model:WaitForChild(segment)
    end
    local display = model:FindFirstChild("空白深色面板", true)
    while not display do
        model.DescendantAdded:Wait()
        display = model:FindFirstChild("空白深色面板", true)
    end
    assert(display:IsA("BasePart"), "Invalid leaderboard panel: " .. path)
    local gui = self._gui:Clone()
    gui.Name = "StrengthLeaderboardWorld" .. worldIndex
    gui.Adornee = display
    gui.Parent = self._gui.Parent
    table.insert(self._boards, {Panel = display, Gui = gui})
    self:TrackConnection(gui.Panel.Refresh.Activated:Connect(function()
        gui.Panel.RankList.CanvasPosition = Vector2.zero
        self._refreshAt = os.time() + 60
        self:RefreshLocalization()
    end))
    self:RefreshLocalization()
end

--- 查看与退出按钮位于屏幕右侧，避开底部物品栏，不往模型添加节点。
function Component:BindCameraView()
    self._viewUI = Create("ScreenGui", self:GetPlayerNode():WaitForChild("PlayerGui"), {
        Name = "LeaderboardViewControls", ResetOnSpawn = false, DisplayOrder = 30,
    })
    self._viewButton = Create("TextButton", self._viewUI, {
        Name = "View", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.fromScale(0.97, 0.65),
        Size = UDim2.new(0.38, 0, 0, 48), BackgroundColor3 = Gold, BorderSizePixel = 0,
        TextColor3 = Color3.fromRGB(64, 38, 15), Font = Enum.Font.FredokaOne, TextSize = 22,
        AutoLocalize = false, Visible = false, Text = "E · View Leaderboard",
    })
    Create("UISizeConstraint", self._viewButton, {MaxSize = Vector2.new(310, 48)})
    Create("UICorner", self._viewButton, {CornerRadius = UDim.new(0, 14)})
    Create("UIStroke", self._viewButton, {Color = Color3.fromRGB(255, 225, 139), Thickness = 2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border})
    self:TrackConnection(self._viewButton.Activated:Connect(function()
        self:EnterView()
    end))
    self._closeButton = Create("TextButton", self._viewUI, {
        Name = "Close", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.fromScale(0.97, 0.65),
        Size = UDim2.new(0.38, 0, 0, 48), BackgroundColor3 = Gold, BorderSizePixel = 0,
        TextColor3 = Color3.fromRGB(64, 38, 15), Font = Enum.Font.FredokaOne, TextSize = 22,
        AutoLocalize = false, Visible = false, Modal = true, Text = "Close · E",
    })
    Create("UISizeConstraint", self._closeButton, {MaxSize = Vector2.new(310, 48)})
    Create("UICorner", self._closeButton, {CornerRadius = UDim.new(0, 14)})
    Create("UIStroke", self._closeButton, {Color = Color3.fromRGB(255, 225, 139), Thickness = 2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border})
    self:GetPlayerObject():RequireComponent("FCCommonUIComp"):RegisterTrainingClickModal(self._closeButton)
    self:TrackConnection(self._closeButton.Activated:Connect(function()
        self:ExitView()
    end))
    self:TrackConnection(UserInputService.InputBegan:Connect(function(input, processed)
        if processed or input.KeyCode ~= Enum.KeyCode.E then
            return
        end
        if self._cameraState then
            self:ExitView()
        else
            self:EnterView()
        end
    end))
    local elapsed = 0
    self:TrackConnection(RunService.Heartbeat:Connect(function(deltaTime)
        elapsed += deltaTime
        if elapsed < 0.1 then
            return
        end
        elapsed = 0
        local character = self:GetPlayerCharacter()
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local activeNear = false
        self._nearBoard = nil
        local nearestDistance = math.huge
        for index, board in ipairs(self._boards) do
            local panel = board.Panel
            local near = false
            if root and humanoid and humanoid.Health > 0 and panel:IsDescendantOf(workspace) then
                local point = panel.CFrame:PointToObjectSpace(root.Position)
                local bottom = -panel.Size.Y / 2
                near = math.abs(point.X) <= panel.Size.X / 2 + 3
                    and math.abs(point.Y - bottom) <= 9 and point.Z >= 0 and point.Z <= 14
            end
            if near then
                local distance = (root.Position - panel.Position).Magnitude
                if distance < nearestDistance then
                    nearestDistance = distance
                    self._nearBoard = board
                end
            end
            if panel == self._panel then
                activeNear = near
            end
        end
        if self._cameraState and (not activeNear or workspace.CurrentCamera ~= self._cameraState.Camera) then
            self:ExitView()
        end
        self._viewButton.Visible = self._nearBoard ~= nil and not self._cameraState
    end))
end

--- 以显示面正面为镜头轴；按屏幕比例计算距离，完整容纳榜单。
function Component:EnterView()
    if self._cameraState or not self._nearBoard then
        return
    end
    local camera = workspace.CurrentCamera
    if not camera then
        return
    end
    self._panel = self._nearBoard.Panel
    self._cameraState = {
        Camera = camera, Type = camera.CameraType, Subject = camera.CameraSubject,
        CFrame = camera.CFrame, Focus = camera.Focus,
    }
    camera.CameraType = Enum.CameraType.Scriptable
    self._viewButton.Visible = false
    self._closeButton.Visible = true
    -- 仅阻止角色移动与跳跃，保留鼠标和触屏滚动、点击。
    ContextActionService:BindActionAtPriority("LeaderboardViewMovement", function()
        return Enum.ContextActionResult.Sink
    end, false, 3000, table.unpack(Enum.PlayerActions:GetEnumItems()))
    self._cameraConnection = RunService.RenderStepped:Connect(function(deltaTime)
        local panel = self._panel
        local aspect = camera.ViewportSize.X / math.max(1, camera.ViewportSize.Y)
        local halfHeight = math.max(panel.Size.Y / 2, panel.Size.X / (2 * aspect))
        local distance = halfHeight / math.tan(math.rad(camera.FieldOfView / 2)) * 1.15
        local target = panel.CFrame:PointToWorldSpace(Vector3.new(0, 0, panel.Size.Z / 2))
        local position = target + panel.CFrame.ZVector * distance
        local frame = CFrame.lookAt(position, target, panel.CFrame.UpVector)
        camera.CFrame = camera.CFrame:Lerp(frame, 1 - math.exp(-12 * deltaTime))
        camera.Focus = CFrame.new(target)
    end)
end

--- 退出、死亡或组件销毁时恢复镜头，解除本组件的移动限制。
function Component:ExitView()
    local state = self._cameraState
    if not state then
        return
    end
    self._cameraState = nil
    self._cameraConnection:Disconnect()
    self._cameraConnection = nil
    ContextActionService:UnbindAction("LeaderboardViewMovement")
    state.Camera.CFrame = state.CFrame
    state.Camera.Focus = state.Focus
    state.Camera.CameraSubject = state.Subject
    state.Camera.CameraType = state.Type
    self._closeButton.Visible = false
end

--- 创建统一三列与圆形头像；用户名、排名和数值不参与翻译。
--- @param parent Instance 列表或固定个人行的父节点。
--- @param rank number 测试名次。
--- @param userId number 头像账号 ID。
--- @param playerName string 测试昵称或个人行英文兜底。
--- @param strength number 原始测试力量。
--- @param personal boolean 是否为金色个人行。
--- @return Frame 排行条目。
function Component:CreateRow(parent, rank, userId, playerName, strength, personal)
    local row = Create("Frame", parent, {
        Name = "Rank" .. rank, LayoutOrder = rank, Size = UDim2.new(1, -12, 0, 70), BorderSizePixel = 0,
        BackgroundColor3 = personal and Gold or (rank % 2 == 0 and Color3.fromRGB(48, 33, 31) or Color3.fromRGB(59, 41, 37)),
    })
    Label(row, "#" .. rank, UDim2.fromScale(0, 0), UDim2.fromScale(0.14, 1))
    local avatar = Create("ImageLabel", row, {
        Name = "Avatar", Position = UDim2.new(0.15, 0, 0.5, -28), Size = UDim2.fromOffset(56, 56),
        BackgroundColor3 = Color3.fromRGB(25, 25, 25), BorderSizePixel = 0,
        Image = "rbxthumb://type=AvatarHeadShot&id=" .. userId .. "&w=150&h=150",
    })
    Create("UICorner", avatar, {CornerRadius = UDim.new(1, 0)})
    local name = Label(row, playerName, UDim2.fromScale(0.25, 0), UDim2.fromScale(0.43, 1))
    name.Name = "PlayerName"
    Label(row, GameUtility.NumberToText(strength), UDim2.fromScale(0.70, 0), UDim2.fromScale(0.29, 1))
    if personal then
        for index, child in ipairs(row:GetChildren()) do
            if child:IsA("TextLabel") then
                child.TextColor3 = Color3.fromRGB(43, 28, 18)
                child.TextStrokeTransparency = 1
            end
        end
    end
    return row
end

--- 云端译文就绪或语言切换时刷新文案，倒计时使用稳定参数 Key。
function Component:RefreshLocalization()
    self._title.Text = self._localization:FormatByKey("Leaderboard.StrengthTitle")
    self._rankHeader.Text = self._localization:FormatByKey("Leaderboard.Rank")
    self._playerHeader.Text = self._localization:FormatByKey("Leaderboard.Player")
    self._strengthHeader.Text = self._localization:FormatByKey("Leaderboard.Strength")
    self._personalName.Text = self._localization:FormatByKey("Leaderboard.You")
    self._testLabel.Text = self._localization:FormatByKey("Leaderboard.TestData")
    self._viewButton.Text = self._localization:FormatByKey("Leaderboard.View")
    for index, board in ipairs(self._boards) do
        local panel = board.Gui.Panel
        for labelIndex, label in ipairs({self._title, self._rankHeader, self._playerHeader, self._strengthHeader, self._testLabel}) do
            panel[label.Name].Text = label.Text
        end
        panel.Rank101.PlayerName.Text = self._personalName.Text
    end
    self._closeButton.Text = self._localization:FormatByKey("Leaderboard.Close")
    self:OnUpdate(os.time())
end

--- 使用框架每秒更新，不创建独立循环；测试数据每分钟保持同一快照。
--- @param serverTime number 框架提供的当前秒时间。
function Component:OnUpdate(serverTime)
    if not self._refresh then
        return
    end
    if serverTime >= self._refreshAt then
        self._refreshAt = serverTime + 60
    end
    local seconds = math.max(0, self._refreshAt - serverTime)
    local text = self._localization:FormatByKey("Leaderboard.Refresh", {
        time = string.format("%d:%02d", math.floor(seconds / 60), seconds % 60),
    })
    for index, board in ipairs(self._boards) do
        board.Gui.Panel.Refresh.Text = text
    end
end

--- 只销毁组件创建的界面，模型和显示面保持原样。
function Component:Dtor()
    self:ExitView()
    for index, thread in pairs(self._boardTasks or {}) do
        task.cancel(thread)
    end
    for index, board in ipairs(self._boards or {}) do
        board.Gui:Destroy()
    end
    if self._viewUI then
        self._viewUI:Destroy()
    end
    Component.Super.Dtor(self)
end

return Component
