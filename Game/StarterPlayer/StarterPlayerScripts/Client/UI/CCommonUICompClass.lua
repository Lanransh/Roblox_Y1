local FX = _G.FX
local UI = FX.Class("CCommonUICompClass", "FCCommonUICompClass")

--- 将通用提示接入项目设计画布，随画布等比缩放。
--- @param owner table 所属客户端玩家对象。
function UI:Ctor(owner)
    UI.Super.Ctor(self, owner)
    local playerGui = self:GetPlayerNode():WaitForChild("PlayerGui")
    local canvas = playerGui:WaitForChild("ScreenGui"):WaitForChild("Canvas")
    self.Tips.TextSize = 28
    self.Tips.Parent = canvas
end

--- 提示已移出框架根节点，需要单独释放，保留项目共享画布。
function UI:Dtor()
    UI.Super.Dtor(self)
    self.Tips:Destroy()
end

return UI
