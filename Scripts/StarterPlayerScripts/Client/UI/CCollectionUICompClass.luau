local FX = _G.FX
local FXLoader = FX.Loader
FXLoader:RequireFromParent(script, "Generated/CCollectionView")
local Fields = _G.PlayerDataConfig
local GameConfig = _G.GameConfig
local GameEnum = _G.GameEnum
local Collection = FXLoader:RequireShared("Scripts/Game/Shared/Collection")
local GameUtility = FXLoader:RequireShared("Scripts/Game/Shared/GameUtility")
local Component = FX.Class("CCollectionUICompClass", "CCollectionView")

--- 返回主界面打开图鉴时使用的组件名称。
--- @return string 图鉴业务组件名。
function Component:GetCompName()
    return "CCollectionUIComp"
end

--- 复用导出的节点和关闭事件，只展示已开放的收藏品并订阅服务端持久图鉴。
function Component:OnReady()
    Component.Super.OnReady(self)
    self.Root.ResetOnSpawn = false
    self.Root.DisplayOrder = 10
    self._commonUI = self:GetPlayerObject():RequireComponent("FCCommonUIComp")
    self._commonUI:RegisterTrainingClickModal(self.Root)
    self._localization = self._commonUI.Localization
    local rules = GameConfig.CommonConfig.CollectionData
    self.Config = {items = {}, strengthPerEntryPercent = rules.TrainingRate * 100,
        unlockCount = rules.UnlockCount, lockedSilhouette = true}
    for index, item in ipairs(GameConfig.ItemData) do
        if index > GameEnum.ItemLimit then
            break
        end
        table.insert(self.Config.items, {
            id = tostring(item.Id), itemId = item.Id,
            name = "", icon = "rbxassetid://" .. item.IconId,
        })
    end
    --- 按稳定道具 ID 排序，不依赖配置字典的遍历顺序。
    --- @param left table 左侧图鉴配置。
    --- @param right table 右侧图鉴配置。
    --- @return boolean 左侧是否排列在右侧之前。
    table.sort(self.Config.items, function(left, right)
        return left.itemId < right.itemId
    end)
    self.State = {open = false, entries = {}, totalStrengthPercent = 0}
    self:Hide()
    self:TrackConnection(self._localization.Changed:Connect(function()
        self:RefreshCollection()
    end))
    self:BindUIData()
end

--- 监听会立即回放已加载的图鉴，不从客户端背包自行激活。
function Component:BindUIData()
    self:WatchDataChanged(Fields.CollectionEntries, self.RefreshCollection, self)
end

--- 提供展示类完整状态；图鉴只以配置 ID 合并，不区分幸运倍率。
function Component:RefreshCollection()
    local entries = self:GetTable(Fields.CollectionEntries)
    for index, item in ipairs(self.Config.items) do
        local config = GameConfig.ItemData[item.itemId]
        item.name = config.Name
        self.State.entries[item.id] = {active = entries[item.id] == true}
    end
    self.State.totalStrengthPercent = (Collection.GetTrainingRate(entries) - 1) * 100
    self:RefreshUI()
end

--- 图鉴训练百分比沿用项目通用数值格式。
--- @param value number 原始训练百分比。
--- @return string 展示数值。
function Component:FormatNumber(value)
    return GameUtility.NumberToText(value)
end

--- 与父类显隐保持一致，打开只刷新状态，不重复连接按钮。
function Component:OnShow()
    self.State.open = true
    Component.Super.OnShow(self)
end

--- 隐藏状态参与后续数据刷新，避免入库同步重新打开已关闭窗口。
function Component:OnHide()
    self.State.open = false
end

--- 展示类只发送关闭动作，不提供客户端激活或领取入口。
--- @param action string 展示类的 Close 动作。
--- @param payload table 展示类关闭动作的空参数，不参与业务。
function Component:OnUIAction(action, payload)
    assert(action == "Close", "Unsupported collection action: " .. tostring(action))
    self:Hide()
end

return Component
