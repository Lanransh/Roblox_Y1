local FX, FC = _G.FX, _G.FC
local FXLoader = FX.Loader
local Text = FXLoader:RequireShared("Scripts/Game/Shared/Text")
local TranslationTexts = Text.Define("GroupRewardChest", {
    Invitation = "Join the group for a FREE reward!",
    Claim = "CLAIM FREE REWARD",
    Claimed = "Reward claimed!",
})

--- 群组奖励占位：仅当前客户端领取和隐藏，不校验群组、不发放或保存奖励。
local Component = FX.Class("CGroupRewardChestCompClass", "FCPlayerCompClass")

--- 将场景等待放到独立任务，避免阻塞其他玩家组件初始化。
--- @param owner CPlayerObjectClass 当前客户端玩家对象。
function Component:Ctor(owner)
    Component.Super.Ctor(self, owner)
    self._claimed = false
    self._initTask = task.defer(function()
        self:InitChest()
        self._initTask = nil
    end)
end

--- 返回玩家组件内唯一的协作名称。
--- @return string 群组奖励宝箱组件名。
function Component:GetCompName()
    return "CGroupRewardChestComp"
end

--- 绑定场景宝箱与可触屏点击的世界按钮；连接由组件统一释放。
function Component:InitChest()
    self._chest = FXLoader:Workspace("Decorations/GroupRewardChest", math.huge)
    local root = FXLoader:Here(self._chest, "Root")
    local billboard = FXLoader:Here(root, "RewardBillboard"):Clone()
    billboard.Adornee = root
    self._billboard = billboard
    self._invitation = FXLoader:Here(billboard, "Invitation")
    self._claimButton = FXLoader:Here(billboard, "Claim")
    -- 可交互 BillboardGui 放在 PlayerGui，支持鼠标与触屏 Activated。
    root.RewardBillboard.Enabled = false
    billboard.Enabled = true
    billboard.Parent = self:GetPlayerNode():WaitForChild("PlayerGui")
    self:RefreshTexts()
    self:TrackConnection(FC.Localization.Changed:Connect(function()
        self:RefreshTexts()
    end))
    self:TrackConnection(self._claimButton.Activated:Connect(function()
        self:ClaimReward()
    end))
    self:TrackConnection(FXLoader:Here(self._chest, "ClickDetector").MouseClick:Connect(function()
        self:ClaimReward()
    end))
end

--- 跟随当前语言更新脚本文案，静态节点已在制作时关闭自动翻译。
function Component:RefreshTexts()
    if self._claimed then
        return
    end
    self._invitation.Text = Text.Tr(TranslationTexts.Invitation)
    self._claimButton.Text = Text.Tr(TranslationTexts.Claim)
end

--- 一次点击完成假领取；只销毁本地宝箱，重生不重建，重新进服恢复。
function Component:ClaimReward()
    if self._claimed then
        return
    end
    self._claimed = true
    self._billboard:Destroy()
    self._chest:Destroy()
    self:GetPlayerObject():RequireComponent("FCCommonUIComp"):ShowTips(Text.Tr(TranslationTexts.Claimed))
end

--- 取消未完成的场景等待，并释放当前组件拥有的交互界面和连接。
function Component:Dtor()
    if self._initTask then
        task.cancel(self._initTask)
    end
    Component.Super.Dtor(self)
    if self._billboard then
        self._billboard:Destroy()
    end
end

return Component
