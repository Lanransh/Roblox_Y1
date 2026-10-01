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
    "FCInventoryCompClass",
    "FCRankingUICompClass",
    "FCTutorialGuideCompClass",
}) do
    require(root.Player:WaitForChild(name))
end
for _, name in ipairs({ "ShopPageBaseClass", "ShopItemBaseClass", "FCShopUICompClass" }) do
    require(root.Shop:WaitForChild(name))
end
for _, name in ipairs({ "FCDragObjectClass", "FCTouchObjectClass", "FCHoldUIObjectClass", "FCKeyObjectClass" }) do
    require(root:WaitForChild(name))
end
return _G.FC
