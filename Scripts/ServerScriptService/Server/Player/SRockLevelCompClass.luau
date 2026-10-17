local FX = _G.FX
local FXLoader = FX.Loader
local Fields = _G.PlayerDataConfig
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RockLevel = require(game:GetService("ReplicatedStorage").Scripts.Game.Shared.RockLevel)
local Collectible = require(script.Parent.RockCollectible)
local ToyRoller = FXLoader:RequireFromParent(script, "ToyRoller")
local RockWeaponTool = require(script.Parent.RockWeaponTool)
local GameConfig = _G.GameConfig
local GameUtility = FXLoader:RequireShared("Scripts/Game/Shared/GameUtility")
local CollectibleText = FXLoader:RequireShared("Scripts/Game/Shared/CollectibleText")
local Collection = FXLoader:RequireShared("Scripts/Game/Shared/Collection")
local Weapon = FXLoader:RequireShared("Scripts/Game/Shared/Weapon")
local InstancePath = FXLoader:RequireShared("Scripts/Game/Shared/InstancePath")
local English = FXLoader:Shared("Shared/Localization"):GetTranslator("en-us")
local Component = FX.Class("SRockLevelCompClass", "FSPlayerCompClass")

--- 配置校验和倍率计算共用的有限数检查，拒绝 NaN 与无穷值。
--- @param value any 待检查的配置值。
--- @return boolean 值是否为有限数字。
local function isFiniteNumber(value)
    return type(value) == "number" and value == value and value > -math.huge and value < math.huge
end

--- 每个玩家独立持有预生成区域、命中凭据、轮次和掉落，客户端预测血量由服务端校正。
--- @param owner FSPlayerObjectClass 已加载的玩家对象。
function Component:Ctor(owner)
    Component.Super.Ctor(self, owner)
    self._attackRecords = {}
    self._claimed = {}
    self._round = 1
    self._nextHit = 0
    self._dropNodes = {}
    self._dropByCell = {}
    self._dropRetryAfter = {}
    self._dropAttempts = {}
    self._dropFailureWarned = {}
    self._areaDefinitions = {}
    self._areaStates = {}
    self._inSafeArea = nil
    self._random = Random.new()
end

--- 返回项目组件协作名称。
--- @return string 组件名称。
function Component:GetCompName()
    return "SRockLevelComp"
end

--- 返回基础容量、永久商店扩容和未到期扩容卡之和。
---@return number 当前可携带的战利品数量上限。
function Component:GetLootCapacity()
    local capacity = RockLevel.LootCapacity + self:GetTable(Fields.CurrencyShopData).capacity
    local boost = self:GetTable(Fields.RockLootCapacityBoost)
    if type(boost) ~= "table" or (boost.expiresAt or 0) <= workspace:GetServerTimeNow() then
        return capacity
    end
    return capacity + math.max(0, math.floor(boost.count or 0))
end

--- 写入扩容卡状态；连续使用时只延长现有到期时间，不重复增加格数。
---@param count number 本次卡片提供的容量格数。
---@param duration number 本次卡片持续秒数。
---@return boolean 是否成功写入扩容状态。
function Component:ApplyLootCapacityBoost(count, duration)
    return self:RequireComponent("FSRewardComp"):AddRewards({
        {Type = "LootCapacityBoost", Count = count, Duration = duration},
    })
end

--- 读档后缓存武器模板、校验奖池模型、同步地板颜色并启动位置检查。
function Component:OnPlayerLogin()
    self._weaponTemplates = {}
    for index, config in ipairs(GameConfig.ToolConfig) do
        self._weaponTemplates[config.ToolId] = InstancePath.Wait(config.ModelId)
    end
    self._itemHUD = FXLoader:Shared("Nodes/ItemHUD")
    self._areas = RockLevel.GetAreas()
    self:PrepareAreaDefinitions()
    local grounds = FXLoader:Workspace("BlockMeshs/World1Root/GuanQia")
    for index, area in ipairs(self._areas) do
        local ground = grounds:WaitForChild("Ground" .. index)
        area.Node.Color = ground.Color
    end
    self._timer = FX.Task:Interval(0.1, function()
        self:Tick()
    end)
