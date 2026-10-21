--[[
道具列表接入契约（全部界面文案使用英文）：
Config.qualities:table<string, string>，必填，品质 ID 到 #RRGGBB 十六进制颜色的字典。
所有 items[i].qualityId 必须在此字典中存在；品质 ID 由游戏配置定义，不硬编码枚举。
Config.qualityGradientEnds:table<string, string>，可选，品质 ID 到 #RRGGBB 渐变终色；缺省使用 qualities 中的颜色。条目从上到下渐变。
Config.doubleSaleGemCost:number，必填，单次双倍出售的钻石费用，无默认值。
State.doubleSaleCards:number 可选，缺省 0，拥有的双倍卡数量。
State.gems:number 可选，缺省 0，钻石余额。State.isVip:boolean 可选，缺省 false。
双倍菜单叠在列表上，列表保持可见但禁用底层按钮；关闭后恢复，打开不会发送出售动作。
Sell 的双倍动作新增 method:string，Card / Gems / Vip；普通出售省略。
Card/Gems 的 multiplier 为 2，VIP 时为 4；Vip 方式固定 2。
真实业务必须验证费用、库存和资格，成功后同步卡券/钻石/背包。
Config.capacity:number，必填，正整数，背包条目容量，当前为 12，无默认值。
State 为完整输入，不是增量，所有必填字段无默认值：
  isOpen:boolean 窗口显示；
  items:array 按显示顺序排列的已拥有道具；空背包为 {}；
  items[i].id:string 唯一、稳定的背包实例 ID，不是名称或数组下标；
  items[i].name:string 英文显示名；
  items[i].qualityId:string 品质 ID，与 Config.qualities 的键对应，必填；
  items[i].value:number 此条目的出售��价，非负，单位金币；展示为钞票图标与 +$金额，百万金额保留一位小数 M；
  pending:boolean 可选，省略 false，出售按钮禁用；
  message:string 可选，完整提示原文，由 Text.TrSource 查询，不传拼接后的动态句子；省略空文本。
  soldAmount:number 可选，最近出售获得的金币；存在时优先显示本地化出售结果，0 也有效。
  无 message/soldAmount 且空列表时显示 No items to sell；新请求前清空两字段。
条目原型位于隐藏的 Templates.LootTemplateImg，显示容器 LootListBox 仅挂载运行时克隆。
按 items[i].id 复用与清理实例，items 顺序决定位置；空列表清理所有克隆，原型保留。
每条占一个容量，不合并同名物品。数量由 #items 计算；达到容量显示黄色。
所有条目图标目前统一使用设计模板的问号占位资源，尚未配置真实 Roblox 图标 ID。
最小示例：
  self.Config = {capacity = 12, doubleSaleGemCost = 40, qualities = {common = "#A5ADB8"}}
  self.State = {isOpen = true, items = {{id = "scroll_001", name = "Ancient Scroll", qualityId = "common", value = 18200000}}}
GetUIConfig/GetUIState 默认读取 self.Config/self.State；首次刷新前准备完整数据。
RefreshUI 调用 Render(GetUIState())，不合并补丁。
接入 OnReady 先调父方法，再 BindUIData()、Show()；更新 State 后 RefreshUI()。
加载时使用 items={}, pending=true, message="Loading items..."；准备完再刷新。
必须覆写 OnUIAction(action,payload)，无返回值：
  Sell：{entryIds:array<string> 当前所有背包实例 ID, multiplier:number 1 / 2 / 4, method:string? Card / Gems / Vip}；
  Close：{}。
可选覆写 GetItemQualityColor(item)，输入为当前完整道具条目，返回 Color3；
默认读取 Config.qualities[item.qualityId]，缺失时明确报错，不沿用上一条颜色。
用于条目渐变起色、图标底色、边框和左侧色条；真实图标仍待资源接入。
游戏层校验实际库存、双倍资格及出售结果，
请求时 pending=true 并清空 message/soldAmount；成功更新 items/soldAmount，失败更新 message，
将 pending=false 后刷新；金额模板由 View 翻译，接入层不拼接结果文案。
失败时保留最新库存并填写英文 message。模拟接入只清空模拟列表，不发放金币。
]]
local FX = _G.FX
local FXLoader = FX.Loader
local Text = FXLoader:RequireShared("Scripts/Game/Shared/Text")
local CLootSellView = FX.Class("CLootSellView", "CUIView")

local TranslationTexts = Text.Define("LootSellUI", {
    Capacity = "Items: {count:int} / {capacity:int}",
    NoItems = "No items to sell",
    Coins = "+${amount}",
    Sold = "{amount} Sold!",
})

-- 将金币金额格式化为参考图的短文案。
-- @param amount number 金币数量
-- @return string 金币展示文本
local function FormatCoins(amount)
    if amount >= 1000000 then
        return Text.Tr(TranslationTexts.Coins, {
            amount = string.format("%.1fM", amount / 1000000),
        })
    end
    return Text.Tr(TranslationTexts.Coins, {
        amount = tostring(amount),
    })
end

