local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local framework = ReplicatedStorage:WaitForChild("Framework")
require(framework:WaitForChild("FrameworkInit"))
require(script.Parent.Framework.FClient)
local FC, FX = _G.FC, _G.FX
local PlayerClass = require(script.Parent.Player.CPlayerObjectClass)

FC.PlayerObject = PlayerClass.New(Players.LocalPlayer.UserId)

-- 在此添加项目客户端组件；UI 子类提供自己的原生节点和模板。
FX.Network:RegServerMsgCallback("S2C_ShowTips", function(message, duration)
    FC.PlayerObject:PublishEvent("ShowTips", message, duration)
end)

FX.Network:RegServerMsgCallback("S2C_ShowDeveloperBuyUI", function(productId)
    FC.PlayerObject:RequireComponent("FCCommonUIComp"):ShowDeveloperBuyUI(productId)
end)

local network = framework:WaitForChild("Network")
while not network:GetAttribute("ServerReady") do
    network:GetAttributeChangedSignal("ServerReady"):Wait()
end

FX.Network:SendMsgToServer("C2S_ClientReady")