end

--- 按石头总数与通用比例确定刷新件数，按 AreaId 校验幸运倍率并缓存候选模型。
function Component:PrepareAreaDefinitions()
    local configsById, duplicateConfigs = {}, {}
    local areaConfigs = type(GameConfig.AreaConfig) == "table" and GameConfig.AreaConfig or {}
    for _, config in pairs(areaConfigs) do
        local areaId = type(config) == "table" and config.AreaId
        if isFiniteNumber(areaId) then
            if configsById[areaId] then
                duplicateConfigs[areaId] = true
            else
                configsById[areaId] = config
            end
        end
    end
    self._areaDefinitions = {}
    local itemDataById = type(GameConfig.ItemData) == "table" and GameConfig.ItemData or {}
    for _, area in ipairs(self._areas) do
        local areaId = area.Index
        local definition = {AreaId = areaId, Pool = {}}
        self._areaDefinitions[areaId] = definition
        local config = configsById[areaId]
        if duplicateConfigs[areaId] then
            definition.Error = "duplicate AreaConfig rows"
        elseif not config or config.AreaId ~= areaId then
            definition.Error = "missing AreaConfig for world 1 area"
        else
            local count = math.floor(area.Columns * area.Rows * GameConfig.CommonConfig.ToyRefreshRatio)
            definition.LuckCount = math.min(GameConfig.CommonConfig.ToyLuckyCount, count)
            definition.NormalCount = count - definition.LuckCount
            if definition.LuckCount > 0 then
                local rate = config.LuckRefreshRate
                if type(rate) ~= "table" or not isFiniteNumber(rate[1]) or not isFiniteNumber(rate[2])
                    or rate[1] <= 0 or rate[2] <= 0 or rate[1] > rate[2] then
                    definition.Error = "lucky rate must contain ordered finite positive bounds"
                else
                    definition.LuckRateMin = rate[1]
                    definition.LuckRateMax = rate[2]
                end
            end
            if not definition.Error and definition.NormalCount + definition.LuckCount > 0 then
                local pool, averagePrice, areaLuck = ToyRoller.CreatePool(1, areaId)
                definition.AveragePrice = averagePrice
                definition.AreaLuck = areaLuck
                for _, reward in ipairs(pool) do
                    local itemId = reward.ItemId
                    local itemData = isFiniteNumber(itemId) and itemDataById[itemId]
                    local template = type(itemData) == "table" and Collectible.ResolveModel(itemData.DisplayModelId)
                    if not isFiniteNumber(itemId) or itemId % 1 ~= 0 or type(itemData) ~= "table"
                        or itemData.Id ~= itemId or not template
                        or not isFiniteNumber(itemData.Quality) or itemData.Quality < 0
                        or itemData.Quality % 1 ~= 0 then
                        definition.Error = "reward has invalid item, model, or quality"
                        break
                    end
                    table.insert(definition.Pool, {
                        ItemId = itemId,
                        DisplayModelId = itemData.DisplayModelId,
                        Template = template,
                        Quality = itemData.Quality,
                        PriceRateMin = reward.PriceRateMin,
                        PriceRateMax = reward.PriceRateMax,
                    })
                end
            end
        end
        if definition.Error then
            warn(string.format("Rock rewards disabled for AreaId %s: %s", tostring(areaId), definition.Error))
        end
    end
end

