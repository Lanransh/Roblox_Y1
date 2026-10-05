local FX, FS = _G.FX, _G.FS
local FXLoader = FX.Loader
local Fields = _G.PlayerDataConfig
local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RockLevel = require(game:GetService("ReplicatedStorage").Scripts.Game.Shared.RockLevel)
local Collectible = require(script.Parent.RockCollectible)
local Component = FX.Class("SRockLevelCompClass", "FSPlayerCompClass")

--- 每个玩家独立持有命中凭据、开奖轮次和掉落，血量由客户端维护。
--- @param owner FSPlayerObjectClass 已加载的玩家对象。
function Component:Ctor(owner)
    Component.Super.Ctor(self, owner)
    self._attackRecords = {}
    self._claimed = {}
    self._round = 1
    self._nextHit = 0
    self._dropResults = {}
    self._dropNodes = {}
    self._random = Random.new()
end

--- 返回项目组件协作名称。
--- @return string 组件名称。
function Component:GetCompName()
    return "SRockLevelComp"
end

--- 读档后从公共模型目录准备收藏品模板、同步地板颜色并启动位置检查。
function Component:OnPlayerLogin()
    self._dropTemplates = FXLoader:Shared("Assets/Models/Collectibles167"):GetChildren()
    self._itemHUD = FXLoader:Shared("Nodes/ItemHUD")
    self._areas = RockLevel.GetAreas()
    local grounds = FXLoader:Workspace("BlockMeshs/世界1/GuanQia")
    for index, area in ipairs(self._areas) do
        local ground = grounds:WaitForChild("Ground" .. index)
        area.Node.Color = ground.Color
    end
    self._timer = FX.Task:Interval(0.1, function()
        self:Tick()
    end)
end

--- 出生或回到安全区时结束开奖轮次，通知客户端恢复个人石头。
--- @param force boolean? 重生时强制切换轮次，即使上一轮未记录命中。
function Component:RestoreRocks(force)
    if force or next(self._attackRecords) ~= nil or next(self._claimed) ~= nil then
        self:ClearDrops()
        self._attackRecords = {}
        self._claimed = {}
        self._round += 1
        self._nextHit = 0
        self._hitInterval = nil
        self:SendRockRound()
    end
    self:PublishEvent("RockRoundReset")
end

--- 提供当前轮次，客户端准备完成后主动请求，避免错过初始重置消息。
function Component:SendRockRound()
    FX.Network:SendMsgToClient(self:GetPlayerId(), "S2C_RockReset", self._round)
end

--- 命中记录仅保存服务端认可的等级与次数；剩余血量完全由客户端维护。
--- @param key string 客户端命中的石头格号。
--- @param round number 客户端当前关卡轮次。
--- @return boolean 是否认可本次命中，可用于回滚客户端预测。
function Component:RecordHit(key, round)
    if not self._areas or round ~= self._round or type(key) ~= "string" or #key > 40 or self._claimed[key] then
        return false
    end
    local areaIndex, cellIndex = string.match(key, "^(%d+):(%d+)$")
    local area = self._areas[tonumber(areaIndex)]
    local cell = tonumber(cellIndex)
    if not area or not cell or cell < 1 or cell > area.Columns * area.Rows
        or key ~= area.Index .. ":" .. cell then
        return false
    end
    local character = self:GetPlayerCharacter()
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if character ~= self._character or not root or not humanoid or humanoid.Health <= 0 or not self._pickaxe
        or self._pickaxe.Parent ~= character or math.abs(root.Position.Y - area.FloorY) >= 12 then
        return false
    end
    local level = self:GetNumber(Fields.RockTrainingLevel)
    local damage = RockLevel.GetDamage(level, area.Index)
    if damage <= 0 then
        return false
    end
    local instantBreak = damage >= RockLevel.HP[area.Index]
    local cells = RockLevel.GetFrontCells(area, root.Position, root.CFrame.LookVector)
    if instantBreak then
        local column = math.floor((root.Position.X - area.MinX) / RockLevel.CellSize)
        local row = math.floor((root.Position.Z - area.MinZ) / RockLevel.CellSize)
        if column >= 0 and column < area.Columns and row >= 0 and row < area.Rows then
            table.insert(cells, 1, area.Index .. ":" .. (row * area.Columns + column + 1))
        end
    end
    local now = os.clock()
    local interval = instantBreak and 0.1 or 0.8
    local nextHit = self._nextHit
    if self._hitInterval then
        nextHit += interval - self._hitInterval
    end
    if not table.find(cells, key) or now < nextHit - 0.1 then
        return false
    end
    -- 小幅网络到达抖动不丢正常命中；累计时间预算仍限制持续攻击速率。
    self._nextHit = math.max(now, nextHit) + interval
    self._hitInterval = interval
    -- 客户端等级复制稍晚时允许其继续补完本地表现，但已具备开奖资格的格子不再产生训练收益。
    if self:GetRecordedDamage(key, area) >= RockLevel.HP[area.Index] then
        return true
    end
    local record = self._attackRecords[key]
    if not record then
        record = {Hits = {}, Character = character}
        self._attackRecords[key] = record
    end
    record.Hits[level] = (record.Hits[level] or 0) + 1
    self:PublishEvent("RockTrainingHit")
    return true
