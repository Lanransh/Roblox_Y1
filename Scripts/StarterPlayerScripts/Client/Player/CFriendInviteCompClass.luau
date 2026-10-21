local FX = _G.FX
local FXLoader = FX.Loader
local Text = FXLoader:RequireShared("Scripts/Game/Shared/Text")
local TranslationTexts = Text.Define("FriendInvite", {
    Title = "Play with friends",
    Online = "{name} is online. Invite them to play!",
    Invite = "Invite",
    Close = "Close",
})
local Players = game:GetService("Players")
local SocialService = game:GetService("SocialService")
local StarterGui = game:GetService("StarterGui")

--- 进服一分钟后，仅提醒一次邀请当前在线且不在本服的好友。
local Component = FX.Class("CFriendInviteCompClass", "FCPlayerCompClass")

--- 独立于角色重生计时，组件销毁时取消尚未完成的平台查询。
--- @param owner CPlayerObjectClass 当前客户端玩家对象。
function Component:Ctor(owner)
    Component.Super.Ctor(self, owner)
    self._checkTask = task.delay(60, function()
        self:CheckOnlineFriends()
        self._checkTask = nil
    end)
end

--- 取消计时与查询，并释放原生通知持有的回调对象。
function Component:Dtor()
    self._destroyed = true
    if self._checkTask then
        task.cancel(self._checkTask)
    end
    if self._notificationCallback then
        self._notificationCallback:Destroy()
    end
    Component.Super.Dtor(self)
end

--- 提供项目内的组件协作名称。
--- @return string 好友邀请组件名称。
function Component:GetCompName()
    return "CFriendInviteComp"
end

--- 只查一次在线状态；无好友、平台不允许邀请或查询失败时不显示提示。
function Component:CheckOnlineFriends()
    local player = self:GetPlayerNode()
    local success, friends = pcall(function()
        return player:GetFriendsOnlineAsync(200)
    end)
    if self._destroyed or not success then
        return
    end

    local candidates = {}
    for index, friend in ipairs(friends) do
        if friend.IsOnline and not Players:GetPlayerByUserId(friend.VisitorId) then
            table.insert(candidates, friend)
        end
    end
    if #candidates == 0 then
        return
    end

    local friend = candidates[math.random(1, #candidates)]
    local canCheck, canInvite = pcall(function()
        return SocialService:CanSendGameInviteAsync(player, friend.VisitorId)
    end)
    if self._destroyed or not canCheck or not canInvite
        or Players:GetPlayerByUserId(friend.VisitorId) then
        return
    end
    self:ShowInviteNotification(friend)
end

--- 使用官方右下角通知；按钮文案与回调比较使用同一份翻译结果。
--- @param friend table 平台返回的在线好友信息。
function Component:ShowInviteNotification(friend)
    local inviteText = Text.Tr(TranslationTexts.Invite)
    local callback = Instance.new("BindableFunction")
    self._notificationCallback = callback
    --- 仅处理邀请按钮，关闭按钮与重复回调不打开邀请窗口。
    --- @param buttonText string 原生通知传回的按钮文字。
    callback.OnInvoke = function(buttonText)
        if self._destroyed or self._inviteHandled or buttonText ~= inviteText then
            return
        end
        self._inviteHandled = true
        self:PromptInvite(friend.VisitorId)
    end

    local success, message = pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = Text.Tr(TranslationTexts.Title),
            Text = Text.Tr(TranslationTexts.Online, { name = friend.DisplayName or friend.UserName }),
            Icon = "rbxthumb://type=AvatarHeadShot&id=" .. friend.VisitorId .. "&w=150&h=150",
            Duration = 12,
            Button1 = inviteText,
            Button2 = Text.Tr(TranslationTexts.Close),
            Callback = callback,
        })
    end)
    if not success then
        callback:Destroy()
        self._notificationCallback = nil
        warn("Unable to show friend invite notification:", message)
    end
end

--- 点击时再次检查邀请资格与同服状态，再交由玩家确认官方邀请。
--- @param friendId number 本次通知对应好友的 Roblox UserId。
function Component:PromptInvite(friendId)
    local success, message = pcall(function()
        local player = self:GetPlayerNode()
        if SocialService:CanSendGameInviteAsync(player, friendId)
            and not self._destroyed and not Players:GetPlayerByUserId(friendId) then
            local options = Instance.new("ExperienceInviteOptions")
            options.InviteUser = friendId
            SocialService:PromptGameInvite(player, options)
            options:Destroy()
        end
    end)
    if not success then
        warn("Unable to open friend invite:", message)
    end
end

return Component
