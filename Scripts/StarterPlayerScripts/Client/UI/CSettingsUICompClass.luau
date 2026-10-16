local FX = _G.FX
local FXLoader = FX.Loader
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local Fields = _G.PlayerDataConfig
FXLoader:RequireFromParent(script, "Generated/CSettingsView")
local Component = FX.Class("CSettingsUICompClass", "CSettingsView")

--- 返回主界面打开设置所用的协作名。
--- @return string 设置组件名。
function Component:GetCompName()
    return "CSettingsUIComp"
end

--- 绑定当前设置展示类并恢复服务端保存的偏好，不再等待已删除的旧选项。
function Component:OnReady()
    Component.Super.OnReady(self)
    local root = self:GetRootNode()
    root.ResetOnSpawn = false
    root.DisplayOrder = 10
    self:GetPlayerObject():RequireComponent("FCCommonUIComp"):RegisterTrainingClickModal(root)
    self.Config = {}
    self._auraStates = {}
    self._musicGroup = Instance.new("SoundGroup")
    self._musicGroup.Name = "SettingsMusic"
    self._musicGroup.Parent = SoundService
    self._effectsGroup = Instance.new("SoundGroup")
    self._effectsGroup.Name = "SettingsEffects"
    self._effectsGroup.Parent = SoundService
    self._sound = self:GetPlayerObject():RequireComponent("CSoundComp")
    self._sound._soundBGM.SoundGroup = self._musicGroup
    self._sound._exclusiveEffectSoundNode.SoundGroup = self._effectsGroup
    for index, sound in ipairs(self._sound._effectSoundNodeList) do
        sound.SoundGroup = self._effectsGroup
    end
    self:BindSliders()
    self:TrackConnection(workspace.DescendantAdded:Connect(function(node)
        self:ApplyAura(node)
    end))
    self:TrackConnection(workspace.DescendantRemoving:Connect(function(node)
        if self._auraStates[node] ~= nil then
            node.Enabled = self._auraStates[node]
            self._auraStates[node] = nil
        end
    end))
    self:Hide()
    self:BindUIData()
end

--- 数据同步仅在没有本地待保存操作时恢复，避免旧回包覆盖正在拖动的值。
function Component:BindUIData()
    self:WatchDataChanged(Fields.Settings, function(settings)
        if not self._saveTask and not self._drag then
            self.State = {
                musicVolume = settings.musicVolume, soundEffectsVolume = settings.soundEffectsVolume,
                showAura = settings.showAura, giantPickaxe = settings.giantPickaxe,
            }
            self:ApplySettings()
        end
    end)
end

--- 忽略生成类的鼠标滑杆计算，改由接入层处理实时布局和触摸拖动。
--- @param action string 展示类动作。
--- @param payload table 动作参数。
function Component:EmitUIAction(action, payload)
    if action == "ChangeSetting" and self.Sliders[payload.setting] then
        return
    end
    self:OnUIAction(action, payload)
end

--- 使用全局移动与抬起事件，拖出命中区仍可结束；每次读取缩放后的真实轨道。
function Component:BindSliders()
    for setting, slider in pairs(self.Sliders) do
        self:TrackConnection(slider.input.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                self._drag = {setting = setting, input = input}
                self:UpdateSlider(input)
            end
        end))
    end
    self:TrackConnection(UserInputService.InputChanged:Connect(function(input)
        if self._drag and (input == self._drag.input
            or (self._drag.input.UserInputType == Enum.UserInputType.MouseButton1
                and input.UserInputType == Enum.UserInputType.MouseMovement)) then
            self:UpdateSlider(input)
        end
    end))
    self:TrackConnection(UserInputService.InputEnded:Connect(function(input)
        if self._drag and input == self._drag.input then
            self._drag = nil
            self:SaveSettings()
        end
    end))
    self:TrackConnection(UserInputService.WindowFocusReleased:Connect(function()
        if self._drag then
            self._drag = nil
            self:SaveSettings()
        end
    end))
end

--- 根据当前轨道尺寸换算音量百分比。
--- @param input InputObject 鼠标或触摸的屏幕坐标。
function Component:UpdateSlider(input)
    local track = self.Sliders[self._drag.setting].track
    if track.AbsoluteSize.X <= 0 then
        return
    end
    local value = math.floor(math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1) * 100 + 0.5)
    self:OnUIAction("ChangeSetting", {setting = self._drag.setting, value = value})
end

--- 关闭时提交最后状态；未接入字段不参与业务或保存。
--- @param action string Close 或 ChangeSetting。
--- @param payload table 设置键和值。
function Component:OnUIAction(action, payload)
    if action == "Close" then
        self:SaveSettings()
        self:Hide()
    elseif action == "ChangeSetting" and (self.Sliders[payload.setting]
        or payload.setting == "showAura" or payload.setting == "giantPickaxe") then
        if self.State[payload.setting] == payload.value then
            return
        end
        self.State = table.clone(self.State)
        self.State[payload.setting] = payload.value
        self:ApplySettings()
        if self._saveTask then
            task.cancel(self._saveTask)
        end
        self._saveTask = task.delay(0.2, function()
            self._saveTask = nil
            self:SaveSettings()
        end)
    end
end

--- 音量分组保留原曲目音量和音效压低音乐行为；光环只影响本机显示。
function Component:ApplySettings()
    self._musicGroup.Volume = self.State.musicVolume / 100
    self._effectsGroup.Volume = self.State.soundEffectsVolume / 100
    if self._appliedShowAura ~= self.State.showAura then
        self._appliedShowAura = self.State.showAura
        for index, node in ipairs(workspace:GetDescendants()) do
            self:ApplyAura(node)
        end
    end
    self:RefreshUI()
end

--- 将独立创建的空间音效接入同一音量组，保留资源音量与空间衰减。
--- @param sound Sound 播放前的客户端音效实例。
function Component:ConfigureEffectSound(sound)
    sound.SoundGroup = self._effectsGroup
end

--- 只处理服务端装备光环粒子，保留原始 Enabled 值，不触碰其他粒子。
--- @param node Instance 当前或新复制的世界节点。
function Component:ApplyAura(node)
    if not self.State or not node:IsA("ParticleEmitter") or node.Name ~= "EquippedAura" then
        return
    end
    if self._auraStates[node] == nil then
        self._auraStates[node] = node.Enabled
    end
    node.Enabled = self.State.showAura and self._auraStates[node]
end

--- 合并拖动事件，提交音量、光环和武器尺寸偏好，沿用框架自动保存与离服保存。
function Component:SaveSettings()
    if self._saveTask then
        task.cancel(self._saveTask)
        self._saveTask = nil
    end
    FX.Network:SendMsgToServer("C2S_SaveSettings", {
        musicVolume = self.State.musicVolume,
        soundEffectsVolume = self.State.soundEffectsVolume,
        showAura = self.State.showAura,
        giantPickaxe = self.State.giantPickaxe,
    })
end

--- 关闭时停止拖动，防止隐藏界面继续修改音量。
function Component:OnHide()
    self._drag = nil
    self._activeSlider = nil
end

--- 释放本组件音量分组与延迟任务，恢复接管粒子的原始可见性。
function Component:Dtor()
    if self._saveTask then
        task.cancel(self._saveTask)
    end
    for node, enabled in pairs(self._auraStates or {}) do
        node.Enabled = enabled
    end
    if self._musicGroup then
        self._musicGroup:Destroy()
        self._effectsGroup:Destroy()
    end
    Component.Super.Dtor(self)
end

return Component