end

--- 根据命中时的服务端等级回算有效伤害，不接受客户端上报的血量或伤害。
--- @param key string 已校验的石头格号。
--- @param area table 石头所属关卡。
--- @return number 有效命中记录能够证明的累计伤害。
function Component:GetRecordedDamage(key, area)
    local record = self._attackRecords[key]
    local totalDamage = 0
    if record then
        for level, count in pairs(record.Hits) do
            totalDamage += RockLevel.GetDamage(level, area.Index) * count
        end
    end
    return totalDamage
end

--- 开奖资格通过后在服务器确定随机结果；重复请求不会重抽道具或价格。
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

--- 开奖时按有效命中的等级和次数校验击破资格，每轮每格只抽一次，包括未中奖结果。
--- @param key string 客户端提交的石头格号，不接受其位置或奖励数据。
--- @param round number 客户端当前关卡轮次，拒绝旧轮次请求。
function Component:RequestDrop(key, round)
    if round ~= self._round or type(key) ~= "string" or #key > 40 or self._claimed[key] then
        return
    end
    local record = self._attackRecords[key]
    local character = self:GetPlayerCharacter()
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not record or record.Character ~= character or not humanoid or humanoid.Health <= 0 then
        return
    end
    local area = self._areas[tonumber(string.match(key, "^(%d+):"))]
    if self:GetRecordedDamage(key, area) < RockLevel.HP[area.Index] then
        return
    end
    self._claimed[key] = true
    self:RollDrop(key, area)
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
    local dropId = HttpService:GenerateGUID(false)
    model:SetAttribute("DropId", dropId)
    local expiresAt = workspace:GetServerTimeNow() + Collectible.DropLifetime
    model:SetAttribute("DropExpiresAt", expiresAt)
    local hud = self._itemHUD:Clone()
    hud.Adornee = root
    hud.StudsOffsetWorldSpace = Vector3.new(0, size.Y / 2 + 1.5, 0)
    hud.Frame.ItemName.Text = result.Template:GetAttribute("DisplayName")
    hud.Frame.Rarity.Text = result.Template:GetAttribute("ValueTier")
    hud.Frame.Price.Text = string.format("$%d", result.Price)
    hud.Frame.Timer.Text = string.format("%ds", Collectible.DropLifetime)
    hud.Frame.Timer.AutoLocalize = false
    hud.Frame.Timer.Visible = true
    hud.Parent = root
    local prompt = Instance.new("ProximityPrompt")
    -- 原生拾取提示只显示操作文案，复用英文源表并交给 Roblox 自动本地化。
    prompt.ActionText = "Pick Up"
    prompt.ObjectText = ""
    prompt.AutoLocalize = true
    prompt.RootLocalizationTable = FXLoader:Shared("Scripts/Game/Shared/Localization")
    prompt.KeyboardKeyCode = Enum.KeyCode.E
    prompt.HoldDuration = 0.5
    prompt.MaxActivationDistance = Collectible.PickupDistance
    prompt.RequiresLineOfSight = false
    prompt.Enabled = false
    prompt.Parent = root
    -- 奖励与有效期只读取服务器记录，实例属性仅供客户端展示和识别。
    local drop = {Model = model, Prompt = prompt, Price = result.Price, Template = result.Template,
        ExpiresAt = expiresAt}
    self._dropNodes[dropId] = drop
    --- 原生提示回调只允许该石头的拥有者发起拾取。
    --- @param player Player 引擎报告的实际触发玩家。
    local function pickup(player)
        if player == self:GetPlayerNode() then
            self:PickupDrop(dropId)
        end
    end
    drop.Connection = prompt.Triggered:Connect(pickup)
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

--- 按服务端掉落 ID 校验有效期、存活、距离和容量，仅使用记录中的真实奖励。
--- @param dropId string 当前玩家的服务器掉落 ID。
function Component:PickupDrop(dropId)
    local drop = self._dropNodes[dropId]
    if drop and workspace:GetServerTimeNow() >= drop.ExpiresAt then
        self:RemoveDrop(dropId)
        return
    end
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
    local loot = self:GetTable(Fields.RockLoot)
    local inventory = self:GetPlayerObject():RequireComponent("FSInventoryComp")
    local inventoryCount = 0
    for gridIndex in pairs(inventory:GetData()) do
        inventoryCount += 1
    end
    local capacity = inventory:GetTotalCapacity()
    if inventoryCount + #loot >= capacity then
        drop.Picking = false
        self:GetPlayerObject():ShowLocalizedTips("Loot.InventoryFull", {capacity = capacity})
        return
    end
    if #loot >= RockLevel.LootCapacity then
        drop.Picking = false
        self:GetPlayerObject():ShowLocalizedTips("Loot.BagFull")
        return
    end
    table.insert(loot, {TemplateName = drop.Template.Name, Price = drop.Price,
        DisplayName = drop.Template:GetAttribute("DisplayName")})
    self:SetTable(Fields.RockLoot, loot)
    self:RemoveDrop(dropId)
    self:ShowTips("拾取了" .. drop.Template:GetAttribute("DisplayName"))
