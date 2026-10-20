-- 客户端圣光礼盒：仅负责表现与一次性开盒回调，不处理奖励或刷新规则。
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local FX, FC = _G.FX, _G.FC
local FXLoader = FX.Loader
local Text = FXLoader:RequireShared("Scripts/Game/Shared/Text")
local TranslationTexts = {
    ["Ready"] = { Key = "GiftDrop.Ready", Source = "Gifts ready to collect!" },
    ["Complete"] = { Key = "GiftDrop.Complete", Source = "All gifts collected today" },
}
local GiftDrop = {}

--- 注册个人礼盒通知；生成表现与领取请求分离，客户端不能自行签发奖励资格。
function GiftDrop.Init()
    local handles = {}
    local countdowns = {}
    for worldIndex = 1, 3 do
        local countdown = FXLoader:Workspace("Decorations/World" .. worldIndex
            .. "Decorations/MysteryGiftLanding/CountdownSign/Display/Countdown")
        countdown.AutoLocalize = false
        table.insert(countdowns, countdown)
    end
    local secondsLeft
    local hasDrops = false
    --- 根据服务端个人在线进度刷新世界牌子，云端语言变化时复用最新状态。
    local function RefreshCountdown()
        local text
        if secondsLeft == nil then
            text = "--:--"
        elseif secondsLeft >= 0 then
            text = string.format("%02d:%02d", math.floor(secondsLeft / 60), secondsLeft % 60)
        elseif hasDrops then
            text = Text.Tr(TranslationTexts.Ready)
        else
            text = Text.Tr(TranslationTexts.Complete)
        end
        for countdownIndex, countdown in ipairs(countdowns) do
            countdown.Text = text
        end
    end
    --- 仅展示服务端计算的剩余时间，不在客户端签发到期资格。
    --- @param seconds number 下一档剩余秒数，-1 表示今日档位全部到期。
    --- @param pending boolean 是否仍有待领取的礼盒。
    FX.Network:RegServerMsgCallback("S2C_GiftDropCountdown", function(seconds, pending)
        secondsLeft = seconds
        hasDrops = pending
        RefreshCountdown()
    end)
    FC.Localization.Changed:Connect(RefreshCountdown)
    RefreshCountdown()
    --- 跨日释放旧礼盒，移除已经失效的领取资格。
    FX.Network:RegServerMsgCallback("S2C_ClearGiftDrops", function()
        for dropId, handle in pairs(handles) do
            handle:Destroy()
        end
        table.clear(handles)
    end)
    --- 接收服务端签发的礼盒，开盒时只提交该礼盒 ID。
    --- @param dropId string 本人礼盒的服务端唯一 ID。
    --- @param options table 服务端确定的落点、高度与降落时长。
    FX.Network:RegServerMsgCallback("S2C_SpawnGiftDrop", function(dropId, options)
        --- 将本地交互结果提交给服务端，不在客户端改写余额。
        --- @param player Player 本地开盒玩家，身份由网络层认证。
        --- @return boolean 服务端是否已成功发奖。
        handles[dropId] = GiftDrop.Spawn(options, function(player)
            local accepted = FX.Network:InvokeServer("C2S_OpenGiftDrop", dropId)
            if accepted then
                handles[dropId] = nil
            end
            return accepted
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
    local landingRing = Instance.new("Model")
    landingRing.Name = "LandingRing"
    for segment = 1, 24 do
        local angle = (segment - 1) * math.pi * 2 / 24
        local marker = Instance.new("Part")
        marker.Name = "LightSegment"
        marker.Size = Vector3.new(0.16, 0.06, 6.8 * math.sin(math.pi / 24))
        marker.CFrame = CFrame.new(options.Position + Vector3.new(0, 0.07, 0))
            * CFrame.Angles(0, angle, 0) * CFrame.new(3.4, 0, 0)
        marker.Color = Color3.fromRGB(255, 224, 145)
        marker.Material = Enum.Material.Neon
        marker.Transparency = 0.35
        marker.Anchored = true
        marker.CanCollide = false
        marker.CanTouch = false
        marker.CanQuery = false
        marker.Parent = landingRing
    end
    landingRing.Parent = container
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
    prompt.ActionText = "Pick Up"
    prompt.ObjectText = ""
    prompt.AutoLocalize = true
    prompt.RootLocalizationTable = FXLoader:Shared("Shared/Localization")
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
            landingRing:Destroy()
            updateConnection:Disconnect()
        end
    end)
    container.Parent = FXLoader:Workspace("Decorations")
    return handle
end

return GiftDrop
