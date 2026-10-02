local Framework = game:GetService("ReplicatedStorage"):WaitForChild("Scripts"):WaitForChild("Framework")
require(Framework:WaitForChild("FrameworkInit"))
local Player = script.Parent.Player
local Service = script.Parent.Service

require(Player.SPlayerObjectClass)
local ManagerClass = require(Player.SPlayerObjectManagerClass)
local RankingClass = require(Service.SRankingServiceClass)

_G.SRankingService = RankingClass.New()
_G.SPlayerObjectManager = ManagerClass.New()
