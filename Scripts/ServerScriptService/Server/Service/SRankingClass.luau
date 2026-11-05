-- 项目排行榜：离服时沿用在线缓存的昵称，避免框架重新查找已移除的 Player。
local FX = _G.FX
local Players = game:GetService("Players")
local Ranking = FX.Class("SRankingClass", "FSRankingClass")

--- 缓存昵称仅用于本次在线会话，存档结束后释放。
--- @param rankingType table 框架排行榜配置。
function Ranking:Ctor(rankingType)
    Ranking.Super.Ctor(self, rankingType)
    self._playerNames = {}
end

--- 在线更新沿用框架；离服更新保留相同的历史最高分和入榜规则，不依赖 Player 节点。
--- @param playerId number 服务端确定的玩家 ID。
--- @param newScore number 原始排行榜分数。
--- @return boolean? 是否进入榜单刷新流程；未达单位或开发者跳过时返回 nil。
function Ranking:UpdatePlayerScore(playerId, newScore)
    local player = Players:GetPlayerByUserId(playerId)
    if player then
        self._playerNames[playerId] = player.DisplayName
        return Ranking.Super.UpdatePlayerScore(self, playerId, newScore)
    end
    if not FX.IsDebugMode() and FX.IsDeveloper(playerId) then
        return
    end

    -- 框架未提供昵称获取钩子，离服分支需保持与其更新规则一致。
    local oldScore = self:GetPlayerScore(playerId)
    if not self._rankingType.UseHistoricalHighScore or not oldScore or self:CompareRankingScore(newScore, oldScore) then
        self:SetPlayerScore(playerId, newScore)
    end
    local unit = self._rankingType.unit or 1
    if newScore < unit then
        return
    end
    local lastEntry = self._isDataLoaded and self._rankingDataCache[self._rankingType.MaxCount]
    if lastEntry and not self:CompareRankingScore(newScore, lastEntry.rankScore) then
        return false
    end
    if self._rankingType.UseHistoricalHighScore then
        local rankNo, rankScore = self:FindPlayerRank(playerId, true)
        if rankScore and not self:CompareRankingScore(newScore, rankScore) then
            return false
        end
    end
    self._updateRankingPlayerMap[playerId] = {
        score = newScore / unit,
        name = self._playerNames[playerId] or tostring(playerId),
    }
    return true
end

--- 框架提交离服尾差后释放会话昵称，不影响玩家 KV 保存。
--- @param playerId number 正在保存的玩家 ID。
function Ranking:OnPlayerDataSaveStarted(playerId)
    Ranking.Super.OnPlayerDataSaveStarted(self, playerId)
    self._playerNames[playerId] = nil
end

return Ranking
