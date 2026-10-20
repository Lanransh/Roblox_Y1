-- 公共菜鸟 NPC：定时换批、区域巡逻与行走动作，所有玩家可竞争拾取。
local FX = _G.FX
local FXLoader = FX.Loader

local Config = FXLoader:RequireShared("Scripts/Game/Shared/GameEnum").NoobNpcConfig
local Service = FX.Class("SNoobNpcServiceClass")

--- 读取模板与区域并启动本服务拥有的刷新任务。
function Service:Ctor()
    self._template = FXLoader:Shared(Config.TemplatePath)
    self._localization = FXLoader:Shared("Shared/Localization")
    self._worlds = {}
    self._container = Instance.new("Folder")
    self._container.Name = "NoobNpcs"
    self._container.Parent = FXLoader:Workspace("Decorations")
    for worldIndex, paths in ipairs(Config.WorldAreaPaths) do
        assert(Config.SpawnCount <= #paths, "Noob SpawnCount exceeds area count")
        local world = {Areas = {}, Noobs = {}, NextRefresh = 0}
        for areaIndex, path in ipairs(paths) do
            world.Areas[areaIndex] = FXLoader:Workspace(path)
        end
        self._worlds[worldIndex] = world
    end
    self:OnUpdate(workspace:GetServerTimeNow())
    self._timer = task.spawn(function()
        while true do
            task.wait(Config.UpdateInterval)
            self:OnUpdate(workspace:GetServerTimeNow())
        end
    end)
end

--- 清理到期批次并推进巡逻，拾取不影响下次刷新时刻。
--- @param serverTime number 当前服务器时间。
function Service:OnUpdate(serverTime)
    for worldIndex, world in ipairs(self._worlds) do
        if serverTime >= world.NextRefresh then
            self:RefreshWorld(world, serverTime)
        end
        for noobIndex, noob in ipairs(world.Noobs) do
            if not noob.Picked then
                self:UpdatePatrol(noob, serverTime)
            end
        end
    end
end

--- 在区域中心范围内选点，并以模型脚底偏移保持巡逻时贴地。
--- @param area BasePart 当前关卡区域。
--- @param heightOffset number 模型枢轴相对区域底面的高度。
--- @return Vector3 巡逻点世界坐标。
function Service:GetPatrolPoint(area, heightOffset)
    return area.CFrame:PointToWorldSpace(Vector3.new(
        (math.random() - 0.5) * area.Size.X * Config.AreaScale,
        -area.Size.Y / 2,
        (math.random() - 0.5) * area.Size.Z * Config.AreaScale
    )) + Vector3.new(0, heightOffset, 0)
end

--- 沿四个固定随机点循环行走，由服务端移动并驱动原模型的四肢关节。
--- @param noob table 服务端保存的菜鸟状态。
--- @param serverTime number 当前服务器时间。
function Service:UpdatePatrol(noob, serverTime)
    local deltaTime = serverTime - noob.LastUpdate
    noob.LastUpdate = serverTime
    local position = noob.Model:GetPivot().Position
    local target = noob.Points[noob.TargetIndex]
    if (target - position).Magnitude <= Config.ArriveDistance then
        noob.TargetIndex = noob.TargetIndex % #noob.Points + 1
        target = noob.Points[noob.TargetIndex]
    end
    local offset = target - position
    local moving = offset.Magnitude > 0.01
    if moving then
        local nextPosition = position + offset.Unit * math.min(offset.Magnitude, Config.WalkSpeed * deltaTime)
        noob.Model:PivotTo(CFrame.lookAt(nextPosition, nextPosition + offset.Unit))
    end
    local swing = (moving and 0.7 or 0.1) * math.sin(serverTime * (moving and 9 or 1))
    noob.Root["Right Shoulder"].DesiredAngle = swing
    noob.Root["Left Shoulder"].DesiredAngle = swing
    noob.Root["Right Hip"].DesiredAngle = -swing
    noob.Root["Left Hip"].DesiredAngle = -swing
end

--- 每批从不同区域各选一组巡逻点；模型双脚对齐关卡地面。
--- @param world table 当前世界的刷新状态。
--- @param serverTime number 本批开始时间。
function Service:RefreshWorld(world, serverTime)
    for noobIndex, noob in ipairs(world.Noobs) do
        noob.Connection:Disconnect()
        noob.Model:Destroy()
    end
    world.Noobs = {}
    world.NextRefresh = serverTime + Config.RefreshInterval
    local available = table.clone(world.Areas)
    for noobIndex = 1, Config.SpawnCount do
        local area = table.remove(available, math.random(#available))
        local model = self._template:Clone()
        model.Name = "Noob"
        model:PivotTo(CFrame.new())
        model:ScaleTo(model:GetScale() * Config.ModelHeight / model:GetExtentsSize().Y)
        local root = model.PrimaryPart
        assert(root and root.Name == "Torso", "Noob template requires Torso as PrimaryPart")
        for nodeIndex, node in ipairs(model:GetDescendants()) do
            if node:IsA("BasePart") then
                node.Anchored = node == root
                node.CanCollide = false
                node.CanTouch = false
                node.CanQuery = false
            end
        end
        local box, size = model:GetBoundingBox()
        local bottom = box.Position.Y - size.Y / 2
        local points = {}
        for pointIndex = 1, Config.PatrolPointCount do
            points[pointIndex] = self:GetPatrolPoint(area, Config.HoverHeight - bottom)
        end
        model:PivotTo(CFrame.new(points[1]))
        local highlight = Instance.new("Highlight")
        highlight.Name = "GoldenOutline"
        highlight.Adornee = model
        highlight.FillTransparency = Config.FillTransparency
        highlight.OutlineColor = Config.OutlineColor
        highlight.OutlineTransparency = Config.OutlineTransparency
        highlight.DepthMode = Enum.HighlightDepthMode.Occluded
        highlight.Parent = model
        local particles = Instance.new("ParticleEmitter")
        particles.Name = "GoldenSparkles"
        particles.Texture = Config.ParticleTexture
        particles.Color = ColorSequence.new(Config.ParticleColor)
        particles.Rate = Config.ParticleRate
        particles.Lifetime = NumberRange.new(1, 2)
        particles.Speed = NumberRange.new(0.5, 1.5)
        particles.SpreadAngle = Vector2.new(180, 180)
        particles.LightEmission = 1
        particles.Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.15),
            NumberSequenceKeypoint.new(0.5, 0.35),
            NumberSequenceKeypoint.new(1, 0),
        })
        particles.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.2, 0),
            NumberSequenceKeypoint.new(1, 1),
        })
        particles.Parent = root
        local prompt = Instance.new("ProximityPrompt")
        prompt.ActionText = "Pick Up"
        prompt.ObjectText = ""
        prompt.AutoLocalize = true
        prompt.RootLocalizationTable = self._localization
        prompt.KeyboardKeyCode = Enum.KeyCode.E
        prompt.MaxActivationDistance = Config.PickupDistance
        prompt.HoldDuration = Config.HoldDuration
        prompt.RequiresLineOfSight = false
        prompt.Parent = root
        local noob = {Model = model, Root = root, Prompt = prompt, Picked = false,
            Points = points, TargetIndex = 2, LastUpdate = serverTime, ExpiresAt = world.NextRefresh}
        --- 原生提示提供引擎认证玩家，服务端再校验距离、存活与会话。
        --- @param player Player 发起拾取的玩家。
        noob.Connection = prompt.Triggered:Connect(function(player)
            self:PickupNoob(noob, player)
        end)
        table.insert(world.Noobs, noob)
        model.Parent = self._container
    end
