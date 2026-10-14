local Scripts = game:GetService("ReplicatedStorage"):WaitForChild("Scripts")
require(Scripts:WaitForChild("GameInit"))
local Handlers = script.Parent.Handlers
_G.Provider.ItemHandlers = require(Handlers.ItemHandlers)
_G.Provider.BuyHandlers = require(Handlers.BuyHandlers)
_G.Provider.RewardHandlers = require(Handlers.RewardHandlers)
local Player = script.Parent.Player
local Service = script.Parent.Service

require(Player.SRockLevelCompClass)
require(Player.SMiscCompClass)
require(Player.SLootSellCompClass)
require(Player.SAuraCompClass)
require(Player.SWeaponCompClass)
require(Player.SGMCompClass)
require(Player.SActivityCompClass)
require(Player.SGiftCompClass)
require(Player.SPlayerObjectClass)
local ManagerClass = require(Player.SPlayerObjectManagerClass)
local RankingClass = require(Service.SRankingServiceClass)
local DogNpcClass = require(Service.SDogNpcServiceClass)
local PurchaseReceiptService = require(Service.SPurchaseReceiptService)

_G.SRankingService = RankingClass.New()
_G.SPlayerObjectManager = ManagerClass.New()
_G.SGiftDropService = require(Service.SGiftDropService)
_G.SGiftDropService.Init()
PurchaseReceiptService.Init()
_G.SDogNpcService = DogNpcClass.New()
