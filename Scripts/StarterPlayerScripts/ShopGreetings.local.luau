local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local greetings = {}

--- 保存固定店员的左臂姿势，挥手只改变本地外观，不改动碰撞或商店交互。
--- @param hut Model 场景中已复制的商店。
--- @return table 店员肩部、手臂初始姿势及靠近状态。
local function CreateGreeting(hut)
    local npc = hut:WaitForChild("ShopNPC")
    local torso = npc:FindFirstChild("UpperTorso") or npc:WaitForChild("Torso")
    local arm = npc:FindFirstChild("LeftUpperArm") or npc:WaitForChild("Left Arm")
    local attachment = torso:FindFirstChild("LeftShoulderRigAttachment")
    local shoulderPosition = attachment and attachment.WorldPosition
        or torso.CFrame:PointToWorldSpace(Vector3.new(-torso.Size.X * 0.5, torso.Size.Y * 0.5, 0))
    local shoulder = CFrame.new(shoulderPosition) * torso.CFrame.Rotation
    local parts = {}
    for index, name in ipairs({arm.Name, "LeftLowerArm", "LeftHand"}) do
        local part = npc:FindFirstChild(name)
        if part then
            table.insert(parts, {part = part, rest = part.CFrame, offset = shoulder:ToObjectSpace(part.CFrame)})
        end
    end
    return {torso = torso, shoulder = shoulder, parts = parts, inside = false, started = nil}
end

for index, name in ipairs({"Shop", "BlueHut", "PurpleHut"}) do
    table.insert(greetings, CreateGreeting(workspace:WaitForChild(name)))
end

--- 玩家在进入气泡区前提前挥手一次；离开外圈才重新触发，死亡或离开时还原原姿势。
--- @param deltaTime number 引擎帧间隔，本动作按实时时钟计算以保持不同帧率下一致。
local function UpdateGreetings(deltaTime)
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local now = os.clock()
    for index, greeting in ipairs(greetings) do
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
            for partIndex, entry in ipairs(greeting.parts) do
                entry.part.CFrame = entry.rest
            end
        end
        if greeting.started then
            local elapsed = now - greeting.started
            local blend = math.min(elapsed / 0.35, (2.4 - elapsed) / 0.35, 1)
            if elapsed >= 2.4 then
                greeting.started = nil
                for partIndex, entry in ipairs(greeting.parts) do
                    entry.part.CFrame = entry.rest
                end
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

local connection = RunService.RenderStepped:Connect(UpdateGreetings)

--- 脚本释放时恢复店员姿势，防止本地挥手残留。
local function Cleanup()
    connection:Disconnect()
    for index, greeting in ipairs(greetings) do
        for partIndex, entry in ipairs(greeting.parts) do
            entry.part.CFrame = entry.rest
        end
    end
end

script.Destroying:Connect(Cleanup)
