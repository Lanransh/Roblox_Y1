local FX = _G.FX
local Text = FX.Loader:RequireShared("Scripts.Game.Shared.Text")
local CPurchaseIntroPreview = FX.Class("CPurchaseIntroPreview", "CPurchaseIntroView")

local TranslationTexts = Text.Define("PurchaseIntroExample", {
    Title = "Confirm Purchase",
    Name = "2× Loot Sale Value",
    Category = "VIP BENEFIT",
    Description = "Unlock VIP to sell your loot for twice the value.",
})

--- 用一个具体商品演示通用契约，数据不导出至游戏。
--- @param owner table 编辑器提供的组件宿主。
function CPurchaseIntroPreview:Ctor(owner)
    CPurchaseIntroPreview.Super.Ctor(self, owner)
    self.Config = {
        itemId = "1",
        title = TranslationTexts.Title,
        name = TranslationTexts.Name,
        category = TranslationTexts.Category,
        description = TranslationTexts.Description,
        icon = "rbxassetid://104326662511955",
        currency = "Robux",
        price = 68,
    }
    self.State = {
        status = "Ready",
        pending = false,
    }
end

--- 父方法绑定节点后，首次刷新并显示商品介绍。
function CPurchaseIntroPreview:OnReady()
    CPurchaseIntroPreview.Super.OnReady(self)
    self:BindUIData()
    self:Show()
end

--- 模拟购买只更新商品状态，不调用平台或游戏接口。
--- @param action string Buy 或 Close。
--- @param payload table Buy 的稳定 itemId，Close 不使用。
function CPurchaseIntroPreview:OnUIAction(action, payload)
    if action == "Close" then
        self:Hide()
        return
    end
    assert(action == "Buy" and payload.itemId == self.Config.itemId, "Unknown purchase action")
    self.State.status = "Purchased"
    self.State.pending = false
    self:RefreshUI()
end

return CPurchaseIntroPreview
