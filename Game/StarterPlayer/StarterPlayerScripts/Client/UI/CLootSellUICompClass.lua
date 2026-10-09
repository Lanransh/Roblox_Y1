local FX = _G.FX
local FXLoader = FX.Loader
local RunService = game:GetService("RunService")
FXLoader:RequireFromParent(script, "Generated/CLootSellView")
local Fields = _G.PlayerDataConfig
local GameConfig = _G.GameConfig
local GameUtility = FXLoader:RequireShared("Scripts/Game/Shared/GameUtility")
local CollectibleText = FXLoader:RequireShared("Scripts/Game/Shared/CollectibleText")
local Rebirth = FXLoader:RequireShared("Scripts/Game/Shared/Rebirth")
local Component = FX.Class("CLootSellUICompClass", "CLootSellView")

--- 出售区域通过业务组件打开正式库存出售窗口。
--- @return string 玩家内协作名称。
function Component:GetCompName()
    return "CLootSellUIComp"
end

--- 复用导出的布局和按钮事件，不向生成脚本写入业务代码。
function Component:OnReady()
    Component.Super.OnReady(self)
    local root = self:GetRootNode()
    root.ResetOnSpawn = false
    root.DisplayOrder = 10
    self._commonUI = self:GetPlayerObject():RequireComponent("FCCommonUIComp")
    self._commonUI:RegisterTrainingClickModal(root)
    self._localization = self._commonUI.Localization
    self.Config = {capacity = _G.Provider:GetNativeBackpackConfig().InventoryCapacity, qualities = {}}
    -- 项目尚无品质颜色配置，保留设计模板配色，不虚构品质等级与颜色规则。
    local color = FXLoader:Here(self.Template, "QualityStripeImg").BackgroundColor3:ToHex()
    for itemId, config in pairs(GameConfig.ItemData) do
        self.Config.qualities[tostring(config.Quality)] = color
    end
    self.State = {isOpen = false, items = {}, pending = false}
    for index, label in ipairs({self.Total, self.CapacityTxt, self.StatusTxt}) do
        label.AutoLocalize = false
    end
    self.StatusTxt.Visible = false
    local labels = {
        ["TitleBox/TitleTxt"] = "SELL LOOT",
        ["PopupPanelImg/TotalImg/TotalLabelTxt"] = "Total Value",
        ["PopupPanelImg/TotalImg/SellAllBtn/ButtonTxt"] = "Sell All",
        ["PopupPanelImg/TotalImg/SellDoubleBtn/ButtonTxt"] = "Sell x2",
    }
    for path, text in pairs(labels) do
        local label = FXLoader:Here(root, path)
        label.Text = text
        label.AutoLocalize = true
    end
    self:Hide()
    self:TrackConnection(self._localization.Changed:Connect(function()
        self:RefreshLoot()
    end))
    self:BindUIData()
    self._sellTrigger = FXLoader:Workspace("Shop/Trigger")
    self._inSellArea = false
    self._nextSellAreaCheck = 0
    --- 只检测本地角色位置，每 0.1 秒检查一次；显隐仅在进出边沿改变。
    self:TrackConnection(RunService.Heartbeat:Connect(function()
        local now = os.clock()
        if now < self._nextSellAreaCheck then
            return
        end
        self._nextSellAreaCheck = now + 0.1
        self:UpdateSellArea()
    end))
    self:UpdateSellArea()
end

--- 按场景触发盒的局部空间检测进入和离开，手动关闭后留在区域内不会反复弹出。
function Component:UpdateSellArea()
    local character = self:GetPlayerCharacter()
    if character ~= self._sellCharacter then
        self._sellCharacter = character
        self._inSellArea = false
        self:Hide()
    end
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local inside = false
    if root and humanoid and humanoid.Health > 0 and self._sellTrigger:IsDescendantOf(workspace) then
        local point = self._sellTrigger.CFrame:PointToObjectSpace(root.Position)
        local half = self._sellTrigger.Size * 0.5
        inside = math.abs(point.X) <= half.X and math.abs(point.Y) <= half.Y
            and math.abs(point.Z) <= half.Z
    end
    if inside == self._inSellArea then
        return
    end
    self._inSellArea = inside
    if inside then
        self:Show()
    else
        self:Hide()
    end
end

