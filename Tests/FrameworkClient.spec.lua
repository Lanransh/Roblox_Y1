-- 先执行服务端测试以产生同步字段；通过 MCP 注入正常 LocalScript 执行。
local FX, FC = _G.FX, _G.FC
local object = assert(FC.PlayerObject)
assert(object._ready, "Handshake not finished")
local results = {}
--- @param label string 测试行为。
--- @param body function 断言测试体。
local function Check(label, body)
    local ok, err = pcall(body)
    table.insert(results, { name = label, passed = ok, error = not ok and tostring(err) or nil })
end
Check("client-false-sync-private-field-and-late-watch", function()
    assert(object._playerData.MigrationTestFlag == false)
    assert(object._playerData.MigrationPrivateFlag == nil)
    local called = false
    local connection = object:WatchDataChanged(
        { Type = "boolean", Key = "MigrationTestFlag", DefVal = true },
        function(value)
            called = value == false
        end
    )
    assert(called)
    connection:Disconnect()
    assert(FX.SyncManager:GetFlag({ Type = "boolean", Key = "MigrationTestFlag", DefVal = true }) == false)
end)
Check("remote-authenticated-rpc-and-invalid-arguments", function()
    assert(type(FX.Network:InvokeServer("C2S_GetServerTime")) == "number")
    assert(not FX.Network:InvokeServer("C2S_CanUseItem", -1, -1))
    assert(not FX.Network:InvokeServer("C2S_SwapGrid", "1", 2))
    assert(not FX.Network:InvokeServer("C2S_BuyCheck", -1))
    FX.Network:SendMsgToServer("C2S_ClientReady")
end)
Check("native-ui-inventory-filter-sort-select-and-destroy", function()
    local gui = Instance.new("ScreenGui")
    gui.Name = "FrameworkMigrationTest"
    gui.ResetOnSpawn = false
    gui.Parent = game.Players.LocalPlayer.PlayerGui
    local root = Instance.new("Frame", gui)
    root.Size = UDim2.fromOffset(600, 350)
    local shortcut = Instance.new("Frame", root)
    shortcut.Size = UDim2.fromOffset(600, 60)
    local backpack = Instance.new("Frame", root)
    backpack.Position = UDim2.fromOffset(0, 70)
    backpack.Size = UDim2.fromOffset(600, 280)
    Instance.new("UIGridLayout", shortcut)
    Instance.new("UIGridLayout", backpack)
    local template = Instance.new("TextButton", gui)
    template.Size = UDim2.fromOffset(60, 50)
    template.Visible = false
    local selected = Instance.new("Frame", template)
    selected.Name = "SelectedIcon"
    selected.Visible = false
    local Class = FX.GetClass("MigrationInventoryUI") or FX.Class("MigrationInventoryUI", "FCInventoryCompClass")
    function Class:GetInventoryListNodeMap()
        return {
            shortcut = { listNode = shortcut, templateNode = template },
            backpack = { listNode = backpack, templateNode = template },
            dragParentNode = gui,
        }
    end
    function Class:RefreshBackpackGridNode(index, grid, node)
        node.Text = tostring(grid)
    end
    function Class:RefreshShortcutGridNode(index, node)
        node.Text = tostring(index)
    end
    function Class:OnSelectBackpackGrid(context) end
    --- @param data table 格子数据。
    --- @param index number 实际格号。
    --- @param filter string 筛选类型。
    --- @return boolean 格子是否可见。
    function Class:IsGridDataMatchFilter(data, index, filter)
        return data ~= nil and (filter ~= "Second" or data.itemId == 2)
    end
    local ui = Class.New(object)
    ui._rootNode = root
    ui:OnInventoryData({ ["58"] = { itemId = 2, stackCount = 3 }, ["9"] = { itemId = 1, stackCount = 2 } })
    assert(ui:GetItemCountById(2) == 3)
    assert(#ui._backpackRows == 2 and ui._virtualIndexToGridIndex[1] == 9)
    ui:ShowInvertory()
    ui:OnBackpackGridClicked(ui._backpackRows[1], 9)
    assert(ui._selectedBackpackGridIndex == 9)
    ui:OnFilterTabClicked("Second")
    assert(#ui._backpackRows == 1 and ui._virtualIndexToGridIndex[1] == 58)
    ui:HideInvertory()
    ui:Hide()
    assert(not root.Visible)
    ui:Show()
    assert(root.Visible)
    ui:Dtor()
    assert(#backpack:GetChildren() == 1 and #shortcut:GetChildren() == 1)
    gui:Destroy()
end)
Check("animation-key-hold-sound-lifecycle", function()
    local frame = Instance.new("Frame")
    frame.Size = UDim2.fromScale(0, 1)
    FX.GetClass("FCUICompClass") -- 类可在模块加载后独立引用。
    FC.UIAnim:Progress(frame, 0.5, 0.01)
    task.wait(0.08)
    assert(math.abs(frame.Size.X.Scale - 0.5) < 0.01)
    local hold = FC.HoldUIObjectClass.New(frame)
    local completed = false
    hold:SetHoldDuration(0.02)
    hold:SetHoldCompleteCallback(function()
        completed = true
    end)
    hold:StartHold()
    task.wait(0.1)
    assert(completed)
    hold:Dtor()
    local key = FC.KeyObjectClass.New(Enum.KeyCode.F)
    key:Dtor()
    local sound = FC.SoundCompClass.New(object, 2)
    assert(#sound._effectSoundNodeList == 2)
    local folder = sound._characterNode
    sound:Dtor()
    assert(folder.Parent == nil)
    frame:Destroy()
end)
return results
