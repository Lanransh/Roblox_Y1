-- 编辑器回归接入：临时替换 integration 运行，完成后恢复 WorldTeleportPreview。
local FX = _G.FX
local CWorldTeleportTests = FX.Class("CWorldTeleportTests", "CWorldTeleportView")

-- 使用最小配置测试可选配色的缺省行为。
-- @param owner table 编辑器组件宿主
function CWorldTeleportTests:Ctor(owner)
    CWorldTeleportTests.Super.Ctor(self, owner)
    self.Config = {
        worlds = {
            { id = "world_1", name = "World 1", requiredLevel = 0 },
            { id = "world_2", name = "World 2", requiredLevel = 190 },
        },
    }
    self.State = {
        level = 600,
        currentWorldId = "world_2",
    }
end

-- 连续刷新验证稳定 ID、增删、排序、空列表和请求状态。
function CWorldTeleportTests:OnReady()
    CWorldTeleportTests.Super.OnReady(self)
    self:BindUIData()
    self:Show()
    local firstRow = self._rows.world_1.row
    self:RefreshUI()
    self:RefreshUI()
    assert(self._rows.world_1.row == firstRow, "Repeated refresh recreated a row")
    assert(#self.ListBox:GetChildren() == 2, "Repeated refresh duplicated rows")
    local firstWorld = self.Config.worlds[1]
    local secondWorld = self.Config.worlds[2]
    self.Config.worlds = {
        secondWorld,
        { id = "world_3", name = "World 3", requiredLevel = 380 },
        firstWorld,
    }
    self:RefreshUI()
    assert(#self.ListBox:GetChildren() == 3, "Addition failed")
    assert(self._rows.world_1.row == firstRow, "Sorting recreated a row")
    assert(self._rows.world_1.row.LayoutOrder == 3, "Sorting failed")
    self.Config.worlds = { firstWorld }
    self:RefreshUI()
    assert(#self.ListBox:GetChildren() == 1, "Removal failed")
    assert(self._rows.world_2 == nil and self._rows.world_3 == nil, "Removed IDs retained")
    self.Config.worlds = {}
    self:RefreshUI()
    assert(#self.ListBox:GetChildren() == 0, "Empty list retained rows")
    assert(self.EmptyTxt.Visible, "Empty state missing")
    self.Config.worlds = {
        firstWorld,
        secondWorld,
        { id = "world_3", name = "World 3", requiredLevel = 380 },
    }
    self.State.pendingWorldId = "world_3"
    self.State.error = "Teleport failed. Please try again."
    self:RefreshUI()
    assert(not self.EmptyTxt.Visible, "Empty state not cleared")
    assert(self._rows.world_3.buttonTxt.Text == "Teleporting", "Pending text missing")
    assert(self.ErrorTxt.Text == "Teleport failed. Please try again." and self.ErrorTxt.Visible, "Error state missing")
    print("PASS: stable IDs, addition, removal, reorder, repeated refresh, empty, pending, error")
end

-- 关闭测试界面；请求态不应分发传送动作。
-- @param action string 本测试仅允许 Close
-- @param payload table 关闭动作的空表
function CWorldTeleportTests:OnUIAction(action, payload)
    assert(action == "Close", "Pending teleport should not dispatch")
    self:Hide()
end

return CWorldTeleportTests
