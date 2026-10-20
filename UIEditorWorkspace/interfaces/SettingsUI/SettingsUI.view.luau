--[[
Settings 接入契约

Config: 空表；本界面不读取配置字段。
State: 必填完整快照，每次 RefreshUI 都提供全部字段。
  musicVolume: number，必填，音乐音量，0 到 100 的百分比整数。
  soundEffectsVolume: number，必填，音效音量，0 到 100 的百分比整数。
  showAura: boolean，必填，是否显示光环。
  giantPickaxe: boolean，必填，是否启用镐子尺寸巨大化。
最小数据示例：Config = {}；State = { musicVolume = 70, soundEffectsVolume = 85,
  showAura = true, giantPickaxe = false }。
首次刷新前由接入层准备完整 State；OnReady 绑定节点后调用 BindUIData、Show。
业务状态更新后替换完整 State 并调用 RefreshUI。

必需覆写 OnUIAction(action, payload)，无返回值：
  ChangeSetting: payload = { setting: string, value: number | boolean }。
    setting 为 musicVolume / soundEffectsVolume 时，value 是 0 到 100 的音量百分比。
    setting 为 showAura / giantPickaxe 时，value 是 boolean。
    giantPickaxe 的实际镐子缩放与关闭后恢复原尺寸由游戏接入层处理。
  Close: payload = {}，由接入层 Hide。
游戏接入负责保存设置并将完整 State 刷新回界面；拖动滑杆会持续发出 ChangeSetting。
编辑器 Preview 只修改本地模拟状态，不写入游戏设置。
]]

local FX = _G.FX
local FXLoader = FX.Loader
local Text = FXLoader:RequireShared("Scripts/Game/Shared/Text")
local CSettingsView = FX.Class("CSettingsView", "CUIView")

local TranslationTexts = Text.Define("SettingsUI", {
    Volume = "{value:int}%",
    On = "ON",
    Off = "OFF",
})

-- 把鼠标位置换算成百分比，并把音量变化交给接入层。
-- @param self CSettingsView 实例
-- @param setting string 稳定的音量设置字段
-- @param track Frame 音量轨道
-- @param inputButton TextButton 透明拖动命中区
local function bindSlider(self, setting, track, inputButton)
    local trackPosition = track.AbsolutePosition
    local trackSize = track.AbsoluteSize
    local trackLeft = trackPosition and trackPosition.X or 711
    local trackWidth = trackSize and trackSize.X or 190

    local function emitVolume(input)
        local position = input.Position
        if position == nil or trackWidth <= 0 then
            return
        end
        local ratio = math.clamp(
            (position.X - trackLeft) / trackWidth,
            0,
            1
        )
        local value = math.floor(ratio * 100 + 0.5)
        self:EmitUIAction("ChangeSetting", {
            setting = setting,
            value = value,
        })
    end

    self:TrackConnection(inputButton.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
            return
        end
        self._activeSlider = setting
        emitVolume(input)
    end))

    self:TrackConnection(inputButton.InputChanged:Connect(function(input)
        if self._activeSlider == setting then
            emitVolume(input)
        end
    end))

    self:TrackConnection(inputButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self._activeSlider = nil
        end
    end))
end

