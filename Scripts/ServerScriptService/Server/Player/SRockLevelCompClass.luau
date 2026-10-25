local FX = _G.FX
local FXLoader = FX.Loader
local Text = FXLoader:RequireShared("Scripts/Game/Shared/Text")
local TranslationTexts = Text.Define("Loot", {
    InventoryFull = "Storage limit reached: {capacity:int} items.",
    BagFull = "Your backpack is full. Return to your base to store your loot.",
    LuckyPickedUp = "Picked up lucky {item} (×{rate})!",
    PickedUp = "Picked up {item}!",
    Deposited = "Loot stored: {count:int}",
    DepositFull = "Your storage is full.",
})

local Fields = _G.PlayerDataConfig
local HttpService = game:GetService("HttpService")
local RockLevel = require(game:GetService("ReplicatedStorage").Scripts.Game.Shared.RockLevel)
local Collectible = FXLoader:RequireShared("Scripts/Game/Shared/RockCollectible")
local ToyRoller = FXLoader:RequireFromParent(script, "ToyRoller")
local RockWeaponTool = require(script.Parent.RockWeaponTool)
local GameConfig = _G.GameConfig
local GameEnum = _G.GameEnum
local GameUtility = FXLoader:RequireShared("Scripts/Game/Shared/GameUtility")
local Collection = FXLoader:RequireShared("Scripts/Game/Shared/Collection")
local Weapon = FXLoader:RequireShared("Scripts/Game/Shared/Weapon")
local InstancePath = FXLoader:RequireShared("Scripts/Game/Shared/InstancePath")
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

--- 读档后仅缓存已开放武器模板、校验奖池模型、同步地板颜色并启动位置检查。
function Component:OnPlayerLogin()
    self._weaponTemplates = {}
    for index, config in ipairs(GameConfig.ToolConfig) do
        if index > GameEnum.WeaponLimit then
            break
        end
        self._weaponTemplates[config.ToolId] = InstancePath.Wait(config.ModelId)
    end
    self._areas = RockLevel.GetAreas()
    self:PrepareAreaDefinitions()
    local grounds = {}
    for worldIndex, world in ipairs(RockLevel.Worlds) do
        local root = FXLoader:Workspace("BlockMeshs/" .. world.Name .. "Root")
        grounds[worldIndex] = root:FindFirstChild("GuanQia", true)
    end
    for index, area in ipairs(self._areas) do
        local ground = grounds[area.World]:WaitForChild("Ground" .. area.LocalIndex)
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
            definition.Error = "missing AreaConfig for area"
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
                local pool, averagePrice, areaLuck = ToyRoller.CreatePool(area.World, area.LocalIndex)
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
    self._round += 1
    self._nextHit = 0
    self._hitInterval = nil
    self:PublishEvent("RockRoundReset")
    self:SendRockRound()
end

--- 回放轮次及个人已击破格号，并补发本人仍有效的掉落；客户端可区分新轮和同轮状态恢复。
function Component:SendRockRound()
    FX.Network:SendMsgToClient(self:GetPlayerId(), "S2C_RockReset", self._round, self:GetBrokenCells())
    local now = workspace:GetServerTimeNow()
    for dropId, drop in pairs(self._dropNodes) do
        if now < drop.ExpiresAt then
            self:SendDrop(dropId, drop)
        end
    end
end

--- 命中记录只累计服务端认可的实际伤害；确认击破时直接结算掉落，再回传剩余血量。
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
        return true, 0
    end
    local character = self:GetPlayerCharacter()
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if character ~= self._character or not root or not humanoid or humanoid.Health <= 0 or not self._pickaxe
        or self._pickaxe.Parent ~= character or math.abs(root.Position.Y - area.FloorY) >= 12 then
        return false
    end
    local level = self:GetNumber(Fields.RockTrainingLevel)
    local damage = RockLevel.GetDamage(level, area.Index, self:GetNumber(Fields.RockTrainingValue))
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
    if self:GetRecordedDamage(key) >= RockLevel.HP[area.Index] then
        self:RequestDrop(key, round)
        return true, 0
    end
    local record = self._attackRecords[key]
    if not record then
        record = {Damage = 0, Character = character}
        self._attackRecords[key] = record
    end
    record.Damage += damage
    self:PublishEvent("RockTrainingHit")
    local health = math.max(0, RockLevel.HP[area.Index] - self:GetRecordedDamage(key))
    if health == 0 then
        self:RequestDrop(key, round)
    end
    return true, health
