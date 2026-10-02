local root = script.Parent
require(root.FCEvents)
require(root.FCUIAnim)
for _, name in ipairs({
    "FCPlayerObjectClass",
    "FCPlayerCompClass",
    "FCUICompClass",
    "FCCommonUICompClass",
    "FCFriendCompClass",
    "FCSoundCompClass",
    "FCRankingUICompClass",
    "FCTutorialGuideCompClass",
}) do
    require(root.Player:WaitForChild(name))
end

for _, name in ipairs({ "ShopPageBaseClass", "ShopItemBaseClass", "FCShopUICompClass" }) do
    require(root.Shop:WaitForChild(name))
end

for _, name in ipairs({ "FCHoldUIObjectClass", "FCKeyObjectClass" }) do
    require(root:WaitForChild(name))
end

local FX, FC = _G.FX, _G.FC

--- 玩家对象与组件创建完成后发起握手，等待服务端完成初始同步。
function FC.WaitServerReady()
    local network = game:GetService("ReplicatedStorage"):WaitForChild("Framework"):WaitForChild("Network")
    while not network:GetAttribute("ServerReady") do
        network:GetAttributeChangedSignal("ServerReady"):Wait()
    end

    FX.Network:SendMsgToServer("C2S_ClientReady")
    FC.Events.OnReady.Event:Wait()
end

return _G.FC
