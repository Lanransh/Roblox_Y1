local FX, FS = _G.FX, _G.FS
local FXLoader = FX.Loader
local Text = FX.Text
local Rebirth = FXLoader:RequireShared("Scripts/Game/Shared/Rebirth")
local RockLevel = FXLoader:RequireShared("Scripts/Game/Shared/RockLevel")
local TutorialPurchase = FXLoader:RequireShared("Scripts/Game/Shared/TutorialPurchase")
local ItemToolVisual = FXLoader:RequireFromParent(script, "ItemToolVisual")
local PlayerDataConfig, ItemConfig = _G.PlayerDataConfig, _G.ItemConfig
local TutorialGuideConfig = _G.TutorialGuideConfig
local Inventory = FX.Class("SInventoryCompClass", "FSInventoryCompClass")

function Inventory:Ctor(owner)
    Inventory.Super.Ctor(self, owner)
    self._tools = {}
end

--- 原生快捷栏与背包共用总容量，快捷栏格子不额外增加可持有道具数量。
--- @return table 背包容量与持久字段。
function Inventory:GetConfig()
    local config = _G.Provider:GetNativeBackpackConfig()
    local shortcutCapacity = config.ShortcutEnabled and math.min(10, config.InventoryCapacity) or 0
    return {
        storeTableVarEnum = PlayerDataConfig.Inventory,
        shortcutCapacity = shortcutCapacity,
        inventoryCapacity = config.InventoryCapacity - shortcutCapacity,
    }
end

--- 登录后从存档创建原生 Tool，后续由数据变化监听保持同步。
function Inventory:OnPlayerLogin()
    local player = self:GetPlayerNode()
    self:WatchDataChanged(PlayerDataConfig.Inventory, self.SyncTools, self)
    self:TrackConnection(player.CharacterAdded:Connect(function(character)
        task.defer(function()
            if self._tools and player.Character == character then
                self:SyncTools()
            end
        end)
    end))
    self:TrackConnection(player.CharacterAppearanceLoaded:Connect(function(character)
        if self._tools and player.Character == character then
            self:SyncTools()
        end
    end))

    self:SyncTools()
end

function Inventory:OnAllChanged()
    self:SyncTools()
end

--- 当前卡片的消耗、奖励和权益统一回滚；禁止 yield，避免恢复时覆盖其他请求。
--- @param grid number 已验证归属的背包格号。
--- @param useCount number 本次使用的整数数量。
--- @return boolean 道具效果是否完整完成。
function Inventory:UseItem(grid, useCount)
    if self._usingItem then
        return false
    end
    local allowed, context = self:CanUseItem(grid, useCount)
    if not allowed then
        return false
    end
    local player = self:GetPlayerObject()
    local fields = {
        PlayerDataConfig.Inventory, PlayerDataConfig.Diamonds,
        PlayerDataConfig.WelfareData, PlayerDataConfig.WelfareState,
        PlayerDataConfig.RockTrainingValue, PlayerDataConfig.RockTrainingLevel,
        PlayerDataConfig.MaxTrainingLevel, PlayerDataConfig.RockLootCapacityBoost,
    }
    local original = {}
    for index, field in ipairs(fields) do
        original[index] = player:_GetData(field)
    end
    local activity = player:RequireComponent("SActivityComp")
    local lastTime = activity._lastTime
    self._usingItem = true
    --- 消耗与处理器放在同一个不让出执行的事务内，异常按失败回滚。
    --- @return boolean 消耗与效果是否完整成功。
    local thread = coroutine.create(function()
        if context.consumeCount > 0 and not self:RemoveItemFromGridId(grid, context.consumeCount) then
            return false
        end
        return context:Use()
    end)
    local ok, result = coroutine.resume(thread)
    local finished = coroutine.status(thread) == "dead"
    if not finished then
        task.cancel(thread)
    end
    local success = ok and finished and result == true
    if not success then
        for index, field in ipairs(fields) do
            player:_SetData(field, original[index], false)
        end
        activity._lastTime = lastTime
    end
    self._usingItem = nil
    if not success then
        player:RequireComponent("SMiscComp"):RefreshProgress()
    elseif context.itemDataConfig.HeldHandler == "Image" then
        FX.Network:SendMsgToClient(self:GetPlayerId(), "S2C_CardActivated", context.itemDataConfig.Id)
    end
    return success
