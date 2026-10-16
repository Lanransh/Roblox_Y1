local FX = _G.FX
local FXLoader = FX.Loader
local RunService = game:GetService("RunService")
local Fields = _G.PlayerDataConfig
local Guide = FX.Class("CTutorialGuideCompClass", "FCTutorialGuideCompClass")

--- 使用现有同步字段，不向服务端发送完成请求。
--- @return string 组件协作名称。
function Guide:GetCompName()
    return "CTutorialGuideComp"
end

--- 两端共用步骤语义。
--- @return table 引导配置。
function Guide:GetGuideConfig()
    return _G.TutorialGuideConfig
end

--- 复用框架持久进度。
--- @return table 引导字段。
function Guide:GetGuideStorage()
    return Fields.Guide
end

--- 创建独立提示层，角色重生不销毁；先准备展示再回放同步状态。
function Guide:OnReady()
    self._localization = self:RequireComponent("FCCommonUIComp").Localization
    self._screen = Instance.new("ScreenGui")
    self._screen.Name = "TutorialGuideUI"
    self._screen.ResetOnSpawn = false
    self._screen.DisplayOrder = 20
    self._label = Instance.new("TextLabel")
    self._label.Name = "Instruction"
    self._label.AnchorPoint = Vector2.new(0.5, 0)
    self._label.Position = UDim2.fromScale(0.5, 0.17)
    self._label.Size = UDim2.new(0.8, 0, 0, 72)
    self._label.BackgroundTransparency = 1
    self._label.Font = Enum.Font.GothamBold
    self._label.TextSize = 24
    self._label.TextWrapped = true
    self._label.TextColor3 = Color3.fromRGB(255, 223, 75)
    self._label.TextStrokeTransparency = 0
    self._label.AutoLocalize = false
    self._label.Text = ""
    self._label.Parent = self._screen
    self._screen.Parent = self:GetPlayerNode():WaitForChild("PlayerGui")
    self:TrackConnection(self._localization.Changed:Connect(function()
        self:RefreshText()
    end))
    Guide.Super.OnReady(self)
end

--- 切换语言时按稳定 Key 更新提示。
function Guide:RefreshText()
    self._label.Text = self._activeTarget and self._localization:FormatByKey(self._activeTarget.key) or ""
end

--- 每四分之一秒重选动态掉落目标，不重复创建箭头。
--- @param target table 服务端同步的目标。
function Guide:OnEnterGuide(target)
    self._activeTarget = target
    self:RefreshText()
    self:RefreshTarget()
    local elapsed = 0
    self._targetConnection = RunService.Heartbeat:Connect(function(dt)
        elapsed += dt
        if elapsed >= 0.25 then
            elapsed = 0
            self:RefreshTarget()
        end
    end)
end

--- 退出步骤清理动态目标与旧提示。
--- @param target table 刚结束的目标，由框架提供。
function Guide:OnExitGuide(target)
    if self._targetConnection then
        self._targetConnection:Disconnect()
        self._targetConnection = nil
    end
    self._activeTarget = nil
    self:HideGuideArrow()
    self:RefreshText()
end

--- 仅指向本人的有效掉落；尚无掉落时指向首关开路。
--- @return Vector3? 最近目标坐标。
function Guide:GetNearestLootPosition()
    local character = self:GetPlayerCharacter()
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then
        return nil
    end
    local position, distance = nil, math.huge
    for index, node in ipairs(workspace:GetChildren()) do
        if node:IsA("Model") and node:GetAttribute("OwnerUserId") == self:GetPlayerId()
            and node:GetAttribute("DropId") and node:GetAttribute("DropExpiresAt") > workspace:GetServerTimeNow() then
            local candidate = node:GetPivot().Position
            local delta = (candidate - root.Position).Magnitude
            if delta < distance then
                position, distance = candidate, delta
            end
        end
    end
    local firstArea = FXLoader:Find(workspace, "GameLevelList/World1/Level_1")
    return position or (firstArea and firstArea.Position)
