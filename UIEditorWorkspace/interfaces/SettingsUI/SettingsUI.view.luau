--[[
设置界面接入契约

【Config / State】
  Config：不读取配置字段，可设置 self.Config = {}。
  State：必填完整快照，以下字段全部必填、无默认值。
    musicVolume: number；音乐音量，0..100 百分比整数，不是 0..1 音频倍率。
    soundEffectsVolume: number；音效音量，0..100 百分比整数。
    showAura: boolean；是否显示光环。
    giantPickaxe: boolean；是否启用镐子尺寸巨大化。
  View 按状态显示，不替业务层保存设置或改变声音/模型。
  无 open、pending、error、列表或独立加载态；异步读取完成前不显示。
  音量图形宽度截断到 0..1、文字取整，但不替业务修正超范围的原始状态。

【最小完整数据（接入 Ctor 调用父构造之后）】
  self.Config = {}
  self.State = {
      musicVolume = 70, soundEffectsVolume = 85,
      showAura = true, giantPickaxe = false,
  }

【初始化与刷新】
  游戏接入类继承 CSettingsView。
  接入 Ctor(owner) 先调用自身类的 Super.Ctor(self, owner)，再准备下例数据。
  接入 OnReady() 先调用自身类的 Super.OnReady(self)，再依次
  self:BindUIData()、self:Show()；父 OnReady 负责绑定节点，OnShow 会刷新。
  GetUIConfig() 默认返回 self.Config；GetUIState() 默认返回 self.State。
  RefreshUI() 调用 Render(GetUIState())，输入是完整快照，不合并增量，
  不自动补齐业务字段。可修改已有表或替换整表，但每次刷新须满足完整契约。
  后续先更新 Config/State，再 self:RefreshUI()；异步未就绪按本页规则处理。
  无需覆写 Render 或手动重复调用 OnReady；业务类覆写生命周期时须保留父调用。

【动作与覆写】
  必需覆写 OnUIAction(action: string, payload: table)，无返回值；默认报错。
  ChangeSetting -> { setting: string, value: number | boolean }。
    setting="musicVolume" / "soundEffectsVolume"：value 为 0..100 整数百分比。
    setting="showAura" / "giantPickaxe"：value 为 boolean，取当前 State 的反值。
    不支持其他设置键；setting 为稳定字段名，不是翻译后的标签。
  Close -> {}；由接入层调用 self:Hide()，没有 State.open。
  无其他页面专用必需或可选覆写。
  拖动滑杆会连续发送 ChangeSetting，不只在释放时发送；接入层收到后
  更新对应 State 字段并 RefreshUI，否则滑杆/开关不会得到状态确认。
  实际音频映射、光环显隐、镐子放大及关闭设置后恢复原尺寸由游戏处理。
  若异步保存，接入层自行处理合并请求、过期响应和失败回滚；
  View 没有等待锁或错误提示，不能将每次滑动事件等同于一次存档成功。

【显隐边界】
  窗口由 Show/Hide 管理，Render 不控制根 Enabled 或整个窗口 Visible。
  当前滑杆只绑定鼠标输入，不据此承诺触屏/手柄行为。
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

-- 游戏接入必须处理本界面的动作。
-- @param action string ChangeSetting 或 Close
-- @param payload table 设置键与新值，或 Close 的空表
function CSettingsView:OnUIAction(action, payload)
    error("Settings integration must implement OnUIAction: " .. tostring(action))
end

return CSettingsView
