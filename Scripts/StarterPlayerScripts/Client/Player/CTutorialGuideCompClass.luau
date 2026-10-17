local FX = _G.FX
local FXLoader = FX.Loader
local RunService = game:GetService("RunService")
local Fields = _G.PlayerDataConfig
local Guide = FX.Class("CTutorialGuideCompClass", "FCTutorialGuideCompClass")
local UPGRADE_TEXT = {Weapon = "Buy a stronger pickaxe!", Aura = "Buy a stronger aura!"}

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
    self._screen.RootLocalizationTable = FXLoader:Shared("Shared/Localization")
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
    self:WatchDataChanged(Fields.Money, self.RefreshUpgradeHint, self)
    self:WatchDataChanged(Fields.WeaponData, self.RefreshUpgradeHint, self)
    self:WatchDataChanged(Fields.AuraData, self.RefreshUpgradeHint, self)
    local elapsed = 0
    self:TrackConnection(RunService.Heartbeat:Connect(function(dt)
        elapsed += dt
        if elapsed >= 0.25 then
            elapsed = 0
            self:RefreshTarget()
        end
    end))
end

--- 切换语言时按稳定 Key 更新提示。
function Guide:RefreshText()
    local target = self._activeTarget
    self._label.AutoLocalize = target ~= nil and target.upgrade == true
    if target and target.upgrade then
        -- 固定英文源文案交由 Roblox 自动本地化，动态新手文案沿用项目翻译器。
        self._label.Text = UPGRADE_TEXT[target.type]
    else
        self._label.Text = target and self._localization:FormatByKey(target.key) or ""
    end
end

--- 主流程完成后由余额与解锁状态决定购买提示，替代一次性的首光环表现。
--- @param guideData table 服务端同步的引导进度。
function Guide:OnGuideDataChanged(guideData)
    local first = guideData.guideMap and guideData.guideMap.FirstLootGuide
    self._mainGuideFinished = first ~= nil and first.state == "Finished"
    if self._mainGuideFinished then
        Guide.Super.OnGuideDataChanged(self, {target = {type = "None"}})
        self:RefreshUpgradeHint()
    else
        Guide.Super.OnGuideDataChanged(self, guideData)
    end
end

--- 只推荐强于全部已拥有装备且尚未购买的商品；同时可升级时优先镐子。
--- @return string? 可购买升级的商店类型。
function Guide:GetAffordableUpgradeType()
    local coins = self:GetNumber(Fields.Money)
    local shops = {
        {type = "Weapon", configs = _G.GameConfig.ToolConfig, field = Fields.WeaponData, id = "ToolId"},
        {type = "Aura", configs = _G.GameConfig.AuraConfig, field = Fields.AuraData, id = "AuraId"},
    }
    for index, shop in ipairs(shops) do
        local owned = self:GetTable(shop.field).owned
        local strongest = 1
        for configIndex, config in ipairs(shop.configs) do
            if owned[tostring(config[shop.id])] == true then
                strongest = math.max(strongest, config.TrainingRate)
            end
        end
        for configIndex, config in ipairs(shop.configs) do
            if config.TrainingRate > strongest and config.Price <= coins
                and owned[tostring(config[shop.id])] ~= true then
                return shop.type
            end
        end
    end
    return nil
end

--- 金币变化、购买与装备同步后立即切换或隐藏主界面的购买提示。
function Guide:RefreshUpgradeHint()
    if not self._mainGuideFinished then
        return
    end
    local shopType = self:GetAffordableUpgradeType()
    if self._activeTarget and self._activeTarget.type == shopType then
        return
    end
    self:OnExitGuide(self._activeTarget)
    if shopType then
        self:OnEnterGuide({type = shopType, key = "Upgrade." .. shopType, upgrade = true})
    end
end

--- 进入步骤时展示服务端目标，定期恢复角色重生后的箭头。
--- @param target table 服务端同步的目标。
function Guide:OnEnterGuide(target)
    self._activeTarget = target
    self:RefreshText()
    self:RefreshTarget()
