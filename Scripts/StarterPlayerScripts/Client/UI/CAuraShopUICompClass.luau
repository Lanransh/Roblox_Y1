local FX = _G.FX
local FXLoader = FX.Loader
local Text = FXLoader:RequireShared("Scripts/Game/Shared/Text")
local TranslationTexts = Text.Define("AuraShop", {
    Unknown = "Something went wrong. Please try again.",
})
local RunService = game:GetService("RunService")
FXLoader:RequireFromParent(script, "Generated/CAuraShopView")
local Fields = _G.PlayerDataConfig
local GameUtility = FXLoader:RequireShared("Scripts/Game/Shared/GameUtility")
local ShopAreas = FXLoader:RequireFromParent(script, "ShopAreas")
local Component = FX.Class("CAuraShopUICompClass", "CAuraShopView")

--- Aura 摊位打开业务子类，生成展示类不单独挂载。
--- @return string 玩家内协作名称。
function Component:GetCompName()
    return "CAuraShopUIComp"
end

--- 复用编辑器布局与按钮事件，按真实品质接入渐变色、存档和场景触发盒。
function Component:OnReady()
    Component.Super.OnReady(self)
    self.Root.ResetOnSpawn = false
    self.Root.DisplayOrder = 10
    self._commonUI = self:GetPlayerObject():RequireComponent("FCCommonUIComp")
    self._commonUI:RegisterTrainingClickModal(self.Root)
    self._localization = self._commonUI.Localization
    self.Config = {title = "AURAS", auras = {}, qualities = {},
        strengthIsMultiplier = true, allowUnaffordableAction = true, allowUnequip = true}
    -- 与出售界面的浅色渐变风格保持一致，未配置专色时按品质循环配色。
    local qualityColors = {
        {"#D8F2CF", "#B0DC9E"},
        {"#D7EDFC", "#A9D4F4"},
        {"#EADCF7", "#CFB3E9"},
        {"#FADCEB", "#EDAFD0"},
        {"#FCEBC8", "#F3D396"},
    }
    for index, config in ipairs(_G.GameConfig.AuraConfig) do
        local qualityId = tostring(config.Quality)
        local colors = qualityColors[(config.Quality - 1) % #qualityColors + 1]
        local rowColor = config.DisplayColor or colors[1]
        if rowColor:sub(1, 1) ~= "#" then
            rowColor = "#" .. rowColor
        end
        self.Config.qualities[qualityId] = {
            name = "", level = config.Quality, color = rowColor,
            colorEnd = config.DisplayColor and rowColor or colors[2],
        }
        table.insert(self.Config.auras, {
            id = tostring(config.AuraId), auraId = config.AuraId, name = config.Name,
            qualityId = qualityId, strength = config.TrainingRate, price = config.Price,
            icon = "rbxassetid://" .. config.Img,
        })
    end
    self.State = {owned = {}, equippedId = "", coins = 0, open = false, pending = {}}
    self:Hide()
    self:TrackConnection(self._localization.Changed:Connect(function()
        self:RefreshUI()
    end))
    self._shopAreas = ShopAreas.New("BlueHut", true)
    self:BindUIData()
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
    self:WatchDataChanged(Fields.Money, self.RefreshAura, self)
end

--- 将同步存档转换为展示状态，并及时更新小屋的购买与装备提醒。
function Component:RefreshAura()
    local data = self:GetTable(Fields.AuraData)
    self.State.owned = data.owned
    self.State.equippedId = data.equippedId == 0 and "" or tostring(data.equippedId)
    self.State.coins = self:GetNumber(Fields.Money)
    self._shopAreas:Refresh(self.Config.auras, self.State)
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
    local position = root and humanoid and humanoid.Health > 0 and root.Position or nil
    local inside = self._shopAreas:IsInside(position)
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

--- 展示类统一处理倍率、品质和卸下文案，数量沿用项目格式。
--- @param value number 未格式化的数量。
--- @return string 用于显示的数量。
function Component:FormatNumber(value)
    return GameUtility.NumberToText(value)
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

--- 请求只发送操作与稳定 ID，成功后按权威返回值更新列表及小屋提醒。
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
    self.State.pending[payload.auraId] = true
    self.State.busy = true
    self:RefreshUI()
    self._requestTask = task.defer(function()
        --- 网络拒绝或失败恢复按钮，不用本地状态伪造成功。
        --- @return table 服务端权威结果。
        local ok, result = pcall(function()
            return FX.Network:InvokeServer("C2S_AuraAction", action, tonumber(payload.auraId))
        end)
        self._requestTask = nil
        self.State.pending[payload.auraId] = nil
        self.State.busy = false
        if ok and result.success then
            self.State.owned = result.data.owned
            self.State.equippedId = result.data.equippedId == 0 and "" or tostring(result.data.equippedId)
            self.State.coins = result.coins
            self._shopAreas:Refresh(self.Config.auras, self.State)
        else
            self._commonUI:ShowLocalizedTips(ok and result.key or TranslationTexts.Unknown)
        end
        self:RefreshUI()
    end)
end

--- 取消请求并释放小屋提醒，父类清理行节点、区域检测与数据订阅。
function Component:Dtor()
    if self._shopAreas then
        self._shopAreas:Destroy()
    end
    if self._requestTask then
        task.cancel(self._requestTask)
        self._requestTask = nil
    end
    Component.Super.Dtor(self)
end

return Component
