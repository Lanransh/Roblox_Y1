local FX = _G.FX
local FXLoader = FX.Loader
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local RockLevel = require(ReplicatedStorage.Scripts.Game.Shared.RockLevel)
local Collectible = FXLoader:RequireShared("Scripts/Game/Shared/RockCollectible")
local GameUtility = FXLoader:RequireShared("Scripts/Game/Shared/GameUtility")
local GameEnum = FXLoader:RequireShared("Scripts/Game/Shared/GameEnum")
local Fields = _G.PlayerDataConfig
local Component = FX.Class("CRockLevelCompClass", "FCPlayerCompClass")
local ColliderHeight = 16
local RockNames = {"Rock_01", "Rock_02", "Rock_03", "Rock_04", "Rock_Small_01"}
local RockColors = {
    Color3.fromRGB(217, 220, 224), Color3.fromRGB(228, 225, 215),
    Color3.fromRGB(224, 228, 226), Color3.fromRGB(235, 233, 223),
    Color3.fromRGB(219, 224, 218),
}
local LuckUnits = {
    {1e36, "Ud"}, {1e33, "Dc"}, {1e30, "No"}, {1e27, "Oc"},
    {1e24, "Sp"}, {1e21, "Sx"}, {1e18, "Qi"}, {1e15, "Qa"},
    {1e12, "T"}, {1e9, "B"}, {1e6, "M"}, {1e3, "K"},
}

--- 幸运牌文案：不足千的整数直接显示，大数四舍五入到一位小数并去掉末尾的零。
--- @param rate number 关卡幸运倍率。
--- @return string 幸运倍率文本。
local function FormatLuck(rate)
    local absRate = math.abs(rate)
    if absRate < 1e3 then
        return tostring(math.floor(rate))
    end
    for index, entry in ipairs(LuckUnits) do
        local value, unit = entry[1], entry[2]
        if absRate >= value then
            local text = string.format("%.1f", rate / value):gsub("%.0$", "")
            return text .. unit
        end
    end
    return tostring(math.floor(rate))
end

--- 只拥有本客户端生成的石头；不会修改公共 SyntyRocks 模板。
--- @param owner FCPlayerObjectClass 客户端玩家对象。
function Component:Ctor(owner)
    Component.Super.Ctor(self, owner)
    self._chunks = {}
    self._pool = {}
    self._templates = {}
    self._health = {}
    self._fragments = {}
    self._fragmentPool = {}
    self._trainingFragmentPool = {}
    self._hitReactions = {}
    self._trainingHitReactions = {}
    self._nextChunkCheck = 0
    self._lastAttack = -math.huge
    self._nextAttackCheck = 0
    self._pendingHits = {}
    self._nextDropUpdate = 0
    self._drops = {}
    self._luckLabels = {}
end

--- 返回项目关卡组件协作名称。
--- @return string 组件名称。
function Component:GetCompName()
    return "CRockLevelComp"
end

--- 同步握手后加载关卡幸运牌、受击、秒杀气场及个人石头资源，订阅轮次和命中校验结果。
function Component:OnReady()
    self._localization = self:GetPlayerObject():RequireComponent("FCCommonUIComp").Localization
    self._itemHUD = FXLoader:Shared("Nodes/ItemHUD")
    local assets = FXLoader:Shared("Assets")
    self._powerAuraTemplate = FXLoader:Here(assets, "Effects/Goku (SSJ)/Torso")
    local effects = FXLoader:Here(assets, "Effects/ROCK")
    self._fragmentTemplate = FXLoader:Here(effects, "Fragment"):Clone()
    self._smokeTemplate = FXLoader:Here(effects, "Smoke")
    self._breakSound = FXLoader:Here(assets, "Sounds/RockBreak")
    -- 本地模型同步后补齐网格数据，保证碎石缩放使用原网格尺寸。
    if self._fragmentTemplate.MeshSize.Magnitude == 0 then
        local size = self._fragmentTemplate.Size
        local mesh = game:GetService("AssetService"):CreateMeshPartAsync(self._fragmentTemplate.MeshContent)
        self._fragmentTemplate:ApplyMesh(mesh)
        self._fragmentTemplate.Size = size
        mesh:Destroy()
    end
    local sources = FXLoader:Here(assets, "Models/SyntyRocks")
    for index, name in ipairs(RockNames) do
        local source = sources:WaitForChild(name)
        local part = source:Clone()
        -- JSON 同步可能丢失原始网格尺寸；恢复后保留已验看的尺寸和贴图。
        if part.MeshSize.Magnitude == 0 then
            local size = part.Size
            local mesh = game:GetService("AssetService"):CreateMeshPartAsync(part.MeshContent)
            part:ApplyMesh(mesh)
            part.Size = size
            part.TextureID = source.TextureID
            mesh:Destroy()
        end
        local template = Instance.new("Model")
        template.Name = name
        part.Name = "Root"
        part.CFrame = CFrame.new()
        part.CanCollide = false
        part.CanTouch = false
        part.CanQuery = false
        part.Parent = template
        local collider = Instance.new("Part")
        collider.Name = "Collider"
        collider.Shape = Enum.PartType.Block
        collider.Size = Vector3.new(part.Size.X, ColliderHeight, part.Size.Z)
        collider.CFrame = CFrame.new(0, (ColliderHeight - part.Size.Y) / 2, 0)
        -- 默认相机遮挡检测忽略全透明部件；可见网格已关闭碰撞与查询。
        collider.Transparency = 1
        collider.Anchored = true
        collider.CanCollide = false
        collider.CanTouch = false
        collider.CanQuery = false
        collider.CastShadow = false
        collider.Parent = template
        template.PrimaryPart = part
        template:SetAttribute("Variant", index)
        template:SetAttribute("FullHeight", part.Size.Y)
        self._templates[index] = template
        self._pool[index] = {}
    end
    self._areas = RockLevel.GetAreas()
    self._folder = Instance.new("Folder")
    self._folder.Name = "RockLevelVisuals"
    self._folder.Parent = workspace
    self:CreateLevelLuckSigns()
    for index = 1, #self._areas do
        local area = self._areas[index]
        for row = 0, area.Rows - 1, 6 do
            for column = 0, area.Columns - 1, 6 do
                table.insert(self._chunks, {
                    Area = area, Row = row, Column = column, Rocks = nil,
                    Center = Vector3.new(area.MinX + (column + 3) * RockLevel.CellSize,
                        area.FloorY, area.MinZ + (row + 3) * RockLevel.CellSize),
                })
            end
        end
    end
    FX.Network:RegServerMsgCallback("S2C_RockReset", self.ResetRound, self)
    FX.Network:RegServerMsgCallback("S2C_RockHitResult", self.OnHitResult, self)
    FX.Network:RegServerMsgCallback("S2C_SpawnRockDrop", self.SpawnDrop, self)
    FX.Network:RegServerMsgCallback("S2C_RemoveRockDrop", self.RemoveDrop, self)
    FX.Network:SendMsgToServer("C2S_RequestRockRound")
    self:TrackConnection(RunService.Heartbeat:Connect(function()
        self:UpdateDrops()
        self:UpdateVisuals()
    end))
end

