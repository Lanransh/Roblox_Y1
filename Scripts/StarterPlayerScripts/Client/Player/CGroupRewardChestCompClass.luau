local FX, FC = _G.FX, _G.FC
local FXLoader = FX.Loader
local Text = FXLoader:RequireShared("Scripts/Game/Shared/Text")
local GameUtility = FXLoader:RequireShared("Scripts/Game/Shared/GameUtility")
local AnimatedText = FXLoader:Require(script.Parent.Parent, "UI/CAnimatedText")
local TranslationTexts = Text.Define("GroupRewardChest", {
    Invitation = "Join the group for a FREE reward!",
    Claim = "CLAIM {value} DIAMONDS",
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

--- 保留群组说明，领取复用空投礼物的自定义提示与半秒长按进度。
function Component:InitChest()
    self._chest = FXLoader:Workspace("Decorations/GroupRewardChest", math.huge)
    local root = FXLoader:Here(self._chest, "Root")
    local billboard = FXLoader:Here(root, "RewardBillboard"):Clone()
    billboard.Adornee = root
    self._billboard = billboard
    self._invitation = FXLoader:Here(billboard, "Invitation")
    self._invitationEffect = AnimatedText.Attach(self._invitation)
    FXLoader:Here(billboard, "Claim").Visible = false
    FXLoader:Here(self._chest, "ClickDetector").MaxActivationDistance = 0
    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "GroupRewardClaim"
    prompt.Style = Enum.ProximityPromptStyle.Custom
    prompt:SetAttribute("CustomPickup", true)
    prompt.AutoLocalize = false
    prompt.ObjectText = ""
    prompt.KeyboardKeyCode = Enum.KeyCode.E
    prompt.MaxActivationDistance = 10
    prompt.HoldDuration = 0.5
    prompt.RequiresLineOfSight = false
    self._claimPrompt = prompt
    root.RewardBillboard.Enabled = false
    billboard.Enabled = true
    billboard.Parent = self:GetPlayerNode():WaitForChild("PlayerGui")
    self:RefreshTexts()
    prompt.Parent = root
    self:TrackConnection(FC.Localization.Changed:Connect(function()
        self:RefreshTexts()
    end))
    self:TrackConnection(prompt.Triggered:Connect(function(player)
        if player == self:GetPlayerNode() then
            self:ClaimReward()
        end
    end))
end

--- 跟随当前语言更新脚本文案，静态节点已在制作时关闭自动翻译。
function Component:RefreshTexts()
    if self._claimed then
        return
    end
    self._invitation.Text = Text.Tr(TranslationTexts.Invitation)
    local reward = _G.ActivityConfig.CommonConfig.GroupRewardChestReward
    self._claimPrompt.ActionText = Text.Tr(TranslationTexts.Claim, {
        value = GameUtility.NumberToText(reward.Count),
    })
end

--- 长按完成假领取，先释放说明渐变，再复用空投礼物的钻石领奖动画。
function Component:ClaimReward()
    if self._claimed then
        return
    end
    self._claimed = true
    self._invitationEffect:Destroy()
    self._invitationEffect = nil
    self._billboard:Destroy()
    self._chest:Destroy()
    local reward = _G.ActivityConfig.CommonConfig.GroupRewardChestReward
    self:GetPlayerObject():RequireComponent("CMainUIComp"):ShowPickupEffect({
        MoneyAmount = reward.Count,
        Currency = "Diamonds",
    })
    self:GetPlayerObject():RequireComponent("FCCommonUIComp"):ShowTips(Text.Tr(TranslationTexts.Claimed))
end

--- 取消未完成的场景等待，并在界面销毁前释放通用文字渐变。
function Component:Dtor()
    if self._initTask then
        task.cancel(self._initTask)
    end
    Component.Super.Dtor(self)
    if self._invitationEffect then
        self._invitationEffect:Destroy()
    end
    if self._billboard then
        self._billboard:Destroy()
    end
    if self._claimPrompt then
        self._claimPrompt:Destroy()
    end
end

return Component
