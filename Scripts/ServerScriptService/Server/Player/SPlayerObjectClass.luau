local FX, FS = _G.FX, _G.FS
local FXLoader = FX.Loader
local Rebirth = FXLoader:RequireShared("Scripts/Game/Shared/Rebirth")
local RockLevel = FXLoader:RequireShared("Scripts/Game/Shared/RockLevel")
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
                tool:SetAttribute("DisplayNameKey", "Welfare.Item." .. item.itemId)

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

--- 登录续接时清除上一会话的坐标，等待本轮进入首关后重新锁定。
--- @param eventName string 框架或业务发布的引导事件。
function Guide:OnGuideEvent(eventName)
    Guide.Super.OnGuideEvent(self, eventName)
    if eventName == "Tutorial.Login" and self:IsLootStep(1) then
        local data = self:GetGuideData()
        data.target.cell = nil
        data.target.position = nil
        self:SetGuideData(data)
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

--- 成功拾取后记录持久次数，重登与回基地不会清零。
function Guide:RecordPickup()
    if not self:IsLootStep(1) then
        return
    end
    local data = self:GetGuideData()
    data.collected = (data.collected or 0) + 1
    self:SetGuideData(data)
    if data.collected >= 2 then
        self:PublishEvent("Tutorial.Collected")
    end
end

--- 只由完成扣库存与到账的出售业务通知，客户端不能直接完成引导。
function Guide:RecordSale()
    self:PublishEvent("Tutorial.Sold")
    self:GrantTrainingDiamonds()
end

--- 出售引导完成后赠送训练倍率所需钻石；领取状态随引导存档，重复事件和重登不重复发放。
function Guide:GrantTrainingDiamonds()
    if not self:IsLootStep(4) then
        return
    end
    local data = self:GetGuideData()
    if data.trainingDiamondsGranted then
        return
    end
    assert(self:RequireComponent("FSRewardComp"):AddRewards({{Type = "Money", Currency = "Diamonds", Count = 30}}),
        "Tutorial diamonds failed")
    data.trainingDiamondsGranted = true
    self:SetGuideData(data)
end

--- 关卡外先指向首关入口，进入后再锁定本轮道具；不触发生成或修改奖励。
--- @param rock table 玩家的服务端关卡组件。
--- @param position Vector3 服务端角色当前位置。
--- @return string? 当前轮次内锁定的石头格号。
--- @return Vector3? 首关入口或道具所在格子的固定世界坐标。
function Guide:GetLootTarget(rock, position)
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
    local now = workspace:GetServerTimeNow()
    for cell, content in pairs(state.Contents) do
        local key = "1:" .. cell
        local dropId = rock._dropByCell[key]
        local drop = dropId and rock._dropNodes[dropId]
        if not rock._claimed[key] or (drop and drop.ExpiresAt > now and drop.Model.Parent == workspace) then
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

--- 使用权威存档恢复提前完成的操作，末尾提醒按配置计时推进，不新增跳步协议。
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
    if self:IsLootStep(4) and self:GetTable(PlayerDataConfig.CurrencyShopData).trainingLevel > 0 then
        -- 同一个无让出执行的回调先推进再奖励，重复检查不会再次发钱。
        self:PublishEvent("Tutorial.Rate")
        assert(self:RequireComponent("FSRewardComp"):AddRewards({{Type = "Money", Currency = "Money", Count = 100}}))
    end
    if self:IsLootStep(5) then
        local weapon = FXLoader:RequireShared("Scripts/Game/Shared/Weapon")
        local equipped = weapon.GetEquippedConfig(self:GetTable(PlayerDataConfig.WeaponData))
        if equipped.TrainingRate > weapon.GetConfig(101).TrainingRate then
            self:PublishEvent("Tutorial.Weapon")
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
    data = self:GetGuideData()
    first = data.guideMap.FirstLootGuide
    if not first or first.state ~= "Finished" then
        return
    end
    if self:GetNumber(PlayerDataConfig.Money) >= _G.GameConfig.AuraConfig[1].Price then
        self:PublishEvent("Tutorial.AuraAffordable")
    end
    if self:GetTable(PlayerDataConfig.AuraData).equippedId ~= 0 then
        self:PublishEvent("Tutorial.AuraEntered")
        return
    end
    local trigger = FXLoader:Find(workspace, "Decorations/World1Decorations/BlueHut/Trigger")
    local character = self:GetPlayerCharacter()
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if trigger and root then
        local position = trigger.CFrame:PointToObjectSpace(root.Position)
        if math.abs(position.X) <= trigger.Size.X / 2 and math.abs(position.Z) <= trigger.Size.Z / 2
            and math.abs(position.Y) <= trigger.Size.Y / 2 + 3 then
            self:PublishEvent("Tutorial.AuraEntered")
        end
    end
end

local Player = FX.Class("SPlayerObjectClass", "FSPlayerObjectClass")

--- @param id number Roblox UserId。
function Player:Ctor(id)
    Player.Super.Ctor(self, id)
    self:AddComponent("SInventoryCompClass")
    self:AddComponent("FSRewardCompClass")
    self:AddComponent("SActivityCompClass")
    self:AddComponent("SGiftCompClass")
    self:AddComponent("STutorialGuideCompClass")
    self:AddComponent("SRockLevelCompClass")
    self:AddComponent("SMiscCompClass")
    self:AddComponent("SLootSellCompClass")
    self:AddComponent("SAuraCompClass")
    self:AddComponent("SWeaponCompClass")
    self:AddComponent("SGMCompClass")
end

--- 服务端仅发送文案 Key 和业务参数，不按服务器语言提前生成提示。
--- @param key string 本地文案表中的提示 Key。
--- @param arguments table? 提示模板参数。
--- @param duration number? 显示时长，单位为秒。
function Player:ShowLocalizedTips(key, arguments, duration)
    FX.Network:SendMsgToClient(self:GetPlayerId(), "S2C_ShowLocalizedTips", key, arguments, duration)
end

--- 为旧存档补入历史等级、离线福利与默认开启的武器巨大化偏好。
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
end

--- 未拥有初始武器时通过统一奖励组件发放；钻石由出售引导完成后赠送。
function Player:OnPlayerLogin()
    local rewards = {}
    local weapon = PlayerDataConfig.WeaponData
    local kv = FS.PlayerKVDataManager:GetKVTable(self:GetPlayerId(), weapon.KVTable)
    if kv:GetDeep(weapon.Key .. ".RealData") == nil then
        table.insert(rewards, {Type = "Unlock", Kind = "Weapon", Id = 101, Count = 1})
    end
    assert(self:RequireComponent("FSRewardComp"):AddRewards(rewards), "Initial rewards failed")
    Player.Super.OnPlayerLogin(self)
    self:PublishEvent("Tutorial.Login")
    self:PublishEvent("PlayerLogin")
end

return Player