--- 在所有世界的关卡中心上方创建幸运牌，随场景遮挡和距离隐藏，避免远处牌子叠在一起。
function Component:CreateLevelLuckSigns()
    local config = GameEnum.LevelLuckDisplay
    for worldIndex, worldName in ipairs(config.Worlds) do
        local world = FXLoader:Workspace("GameLevelList/" .. worldName)
        for index = 1, RockLevel.WorldLevelCount do
            local area = FXLoader:Here(world, "Level_" .. index)
            local billboard = Instance.new("BillboardGui")
            billboard.Name = worldName .. "_Level_" .. index .. "_Luck"
            billboard.Adornee = area
            billboard.StudsOffsetWorldSpace = Vector3.new(0, config.Height, 0)
            billboard.Size = UDim2.fromScale(30, 7)
            billboard.AlwaysOnTop = false
            billboard.LightInfluence = 0
            billboard.MaxDistance = 150
            local icon = Instance.new("ImageLabel")
            icon.Name = "LuckIcon"
            icon.BackgroundTransparency = 1
            icon.Size = UDim2.fromScale(0.23, 1)
            icon.Image = config.Icon
            icon.ScaleType = Enum.ScaleType.Fit
            icon.Parent = billboard
            local label = Instance.new("TextLabel")
            label.Name = "LuckText"
            label.BackgroundTransparency = 1
            label.Position = UDim2.fromScale(0.25, 0)
            label.Size = UDim2.fromScale(0.75, 1)
            label.Font = Enum.Font.GothamBlack
            label.TextScaled = true
            label.TextColor3 = Color3.new(1, 1, 1)
            label.AutoLocalize = false
            local stroke = Instance.new("UIStroke")
            stroke.Color = Color3.fromRGB(15, 20, 30)
            stroke.Thickness = 3
            stroke.Parent = label
            label.Parent = billboard
            billboard.Parent = self._folder
            table.insert(self._luckLabels, {Label = label, Rate = RockLevel.GetLuck(worldIndex, index)})
        end
    end
    self:RefreshLevelLuckSigns()
    self:TrackConnection(self._localization.Changed:Connect(function()
        self:RefreshLevelLuckSigns()
    end))
end

--- 云端翻译加载或语言变化后刷新幸运牌，幸运倍率使用一位小数格式。
function Component:RefreshLevelLuckSigns()
    for index, entry in ipairs(self._luckLabels) do
        entry.Label.Text = self._localization:FormatByKey("Level.Luck", {
            rate = FormatLuck(entry.Rate),
        })
    end
end

--- 只使用服务端签发给本人的掉落数据创建本地模型，其他玩家不会收到该实例。
--- @param data table S2C_SpawnRockDrop 携带的掉落数据。
function Component:SpawnDrop(data)
    if type(data) ~= "table" or type(data.DropId) ~= "string" or self._drops[data.DropId]
        or typeof(data.GroundPosition) ~= "Vector3" or type(data.ExpiresAt) ~= "number"
        or type(data.Quality) ~= "number" or type(data.Price) ~= "number" then
        return
    end
    if not self._folder or not self._itemHUD then
        return
    end
    local template = Collectible.ResolveModel(data.DisplayModelId)
    if not template then
        warn("Rock drop model is unavailable: " .. tostring(data.DisplayModelId))
        return
    end

    local model = Collectible.CreateModel(template)
    local box, size = model:GetBoundingBox()
    model:PivotTo(CFrame.new(data.GroundPosition + Vector3.new(0, size.Y / 2 + 0.2, 0) - box.Position))
    local root = model.PrimaryPart
    local landing = root.CFrame
    model:PivotTo(model:GetPivot() - Vector3.new(0, 0.5, 0))

    local hud = self._itemHUD:Clone()
    hud.Adornee = root
    Collectible.StyleHUD(hud, model, data.Quality)
    hud.Frame.LuckIcon.Visible = data.IsLucky == true
    hud.Frame.ItemName.AutoLocalize = false
    hud.Frame.Rarity.AutoLocalize = false
    hud.Frame.Price.AutoLocalize = false
    hud.Frame.Timer.AutoLocalize = false
    hud.Frame.Timer.Visible = true
    hud.Parent = root

    local prompt = Instance.new("ProximityPrompt")
    -- 原生拾取提示只显示操作文案，复用英文源表并交给 Roblox 自动本地化。
    prompt.ActionText = "Pick Up"
    prompt.ObjectText = ""
    prompt.AutoLocalize = true
    prompt.RootLocalizationTable = FXLoader:Shared("Shared/Localization")
    prompt.KeyboardKeyCode = Enum.KeyCode.E
    prompt.HoldDuration = 0.5
    prompt.MaxActivationDistance = Collectible.PickupDistance
    prompt.RequiresLineOfSight = false
    prompt.Enabled = false
    prompt.Parent = root

    local drop = {
        DropId = data.DropId,
        Model = model,
        Prompt = prompt,
        Hud = hud,
        NameKey = data.NameKey,
        Quality = data.Quality,
        Price = data.Price,
        IsLucky = data.IsLucky,
        LuckRate = data.LuckRate,
        ExpiresAt = data.ExpiresAt,
        Landing = landing,
    }
    self._drops[drop.DropId] = drop
    drop.Connection = prompt.Triggered:Connect(function(player)
        if player ~= Players.LocalPlayer then
            return
        end
        prompt.Enabled = false
        -- 网络层拒绝或超时会抛错；恢复提示，保留掉落直到服务端确认移除。
        local ok, accepted = pcall(function()
            return FX.Network:InvokeServer("C2S_PickupRockDrop", drop.DropId)
        end)
        if (not ok or not accepted) and self._drops[drop.DropId] == drop then
            prompt.Enabled = true
        end
    end)
    model.Parent = self._folder
    self:UpdateDropText(drop, workspace:GetServerTimeNow())

    --- 本地播放弹起与落地，完成后启用拾取并开始待拾取动画。
    drop.Task = task.spawn(function()
        local tween = TweenService:Create(root, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {CFrame = landing + Vector3.new(0, 4, 0)})
        drop.Tween = tween
        tween:Play()
        task.wait(0.25)
        if self._drops[drop.DropId] ~= drop then
            return
        end
        tween = TweenService:Create(root, TweenInfo.new(0.35, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
            {CFrame = landing})
        drop.Tween = tween
        tween:Play()
        task.wait(0.35)
        if self._drops[drop.DropId] ~= drop then
            return
        end
        drop.Task = nil
        drop.Tween = nil
        root.CFrame = landing
        drop.LandedAt = workspace:GetServerTimeNow()
        prompt.Enabled = true
        self:RegisterDropVisual(drop)
    end)
end

--- 刷新掉落 HUD 的名称、品质、价格和倒计时，云端翻译就绪后也会同步更新。
--- @param drop table 当前客户端持有的掉落。
--- @param now number 当前服务器同步时间。
function Component:UpdateDropText(drop, now)
    if drop.NameKey then
        drop.Hud.Frame.ItemName.Text = self._localization:FormatByKey(drop.NameKey)
    end
    local rarityArguments = {level = drop.Quality}
    if drop.IsLucky == true then
        rarityArguments.rate = GameUtility.NumberToText(drop.LuckRate or 1)
    end
    drop.Hud.Frame.Rarity.Text = self._localization:FormatByKey("Rarity.Quality", rarityArguments)
    drop.Hud.Frame.Price.Text = "$" .. GameUtility.NumberToText(drop.Price)
    drop.Hud.Frame.Timer.Text = string.format("%ds", math.max(0, math.ceil(drop.ExpiresAt - now)))
end

--- 落地后注册放射光环和漂浮动画所需的固定落点数据。
--- @param drop table 已完成落地的本地掉落。
function Component:RegisterDropVisual(drop)
    local model = drop.Model
    local root = model.PrimaryPart
    local box, size = model:GetBoundingBox()
    local centerOffset = model:GetPivot():ToObjectSpace(box)
    local anchor = Instance.new("Attachment")
    anchor.Name = "DropGlowAnchor"
    anchor.Position = root.CFrame:PointToObjectSpace(box.Position)
    anchor.Parent = root
    local glow = Instance.new("BillboardGui")
    glow.Name = "DropGlow"
    glow.Adornee = anchor
    local diameter = math.max(size.X, size.Y, size.Z) * 1.65
    glow.Size = UDim2.fromScale(diameter, diameter)
    glow.AlwaysOnTop = false
    glow.LightInfluence = 0
    glow.MaxDistance = 120
    local rays = Instance.new("Frame")
    rays.Name = "Rays"
    rays.AnchorPoint = Vector2.new(0.5, 0.5)
    rays.Position = UDim2.fromScale(0.5, 0.5)
    rays.Size = UDim2.fromScale(1, 1)
    rays.BackgroundTransparency = 1
    rays.Parent = glow
    for index = 1, 12 do
        local angle = (index - 1) * math.pi / 6
        local ray = Instance.new("Frame")
        ray.Name = "Ray" .. index
        ray.AnchorPoint = Vector2.new(0.5, 0.5)
        ray.Position = UDim2.fromScale(0.5 + math.cos(angle) * 0.34, 0.5 + math.sin(angle) * 0.34)
        ray.Size = UDim2.fromScale(0.32, 0.055)
        ray.Rotation = math.deg(angle)
        ray.BackgroundColor3 = Color3.fromRGB(255, 243, 196)
        ray.BorderSizePixel = 0
        local gradient = Instance.new("UIGradient")
        gradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.85),
            NumberSequenceKeypoint.new(0.25, 0.55),
            NumberSequenceKeypoint.new(0.6, 0.7),
            NumberSequenceKeypoint.new(1, 1),
        })
        gradient.Parent = ray
        ray.Parent = rays
    end
    glow.Parent = root
    drop.Anchor = anchor
    drop.Glow = glow
    drop.Rays = rays
    drop.Center = drop.Landing * centerOffset
    drop.PivotOffset = centerOffset:Inverse()
