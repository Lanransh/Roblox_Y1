local FX = _G.FX
local FXLoader = FX.Loader
local Text = FXLoader:RequireShared("Scripts/Game/Shared/Text")
local TranslationTexts = Text.Define("Leaderboard", {
    StrengthTitle = "Strength Leaderboard",
    RebirthTitle = "Rebirth Leaderboard",
    PlaytimeTitle = "Playtime Leaderboard",
    Strength = "Strength",
    Rebirths = "Rebirths",
    Playtime = "Playtime",
    Rank = "Rank",
    Player = "Player",
    You = "You",
    View = "E · View Leaderboard",
    Close = "Close · E",
    Minutes = "{count:int}min",
    Hours = "{count:int}h",
    DaysHours = "{days:int}d{hours:int}h",
    Loading = "Loading...",
    Empty = "No rankings yet.",
    Unavailable = "Leaderboard unavailable.",
})

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local GameUtility = FXLoader:RequireShared("Scripts/Game/Shared/GameUtility")
local RankingDataConfig = FXLoader:RequireShared("Scripts/Game/Shared/RankingDataConfig")
local Component = FX.Class("CLeaderboardUICompClass", "FCUICompClass")

local Gold = Color3.fromRGB(255, 194, 46)
local Cream = Color3.fromRGB(255, 237, 198)
local VisibleRankCount = 7
local BoardTypes = {
    {Name = "Strength", TextColor = Gold},
    {Name = "Rebirth", TextColor = Color3.fromRGB(210, 165, 255)},
    {Name = "Playtime", TextColor = Color3.fromRGB(110, 235, 245)},
}

--- 力量沿用统一缩写，重生次数显示整数；在线不足一小时显示分钟，其余显示整小时或天和剩余小时。
--- @param kind number 榜单类型，依次为力量、重生和在线时长。
--- @param score number 服务端原始分数；在线时长单位为秒。
--- @return string 榜单数值文案。
local function FormatScore(kind, score)
    if kind == 1 then
        return GameUtility.NumberToText(score)
    end
    if kind == 3 then
        if score < 3600 then
            return Text.Tr(TranslationTexts.Minutes, {count = math.floor(score / 60)})
        end
        local hours = math.floor(score / 3600)
        if hours >= 24 then
            return Text.Tr(TranslationTexts.DaysHours, {days = math.floor(hours / 24), hours = hours % 24})
        end
        return Text.Tr(TranslationTexts.Hours, {count = hours})
    end
    return tostring(math.floor(score))
end

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

--- 统一榜单字体；运行时标签由本组件翻译，避免再次自动翻译。
--- @param parent Instance 父节点。
--- @param text string 英文兜底或数字。
--- @param position UDim2 列位置。
--- @param size UDim2 列尺寸。
--- @return TextLabel 文字节点。
local function Label(parent, text, position, size)
    return Create("TextLabel", parent, {
        BackgroundTransparency = 1, Position = position, Size = size,
        Text = text, TextColor3 = Cream, TextSize = 42,
        Font = Enum.Font.FredokaOne, AutoLocalize = false,
        TextStrokeTransparency = 0.65, TextTruncate = Enum.TextTruncate.AtEnd,
    })
end

--- 返回玩家内的排行榜协作名称。
--- @return string 组件名称。
function Component:GetCompName()
    return "CLeaderboardUIComp"
end

