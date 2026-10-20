--[[
GM 面板游戏接入契约
Config = {}，无必填配置。
State 为完整状态：pending:boolean 可选，默认 false，请求期间禁用按钮；
最小数据：self.Config = {}; self.State = { pending = false }。
Ctor 先调用父构造再准备数据；OnReady 先调用父方法，再 BindUIData()、Show()。
GetUIConfig/GetUIState 默认读取 self.Config/self.State；
RefreshUI 调用 Render(GetUIState())，不合并增量；后续更新 State 后 RefreshUI。
无列表、无异步加载态；首次 Show 前准备完整数据。
必需覆写 OnUIAction(action, payload)，无返回值：
SetLevel / SetRebirth / SetMoney / SetDiamonds：
payload = { value:number, param2:string, param3:string }；
value 为参数1的非负安全整数，等级至少1，单位分别为级/次数/金币/钻石。
param2、param3 为另外两个输入框原文（空框为 ""），当前四项功能不消费。
AddItem：payload = { itemId:number, count:number }；参数1为道具配置 ID，参数2为添加数量，
两者均为正安全整数，参数3不消费；游戏接入校验道具配置存在并向当前管理员背包添加。
ResetData / SaveNow / Close：payload = {}。ResetData 经再次点击确认才发送。
ReachRebirthLevel：payload = {}，无需输入参数；游戏接入按当前管理员最新重生次数和
重生配置计算所需等级，将等级提升至 math.max(当前等级, 所需等级)，不执行重生。
已达重生上限时保持数据不变；服务端重新计算目标，不信任客户端等级。
设置作用于当前管理员本人，目标身份由游戏接入层决定，不把备用框当作玩家ID。
游戏接入负责服务端权限、数值校验、实际写入、重置和持久化；
请求前 pending=true 并刷新，返回后 pending=false 并刷新；结果与错误由接入层处理，本面板不显示状态文本。
无其他必需或可选覆写；Preview 只改模拟数据，不持久化。
GM 面板仅供管理员自用，静态标签、输入提示和重置确认均保留中文，不参与翻译。
输入参数保留玩家原文，不作翻译。
TextBox 为原生 Roblox 输入框；App 自动化不支持键盘、文本输入和焦点事件。
]]
local FX = _G.FX
local FXLoader = FX.Loader
local CGMPanelView = FX.Class("CGMPanelView", "CUIView")

-- 一次绑定静态节点和按钮，输入值在点击时读取。
function CGMPanelView:OnReady()
    local root = FXLoader:PlayerGui("GMPanelUI")
    self.Panel = FXLoader:Here(root, "PopupPanelImg")
    self.Title = FXLoader:Here(root, "TitleBox")
    self.Inputs = {}
    self.Buttons = {}
    self.ResetArmed = false
    for index = 1, 3 do
        self.Inputs[index] = FXLoader:Here(root, "PopupPanelImg.Param" .. index .. "Input")
    end
    local actions = { "SetLevel", "SetRebirth", "SetMoney", "SetDiamonds", "ResetData", "SaveNow", "AddItem", "ReachRebirthLevel" }
    for index, action in ipairs(actions) do
        local button = FXLoader:Here(root, "PopupPanelImg." .. action .. "Btn")
        self.Buttons[action] = button
        -- 绑定稳定命令名，不按显示文字判断动作。
        self:TrackConnection(button.Activated:Connect(function()
            self:ExecuteCommand(action)
        end))
    end
    self.ResetTxt = FXLoader:Here(root, "PopupPanelImg.ResetDataBtn.ButtonTxt")
    local close = FXLoader:Here(root, "TitleBox.CloseSurfaceImg")
    -- 关闭隐藏当前面板，并取消尚未执行的重置确认。
    self:TrackConnection(close.Activated:Connect(function()
        self:CancelReset()
        self.Panel.Visible = false
        self.Title.Visible = false
        self:EmitUIAction("Close", {})
    end))
end

-- 每次打开用最新完整状态刷新。
function CGMPanelView:OnShow()
    self.Panel.Visible = true
    self.Title.Visible = true
    self:CancelReset()
    self:RefreshUI()
end

-- 清除本地二次确认，不改业务状态。
function CGMPanelView:CancelReset()
    self.ResetArmed = false
    self.ResetTxt.Text = "重置数据"
end

-- 校验输入后发送命令；重置需要连续两次点击。
-- @param action string 契约中声明的稳定命令名
function CGMPanelView:ExecuteCommand(action)
    if self:GetUIState().pending then
        return
    end
    if action == "ResetData" then
        if not self.ResetArmed then
            self.ResetArmed = true
            self.ResetTxt.Text = "确认重置"
            return
        end
        self:CancelReset()
        self:EmitUIAction(action, {})
        return
    end
    self:CancelReset()
    if action == "SaveNow" or action == "ReachRebirthLevel" then
        self:EmitUIAction(action, {})
        return
    end
    if action == "AddItem" then
        local itemId = tonumber(self.Inputs[1].Text)
        local count = tonumber(self.Inputs[2].Text)
        if not itemId or itemId ~= itemId or itemId < 1 or itemId > 9007199254740991 or itemId % 1 ~= 0 then
            warn("GM 参数 1 请输入正整数道具 ID")
            return
        end
        if not count or count ~= count or count < 1 or count > 9007199254740991 or count % 1 ~= 0 then
            warn("GM 参数 2 请输入正整数数量")
            return
        end
        self:EmitUIAction(action, { itemId = itemId, count = count })
        return
    end
    local value = tonumber(self.Inputs[1].Text)
    if not value or value ~= value or value < 0 or value > 9007199254740991 or value % 1 ~= 0 then
        warn("GM 参数 1 请输入非负整数")
        return
    end
    if action == "SetLevel" and value < 1 then
        warn("GM 等级至少为 1")
        return
    end
    self:EmitUIAction(action, {
        value = value,
        param2 = self.Inputs[2].Text,
        param3 = self.Inputs[3].Text,
    })
end

-- 渲染完整业务状态，保留正在输入的参数。
-- @param state table pending，字段缺省规则见文件头
function CGMPanelView:Render(state)
    for action, button in pairs(self.Buttons) do
        self:SetButtonEnabled(button, not state.pending)
    end
    if state.pending then
        self:CancelReset()
    end
end

-- 真实游戏和模拟接入分别覆写本方法。
-- @param action string 稳定命令名
-- @param payload table 对应命令参数，见文件头
function CGMPanelView:OnUIAction(action, payload)
    error("GM integration must implement OnUIAction")
end

return CGMPanelView
