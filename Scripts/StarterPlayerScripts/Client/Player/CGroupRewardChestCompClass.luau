local FX, FC = _G.FX, _G.FC
local FXLoader = FX.Loader
local Text = FXLoader:RequireShared("Scripts/Game/Shared/Text")
local GameUtility = FXLoader:RequireShared("Scripts/Game/Shared/GameUtility")
local AnimatedText = FXLoader:Require(script.Parent.Parent, "UI/CAnimatedText")
local GroupService = game:GetService("GroupService")
local TweenService = game:GetService("TweenService")
local TranslationTexts = Text.Define("GroupRewardChest", {
    Invitation = "Join the group for a FREE reward!",
    Free = "Free!",
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
    self._chests = {}
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

--- 三个世界共用一次领取记录，所有宝箱完成接入后统一订阅领取与语言变化。
function Component:InitChest()
    for worldIndex = 1, 3 do
        local model = FXLoader:Workspace(
            string.format("Decorations/World%dDecorations/GroupRewardChest", worldIndex), math.huge)
        self:InitWorldChest(model)
    end
    self:RefreshTexts()
    self:TrackConnection(FC.Localization.Changed:Connect(function()
        self:RefreshTexts()
    end))
    self:WatchDataChanged(_G.PlayerDataConfig.GroupRewardClaimed, function(claimed)
        if claimed then
            self:HideChest()
        end
    end)
end

--- 为一个世界的宝箱接入点击领取和原有标题动画，不在靠近时发奖。
--- @param model Model 当前世界的群组宝箱。
function Component:InitWorldChest(model)
    local root = FXLoader:Here(model, "Root")
    local billboard = FXLoader:Here(root, "RewardBillboard"):Clone()
    -- 场景模板不限距离以便 Studio 编辑，玩家提示保留原有可见范围。
    billboard.MaxDistance = 143
    billboard.Adornee = root
    local chest = {model = model, billboard = billboard}
    table.insert(self._chests, chest)
    chest.invitation = FXLoader:Here(billboard, "Invitation")
    chest.invitationEffect = AnimatedText.Attach(chest.invitation)
    chest.freeLabel = FXLoader:Here(billboard, "Free")
    chest.freeEffect = AnimatedText.Attach(chest.freeLabel)
    chest.freeJump = TweenService:Create(chest.freeLabel,
        TweenInfo.new(0.42, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
            Position = chest.freeLabel.Position - UDim2.fromScale(0, 0.075),
            Rotation = 5,
        })
    chest.freeJump:Play()
    FXLoader:Here(billboard, "Claim").Visible = false
    local clickDetector = FXLoader:Here(model, "ClickDetector")
    clickDetector.MaxActivationDistance = 10
    self:TrackConnection(clickDetector.MouseClick:Connect(function(player)
        if player == self:GetPlayerNode() then
            self:ClaimReward()
        end
    end))
    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "GroupRewardClaim"
    prompt.Style = Enum.ProximityPromptStyle.Custom
    prompt:SetAttribute("CustomPickup", true)
    prompt.AutoLocalize = false
    prompt.ObjectText = ""
    prompt.KeyboardKeyCode = Enum.KeyCode.E
    prompt.MaxActivationDistance = 10
    prompt.HoldDuration = 0
    prompt.RequiresLineOfSight = false
    chest.prompt = prompt
    root.RewardBillboard.Enabled = false
    billboard.Enabled = true
    billboard.Parent = self:GetPlayerNode():WaitForChild("PlayerGui")
    prompt.Parent = root
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
    local reward = _G.ActivityConfig.CommonConfig.GroupRewardChestReward
    local actionText = Text.Tr(TranslationTexts.Claim, {
        value = GameUtility.NumberToText(reward.Count),
    })
    for chestIndex, chest in ipairs(self._chests) do
        chest.invitation.Text = Text.Tr(TranslationTexts.Invitation)
        chest.freeLabel.Text = Text.Tr(TranslationTexts.Free)
        chest.prompt.ActionText = actionText
    end
end

--- 释放单个宝箱由组件创建的表现，支持初始化等待期间销毁组件。
--- @param chest table 宝箱模型及其客户端表现记录。
function Component:DestroyChestPresentation(chest)
    if chest.freeJump then
        chest.freeJump:Cancel()
    end
    if chest.freeEffect then
        chest.freeEffect:Destroy()
    end
    if chest.invitationEffect then
        chest.invitationEffect:Destroy()
    end
    chest.billboard:Destroy()
    if chest.prompt then
        chest.prompt:Destroy()
    end
end

--- 任意世界领取后同时收起三个宝箱，重复同步或回包不会重复释放。
function Component:HideChest()
    if self._claimed then
        return
    end
    self._claimed = true
    for chestIndex, chest in ipairs(self._chests) do
        self:DestroyChestPresentation(chest)
        chest.model:Destroy()
    end
    self._chests = {}
end

--- 已入群时跳过平台弹窗，未入群才提示加入；奖励始终由服务端核实后发放。
function Component:ClaimReward()
    if self._claimed or self._claiming then
        return
    end
    self._claiming = true
    local ok, result = pcall(function()
        local response = FX.Network:InvokeServer("C2S_ClaimGroupReward")
        if response and response.groupId then
            local status = Enum.GroupMembershipStatus.AlreadyMember
            if not self:GetPlayerNode():IsInGroupAsync(response.groupId) then
                status = GroupService:PromptJoinAsync(response.groupId)
            end
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

--- 取消场景等待，并释放三个世界的客户端表现与动画。
function Component:Dtor()
    self._destroyed = true
    if self._initTask then
        task.cancel(self._initTask)
    end
    Component.Super.Dtor(self)
    for chestIndex, chest in ipairs(self._chests) do
        self:DestroyChestPresentation(chest)
    end
    self._chests = {}
end

return Component
