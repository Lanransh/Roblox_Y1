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
    assert(not FX.Network:InvokeServer("C2S_ActivateTool", nil))
    assert(not FX.Network:InvokeServer("C2S_BuyCheck", -1))
    FX.Network:SendMsgToServer("C2S_ClientReady")
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