--- 快照与重生倍率都由服务端同步；库存保持私有，不从 Tool 名称推断道具。
function Component:BindUIData()
    self:WatchDataChanged(Fields.LootSellEntries, self.RefreshLoot, self)
    self:WatchDataChanged(Fields.RebirthCount, function()
        self:RefreshLoot()
    end, self)
end

--- 将真实实例转换为展示契约；幸运价格已包含倍率，重生加成只计算一次。
--- @param entries table? 服务端快照；省略时读取最新同步值。
function Component:RefreshLoot(entries)
    entries = entries or self:GetTable(Fields.LootSellEntries)
    local items = {}
    local rate = Rebirth.GetMoneyRate(self:GetNumber(Fields.RebirthCount))
    for index, entry in ipairs(entries) do
        local config = GameConfig.ItemData[entry.itemId]
        local nameKey = CollectibleText.GetNameKey(config.DisplayModelId)
        local name = self._localization:FormatByKey(nameKey)
        if entry.isLucky then
            name = self._localization:FormatByKey("LootSell.LuckyName", {
                itemKey = nameKey, rate = GameUtility.NumberToText(entry.luckRate),
            })
        end
        table.insert(items, {
            id = entry.id, name = name, qualityId = tostring(config.Quality),
            value = entry.price * rate, icon = "rbxassetid://" .. tostring(config.IconId),
        })
    end
    self.State.items = items
    self:RefreshUI()
end

--- 复用父类列表更新，只覆写实际图标与项目统一数值、本地化文案。
--- @param state table 正式库存派生的完整展示状态。
function Component:Render(state)
    Component.Super.Render(self, state)
    local total = 0
    for index, item in ipairs(state.items) do
        local row = self.Rows[item.id]
        row.name.AutoLocalize = false
        row.value.AutoLocalize = false
        row.icon.Image = item.icon
        row.value.Text = self._localization:FormatByKey("LootSell.Coins", {
            value = GameUtility.NumberToText(item.value),
        })
        total += item.value
    end
    self.Total.Text = self._localization:FormatByKey("LootSell.Coins", {
        value = GameUtility.NumberToText(total),
    })
    self.CapacityTxt.Text = self._localization:FormatByKey("LootSell.Count", {
        count = #state.items, capacity = self.Config.capacity,
    })
    -- 空包点击仍需反馈，仅请求处理中禁用按钮，覆盖展示类的空包禁用规则。
    self:SetButtonEnabled(self.SellAllBtn, not state.pending)
    self:SetButtonEnabled(self.SellDoubleBtn, not state.pending)
end

--- 每次打开读取当前正式库存，不重新绑定按钮。
function Component:OnShow()
    self.State.isOpen = true
    self:RefreshLoot()
end

--- 关闭后库存同步只刷新数据，不重新显示窗口。
function Component:OnHide()
    self.State.isOpen = false
end

--- 出售仅提交稳定 ID 与固定倍率；等待结果期间禁止重复点击。
--- @param action string 展示类发送的 Sell 或 Close。
--- @param payload table Sell 携带 entryIds 与 multiplier，Close 不使用参数。
function Component:OnUIAction(action, payload)
    if action == "Close" then
        self:Hide()
        return
    end
    assert(action == "Sell", "Unsupported loot sell action: " .. tostring(action))
    if self.State.pending then
        return
    end
    if #self.State.items == 0 then
        self._commonUI:ShowLocalizedTips("LootSell.Empty")
        return
    end
    self.State.pending = true
    self:RefreshUI()
    --- RPC 限速或网络失败保留库存并恢复按钮，不伪造成功。
    self._sellTask = task.defer(function()
        --- 按框架白名单请求本人正式库存出售，服务端自行计算金额。
        --- @return table 权威出售结果。
        local ok, result = pcall(function()
            return FX.Network:InvokeServer("C2S_SellLoot", payload.entryIds, payload.multiplier)
        end)
        self._sellTask = nil
        self.State.pending = false
        if ok and result.success then
            self._commonUI:ShowLocalizedTips("LootSell.Gained", {
                value = GameUtility.NumberToText(result.amount),
            })
        else
            self._commonUI:ShowLocalizedTips(ok and result.key or "Common.Unknown")
        end
        self:RefreshLoot(ok and result.entries or nil)
    end)
end

--- 释放尚未返回的 RPC 任务，父类清理列表克隆与按钮、数据监听。
function Component:Dtor()
    if self._sellTask then
        task.cancel(self._sellTask)
        self._sellTask = nil
    end
    Component.Super.Dtor(self)
end

return Component
