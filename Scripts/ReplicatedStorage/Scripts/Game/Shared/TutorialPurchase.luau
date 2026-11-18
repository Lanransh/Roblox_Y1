-- 重生引导的镐子、光环共用购买目标；价格与倍率只读正式商品配置。
local FX = _G.FX
local FXLoader = FX.Loader
local Weapon = FXLoader:RequireShared("Scripts/Game/Shared/Weapon")
local Aura = FXLoader:RequireShared("Scripts/Game/Shared/Aura")
local TutorialPurchase = {}

--- 两端共用目标价格与装备资格；三至五段逐级补买到目标武器，已有更强物品时不重复购买。
--- @param route table 含 shopType、itemId 的路线配置，purchaseStepIndex 标识逐级购买路线。
--- @param data table 对应商店的解锁字典与装备 ID。
--- @return table 正式目标商品配置。
--- @return table? 已拥有且达到目标倍率的最强商品。
--- @return boolean 是否已装备达到目标倍率的商品。
function TutorialPurchase.GetStatus(route, data)
    local isWeapon = route.shopType == "Weapon"
    local shop = isWeapon and Weapon or Aura
    local goal = shop.GetConfig(route.itemId)
    local items = isWeapon and _G.GameConfig.ToolConfig or _G.GameConfig.AuraConfig
    local limit = isWeapon and _G.GameEnum.WeaponLimit or _G.GameEnum.AuraLimit
    local idKey = isWeapon and "ToolId" or "AuraId"
    local equipped = shop.GetConfig(data.equippedId)
    if route.purchaseStepIndex then
        local strongestOwned
        for index, item in ipairs(items) do
            if index > limit then
                break
            end
            if data.owned[tostring(item[idKey])] == true
                and (not strongestOwned or item.TrainingRate > strongestOwned.TrainingRate) then
                strongestOwned = item
            end
        end
        if strongestOwned and strongestOwned.TrainingRate < goal.TrainingRate then
            if not equipped or data.owned[tostring(data.equippedId)] ~= true
                or equipped.TrainingRate < strongestOwned.TrainingRate then
                -- 先装备已拥有的升级，再判断下一把武器，避免拿着弱武器继续攒钱。
                goal = strongestOwned
            else
                for index, item in ipairs(items) do
                    if index > limit then
                        break
                    end
                    if item.TrainingRate > strongestOwned.TrainingRate and item.TrainingRate <= goal.TrainingRate then
                        goal = item
                        break
                    end
                end
            end
        end
    end
    local ownedGoal
    for index, item in ipairs(items) do
        if index > limit then
            break
        end
        if data.owned[tostring(item[idKey])] == true and item.TrainingRate >= goal.TrainingRate
            and (not ownedGoal or item.TrainingRate > ownedGoal.TrainingRate) then
            ownedGoal = item
        end
    end
    local isEquipped = equipped ~= nil and data.owned[tostring(data.equippedId)] == true
        and equipped.TrainingRate >= goal.TrainingRate
    return goal, ownedGoal, isEquipped
end

return TutorialPurchase
