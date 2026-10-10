--[[
世界传送展示与游戏接入契约

Config.worlds: 必填数组，顺序即显示顺序；空数组显示空状态。
每项 id: 必填唯一 string，稳定世界业务 ID，不使用名称或列表位置作为身份；
name: 必填 string，显示名称；requiredLevel: 必填 number，解锁等级，单位为级；
color / edgeColor: 可选十六进制 string，省略分别用 #8a4dc2 / #48246b。
State: Render 接收完整状态，不合并增量。
level: 必填 number，玩家当前等级；
currentWorldId: 必填 string，当前世界 ID；可以不在本次列表中；
pendingWorldId: 可选 string，正在请求的世界 ID，省略无请求，非 nil 时全部禁用；
error: 可选 string，失败提示，省略不显示。

最小数据示例（接入 Ctor 调用父构造之后准备）：
self.Config = { worlds = {
    { id = "world_1", name = "World 1", requiredLevel = 0 },
} }
self.State = { level = 318, currentWorldId = "world_1" }

GetUIConfig / GetUIState 默认读取 self.Config / self.State。
首次刷新前备齐数据；异步数据未准备好时不要 Show。
接入 OnReady 先调用父方法，再 BindUIData、Show。
后续更新 Config 或完整 State 后调用 RefreshUI；列表按 id 增删、更新、排序。
条目外观来自隐藏 Templates.WorldRowTemplate，不写回设计文档。

必需覆写 OnUIAction(action, payload)，无返回值：
Teleport: payload = { worldId: string }，目标配置的稳定世界 ID。
Close: payload = {}，由接入层 Hide；无其他必需或页面专用可选覆写。
真实业务必须在服务器验证世界、等级与权限，并执行真实传送。
请求前设置 pendingWorldId、清空 error 并刷新；结果返回后清空 pendingWorldId，
成功更新 currentWorldId，失败填写 error，每次更新后 RefreshUI。
展示按钮禁用不是服务端校验；Preview 只改模拟状态，不执行真实传送。
本界面不需要静态图标资源，Stud 使用项目模板已有纹理。
]]
local FX = _G.FX
local FXLoader = FX.Loader
local CWorldTeleportView = FX.Class("CWorldTeleportView", "CUIView")

-- 绑定固定窗口与隐藏条目原型，关闭事件只连接一次。
function CWorldTeleportView:OnReady()
    local root = FXLoader:PlayerGui("WorldTeleportUI")
    self.ListBox = FXLoader:Here(root, "WindowBox.PopupPanelImg.WorldListBox")
    self.EmptyTxt = FXLoader:Here(root, "WindowBox.PopupPanelImg.EmptyTxt")
    self.ErrorTxt = FXLoader:Here(root, "WindowBox.ErrorTxt")
    self.RowTemplate = FXLoader:Here(root, "Templates.WorldRowTemplate")
    self._rows = {}
    local closeBtn = FXLoader:Here(root, "WindowBox.TitleBox.CloseSurfaceImg.CloseBtn")
    -- 关闭动作由接入层处理，不销毁设计节点。
    self:TrackConnection(closeBtn.Activated:Connect(function()
        self:EmitUIAction("Close", {})
    end))
end

-- 每次打开读取最新配置和完整状态，不重复绑定事件。
function CWorldTeleportView:OnShow()
    self:RefreshUI()
end

-- 新业务 ID 才克隆完整原型，注册事件及独立释放函数。
-- @param worldId string 稳定世界业务 ID
-- @return table 条目节点、按钮及释放函数
function CWorldTeleportView:CreateRow(worldId)
    local row = self.RowTemplate:Clone()
    row.Name = "WorldRow_" .. worldId
    row.Parent = self.ListBox
    row.Visible = true
    local button = FXLoader:Here(row, "TravelBtn")
    -- 点击读取最新状态，传送动作只携带稳定世界 ID。
    local connection = self:TrackConnection(button.Activated:Connect(function()
        local state = self:GetUIState()
        local world = self._rows[worldId].world
        if state.pendingWorldId or state.currentWorldId == worldId then
            return
        end
        if state.level < world.requiredLevel then
            return
        end
        self:EmitUIAction("Teleport", { worldId = worldId })
    end))
    -- 移除时只释放本条目拥有的连接与克隆节点。
    local release = self:TrackCleanup(function()
        connection:Disconnect()
        row:Destroy()
    end)
    return {
        row = row,
        button = button,
        nameTxt = FXLoader:Here(row, "WorldNameTxt"),
        buttonTxt = FXLoader:Here(button, "ButtonTxt"),
        rowEdge = FXLoader:Here(row, "BottomEdgeImg"),
        buttonEdge = FXLoader:Here(button, "BottomEdgeImg"),
        release = release,
    }
end

-- 按完整配置更新列表，按稳定 ID 复用、排序、清理条目。
-- @param state table 文件头定义的完整 State
function CWorldTeleportView:Render(state)
    local worlds = self:GetUIConfig().worlds
    local seen = {}
    for index, world in ipairs(worlds) do
        assert(not seen[world.id], "Duplicate world ID: " .. world.id)
        seen[world.id] = true
        local record = self._rows[world.id]
        if not record then
            record = self:CreateRow(world.id)
            self._rows[world.id] = record
        end
        record.world = world
        record.row.Position = UDim2.fromOffset(2, (index - 1) * 106 + 2)
        record.row.LayoutOrder = index
        record.row.BackgroundColor3 = Color3.fromHex(world.color or "#8a4dc2")
        record.rowEdge.BackgroundColor3 = Color3.fromHex(world.edgeColor or "#48246b")
        record.nameTxt.Text = world.name
        local unlocked = state.level >= world.requiredLevel
        local current = state.currentWorldId == world.id
        local buttonText = "Go"
        if state.pendingWorldId == world.id then
            buttonText = "Teleporting"
        elseif current then
            buttonText = "Here"
        elseif not unlocked then
            buttonText = "Level " .. tostring(world.requiredLevel)
        end
        record.buttonTxt.Text = buttonText
        local buttonColor = "#67ed14"
        local edgeColor = "#225a07"
        if not unlocked or state.pendingWorldId then
            buttonColor = "#638079"
            edgeColor = "#263e36"
        end
        record.button.BackgroundColor3 = Color3.fromHex(buttonColor)
        record.buttonEdge.BackgroundColor3 = Color3.fromHex(edgeColor)
        self:SetButtonEnabled(record.button, unlocked and not current and not state.pendingWorldId)
    end
    for worldId, record in pairs(self._rows) do
        if not seen[worldId] then
            record.release()
            self._rows[worldId] = nil
        end
    end
    self.ListBox.CanvasSize = UDim2.fromOffset(0, math.max(0, #worlds * 106 - 10))
    self.EmptyTxt.Visible = #worlds == 0
    self.ErrorTxt.Text = state.error or ""
    self.ErrorTxt.Visible = state.error ~= nil and state.error ~= ""
end

-- 由真实游戏接入或编辑器模拟接入实现动作，无静默空处理。
-- @param action string Teleport 或 Close
-- @param payload table Teleport 的 worldId 或 Close 的空表
function CWorldTeleportView:OnUIAction(action, payload)
    error("World teleport integration must implement OnUIAction: " .. action)
end

return CWorldTeleportView
