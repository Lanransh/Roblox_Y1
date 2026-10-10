-- 两端共同入口：独立配置、项目 Provider、框架、依赖框架的公共模块依次加载。
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Configs = script.Parent:WaitForChild("Game"):WaitForChild("Configs")
local SharedGameConfig = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"):WaitForChild("GameConfig")
_G.GameConfig = require(SharedGameConfig)
-- 玩法配置可能重新导出；项目名称、奖励映射和开发者名单由现有项目配置维护。
local RuntimeConfig = require(Configs:WaitForChild("GameConfig"))
_G.GameConfig.GameName = RuntimeConfig.GameName
_G.GameConfig.RewardCurrencies = RuntimeConfig.RewardCurrencies
_G.GameConfig.DeveloperUserIds = RuntimeConfig.DeveloperUserIds
_G.ItemConfig = require(Configs:WaitForChild("ItemConfig"))
_G.GoodsConfig = require(Configs:WaitForChild("GoodsConfig"))
_G.ActivityConfig = require(Configs:WaitForChild("ActivityConfig"))
_G.ShopConfig = require(Configs:WaitForChild("ShopConfig"))
_G.NumericalConfig = require(Configs:WaitForChild("NumericalConfig"))

local GameShared = script.Parent:WaitForChild("Game"):WaitForChild("Shared")
_G.NetworkProtocol = require(GameShared:WaitForChild("NetworkProtocol"))
_G.PlayerDataConfig = require(GameShared:WaitForChild("PlayerDataConfig"))
_G.ServerDataConfig = require(GameShared:WaitForChild("ServerDataConfig"))
_G.RankingDataConfig = require(GameShared:WaitForChild("RankingDataConfig"))
_G.TutorialGuideConfig = require(GameShared:WaitForChild("TutorialGuideConfig"))
_G.GameEnum = require(GameShared:WaitForChild("GameEnum"))

require(script.Parent:WaitForChild("SetupProvider"))
require(script.Parent:WaitForChild("Framework"):WaitForChild("FrameworkInit"))

local FX = _G.FX
local FXLoader = FX.Loader

return {
    GameEnum = _G.GameEnum,
    GameUtility = FXLoader:Require(GameShared, "GameUtility"),
    GameFormula = FXLoader:Require(GameShared, "GameFormula"),
    GameFunction = FXLoader:Require(GameShared, "GameFunction"),
}
