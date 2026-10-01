local FX, FC = _G.FX, _G.FC
local UI = FX.Class("FCUICompClass", "FCPlayerCompClass")
FC.UICompClass = UI
--- @param owner table 本地玩家对象。
function UI:Ctor(owner)
    UI.Super.Ctor(self, owner)
end
--- @return string 默认组件名，项目子类应覆盖。
function UI:GetCompName()
    return "FCUIComp"
end
--- @return Instance 项目提供的 ScreenGui 或 GuiObject 根节点。
function UI:GetRootNode()
    return assert(self._rootNode, "Set _rootNode or override GetRootNode")
end
--- 展示节点并调用一次本次打开钩子；不重新绑定按钮。
function UI:Show()
    local node = self:GetRootNode()
    if node:IsA("ScreenGui") then
        node.Enabled = true
    else
        node.Visible = true
    end
    if self.OnShow then
        self:OnShow()
    end
end
--- 隐藏根节点，生命周期清理由析构负责。
function UI:Hide()
    local node = self:GetRootNode()
    if node:IsA("ScreenGui") then
        node.Enabled = false
    else
        node.Visible = false
    end
    if self.OnHide then
        self:OnHide()
    end
end
return UI