-- 绑定音量与开关节点；事件只连接一次。
function CSettingsView:OnReady()
    local root = FXLoader:PlayerGui("SettingsUI")

    self.Sliders = {
        musicVolume = {
            value = FXLoader:Here(root, "SettingsPanel.ContentBox.MusicRowImg.ValueTxt"),
            track = FXLoader:Here(root, "SettingsPanel.ContentBox.MusicRowImg.MusicTrackImg"),
            fill = FXLoader:Here(root, "SettingsPanel.ContentBox.MusicRowImg.MusicTrackImg.MusicFillImg"),
            knob = FXLoader:Here(root, "SettingsPanel.ContentBox.MusicRowImg.MusicTrackImg.MusicKnobImg"),
            input = FXLoader:Here(root, "SettingsPanel.ContentBox.MusicRowImg.MusicTrackImg.MusicInputBtn"),
        },
        soundEffectsVolume = {
            value = FXLoader:Here(root, "SettingsPanel.ContentBox.SoundEffectsRowImg.ValueTxt"),
            track = FXLoader:Here(root, "SettingsPanel.ContentBox.SoundEffectsRowImg.SoundEffectsTrackImg"),
            fill = FXLoader:Here(root, "SettingsPanel.ContentBox.SoundEffectsRowImg.SoundEffectsTrackImg.SoundEffectsFillImg"),
            knob = FXLoader:Here(root, "SettingsPanel.ContentBox.SoundEffectsRowImg.SoundEffectsTrackImg.SoundEffectsKnobImg"),
            input = FXLoader:Here(root, "SettingsPanel.ContentBox.SoundEffectsRowImg.SoundEffectsTrackImg.SoundEffectsInputBtn"),
        },
    }

    for setting, slider in pairs(self.Sliders) do
        bindSlider(self, setting, slider.track, slider.input)
    end

    self.Toggles = {
        giantPickaxe = {
            button = FXLoader:Here(root, "SettingsPanel.ContentBox.GiantPickaxeRowImg.GiantPickaxeBtn"),
            edge = FXLoader:Here(root, "SettingsPanel.ContentBox.GiantPickaxeRowImg.GiantPickaxeBtn.BottomEdgeImg"),
            text = FXLoader:Here(root, "SettingsPanel.ContentBox.GiantPickaxeRowImg.GiantPickaxeBtn.ButtonTxt"),
        },
        showAura = {
            button = FXLoader:Here(root, "SettingsPanel.ContentBox.ShowAuraRowImg.ShowAuraBtn"),
            edge = FXLoader:Here(root, "SettingsPanel.ContentBox.ShowAuraRowImg.ShowAuraBtn.BottomEdgeImg"),
            text = FXLoader:Here(root, "SettingsPanel.ContentBox.ShowAuraRowImg.ShowAuraBtn.ButtonTxt"),
        },
    }

    for setting, toggle in pairs(self.Toggles) do
        local settingName = setting
        local button = toggle.button
        -- 点击只传设置键和新值，具体保存由接入层负责。
        self:TrackConnection(button.Activated:Connect(function()
            local state = self:GetUIState()
            self:EmitUIAction("ChangeSetting", {
                setting = settingName,
                value = not state[settingName],
            })
        end))
    end

    local closeButton = FXLoader:Here(root, "TitleBox.CloseSurfaceImg")
    -- Close 由接入层转换为窗口 Hide。
    self:TrackConnection(closeButton.Activated:Connect(function()
        self:EmitUIAction("Close", {})
    end))
end

-- 窗口重新显示时读取完整的最新状态。
function CSettingsView:OnShow()
    self:RefreshUI()
end

-- 按完整 State 更新音量与开关显示。
-- @param state table 本文件头定义的完整设置快照
function CSettingsView:Render(state)
    for setting, slider in pairs(self.Sliders) do
        local value = state[setting]
        local ratio = math.clamp(value / 100, 0, 1)
        slider.value.Text = Text.Tr(TranslationTexts.Volume, {
            value = math.floor(value + 0.5),
        })
        slider.fill.Size = UDim2.new(ratio, 0, 1, 0)
        slider.knob.Position = UDim2.new(ratio, 0, 0.5, 0)
    end

    for setting, toggle in pairs(self.Toggles) do
        local enabled = state[setting]
        toggle.button.BackgroundColor3 = Color3.fromHex(
            enabled and "#45A85A" or "#638079"
        )
        toggle.edge.BackgroundColor3 = Color3.fromHex(
            enabled and "#1D542A" or "#263E36"
        )
        if enabled then
            toggle.text.Text = Text.Tr(TranslationTexts.On)
        else
            toggle.text.Text = Text.Tr(TranslationTexts.Off)
        end
    end
end

-- 真实游戏接入或 Preview 必须处理本界面的动作。
-- @param action string ChangeSetting 或 Close
-- @param payload table 设置键与新值，或 Close 的空表
function CSettingsView:OnUIAction(action, payload)
    error("Settings integration must implement OnUIAction: " .. tostring(action))
end

return CSettingsView
