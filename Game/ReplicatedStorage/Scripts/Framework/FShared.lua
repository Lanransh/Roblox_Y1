local root = script.Parent:WaitForChild("Shared")
local core = root:WaitForChild("Core")
for _, name in ipairs({ "FXLoader", "FXTable", "FXClass", "FXLog", "FXTask", "FXTime", "FXMath", "FXJson" }) do
    require(core:WaitForChild(name))
end

require(root:WaitForChild("FXUtility"))
require(core:WaitForChild("FXNetwork"))
for _, name in ipairs({ "FXObjectBaseClass", "FXCompBaseClass", "FXModelAnimationCompClass" }) do
    require(root:WaitForChild("Object"):WaitForChild(name))
end

for _, name in ipairs({ "FXSyncManager", "FXDelayedInvokeClass", "FXItemProcessor", "FXBuyProcessor" }) do
    require(root:WaitForChild(name))
end

return _G.FX
