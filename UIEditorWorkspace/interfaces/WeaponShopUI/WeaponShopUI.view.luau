--[[
武器列表接入契约（完整状态，非增量）
Config.title: string，必填标题。
Config.qualities: 字典，键为品质 ID；值 {name: string, color: string} 均必填，color 为 #RRGGBB 卡片底色。
每项可选 colorEnd:string，#RRGGBB 渐变终色，缺省与 color 相同；卡片从上到下由 color 渐变至 colorEnd。
Config.weapons: 数组，显示顺序；每项 {id: string, name: string, qualityId: string,
 strength: number, price: number, icon: string?}。前五项必填；price 单位金币，显示为钞票图标与 +$金额；strength 为加成点数；
 id 唯一稳定，qualityId 对应 qualities 键；icon 可选 Roblox 图片 ID，缺省或空字符串显示问号占位。
State.owned: 字典，weaponId -> boolean，缺省键表示未拥有。
State.equippedId: string，必填，空字符串表示未装备。
State.coins: number，必填，可用金币；State.open: boolean，必填。
State.pending: 字典，可选，weaponId -> boolean，缺省为未请求；State.loading: boolean? 缺省 false。
最小示例：
 self.Config = {title="WEAPONS", qualities={common={name="Common",color="#FAFCF9"}},
 weapons={{id="sickle",name="Sickle",qualityId="common",strength=1,price=0}}}
 self.State = {owned={sickle=true},equippedId="sickle",coins=700,open=true}
GetUIConfig/GetUIState 默认读取 self.Config/self.State。首次 Show 前准备全部必填数据；
接入 OnReady 先父 OnReady，再 BindUIData、Show；后续更新数据后 RefreshUI。
RefreshUI 调用 Render(GetUIState())；列表空时显示空提示，loading=true 时显示加载提示并清空条目。
动作：Buy / Equip，payload={weaponId:string}；Close，payload={}。无返回值。
必需覆写 OnUIAction，负责服务端校验、扣款及装备，请求时设置 pending[id]，完成后更新完整状态并刷新。
无其他页面专用覆写。UI 禁用不代表服务器校验。模拟 integration 不导入游戏。
WeaponIconImg 是动态图占位，正式图由 Config.weapons[].icon 替换；
App 动态 ID 预览能力有限，真实资源权限及 Studio 显示需另验。
]]
local FX = _G.FX
local FXLoader = FX.Loader
local Text = FXLoader:RequireShared("Scripts/Game/Shared/Text")
local CWeaponShopView = FX.Class("CWeaponShopView", "CUIView")

local TranslationTexts = Text.Define("WeaponShopUI", {
    Strength = "Strength +{strength}",
    Price = "+${price}",
    Equip = "Equip",
    Equipped = "Equipped",
    Waiting = "Waiting...",
    NoWeapons = "No weapons available",
    Loading = "Loading...",
})

-- 绑定窗口与隐藏原型，只在首次准备时连接关闭按钮。
function CWeaponShopView:OnReady()
    local root = FXLoader:PlayerGui("WeaponShopUI")
    -- 原型在克隆前关闭主动翻译文本的自动本地化。
    for index, path in ipairs({
        "Templates.WeaponRowImg.ActionBtn.ButtonTxt",
        "Templates.WeaponRowImg.NameTxt",
        "Templates.WeaponRowImg.RarityTxt",
        "Templates.WeaponRowImg.StrengthTxt",
    }) do
        FXLoader:Here(root, path).AutoLocalize = false
    end
    self.Root = root
    self.Panel = FXLoader:Here(root, "PopupPanelImg")
    self.TitleBox = FXLoader:Here(root, "TitleBox")
    self.TitleTxt = FXLoader:Here(root, "TitleBox.TitleTxt")
    self.TitleTxt.AutoLocalize = false
    self.List = FXLoader:Here(root, "PopupPanelImg.WeaponListBox")
    self.EmptyTxt = FXLoader:Here(root, "PopupPanelImg.EmptyTxt")
    self.EmptyTxt.AutoLocalize = false
    self.Template = FXLoader:Here(root, "Templates.WeaponRowImg")
    self.Rows = {}
    local closeBtn = FXLoader:Here(root, "TitleBox.CloseSurfaceImg")
    self:TrackConnection(closeBtn.Activated:Connect(function()
        self:EmitUIAction("Close", {})
    end))
end

-- 打开时应用当前完整数据。
function CWeaponShopView:OnShow()
    self:RefreshUI()
end

