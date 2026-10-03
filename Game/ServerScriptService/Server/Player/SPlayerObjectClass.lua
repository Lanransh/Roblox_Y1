local FX, FS = _G.FX, _G.FS
local GameConfig = _G.GameConfig
local PlayerDataConfig, ItemConfig = _G.PlayerDataConfig, _G.ItemConfig
local TutorialGuideConfig = _G.TutorialGuideConfig
local RunService = game:GetService("RunService")
local Inventory = FX.Class("SInventoryCompClass", "FSInventoryCompClass")

function Inventory:Ctor(owner)
    Inventory.Super.Ctor(self, owner)
    self._tools = {}
end

--- @return table 背包容量与持久字段。
function Inventory:GetConfig()
    local config = _G.Provider:GetNativeBackpackConfig()
    return {
        storeTableVarEnum = PlayerDataConfig.Inventory,
        shortcutCapacity = config.ShortcutEnabled and 10 or 0,
        inventoryCapacity = config.InventoryCapacity,
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

    -- 试玩时给空存档发测试道具；正式服务器只显示已保存或业务发放的物品。
    if RunService:IsStudio() and next(self:GetData()) == nil then
        self:AddItems({ FS.ItemClass.New(1001, 1), FS.ItemClass.New(1002, 3) })
    end
    self:SyncTools()
end

function Inventory:OnAllChanged()
    self:SyncTools()
end

--- 将框架道具数据投影为原生 Tool；快捷栏关闭时清理本组件持有的 Tool，保留道具数据。
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
        if not config or not config.ToolShape or (tool.Parent ~= backpack and tool.Parent ~= player.Character)
            or tool:GetAttribute("FrameworkItemId") ~= item.itemId then
            tool:Destroy()
            self._tools[gridIndex] = nil
        end
    end

    for gridIndex = 1, self:GetTotalCapacity() do
        local item = data[gridIndex]
        local config = item and ItemConfig.Data[item.itemId]
        if config and config.ToolShape then
            local tool = self._tools[gridIndex]
            if not tool then
                tool = Instance.new("Tool")
                tool.CanBeDropped = false
                tool.ToolTip = config.Name
                tool:SetAttribute("FrameworkGridIndex", gridIndex)
                tool:SetAttribute("FrameworkItemId", item.itemId)

                local handle = Instance.new("Part")
                handle.Name = "Handle"
                handle.Shape = Enum.PartType[config.ToolShape]
                handle.Size = Vector3.new(0.9, 0.9, 0.9)
                handle.Color = config.ToolColor
                handle.CanCollide = false
                handle.Massless = true
                handle.Parent = tool

                self._tools[gridIndex] = tool
                tool.Parent = backpack
            end
            tool.Name = item.stackCount > 1 and string.format("%s x%d", config.Name, item.stackCount) or config.Name
        end
    end
end

--- 快捷栏关闭时拒绝手持使用入口；其他请求仍需校验归属及装备状态。
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
    self:AddComponent("STutorialGuideCompClass")
    self:AddComponent("SRockLevelCompClass")
end

--- @param version number 已保存的数据版本；新增迁移在此顺序执行。
function Player:MigrateData(version)
    assert(version <= GameConfig.DataVersion, "Saved data is newer than this server")
    self:SetNumber(PlayerDataConfig.DataVersion, GameConfig.DataVersion)
end

--- 先同步初始数据，再向玩家组件发布登录事件。
function Player:OnPlayerLogin()
    Player.Super.OnPlayerLogin(self)
    self:PublishEvent("PlayerLogin")
end

return Player