end

--- 按到期时间更新文案并驱动本地漂浮、自转和光环，过期后直接释放。
function Component:UpdateDrops()
    local now = workspace:GetServerTimeNow()
    local refreshText = now >= self._nextDropUpdate
    if refreshText then
        self._nextDropUpdate = now + 0.1
    end
    for dropId, drop in pairs(self._drops) do
        if now >= drop.ExpiresAt then
            self:RemoveDrop(dropId)
        else
            if refreshText then
                self:UpdateDropText(drop, now)
            end
            if drop.LandedAt then
                local elapsed = math.max(0, now - drop.LandedAt)
                -- 从落点起步，完整行程为 0.3 stud，最低点不会低于原落点。
                local height = 0.15 * (1 - math.cos(elapsed * math.pi * 2 / 2.6))
                local center = drop.Center
                drop.Model:PivotTo(CFrame.new(center.Position + Vector3.new(0, height, 0))
                    * CFrame.Angles(0, elapsed * math.rad(45), 0) * center.Rotation * drop.PivotOffset)
                drop.Rays.Rotation = elapsed * 15
            end
        end
    end
end

--- 释放本人客户端创建的掉落模型、提示连接、补间和光环。
--- @param dropId string 服务端签发的掉落 ID。
function Component:RemoveDrop(dropId)
    local drop = self._drops[dropId]
    if not drop then
        return
    end
    self._drops[dropId] = nil
    if drop.Connection then
        drop.Connection:Disconnect()
    end
    if drop.Task then
        task.cancel(drop.Task)
    end
    if drop.Tween then
        drop.Tween:Cancel()
    end
    if drop.Glow then
        drop.Glow:Destroy()
    end
    if drop.Anchor then
        drop.Anchor:Destroy()
    end
    drop.Model:Destroy()
end

--- 轮次切换或组件销毁时释放全部本地掉落。
function Component:ClearDrops()
    for dropId in pairs(self._drops) do
        self:RemoveDrop(dropId)
    end
end

--- 新轮时清除旧命中；同轮快照只补已击破格号，保留未击破石头的本地血量。
--- @param round number 服务器当前关卡轮次。
--- @param brokenCells table? 本玩家当前轮次已通过服务端校验的格号。
function Component:ResetRound(round, brokenCells)
    if self._round and round < self._round then
        return
    end
    if self._round == round then
        for _, key in ipairs(brokenCells or {}) do
            self._health[key] = 0
            self._pendingHits[key] = nil
        end
        self._refreshRocks = true
        return
    end
    self:StopSwing()
    self:ClearDrops()
    self._round = round
    self._health = {}
    self._pendingHits = {}
    self._lastAttack = -math.huge
    for _, key in ipairs(brokenCells or {}) do
        self._health[key] = 0
    end
    self:ResetVisuals()
end

--- 命中失败时回滚预测；认可后使用服务端血量决定击碎，避免等级复制延迟造成提前或延后开奖。
--- @param key string 本次命中的格号。
--- @param round number 本次命中所属轮次。
--- @param accepted boolean 是否通过服务端位置、装备及频率校验。
--- @param health number? 认可命中后的服务端剩余血量，拒绝时为空。
function Component:OnHitResult(key, round, accepted, health)
    local pending = self._pendingHits[key]
    if not pending or round ~= self._round or pending.Round ~= round then
        return
    end
    self._pendingHits[key] = nil
    if pending.Character ~= self:GetPlayerCharacter() then
        return
    end
    if not accepted then
        self._health[key] = pending.Health
        if pending.Value > 0 then
            self:ResetVisuals()
        end
    else
        self._health[key] = health
        if health == 0 then
            for index, chunk in ipairs(self._chunks) do
                local rock = chunk.Rocks and chunk.Rocks[key]
                if rock then
                    self:PlayHitEffect(rock, true)
                    break
                end
            end
            FX.Network:SendMsgToServer("C2S_RequestRockDrop", key, round)
        end
    end
    self._refreshRocks = true
end

--- 非致命命中即时预测，致命命中保留石头直到服务器认可，避免秒杀回滚时重复碎裂。
--- @param key string 已经过本地目标检查的格号。
--- @param area table 目标所属关卡。
function Component:ApplyHit(key, area)
    if not self._round or self._pendingHits[key] then
        return
    end
    local oldValue = self._health[key] or RockLevel.HP[area.Index]
    local damage = RockLevel.GetDamage(self:GetNumber(Fields.RockTrainingLevel), area.Index)
    if oldValue <= 0 or damage <= 0 then
        return
    end
    local value = math.max(0, oldValue - damage)
    self._pendingHits[key] = {Round = self._round, Health = oldValue, Value = value, Character = self:GetPlayerCharacter()}
    if value > 0 then
        self._health[key] = value
        for index, chunk in ipairs(self._chunks) do
            local rock = chunk.Rocks and chunk.Rocks[key]
            if rock then
                self:PlayHitEffect(rock, false)
                break
            end
        end
    end
    self._refreshRocks = true
    FX.Network:SendMsgToServer("C2S_RockHit", key, self._round)
end

--- 从服务器发放的镐子绑定本地轨道和拖尾，不创建或发放新的 Tool。
--- @param character Model 当前本地角色。
--- @param humanoid Humanoid 当前角色的 Humanoid。
--- @return boolean 镐子及动画资源是否已复制到达。
function Component:BindPickaxe(character, humanoid)
    local pickaxe
    for index, node in ipairs(character:GetChildren()) do
        if node:IsA("Tool") and node:GetAttribute("StarterPickaxe") then
            pickaxe = node
            break
        end
    end
    local handle = pickaxe and pickaxe:FindFirstChild("Handle")
    local trail = handle and handle:FindFirstChild("PickaxeSwingTrail")
    local animation = pickaxe and pickaxe:FindFirstChild("RockUpperBodySwing")
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not trail or (humanoid.RigType == Enum.HumanoidRigType.R15 and (not animation or not animator)) then
        return false
    end
    if self._pickaxe == pickaxe then
        return true
    end
    self:StopSwing()
    if self._swingTrack then
        self._swingTrack:Destroy()
        self._swingTrack = nil
    end
    self._pickaxe = pickaxe
    self._swingTrail = trail
    if humanoid.RigType == Enum.HumanoidRigType.R15 then
        self._swingTrack = animator:LoadAnimation(animation)
        self._swingTrack.Priority = Enum.AnimationPriority.Action
        self._swingTrack.Looped = false
    end
    return true
end