end

--- 累计每次命中时的服务端伤害，不用后续增长的力量回算历史命中。
--- @param key string 已校验的石头格号。
--- @return number 有效命中记录能够证明的累计伤害。
function Component:GetRecordedDamage(key)
    local record = self._attackRecords[key]
    return record and record.Damage or 0
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
        or self:GetRecordedDamage(key) < RockLevel.HP[area.Index] then
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
    if self._dropByCell[key] then
        return
    end
    self:CreateDrop(key, area, cell, result, round)
end

--- 把已登记掉落的数据发给拥有者，由客户端本地生成模型、HUD 和拾取提示。
--- @param dropId string 服务端掉落 ID。
--- @param drop table 服务端登记的掉落数据。
function Component:SendDrop(dropId, drop)
    FX.Network:SendMsgToClient(self:GetPlayerId(), "S2C_SpawnRockDrop", {
        DropId = dropId,
        DisplayModelId = drop.DisplayModelId,
        PreviewModelIds = drop.PreviewModelIds,
        NameSource = GameConfig.ItemData[drop.ItemId].Name,
        Quality = drop.Quality,
        Price = drop.Price,
        IsLucky = drop.IsLucky,
        LuckRate = drop.LuckRate,
        GroundPosition = drop.Position,
        ExpiresAt = drop.ExpiresAt,
    })
end

--- 创建已通过击破校验的固定奖励，只把掉落数据和落点发给拥有者，由客户端本地生成表现。
--- 幸运掉落由客户端 HUD 图标和品质倍率共同标识。
--- @param key string 已击破的石头格号。
--- @param area table 奖励所属区域。
--- @param cell number 区域内格号。
--- @param result table 本轮预生成且已揭露的奖励。
--- @param round number 击破所属轮次。
function Component:CreateDrop(key, area, cell, result, round)
    if round ~= self._round or self._claimed[key] or self._dropByCell[key] then
        return
    end

    local dropId = HttpService:GenerateGUID(false)
    local now = workspace:GetServerTimeNow()
    local position = Vector3.new(area.MinX + ((cell - 1) % area.Columns + 0.5) * RockLevel.CellSize,
        area.FloorY, area.MinZ + (math.floor((cell - 1) / area.Columns) + 0.5) * RockLevel.CellSize)
    local previewModelIds = {}
    for index, reward in ipairs(self._areaDefinitions[area.Index].Pool) do
        previewModelIds[index] = reward.DisplayModelId
    end
    local expiresAt = now + Collectible.DropRevealDuration + Collectible.DropLifetime
    self._claimed[key] = true
    self._dropNodes[dropId] = {
        CellKey = key,
        Round = round,
        ExpiresAt = expiresAt,
        ReadyAt = now + Collectible.DropRevealDuration + 0.6,
        PreviewModelIds = previewModelIds,
        Position = position,
        Quality = result.Quality,
        Price = result.Price,
        Template = result.Template,
        ItemId = result.ItemId,
        DisplayModelId = result.DisplayModelId,
        IsLucky = result.IsLucky,
        LuckRate = result.LuckRate,
    }
    self._dropByCell[key] = dropId
    self:SendDrop(dropId, self._dropNodes[dropId])
end

