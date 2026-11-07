local FX = _G.FX
local FXLoader = FX.Loader
local RunService = game:GetService("RunService")

--- 店员挥手仅改变客户端外观，保留原有距离与动画时长。
local Component = FX.Class("CShopGreetingsCompClass", "FCPlayerCompClass")

--- 异步等待店员复制并记录初始姿势，不阻塞玩家对象及其他组件创建。
--- @param owner CPlayerObjectClass 当前客户端玩家对象。
function Component:Ctor(owner)
    Component.Super.Ctor(self, owner)
    self._greetings = {}
    self._initTask = task.defer(function()
        self:InitGreetings()
        self._initTask = nil
    end)
end

--- 提供玩家对象内唯一的组件名称。
--- @return string 商店招呼组件名称。
function Component:GetCompName()
    return "CShopGreetingsComp"
end

--- 复制完成后绑定世界一的三个店员，帧连接由组件统一释放。
--- @return nil
function Component:InitGreetings()
    local world1 = FXLoader:Workspace("Decorations/World1Decorations", math.huge)
    for index, name in ipairs({"Shop", "BlueHut", "PurpleHut"}) do
        table.insert(self._greetings, self:CreateGreeting(FXLoader:Here(world1, name, math.huge)))
    end
    self:TrackConnection(RunService.RenderStepped:Connect(function()
        self:UpdateGreetings()
    end))
end

--- 按类型等待 Humanoid，兼容 Morph 名称，并按骨架收集左臂。
--- @param hut Model 场景中已复制的商店。
--- @return table 店员肩部、手臂初始姿势及靠近状态。
function Component:CreateGreeting(hut)
    local npc = FXLoader:Here(hut, "ShopNPC", math.huge)
    local humanoid = npc:FindFirstChildOfClass("Humanoid")
    while not humanoid do
        npc.ChildAdded:Wait()
        humanoid = npc:FindFirstChildOfClass("Humanoid")
    end
    local isR15 = humanoid.RigType == Enum.HumanoidRigType.R15
    local torso = FXLoader:Here(npc, isR15 and "UpperTorso" or "Torso", math.huge)
    local armNames = isR15 and {"LeftUpperArm", "LeftLowerArm", "LeftHand"} or {"Left Arm"}
    local attachment = torso:FindFirstChild("LeftShoulderRigAttachment")
    local shoulderPosition = attachment and attachment.WorldPosition
        or torso.CFrame:PointToWorldSpace(Vector3.new(-torso.Size.X * 0.5, torso.Size.Y * 0.5, 0))
    local shoulder = CFrame.new(shoulderPosition) * torso.CFrame.Rotation
    local parts = {}
    for index, name in ipairs(armNames) do
        local part = FXLoader:Here(npc, name, math.huge)
        table.insert(parts, {part = part, rest = part.CFrame, offset = shoulder:ToObjectSpace(part.CFrame)})
    end
    return {torso = torso, shoulder = shoulder, parts = parts, inside = false, started = nil}
end

--- 进入 70 格内挥手一次，离开 80 格或死亡后还原并允许再次触发。
function Component:UpdateGreetings()
    local character = self:GetPlayerCharacter()
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local now = os.clock()
    for index, greeting in ipairs(self._greetings) do
        local distance = math.huge
        if root and humanoid and humanoid.Health > 0 then
            distance = (root.Position - greeting.torso.Position).Magnitude
        end
        if not greeting.inside and distance <= 70 then
            greeting.inside = true
            greeting.started = now
        elseif greeting.inside and distance >= 80 then
            greeting.inside = false
            greeting.started = nil
            self:RestoreGreeting(greeting)
        end
        if greeting.started then
            local elapsed = now - greeting.started
            local blend = math.min(elapsed / 0.35, (2.4 - elapsed) / 0.35, 1)
            if elapsed >= 2.4 then
                greeting.started = nil
                self:RestoreGreeting(greeting)
            else
                local angle = math.rad(-140 + 16 * math.sin(elapsed * math.pi * 4)) * math.max(blend, 0)
                local pose = greeting.shoulder * CFrame.Angles(0, 0, angle)
                for partIndex, entry in ipairs(greeting.parts) do
                    entry.part.CFrame = pose * entry.offset
                end
            end
        end
    end
end

--- 还原左臂初始姿势，避免挥手结束或释放后残留动作。
--- @param greeting table 当前店员的手臂姿势记录。
function Component:RestoreGreeting(greeting)
    for partIndex, entry in ipairs(greeting.parts) do
        entry.part.CFrame = entry.rest
    end
end

--- 取消复制等待、断开帧回调，再恢复全部店员的初始姿势。
function Component:Dtor()
    if self._initTask then
        task.cancel(self._initTask)
    end
    Component.Super.Dtor(self)
    for index, greeting in ipairs(self._greetings) do
        self:RestoreGreeting(greeting)
    end
end

return Component
