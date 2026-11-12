local FX = _G.FX
local CPurchaseIntroPreview = FX.Class("CPurchaseIntroPreview", "CPurchaseIntroView")

--- 仅提供 VIP 模拟报价与状态，不调用平台支付。
--- @param owner table 编辑器提供的组件宿主。
function CPurchaseIntroPreview:Ctor(owner)
    CPurchaseIntroPreview.Super.Ctor(self, owner)
    self.Config = {itemId = "1", price = 68}
    self.State = {status = "Ready", pending = false}
end

--- 绑定完成后显示 VIP 专属内容，价格仅为模拟数据。
function CPurchaseIntroPreview:OnReady()
    CPurchaseIntroPreview.Super.OnReady(self)
    self:BindUIData()
    self:Show()
end

--- 模拟购买成功与关闭，不访问真实资格或支付接口。
--- @param action string Buy 或 Close。
--- @param payload table Buy 的稳定 itemId，Close 不使用。
function CPurchaseIntroPreview:OnUIAction(action, payload)
    if action == "Close" then
        self:Hide()
        return
    end
    assert(action == "Buy" and payload.itemId == self.Config.itemId, "Unknown VIP purchase action")
    self.State.status = "Purchased"
    self.State.pending = false
    self:RefreshUI()
end

return CPurchaseIntroPreview