--- UI 留在 PlayerGui；绑定现有模型面板，前七名纵向滚动，个人行固定显示。
function Component:OnReady()
    self._localization = self:GetPlayerObject():RequireComponent("FCCommonUIComp").Localization
    self._rankingData = {}
    self._rankingErrors = {}
    self._rankingIndexes = {}
    for index, config in ipairs(RankingDataConfig) do
        self._rankingIndexes[config.Name] = index
    end
    local panel = FXLoader:Workspace("BlockMeshs/World1Root/Base/排行榜1/橙木空白排行榜/空白深色面板")
    self._panel = panel
    self._gui = Create("SurfaceGui", FXLoader:Here(self:GetPlayerNode(), "PlayerGui", math.huge), {
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
    self._title.TextSize = 52
    self._title.Name = "Title"
    self._rankHeader = Label(self._rootNode, "Rank", UDim2.fromScale(0.03, 0.1), UDim2.fromScale(0.13, 0.045))
    self._playerHeader = Label(self._rootNode, "Player", UDim2.fromScale(0.26, 0.1), UDim2.fromScale(0.43, 0.045))
    self._strengthHeader = Label(self._rootNode, "Strength", UDim2.fromScale(0.70, 0.1), UDim2.fromScale(0.27, 0.045))
    self._rankHeader.Name = "RankHeader"
    self._playerHeader.Name = "PlayerHeader"
    self._strengthHeader.Name = "StrengthHeader"
    self._rankHeader.TextSize = 36
    self._playerHeader.TextSize = 36
    self._strengthHeader.TextSize = 36
    self._list = Create("ScrollingFrame", self._rootNode, {
        Name = "RankList", Position = UDim2.fromScale(0.03, 0.16), Size = UDim2.fromScale(0.94, 0.66),
        BackgroundTransparency = 1, BorderSizePixel = 0, Active = true,
        CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingEnabled = true, ScrollingDirection = Enum.ScrollingDirection.Y, ScrollBarThickness = 8,
        ScrollBarImageColor3 = Gold,
    })
    Create("UIListLayout", self._list, {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)})
    for rank = 1, VisibleRankCount do
        self:CreateRow(self._list, rank, false).Visible = false
    end
    local status = Label(self._rootNode, "", UDim2.fromScale(0.03, 0.38), UDim2.fromScale(0.94, 0.065))
    status.Name = "Status"
    status.TextSize = 30
    local personal = self:CreateRow(self._rootNode, 0, true)
    personal.Position = UDim2.fromScale(0.03, 0.835)
    personal.Size = UDim2.fromScale(0.94, 0.095)
    self._boards = {{Panel = panel, Gui = self._gui, Kind = 1}}
    local worldPaths = {"BlockMeshs/World1Root/Base", "BlockMeshs/World2Root/世界2/Base", "BlockMeshs/World3Root/世界3/Base"}
    self:TrackConnection(self._localization.Changed:Connect(function()
        self:RefreshLocalization()
    end))
    self:BindCameraView()
    self:RefreshLocalization()
    self._boardTasks = {}
    for worldIndex, path in ipairs(worldPaths) do
        for kind = 1, #BoardTypes do
            if worldIndex ~= 1 or kind ~= 1 then
                local taskIndex = (worldIndex - 1) * #BoardTypes + kind
                self._boardTasks[taskIndex] = task.defer(function()
                    self:AttachWorldBoard(path .. "/排行榜" .. kind, worldIndex, kind)
                    self._boardTasks[taskIndex] = nil
                end)
            end
        end
    end
    self._rankingTask = task.defer(function()
        while true do
            self:RefreshRankingData()
            task.wait(30)
        end
    end)
end

--- 其余八块榜单沿用前七名布局，异步等待复制，避免阻塞首个榜单初始化。
--- @param path string 已核对的世界排行榜模型路径。
--- @param worldIndex number 世界编号，用于界面节点名。
--- @param kind number 榜单类型，依次为力量、重生和在线时长。
function Component:AttachWorldBoard(path, worldIndex, kind)
    local model = FXLoader:Workspace(path, math.huge)
    local display = model:FindFirstChild("空白深色面板", true)
    while not display do
        model.DescendantAdded:Wait()
        display = model:FindFirstChild("空白深色面板", true)
    end
    assert(display:IsA("BasePart"), "Invalid leaderboard panel: " .. path)
    local gui = self._gui:Clone()
    local config = BoardTypes[kind]
    gui.Name = config.Name .. "LeaderboardWorld" .. worldIndex
    gui.Adornee = display
    gui.Parent = self._gui.Parent
    table.insert(self._boards, {Panel = display, Gui = gui, Kind = kind})
    self:RefreshLocalization()
end

--- 三种榜单各请求一次，所有世界复用结果；串行轮询避免网络请求重叠。
function Component:RefreshRankingData()
    for kind, config in ipairs(BoardTypes) do
        local success, data = pcall(function()
            return FX.Network:InvokeServer("C2S_RankingData", 2, self._rankingIndexes[config.Name], 1, VisibleRankCount)
        end)
        if self._destroyed then
            return
        end
        if success and type(data) == "table" and type(data.itemData) == "table" then
            self._rankingData[kind] = data
            self._rankingErrors[kind] = nil
        else
            self._rankingData[kind] = nil
            self._rankingErrors[kind] = true
        end
    end
    self:RefreshLocalization()
end

--- 用缓存的真实成绩更新榜单；空榜与查询失败均不伪造玩家、分数或个人名次。
--- @param board table 当前世界的显示面、界面和榜单类型。
function Component:RefreshBoardData(board)
    local panel = FXLoader:Here(board.Gui, "Panel")
    local data = self._rankingData[board.Kind]
    local items = data and data.itemData or {}
    for rank = 1, VisibleRankCount do
        local row = FXLoader:Here(panel, "RankList/Rank" .. rank)
        local item = items[rank]
        row.Visible = item ~= nil
        if item then
            FXLoader:Here(row, "RankNumber").Text = "#" .. item.rankNo
            FXLoader:Here(row, "PlayerName").Text = item.playerName
            FXLoader:Here(row, "Avatar").Image = "rbxthumb://type=AvatarHeadShot&id=" .. item.playerId .. "&w=150&h=150"
            FXLoader:Here(row, "Score").Text = FormatScore(board.Kind, item.rankScore)
        end
    end
    local status = FXLoader:Here(panel, "Status")
    status.Visible = #items == 0
    if self._rankingErrors[board.Kind] then
        status.Text = Text.Tr(TranslationTexts.Unavailable)
    elseif data then
        status.Text = Text.Tr(TranslationTexts.Empty)
    else
        status.Text = Text.Tr(TranslationTexts.Loading)
    end
    local personal = FXLoader:Here(panel, "Personal")
    FXLoader:Here(personal, "RankNumber").Text = data and data.myNo and ("#" .. data.myNo) or "--"
    FXLoader:Here(personal, "Score").Text = data and data.myScore ~= nil and FormatScore(board.Kind, data.myScore) or "--"
    FXLoader:Here(personal, "PlayerName").Text = Text.Tr(TranslationTexts.You)
    FXLoader:Here(personal, "Avatar").Image = "rbxthumb://type=AvatarHeadShot&id=" .. self:GetPlayerId() .. "&w=150&h=150"
end

--- 查看与退出按钮位于屏幕右侧，避开底部物品栏，不往模型添加节点。
function Component:BindCameraView()
    self._viewUI = Create("ScreenGui", FXLoader:Here(self:GetPlayerNode(), "PlayerGui", math.huge), {
        Name = "LeaderboardViewControls", ResetOnSpawn = false, DisplayOrder = 30,
    })
    self._viewButton = Create("TextButton", self._viewUI, {
        Name = "View", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.fromScale(0.92, 0.65),
        Size = UDim2.new(0.28, 0, 0, 36), BackgroundColor3 = Gold, BorderSizePixel = 0,
        TextColor3 = Color3.fromRGB(64, 38, 15), Font = Enum.Font.FredokaOne, TextSize = 16,
        AutoLocalize = false, Visible = false, Text = Text.Tr(TranslationTexts.View),
    })
    Create("UISizeConstraint", self._viewButton, {MaxSize = Vector2.new(220, 36)})
    Create("UICorner", self._viewButton, {CornerRadius = UDim.new(0, 14)})
    Create("UIStroke", self._viewButton, {Color = Color3.fromRGB(255, 225, 139), Thickness = 2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border})
    self:TrackConnection(self._viewButton.Activated:Connect(function()
        self:EnterView()
    end))
    self._closeButton = Create("TextButton", self._viewUI, {
        Name = "Close", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.fromScale(0.92, 0.65),
        Size = UDim2.new(0.28, 0, 0, 36), BackgroundColor3 = Gold, BorderSizePixel = 0,
        TextColor3 = Color3.fromRGB(64, 38, 15), Font = Enum.Font.FredokaOne, TextSize = 16,
        AutoLocalize = false, Visible = false, Modal = true, Text = Text.Tr(TranslationTexts.Close),
    })
    Create("UISizeConstraint", self._closeButton, {MaxSize = Vector2.new(220, 36)})
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
        local root = character and FXLoader:Find(character, "HumanoidRootPart")
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

--- 以显示面正面为镜头轴；按屏幕比例计算距离，缩小留白并完整容纳榜单。
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
        local distance = halfHeight / math.tan(math.rad(camera.FieldOfView / 2)) * 1.08
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

--- 列表行高保证七名榜单有实际滚动范围，右侧留出滚动条空间；个人行由调用方固定尺寸。
--- @param parent Instance 列表或固定个人行的父节点。
--- @param rank number 列表行槽位；个人行传 0，不作为实际名次显示。
--- @param personal boolean 是否为金色个人行。
--- @return Frame 排行条目。
function Component:CreateRow(parent, rank, personal)
    local row = Create("Frame", parent, {
        Name = personal and "Personal" or "Rank" .. rank, LayoutOrder = rank, Size = UDim2.new(1, -12, 0, 104), BorderSizePixel = 0,
        BackgroundColor3 = personal and Gold or (rank % 2 == 0 and Color3.fromRGB(48, 33, 31) or Color3.fromRGB(59, 41, 37)),
    })
    local rankNumber = Label(row, "--", UDim2.fromScale(0, 0), UDim2.fromScale(0.14, 1))
    rankNumber.Name = "RankNumber"
    local avatar = Create("ImageLabel", row, {
        Name = "Avatar", Position = UDim2.new(0.15, 0, 0.5, -32), Size = UDim2.fromOffset(64, 64),
        BackgroundColor3 = Color3.fromRGB(25, 25, 25), BorderSizePixel = 0,
        Image = "",
    })
    Create("UICorner", avatar, {CornerRadius = UDim.new(1, 0)})
    local name = Label(row, "", UDim2.fromScale(0.25, 0), UDim2.fromScale(0.43, 1))
    name.Name = "PlayerName"
    name.AutoLocalize = false
    local score = Label(row, "--", UDim2.fromScale(0.70, 0), UDim2.fromScale(0.29, 1))
    score.Name = "Score"
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

--- 从缓存刷新各世界的真实成绩、翻译和分类字色；个人行使用深色版本保证可读性。
function Component:RefreshLocalization()
    self._rankHeader.Text = Text.Tr(TranslationTexts.Rank)
    self._playerHeader.Text = Text.Tr(TranslationTexts.Player)
    self._viewButton.Text = Text.Tr(TranslationTexts.View)
    local titles = {TranslationTexts.StrengthTitle, TranslationTexts.RebirthTitle, TranslationTexts.PlaytimeTitle}
    local headers = {TranslationTexts.Strength, TranslationTexts.Rebirths, TranslationTexts.Playtime}
    for index, board in ipairs(self._boards) do
        local panel = FXLoader:Here(board.Gui, "Panel")
        local personal = FXLoader:Here(panel, "Personal")
        local config = BoardTypes[board.Kind]
        for labelIndex, label in ipairs(panel:GetDescendants()) do
            if label:IsA("TextLabel") then
                label.TextColor3 = label:IsDescendantOf(personal)
                    and config.TextColor:Lerp(Color3.new(0, 0, 0), 0.75) or config.TextColor
            end
        end
        FXLoader:Here(panel, "Title").Text = Text.Tr(titles[board.Kind])
        FXLoader:Here(panel, "StrengthHeader").Text = Text.Tr(headers[board.Kind])
        for labelIndex, label in ipairs({self._rankHeader, self._playerHeader}) do
            FXLoader:Here(panel, label.Name).Text = label.Text
        end
        self:RefreshBoardData(board)
    end
    self._closeButton.Text = Text.Tr(TranslationTexts.Close)
end

--- 只销毁组件创建的界面，模型和显示面保持原样。
function Component:Dtor()
    self._destroyed = true
    if self._rankingTask then
        task.cancel(self._rankingTask)
    end
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
