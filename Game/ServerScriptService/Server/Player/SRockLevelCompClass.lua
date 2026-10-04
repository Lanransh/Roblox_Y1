local FX, FS = _G.FX, _G.FS
local Fields = _G.PlayerDataConfig
local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")
local RockLevel = require(game:GetService("ReplicatedStorage").Scripts.Game.Shared.RockLevel)
local Collectible = require(script.Parent.RockCollectible)
local Component = FX.Class("SRockLevelCompClass", "FSPlayerCompClass")

--- 玩家各自持有石头、随机掉落及其场景节点，避免请求跨玩家领取。
--- @param owner FSPlayerObjectClass 已加载的玩家对象。
function Component:Ctor(owner)
    Component.Super.Ctor(self, owner)
    self._health = {}
    self._dropResults = {}
    self._dropNodes = {}
    self._random = Random.new()
    self._lastAttack = -1
    self._lastGrowth = os.clock()
    self._hit = false
end

--- 返回项目组件协作名称。
--- @return string 组件名称。
function Component:GetCompName()
    return "SRockLevelComp"
end

--- 读档后准备掉落模板、同步地板颜色并启动位置检查。
function Component:OnPlayerLogin()
    self._dropTemplates = ServerStorage:WaitForChild("Collectibles208"):GetChildren()
    self._itemHUD = game:GetService("ReplicatedStorage"):WaitForChild("Nodes"):WaitForChild("ItemHUD")
    self._areas = RockLevel.GetAreas()
    local grounds = workspace:WaitForChild("BlockMeshs"):WaitForChild("世界1"):WaitForChild("GuanQia")
    for index, area in ipairs(self._areas) do
        local ground = grounds:WaitForChild("Ground" .. index)
        area.Node.Color = ground.Color
    end
    local player = self:GetPlayerNode()
    self._stats = player:FindFirstChild("leaderstats")
    self._ownsStats = self._stats == nil
    if self._ownsStats then
        self._stats = Instance.new("Folder")
        self._stats.Name = "leaderstats"
        self._stats.Parent = player
    end
    self._levelStat = Instance.new("IntValue")
    self._levelStat.Name = "训练等级"
    self._levelStat.Parent = self._stats
    self._strengthStat = Instance.new("NumberValue")
    self._strengthStat.Name = "力量"
    self._strengthStat.Parent = self._stats
    self:RefreshProgress()
    self._timer = FX.Task:Interval(0.1, function()
        self:Tick()
    end)
end

--- 将持久训练值派生为同步等级，并暴露原生玩家属性便于检查。
function Component:RefreshProgress()
    local level, strength = RockLevel.GetProgress(self:GetNumber(Fields.RockTrainingValue))
    self:SetNumber(Fields.RockTrainingLevel, level)
    local player = self:GetPlayerNode()
    player:SetAttribute("TrainingLevel", level)
    player:SetAttribute("Strength", strength)
    self._levelStat.Value = level
    self._strengthStat.Value = strength
end

--- 在出生或回到安全区时恢复个人石头，并清理上一轮尚未拾取的道具。
function Component:RestoreRocks()
    self:StopSwing()
    if next(self._health) ~= nil then
        self:ClearDrops()
        self._health = {}
        self:SetTable(Fields.RockHealth, self._health)
    end
    self._hit = false
end

