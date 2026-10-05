local FX = _G.FX
local FXLoader = FX.Loader
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local RockLevel = require(ReplicatedStorage.Scripts.Game.Shared.RockLevel)
local Fields = _G.PlayerDataConfig
local Component = FX.Class("CRockLevelCompClass", "FCPlayerCompClass")
local ColliderHeight = 16
local RockNames = {"Rock_01", "Rock_02", "Rock_03", "Rock_04", "Rock_Small_01"}
local RockColors = {
    Color3.fromRGB(217, 220, 224), Color3.fromRGB(228, 225, 215),
    Color3.fromRGB(224, 228, 226), Color3.fromRGB(235, 233, 223),
    Color3.fromRGB(219, 224, 218),
}

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
    self._hitReactions = {}
    self._nextChunkCheck = 0
    self._lastAttack = -math.huge
    self._nextAttackCheck = 0
    self._pendingHits = {}
    self._nextDropTimerCheck = 0
end

--- 返回项目关卡组件协作名称。
--- @return string 组件名称。
function Component:GetCompName()
    return "CRockLevelComp"
end

--- 同步握手后加载受击资源及个人石头，订阅轮次和命中校验结果，血量保存在本组件。
function Component:OnReady()
    local assets = FXLoader:Shared("Assets")
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
    FX.Network:SendMsgToServer("C2S_RequestRockRound")
    self:TrackConnection(RunService.Heartbeat:Connect(function()
        self:UpdateDropTimers()
        self:UpdateVisuals()
    end))
end

--- 按复制的服务器到期时间刷新掉落 HUD，延迟到达的模型和 HUD 在后续检查补齐。
function Component:UpdateDropTimers()
    local now = workspace:GetServerTimeNow()
    if now < self._nextDropTimerCheck then
        return
    end
    self._nextDropTimerCheck = now + 0.1
    for index, model in ipairs(workspace:GetChildren()) do
        local expiresAt = model:GetAttribute("DropExpiresAt")
        if model:IsA("Model") and model:GetAttribute("DropId") and type(expiresAt) == "number" then
            local root = model.PrimaryPart
            local hud = root and root:FindFirstChild("ItemHUD")
            local timer = hud and FXLoader:Find(hud, "Frame/Timer")
            if timer then
                local text = string.format("%ds", math.max(0, math.ceil(expiresAt - now)))
                if timer.Text ~= text then
                    timer.Text = text
                end
            end
        end
    end
end

--- 服务端轮次推进时取消旧挥镐和预测，恢复本地石头；初始请求可重复回放当前轮次。
--- @param round number 服务器当前关卡轮次。
function Component:ResetRound(round)
    if self._round and round <= self._round then
        return
    end
    self:StopSwing()
    self._round = round
    self._health = {}
    self._pendingHits = {}
    self._lastAttack = -math.huge
    self:ResetVisuals()
end

--- 校验结果只决定是否认可本次预测，服务器不发送或保存剩余血量。
--- @param key string 本次命中的格号。
--- @param round number 本次命中所属轮次。
--- @param accepted boolean 是否通过服务端位置、装备及频率校验。
function Component:OnHitResult(key, round, accepted)
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
        self:ResetVisuals()
    elseif self._health[key] == 0 then
        FX.Network:SendMsgToServer("C2S_RequestRockDrop", key, round)
    end
    self._refreshRocks = true
end

--- 本地即时扣血并播放特效，命中记录交给服务器校验，击破须等待认可后申请开奖。
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
    self._health[key] = value
    self._pendingHits[key] = {Round = self._round, Health = oldValue, Character = self:GetPlayerCharacter()}
    for index, chunk in ipairs(self._chunks) do
        local rock = chunk.Rocks and chunk.Rocks[key]
        if rock then
            self:PlayHitEffect(rock, value == 0)
            break
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
    local pickaxe = character:FindFirstChild("免费镐子")
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

--- 本地下砸时重验存活、装备、朝向和目标，取消已失效的挥镐伤害。
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
    if not table.find(cells, key) or health <= 0 or damage <= 0 then
        return
    end
    self:ApplyHit(key, area)
end

