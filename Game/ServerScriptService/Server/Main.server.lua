local Framework = game:GetService("ReplicatedStorage"):WaitForChild("Framework")
require(Framework.FrameworkInit)
local FS = require(script.Parent.Framework.FServer)
local Player = script.Parent.Player
local Service = script.Parent.Service

require(Player.SPlayerObjectClass)
local ManagerClass = require(Player.SPlayerObjectManagerClass)
local RankingClass = require(Service.SRankingServiceClass)

_G.SPlayerObjectManager = ManagerClass.New()
FS.PlayerManager = _G.SPlayerObjectManager
FS.PlayerKVDataManager:Init()
FS.RankingManager:Init()
require(script.Parent.Framework.Modules.FSShopService):Init()
require(script.Parent.Framework.Modules.FSFriendService):Init()
_G.SRankingService = RankingClass.New()
_G.SPlayerObjectManager:Start()

print("[Roblox_Y1] 服务端框架已启动")
