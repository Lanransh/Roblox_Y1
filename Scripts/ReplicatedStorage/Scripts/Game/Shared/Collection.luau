local GameConfig = _G.GameConfig
local GameEnum = _G.GameEnum
local Rules = GameConfig.CommonConfig.CollectionData
local Collection = {}

--- 仅按稳定 ID 返回已开放的收藏品配置，与武器、光环一样按配置顺序限制。
--- @param itemId number 收藏品配置 ID。
--- @return table? 已开放的收藏品配置，未知或未开放时返回 nil。
function Collection.GetConfig(itemId)
    for index, item in ipairs(GameConfig.ItemData) do
        if index > GameEnum.ItemLimit then
            break
        end
        if item.Id == itemId then
            return item
        end
    end
    return nil
end

--- 只统计已开放且已入库的道具种类，普通和幸运版本共用道具 ID。
--- @param entries table 持久图鉴字典，字符串道具 ID 对应 true。
--- @return number 已激活的不同道具数量。
function Collection.GetCount(entries)
    local count = 0
    for index, item in ipairs(GameConfig.ItemData) do
        if index > GameEnum.ItemLimit then
            break
        end
        if entries[tostring(item.Id)] == true then
            count += 1
        end
    end
    return count
end

--- 每满一个收集门槛增加一档训练收益，不对未满门槛的数量插值。
--- @param entries table 持久图鉴字典。
--- @return number 包含基础收益的训练倍率。
function Collection.GetTrainingRate(entries)
    return 1 + math.floor(Collection.GetCount(entries) / Rules.UnlockCount) * Rules.TrainingRate
end

--- 成功入库后登记已开放的稳定道具 ID；重复、未开放或缺失 ID 不增加种类。
--- @param entries table 本次入库修改的图鉴副本。
--- @param itemId number? 入库战利品的配置 ID，旧存档可能缺失。
--- @return boolean 是否首次激活已开放的配置道具。
function Collection.Activate(entries, itemId)
    if type(itemId) ~= "number" or not Collection.GetConfig(itemId) then
        return false
    end
    local key = tostring(itemId)
    if entries[key] == true then
        return false
    end
    entries[key] = true
    return true
end

return Collection
