local FX, FS = _G.FX, _G.FS
local PlayerDataConfig, ItemConfig = _G.PlayerDataConfig, _G.ItemConfig
local TutorialGuideConfig = _G.TutorialGuideConfig
local Collectible = require(script.Parent.RockCollectible)
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

--- 将背包投影为原生 Tool；收藏品保留独立模型和价格，换格后重建不匹配的显示。
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
        if not config or (not config.ToolShape and item.itemId ~= Collectible.ItemId)
            or (tool.Parent ~= backpack and tool.Parent ~= player.Character)
            or tool:GetAttribute("FrameworkItemId") ~= item.itemId
            or (item.itemId == Collectible.ItemId and (not item.extraData
                or tool:GetAttribute("CollectibleTemplate") ~= item.extraData.TemplateName
                or tool:GetAttribute("Price") ~= item.extraData.Price
                or tool:GetAttribute("ItemId") ~= item.extraData.ItemId
                or tool:GetAttribute("DisplayModelId") ~= item.extraData.DisplayModelId
                or tool:GetAttribute("IsLucky") ~= (item.extraData.IsLucky == true)
                or tool:GetAttribute("LuckRate") ~= (item.extraData.LuckRate or 1))) then
            tool:Destroy()
            self._tools[gridIndex] = nil
        end
    end

    for gridIndex = 1, self:GetTotalCapacity() do
        local item = data[gridIndex]
        local config = item and ItemConfig.Data[item.itemId]
        if config and (config.ToolShape or item.itemId == Collectible.ItemId) then
            local tool = self._tools[gridIndex]
            if not tool then
                if item.itemId == Collectible.ItemId then
                    tool = Collectible.CreateTool(item.extraData)
                    if not tool then
                        continue
                    end
                else
                    tool = Instance.new("Tool")
                    tool.CanBeDropped = false
                    tool.ToolTip = config.Name

                    local handle = Instance.new("Part")
                    handle.Name = "Handle"
                    handle.Shape = Enum.PartType[config.ToolShape]
                    handle.Size = Vector3.new(0.9, 0.9, 0.9)
                    handle.Color = config.ToolColor
                    handle.CanCollide = false
                    handle.Massless = true
                    handle.Parent = tool
                end

                tool:SetAttribute("FrameworkGridIndex", gridIndex)
                tool:SetAttribute("FrameworkItemId", item.itemId)

                self._tools[gridIndex] = tool
                tool.Parent = backpack
            end
            if item.itemId ~= Collectible.ItemId then
                tool.Name = item.stackCount > 1 and string.format("%s x%d", config.Name, item.stackCount) or config.Name
            end
        end
    end
end

--- 校验快捷栏、归属和装备状态；收藏品只供手持展示，不执行使用消耗。
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
    if item.itemId == Collectible.ItemId then
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
    self:AddComponent("STutorialGuideCompClass")
    self:AddComponent("SRockLevelCompClass")
    self:AddComponent("SMiscCompClass")
    self:AddComponent("SLootSellCompClass")
    self:AddComponent("SAuraCompClass")
end

--- 服务端仅发送文案 Key 和业务参数，不按服务器语言提前生成提示。
--- @param key string 本地文案表中的提示 Key。
--- @param arguments table? 提示模板参数。
--- @param duration number? 显示时长，单位为秒。
function Player:ShowLocalizedTips(key, arguments, duration)
    FX.Network:SendMsgToClient(self:GetPlayerId(), "S2C_ShowLocalizedTips", key, arguments, duration)
end

--- 项目不使用存档版本检查或迁移，保留框架要求的入口以完成玩家初始化。
--- @param version number 框架传入的旧存档字段，本项目不使用。
function Player:MigrateData(version)
end

--- 先同步初始数据，再向玩家组件发布登录事件。
function Player:OnPlayerLogin()
    Player.Super.OnPlayerLogin(self)
    self:PublishEvent("PlayerLogin")
end

return Player