--- R15 蓄力后快速弯腰下砸，仅叠加腰关节以保持双脚原位；伤害仍在 0.4 秒结算。
--- @param humanoid Humanoid 当前执行敲击的角色。
--- @param key string 本次锁定的石头格子。
--- @param area table 石头所属关卡。
function Component:SwingPickaxe(humanoid, key, area)
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
        -- 原轨道 0.25 秒举镐、0.5 秒命中：延长蓄力、压缩下砸，保持总命中时点。
        self._swingTrack:Play(0.08, 1, 0.25 / 0.26)
        self._swingTask = task.spawn(function()
            self:PoseSwing(0.26, 0, 10, Enum.EasingDirection.Out)
            task.wait(0.26)
            self._swingTrack:AdjustSpeed(0.25 / 0.14)
            self._swingTrail.Enabled = true
            self:PoseSwing(0.14, 0, -38, Enum.EasingDirection.In)
            task.wait(0.14)
            self._swingTrack:AdjustSpeed(1.25)
            self:ResolvePickaxeHit(character, key, area)
            task.wait(0.06)
            self._swingTrail.Enabled = false
            self:PoseSwing(0.26, 0, 0, Enum.EasingDirection.Out)
            task.wait(0.26)
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
    self._swingTask = task.spawn(function()
        self:PoseSwing(0.22, 85, 12, Enum.EasingDirection.Out)
        task.wait(0.22)
        self._swingTrail.Enabled = true
        self:PoseSwing(0.1, -40, -18, Enum.EasingDirection.In)
        task.wait(0.1)
        self:ResolvePickaxeHit(character, key, area)
        task.wait(0.08)
        self._swingTrail.Enabled = false
        self:PoseSwing(0.28, 0, 0, Enum.EasingDirection.Out)
        task.wait(0.28)
        self._swingTask = nil
        self:StopSwing()
    end)
end

--- 本地每 0.1 秒选取近身目标，普通挥镐间隔 0.8 秒，秒杀时即时扣血并允许穿行。
function Component:UpdateAttacks()
    local character = self:GetPlayerCharacter()
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0 then
        self:StopSwing()
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
        return
    end
    local position = root.Position
    local regularAttack = now - self._lastAttack >= 0.8
    local targetFound = false
    local level = self:GetNumber(Fields.RockTrainingLevel)
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
                        self:StopSwing()
                        self:ApplyHit(key, area)
                    elseif damage > 0 and regularAttack then
                        self:SwingPickaxe(humanoid, key, area)
                    end
                    break
                end
            end
        end
        if targetFound then
            break
        end
    end
    if regularAttack then
        self._lastAttack = now
    end
end

--- 每次命中以配置颜色爆发粒子闪光、光环及火星；仅击破时散出较大烟尘。
--- @param rock Model 当前受击且仍在场景中的石头。
--- @param broken boolean 本次扣血是否击破石头。
function Component:PlayHitEffect(rock, broken)
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
    local localDirection = rock.Root.CFrame:VectorToObjectSpace(normal)
    local halfSize = rock.Root.Size / 2
    local distance = 1 / math.max(math.abs(localDirection.X) / halfSize.X,
        math.abs(localDirection.Y) / halfSize.Y, math.abs(localDirection.Z) / halfSize.Z)
    local position = rock.Root.Position + normal * distance
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
    local radius = math.clamp(math.max(rock.Root.Size.X, rock.Root.Size.Y, rock.Root.Size.Z) * 0.55, 1.5, 4)
    self:PlayImpactParticles(effect, radius, broken, effectColor)
    sound:Play()
    local away = Vector3.new(direction.X, 0, direction.Z)
    if away.Magnitude < 0.01 then
        away = Vector3.new(0, 0, 1)
    end
    away = away.Unit
    if not broken then
        self._hitReactions[rock] = {Started = os.clock(), Direction = away}
    end
    local fragmentOrigin = broken and CFrame.lookAt(center, center + normal) or effect.CFrame
    self:SpawnFragments(fragmentOrigin, rock:GetAttribute("GroundColor"), rock.Root.Size, broken)
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

--- 优先复用碎石，普通命中喷出三块小碎屑，击破爆散四块；重置透明度避免复用时不可见。
--- @param origin CFrame 普通命中的表面位置或击破的石头中心，朝向表面外侧。
--- @param color Color3 对应地板的原始颜色，以 20% 强度叠加到碎石底色。
--- @param rockSize Vector3 当前石头尺寸，用于限定击破碎块的生成范围。
--- @param broken boolean 是否击破，控制碎屑数量、尺寸及生成范围。
function Component:SpawnFragments(origin, color, rockSize, broken)
    local source = self._fragmentTemplate
    local tint = Color3.new(1, 1, 1):Lerp(color, 0.2)
    local fragmentColor = Color3.new(source.Color.R * tint.R, source.Color.G * tint.G, source.Color.B * tint.B)
    local count = broken and 4 or 3
    local phase = math.random() * math.pi * 2
    for index = 1, count do
        local fragment = table.remove(self._fragmentPool) or source:Clone()
        fragment.Name = "RockFragment"
        fragment.Anchored = true
        fragment.CanCollide = false
        fragment.CanTouch = false
        fragment.CanQuery = false
        fragment.CastShadow = false
        fragment.Color = fragmentColor
        fragment.Transparency = source.Transparency
        local size = (0.5 + math.random() * 0.4) * (broken and 1.8 or 0.65)
        fragment.Size = source.Size * (size / math.max(source.Size.X, source.Size.Y, source.Size.Z))
        local rotation = CFrame.Angles(math.random() * math.pi, math.random() * math.pi, math.random() * math.pi)
        local offset = broken and Vector3.new((math.random() - 0.5) * rockSize.X * 0.7,
            (math.random() - 0.5) * rockSize.Y * 0.5, (math.random() - 0.5) * rockSize.Z * 0.7) or Vector3.zero
        fragment.CFrame = CFrame.new(origin.Position + offset) * rotation
        fragment.Parent = self._folder
        local angle = phase + (index - 1 + math.random() * 0.4) / count * math.pi * 2
        local spread = broken and (7 + math.random() * 5) or 2
        table.insert(self._fragments, {
            Part = fragment, Size = fragment.Size, Position = origin.Position + offset, Rotation = rotation,
            Started = os.clock(), Lifetime = 0.45 + math.random() * 0.1,
            Velocity = Vector3.new(math.cos(angle) * spread, broken and (8 + math.random() * 3) or 5,
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
            table.insert(self._fragmentPool, fragment.Part)
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

--- 受损与受击只改变外观；碰撞盒保持竖直及固定高度，避免缩小或倾斜后可跳上石头。
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

--- 每 0.1 秒检查分块及攀爬限制，每帧最多生成 6 块石头；血量与等级变化及时刷新。
function Component:UpdateVisuals()
    self:UpdateFragments()
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

--- 恢复角色攀爬设置并释放场景、粒子容器、模板及全部对象池，基类负责断开监听。
function Component:Dtor()
    FX.Network:UnRegServerMsgCallback("S2C_RockReset")
    FX.Network:UnRegServerMsgCallback("S2C_RockHitResult")
    self:StopSwing()
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