--- 按服务端掉落 ID 校验有效期、存活、距离和容量，仅使用记录中的真实奖励。
--- @param dropId string 当前玩家的服务器掉落 ID。
--- @return boolean 是否成功拾取并发奖。
function Component:PickupDrop(dropId)
    if type(dropId) ~= "string" then
        return false
    end
    local now = workspace:GetServerTimeNow()
    local drop = self._dropNodes[dropId]
    if not drop then
        return false
    end
    if now >= drop.ExpiresAt then
        self:RemoveDrop(dropId)
        return false
    end
    if drop.Picking or now < drop.ReadyAt then
        return false
    end
    local character = self:GetPlayerCharacter()
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0
        or (root.Position - drop.Position).Magnitude > Collectible.PickupDistance then
        return false
    end
    drop.Picking = true
    local loot = self:GetTable(Fields.RockLoot)
    local stored = self:GetTable(Fields.StoredLoot)
    local capacity = RockLevel.StoredLootCapacity
    if #stored + #loot >= capacity then
        drop.Picking = false
        self:GetPlayerObject():ShowLocalizedTips(TranslationTexts.InventoryFull, {capacity = capacity})
        return false
    end
    if #loot >= self:GetLootCapacity() then
        drop.Picking = false
        self:GetPlayerObject():ShowLocalizedTips(TranslationTexts.BagFull)
        return false
    end
    local entry = {
        TemplateName = drop.Template.Name,
        ItemId = drop.ItemId,
        DisplayModelId = drop.DisplayModelId,
        Price = drop.Price,
        IsLucky = drop.IsLucky,
        LuckRate = drop.LuckRate,
        DisplayName = GameConfig.ItemData[drop.ItemId].Name,
    }
    if not self:RequireComponent("FSRewardComp"):AddRewards({{Type = "Loot", Count = 1, Data = entry}}) then
        drop.Picking = false
        return false
    end
    self:RemoveDrop(dropId)
    local nameSource = GameConfig.ItemData[drop.ItemId].Name
    self:RequireComponent("SActivityComp"):RecordPickup()
    self:RequireComponent("TutorialGuide"):RecordPickup()
    if drop.IsLucky then
        self:GetPlayerObject():ShowLocalizedTips(TranslationTexts.LuckyPickedUp,
            {itemSource = nameSource, rate = GameUtility.NumberToText(drop.LuckRate)})
    else
        self:GetPlayerObject():ShowLocalizedTips(TranslationTexts.PickedUp, {itemSource = nameSource})
    end
    return true
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
        self:GetPlayerObject():ShowLocalizedTips(TranslationTexts.Deposited, {count = deposited})
        self:PublishEvent("Tutorial.Deposited")
    end
    if #loot > 0 and not self._depositFull then
        self:GetPlayerObject():ShowLocalizedTips(TranslationTexts.DepositFull)
    end
    self._depositFull = #loot > 0
end

--- 先注销掉落 ID，再通知拥有者移除本地表现，避免超时或重复拾取后继续领奖。
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
    FX.Network:SendMsgToClient(self:GetPlayerId(), "S2C_RemoveRockDrop", dropId)
end

--- 结束个人关卡轮次时注销全部掉落 ID，并通知拥有者清理本地表现。
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
    local nameSource = config.Name
    self._pickaxe.Name = nameSource
    self._pickaxe.ToolTip = self._pickaxe.Name
    self._pickaxe.TextureId = "rbxassetid://" .. config.Img
    self._pickaxe:SetAttribute("WeaponId", config.ToolId)
    self._pickaxe:SetAttribute("StarterPickaxe", true)
    self._pickaxe:SetAttribute("DisplayNameSource", nameSource)
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
    local inSafeArea = false
    for worldIndex, world in ipairs(RockLevel.Worlds) do
        local firstArea = self._areas[world.Stages[1]]
        if position.Z < firstArea.MinZ - 8
            and position.Z >= firstArea.MinZ - 100
            and math.abs(position.X - firstArea.Node.Position.X) <= 72
            and math.abs(position.Y - firstArea.FloorY) < 16 then
            inSafeArea = true
            break
        end
    end
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
                if nextArea and nextArea.World == area.World then
                    self:InitializeArea(nextArea)
                end
                break
            end
        end
    end
end

--- 仅允许关卡内存活角色回到该关卡所属世界的基地，并同步当前世界；入库与轮次重置由基地位置检查处理。
function Component:ReturnHome()
    local character = self:GetPlayerCharacter()
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not self._areas or not root or not humanoid or humanoid.Health <= 0 then
        return
    end
    local inArea, area = RockLevel.IsInArea(self._areas, root.Position)
    if not inArea then
        return
    end
    local spawn = FXLoader:Workspace(_G.GameEnum.WorldTransferConfig[area.World].SpawnPath)
    character:PivotTo(spawn.CFrame * CFrame.new(0, spawn.Size.Y / 2 + humanoid.HipHeight + root.Size.Y / 2, 0))
    self:SetNumber(Fields.WorldIndex, area.World)
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
    self._areaStates = {}
    self._areaDefinitions = {}
end

--- 析构也释放任务，覆盖初始化中断的生命周期。
function Component:Dtor()
    self:OnPlayerLogout()
    Component.Super.Dtor(self)
end

return Component
