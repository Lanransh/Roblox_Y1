-- Studio Client；运行实际 Roblox GUI 实例和回调，所有临时 UI 均销毁。
assert(game:GetService("RunService"):IsStudio(), "Studio only")
local FX, FC = _G.FX, _G.FC
local object = FC.PlayerObject
assert(object and object._ready, "Handshake required")
local results = {}
local function Check(name, body)
    local ok, err = pcall(body)
    table.insert(results, { name = name, passed = ok, error = not ok and tostring(err) or nil })
end
Check("common UI and friend components attached at startup", function()
    local ui = object:RequireComponent("FCCommonUIComp")
    assert(ui.Root:IsA("ScreenGui") and ui.Root.Parent == game.Players.LocalPlayer.PlayerGui)
    assert(ui.Root.ResetOnSpawn == false and not ui.Modal.Visible)
    assert(object:RequireComponent("FCFriendComp"))
end)
local ui = FC.CommonUICompClass.New(object)
Check("native modal scroll content and exactly-once confirmation", function()
    local calls = 0
    ui:ShowConfirm({
        Desc = "通用确认弹窗",
        ConfirmCB = function()
            calls += 1
        end,
    })
    task.wait()
    assert(ui.Modal.Visible and ui.Cancel.Visible and ui.Confirm:IsA("TextButton"))
    assert(ui.Description.Parent:IsA("ScrollingFrame"))
    assert(ui.Confirm.AbsoluteSize.Y >= 40 and ui.Confirm.AbsoluteSize.X > 0)
    ui:_Finish(true)
    ui:_Finish(true)
    assert(calls == 1 and not ui.Modal.Visible)
end)
Check("toast replacement timer and destructor release native resources", function()
    ui:ShowTips("旧提示", 0.05)
    ui:ShowTips("新提示", 0.3)
    task.wait(0.1)
    assert(ui.Tips.Visible and ui.Tips.Text == "新提示")
    task.wait(0.3)
    assert(not ui.Tips.Visible)
end)
ui:ShowTips("待销毁", 10)
local root, connections = ui.Root, table.clone(ui._connections)
ui:Dtor()
Check("UI destructor disconnects buttons and cancels toast timer", function()
    assert(root.Parent == nil)
    for _, connection in ipairs(connections) do
        assert(not connection.Connected)
    end
    assert(coroutine.status(ui._tipTask) == "dead")
end)
Check("friend snapshot request uses authenticated identity", function()
    local state = FX.Network:InvokeServer("C2S_GetFriendState", 999999999, { 1, 2, 3 })
    task.wait()
    local friend = object:RequireComponent("FCFriendComp")
    local received = friend:GetState()
    assert(received.revision >= state.revision)
    assert(received.status == "Ready" or received.status == "Unavailable" or received.status == "Loading")
    if received.status ~= "Ready" then
        assert(friend:GetFriendCountInRoom() == nil)
    end
end)
return results
