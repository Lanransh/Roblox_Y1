local FX = _G.FX
local FXLoader = FX.Loader
local Text = FXLoader:RequireShared("Scripts/Game/Shared/Text")
local TranslationTexts = Text.Define("WeaponShop", {
    TrainingRate = "Training ×{rate}",
    Price = "Buy: {value} Coins",
    Equipped = "Equipped",
    Equip = "Equip",
    Unknown = "Something went wrong. Please try again.",
})
local RunService = game:GetService("RunService")
FXLoader:RequireFromParent(script, "Generated/CWeaponShopView")
local Fields = _G.PlayerDataConfig
local GameUtility = FXLoader:RequireShared("Scripts/Game/Shared/GameUtility")
local ShopAreas = FXLoader:RequireFromParent(script, "ShopAreas")
local Component = FX.Class("CWeaponShopUICompClass", "CWeaponShopView")

--- 只挂载业务子类，复用编辑器展示与交互。
--- @return string 玩家内协作名称。
function Component:GetCompName()
    return "CWeaponShopUIComp"
end

--- 从 ToolConfig 提供展示契约，按工具顺序循环配色，数据与区域监听只绑定一次。
function Component:OnReady()
    Component.Super.OnReady(self)
    self.Root.ResetOnSpawn = false
    self.Root.DisplayOrder = 10
    self.Template.Visible = false
    self._commonUI = self:GetPlayerObject():RequireComponent("FCCommonUIComp")
    self._commonUI:RegisterTrainingClickModal(self.Root)
    self._localization = self._commonUI.Localization
    self.Config = {
        title = "WEAPONS", weapons = {}, qualities = {},
    }
    -- 工具没有品质字段，展示配色按顺序循环，不增加虚构的品质文案。
    local rowColors = {
        {"#D8F2CF", "#B0DC9E"},
        {"#D7EDFC", "#A9D4F4"},
        {"#EADCF7", "#CFB3E9"},
        {"#FADCEB", "#EDAFD0"},
        {"#FCEBC8", "#F3D396"},
    }
    for index, config in ipairs(_G.GameConfig.ToolConfig) do
        local colorId = tostring((index - 1) % #rowColors + 1)
        local colors = rowColors[(index - 1) % #rowColors + 1]
        self.Config.qualities[colorId] = {name = "", color = colors[1], colorEnd = colors[2]}
        table.insert(self.Config.weapons, {
            id = tostring(config.ToolId), name = config.Name, qualityId = colorId,
            strength = config.TrainingRate, price = config.Price, icon = "rbxassetid://" .. config.Img,
        })
    end
    self.State = {owned = {}, equippedId = "", coins = 0, open = false}
    self:Hide()
    self:TrackConnection(self._localization.Changed:Connect(function()
        self:RefreshUI()
    end))
    self._shopAreas = ShopAreas.New("PurpleHut", true)
    self:BindUIData()
    self._inside = false
    self._nextAreaCheck = 0
    --- 区域只控制显隐，不能决定服务端扣款或解锁资格。
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

--- 监听立即回放，关闭后同步只刷新内容，不重新打开窗口。
function Component:BindUIData()
    self:WatchDataChanged(Fields.WeaponData, self.RefreshWeapon, self)
    self:WatchDataChanged(Fields.Money, self.RefreshWeapon, self)
end

--- 将权威存档转换为展示状态，并及时更新小屋的购买与装备提醒。
function Component:RefreshWeapon()
    local data = self:GetTable(Fields.WeaponData)
    self.State.owned = data.owned
    self.State.equippedId = tostring(data.equippedId)
    self.State.coins = self:GetNumber(Fields.Money)
    self._shopAreas:Refresh(self.Config.weapons, self.State)
    self:RefreshUI()
end

--- 手动关闭后留在区域内不会重开，离开再进入、死亡和重生按边沿处理。
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

--- 生成类未处理倍率和价格模板翻译；仅补动态文案与数量格式，配置名称按原文查询。
--- @param state table 服务端数据派生的完整 UI 状态。
function Component:Render(state)
    for index, weapon in ipairs(self.Config.weapons) do
        weapon.name = Text.TrSource(_G.GameConfig.ToolConfig[index].Name)
    end
    Component.Super.Render(self, state)
    for index, weapon in ipairs(self.Config.weapons) do
        local entry = self.Rows[weapon.id]
        if entry then
            local row = entry.row
            FXLoader:Here(row, "NameTxt").AutoLocalize = false
            FXLoader:Here(row, "RarityTxt").Visible = false
            local rate = FXLoader:Here(row, "StrengthTxt")
            rate.TextScaled = true
            rate.AutoLocalize = false
            rate.Text = Text.Tr(TranslationTexts.TrainingRate, {
                rate = GameUtility.NumberToText(weapon.strength),
            })
            local owned = state.owned[weapon.id] == true
            local equipped = state.equippedId == weapon.id
            local key = TranslationTexts.Price
            if equipped then
                key = TranslationTexts.Equipped
            elseif owned then
                key = TranslationTexts.Equip
            end
            local caption = FXLoader:Here(row, "ActionBtn/ButtonTxt")
            caption.AutoLocalize = false
            caption.Text = Text.Tr(key, {value = GameUtility.NumberToText(weapon.price)})
            -- 请求期间保持原有显示；余额不足也允许服务端返回提示。
            self:SetButtonEnabled(entry.button, not equipped)
        end
    end
end

--- 打开时读取最新状态，不重复绑定条目按钮。
function Component:OnShow()
    self.State.open = true
    self:RefreshWeapon()
end

--- 保留关闭状态，后续同步不能将面板重新打开。
function Component:OnHide()
    self.State.open = false
end

--- 扣款与解锁由服务端负责，成功后按权威返回值更新列表及小屋提醒。
--- @param action string Buy、Equip 或 Close。
--- @param payload table 展示类提供的字符串 weaponId。
function Component:OnUIAction(action, payload)
    if action == "Close" then
        self:Hide()
        return
    end
    if self._requestTask then
        return
    end
    self._requestTask = task.defer(function()
        --- 网络限速或失败恢复按钮，不以本地状态伪造购买成功。
        --- @return table 服务端权威结果。
        local ok, result = pcall(function()
            return FX.Network:InvokeServer("C2S_WeaponAction", action, tonumber(payload.weaponId))
        end)
        self._requestTask = nil
        if ok and result.success then
            self.State.owned = result.data.owned
            self.State.equippedId = tostring(result.data.equippedId)
            self.State.coins = result.coins
            self._shopAreas:Refresh(self.Config.weapons, self.State)
        else
            self._commonUI:ShowLocalizedTips(ok and result.key or TranslationTexts.Unknown)
        end
        self:RefreshUI()
    end)
end

--- 取消请求并释放小屋提醒，父类释放列表、连接和数据订阅。
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
