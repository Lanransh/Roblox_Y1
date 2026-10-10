local FX = _G.FX
local FXLoader = FX.Loader
local RunService = game:GetService("RunService")
FXLoader:RequireFromParent(script, "Generated/CAuraShopView")
local Fields = _G.PlayerDataConfig
local GameUtility = FXLoader:RequireShared("Scripts/Game/Shared/GameUtility")
local Component = FX.Class("CAuraShopUICompClass", "CAuraShopView")

--- Aura 摊位打开业务子类，生成展示类不单独挂载。
--- @return string 玩家内协作名称。
function Component:GetCompName()
    return "CAuraShopUIComp"
end

--- 复用编辑器布局与按钮事件，绑定真实配置、存档和场景触发盒。
function Component:OnReady()
    Component.Super.OnReady(self)
    self.Root.ResetOnSpawn = false
    self.Root.DisplayOrder = 10
    self._commonUI = self:GetPlayerObject():RequireComponent("FCCommonUIComp")
    self._commonUI:RegisterTrainingClickModal(self.Root)
    self._localization = self._commonUI.Localization
    self.Config = {title = "AURAS", auras = {}, qualities = {}}
    local color = "#" .. self.Template.BackgroundColor3:ToHex()
    for index, config in ipairs(_G.GameConfig.AuraConfig) do
        local qualityId = tostring(config.Quality)
        self.Config.qualities[qualityId] = {name = "", color = color}
        table.insert(self.Config.auras, {
            id = tostring(config.AuraId), auraId = config.AuraId, name = config.Name,
            qualityId = qualityId, strength = config.TrainingRate, price = config.Price,
        })
    end
    self.State = {owned = {}, equippedId = "", coins = 0, open = false, pending = {}}
    self:Hide()
    self:TrackConnection(self._localization.Changed:Connect(function()
        self:RefreshUI()
    end))
    self:BindUIData()
    self._trigger = FXLoader:Workspace("BlueHut/Trigger")
    self._inside = false
    self._nextAreaCheck = 0
    --- 区域只控制本地显隐，不能决定扣款或装备资格。
    self:TrackConnection(RunService.Heartbeat:Connect(function()
        local now = os.clock()
        if now < self._nextAreaCheck then
            return
        end
        self._nextAreaCheck = now + 0.1
        self:UpdateShopArea()
    end))
    self:UpdateShopArea()
end

--- 数据监听立即回放，关闭后同步只刷新条目，不重新打开窗口。
function Component:BindUIData()
    self:WatchDataChanged(Fields.AuraData, self.RefreshAura, self)
    self:WatchDataChanged(Fields.Coins, self.RefreshAura, self)
end

--- 将同步存档转换为生成展示类要求的完整状态。
function Component:RefreshAura()
    local data = self:GetTable(Fields.AuraData)
    self.State.owned = data.owned
    self.State.equippedId = data.equippedId == 0 and "" or tostring(data.equippedId)
    self.State.coins = self:GetNumber(Fields.Coins)
    self:RefreshUI()
end

--- 进出区域边沿控制窗口；手动关闭后必须离开再进入才重新打开。
function Component:UpdateShopArea()
    local character = self:GetPlayerCharacter()
    if character ~= self._character then
        self._character = character
        self._inside = false
        self:Hide()
    end
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local inside = false
    if root and humanoid and humanoid.Health > 0 and self._trigger:IsDescendantOf(workspace) then
        local point = self._trigger.CFrame:PointToObjectSpace(root.Position)
        local half = self._trigger.Size * 0.5
        inside = math.abs(point.X) <= half.X and math.abs(point.Y) <= half.Y
            and math.abs(point.Z) <= half.Z
    end
    if inside == self._inside then
        return
    end
    self._inside = inside
    if inside then
        self:Show()
    else
        self:Hide()
    end
end

--- 保留父类列表与配色，只接入倍率文案、数值格式化和当前装备的卸下操作。
--- @param state table 权威数据派生的完整 UI 状态。
function Component:Render(state)
    for qualityId, quality in pairs(self.Config.qualities) do
        quality.name = self._localization:FormatByKey("Rarity.Quality", {level = tonumber(qualityId)})
    end
    Component.Super.Render(self, state)
    for index, aura in ipairs(self.Config.auras) do
        local entry = self.Rows[aura.id]
        local row = entry.row
        local rate = FXLoader:Here(row, "StrengthTxt")
        local quality = FXLoader:Here(row, "RarityTxt")
        local caption = FXLoader:Here(row, "ActionBtn/ButtonTxt")
        rate.AutoLocalize = false
        quality.AutoLocalize = false
        caption.AutoLocalize = false
        rate.Text = self._localization:FormatByKey("Aura.TrainingRate", {
            rate = GameUtility.NumberToText(aura.strength),
        })
        local owned = state.owned[aura.id] == true
        local equipped = state.equippedId == aura.id
        local pending = state.pending[aura.id]
        local key = "Aura.Price"
        if pending then
            key = "Aura.Waiting"
        elseif equipped then
            key = "Aura.Unequip"
        elseif owned then
            key = "Aura.Equip"
        elseif state.coins < aura.price then
            key = "Aura.NeedCoins"
        end
        caption.Text = self._localization:FormatByKey(key, {value = GameUtility.NumberToText(aura.price)})
        -- 余额不足仍允许点击，由服务端返回提示；已装备允许卸下，仅请求期间禁用。
        self:SetButtonEnabled(entry.button, not pending)
    end
end

--- 打开时读取最新同步状态，不重复绑定按钮。
function Component:OnShow()
    self.State.open = true
    self:RefreshAura()
end

--- 关闭状态保留到后续数据同步。
function Component:OnHide()
    self.State.open = false
end

--- 只请求操作与稳定 ID，不在客户端扣款、写存档或创建角色特效。
--- @param action string Buy、Equip 或 Close。
--- @param payload table 展示类提供的字符串 auraId。
function Component:OnUIAction(action, payload)
    if action == "Close" then
        self:Hide()
        return
    end
    if self._requestTask then
        return
    end
    for index, aura in ipairs(self.Config.auras) do
        self.State.pending[aura.id] = true
    end
    self:RefreshUI()
    self._requestTask = task.defer(function()
        --- 网络拒绝或失败恢复按钮，不用本地状态伪造成功。
        --- @return table 服务端权威结果。
        local ok, result = pcall(function()
            return FX.Network:InvokeServer("C2S_AuraAction", action, tonumber(payload.auraId))
        end)
        self._requestTask = nil
        table.clear(self.State.pending)
        if ok and result.success then
            self.State.owned = result.data.owned
            self.State.equippedId = result.data.equippedId == 0 and "" or tostring(result.data.equippedId)
            self.State.coins = result.coins
        else
            self._commonUI:ShowLocalizedTips(ok and result.key or "Common.Unknown")
        end
        self:RefreshUI()
    end)
end

--- 取消尚未返回的请求，父类清理行节点、区域检测与数据订阅。
function Component:Dtor()
    if self._requestTask then
        task.cancel(self._requestTask)
        self._requestTask = nil
    end
    Component.Super.Dtor(self)
end

return Component