-- 绑定静态节点，事件只连接一次。
function CLootSellView:OnReady()
    local root = FXLoader:PlayerGui("LootSellUI")
    self.Panel = FXLoader:Here(root, "PopupPanelImg")
    self.Title = FXLoader:Here(root, "TitleBox")
    self.Total = FXLoader:Here(root, "PopupPanelImg.TotalImg.TotalValueTxt")
    self.List = FXLoader:Here(root, "PopupPanelImg.LootListBox")
    self.Template = FXLoader:Here(root, "Templates.LootTemplateImg")
    self.CapacityTxt = FXLoader:Here(root, "PopupPanelImg.CapacityTxt")
    self.Rows = {}
    self.List.CanvasPosition = Vector2.new(0, 0)
    self.StatusTxt = FXLoader:Here(root, "PopupPanelImg.StatusTxt")
    self.StatusMoneyIcon = FXLoader:Here(root, "PopupPanelImg.StatusMoneyIconImg")
    self.SellAllBtn = FXLoader:Here(root, "PopupPanelImg.TotalImg.SellAllBtn")
    self.SellDoubleBtn = FXLoader:Here(root, "PopupPanelImg.TotalImg.SellDoubleBtn")
    self.DoubleSaleBox = FXLoader:Here(root, "DoubleSaleBox")
    self.CardBtn = FXLoader:Here(root, "DoubleSaleBox.PopupPanelImg.CardBtn")
    self.GemsBtn = FXLoader:Here(root, "DoubleSaleBox.PopupPanelImg.GemsBtn")
    self.VipBtn = FXLoader:Here(root, "DoubleSaleBox.PopupPanelImg.VipBtn")
    self.GemsPriceTxt = FXLoader:Here(root, "DoubleSaleBox.PopupPanelImg.GemsBtn.ButtonTxt")
    self.DoubleSaleOpen = false
    local backBtn = FXLoader:Here(root, "DoubleSaleBox.TitleBox.CloseSurfaceImg.CloseBtn")
    -- 二级菜单关闭只返回列表，不提交出售。
    self:TrackConnection(backBtn.Activated:Connect(function()
        self.DoubleSaleOpen = false
        self:RefreshUI()
    end))
    self:TrackConnection(self.CardBtn.Activated:Connect(function()
        self:ConfirmDoubleSale("Card")
    end))
    self:TrackConnection(self.GemsBtn.Activated:Connect(function()
        self:ConfirmDoubleSale("Gems")
    end))
    self:TrackConnection(self.VipBtn.Activated:Connect(function()
        self:ConfirmDoubleSale("Vip")
    end))
    self.CloseBtn = FXLoader:Here(root, "TitleBox.CloseSurfaceImg")
    -- 点击时发送当前配置中的稳定 ID。
    self:TrackConnection(self.SellAllBtn.Activated:Connect(function()
        self:EmitUIAction("Sell", {entryIds = self:GetEntryIds(), multiplier = 1})
    end))
    self:TrackConnection(self.SellDoubleBtn.Activated:Connect(function()
        self.DoubleSaleOpen = true
        self:RefreshUI()
    end))
    self:TrackConnection(self.CloseBtn.Activated:Connect(function()
        self:EmitUIAction("Close", {})
    end))
end

-- 选定出售方式后提交稳定条目 ID；扣费和资格校验由接入层负责。
-- @param method string Card / Gems / Vip
function CLootSellView:ConfirmDoubleSale(method)
    local state = self:GetUIState()
    if not self.DoubleSaleOpen or state.pending or #state.items == 0 then
        return
    end
    if method == "Card" and (state.doubleSaleCards or 0) < 1 then
        return
    elseif method == "Gems" and (state.gems or 0) < self:GetUIConfig().doubleSaleGemCost then
        return
    elseif method == "Vip" and not state.isVip then
        return
    end
    local multiplier = 2
    if state.isVip and method ~= "Vip" then
        multiplier = 4
    end
    self.DoubleSaleOpen = false
    self:EmitUIAction("Sell", {entryIds = self:GetEntryIds(), multiplier = multiplier, method = method})
    self:RefreshUI()
end

-- 打开时刷新最新数据。
function CLootSellView:OnShow()
    self:RefreshUI()
end

-- 发送当前背包条目的稳定身份，不使用名称或列表位置。
-- @return table 稳定条目 ID 数组
function CLootSellView:GetEntryIds()
    local ids = {}
    for index, item in ipairs(self:GetUIState().items) do
        table.insert(ids, item.id)
    end
    return ids
end

-- 从游戏提供的��质映射获取每个道具的颜色，可由接入层覆写。
-- @param item table 当前道具，含 qualityId
-- @return Color3 此道具的品质颜色
function CLootSellView:GetItemQualityColor(item)
    local color = self:GetUIConfig().qualities[item.qualityId]
    assert(color, "Missing quality color: " .. tostring(item.qualityId))
    return Color3.fromHex(color)
end

