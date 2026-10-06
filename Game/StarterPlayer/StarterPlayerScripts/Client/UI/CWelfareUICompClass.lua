local FX = _G.FX
local FXLoader = FX.Loader
local GameUtility = FXLoader:RequireShared("Scripts/Game/Shared/GameUtility")
local Component = FX.Class("CWelfareUICompClass", "FCUICompClass")

--- 返回福利入口使用的组件名。
--- @return string 福利界面组件名。
function Component:GetCompName()
    return "CWelfareUIComp"
end

--- 绑定工程中的静态模板，布局和凸点由 StarterGui 节点保存。
function Component:OnReady()
    self._rootNode = FXLoader:PlayerGui("WelfareUI")
    self._rootNode.ResetOnSpawn = false
    self:Hide()
    local window = FXLoader:Here(self._rootNode, "Canvas/WelfareOnlineUI")
    window:SetAttribute("HoverEnabled", false)
    self._commonUI = self:GetPlayerObject():RequireComponent("FCCommonUIComp")
    self._commonUI:RegisterTrainingClickModal(self._rootNode)
    self._online = FXLoader:Here(window, "PopupPanelImg/OnlineRewardsBox")
    self._comingSoon = FXLoader:Here(window, "PopupPanelImg/ComingSoonTxt")
    self._subtitle = FXLoader:Here(window, "TitleImg/SubtitleTxt")
    self._tabs = {}
    for index, key in ipairs({"Task", "Online", "SignIn"}) do
        local button = FXLoader:Here(window, key .. "TabBtn")
        self._tabs[key] = button
        --- 分类切换只调整模板显示状态，不重复创建界面。
        self:TrackConnection(button.Activated:Connect(function()
            self:SelectTab(key)
        end))
    end
    --- 关闭模板，下次打开复用已有事件和节点。
    self:TrackConnection(FXLoader:Here(window, "TitleImg/CloseBtn").Activated:Connect(function()
        self:Hide()
    end))
    --- 发奖尚未接入，预览按钮只显示开发中提示。
    self:TrackConnection(FXLoader:Here(self._online, "Reward1Img/ClaimBtn").Activated:Connect(function()
        self._commonUI:ShowLocalizedTips("Common.InDevelopment")
    end))
    self._rewardLabels = {
        {Label = FXLoader:Here(self._online, "Reward2Img/RewardTxt"), Key = "Welfare.Coins", Value = 500},
        {Label = FXLoader:Here(self._online, "Reward3Img/RewardTxt"), Key = "Welfare.Diamonds", Value = 50},
    }
    --- 云端翻译就绪或语言切换后刷新参数文案。
    self:TrackConnection(self._commonUI.Localization.Changed:Connect(function()
        self:RefreshRewardText()
    end))
    self:SelectTab("Online")
    self:RefreshRewardText()
end

--- 分类标识来自三个固定按钮，选中色同步驱动已有凸点脚本。
--- @param key string 已创建的分类标识。
function Component:SelectTab(key)
    for name, button in pairs(self._tabs) do
        button.BackgroundColor3 = name == key and Color3.fromRGB(38, 158, 237) or Color3.fromRGB(88, 110, 131)
    end
    self._online.Visible = key == "Online"
    self._comingSoon.Visible = key ~= "Online"
    local subtitles = {
        Task = "Tasks · Complete goals to earn rewards",
        Online = "Online rewards · Stay longer, earn more!",
        SignIn = "Daily check-in · Come back for more rewards",
    }
    self._subtitle.Text = subtitles[key]
end

--- 数量先统一格式化，再按稳定 Key 翻译，缺失译文时沿用英文。
function Component:RefreshRewardText()
    for index, entry in ipairs(self._rewardLabels) do
        entry.Label.Text = self._commonUI.Localization:FormatByKey(entry.Key, {
            value = GameUtility.NumberToText(entry.Value),
        })
    end
end

return Component