end

--- 仅将普通框架道具投影为原生 Tool，展示信息读取 ItemConfig.Display，收藏品仍由 KV 保存。
function Inventory:SyncTools()
    local player = self:GetPlayerNode()
    local backpack = player and player:FindFirstChildOfClass("Backpack")
    if not backpack or not self._tools then
        return
    end

    if not _G.Provider:GetNativeBackpackConfig().ShortcutEnabled then
        for gridIndex, tool in pairs(self._tools) do
            tool:Destroy()
            self._tools[gridIndex] = nil
        end
        return
    end

    -- 原生快捷栏按 Tool 到达顺序分配空位，出生时先让镐子占据第一个位置。
    local character = player.Character
    local hasPickaxe = false
    for index, container in ipairs({backpack, character}) do
        for childIndex, node in ipairs(container:GetChildren()) do
            if node:IsA("Tool") and node:GetAttribute("StarterPickaxe") == true then
                hasPickaxe = true
                break
            end
        end
    end
    if not hasPickaxe then
        return
    end

    local data = self:GetData()
    for gridIndex, tool in pairs(self._tools) do
        local item = data[gridIndex]
        local config = item and ItemConfig.Data[item.itemId]
        if not config
            or (tool.Parent ~= backpack and tool.Parent ~= player.Character)
            or tool:GetAttribute("FrameworkItemId") ~= item.itemId then
            tool:Destroy()
            self._tools[gridIndex] = nil
        end
    end

    for gridIndex = 1, self:GetTotalCapacity() do
        local item = data[gridIndex]
        local config = item and ItemConfig.Data[item.itemId]
        if config then
            local display = ItemConfig.Display[item.itemId]
            local tool = self._tools[gridIndex]
            if not tool then
                tool = Instance.new("Tool")
                tool.CanBeDropped = false
                tool.TextureId = display.IconId or ""
                tool.ToolTip = display.Name

                if config.HeldHandler == "Image" then
                    ItemToolVisual.AddImageHandle(tool, display.IconId)
                elseif config.ToolShape then
                    local handle = Instance.new("Part")
                    handle.Name = "Handle"
                    handle.Shape = Enum.PartType[config.ToolShape]
                    handle.Size = Vector3.new(0.9, 0.9, 0.9)
                    handle.Color = config.ToolColor
                    handle.CanCollide = false
                    handle.Massless = true
                    handle.Parent = tool
                else
                    tool.RequiresHandle = false
                end

                tool:SetAttribute("FrameworkGridIndex", gridIndex)
                tool:SetAttribute("FrameworkItemId", item.itemId)
                tool:SetAttribute("DisplayNameSource", display.Name)

                self._tools[gridIndex] = tool
                tool.Parent = backpack
            end
            tool.Name = item.stackCount > 1 and string.format("%s x%d", display.Name, item.stackCount) or display.Name
        end
    end
end

--- 校验快捷栏、归属和装备状态，仅处理普通框架背包道具。
--- @param tool Instance 客户端请求使用的原生 Tool。
--- @return boolean 是否通过校验并使用成功。
function Inventory:ActivateTool(tool)
    if not _G.Provider:GetNativeBackpackConfig().ShortcutEnabled then
        return false
    end
    if typeof(tool) ~= "Instance" or not tool:IsA("Tool") then
        return false
    end
    local player = self:GetPlayerNode()
    local gridIndex = tool:GetAttribute("FrameworkGridIndex")
    local item = type(gridIndex) == "number" and self:GetGridData(gridIndex)
    if not player or tool.Parent ~= player.Character or self._tools[gridIndex] ~= tool
        or not item or item.itemId ~= tool:GetAttribute("FrameworkItemId") then
        return false
    end
    return self:UseItem(gridIndex, 1)