--- 按 2×2 分区轮流抽取固定比例的石头格，分散道具后打乱幸运位置；已有区域不重抽。
--- @param area table 服务端加载的当前关或下一关边界。
--- @return boolean 区域是否已可用于本轮。
function Component:InitializeArea(area)
    local areaId = area.Index
    if self._areaStates[areaId] then
        return true
    end
    local definition = self._areaDefinitions[areaId]
    if not definition or definition.Error then
        return false
    end
    local cells = {}
    local count = definition.NormalCount + definition.LuckCount
    local zones = {}
    for row = 0, area.Rows - 1, 2 do
        for column = 0, area.Columns - 1, 2 do
            local zone = {}
            for zoneRow = row, math.min(row + 1, area.Rows - 1) do
                for zoneColumn = column, math.min(column + 1, area.Columns - 1) do
                    table.insert(zone, zoneRow * area.Columns + zoneColumn + 1)
                end
            end
            table.insert(zones, zone)
        end
    end
    -- 每个分区先抽一格再开始下一轮，避免道具集中在一侧；分区顺序随机。
    for index = 1, #zones do
        local swap = self._random:NextInteger(index, #zones)
        zones[index], zones[swap] = zones[swap], zones[index]
    end
    while #cells < count do
        for zoneIndex, zone in ipairs(zones) do
            if #zone > 0 then
                table.insert(cells, table.remove(zone, self._random:NextInteger(1, #zone)))
                if #cells == count then
                    break
                end
            end
        end
    end
    -- 幸运件数按最终顺序分配，打乱后不会固定落在最后遍历的几个分区。
    for index = 1, count do
        local swap = self._random:NextInteger(index, #cells)
        cells[index], cells[swap] = cells[swap], cells[index]
    end

    local contents = {}
    for index = 1, count do
        local selected = definition.Pool[self._random:NextInteger(1, #definition.Pool)]
        local isLucky = index > definition.NormalCount
        local luckRate = isLucky and self._random:NextNumber(definition.LuckRateMin, definition.LuckRateMax) or 1
        -- 每种道具使用本关固定档次的价格区间，同款浮动，幸运倍率额外叠加。
        local price = definition.AveragePrice
            * self._random:NextNumber(selected.PriceRateMin, selected.PriceRateMax) * luckRate
        if not isFiniteNumber(price) or price < 0 then
            definition.Error = "generated reward price is not finite"
            warn(string.format("Rock rewards disabled for AreaId %s: %s", tostring(areaId), definition.Error))
            return false
        end
        contents[cells[index]] = {
            ItemId = selected.ItemId,
            DisplayModelId = selected.DisplayModelId,
            Template = selected.Template,
            Quality = selected.Quality,
            Price = price,
            IsLucky = isLucky,
            LuckRate = luckRate,
        }
    end
    self._areaStates[areaId] = {Initialized = true, Contents = contents, Broken = {}}
    return true
end

--- 返回本玩家当前轮次已击破的格号，供角色更换或网络重连后恢复。
--- @return table 已击破格号数组。
function Component:GetBrokenCells()
    local cells = {}
    for areaId, areaState in pairs(self._areaStates) do
        for cell in pairs(areaState.Broken) do
            table.insert(cells, areaId .. ":" .. cell)
        end
    end
    table.sort(cells)
    return cells
end

--- 回基地边沿结束上一轮并清理个人场景状态，保留已经领取的 RockLoot。
function Component:RestoreRocks()
    self:ClearDrops()
    self._areaStates = {}
    self._attackRecords = {}
    self._claimed = {}
    self._dropRetryAfter = {}
    self._dropAttempts = {}
    self._dropFailureWarned = {}
    self._round += 1
    self._nextHit = 0
    self._hitInterval = nil
    self:PublishEvent("RockRoundReset")
    self:SendRockRound()
end

--- 回放轮次及个人已击破格号；客户端可区分新轮和同轮状态恢复。
function Component:SendRockRound()
    FX.Network:SendMsgToClient(self:GetPlayerId(), "S2C_RockReset", self._round, self:GetBrokenCells())
end

--- 命中记录只保存服务端认可的等级与次数，并回传累计减伤后的剩余血量。
--- @param key string 客户端命中的石头格号。
--- @param round number 客户端当前关卡轮次。
--- @return boolean 是否认可本次命中，可用于回滚客户端预测。
--- @return number? 认可命中后的服务端剩余血量，拒绝时不返回。
function Component:RecordHit(key, round)
    if not self._areas or round ~= self._round or type(key) ~= "string" or #key > 40 then
        return false
    end
    local areaIndex, cellIndex = string.match(key, "^(%d+):(%d+)$")
    local area = self._areas[tonumber(areaIndex)]
    local cell = tonumber(cellIndex)
    if not area or not cell or cell < 1 or cell > area.Columns * area.Rows
        or key ~= area.Index .. ":" .. cell then
        return false
    end
    local areaState = self._areaStates[area.Index]
    if areaState and areaState.Broken[cell] then
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
    if not self:InitializeArea(area) then
        return false
    end
    -- 等级复制延迟时直接校正为击破，已具备开奖资格的格子不再产生训练收益。
    if self:GetRecordedDamage(key, area) >= RockLevel.HP[area.Index] then
        return true, 0
    end
    local record = self._attackRecords[key]
    if not record then
        record = {Hits = {}, Character = character}
        self._attackRecords[key] = record
    end
    record.Hits[level] = (record.Hits[level] or 0) + 1
    self:PublishEvent("RockTrainingHit")
    return true, math.max(0, RockLevel.HP[area.Index] - self:GetRecordedDamage(key, area))
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

--- 使用区域预生成记录揭露格子；空格也只结算一次，创建失败保留原记录供重试。
--- @param key string 客户端提交的石头格号，不接受其位置或奖励数据。
--- @param round number 客户端当前关卡轮次，拒绝旧轮次请求。
function Component:RequestDrop(key, round)
    if round ~= self._round or type(key) ~= "string" or #key > 40 then
        return
    end
    local areaIndex, cellIndex = string.match(key, "^(%d+):(%d+)$")
    local area = areaIndex and self._areas[tonumber(areaIndex)]
    local cell = tonumber(cellIndex)
    if not area or not cell or key ~= area.Index .. ":" .. cell then
        return
    end
    local record = self._attackRecords[key]
    local character = self:GetPlayerCharacter()
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not record or record.Character ~= character or not humanoid or humanoid.Health <= 0
        or self:GetRecordedDamage(key, area) < RockLevel.HP[area.Index] then
        return
    end
    if not self:InitializeArea(area) then
        return
    end
    local areaState = self._areaStates[area.Index]
    areaState.Broken[cell] = true
    if self._claimed[key] then
        return
    end
    local result = areaState.Contents[cell]
    if not result then
        self._claimed[key] = true
        return
    end
    if self._dropByCell[key] or os.clock() < (self._dropRetryAfter[key] or 0) then
        return
    end
    self:CreateDrop(key, area, cell, result, round)
end

--- 创建已通过击破校验的固定奖励；失败由位置 Tick 最多自动重试三次，不依赖旧角色凭据。
--- 幸运掉落仅通过 HUD 图标标识，品质文案不显示幸运倍率。
--- @param key string 已击破的石头格号。
--- @param area table 奖励所属区域。
--- @param cell number 区域内格号。
--- @param result table 本轮预生成且已揭露的奖励。
--- @param round number 击破所属轮次。
function Component:CreateDrop(key, area, cell, result, round)
    if round ~= self._round or self._claimed[key] or self._dropByCell[key]
        or (self._dropAttempts[key] or 0) >= 4 then
        return
    end
    self._dropRetryAfter[key] = nil
    self._dropAttempts[key] = (self._dropAttempts[key] or 0) + 1

    local dropId = HttpService:GenerateGUID(false)
    local model, prompt, drop
    --- 模型、HUD 和提示同步创建且不等待；异常时释放局部实例并保留预生成奖励。
    local success, failure = pcall(function()
        model = Collectible.CreateModel(result.Template)
        local box, size = model:GetBoundingBox()
        local position = Vector3.new(area.MinX + ((cell - 1) % area.Columns + 0.5) * RockLevel.CellSize,
            area.FloorY, area.MinZ + (math.floor((cell - 1) / area.Columns) + 0.5) * RockLevel.CellSize)
        model:PivotTo(CFrame.new(position + Vector3.new(0, size.Y / 2 + 0.2, 0) - box.Position))
        local root = model.PrimaryPart
        local landing = root.CFrame
        model:PivotTo(model:GetPivot() - Vector3.new(0, 0.5, 0))
        model:SetAttribute("OwnerUserId", self:GetPlayerId())
        model:SetAttribute("Price", result.Price)
        model:SetAttribute("ItemId", result.ItemId)
        model:SetAttribute("DisplayModelId", result.DisplayModelId)
        model:SetAttribute("IsLucky", result.IsLucky)
        model:SetAttribute("LuckRate", result.LuckRate)
        model:SetAttribute("DropId", dropId)
        local expiresAt = workspace:GetServerTimeNow() + Collectible.DropLifetime
        model:SetAttribute("DropExpiresAt", expiresAt)
        local hud = self._itemHUD:Clone()
        hud.Adornee = root
        Collectible.StyleHUD(hud, model, result.Quality)
        local nameKey = CollectibleText.GetNameKey(result.Template.Name)
        local rarityKey = "Rarity.Quality"
        local rarityArguments = {level = result.Quality}
        hud:SetAttribute("DisplayNameKey", nameKey)
        hud:SetAttribute("RarityKey", rarityKey)
        hud:SetAttribute("RarityLevel", result.Quality)
        hud:SetAttribute("IsLucky", result.IsLucky)
        hud:SetAttribute("LuckRate", result.LuckRate)
        hud.Frame.LuckIcon.Visible = result.IsLucky == true
        hud.Frame.ItemName.Text = English:FormatByKey(nameKey)
        hud.Frame.Rarity.Text = English:FormatByKey(rarityKey, rarityArguments)
        hud.Frame.ItemName.AutoLocalize = false
        hud.Frame.Rarity.AutoLocalize = false
        hud.Frame.Price.Text = "$" .. GameUtility.NumberToText(result.Price)
        hud.Frame.Price.AutoLocalize = false
        hud.Frame.Timer.Text = string.format("%ds", Collectible.DropLifetime)
        hud.Frame.Timer.AutoLocalize = false
        hud.Frame.Timer.Visible = true
        hud.Parent = root
        prompt = Instance.new("ProximityPrompt")
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
        drop = {Model = model, Prompt = prompt, Price = result.Price, Template = result.Template,
            ItemId = result.ItemId, DisplayModelId = result.DisplayModelId, IsLucky = result.IsLucky,
            LuckRate = result.LuckRate, ExpiresAt = expiresAt, CellKey = key, Round = round, Landing = landing}
    end)
    if not success then
        if prompt then
            prompt:Destroy()
        end
        if model then
            model:Destroy()
        end
        if self._dropAttempts[key] < 4 then
            self._dropRetryAfter[key] = os.clock() + 1
        end
        if not self._dropFailureWarned[key] then
            self._dropFailureWarned[key] = true
            warn("Rock reward drop creation failed for " .. key .. ": " .. tostring(failure))
        end
        return
    end

    self._claimed[key] = true
    self._dropAttempts[key] = nil
    self._dropNodes[dropId] = drop
    self._dropByCell[key] = dropId
    --- 原生提示回调只允许该石头的拥有者发起拾取。
    --- @param player Player 引擎报告的实际触发玩家。
    local function pickup(player)
        if player == self:GetPlayerNode() then
            self:PickupDrop(dropId)
        end
    end
    drop.Connection = prompt.Triggered:Connect(pickup)
    model.Parent = workspace
    --- 弹起结束后交给客户端播放待拾取表现，服务端保留固定拾取位置。
    drop.Task = task.spawn(function()
        local root = model.PrimaryPart
        drop.Tween = TweenService:Create(root, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {CFrame = drop.Landing + Vector3.new(0, 4, 0)})
        drop.Tween:Play()
        task.wait(0.25)
        if self._round ~= drop.Round or self._dropNodes[dropId] ~= drop then
            return
        end
        drop.Tween = TweenService:Create(root, TweenInfo.new(0.35, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
            {CFrame = drop.Landing})
        drop.Tween:Play()
        task.wait(0.35)
        if self._round ~= drop.Round or self._dropNodes[dropId] ~= drop then
            return
        end
        drop.Task = nil
        drop.Tween:Destroy()
        drop.Tween = nil
        root.CFrame = drop.Landing
        model:SetAttribute("DropRestPivot", model:GetPivot())
        model:SetAttribute("DropVisualStartedAt", workspace:GetServerTimeNow())
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
    local stored = self:GetTable(Fields.StoredLoot)
    local capacity = RockLevel.StoredLootCapacity
    if #stored + #loot >= capacity then
        drop.Picking = false
        self:GetPlayerObject():ShowLocalizedTips("Loot.InventoryFull", {capacity = capacity})
        return
    end
    if #loot >= self:GetLootCapacity() then
        drop.Picking = false
        self:GetPlayerObject():ShowLocalizedTips("Loot.BagFull")
        return
    end
    local entry = {
        TemplateName = drop.Template.Name,
        ItemId = drop.ItemId,
        DisplayModelId = drop.DisplayModelId,
        Price = drop.Price,
        IsLucky = drop.IsLucky,
        LuckRate = drop.LuckRate,
        DisplayName = English:FormatByKey(CollectibleText.GetNameKey(drop.Template.Name)),
    }
    if not self:RequireComponent("FSRewardComp"):AddRewards({{Type = "Loot", Count = 1, Data = entry}}) then
        drop.Picking = false
        return
    end
    self:RemoveDrop(dropId)
    local nameKey = CollectibleText.GetNameKey(drop.Template.Name)
    self:RequireComponent("SActivityComp"):RecordPickup()
    self:RequireComponent("TutorialGuide"):RecordPickup()
    if drop.IsLucky then
        self:GetPlayerObject():ShowLocalizedTips("Loot.LuckyPickedUp",
            {itemKey = nameKey, rate = GameUtility.NumberToText(drop.LuckRate)})
    else
        self:GetPlayerObject():ShowLocalizedTips("Loot.PickedUp", {itemKey = nameKey})
    end
end

--- 仅在基地转存玩家 KV 并激活图鉴，不创建背包道具；满存储保留随身战利品。
function Component:DepositLoot()
    local loot = self:GetTable(Fields.RockLoot)
    if #loot == 0 then
        return
    end
    local stored = self:GetTable(Fields.StoredLoot)
    local deposited = 0
    local entries = self:GetTable(Fields.CollectionEntries)
    local collectionChanged = false
    while #loot > 0 and #stored < RockLevel.StoredLootCapacity do
        local entry = loot[1]
        table.insert(stored, entry)
        if Collection.Activate(entries, entry.ItemId) then
            collectionChanged = true
        end
        table.remove(loot, 1)
        deposited += 1
    end
    if deposited > 0 then
        self:SetTable(Fields.StoredLoot, stored)
        self:SetTable(Fields.RockLoot, loot)
        if collectionChanged then
            self:SetTable(Fields.CollectionEntries, entries)
        end
        self:GetPlayerObject():ShowLocalizedTips("Loot.Deposited", {count = deposited})
        self:PublishEvent("Tutorial.Deposited")
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
    if not drop then
        return
    end
    self._dropNodes[dropId] = nil
    if self._dropByCell[drop.CellKey] == dropId then
        self._dropByCell[drop.CellKey] = nil
    end
    if drop.Connection then
        drop.Connection:Disconnect()
    end
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
    for dropId in pairs(self._dropNodes) do
        self:RemoveDrop(dropId)
    end
    self._dropNodes = {}
    self._dropByCell = {}
end

--- 出生、重生、切换装备或尺寸偏好时重新构建武器，避免累计缩放。
--- @param humanoid Humanoid 当前存活角色的 Humanoid。
function Component:EquipPickaxe(humanoid)
    if self._pickaxe then
        self._pickaxe:Destroy()
    end
    local config = Weapon.GetEquippedConfig(self:GetTable(Fields.WeaponData))
    local template = self._weaponTemplates[config.ToolId]
    local model
    self._giantPickaxe = self:GetTable(Fields.Settings).giantPickaxe
    self._pickaxe, model = RockWeaponTool.Build(template, self._giantPickaxe)
    local handle = self._pickaxe.Handle
    self._weaponId = config.ToolId
    local nameKey = "Weapon.Name." .. tostring(config.ToolId)
    self._pickaxe.Name = English:FormatByKey(nameKey)
    self._pickaxe.ToolTip = self._pickaxe.Name
    self._pickaxe.TextureId = "rbxassetid://" .. config.Img
    self._pickaxe:SetAttribute("WeaponId", config.ToolId)
    self._pickaxe:SetAttribute("StarterPickaxe", true)
    self._pickaxe:SetAttribute("DisplayNameKey", nameKey)
    local headCFrame, modelSize = model:GetBoundingBox()
    local headY = headCFrame.Position.Y + modelSize.Y * 0.5 - 0.2 - handle.Position.Y
    local start = Instance.new("Attachment")
    start.Name = "SwingTrailStart"
    start.Position = Vector3.new(-modelSize.X * 0.35, headY, 0)
    start.Parent = handle
    local finish = Instance.new("Attachment")
    finish.Name = "SwingTrailEnd"
    finish.Position = Vector3.new(modelSize.X * 0.35, headY, 0)
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
    -- 出生时卡片等待镐子入栏后再同步，避免卡片先占原生快捷栏的第一格。
    self:RequireComponent("FSInventoryComp"):SyncTools()
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

--- 服务端处理掉落、角色与入库，进入当前关时预生成当前关及下一关；死亡期间仍回收掉落。
function Component:Tick()
    local now = workspace:GetServerTimeNow()
    for dropId, drop in pairs(self._dropNodes) do
        if now >= drop.ExpiresAt then
            self:RemoveDrop(dropId)
        end
    end
    local retryTime = os.clock()
    for key, retryAfter in pairs(self._dropRetryAfter) do
        if retryTime >= retryAfter then
            local areaIndex, cellIndex = string.match(key, "^(%d+):(%d+)$")
            local area = self._areas[tonumber(areaIndex)]
            local cell = tonumber(cellIndex)
            local areaState = self._areaStates[area.Index]
            self:CreateDrop(key, area, cell, areaState.Contents[cell], self._round)
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
        if self._character then
            self._attackRecords = {}
            self._nextHit = 0
            self._hitInterval = nil
            self:PublishEvent("RockAttackReset")
        end
        self._character = character
        self:EquipPickaxe(humanoid)
    elseif self._weaponId ~= Weapon.GetEquippedConfig(self:GetTable(Fields.WeaponData)).ToolId
        or self._giantPickaxe ~= self:GetTable(Fields.Settings).giantPickaxe then
        self:EquipPickaxe(humanoid)
    end
    local firstArea = self._areas[1]
    local inSafeArea = position.Z < firstArea.MinZ - 8
        and position.Z >= firstArea.MinZ - 100
        and math.abs(position.X) <= 72
        and math.abs(position.Y - firstArea.FloorY) < 16
    if self._inSafeArea == nil then
        self._inSafeArea = inSafeArea
    end
    if inSafeArea then
        if not self._inSafeArea then
            self:RestoreRocks()
        end
        self._inSafeArea = true
        self:DepositLoot()
    else
        self._inSafeArea = false
        self._depositFull = false
        for _, area in ipairs(self._areas) do
            if position.X >= area.MinX and position.X < area.MinX + area.Columns * RockLevel.CellSize
                and position.Z >= area.MinZ and position.Z < area.MinZ + area.Rows * RockLevel.CellSize
                and math.abs(position.Y - area.FloorY) < 12 then
                self:InitializeArea(area)
                local nextArea = self._areas[area.Index + 1]
                if nextArea then
                    self:InitializeArea(nextArea)
                end
                break
            end
        end
    end
end

--- 仅允许关卡内存活角色回到基地，入库与轮次重置仍由原有基地位置检查处理。
function Component:ReturnHome()
    local character = self:GetPlayerCharacter()
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not self._areas or not root or not humanoid or humanoid.Health <= 0
        or not RockLevel.IsInArea(self._areas, root.Position) then
        return
    end
    local spawn = FXLoader:Workspace("Decorations/World1Decorations/SpawnLocation")
    character:PivotTo(spawn.CFrame * CFrame.new(0, spawn.Size.Y / 2 + humanoid.HipHeight + root.Size.Y / 2, 0))
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
end

--- 离服释放掉落、关卡任务和镐子，清空个人区域与命中记录。
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
    self._dropRetryAfter = {}
    self._dropAttempts = {}
    self._dropFailureWarned = {}
    self._areaStates = {}
    self._areaDefinitions = {}
end

--- 析构也释放任务，覆盖初始化中断的生命周期。
function Component:Dtor()
    self:OnPlayerLogout()
    Component.Super.Dtor(self)
end

return Component
