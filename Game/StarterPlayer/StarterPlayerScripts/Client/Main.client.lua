local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local framework = ReplicatedStorage:WaitForChild("Framework")
require(framework:WaitForChild("FrameworkInit"))
require(script.Parent.Framework.FClient)
local FC, FX = _G.FC, _G.FX
FC.PlayerObject = FC.PlayerObjectClass.New(Players.LocalPlayer.UserId)
FC.PlayerObject:AddComponent("FCCommonUICompClass")
FC.PlayerObject:AddComponent("FCFriendCompClass")
-- 在此添加项目客户端组件；UI 子类提供自己的原生节点和模板。
FX.Network:RegServerMsgCallback("S2C_ShowTips", function(message, duration)
    FC.PlayerObject:PublishEvent("ShowTips", message, duration)
end)
local MarketplaceService = game:GetService("MarketplaceService")
--- @param productId number Roblox Developer Product ID。
--- @return boolean 是否通过服务端预检并发起购买提示。
function FC.ShowDeveloperBuyUI(productId)
    if not FX.Network:InvokeServer("C2S_BuyCheck", productId) then
        return false
    end
    MarketplaceService:PromptProductPurchase(Players.LocalPlayer, productId)
    return true
end
FX.Network:RegServerMsgCallback("S2C_ShowDeveloperBuyUI", function(productId)
    FC.ShowDeveloperBuyUI(productId)
end)
local network = framework:WaitForChild("Network")
while not network:GetAttribute("ServerReady") do
    network:GetAttributeChangedSignal("ServerReady"):Wait()
end
FX.Network:SendMsgToServer("C2S_ClientReady")