-- 根据稳定 ID 增删和更新条目，颜色始终从品质配置读取。
-- @param state table 完整状态，字段见文件头。
function CWeaponShopView:Render(state)
    local config = self:GetUIConfig()
    self.Panel.Visible = state.open
    self.TitleBox.Visible = state.open
    self.TitleTxt.Text = Text.TrSource(config.title)
    local active = {}
    local count = 0
    if not state.loading then
        for index, weapon in ipairs(config.weapons) do
            count = index
            active[weapon.id] = true
            local entry = self.Rows[weapon.id]
            if not entry then
                local row = self.Template:Clone()
                row.Name = "Weapon_" .. weapon.id
                row.Parent = self.List
                row.Visible = true
                local button = FXLoader:Here(row, "ActionBtn")
                local weaponId = weapon.id
                -- 每个实例只连接一次；点击时读取当前状态，以稳定 ID 发出动作。
                local connection = self:TrackConnection(button.Activated:Connect(function()
                    local currentState = self:GetUIState()
                    local action = "Buy"
                    if currentState.owned[weaponId] then
                        action = "Equip"
                    end
                    self:EmitUIAction(action, {weaponId = weaponId})
                end))
                local release = self:TrackCleanup(function()
                    connection:Disconnect()
                    row:Destroy()
                end)
                entry = {row = row, button = button, release = release}
                self.Rows[weapon.id] = entry
            end
            local row = entry.row
            local quality = config.qualities[weapon.qualityId]
            row.Position = UDim2.fromOffset(2, (index - 1) * 172 + 2)
            row.BackgroundColor3 = Color3.fromHex("#FFFFFF")
            local startColor = Color3.fromHex(quality.color)
            local endColor = Color3.fromHex(quality.colorEnd or quality.color)
            local gradient = FXLoader:Here(row, "QualityGradient")
            local studGradient = FXLoader:Here(row, "StudTileImg.QualityGradient")
            -- Roblox 使用原生色序列；App 预览仅支持起止色属性。
            if ColorSequence then
                local colors = ColorSequence.new(startColor, endColor)
                gradient.Color = colors
                studGradient.Color = colors
            else
                gradient.ColorStart = startColor
                gradient.ColorEnd = endColor
                studGradient.ColorStart = startColor
                studGradient.ColorEnd = endColor
            end
            FXLoader:Here(row, "NameTxt").Text = Text.TrSource(weapon.name)
            FXLoader:Here(row, "RarityTxt").Text = Text.TrSource(quality.name)
            local strengthTxt = FXLoader:Here(row, "StrengthTxt")
            strengthTxt.Text = Text.Tr(TranslationTexts.Strength, {
                strength = weapon.strength,
            })
            local icon = FXLoader:Here(row, "WeaponIconImg")
            icon.Image = weapon.icon or "rbxassetid://86795093617566"
            local owned = state.owned[weapon.id] == true
            local equipped = state.equippedId == weapon.id
            local pending = state.pending and state.pending[weapon.id]
            local caption = Text.Tr(TranslationTexts.Price, {
                price = weapon.price,
            })
            local color = "#67ED14"
            local edge = "#225A07"
            if owned then
                caption = Text.Tr(TranslationTexts.Equip)
            end
            if equipped then
                caption = Text.Tr(TranslationTexts.Equipped)
                color = "#397BA7"
                edge = "#193E73"
            elseif pending then
                caption = Text.Tr(TranslationTexts.Waiting)
                color = "#638079"
            elseif not owned and state.coins < weapon.price then
                color = "#638079"
            end
            FXLoader:Here(row, "OwnedTxt").Visible = false
            local showMoney = not owned and not equipped and not pending
            FXLoader:Here(row, "ActionBtn.MoneyIconImg").Visible = showMoney
            local buttonText = FXLoader:Here(row, "ActionBtn.ButtonTxt")
            buttonText.Text = caption
            buttonText.Position = UDim2.fromOffset(0, 0)
            buttonText.Size = UDim2.fromScale(1, 1)
            buttonText.TextXAlignment = Enum.TextXAlignment.Center
            if showMoney then
                buttonText.Position = UDim2.fromOffset(64, 0)
                buttonText.Size = UDim2.new(1, -72, 1, 0)
                buttonText.TextXAlignment = Enum.TextXAlignment.Left
            end
            FXLoader:Here(row, "ActionBtn.BottomEdgeImg").BackgroundColor3 = Color3.fromHex(edge)
            entry.button.BackgroundColor3 = Color3.fromHex(color)
            self:SetButtonEnabled(entry.button, not equipped and not pending and (owned or state.coins >= weapon.price))
        end
    end
    for weaponId, entry in pairs(self.Rows) do
        if not active[weaponId] then
            entry.release()
            self.Rows[weaponId] = nil
        end
    end
    self.List.CanvasSize = UDim2.fromOffset(0, math.max(524, count * 172))
    self.EmptyTxt.Visible = count == 0
    self.EmptyTxt.Text = Text.Tr(TranslationTexts.NoWeapons)
    if state.loading then
        self.EmptyTxt.Text = Text.Tr(TranslationTexts.Loading)
    end
end

-- 必须由游戏接入或模拟类处理业务动作。
-- @param action string Buy、Equip 或 Close。
-- @param payload table weaponId 或空表。
function CWeaponShopView:OnUIAction(action, payload)
    error("Weapon shop integration must implement OnUIAction")
end

return CWeaponShopView
