-- 首次累计在线到点直接提示收藏当前游戏，不读取玩家物品栏。
local FX = _G.FX
local AvatarEditorService = game:GetService("AvatarEditorService")
local Fields = _G.PlayerDataConfig
local Minutes = _G.GameEnum.FavoritePromptMinutes
local Component = FX.Class("CFavoritePromptCompClass", "FCPlayerCompClass")

--- 返回玩家内收藏提醒的协作名称。
--- @return string 组件名称。
function Component:GetCompName()
    return "CFavoritePromptComp"
end

--- 握手完成后以读档时长作为起点，重生和重新登录不重新计时。
function Component:OnReady()
    self._lastPlaytime = self:GetNumber(Fields.TrainingPlaytime)
    self:WatchDataChanged(Fields.TrainingPlaytime, self.OnPlaytimeChanged, self)
end

--- 只处理本次在线跨过的唯一节点，取消或失败后也不再次打扰。
--- @param seconds number 服务端同步的累计在线秒数。
function Component:OnPlaytimeChanged(seconds)
    local previous = self._lastPlaytime
    self._lastPlaytime = seconds
    if previous >= Minutes * 60 or seconds < Minutes * 60 or self._destroyed then
        return
    end
    local ok, failure = pcall(function()
        if not FX.Network:InvokeServer("C2S_ConsumeFavoritePrompt") or self._destroyed then
            return
        end
        AvatarEditorService:PromptSetFavorite(game.PlaceId, Enum.AvatarItemType.Asset, true)
    end)
    if not ok and not self._destroyed then
        warn("[FavoritePrompt] 收藏提醒失败，已跳过本次提醒：", failure)
    end
end

--- 阻止尚未返回的提醒请求在组件销毁后弹窗，连接由基类释放。
function Component:Dtor()
    self._destroyed = true
    Component.Super.Dtor(self)
end

return Component
