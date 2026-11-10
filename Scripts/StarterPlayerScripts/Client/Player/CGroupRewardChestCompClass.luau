local FX, FC = _G.FX, _G.FC
local FXLoader = FX.Loader
local Text = FXLoader:RequireShared("Scripts/Game/Shared/Text")
local GameUtility = FXLoader:RequireShared("Scripts/Game/Shared/GameUtility")
local AnimatedText = FXLoader:Require(script.Parent.Parent, "UI/CAnimatedText")
local GroupService = game:GetService("GroupService")
local TranslationTexts = Text.Define("GroupRewardChest", {
    Invitation = "Join the group for a FREE reward!",
    Claim = "CLAIM {value} DIAMONDS",
    Claimed = "Reward claimed!",
    Failed = "Something went wrong. Please try again.",
    MembershipPending = "If you just joined the group, rejoin the game to claim your reward.",
})

--- 群组宝箱表现只读取服务端领取结果，入群与发奖均由服务端决定。
local Component = FX.Class("CGroupRewardChestCompClass", "FCPlayerCompClass")

--- 初始化本地交互状态，等待 Ready 后读取服务端永久领取记录。
--- @param owner CPlayerObjectClass 当前客户端玩家对象。
function Component:Ctor(owner)
    Component.Super.Ctor(self, owner)
    self._claimed = false
end

--- 数据就绪后再等待场景，避免旧玩家在同步领取记录前重复看到可领取提示。
function Component:OnReady()
    Component.Super.OnReady(self)
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
    self:WatchDataChanged(_G.PlayerDataConfig.GroupRewardClaimed, function(claimed)
        if claimed then
            self:HideChest()
        end
    end)
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

--- 同步记录或成功回包均可收起宝箱，重复调用不会再次释放实例。
function Component:HideChest()
    if self._claimed then
        return
    end
    self._claimed = true
    self._invitationEffect:Destroy()
    self._invitationEffect = nil
    self._billboard:Destroy()
    self._billboard = nil
    self._claimPrompt:Destroy()
    self._claimPrompt = nil
    self._chest:Destroy()
end

--- 领取失败时保留宝箱；未入群则展示平台弹窗，完成后仍须再次由服务端核实。
function Component:ClaimReward()
    if self._claimed or self._claiming then
        return
    end
    self._claiming = true
    local ok, result = pcall(function()
        local response = FX.Network:InvokeServer("C2S_ClaimGroupReward")
        if response and response.groupId then
            local status = GroupService:PromptJoinAsync(response.groupId)
            if status == Enum.GroupMembershipStatus.Joined or status == Enum.GroupMembershipStatus.AlreadyMember then
                response = FX.Network:InvokeServer("C2S_ClaimGroupReward")
                if response and response.groupId then
                    response.key = TranslationTexts.MembershipPending
                end
            end
        end
        return response
    end)
    self._claiming = false
    if self._destroyed then
        return
    end
    local commonUI = self:GetPlayerObject():RequireComponent("FCCommonUIComp")
    if not ok or not result then
        commonUI:ShowTips(Text.Tr(TranslationTexts.Failed))
        return
    end
    if not result.success then
        commonUI:ShowTips(Text.Tr(result.key))
        return
    end
    self:HideChest()
    self:GetPlayerObject():RequireComponent("CMainUIComp"):ShowPickupEffect({
        MoneyAmount = result.amount,
        Currency = "Diamonds",
    })
    commonUI:ShowTips(Text.Tr(TranslationTexts.Claimed))
end

--- 取消未完成的场景等待，并在界面销毁前释放通用文字渐变。
function Component:Dtor()
    self._destroyed = true
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
