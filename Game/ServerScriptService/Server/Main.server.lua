local Scripts = game:GetService("ReplicatedStorage"):WaitForChild("Scripts")
require(Scripts:WaitForChild("GameInit"))
local Handlers = script.Parent.Handlers
_G.Provider.ItemHandlers = require(Handlers.ItemHandlers)
_G.Provider.BuyHandlers = require(Handlers.BuyHandlers)
local Player = script.Parent.Player
local Service = script.Parent.Service

require(Player.SRockLevelCompClass)
require(Player.SPlayerObjectClass)
local ManagerClass = require(Player.SPlayerObjectManagerClass)
local RankingClass = require(Service.SRankingServiceClass)

_G.SRankingService = RankingClass.New()
_G.SPlayerObjectManager = ManagerClass.New()