--- 中断时关闭并清空拖尾，淡出上半身轨道、恢复关节，取消延迟伤害。
function Component:StopSwing()
    if self._swingTrail then
        self._swingTrail.Enabled = false
        self._swingTrail:Clear()
    end
    if self._swingTask then
        task.cancel(self._swingTask)
        self._swingTask = nil
    end
    if self._swingTrack and self._swingTrack.IsPlaying then
        self._swingTrack:Stop(0.08)
    end
    for joint, pose in pairs(self._swingJoints or {}) do
        if pose.Tween then
            pose.Tween:Cancel()
        end
        if joint.Parent then
            joint[pose.Property or "C0"] = pose.Base
        end
    end
    self._swingJoints = nil
end

--- 在原始关节或腰部连接点上叠加旋转，兼容两类 R15 骨架并保留腿部姿态。
--- @param duration number 当前阶段持续秒数。
--- @param armAngle number 持镐手臂俯仰角度。
--- @param bodyAngle number 躯干俯仰角度。
--- @param direction Enum.EasingDirection 蓄力减速或下砸加速。
function Component:PoseSwing(duration, armAngle, bodyAngle, direction)
    for joint, pose in pairs(self._swingJoints) do
        local angle = pose.Body and bodyAngle or armAngle
        local base = pose.Base
        local target = CFrame.new(base.Position) * CFrame.Angles(math.rad(angle), 0, 0) * base.Rotation
        pose.Tween = TweenService:Create(joint, TweenInfo.new(duration, Enum.EasingStyle.Quad, direction), {
            [pose.Property or "C0"] = target,
        })
        pose.Tween:Play()
    end
end

--- 下砸时重验装备与近身目标；秒杀穿行允许命中已走到脚下的起手目标。
--- @param character Model 起手时的角色。
--- @param key string 起手时锁定的石头格子。
--- @param area table 目标所属关卡。
function Component:ResolvePickaxeHit(character, key, area)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    if self:GetPlayerCharacter() ~= character or not humanoid or humanoid.Health <= 0
        or not root or self._pickaxe.Parent ~= character
        or math.abs(root.Position.Y - area.FloorY) >= 12 then
        return
    end
    local cells = RockLevel.GetFrontCells(area, root.Position, root.CFrame.LookVector)
    local health = self._health[key] or RockLevel.HP[area.Index]
    local damage = RockLevel.GetDamage(self:GetNumber(Fields.RockTrainingLevel), area.Index)
    if damage >= RockLevel.HP[area.Index] then
        local column = math.floor((root.Position.X - area.MinX) / RockLevel.CellSize)
        local row = math.floor((root.Position.Z - area.MinZ) / RockLevel.CellSize)
        if column >= 0 and column < area.Columns and row >= 0 and row < area.Rows then
            table.insert(cells, 1, area.Index .. ":" .. (row * area.Columns + column + 1))
        end
    end
    if not table.find(cells, key) or health <= 0 or damage <= 0 then
        return
    end
    self:ApplyHit(key, area)
end

--- 下砸时普通关卡攻击扣血，训练巨石只播放受击表现；秒杀由穿行检查独立结算。
--- @param humanoid Humanoid 当前执行敲击的角色。
--- @param key string? 本次锁定的石头格子，训练巨石为 nil。
--- @param area table? 石头所属关卡，训练巨石为 nil。
--- @param instantBreak boolean 是否仅播放秒杀动作，避免与穿行击碎重复扣血。
function Component:SwingPickaxe(humanoid, key, area, instantBreak)
    self:StopSwing()
    local character = self._character
    if humanoid.RigType == Enum.HumanoidRigType.R15 then
        local upperTorso = character:FindFirstChild("UpperTorso")
        local waist = upperTorso and upperTorso:FindFirstChild("Waist")
        self._swingJoints = {}
        if waist and waist:IsA("Motor6D") then
            self._swingJoints[waist] = {Base = waist.C0, Body = true}
        elseif waist and waist:IsA("AnimationConstraint") and waist.Attachment0 then
            local attachment = waist.Attachment0
            self._swingJoints[attachment] = {Base = attachment.CFrame, Body = true, Property = "CFrame"}
        end
        local windup = instantBreak and 0.06 or 0.26
        local strike = instantBreak and 0.04 or 0.14
        local recovery = instantBreak and 0.56 or 0.26
        -- 原轨道 0.25 秒举镐、0.5 秒命中，按阶段调速，让伤害跟随实际下砸。
        self._swingTrack:Play(instantBreak and 0.03 or 0.08, 1, 0.25 / windup)
        self._swingTask = task.spawn(function()
            self:PoseSwing(windup, 0, 10, Enum.EasingDirection.Out)
            task.wait(windup)
            self._swingTrack:AdjustSpeed(0.25 / strike)
            self._swingTrail.Enabled = true
            self:PoseSwing(strike, 0, -38, Enum.EasingDirection.In)
            task.wait(strike)
            self._swingTrack:AdjustSpeed(1.25 * 0.26 / recovery)
            if key == nil then
                self:PlayTrainingHitEffect(character)
            elseif not instantBreak then
                self:ResolvePickaxeHit(character, key, area)
            end
            task.wait(0.06)
            self._swingTrail.Enabled = false
            self:PoseSwing(recovery, 0, 0, Enum.EasingDirection.Out)
            task.wait(recovery)
            self._swingTask = nil
            self:StopSwing()
        end)
        return
    end
    self._swingJoints = {}
    for nodeIndex, joint in ipairs(character:GetDescendants()) do
        if joint:IsA("Motor6D") and joint.Part1 then
            local name = joint.Part1.Name
            if name == "RightUpperArm" or name == "Right Arm" or name == "UpperTorso" then
                self._swingJoints[joint] = {Base = joint.C0, Body = name == "UpperTorso"}
            end
        end
    end
    local windup = instantBreak and 0.06 or 0.22
    local strike = instantBreak and 0.04 or 0.1
    local recovery = instantBreak and 0.5 or 0.28
    self._swingTask = task.spawn(function()
        self:PoseSwing(windup, 85, 12, Enum.EasingDirection.Out)
        task.wait(windup)
        self._swingTrail.Enabled = true
        self:PoseSwing(strike, -40, -18, Enum.EasingDirection.In)
        task.wait(strike)
        if key == nil then
            self:PlayTrainingHitEffect(character)
        elseif not instantBreak then
            self:ResolvePickaxeHit(character, key, area)
        end
        task.wait(0.08)
        self._swingTrail.Enabled = false
        self:PoseSwing(recovery, 0, 0, Enum.EasingDirection.Out)
        task.wait(recovery)
        self._swingTask = nil
        self:StopSwing()
    end)
end

--- 对已解锁场地巨石播放火花、碎屑、声音及短暂缩放，不改血量或关卡命中记录。
--- @param character Model 开始本次挥镐的角色，切换角色后不播放旧动作的特效。
function Component:PlayTrainingHitEffect(character)
    if character ~= self:GetPlayerCharacter() then
        return
    end
    local config = _G.GameConfig.TrainingFieldData[self:GetNumber(Fields.TrainingFieldIndex)]
    local root = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not config or not root or not humanoid or humanoid.Health <= 0 then
        return
    end
    local worldName, fieldName = GameUtility.ParseTrainingFieldNode(config.Node)
    local field = FXLoader:Find(workspace, "BlockMeshs/" .. worldName .. "/TrainingCenter/" .. fieldName)
    local core = field and field:FindFirstChild("巨岩暗色核心", true)
    if not core or not core:IsA("BasePart") then
        return
    end
    local direction = core.Position - root.Position
    if direction.Magnitude < 0.01 then
        return
    end
    local rockParts = {}
    for index, part in ipairs(core.Parent:GetDescendants()) do
        if part:IsA("BasePart") and string.find(part.Name, "岩") then
            table.insert(rockParts, part)
        end
    end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Include
    params.FilterDescendantsInstances = rockParts
    local impact = workspace:Raycast(root.Position, direction.Unit * (direction.Magnitude + core.Size.Magnitude), params)
    if impact then
        self:PlayHitEffect(core.Parent, false, impact)
        local reaction = self._trainingHitReactions[core.Parent]
        if not reaction then
            reaction = {Origin = core.CFrame, Parts = {}}
            for index, part in ipairs(rockParts) do
                table.insert(reaction.Parts, {
                    Part = part, Size = part.Size, Pose = part.CFrame,
                    LocalPose = core.CFrame:ToObjectSpace(part.CFrame),
                })
            end
            self._trainingHitReactions[core.Parent] = reaction
        end
        reaction.Started = os.clock()
    end