end

--- 退出步骤清理动态目标与旧提示。
--- @param target table 刚结束的目标，由框架提供。
function Guide:OnExitGuide(target)
    self._activeTarget = nil
    self:HideGuideArrow()
    self:RefreshText()
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
        local coordinates = target.position
        position = coordinates and Vector3.new(coordinates[1], coordinates[2], coordinates[3])
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

--- 两个连接点把空中的箭头光束直接连接到当前目标。
--- @param position Vector3 世界目标。
function Guide:ShowGuideArrowToPosition(position)
    self._worldTargetPosition = position
    if not self._arrowTrans then
        local decorations = FXLoader:Workspace("Decorations")
        local arrow = Instance.new("Part")
        arrow.Name = "TutorialGuideArrow"
        arrow.Size = Vector3.new(0.1, 0.1, 0.1)
        arrow.Anchored = true
        arrow.CanCollide, arrow.CanTouch, arrow.CanQuery = false, false, false
        arrow.Transparency = 1
        arrow.CastShadow = false
        self._arrowStart = Instance.new("Attachment")
        self._arrowStart.Name = "Start"
        self._arrowStart.Parent = arrow
        self._arrowTarget = Instance.new("Attachment")
        self._arrowTarget.Name = "Target"
        self._arrowTarget.Parent = arrow
        local beam = Instance.new("Beam")
        beam.Name = "TargetArrows"
        beam.Attachment0 = self._arrowStart
        beam.Attachment1 = self._arrowTarget
        beam.Texture = FXLoader:Shared("Assets/TutorialArrowTexture").Texture
        beam.TextureMode = Enum.TextureMode.Wrap
        beam.TextureLength = 3
        beam.TextureSpeed = 1.5
        beam.Width0, beam.Width1 = 1.4, 1.4
        beam.FaceCamera = true
        beam.Segments = 32
        beam.LightInfluence = 0
        beam.LightEmission = 0.2
        beam.Transparency = NumberSequence.new(0.05)
        beam.Enabled = false
        beam.Parent = arrow
        arrow.Parent = decorations
        self._arrowTrans = arrow
        self._arrowEffect = beam
        self._renderSteppedConn = RunService.RenderStepped:Connect(function()
            self:UpdateGuideArrow()
            self:UpdateGuideArrowAppearance()
        end)
    end
    self:UpdateGuideArrow()
    self:UpdateGuideArrowAppearance()
end

--- 起点跟随角色，终点直达目标上方；目标高度参与三维朝向计算。
function Guide:UpdateGuideArrow()
    local character = self:GetPlayerCharacter()
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not self._arrowTrans then
        return
    end
    if not root or not self._worldTargetPosition then
        self._arrowEffect.Enabled = false
        return
    end
    local lootGuide = self._activeTarget and self._activeTarget.type == "NearestItem"
    local origin = root.Position + Vector3.new(0, lootGuide and 4 or 0.5, 0)
    local target = self._worldTargetPosition + Vector3.new(0, lootGuide and 7 or 2, 0)
    local direction = target - origin
    if direction.Magnitude < 2.5 then
        self._arrowEffect.Enabled = false
        return
    end
    self._arrowTrans.Position = origin
    self._arrowStart.WorldPosition = origin + direction.Unit * 2
    self._arrowTarget.WorldPosition = target
    self._arrowEffect.Enabled = true
end

--- 光束使用沿连接线分布的彩虹渐变，箭头纹理由 Beam 自动向目标滚动。
function Guide:UpdateGuideArrowAppearance()
    local now = os.clock()
    local colors = {}
    for index = 0, 8 do
        local position = index / 8
        colors[index + 1] = ColorSequenceKeypoint.new(position, Color3.fromHSV((position - now * 0.2) % 1, 0.95, 1))
    end
    self._arrowEffect.Color = ColorSequence.new(colors)
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
