local FX, FS = _G.FX, _G.FS
local Config = require(game.ReplicatedStorage.Shared.Config.FrameworkConfig)
local Inventory = FX.Class("SInventoryCompClass", "FSInventoryCompClass")
--- @return table 背包容量与持久字段。
function Inventory:GetConfig()
    return {
        storeTableVarEnum = Config.PlayerData.Inventory,
        shortcutCapacity = Config.ShortcutCapacity,
        inventoryCapacity = Config.InventoryCapacity,
    }
end
--- 登录时全量发送背包，后续变化走增量协议。
function Inventory:OnPlayerLogin()
    self:SendInventoryDataToClient()
end
local Guide = FX.Class("STutorialGuideCompClass", "FSTutorialGuideCompClass")
--- @return string 玩家组件名。
function Guide:GetCompName()
    return "TutorialGuide"
end
--- @return table 项目引导 DSL。
function Guide:GetGuideConfig()
    return Config.GuideGroups
end
--- @return table 引导数据字段。
function Guide:GetGuideStorage()
    return Config.PlayerData.Guide
end
local Player = FX.Class("SPlayerObjectClass", "FSPlayerObjectClass")
--- @param id number Roblox UserId。
function Player:Ctor(id)
    Player.Super.Ctor(self, id)
    self:AddComponent("SInventoryCompClass")
    self:AddComponent("FSRewardCompClass")
    self:AddComponent("STutorialGuideCompClass")
end
--- @param version number 已保存的数据版本；新增迁移在此顺序执行。
function Player:MigrateData(version)
    assert(version <= Config.DataVersion, "Saved data is newer than this server")
    self:SetNumber(Config.PlayerData.DataVersion, Config.DataVersion)
end
--- 先同步初始数据，再向玩家组件发布登录事件。
function Player:OnPlayerLogin()
    Player.Super.OnPlayerLogin(self)
    self:PublishEvent("PlayerLogin")
end
return Player