end

--- 解析当前地图实际节点；流出、死亡时隐藏而不保留错误方向。
function Guide:RefreshTarget()
    local target = self._activeTarget
    local character = self:GetPlayerCharacter()
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not target or not humanoid or humanoid.Health <= 0 then
        self:HideGuideArrow()
        return
    end
    local position
    if target.type == "NearestItem" then
        position = self:GetNearestLootPosition()
    elseif target.type == "Base" then
        position = _G.GameEnum.WorldTransferConfig[1].Position
    elseif target.type == "Training" then
        local field = FXLoader:Find(workspace, "BlockMeshs/World1Root/TrainingCenter/Training1")
        local platform = field and field:FindFirstChild("彩色训练台", true)
        position = platform and platform.Position
    else
        local names = {Sell = "Shop", Weapon = "PurpleHut", Aura = "BlueHut"}
        local name = names[target.type]
        local trigger = name and FXLoader:Find(workspace, "Decorations/World1Decorations/" .. name .. "/Trigger")
        position = trigger and trigger.Position
    end
    if position then
        self:ShowGuideArrowToPosition(position)
    else
        self:HideGuideArrow()
    end
end

--- 原生实体拼成有厚度的三维箭头；仅本客户端可见，不影响碰撞。
--- @param position Vector3 世界目标。
function Guide:ShowGuideArrowToPosition(position)
    self._worldTargetPosition = position
    if not self._arrowTrans then
        local decorations = FXLoader:Workspace("Decorations")
        local shaft = Instance.new("Part")
        shaft.Name = "TutorialGuideArrow"
        shaft.Size = Vector3.new(0.45, 0.4, 3)
        shaft.Anchored = true
        shaft.CanCollide, shaft.CanTouch, shaft.CanQuery = false, false, false
        shaft.Material = Enum.Material.Neon
        shaft.Color = Color3.fromRGB(255, 215, 60)
        shaft.CastShadow = false
        for index = 1, 2 do
            local arm = Instance.new("Part")
            arm.Name = "Head" .. index
            arm.Size = Vector3.new(0.5, 0.4, 1.9)
            arm.Anchored = true
            arm.CanCollide, arm.CanTouch, arm.CanQuery = false, false, false
            arm.Material, arm.Color = shaft.Material, shaft.Color
            arm.CastShadow = false
            arm.Parent = shaft
        end
        shaft.Parent = decorations
        self._arrowTrans = shaft
        self._renderSteppedConn = RunService.RenderStepped:Connect(function()
            self:UpdateGuideArrow()
        end)
    end
    self:UpdateGuideArrow()
end

--- 箭头保持水平、从角色前方指向目标，重生时自动重新跟随。
function Guide:UpdateGuideArrow()
    local character = self:GetPlayerCharacter()
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root or not self._arrowTrans or not self._worldTargetPosition then
        return
    end
    local origin = root.Position + Vector3.new(0, 3.5 + math.sin(os.clock() * 3) * 0.25, 0)
    local delta = self._worldTargetPosition - origin
    local direction = Vector3.new(delta.X, 0, delta.Z)
    if direction.Magnitude < 0.01 then
        return
    end
    local frame = CFrame.lookAt(origin + direction.Unit * 3, origin + direction.Unit * 4)
    self._arrowTrans.CFrame = frame
    self._arrowTrans.Head1.CFrame = frame * CFrame.new(-0.55, 0, -1.7) * CFrame.Angles(0, math.rad(-45), 0)
    self._arrowTrans.Head2.CFrame = frame * CFrame.new(0.55, 0, -1.7) * CFrame.Angles(0, math.rad(45), 0)
end

--- 清理提示层、刷新连接与全部箭头实例。
function Guide:Dtor()
    if self._screen then
        self:OnExitGuide(self._activeTarget)
        self._screen:Destroy()
    end
    Guide.Super.Dtor(self)
end

return Guide
