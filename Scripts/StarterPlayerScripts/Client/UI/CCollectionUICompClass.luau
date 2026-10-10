local FX = _G.FX
local FXLoader = FX.Loader
FXLoader:RequireFromParent(script, "Generated/CCollectionView")
local Fields = _G.PlayerDataConfig
local GameConfig = _G.GameConfig
local Collection = FXLoader:RequireShared("Scripts/Game/Shared/Collection")
local CollectibleText = FXLoader:RequireShared("Scripts/Game/Shared/CollectibleText")
local Component = FX.Class("CCollectionUICompClass", "CCollectionView")

--- 返回主界面打开图鉴时使用的组件名称。
--- @return string 图鉴业务组件名。
function Component:GetCompName()
    return "CCollectionUIComp"
end

--- 复用导出的节点和关闭事件，只订阅服务端持久图鉴。
function Component:OnReady()
    Component.Super.OnReady(self)
    self.Root.ResetOnSpawn = false
    self.Root.DisplayOrder = 10
    self._commonUI = self:GetPlayerObject():RequireComponent("FCCommonUIComp")
    self._commonUI:RegisterTrainingClickModal(self.Root)
    self._localization = self._commonUI.Localization
    self._hint = FXLoader:Here(self.Root, "PopupPanelImg/SummaryImg/HintTxt")
    self._boostLabel = FXLoader:Here(self.Root, "PopupPanelImg/SummaryImg/BoostLabelTxt")
    self._hint.Text = "Store items at your base to unlock them."
    self._boostLabel.Text = "Total Training Bonus"
    self._hint.AutoLocalize = true
    self._boostLabel.AutoLocalize = true
    self.Count.AutoLocalize = false
    self.Rule.AutoLocalize = false
    self.Boost.AutoLocalize = false
    -- 父类保留按项力量字段；实际门槛和训练文案由本业务 Render 提供。
    self.Config = {items = {}, strengthPerEntryPercent = 0}
    for itemId, item in pairs(GameConfig.ItemData) do
        table.insert(self.Config.items, {
            id = tostring(item.Id), itemId = item.Id,
            name = "", icon = "rbxassetid://" .. tostring(item.IconId),
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
        item.name = self._localization:FormatByKey(CollectibleText.GetNameKey(config.DisplayModelId))
        self.State.entries[item.id] = {active = entries[item.id] == true}
    end
    self.State.totalStrengthPercent = (Collection.GetTrainingRate(entries) - 1) * 100
    self:RefreshUI()
end

--- 复用生成列表，显示真实训练门槛；未激活图标使用道具原图的黑色剪影。
--- @param state table 服务端记录派生的完整展示状态。
function Component:Render(state)
    Component.Super.Render(self, state)
    local rules = GameConfig.CommonConfig.CollectionData
    self.Rule.Text = self._localization:FormatByKey("Collection.Rule", {
        count = rules.UnlockCount, percent = rules.TrainingRate * 100,
    })
    self.Count.Text = self._localization:FormatByKey("Collection.Count", {
        count = Collection.GetCount(self:GetTable(Fields.CollectionEntries)), total = #self.Config.items,
    })
    for index, item in ipairs(self.Config.items) do
        local row = self.Rows[item.id]
        row.name.AutoLocalize = false
        row.icon.Image = item.icon
        row.icon.ImageColor3 = state.entries[item.id].active and Color3.new(1, 1, 1) or Color3.new(0, 0, 0)
        row.icon.ImageTransparency = 0
        -- 只保留原图轮廓，不显示问号或占位图的实色底块。
        row.icon.BackgroundTransparency = 1
        row.unknown.Visible = false
    end
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
