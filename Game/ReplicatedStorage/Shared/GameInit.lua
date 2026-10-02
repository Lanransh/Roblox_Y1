-- 两端共同入口：先加载配置与当前端框架，再加载依赖框架的项目公共模块。
-- 权威购买/道具处理器由服务端 Main 单独加载。
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Framework = ReplicatedStorage:WaitForChild("Scripts"):WaitForChild("Framework")
require(Framework:WaitForChild("FrameworkInit"))

local Config = script.Parent:WaitForChild("Config")
return {
    Config = require(Config:WaitForChild("FrameworkConfig")),
    GameEnum = require(Config:WaitForChild("GameEnum")),
    GameUtility = require(script.Parent:WaitForChild("GameUtility")),
    GameFormula = require(script.Parent:WaitForChild("GameFormula")),
    GameFunction = require(script.Parent:WaitForChild("GameFunction")),
}