end

--- 仅让训练巨石部件放大后回缩；保存原始姿态，重触发不累积缩放，角色缺失时也继续恢复。
--- @param reset boolean? 组件释放时立即恢复全部原始尺寸和位置。
function Component:UpdateTrainingHitReactions(reset)
    local now = os.clock()
    for rock, reaction in pairs(self._trainingHitReactions) do
        local progress = reset and 1 or math.clamp((now - reaction.Started) / 0.35, 0, 1)
        local scale = 1 + math.sin(progress * math.pi * 2) * (1 - progress) * 0.18
        for index, entry in ipairs(reaction.Parts) do
            local part = entry.Part
            if part.Parent then
                if progress >= 1 then
                    part.Size = entry.Size
                    part.CFrame = entry.Pose
                else
                    part.Size = entry.Size * scale
                    part.CFrame = reaction.Origin * CFrame.new(entry.LocalPose.Position * scale)
                        * entry.LocalPose.Rotation
                end
            end
        end
        if progress >= 1 then
            self._trainingHitReactions[rock] = nil
        end
    end
end

--- 已解锁训练基地复用挥镐表现且不发送关卡命中；场外仍按关卡秒杀资格检查攻击。
function Component:UpdateAttacks()
    local character = self:GetPlayerCharacter()
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0 then
        self:StopSwing()
        self:SetPowerAura(nil)
        return
    end
    if self._character ~= character then
        self:StopSwing()
        self._character = character
        self._health = {}
        self._pendingHits = {}
        self._lastAttack = -math.huge
        self:ResetVisuals()
        FX.Network:SendMsgToServer("C2S_RequestRockRound")
    end
    local now = os.clock()
    if now < self._nextAttackCheck then
        return
    end
    self._nextAttackCheck = now + 0.1
    if not self._round or not self:BindPickaxe(character, humanoid) then
        self:StopSwing()
        self:SetPowerAura(nil)
        return
    end
    local position = root.Position
    local regularAttack = now - self._lastAttack >= 0.8
    if self:GetNumber(Fields.TrainingFieldIndex) > 0 then
        self:SetPowerAura(nil)
        if regularAttack then
            self._lastAttack = now
            self:SwingPickaxe(humanoid, nil, nil, true)
        end
        return
    end
    local targetFound = false
    local powerRoot
    local level = self:GetNumber(Fields.RockTrainingLevel)
    -- 气场不使用攻击范围的外扩边界，避免相邻低级关卡使高级关卡内仍显示秒杀特效。
    for index, area in ipairs(self._areas) do
        if math.abs(position.Y - area.FloorY) < 12
            and position.X >= area.MinX and position.X < area.MinX + area.Columns * RockLevel.CellSize
            and position.Z >= area.MinZ and position.Z < area.MinZ + area.Rows * RockLevel.CellSize then
            if RockLevel.GetDamage(level, index) >= RockLevel.HP[index] then
                powerRoot = root
            end
            break
        end
    end
    for index = 1, #self._areas do
        local area = self._areas[index]
        if math.abs(position.Y - area.FloorY) < 12
            and position.X >= area.MinX - 8 and position.X < area.MinX + area.Node.Size.X + 8
            and position.Z >= area.MinZ - 8 and position.Z < area.MinZ + area.Node.Size.Z + 8 then
            local damage = RockLevel.GetDamage(level, index)
            local cells = RockLevel.GetFrontCells(area, position, root.CFrame.LookVector)
            local instantBreak = damage >= RockLevel.HP[index]
            if instantBreak then
                -- 穿行时先检查脚下，避免玩家越过前方格子后石头仍留在身后。
                local column = math.floor((position.X - area.MinX) / RockLevel.CellSize)
                local row = math.floor((position.Z - area.MinZ) / RockLevel.CellSize)
                if column >= 0 and column < area.Columns and row >= 0 and row < area.Rows then
                    table.insert(cells, 1, index .. ":" .. (row * area.Columns + column + 1))
                end
            end
            for cellIndex = 1, #cells do
                local key = cells[cellIndex]
                local health = self._health[key] or RockLevel.HP[index]
                if health > 0 and not self._pendingHits[key] then
                    targetFound = true
                    if instantBreak then
                        self:ApplyHit(key, area)
                    else
                        powerRoot = nil
                    end
                    if damage > 0 and regularAttack then
                        self._lastAttack = now
                        self:SwingPickaxe(humanoid, key, area, instantBreak)
                    end
                    break
                end
            end
        end
        if targetFound then
            break
        end
    end
    self:SetPowerAura(powerRoot)
end

--- 整组克隆 Goku (SSJ) 气场以保留光柱连接，挂到角色躯干；退出时仅清理本组件的副本。
--- @param root BasePart? 满足当前关卡秒杀条件的角色根节点，nil 表示退出状态。
function Component:SetPowerAura(root)
    if self._powerAuraRoot == root then
        return
    end
    for index, effect in ipairs(self._powerAuraEffects or {}) do
        effect:Destroy()
    end
    self._powerAuraEffects = {}
    self._powerAuraRoot = nil
    if not root then
        return
    end
    local character = root.Parent
    local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    if not torso or not torso:IsA("BasePart") then
        return
    end
    -- 连接点必须与 Beam 一起克隆，逐个克隆会继续引用资源模板中的连接点。
    local group = self._powerAuraTemplate:Clone()
    for index, effect in ipairs(group:GetChildren()) do
        effect.Parent = torso
        table.insert(self._powerAuraEffects, effect)
    end
    group:Destroy()
    self._powerAuraRoot = root
end

