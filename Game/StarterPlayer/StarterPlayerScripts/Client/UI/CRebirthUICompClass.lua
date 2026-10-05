local FX = _G.FX
local FXLoader = FX.Loader
local Fields = _G.PlayerDataConfig
local Rebirth = FXLoader:RequireShared("Scripts/Game/Shared/Rebirth")
local RockLevel = FXLoader:RequireShared("Scripts/Game/Shared/RockLevel")
local GameUtility = FXLoader:RequireShared("Scripts/Game/Shared/GameUtility")
local Component = FX.Class("CRebirthUICompClass", "FCUICompClass")

--- 返回重生界面协作名，供主界面打开。
--- @return string 组件名称。
function Component:GetCompName()
    return "CRebirthUIComp"
end

--- 复用已确认的原生模板，事件与数据监听只绑定一次。
function Component:OnReady()
    self._rootNode = FXLoader:PlayerGui("RebirthUI")
    self._rootNode.ResetOnSpawn = false
    self:Hide()
    self._panel = FXLoader:Here(self._rootNode, "PopupPanelImg")
    self:SetOpenAnimation(self._panel)
    self._commonUI = self:GetPlayerObject():RequireComponent("FCCommonUIComp")
    self._commonUI:RegisterTrainingClickModal(self._rootNode)
    self._localization = self._commonUI.Localization
    local labels = {
        ["TitleBox/TitleTxt"] = "Rebirth",
        BeforeLabelTxt = "Before",
        AfterLabelTxt = "After",
        ["BeforeStrengthImg/BeforeStrengthLabelTxt"] = "Training",
        ["AfterStrengthImg/AfterStrengthLabelTxt"] = "Training",
        ["BeforeMoneyImg/BeforeMoneyLabelTxt"] = "Coins",
        ["AfterMoneyImg/AfterMoneyLabelTxt"] = "Coins",
    }
    for path, text in pairs(labels) do
        local label = FXLoader:Here(self._panel, path)
        label.Text = text
        label.AutoLocalize = true
    end
    self._beforeTraining = FXLoader:Here(self._panel, "BeforeStrengthImg/BeforeStrengthValueTxt")
    self._afterTraining = FXLoader:Here(self._panel, "AfterStrengthImg/AfterStrengthValueTxt")
    self._beforeMoney = FXLoader:Here(self._panel, "BeforeMoneyImg/BeforeMoneyValueTxt")
    self._afterMoney = FXLoader:Here(self._panel, "AfterMoneyImg/AfterMoneyValueTxt")
    self._progress = FXLoader:Here(self._panel, "LevelProgressImg/LevelProgressTxt")
    self._fill = FXLoader:Here(self._panel, "LevelProgressImg/ProgressFillImg")
    self._button = FXLoader:Here(self._panel, "RebirthBtn")
    self._buttonText = FXLoader:Here(self._button, "RebirthTxt")
    for index, label in ipairs({self._beforeTraining, self._afterTraining, self._beforeMoney,
        self._afterMoney, self._progress, self._buttonText}) do
        label.AutoLocalize = false
    end
    self:TrackConnection(FXLoader:Here(self._panel, "TitleBox/CloseBtn").Activated:Connect(function()
        self:Hide()
    end))
    self:TrackConnection(self._button.Activated:Connect(function()
        self:OnClickConfirm()
    end))
    self:TrackConnection(self._localization.Changed:Connect(function()
        self:RefreshRebirthInfo()
    end))
    self:WatchDataChanged(Fields.RebirthCount, self.RefreshRebirthInfo, self)
    self:WatchDataChanged(Fields.RockTrainingValue, self.RefreshRebirthInfo, self)
end

--- 预览两种永久倍率，次数封顶后不采样不存在的下一档。
function Component:RefreshRebirthInfo()
    local count = self:GetNumber(Fields.RebirthCount)
    local isMax = count >= Rebirth.MaxCount
    local nextCount = isMax and count or count + 1
    local required = Rebirth.GetRequiredLevel(count)
    local level = RockLevel.GetProgress(self:GetNumber(Fields.RockTrainingValue), required)
    self._beforeTraining.Text = GameUtility.NumberToText(Rebirth.GetTrainingRate(count)) .. "X"
    self._afterTraining.Text = GameUtility.NumberToText(Rebirth.GetTrainingRate(nextCount)) .. "X"
    self._beforeMoney.Text = GameUtility.NumberToText(Rebirth.GetMoneyRate(count)) .. "X"
    self._afterMoney.Text = GameUtility.NumberToText(Rebirth.GetMoneyRate(nextCount)) .. "X"
    self._progress.Text = self._localization:FormatByKey("Rebirth.Progress", {level = level, required = required})
    self._fill.Size = UDim2.fromScale(math.clamp(level / required, 0, 1), 1)
    self._buttonText.Text = self._localization:FormatByKey(isMax and "Common.InDevelopment" or "Rebirth.Confirm")
    self._buttonText.TextTransparency = (isMax or level < required) and 0.4 or 0
end

--- 按当前同步数据提示门槛，达标后提交无参数请求，由服务端最终校验。
function Component:OnClickConfirm()
    local count = self:GetNumber(Fields.RebirthCount)
    if count >= Rebirth.MaxCount then
        self._commonUI:ShowLocalizedTips("Common.InDevelopment")
        return
    end
    local required = Rebirth.GetRequiredLevel(count)
    local level = RockLevel.GetProgress(self:GetNumber(Fields.RockTrainingValue), required)
    if level < required then
        self._commonUI:ShowLocalizedTips("Rebirth.RequiredLevel", {level = required})
        return
    end
    FX.Network:SendMsgToServer("C2S_Rebirth")
end

return Component