--- 击破时在服务器确定随机结果；客户端重复请求不会重抽道具或价格。
--- @param key string 本次刚击破的格号。
--- @param area table 服务器已验证的关卡边界。
function Component:RollDrop(key, area)
    if self._random:NextNumber() >= Collectible.DropChance then
        return
    end
    local cell = tonumber(string.match(key, ":(%d+)$")) - 1
    self._dropResults[key] = {
        Template = self._dropTemplates[self._random:NextInteger(1, #self._dropTemplates)],
        Price = self._random:NextInteger(Collectible.MinPrice, Collectible.MaxPrice),
        Position = Vector3.new(area.MinX + (cell % area.Columns + 0.5) * RockLevel.CellSize,
            area.FloorY, area.MinZ + (math.floor(cell / area.Columns) + 0.5) * RockLevel.CellSize),
    }
end

--- 弹出已确认击破的个人石头道具，随后连同 ItemHUD 持续漂浮并开放 E 拾取。
--- @param key string 客户端提交的石头格号，不接受其位置或奖励数据。
function Component:RequestDrop(key)
    if type(key) ~= "string" or #key > 40 or self._health[key] ~= 0 then
        return
    end
    local result = self._dropResults[key]
    if not result then
        return
    end
    self._dropResults[key] = nil
    local model = Collectible.CreateModel(result.Template)
    local box, size = model:GetBoundingBox()
    model:PivotTo(CFrame.new(result.Position + Vector3.new(0, size.Y / 2 + 0.2, 0) - box.Position))
    local root = model.PrimaryPart
    local landing = root.CFrame
    model:PivotTo(model:GetPivot() - Vector3.new(0, 0.5, 0))
    model:SetAttribute("OwnerUserId", self:GetPlayerId())
    model:SetAttribute("Price", result.Price)
    local hud = self._itemHUD:Clone()
    hud.Adornee = root
    hud.StudsOffsetWorldSpace = Vector3.new(0, size.Y / 2 + 1.5, 0)
    hud.Frame.ItemName.Text = result.Template:GetAttribute("DisplayName")
    hud.Frame.Rarity.Text = result.Template:GetAttribute("ValueTier")
    hud.Frame.Price.Text = string.format("$%d", result.Price)
    hud.Frame.Timer.Visible = false
    hud.Parent = root
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "拾取"
    prompt.ObjectText = hud.Frame.ItemName.Text
    prompt.KeyboardKeyCode = Enum.KeyCode.E
    prompt.HoldDuration = 0
    prompt.MaxActivationDistance = Collectible.PickupDistance
    prompt.RequiresLineOfSight = false
    prompt.Enabled = false
    prompt.Parent = root
    local drop = {Model = model, Prompt = prompt, Price = result.Price, Template = result.Template}
    self._dropNodes[key] = drop
    --- 原生提示回调只允许该石头的拥有者发起拾取。
    --- @param player Player 引擎报告的实际触发玩家。
    local function pickup(player)
        if player == self:GetPlayerNode() then
            self:PickupDrop(key)
        end
    end
    prompt.Triggered:Connect(pickup)
    model.Parent = workspace
    --- 弹起结束后进入往返漂浮并开放拾取，清理关卡时取消任务和补间。
    drop.Task = task.spawn(function()
        drop.Tween = TweenService:Create(root, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {CFrame = landing + Vector3.new(0, 4, 0)})
        drop.Tween:Play()
        task.wait(0.25)
        drop.Tween = TweenService:Create(root, TweenInfo.new(0.35, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
            {CFrame = landing})
        drop.Tween:Play()
        task.wait(0.35)
        drop.Task = nil
        drop.Tween:Destroy()
        -- 沿用 Studio_Y3 的 1.3 秒 Quad InOut 往返节奏，幅度适配 Roblox stud 尺度。
        drop.Tween = TweenService:Create(root,
            TweenInfo.new(1.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, -1, true),
            {CFrame = landing + Vector3.new(0, 0.8, 0)})
        drop.Tween:Play()
        prompt.Enabled = true
    end)
end

--- 校验存活、距离和一次性状态；满包保留漂浮道具，入包成功后停止动画并移除掉落。
--- @param key string 当前玩家掉落记录的格号。
function Component:PickupDrop(key)
    local drop = self._dropNodes[key]
    if not drop or drop.Picking or not drop.Prompt.Enabled then
        return
    end
    local character = self:GetPlayerCharacter()
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0
        or (root.Position - drop.Model.PrimaryPart.Position).Magnitude > Collectible.PickupDistance then
        return
    end
    drop.Picking = true
    local inventory = self:GetPlayerObject():RequireComponent("FSInventoryComp")
    local item = FS.ItemClass.New(Collectible.ItemId, 1, {TemplateName = drop.Template.Name, Price = drop.Price})
    if not inventory:AddItems({item}) then
        drop.Picking = false
        self:ShowTips("背包已满，请先腾出空位")
        return
    end
    self._dropNodes[key] = nil
    drop.Tween:Cancel()
    drop.Tween:Destroy()
    drop.Model:Destroy()
    self:ShowTips("拾取了" .. drop.Template:GetAttribute("DisplayName"))
end

--- 结束个人关卡轮次时释放掉落、提示连接和仍在播放的补间任务。
function Component:ClearDrops()
    self._dropResults = {}
    for key, drop in pairs(self._dropNodes) do
        if drop.Task then
            task.cancel(drop.Task)
        end
        if drop.Tween then
            drop.Tween:Cancel()
            drop.Tween:Destroy()
        end
        drop.Model:Destroy()
    end
    self._dropNodes = {}
end

--- 出生与重生时发放默认镐子，并为当前 R15 角色缓存上半身攻击轨道。
--- @param humanoid Humanoid 当前存活角色的 Humanoid。
function Component:EquipPickaxe(humanoid)
    if self._swingTrack then
        self._swingTrack:Destroy()
        self._swingTrack = nil
    end
    if self._pickaxe then
        self._pickaxe:Destroy()
    end
    self._pickaxe = ServerStorage:WaitForChild("StarterPickaxe"):Clone()
    self._pickaxe.Name = "免费镐子"
    self._pickaxe.Parent = self:GetPlayerNode():WaitForChild("Backpack")
    humanoid:EquipTool(self._pickaxe)
    if humanoid.RigType == Enum.HumanoidRigType.R15 then
        local animator = humanoid:FindFirstChildOfClass("Animator")
        if not animator then
            animator = Instance.new("Animator")
            animator.Parent = humanoid
        end
        local animation = Instance.new("Animation")
        animation.Name = "RockUpperBodySwing"
        -- 06 号预览的 Roblox 官方动画：仅双臂和手腕有权重，不覆盖腰、根节点和腿部。
        animation.AnimationId = "rbxassetid://2850678159"
        animation.Parent = self._pickaxe
        self._swingTrack = animator:LoadAnimation(animation)
        self._swingTrack.Priority = Enum.AnimationPriority.Action
        self._swingTrack.Looped = false
    end
end

--- 淡出上半身轨道并恢复旧关节补间，取消中断后的延迟伤害。
function Component:StopSwing()
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
            joint.C0 = pose.Base
        end
    end
    self._swingJoints = nil
end

--- 在原始关节上叠加躯干坐标系旋转，兼容 R6 肩轴方向并保留行走动画。
--- @param duration number 当前阶段持续秒数。
--- @param armAngle number 持镐手臂俯仰角度。
--- @param bodyAngle number 躯干俯仰角度。
--- @param direction Enum.EasingDirection 蓄力减速或下砸加速。
function Component:PoseSwing(duration, armAngle, bodyAngle, direction)
    for joint, pose in pairs(self._swingJoints) do
        local angle = pose.Body and bodyAngle or armAngle
        local base = pose.Base
        local target = CFrame.new(base.Position) * CFrame.Angles(math.rad(angle), 0, 0) * base.Rotation
        pose.Tween = TweenService:Create(joint, TweenInfo.new(duration, Enum.EasingStyle.Quad, direction), {C0 = target})
        pose.Tween:Play()
    end
end

--- 下砸时重验存活、装备、朝向和目标；击破时先确定掉落，再同步血量通知客户端。
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
    self._health[key] = math.max(0, health - damage)
    if self._health[key] == 0 then
        self:RollDrop(key, area)
    end
    self._hit = true
    self:SetTable(Fields.RockHealth, self._health)
end

--- R15 用 1.25 倍速的 06 号上半身轨道叠加行走，配合 0.8 秒攻击间隔；R6 保留原补间。
--- @param humanoid Humanoid 当前执行敲击的角色。
--- @param key string 本次锁定的石头格子。
--- @param area table 石头所属关卡。
function Component:SwingPickaxe(humanoid, key, area)
    self:StopSwing()
    if self._pickaxe.Parent ~= self._character then
        humanoid:EquipTool(self._pickaxe)
    end
    local character = self._character
    if humanoid.RigType == Enum.HumanoidRigType.R15 then
        self._swingTrack:Play(0.08, 1, 1.25)
        -- 原动画加速后在 0.2 秒举起、0.4 秒砸下；0.72 秒开始淡出，0.8 秒前结束。
        self._swingTask = task.spawn(function()
            task.wait(0.4)
            self:ResolvePickaxeHit(character, key, area)
            task.wait(0.32)
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
        self:PoseSwing(0.1, -40, -18, Enum.EasingDirection.In)
        task.wait(0.1)
        self:ResolvePickaxeHit(character, key, area)
        task.wait(0.08)
        self:PoseSwing(0.28, 0, 0, Enum.EasingDirection.Out)
        task.wait(0.28)
        self._swingTask = nil
        self:StopSwing()
    end)
end

--- 每次只处理朝向上最近的未破坏石头；所有攻击（包括残血击破）统一遵守 0.8 秒间隔。
function Component:Tick()
    local character = self:GetPlayerCharacter()
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0 then
        self:StopSwing()
        self._lastPosition = nil
        self._hit = false
        return
    end
    local now = os.clock()
    local position = root.Position
    if self._character ~= character then
        self._character = character
        self._lastPosition = position
        self._lastGrowth = now
        self:RestoreRocks()
        self:EquipPickaxe(humanoid)
    end
    local firstArea = self._areas[1]
    local inSafeArea = position.Z < firstArea.MinZ - 8
        and position.Z >= firstArea.MinZ - 100
        and math.abs(position.X) <= 72
        and math.abs(position.Y - firstArea.FloorY) < 16
    if inSafeArea then
        self:RestoreRocks()
    end
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
            for cellIndex = 1, #cells do
                local key = cells[cellIndex]
                local health = self._health[key] or RockLevel.HP[index]
                if health > 0 then
                    targetFound = true
                    if damage > 0 and regularAttack then
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
    if now - self._lastGrowth >= 1 then
        local previous = self._lastPosition or position
        local distance = Vector3.new(position.X - previous.X, 0, position.Z - previous.Z).Magnitude
        local elapsed = now - self._lastGrowth
        -- 不按客户端声明的行走状态结算，排除原地和超出正常步速的瞬移。
        local moving = distance > 0.1 and distance <= humanoid.WalkSpeed * elapsed * 1.5
            and humanoid.FloorMaterial ~= Enum.Material.Air
        local gain = (moving and 2 or 0) + (self._hit and 2 or 0)
        if gain > 0 then
            self:AddNumber(Fields.RockTrainingValue, gain)
            self:RefreshProgress()
        end
        self._lastPosition = position
        self._lastGrowth = now
        self._hit = false
    end
end

--- 离服释放掉落、结算任务、当前角色轨道和镐子。
function Component:OnPlayerLogout()
    self:ClearDrops()
    self:StopSwing()
    FX.Task:Cancel(self._timer)
    self._timer = nil
    if self._swingTrack then
        self._swingTrack:Destroy()
        self._swingTrack = nil
    end
    if self._pickaxe then
        self._pickaxe:Destroy()
        self._pickaxe = nil
    end
end

--- 析构也释放任务，覆盖初始化中断的生命周期。
function Component:Dtor()
    self:OnPlayerLogout()
    if self._ownsStats then
        self._stats:Destroy()
    else
        if self._levelStat then
            self._levelStat:Destroy()
        end
        if self._strengthStat then
            self._strengthStat:Destroy()
        end
    end
    Component.Super.Dtor(self)
end

return Component
