local FX = _G.FX
local CLootSellPreview = FX.Class("CLootSellPreview", "CLootSellView")

-- 准备十二条模拟数据以验证满容量和滚动列表。
-- @param owner table 编辑器宿主
function CLootSellPreview:Ctor(owner)
    CLootSellPreview.Super.Ctor(self, owner)
    self.Config = {
        capacity = 12,
        qualities = {
            common = "#A5ADB8",
            uncommon = "#55CE35",
            rare = "#30A7F4",
            epic = "#A85BE0",
            legendary = "#F2A532",
        },
    }
    local qualities = {"common", "uncommon", "rare", "epic", "legendary"}
    self.State = {isOpen = true, items = {}, pending = false}
    for index = 1, 12 do
        local item = {id = "sample_" .. index, name = "Sample Item " .. index, value = 1000000}
        if index == 1 then
            item.name = "Ancient Scroll"
            item.value = 18200000
        end
        item.qualityId = qualities[(index - 1) % #qualities + 1]
        table.insert(self.State.items, item)
    end
end

-- 父层绑定后初次展示。
function CLootSellPreview:OnReady()
    CLootSellPreview.Super.OnReady(self)
    self:BindUIData()
    self:Show()
end

-- 校验稳定实例 ID 后模拟出售整个列表。
-- @param action string Sell 或 Close
-- @param payload table entryIds 和 multiplier，关闭时为空表
function CLootSellPreview:OnUIAction(action, payload)
    if action == "Close" then
        self.State.isOpen = false
    elseif action == "Sell" then
        if self.State.pending or #self.State.items == 0 then
            return
        end
        assert(payload.multiplier == 1 or payload.multiplier == 2, "Invalid multiplier")
        assert(#payload.entryIds == #self.State.items, "Inventory changed")
        local total = 0
        for index, item in ipairs(self.State.items) do
            assert(payload.entryIds[index] == item.id, "Unknown inventory entry")
            total = total + item.value
        end
        self.State.items = {}
        self.State.message = string.format("+$%.1fM Sold!", total * payload.multiplier / 1000000)
    else
        error("Unknown action: " .. tostring(action))
    end
    self:RefreshUI()
end

return CLootSellPreview