--- 每次命中以配置颜色爆发粒子闪光、光环及火星；仅击破时散出较大烟尘。
--- @param rock Model 当前受击且仍在场景中的石头。
--- @param broken boolean 本次扣血是否击破石头。
--- @param impact RaycastResult? 训练巨石的实际表面命中；提供时只生成表现，不移动巨石。
function Component:PlayHitEffect(rock, broken, impact)
    local character = self:GetPlayerCharacter()
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then
        return
    end
    local center = rock:GetPivot().Position
    local direction = center - root.Position
    if direction.Magnitude < 0.01 then
        return
    end
    -- 表现点放在镜头可见侧的包围盒外，避免碰撞网格内凹或角色贴入石头时遮住火花。
    local camera = workspace.CurrentCamera
    local toViewer = (camera and camera.CFrame.Position or root.Position) - center
    if toViewer.Magnitude < 0.01 then
        toViewer = -direction
    end
    local normal = toViewer.Unit
    local rockPart = impact and impact.Instance or rock.Root
    local localDirection = rockPart.CFrame:VectorToObjectSpace(normal)
    local halfSize = rockPart.Size / 2
    local distance = 1 / math.max(math.abs(localDirection.X) / halfSize.X,
        math.abs(localDirection.Y) / halfSize.Y, math.abs(localDirection.Z) / halfSize.Z)
    local position = rockPart.Position + normal * distance
    if impact then
        position = impact.Position
        normal = impact.Normal
    end
    local effect = Instance.new("Part")
    effect.Name = "RockHitEffect"
    effect.Size = Vector3.new(0.1, 0.1, 0.1)
    effect.Transparency = 1
    effect.Anchored = true
    effect.CanCollide = false
    effect.CanTouch = false
    effect.CanQuery = false
    effect.CFrame = CFrame.lookAt(position + normal * 0.55, position + normal * 1.55)
    local sound = self._breakSound:Clone()
    self:GetPlayerObject():RequireComponent("CSettingsUIComp"):ConfigureEffectSound(sound)
    sound.Parent = effect
    effect.Parent = self._folder
    if broken then
        local dustOrigin = Instance.new("Attachment")
        dustOrigin.Position = effect.CFrame:PointToObjectSpace(center)
        dustOrigin.Parent = effect
        local dust = self._smokeTemplate:Clone()
        dust.Lifetime = NumberRange.new(0.3, 0.45)
        dust.Size = NumberSequence.new(3, 7)
        dust.Transparency = NumberSequence.new(0.25, 1)
        dust.Parent = dustOrigin
        dust:Emit(3)
    end
    local effectColor = RockLevel.HitEffectColors[math.random(1, #RockLevel.HitEffectColors)]
    local radius = math.clamp(math.max(rockPart.Size.X, rockPart.Size.Y, rockPart.Size.Z) * 0.55, 1.5, 4)
    self:PlayImpactParticles(effect, radius, broken, effectColor)
    sound:Play()
    local away = Vector3.new(direction.X, 0, direction.Z)
    if away.Magnitude < 0.01 then
        away = Vector3.new(0, 0, 1)
    end
    away = away.Unit
    if not broken and not impact then
        self._hitReactions[rock] = {Started = os.clock(), Direction = away}
    end
    local fragmentOrigin = broken and CFrame.lookAt(center, center + normal) or effect.CFrame
    self:SpawnFragments(fragmentOrigin, impact and rockPart.Color or rock:GetAttribute("GroundColor"), rockPart.Size,
        broken, impact ~= nil)
    Debris:AddItem(effect, math.max(3, sound.TimeLength + 0.1))
end

--- 使用紧凑的中心闪光、柔边冲击波和飞散火星，限制亮度与叠加以免遮住角色和石头。
--- @param effect BasePart 位于接触点且朝向表面外侧的特效容器。
--- @param radius number 按受击石头尺寸确定的光环半径。
--- @param broken boolean 击破时增加火星数量和爆闪尺寸。
--- @param color Color3 配置中的光效颜色，当前统一为金色。
function Component:PlayImpactParticles(effect, radius, broken, color)
    local origin = Instance.new("Attachment")
    origin.Name = "ImpactOrigin"
    origin.Parent = effect
    local flash = Instance.new("ParticleEmitter")
    flash.Name = "ImpactFlash"
    flash.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    flash.Enabled = false
    flash.Rate = 0
    flash.Color = ColorSequence.new(color)
    flash.LightEmission = 0.65
    flash.LightInfluence = 0
    flash.Brightness = 1
    flash.Orientation = Enum.ParticleOrientation.FacingCamera
    flash.EmissionDirection = Enum.NormalId.Front
    flash.Speed = NumberRange.new(0)
    flash.Rotation = NumberRange.new(0, 360)
    flash.Lifetime = NumberRange.new(0.14)
    local burstSize = math.min(radius * (broken and 1.1 or 0.85), 3.2)
    flash.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, burstSize * 0.45),
        NumberSequenceKeypoint.new(0.15, burstSize),
        NumberSequenceKeypoint.new(1, burstSize * 0.65),
    })
    flash.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.3),
        NumberSequenceKeypoint.new(0.3, 0.45),
        NumberSequenceKeypoint.new(1, 1),
    })
    flash.Parent = origin

    local ring = flash:Clone()
    ring.Name = "ImpactShockwave"
    ring.Texture = "rbxasset://textures/particles/explosion01_shockwave_main.dds"
    ring.Lifetime = NumberRange.new(0.32)
    ring.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, radius * 0.5),
        NumberSequenceKeypoint.new(0.35, radius * 2),
        NumberSequenceKeypoint.new(1, radius * 3),
    })
    ring.Parent = origin

    local sparks = flash:Clone()
    sparks.Name = "ImpactSparks"
    sparks.Lifetime = NumberRange.new(0.25, 0.45)
    sparks.Speed = NumberRange.new(radius * 3, radius * 6)
    sparks.SpreadAngle = Vector2.new(85, 85)
    sparks.Drag = 3
    sparks.Acceleration = Vector3.new(0, -12, 0)
    sparks.RotSpeed = NumberRange.new(-180, 180)
    sparks.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.65, 0.2),
        NumberSequenceKeypoint.new(0.4, 0.4, 0.1),
        NumberSequenceKeypoint.new(1, 0),
    })
    sparks.Parent = origin
    flash:Emit(1)
    ring:Emit(1)
    sparks:Emit(broken and 28 or 18)
end

--- 训练命中喷出同色发光方块，关卡保留原碎石；分别复用对象，避免两种外观串用。
--- @param origin CFrame 普通命中的表面位置或击破的石头中心，朝向表面外侧。
--- @param color Color3 训练使用受击部件原色，关卡以地板颜色轻微染色。
--- @param rockSize Vector3 当前石头尺寸，用于限定击破碎块的生成范围。
--- @param broken boolean 是否击破，控制碎屑数量、尺寸及生成范围。
--- @param training boolean? 是否为训练巨石命中，控制方块外观和飞散轨迹。
function Component:SpawnFragments(origin, color, rockSize, broken, training)
    local source = self._fragmentTemplate
    local tint = Color3.new(1, 1, 1):Lerp(color, 0.2)
    local fragmentColor = Color3.new(source.Color.R * tint.R, source.Color.G * tint.G, source.Color.B * tint.B)
    local pool = training and self._trainingFragmentPool or self._fragmentPool
    local count = training and 9 or (broken and 4 or 3)
    local phase = math.random() * math.pi * 2
    for index = 1, count do
        local fragment = table.remove(pool)
        if not fragment then
            fragment = training and Instance.new("Part") or source:Clone()
        end
        fragment.Name = "RockFragment"
        fragment.Anchored = true
        fragment.CanCollide = false
        fragment.CanTouch = false
        fragment.CanQuery = false
        fragment.CastShadow = false
        fragment.Color = training and color or fragmentColor
        fragment.Transparency = training and 0 or source.Transparency
        local size = (0.5 + math.random() * 0.4) * (broken and 1.8 or 0.65)
        fragment.Size = source.Size * (size / math.max(source.Size.X, source.Size.Y, source.Size.Z))
        if training then
            size = 0.3 + math.random() * 0.45
            fragment.Size = Vector3.new(size, size, size)
            fragment.Material = Enum.Material.Neon
        end
        local rotation = CFrame.Angles(math.random() * math.pi, math.random() * math.pi, math.random() * math.pi)
        local offset = broken and Vector3.new((math.random() - 0.5) * rockSize.X * 0.7,
            (math.random() - 0.5) * rockSize.Y * 0.5, (math.random() - 0.5) * rockSize.Z * 0.7) or Vector3.zero
        fragment.CFrame = CFrame.new(origin.Position + offset) * rotation
        fragment.Parent = self._folder
        local angle = phase + (index - 1 + math.random() * 0.4) / count * math.pi * 2
        local spread = (training or broken) and (7 + math.random() * 5) or 2
        table.insert(self._fragments, {
            Part = fragment, Size = fragment.Size, Position = origin.Position + offset, Rotation = rotation,
            Started = os.clock(), Lifetime = training and (0.8 + math.random() * 0.2) or (0.45 + math.random() * 0.1),
            Pool = pool,
            Velocity = Vector3.new(math.cos(angle) * spread, (training or broken) and (8 + math.random() * 3) or 5,
                math.sin(angle) * spread) + (broken and Vector3.zero or origin.LookVector * 6),
            Spin = Vector3.new(math.random() * 10 - 5, math.random() * 10 - 5, math.random() * 10 - 5),
        })
    end
end