end

--- 仅在基地调用，逐件入正式背包；满包时保留未转移战利品，避免丢失或重复发放。
function Component:DepositLoot()
    local loot = self:GetTable(Fields.RockLoot)
    if #loot == 0 then
        return
    end
    local inventory = self:GetPlayerObject():RequireComponent("FSInventoryComp")
    local deposited = 0
    while #loot > 0 do
        local entry = loot[1]
        local item = FS.ItemClass.New(Collectible.ItemId, 1,
            {TemplateName = entry.TemplateName, Price = entry.Price})
        if not inventory:AddItems({item}) then
            break
        end
        table.remove(loot, 1)
        deposited += 1
    end
    if deposited > 0 then
        self:SetTable(Fields.RockLoot, loot)
        self:GetPlayerObject():ShowLocalizedTips("Loot.Deposited", {count = deposited})
    end
    if #loot > 0 and not self._depositFull then
        self:GetPlayerObject():ShowLocalizedTips("Loot.DepositFull")
    end
    self._depositFull = #loot > 0
end

--- 先注销掉落 ID，再释放实例、连接和动画，避免超时或重复拾取后继续领奖。
--- @param dropId string 已登记的服务器掉落 ID。
function Component:RemoveDrop(dropId)
    local drop = self._dropNodes[dropId]
    self._dropNodes[dropId] = nil
    drop.Connection:Disconnect()
    if drop.Task then
        task.cancel(drop.Task)
    end
    if drop.Tween then
        drop.Tween:Cancel()
        drop.Tween:Destroy()
    end
    drop.Model:Destroy()
end

--- 结束个人关卡轮次时注销全部掉落 ID，并释放提示连接和仍在播放的补间任务。
function Component:ClearDrops()
    self._dropResults = {}
    for dropId in pairs(self._dropNodes) do
        self:RemoveDrop(dropId)
    end
    self._dropNodes = {}
end

--- 出生与重生时发放带短拖尾的默认镐子，动画和拖尾由客户端控制。
--- @param humanoid Humanoid 当前存活角色的 Humanoid。
function Component:EquipPickaxe(humanoid)
    if self._pickaxe then
        self._pickaxe:Destroy()
    end
    self._pickaxe = ServerStorage:WaitForChild("StarterPickaxe"):Clone()
    self._pickaxe.Name = "免费镐子"
    local handle = self._pickaxe:WaitForChild("Handle")
    local start = Instance.new("Attachment")
    start.Name = "SwingTrailStart"
    start.Position = Vector3.new(0, 0, -handle.Size.Z * 0.35)
    start.Parent = handle
    local finish = Instance.new("Attachment")
    finish.Name = "SwingTrailEnd"
    finish.Position = Vector3.new(0, 0, handle.Size.Z * 0.35)
    finish.Parent = handle
    self._swingTrail = Instance.new("Trail")
    self._swingTrail.Name = "PickaxeSwingTrail"
    self._swingTrail.Attachment0 = start
    self._swingTrail.Attachment1 = finish
    self._swingTrail.Lifetime = 0.1
    self._swingTrail.MinLength = 0.05
    self._swingTrail.FaceCamera = true
    self._swingTrail.Color = ColorSequence.new(Color3.fromRGB(255, 240, 205))
    self._swingTrail.Transparency = NumberSequence.new(0.55, 1)
    self._swingTrail.WidthScale = NumberSequence.new(1, 0)
    self._swingTrail.Enabled = false
    self._swingTrail.Parent = handle
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
    end
end

--- 服务端回收超时道具并处理角色与入库，倒计时文字由客户端刷新，死亡期间仍正常回收。
function Component:Tick()
    local now = workspace:GetServerTimeNow()
    for dropId, drop in pairs(self._dropNodes) do
        if now >= drop.ExpiresAt then
            self:RemoveDrop(dropId)
        end
    end
    local character = self:GetPlayerCharacter()
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0 then
        return
    end
    local position = root.Position
    if self._character ~= character then
        self:RestoreRocks(self._character ~= nil)
        self._character = character
        self:EquipPickaxe(humanoid)
    end
    local firstArea = self._areas[1]
    local inSafeArea = position.Z < firstArea.MinZ - 8
        and position.Z >= firstArea.MinZ - 100
        and math.abs(position.X) <= 72
        and math.abs(position.Y - firstArea.FloorY) < 16
    if inSafeArea then
        self:RestoreRocks()
        self:DepositLoot()
    else
        self._depositFull = false
    end
end

--- 离服释放掉落、关卡任务和镐子，清空开奖校验记录。
function Component:OnPlayerLogout()
    self:ClearDrops()
    FX.Task:Cancel(self._timer)
    self._timer = nil
    if self._pickaxe then
        self._pickaxe:Destroy()
        self._pickaxe = nil
    end
    self._swingTrail = nil
    self._attackRecords = {}
    self._claimed = {}
end

--- 析构也释放任务，覆盖初始化中断的生命周期。
function Component:Dtor()
    self:OnPlayerLogout()
    Component.Super.Dtor(self)
end

return Component
