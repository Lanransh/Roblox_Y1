-- 客户端圣光礼盒：仅负责表现与一次性开盒回调，不处理奖励或刷新规则。
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local FX = _G.FX
local FXLoader = FX.Loader
local GiftDrop = {}

--- 注册个人礼盒通知；生成表现与领取请求分离，客户端不能自行签发奖励资格。
function GiftDrop.Init()
    --- 接收服务端签发的礼盒，开盒时只提交该礼盒 ID。
    --- @param dropId string 本人礼盒的服务端唯一 ID。
    --- @param options table 服务端确定的落点、高度与降落时长。
    FX.Network:RegServerMsgCallback("S2C_SpawnGiftDrop", function(dropId, options)
        --- 将本地交互结果提交给服务端，不在客户端改写余额。
        --- @param player Player 本地开盒玩家，身份由网络层认证。
        --- @return boolean 服务端是否已成功发奖。
        GiftDrop.Spawn(options, function(player)
            return FX.Network:InvokeServer("C2S_OpenGiftDrop", dropId)
        end)
    end)
end

--- 在指定地面位置生成本地礼盒；模型底部对齐落点，落地后才允许打开。
--- @param options table Position 为地面 Vector3，Height 为降落高度，Duration 为降落秒数。
--- @param onOpened function 本地交互回调，参数为 Player；返回 false 保留礼盒，其余返回值视为成功。
--- @return table 礼盒句柄，可调用 Destroy 提前取消并清理。
function GiftDrop.Spawn(options, onOpened)
    assert(RunService:IsClient(), "GiftDrop is client-only")
    assert(typeof(options.Position) == "Vector3", "Position must be a Vector3")
    assert(type(options.Height) == "number" and options.Height > 0 and options.Height < math.huge,
        "Height must be finite and positive")
    assert(type(options.Duration) == "number" and options.Duration > 0 and options.Duration < math.huge,
        "Duration must be finite and positive")
    assert(type(onOpened) == "function", "onOpened must be a function")

    local template = FXLoader:Shared("Giftbox")
    local container = Instance.new("Model")
    container.Name = "ClientGiftDrop"
    local gift = template:Clone()
    local parts = {}
    for nodeIndex, node in ipairs(gift:GetDescendants()) do
        if node:IsA("BaseScript") then
            node:Destroy()
        elseif node:IsA("BasePart") then
            node.Anchored = true
            node.CanCollide = false
            node.CanTouch = false
            node.CanQuery = false
            table.insert(parts, node)
        end
    end
    assert(#parts > 0, "Giftbox must contain a BasePart")
    local pivot = gift:GetPivot()
    local box, size = gift:GetBoundingBox()
    local landing = CFrame.new(options.Position + Vector3.new(0,
        pivot.Position.Y - (box.Position.Y - size.Y / 2), 0)) * pivot.Rotation
    gift:PivotTo(landing + Vector3.new(0, options.Height, 0))
    gift.Parent = container

    local anchor = Instance.new("Part")
    anchor.Name = "HolyLight"
    anchor.Size = Vector3.one
    anchor.Anchored = true
    anchor.CanCollide = false
    anchor.CanTouch = false
    anchor.CanQuery = false
    anchor.Transparency = 1
    anchor.Position = options.Position
    anchor.Parent = container
    local bottom = Instance.new("Attachment")
    bottom.Parent = anchor
    local top = Instance.new("Attachment")
    top.Position = Vector3.new(0, options.Height + size.Y, 0)
    top.Parent = anchor
    local beam = Instance.new("Beam")
    beam.Attachment0 = top
    beam.Attachment1 = bottom
    beam.FaceCamera = true
    beam.Width0 = math.max(size.X, size.Z) * 0.8
    beam.Width1 = beam.Width0 * 1.4
    beam.Color = ColorSequence.new(Color3.fromRGB(255, 248, 205))
    beam.Transparency = NumberSequence.new(0.45)
    beam.LightEmission = 1
    beam.LightInfluence = 0
    beam.Parent = anchor
    local light = Instance.new("PointLight")
    light.Color = Color3.fromRGB(255, 235, 160)
    light.Brightness = 2
    light.Range = 16
    light.Parent = anchor
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = ""
    prompt.ObjectText = ""
    prompt.KeyboardKeyCode = Enum.KeyCode.E
    prompt.MaxActivationDistance = 10
    prompt.HoldDuration = 0.5
    prompt.RequiresLineOfSight = false
    prompt.Enabled = false
    prompt.Parent = parts[1]
    local handle = {}
    local elapsed = 0
    local destroyed = false
    local opening = false
    local updateConnection
    local promptConnection

    --- 提前取消本地礼盒，释放动画、交互连接与全部生成实例。
    function handle:Destroy()
        if destroyed then
            return
        end
        destroyed = true
        updateConnection:Disconnect()
        promptConnection:Disconnect()
        container:Destroy()
    end

    --- 只接受本地存活玩家近距离开盒，先锁定状态以阻止重复回调。
    --- @param player Player 原生交互提示触发的玩家。
    promptConnection = prompt.Triggered:Connect(function(player)
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if destroyed or opening or elapsed < options.Duration or player ~= Players.LocalPlayer
            or not root or not humanoid or humanoid.Health <= 0
            or (root.Position - parts[1].Position).Magnitude > prompt.MaxActivationDistance then
            return
        end
        opening = true
        prompt.Enabled = false
        local success, accepted = pcall(onOpened, player)
        if destroyed then
            return
        end
        opening = false
        if success and accepted ~= false then
            handle:Destroy()
        else
            prompt.Enabled = true
            if not success then
                warn("Gift opening failed: " .. tostring(accepted))
            end
        end
    end)

    --- 按帧平滑降落，抵达地面后开放交互。
    --- @param deltaTime number 本帧经过的秒数。
    updateConnection = RunService.RenderStepped:Connect(function(deltaTime)
        if not container.Parent then
            handle:Destroy()
            return
        end
        elapsed += deltaTime
        local progress = math.min(elapsed / options.Duration, 1)
        gift:PivotTo(landing + Vector3.new(0, options.Height * (1 - progress), 0))
        prompt.Enabled = progress >= 1
        if progress >= 1 then
            updateConnection:Disconnect()
        end
    end)
    container.Parent = FXLoader:Workspace("Decorations")
    return handle
end

return GiftDrop