--- 碎石在最后三成寿命缩小淡出，到期移出场景归池；角色缺失时也继续回收。
function Component:UpdateFragments()
    local now = os.clock()
    for index = #self._fragments, 1, -1 do
        local fragment = self._fragments[index]
        local elapsed = now - fragment.Started
        if elapsed >= fragment.Lifetime then
            fragment.Part.Parent = nil
            table.insert(fragment.Pool, fragment.Part)
            table.remove(self._fragments, index)
        else
            local fade = math.clamp((elapsed / fragment.Lifetime - 0.7) / 0.3, 0, 1)
            local position = fragment.Position + fragment.Velocity * elapsed + Vector3.new(0, -14 * elapsed * elapsed, 0)
            local spin = fragment.Spin * elapsed
            fragment.Part.CFrame = CFrame.new(position) * fragment.Rotation * CFrame.Angles(spin.X, spin.Y, spin.Z)
            fragment.Part.Size = fragment.Size * math.max(0.05, 1 - fade)
            fragment.Part.Transparency = fade
        end
    end
end

--- 按格子固定随机模型、朝向和灰色，分模型复用，避免重新载入时外观跳变。
--- @param area table 所属关卡。
--- @param column number 从零开始的列号。
--- @param row number 从零开始的行号。
--- @return Model 本客户端拥有的石头。
function Component:CreateRock(area, column, row)
    local x = area.MinX + (column + 0.5) * RockLevel.CellSize
    local z = area.MinZ + (row + 0.5) * RockLevel.CellSize
    local seed = math.abs(math.floor(x * 73856093 + z * 19349663)) % 2147483647
    local random = Random.new(seed)
    local variant = random:NextInteger(1, #RockNames)
    local rotation = CFrame.Angles(0, random:NextInteger(0, 3) * math.pi / 2, 0)
    local rock = table.remove(self._pool[variant])
    if not rock then
        rock = self._templates[variant]:Clone()
    end
    rock.Name = "Rock_" .. area.Index .. "_" .. (row * area.Columns + column + 1)
    rock:ScaleTo(1)
    rock:SetAttribute("BaseColor", RockColors[Random.new(seed + 17):NextInteger(1, #RockColors)])
    rock:SetAttribute("HealthRatio", nil)
    rock:SetAttribute("GroundColor", nil)
    rock:PivotTo(CFrame.new(x, area.FloorY + rock:GetAttribute("FullHeight") / 2, z) * rotation)
    rock:SetAttribute("RestPivot", rock:GetPivot())
    self:SetRockState(rock, true)
    rock.Parent = self._folder
    return rock
end

--- 受损后按需创建世界尺寸血条，随镜头拉远缩小；复用石头时按当前血量恢复显隐。
--- @param rock Model 本组件拥有的客户端石头。
--- @param healthRatio number 当前血量占最大血量的比例。
function Component:UpdateRockHealthBar(rock, healthRatio)
    local billboard = rock:FindFirstChild("RockHealthBar")
    if healthRatio >= 1 then
        if billboard then
            billboard.Enabled = false
        end
        return
    end
    if not billboard then
        billboard = Instance.new("BillboardGui")
        billboard.Name = "RockHealthBar"
        billboard.Adornee = rock.Root
        billboard.Size = UDim2.fromScale(5, 0.6)
        billboard.AlwaysOnTop = true
        billboard.LightInfluence = 0
        billboard.MaxDistance = 80
        local background = Instance.new("Frame")
        background.Name = "Background"
        background.Size = UDim2.fromScale(1, 1)
        background.BackgroundColor3 = Color3.fromRGB(25, 29, 35)
        background.BorderSizePixel = 0
        background.Parent = billboard
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = background
        local fill = Instance.new("Frame")
        fill.Name = "Fill"
        fill.BackgroundColor3 = Color3.fromRGB(80, 220, 105)
        fill.BorderSizePixel = 0
        fill.Parent = background
        local fillCorner = corner:Clone()
        fillCorner.Parent = fill
        billboard.Parent = rock
    end
    billboard.Enabled = healthRatio > 0
    billboard.StudsOffsetWorldSpace = Vector3.new(0, rock.Root.Size.Y / 2 + 1.2, 0)
    billboard.Background.Fill.Size = UDim2.fromScale(math.clamp(healthRatio, 0, 1), 1)
end

--- 受损与受击更新外观和血条；碰撞盒保持竖直及固定高度，避免缩小或倾斜后可跳上石头。
--- @param rock Model 当前客户端石头。
--- @param area table 所属关卡及常驻颜色标记。
--- @param health number 大于零的当前血量。
function Component:UpdateRockAppearance(rock, area, health)
    local healthRatio = health / RockLevel.HP[area.Index]
    local ratio = healthRatio > 0.66 and 1 or (healthRatio > 0.33 and 0.92 or 0.84)
    local reaction = self._hitReactions[rock]
    if rock:GetAttribute("HealthRatio") ~= ratio or reaction then
        local pivot = rock:GetAttribute("RestPivot")
        rock:ScaleTo(ratio)
        local pose = CFrame.new(pivot.Position.X,
            area.FloorY + rock:GetAttribute("FullHeight") * ratio / 2, pivot.Position.Z) * pivot.Rotation
        if reaction then
            reaction.Area = area
            reaction.Health = health
            local progress = math.clamp((os.clock() - reaction.Started) / 0.16, 0, 1)
            local kick = math.sin(progress * math.pi * 2) * (1 - progress)
            local direction = reaction.Direction
            pose = CFrame.new(direction * (0.18 * kick)) * pose
                * CFrame.fromAxisAngle(pivot:VectorToObjectSpace(Vector3.yAxis:Cross(direction)), math.rad(4) * kick)
            if progress >= 1 then
                self._hitReactions[rock] = nil
            end
        end
        rock:PivotTo(pose)
        local collider = rock.Collider
        collider.Size = Vector3.new(rock.Root.Size.X, ColliderHeight, rock.Root.Size.Z)
        collider.CFrame = CFrame.new(pivot.Position.X, area.FloorY + ColliderHeight / 2, pivot.Position.Z)
            * pivot.Rotation
        rock:SetAttribute("HealthRatio", ratio)
    end
    self:UpdateRockHealthBar(rock, healthRatio)
    local color = area.Node.Color
    if rock:GetAttribute("GroundColor") ~= color then
        local baseColor = rock:GetAttribute("BaseColor")
        local tint = Color3.new(1, 1, 1):Lerp(color, 0.2)
        rock.Root.SurfaceAppearance.Color = Color3.new(baseColor.R * tint.R, baseColor.G * tint.G, baseColor.B * tint.B)
        rock:SetAttribute("GroundColor", color)
    end
end

--- 隐藏时解除碰撞并移出场景，按模型种类回收，避免复用时改变选定的轮廓。
--- @param rock Model 本组件创建的石头。
function Component:RecycleRock(rock)
    self._hitReactions[rock] = nil
    self:SetRockState(rock, false)
    rock.Parent = nil
    table.insert(self._pool[rock:GetAttribute("Variant")], rock)
end

--- 仅切换独立方块的碰撞；满血可一击击破的关卡允许穿行，由客户端即时破坏近身石头。
--- @param rock Model 本组件创建的石头。
--- @param canCollide boolean 是否阻挡玩家。
function Component:SetRockState(rock, canCollide)
    if rock.Collider.CanCollide ~= canCollide then
        rock.Collider.CanCollide = canCollide
    end
end

--- 石头关卡内禁止爬梯式攀爬，离开后恢复角色原设置；重生后重新记录新角色状态。
--- @param character Model 当前本地角色。
--- @param position Vector3 角色根节点位置，用于判断是否位于石头关卡。
function Component:UpdateClimbing(character, position)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        return
    end
    local climbing = Enum.HumanoidStateType.Climbing
    if self._climbHumanoid ~= humanoid then
        if self._climbHumanoid and self._climbHumanoid.Parent then
            self._climbHumanoid:SetStateEnabled(climbing, self._originalClimbingEnabled)
        end
        self._climbHumanoid = humanoid
        self._originalClimbingEnabled = humanoid:GetStateEnabled(climbing)
    end
    local inRockArea = false
    for index, area in ipairs(self._areas) do
        if position.X >= area.MinX and position.X < area.MinX + area.Columns * RockLevel.CellSize
            and position.Z >= area.MinZ and position.Z < area.MinZ + area.Rows * RockLevel.CellSize
            and math.abs(position.Y - area.FloorY) < 12 then
            inRockArea = true
            break
        end
    end
    local enabled = self._originalClimbingEnabled and not inRockArea
    if humanoid:GetStateEnabled(climbing) ~= enabled then
        humanoid:SetStateEnabled(climbing, enabled)
    end
    if inRockArea and humanoid:GetState() == climbing then
        humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
    end
end

--- 公共小狗仅在本客户端按距离隐藏，保留服务端模型与其他玩家的拾取资格。
--- @param position Vector3? 当前角色位置；为空时在组件销毁前恢复显示。
function Component:UpdateDogVisibility(position)
    local decorations = workspace:FindFirstChild("Decorations")
    local dogs = decorations and decorations:FindFirstChild("DogNpcs")
    if not dogs then
        return
    end
    for dogIndex, dog in ipairs(dogs:GetChildren()) do
        if dog:IsA("Model") then
            local visible = not position or (dog:GetPivot().Position - position).Magnitude <= RockLevel.HideDistance
            for nodeIndex, node in ipairs(dog:GetDescendants()) do
                if node:IsA("BasePart") then
                    node.LocalTransparencyModifier = visible and 0 or 1
                elseif node:IsA("Highlight") then
                    node.Enabled = visible
                elseif node:IsA("ParticleEmitter") then
                    if node.Enabled ~= visible then
                        node.Enabled = visible
                        if not visible then
                            node:Clear()
                        end
                    end
                end
            end
        end
    end
end

--- 每帧更新碎屑及训练缩放，每 0.1 秒检查分块、攀爬和小狗显隐，每帧最多生成 6 块石头。
function Component:UpdateVisuals()
    self:UpdateFragments()
    self:UpdateTrainingHitReactions()
    self:UpdateAttacks()
    local character = self:GetPlayerCharacter()
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then
        return
    end
    local position = root.Position
    local now = os.clock()
    if now >= self._nextChunkCheck then
        self._nextChunkCheck = now + 0.1
        self:UpdateClimbing(character, position)
        self:UpdateDogVisibility(position)
        self._refreshRocks = true
        local candidate, nearest = nil, math.huge
        for index = 1, #self._chunks do
            local chunk = self._chunks[index]
            local dx, dz = position.X - chunk.Center.X, position.Z - chunk.Center.Z
            local distanceSquared = dx * dx + dz * dz
            if chunk.Rocks and distanceSquared > RockLevel.HideDistance * RockLevel.HideDistance then
                for key, rock in pairs(chunk.Rocks) do
                    self:RecycleRock(rock)
                end
                chunk.Rocks = nil
                if self._loadingChunk == chunk then
                    self._loadingChunk = nil
                end
            elseif not chunk.Rocks and distanceSquared <= RockLevel.LoadDistance * RockLevel.LoadDistance
                and distanceSquared < nearest then
                candidate, nearest = chunk, distanceSquared
            end
        end
        if candidate and not self._loadingChunk then
            candidate.Rocks = {}
            candidate.NextCell = 0
            self._loadingChunk = candidate
        end
    end
    local level = self:GetNumber(Fields.RockTrainingLevel)
    local loading = self._loadingChunk
    if loading then
        local columns = math.min(6, loading.Area.Columns - loading.Column)
        local count = columns * math.min(6, loading.Area.Rows - loading.Row)
        local canCollide = RockLevel.GetDamage(level, loading.Area.Index) < RockLevel.HP[loading.Area.Index]
        for cell = loading.NextCell, math.min(loading.NextCell + 5, count - 1) do
            local row = loading.Row + math.floor(cell / columns)
            local column = loading.Column + cell % columns
            local key = loading.Area.Index .. ":" .. (row * loading.Area.Columns + column + 1)
            local health = self._health[key] or RockLevel.HP[loading.Area.Index]
            if health > 0 then
                local rock = self:CreateRock(loading.Area, column, row)
                loading.Rocks[key] = rock
                self:UpdateRockAppearance(rock, loading.Area, health)
                self:SetRockState(rock, canCollide)
            end
            loading.NextCell = cell + 1
        end
        if loading.NextCell >= count then
            self._loadingChunk = nil
        end
    end
    if self._refreshRocks or self._visualLevel ~= level then
        self._refreshRocks = false
        self._visualLevel = level
        self:RefreshVisibleRocks(level)
    end
    for rock, reaction in pairs(self._hitReactions) do
        self:UpdateRockAppearance(rock, reaction.Area, reaction.Health)
    end
end

--- 在状态变化或低频检查时同步已显示石头，避免静止石头每帧重复计算与写属性。
--- @param level number 当前训练等级，按关卡满血判断是否允许直接穿行。
function Component:RefreshVisibleRocks(level)
    for index = 1, #self._chunks do
        local chunk = self._chunks[index]
        if chunk.Rocks then
            local canCollide = RockLevel.GetDamage(level, chunk.Area.Index) < RockLevel.HP[chunk.Area.Index]
            for key, rock in pairs(chunk.Rocks) do
                local health = self._health[key] or RockLevel.HP[chunk.Area.Index]
                if health <= 0 then
                    self:RecycleRock(rock)
                    chunk.Rocks[key] = nil
                else
                    self:UpdateRockAppearance(rock, chunk.Area, health)
                    self:SetRockState(rock, canCollide)
                end
            end
        end
    end
end

--- 回到安全区后清空已显示的块索引，下一帧按新血量重建。
function Component:ResetVisuals()
    self._loadingChunk = nil
    self._nextChunkCheck = 0
    for index = 1, #self._chunks do
        local chunk = self._chunks[index]
        if chunk.Rocks then
            for key, rock in pairs(chunk.Rocks) do
                self:RecycleRock(rock)
            end
            chunk.Rocks = nil
        end
    end
end

--- 释放特效、场景及对象池，恢复训练巨石、攀爬和小狗显示，基类负责断开监听。
function Component:Dtor()
    self:UpdateTrainingHitReactions(true)
    self:UpdateDogVisibility(nil)
    self:ClearDrops()
    FX.Network:UnRegServerMsgCallback("S2C_RockReset")
    FX.Network:UnRegServerMsgCallback("S2C_RockHitResult")
    FX.Network:UnRegServerMsgCallback("S2C_SpawnRockDrop")
    FX.Network:UnRegServerMsgCallback("S2C_RemoveRockDrop")
    self:StopSwing()
    self:SetPowerAura(nil)
    if self._swingTrack then
        self._swingTrack:Destroy()
        self._swingTrack = nil
    end
    if self._climbHumanoid and self._climbHumanoid.Parent then
        self._climbHumanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, self._originalClimbingEnabled)
    end
    if self._fragmentTemplate then
        self._fragmentTemplate:Destroy()
    end
    for index, template in ipairs(self._templates) do
        template:Destroy()
    end
    for index, fragment in ipairs(self._fragmentPool) do
        fragment:Destroy()
    end
    self._fragmentPool = {}
    for index, fragment in ipairs(self._trainingFragmentPool) do
        fragment:Destroy()
    end
    self._trainingFragmentPool = {}
    if self._folder then
        self._folder:Destroy()
    end
    self._fragments = {}
    self._hitReactions = {}
    for index, pool in ipairs(self._pool) do
        for rockIndex, rock in ipairs(pool) do
            rock:Destroy()
        end
    end
    Component.Super.Dtor(self)
end

return Component
