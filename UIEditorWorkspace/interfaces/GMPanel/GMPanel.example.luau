local FX = _G.FX
local CGMPanelPreview = FX.Class("CGMPanelPreview", "CGMPanelView")

-- 准备模拟数据，不连接真实存档。
-- @param owner table 编辑器组件宿主
function CGMPanelPreview:Ctor(owner)
    CGMPanelPreview.Super.Ctor(self, owner)
    self.Config = {}
    self.State = { pending = false }
    self.Data = { SetLevel = 1, SetRebirth = 0, SetMoney = 0, SetDiamonds = 0 }
end

-- 父方法绑定完成后初始化并显示。
function CGMPanelPreview:OnReady()
    CGMPanelPreview.Super.OnReady(self)
    self:BindUIData()
    self:Show()
end

-- 模拟命令仅更新内存；保存按钮仅模拟成功反馈。
-- @param action string 稳定命令名
-- @param payload table 设置命令的 value/param2/param3 或空表
function CGMPanelPreview:OnUIAction(action, payload)
    if action == "Close" then
        return
    elseif action == "ResetData" then
        self.Data = { SetLevel = 1, SetRebirth = 0, SetMoney = 0, SetDiamonds = 0 }
        print("模拟：数据已重置")
    elseif action == "SaveNow" then
        print("模拟：立即保存成功")
    else
        self.Data[action] = payload.value
        local labels = { SetLevel = "等级", SetRebirth = "重生", SetMoney = "金钱", SetDiamonds = "钻石" }
        print("模拟：" .. labels[action] .. "已设置为 " .. tostring(payload.value))
    end
    self:RefreshUI()
end

return CGMPanelPreview