-- 按稳定 ID 更新条目，只创建新增条目并清理已移除条目。
-- @param state table 完整列表状态，见文件头
function CLootSellView:Render(state)
    if not state.isOpen or #state.items == 0 then
        self.DoubleSaleOpen = false
    end
    self.Panel.Visible = state.isOpen
    self.Title.Visible = state.isOpen
    self.DoubleSaleBox.Visible = state.isOpen and self.DoubleSaleOpen
    self.GemsPriceTxt.Text = tostring(self:GetUIConfig().doubleSaleGemCost)
    local canSell = #state.items > 0 and not state.pending
    self:SetButtonEnabled(self.CardBtn, canSell and (state.doubleSaleCards or 0) > 0)
    self:SetButtonEnabled(self.GemsBtn, canSell and (state.gems or 0) >= self:GetUIConfig().doubleSaleGemCost)
    self:SetButtonEnabled(self.VipBtn, canSell and state.isVip == true)
    local present = {}
    local total = 0
    for index, item in ipairs(state.items) do
        present[item.id] = true
        total = total + item.value
        local record = self.Rows[item.id]
        if not record then
            local row = self.Template:Clone()
            row.Name = "OwnedItem" .. index .. "Img"
            row.Parent = self.List
            row.Visible = true
            record = {
                node = row,
                name = FXLoader:Here(row, "LootNameTxt"),
                value = FXLoader:Here(row, "LootValueTxt"),
                icon = FXLoader:Here(row, "LootIconImg"),
                stripe = FXLoader:Here(row, "QualityStripeImg"),
                border = FXLoader:Here(row, "LootIconImg.UIStroke"),
                gradient = FXLoader:Here(row, "QualityGradient"),
                studGradient = FXLoader:Here(row, "StudTileImg.QualityGradient"),
                iconBackground = FXLoader:Here(row, "LootIconBackgroundImg"),
            }
            -- 此清理函数仅拥有本次克隆的行。
            record.release = self:TrackCleanup(function()
                row:Destroy()
            end)
            self.Rows[item.id] = record
        end
        record.node.Position = UDim2.fromOffset(2, 2 + (index - 1) * 112)
        record.name.Text = Text.TrSource(item.name)
        record.value.Text = FormatCoins(item.value)
        local qualityColor = self:GetItemQualityColor(item)
        local gradientEnds = self:GetUIConfig().qualityGradientEnds
        local endColor = qualityColor
        if gradientEnds and gradientEnds[item.qualityId] then
            endColor = Color3.fromHex(gradientEnds[item.qualityId])
        end
        -- Roblox 使用原生色序列；App 预览仅支持起止色属性。
        if ColorSequence then
            local colors = ColorSequence.new(qualityColor, endColor)
            record.gradient.Color = colors
            record.studGradient.Color = colors
        else
            record.gradient.ColorStart = qualityColor
            record.gradient.ColorEnd = endColor
            record.studGradient.ColorStart = qualityColor
            record.studGradient.ColorEnd = endColor
        end
        record.iconBackground.BackgroundColor3 = qualityColor
        record.icon.BackgroundColor3 = qualityColor
        record.stripe.BackgroundColor3 = qualityColor
        record.border.Color = qualityColor
    end
    for id, record in pairs(self.Rows) do
        if not present[id] then
            record.release()
            self.Rows[id] = nil
        end
    end
    local count = #state.items
    local canvasHeight = math.max(252, count * 112 - 8)
    self.List.CanvasSize = UDim2.fromOffset(822, canvasHeight)
    self.List.CanvasPosition = Vector2.new(0, math.min(self.List.CanvasPosition.Y, canvasHeight - 252))
    self.Total.Text = FormatCoins(total)
    self.CapacityTxt.Text = Text.Tr(TranslationTexts.Capacity, {
        count = count,
        capacity = self:GetUIConfig().capacity,
    })
    self.CapacityTxt.TextColor3 = Color3.fromHex("#FFFFFF")
    if count >= self:GetUIConfig().capacity then
        self.CapacityTxt.TextColor3 = Color3.fromHex("#FFD34F")
    end
    self.StatusTxt.Text = Text.TrSource(state.message or "")
    self.StatusMoneyIcon.Visible = state.soldAmount ~= nil or string.find(state.message or "", "+$", 1, true) ~= nil
    if state.soldAmount ~= nil then
        self.StatusTxt.Text = Text.Tr(TranslationTexts.Sold, {
            amount = FormatCoins(state.soldAmount),
        })
    elseif count == 0 and not state.message then
        self.StatusTxt.Text = Text.Tr(TranslationTexts.NoItems)
    end
    self:SetButtonEnabled(self.SellAllBtn, count > 0 and not state.pending and not self.DoubleSaleOpen)
    self:SetButtonEnabled(self.SellDoubleBtn, count > 0 and not state.pending and not self.DoubleSaleOpen)
    self:SetButtonEnabled(self.CloseBtn, not self.DoubleSaleOpen)
end

-- 业务接入必须处理出售和关闭。
-- @param action string Sell 或 Close
-- @param payload table 动作参数见文件头
function CLootSellView:OnUIAction(action, payload)
    error("Loot sell integration must implement OnUIAction")
end

return CLootSellView
