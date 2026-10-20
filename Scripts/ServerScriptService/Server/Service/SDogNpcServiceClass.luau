-- 公共小狗 NPC：定时换批、原地旋转和黄金描边，所有玩家可竞争拾取。
local FX = _G.FX
local FXLoader = FX.Loader

local Config = FXLoader:RequireShared("Scripts/Game/Shared/GameEnum").DogNpcConfig
local Service = FX.Class("SDogNpcServiceClass")

--- 读取模板与区域并启动本服务拥有的刷新任务。
function Service:Ctor()
    self._template = FXLoader:Shared(Config.TemplatePath)
    self._localization = FXLoader:Shared("Shared/Localization")
    self._worlds = {}
    self._container = Instance.new("Folder")
    self._container.Name = "DogNpcs"
    self._container.Parent = FXLoader:Workspace("Decorations")
    for worldIndex, paths in ipairs(Config.WorldAreaPaths) do
        assert(Config.SpawnCount <= #paths, "Dog SpawnCount exceeds area count")
        local world = {Areas = {}, Dogs = {}, NextRefresh = 0}
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

--- 清理到期批次并按服务器时间转动，拾取不影响下次刷新时刻。
--- @param serverTime number 当前服务器时间。
function Service:OnUpdate(serverTime)
    for worldIndex, world in ipairs(self._worlds) do
        if serverTime >= world.NextRefresh then
            self:RefreshWorld(world, serverTime)
        end
        local angle = math.rad((serverTime - world.StartTime) * Config.RotationSpeed % 360)
        for dogIndex, dog in ipairs(world.Dogs) do
            if not dog.Picked then
                dog.Model:PivotTo(dog.Pivot * CFrame.Angles(0, angle, 0))
            end
        end
    end
end

--- 每批从不同区域各选一个随机位置；模型底部对齐关卡地面。
--- @param world table 当前世界的刷新状态。
--- @param serverTime number 本批开始时间。
function Service:RefreshWorld(world, serverTime)
    for dogIndex, dog in ipairs(world.Dogs) do
        dog.Connection:Disconnect()
        dog.Model:Destroy()
    end
    world.Dogs = {}
    world.StartTime = serverTime
    world.NextRefresh = serverTime + Config.RefreshInterval
    local available = table.clone(world.Areas)
    for dogIndex = 1, Config.SpawnCount do
        local area = table.remove(available, math.random(#available))
        local model = self._template:Clone()
        model:PivotTo(CFrame.new())
        model:ScaleTo(model:GetScale() * Config.ModelHeight / model:GetExtentsSize().Y)
        local root = model:FindFirstChildWhichIsA("BasePart", true)
        assert(root, "dog template must contain a BasePart")
        for nodeIndex, node in ipairs(model:GetDescendants()) do
            if node:IsA("BasePart") then
                node.Anchored = true
                node.CanCollide = false
                node.CanTouch = false
                node.CanQuery = false
            end
        end
        local box, size = model:GetBoundingBox()
        local bottom = box.Position.Y - size.Y / 2
        local position = area.CFrame:PointToWorldSpace(Vector3.new(
            (math.random() - 0.5) * area.Size.X * Config.AreaScale,
            -area.Size.Y / 2,
            (math.random() - 0.5) * area.Size.Z * Config.AreaScale
        ))
        local pivot = CFrame.new(position + Vector3.new(0, Config.HoverHeight - bottom, 0))
        model:PivotTo(pivot)
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
        local dog = {Model = model, Root = root, Pivot = pivot, Prompt = prompt, Picked = false,
            ExpiresAt = world.NextRefresh}
        --- 原生提示提供引擎认证玩家，服务端再校验距离、存活与会话。
        --- @param player Player 发起拾取的玩家。
        dog.Connection = prompt.Triggered:Connect(function(player)
            self:PickupDog(dog, player)
        end)
        table.insert(world.Dogs, dog)
        model.Parent = self._container
    end
end

--- 先锁定唯一拾取，再累计 GetDog 每日任务；小狗不进入背包或普通道具拾取进度。
--- @param dog table 服务端保存的小狗状态。
--- @param player Player 引擎认证的请求玩家。
function Service:PickupDog(dog, player)
    if dog.Picked or workspace:GetServerTimeNow() >= dog.ExpiresAt then
        return
    end
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local playerObject = _G.SPlayerObjectManager:GetPlayerObject(player.UserId)
    local activity = playerObject and playerObject:GetComponent("SActivityComp")
    if not root or not humanoid or humanoid.Health <= 0 or not activity
        or (root.Position - dog.Root.Position).Magnitude > Config.PickupDistance then
        return
    end
    dog.Picked = true
    dog.Prompt.Enabled = false
    dog.Connection:Disconnect()
    dog.Model:Destroy()
    activity:RecordDogPickup()
    FX.Network:SendMsgToClient(player.UserId, "S2C_DogPickedUp")
end

--- 取消服务自有任务、连接和生成实例。
function Service:Dtor()
    task.cancel(self._timer)
    for worldIndex, world in ipairs(self._worlds) do
        for dogIndex, dog in ipairs(world.Dogs) do
            dog.Connection:Disconnect()
        end
    end
    self._container:Destroy()
end

return Service
