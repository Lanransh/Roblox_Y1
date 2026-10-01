local root = script.Parent
require(root.FSEvents)
require(root.PlayerKV.FSPlayerKVDataManager)
require(root.Ranking.FSRankingManager)
require(root.FSObjectManagerClass)
for _, name in ipairs({
    "FSPlayerObjectClass",
    "FSPlayerCompClass",
    "FSInventoryCompClass",
    "FSRewardCompClass",
    "FSTutorialGuideCompClass",
    "FSPlayerObjectManagerClass",
}) do
    require(root.Player:WaitForChild(name))
end

require(root.SItemClass)
require(root.Modules.FSRankingServiceClass)
return _G.FS