end

--- 先锁定唯一拾取，再累计 GetNoob 每日任务；菜鸟不进入背包或普通道具拾取进度。
--- @param noob table 服务端保存的菜鸟状态。
--- @param player Player 引擎认证的请求玩家。
function Service:PickupNoob(noob, player)
    if noob.Picked or workspace:GetServerTimeNow() >= noob.ExpiresAt then
        return
    end
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local playerObject = _G.SPlayerObjectManager:GetPlayerObject(player.UserId)
    local activity = playerObject and playerObject:GetComponent("SActivityComp")
    if not root or not humanoid or humanoid.Health <= 0 or not activity
        or (root.Position - noob.Root.Position).Magnitude > Config.PickupDistance then
        return
    end
    noob.Picked = true
    noob.Prompt.Enabled = false
    noob.Connection:Disconnect()
    noob.Model:Destroy()
    activity:RecordNoobPickup()
    FX.Network:SendMsgToClient(player.UserId, "S2C_NoobPickedUp")
end

--- 取消服务自有任务、连接和生成实例。
function Service:Dtor()
    task.cancel(self._timer)
    for worldIndex, world in ipairs(self._worlds) do
        for noobIndex, noob in ipairs(world.Noobs) do
            noob.Connection:Disconnect()
        end
    end
    self._container:Destroy()
end

return Service