end

function Inventory:Dtor()
    for _, tool in pairs(self._tools) do
        tool:Destroy()
    end
    self._tools = nil
    Inventory.Super.Dtor(self)
end

local Guide = FX.Class("STutorialGuideCompClass", "FSTutorialGuideCompClass")

--- 所有权威进度提交共用此处，分析异常不能阻止引导推进。
--- @param guideData table 完整引导状态。
--- @return boolean 状态是否提交。
function Guide:SetGuideData(guideData)
    local result = Guide.Super.SetGuideData(self, guideData)
    local analytics = self:GetPlayerObject():GetComponent("SAnalyticsComp")
    if analytics then
        pcall(analytics.RecordGuide, analytics, guideData)
    end
    return result
end

--- @return string 玩家组件名。
function Guide:GetCompName()
    return "TutorialGuide"
end

--- @return table 项目引导 DSL。
function Guide:GetGuideConfig()
    return TutorialGuideConfig
end

--- @return table 引导数据字段。
function Guide:GetGuideStorage()
    return PlayerDataConfig.Guide
end

--- 登录续接时清除旧坐标；历史已拾取玩家须仍有随身或已存战利品才进入寄存步骤，避免空库存卡住。
--- @param eventName string 框架或业务发布的引导事件。
function Guide:OnGuideEvent(eventName)
    local data = self:GetGuideData()
    if data.activeGuideId == "World2Guide" then
        self:FinishGroup(data, "World2Guide")
    end
    Guide.Super.OnGuideEvent(self, eventName)
    if eventName == "Tutorial.Login" and self:IsLootStep(1) then
        local data = self:GetGuideData()
        data.target.cell = nil
        data.target.position = nil
        self:SetGuideData(data)
        if (data.collected or 0) >= 1 and (#self:GetTableView(PlayerDataConfig.RockLoot) > 0
            or #self:GetTableView(PlayerDataConfig.StoredLoot) > 0) then
            self:PublishEvent("Tutorial.Collected")
        end
    end
end

--- 仅匹配当前步骤，避免提前操作或重复回调重复发放奖励。
--- @param index number 首轮引导步骤。
--- @return boolean 当前是否处于该步骤。
function Guide:IsLootStep(index)
    local data = self:GetGuideData()
    return data.activeGuideId == "FirstLootGuide"
        and data.guideMap.FirstLootGuide.stepIndex == index
end

--- 成功拾取一件即完成收集引导，持久次数在重登与回基地时保留。
function Guide:RecordPickup()
    if not self:IsLootStep(1) then
        return
    end
    local data = self:GetGuideData()
    data.collected = (data.collected or 0) + 1
    self:SetGuideData(data)
    if data.collected >= 1 then
        self:PublishEvent("Tutorial.Collected")
    end
end

--- 只由完成扣库存与到账的出售业务通知，客户端不能直接完成引导。
function Guide:RecordSale()
    self:PublishEvent("Tutorial.Sold")
    self:GrantTrainingDiamonds()
end

--- 倍率购买成功后立即推进并赠送武器金币；每秒续接复用同一入口，步骤校验避免重复奖励。
function Guide:RecordTrainingRatePurchase()
    if not self:IsLootStep(4) or self:GetTableView(PlayerDataConfig.CurrencyShopData).trainingLevel <= 0 then
        return
    end
    -- 同一个无让出执行的回调先推进再奖励，重复检查不会再次发钱。
    self:PublishEvent("Tutorial.Rate")
    assert(self:RequireComponent("FSRewardComp"):AddRewards({{Type = "Money", Currency = "Money", Count = 100}}))
end

--- 出售引导完成后赠送 35 钻石用于首次倍率升级；领取状态随引导存档，重复事件和重登不重复发放。
function Guide:GrantTrainingDiamonds()
    if not self:IsLootStep(4) then
        return
    end
    local data = self:GetGuideData()
    if data.trainingDiamondsGranted then
        return
    end
    assert(self:RequireComponent("FSRewardComp"):AddRewards({{Type = "Money", Currency = "Diamonds", Count = 35}}),
        "Tutorial diamonds failed")
    data.trainingDiamondsGranted = true
    self:SetGuideData(data)
end

--- 收集时优先指向最近的有效掉落；尚无掉落时沿用首关入口和藏宝格引导。
--- @param rock table 玩家的服务端关卡组件。
--- @param position Vector3 服务端角色当前位置。
--- @return string? 当前轮次内有效掉落或锁定石头的格号。
--- @return Vector3? 有效掉落、首关入口或藏宝格的世界坐标。
function Guide:GetLootTarget(rock, position)
    local nearestDrop, nearestDistance = nil, math.huge
    local now = workspace:GetServerTimeNow()
    for dropId, drop in pairs(rock._dropNodes) do
        if drop.ExpiresAt > now then
            local distance = (drop.Position - position).Magnitude
            if distance < nearestDistance then
                nearestDrop, nearestDistance = drop, distance
            end
        end
    end
    if nearestDrop then
        return nearestDrop.CellKey, nearestDrop.Position + Vector3.new(0, 1, 0)
    end
    local area = rock._areas and rock._areas[1]
    local state = rock._areaStates[1]
    if not area then
        return nil, nil
    end
    local cellSize = RockLevel.CellSize
    if position.X < area.MinX or position.X >= area.MinX + area.Columns * cellSize
        or position.Z < area.MinZ or position.Z >= area.MinZ + area.Rows * cellSize
        or math.abs(position.Y - area.FloorY) >= 12 or not state then
        return nil, Vector3.new(area.MinX + area.Columns * cellSize / 2,
            area.FloorY + 1, area.MinZ + cellSize / 2)
    end
    if self._lootRound ~= rock._round then
        self._lootRound = rock._round
        self._lootOrigin = position
        self._lootCell = nil
    end
    local selected, target, distance = nil, nil, math.huge
    for cell, content in pairs(state.Contents) do
        local key = "1:" .. cell
        local dropId = rock._dropByCell[key]
        local drop = dropId and rock._dropNodes[dropId]
        if not rock._claimed[key] or (drop and drop.ExpiresAt > now) then
            local candidate = Vector3.new(area.MinX + ((cell - 1) % area.Columns + 0.5) * cellSize,
                area.FloorY + 1, area.MinZ + (math.floor((cell - 1) / area.Columns) + 0.5) * cellSize)
            if cell == self._lootCell then
                return key, candidate
            end
            local delta = (candidate - self._lootOrigin).Magnitude
            if delta < distance or (delta == distance and cell < selected) then
                selected, target, distance = cell, candidate, delta
            end
        end
    end
    self._lootCell = selected
    return selected and "1:" .. selected or nil, target
end

--- 达到世界二门槛后仅弹一次通用渐变提醒，复用已有进度记录避免重登重复。
function Guide:RefreshWorld2Reminder()
    local data = self:GetGuideData()
    local first = data.guideMap.FirstLootGuide
    local world2 = data.guideMap.World2Guide
    if not first or first.state ~= "Finished" or (world2 and world2.state == "Finished") then
        return
    end
    if self:GetNumber(PlayerDataConfig.MaxTrainingLevel) < _G.GameEnum.WorldTransferConfig[2].NeedTrainingLevel then
        return
    end
    data.guideMap.World2Guide = {state = "Finished", stepIndex = 0}
    data.world2ReminderUntil = workspace:GetServerTimeNow() + 5
    self:SetGuideData(data)
end

--- 按真实等级、训练场和商品价格判断路线；攒钱目标只统计已到账金币。
--- @param target table 当前步骤目标。
--- @param config table 固定路线配置。
--- @return boolean 是否已满足当前步骤。
function Guide:IsRebirthRouteStepComplete(target, config)
    if target.type == "Training" then
        return self:GetNumber(PlayerDataConfig.RockTrainingLevel) >= target.level
    elseif target.type == "Rebirth" then
        return self:GetNumber(PlayerDataConfig.RebirthCount) >= target.count
    elseif target.type == "TrainingField" then
        local current = _G.GameConfig.TrainingFieldData[self:GetNumber(PlayerDataConfig.TrainingFieldIndex)]
        local goal = _G.GameConfig.TrainingFieldData[target.fieldIndex]
        return current ~= nil and current.TrainingRate >= goal.TrainingRate
    end
    local data = self:GetTable(PlayerDataConfig[config.shopType .. "Data"])
    local goal, ownedGoal, isEquipped = TutorialPurchase.GetStatus(config, data)
    if target.type == "Weapon" or target.type == "Aura" then
        return isEquipped
    end
    if ownedGoal then
        return true
    end
    local money = self:GetNumber(PlayerDataConfig.Money)
    if money >= goal.Price then
        return true
    end
    if target.type == "Money" then
        return false
    end
    local carried = self:GetTable(PlayerDataConfig.RockLoot)
    local stored = self:GetTable(PlayerDataConfig.StoredLoot)
    if target.type == "Base" then
        return #carried == 0
    elseif target.type == "Sell" then
        return #stored == 0
    end
    local capacity = self:RequireComponent("SRockLevelComp"):GetLootCapacity()
    if #stored > 0 or #carried >= math.min(config.lootCount, capacity) then
        return true
    end
    local rate = Rebirth.GetMoneyRate(self:GetNumber(PlayerDataConfig.RebirthCount))
    for index, item in ipairs(carried) do
        money += math.floor(item.Price * rate)
    end
    return money >= goal.Price
end

--- 依次续接重生路线；镐子与光环共用攒钱循环，已可重生时优先重生。
--- @param groupId string 当前重生路线的配置与存档分组名。
function Guide:RefreshRebirthRoute(groupId)
    local config = TutorialGuideConfig[groupId]
    local data = self:GetGuideData()
    local previous = data.guideMap[config.previousGuideId]
    local route = data.guideMap[groupId]
    if not previous or previous.state ~= "Finished" or (route and route.state == "Finished") then
        return
    end
    if self:GetNumber(PlayerDataConfig.RebirthCount) >= config.completionRebirthCount then
        self:FinishGroup(data, groupId)
        return
    end
    self:TryStartGroup(config.startEvent)
    data = self:GetGuideData()
    local rebirthCount = self:GetNumber(PlayerDataConfig.RebirthCount)
    if data.activeGuideId == groupId
        and self:GetNumber(PlayerDataConfig.RockTrainingLevel) >= Rebirth.GetRequiredLevel(rebirthCount) then
        -- 已能重生就不再要求额外赚钱或买镐；下一次重生目标仍由配置中的步骤决定。
        for index, step in ipairs(config.steps) do
            if step.target.type == "Rebirth" and step.target.count == rebirthCount + 1 then
                if data.guideMap[groupId].stepIndex ~= index then
                    self:EnterGroupStep(data, groupId, config, index)
                end
                return
            end
        end
    end
    for attempt = 1, #config.steps do
        data = self:GetGuideData()
        if data.activeGuideId ~= groupId then
            return
        end
        local step = config.steps[data.guideMap[groupId].stepIndex]
        local reminderFinished = false
        if step.duration then
            local reminderId = groupId .. ":" .. data.guideMap[groupId].stepIndex
            if self._routeReminderId ~= reminderId then
                self._routeReminderId = reminderId
                self._routeReminderEnd = workspace:GetServerTimeNow() + step.duration
            end
            reminderFinished = workspace:GetServerTimeNow() >= self._routeReminderEnd
        end
        if self:GetNumber(PlayerDataConfig.RebirthCount) >= step.skipAtRebirthCount
            or reminderFinished or self:IsRebirthRouteStepComplete(step.target, config) then
            self:TryFinishCurrentStep(step.finishEvent)
        else
            if step.target.type == "Money" or step.target.type == "Weapon" or step.target.type == "Aura" then
                local shopData = self:GetTable(PlayerDataConfig[config.shopType .. "Data"])
                local goal, ownedGoal = TutorialPurchase.GetStatus(config, shopData)
                if not ownedGoal and self:GetNumber(PlayerDataConfig.Money) < goal.Price then
                    self:EnterGroupStep(data, groupId, config, config.collectStepIndex)
                end
            end
            return
        end
    end
end

--- 使用权威存档恢复提前完成的操作；基础教学后连续提示到第四次重生。
--- @param serverTime number 框架每秒回调时间。
function Guide:OnUpdate(serverTime)
    if self:IsLootStep(1) then
        local character = self:GetPlayerCharacter()
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if root and humanoid and humanoid.Health > 0 then
            local cell, position = self:GetLootTarget(self:RequireComponent("SRockLevelComp"), root.Position)
            local data = self:GetGuideData()
            local coordinates = position and {position.X, position.Y, position.Z} or nil
            local previous = data.target.position
            if data.target.cell ~= cell or (coordinates and (not previous
                or previous[1] ~= coordinates[1] or previous[2] ~= coordinates[2] or previous[3] ~= coordinates[3]))
                or (previous and not coordinates) then
                data.target.cell = cell
                data.target.position = coordinates
                self:SetGuideData(data)
            end
        end
    end
    self:GrantTrainingDiamonds()
    if self:IsLootStep(2) and #self:GetTable(PlayerDataConfig.StoredLoot) > 0 then
        self:PublishEvent("Tutorial.Deposited")
    end
    self:RecordTrainingRatePurchase()
    if self:IsLootStep(5) then
        local weapon = FXLoader:RequireShared("Scripts/Game/Shared/Weapon")
        local equipped = weapon.GetEquippedConfig(self:GetTable(PlayerDataConfig.WeaponData))
        if equipped.TrainingRate > weapon.GetConfig(101).TrainingRate then
            self:PublishEvent("Tutorial.Weapon")
        end
    end
    if self:IsLootStep(6) then
        local auraData = self:GetTable(PlayerDataConfig.AuraData)
        for auraId, owned in pairs(auraData.owned) do
            if owned == true then
                self:PublishEvent("Tutorial.Aura")
                break
            end
        end
    end
    local data = self:GetGuideData()
    local first = data.guideMap.FirstLootGuide
    if data.activeGuideId == "FirstLootGuide" then
        local step = TutorialGuideConfig.FirstLootGuide.steps[first.stepIndex]
        if step.duration then
            -- 每条提醒独立计时，不要求进入训练台或点击领奖；重登后重新完整展示。
            if self._reminderStep ~= first.stepIndex then
                self._reminderStep = first.stepIndex
                self._reminderEnd = serverTime + step.duration
            end
            if serverTime >= self._reminderEnd then
                self:PublishEvent(step.finishEvent)
                self._reminderStep = nil
                self._reminderEnd = nil
            end
        end
    end
    self:RefreshRebirthRoute("FirstRebirthGuide")
    self:RefreshRebirthRoute("SecondRebirthGuide")
    self:RefreshRebirthRoute("ThirdRebirthGuide")
    self:RefreshRebirthRoute("FourthRebirthGuide")
    self:RefreshWorld2Reminder()
end

local Player = FX.Class("SPlayerObjectClass", "FSPlayerObjectClass")

--- @param id number Roblox UserId。
function Player:Ctor(id)
    Player.Super.Ctor(self, id)
    self:AddComponent("SAnalyticsCompClass")
    self:AddComponent("SInventoryCompClass")
    self:AddComponent("FSRewardCompClass")
    self:AddComponent("SActivityCompClass")
    self:AddComponent("SGiftCompClass")
    self:AddComponent("STutorialGuideCompClass")
    self:AddComponent("SRockLevelCompClass")
    self:AddComponent("SMiscCompClass")
    self:AddComponent("STrainingRejoinCompClass")
    self:AddComponent("SLootSellCompClass")
    self:AddComponent("SAuraCompClass")
    self:AddComponent("SWeaponCompClass")
    self:AddComponent("SGMCompClass")
end

--- 服务端仅发送静态文案定义及参数，由客户端翻译，不提前拼接。
--- @param key table 静态 Key/Source 文案定义。
--- @param arguments table? 提示模板参数。
--- @param duration number? 显示时长，单位为秒。
function Player:ShowLocalizedTips(key, arguments, duration)
    Text.ValidateDefinition(key)
    key = {Key = key.Key, Source = key.Source}
    FX.Network:SendMsgToClient(self:GetPlayerId(), "S2C_ShowLocalizedTips", key, arguments, duration)
end

--- 补齐历史数据及设置，并将旧的合并重生路线迁移为重生一、重生二。
--- @param version number 框架传入的旧存档版本。
function Player:MigrateData(version)
    if version < 1 then
        local count = self:GetNumber(PlayerDataConfig.RebirthCount)
        local level = RockLevel.GetProgress(self:GetNumber(PlayerDataConfig.RockTrainingValue),
            Rebirth.GetRequiredLevel(count))
        local previousLevel = count > 0 and Rebirth.GetRequiredLevel(count - 1) or 1
        self:SetNumber(PlayerDataConfig.MaxTrainingLevel,
            math.max(self:GetNumber(PlayerDataConfig.MaxTrainingLevel), level, previousLevel))
        self:SetNumber(PlayerDataConfig.DataVersion, 1)
    end
    if version < 2 then
        local welfare = self:GetTable(PlayerDataConfig.WelfareData)
        welfare.lastSeenAt = 0
        welfare.offlineClaimDay = -1
        welfare.offline = {id = "", seconds = 0, training = 0}
        self:SetTable(PlayerDataConfig.WelfareData, welfare)
        self:SetNumber(PlayerDataConfig.DataVersion, 2)
    end
    if version < 3 then
        local settings = self:GetTable(PlayerDataConfig.Settings)
        if settings.giantPickaxe == nil then
            settings.giantPickaxe = true
            self:SetTable(PlayerDataConfig.Settings, settings)
        end
        self:SetNumber(PlayerDataConfig.DataVersion, 3)
    end
    if version < 4 then
        -- 引导目标是当前步骤的派生数据；从配置重建，移除历史存档中的字符串文案 Key。
        local guide = self:GetTable(PlayerDataConfig.Guide)
        local group = TutorialGuideConfig[guide.activeGuideId]
        local state = guide.guideMap and guide.guideMap[guide.activeGuideId]
        local step = group and state and group.steps[state.stepIndex]
        guide.target = step and table.clone(step.target) or {type = "None"}
        self:SetTable(PlayerDataConfig.Guide, guide)
        self:SetNumber(PlayerDataConfig.DataVersion, 4)
    end
    if version < 5 then
        local welfare = self:GetTable(PlayerDataConfig.WelfareData)
        if welfare.taskProgress and welfare.taskProgress.GetDog ~= nil then
            welfare.taskProgress.GetNoob = (welfare.taskProgress.GetNoob or 0) + welfare.taskProgress.GetDog
            welfare.taskProgress.GetDog = nil
            self:SetTable(PlayerDataConfig.WelfareData, welfare)
        end
        self:SetNumber(PlayerDataConfig.DataVersion, 5)
    end
    if version < 6 then
        local settings = self:GetTable(PlayerDataConfig.Settings)
        settings.renderDistance = PlayerDataConfig.Settings.DefVal.renderDistance
        self:SetTable(PlayerDataConfig.Settings, settings)
        self:SetNumber(PlayerDataConfig.DataVersion, 6)
    end
    if version < 7 then
        local guide = self:GetTable(PlayerDataConfig.Guide)
        local groups = guide.guideMap or {}
        guide.guideMap = groups
        local route = groups.SecondRebirthGuide
        if route and route.state == "Finished" then
            groups.FirstRebirthGuide = {state = "Finished", stepIndex = 0}
        elseif route and route.state == "Running" then
            if route.stepIndex <= 2 then
                groups.FirstRebirthGuide = route
                groups.SecondRebirthGuide = nil
                if guide.activeGuideId == "SecondRebirthGuide" then
                    guide.activeGuideId = "FirstRebirthGuide"
                end
            else
                groups.FirstRebirthGuide = {state = "Finished", stepIndex = 0}
                -- 旧采矿步骤先补回练；已经在寄存或出售的玩家继续当前动作。
                route.stepIndex = route.stepIndex == 3 and 1 or route.stepIndex - 1
            end
        end
        local first = groups.FirstLootGuide
        if first and first.state == "Running" and first.stepIndex == 9 then
            first.state, first.stepIndex = "Finished", 0
            if guide.activeGuideId == "FirstLootGuide" then
                guide.activeGuideId = ""
            end
        end
        local config = TutorialGuideConfig[guide.activeGuideId]
        local state = groups[guide.activeGuideId]
        local step = config and state and config.steps[state.stepIndex]
        guide.target = step and table.clone(step.target) or {type = "None"}
        self:SetTable(PlayerDataConfig.Guide, guide)
        self:SetNumber(PlayerDataConfig.DataVersion, 7)
    end
    if version < 8 then
        local guide = self:GetTable(PlayerDataConfig.Guide)
        local groups = guide.guideMap or {}
        local second = groups.SecondRebirthGuide
        if second and second.state == "Running" and second.stepIndex >= 5 then
            second.stepIndex += 1
        end
        local third = groups.ThirdRebirthGuide
        if third and third.state == "Running" then
            third.stepIndex = third.stepIndex == 1 and 1 or third.stepIndex + 5
        end
        local config = TutorialGuideConfig[guide.activeGuideId]
        local state = groups[guide.activeGuideId]
        local step = config and state and config.steps[state.stepIndex]
        guide.target = step and table.clone(step.target) or {type = "None"}
        self:SetTable(PlayerDataConfig.Guide, guide)
        self:SetNumber(PlayerDataConfig.DataVersion, 8)
    end
    if version < 9 then
        -- 已停在旧收尾提示的玩家直接完成基础教学，由现有路线逻辑衔接重生一。
        local guide = self:GetTable(PlayerDataConfig.Guide)
        local first = guide.guideMap and guide.guideMap.FirstLootGuide
        if first and first.state == "Running" and first.stepIndex > #TutorialGuideConfig.FirstLootGuide.steps then
            first.state, first.stepIndex = "Finished", 0
            if guide.activeGuideId == "FirstLootGuide" then
                guide.activeGuideId = ""
                guide.target = {type = "None"}
            end
            self:SetTable(PlayerDataConfig.Guide, guide)
        end
        self:SetNumber(PlayerDataConfig.DataVersion, 9)
    end
end

--- 以初始武器存档判断首次游玩并交给分析组件；钻石由出售引导完成后赠送。
--- @return nil
function Player:OnPlayerLogin()
    local rewards = {}
    local isFirstSession = not self:HasStoredData(PlayerDataConfig.WeaponData)
    if isFirstSession then
        table.insert(rewards, {Type = "Unlock", Kind = "Weapon", Id = 101, Count = 1})
    end
    assert(self:RequireComponent("FSRewardComp"):AddRewards(rewards), "Initial rewards failed")
    Player.Super.OnPlayerLogin(self)
    self:RequireComponent("SAnalyticsComp"):StartSession(isFirstSession)
    self:PublishEvent("Tutorial.Login")
    self:PublishEvent("PlayerLogin")
end

--- 分析快照先于任意业务组件登出清理，随后沿用框架离服保存。
function Player:OnPlayerLogout()
    self:RequireComponent("SAnalyticsComp"):EndSession()
    Player.Super.OnPlayerLogout(self)
end

return Player
