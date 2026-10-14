local FX, FS = _G.FX, _G.FS
local FXLoader = FX.Loader
local Rebirth = FXLoader:RequireShared("Scripts/Game/Shared/Rebirth")
local RockLevel = FXLoader:RequireShared("Scripts/Game/Shared/RockLevel")
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

                if config.ToolShape then
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

local Player = FX.Class("SPlayerObjectClass", "FSPlayerObjectClass")

--- @param id number Roblox UserId。
function Player:Ctor(id)
    Player.Super.Ctor(self, id)
    self:AddComponent("SInventoryCompClass")
    self:AddComponent("FSRewardCompClass")
    self:AddComponent("SActivityCompClass")
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

--- 为旧存档补入历史等级与离线福利结构；无离服时间的旧档不追溯奖励。
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
end

--- 未写入过的初始赠送通过统一奖励组件发放；已有余额和武器档案不重复奖励。
function Player:OnPlayerLogin()
    local rewards = {}
    local diamonds = PlayerDataConfig.Diamonds
    local kv = FS.PlayerKVDataManager:GetKVTable(self:GetPlayerId(), diamonds.KVTable)
    if kv:GetDeep(diamonds.Key .. ".RealData") == nil then
        table.insert(rewards, {Type = "Money", Currency = "Diamonds", Count = 500})
    end
    local weapon = PlayerDataConfig.WeaponData
    if kv:GetDeep(weapon.Key .. ".RealData") == nil then
        table.insert(rewards, {Type = "Unlock", Kind = "Weapon", Id = 101, Count = 1})
    end
    assert(self:RequireComponent("FSRewardComp"):AddRewards(rewards), "Initial rewards failed")
    Player.Super.OnPlayerLogin(self)
    self:PublishEvent("PlayerLogin")
end

return Player
