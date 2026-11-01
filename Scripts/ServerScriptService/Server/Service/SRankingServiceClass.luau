local FX, FS = _G.FX, _G.FS
local StrengthRanking = FX.Loader:RequireFromParent(script, "SStrengthRankingClass")
local Ranking = FX.Class("SRankingServiceClass", "FSRankingServiceClass")
_G.SRankingServiceClass = Ranking

local function Integer(value, min, max)
    return type(value) == "number" and value == value and value % 1 == 0 and value >= min and value <= max
end

--- 注册力量大数榜实例与只读查询协议；客户端只能请求范围，不能提交成绩。
function Ranking:Ctor()
    Ranking.Super.Ctor(self)
    -- 框架没有注册派生榜单的接口；仅替换力量实例，其余榜和管理器定时任务保持不变。
    local config = _G.RankingDataConfig[2]
    local strength = StrengthRanking.New(config)
    FS.RankingManager._rankingMap[config.Name] = strength
    strength:LoadRankingDataAsync()
    FX.Network:RegClientMsgCallback("C2S_RankingData", function(id, scope, kind, first, last)
        if
            not FS.PlayerManager:GetPlayerObject(id)
            or not Integer(scope, 1, 2)
            or not Integer(kind, 1, #_G.Provider:GetRankingEnum())
            or not Integer(first, 1, 100)
            or not Integer(last, first, 100)
        then
            return nil
        end

        return self:GetRankingData(id, scope, kind, first, last)
    end)
end

--- 正式环境先剔除开发者再连续编号和分页；Studio 保留开发者，便于测试真实榜单。
--- @param playerId number 引擎认证的玩家 ID。
--- @param scope number 查询范围，1 为房间，2 为全服。
--- @param kind number 榜单配置索引。
--- @param first number 起始名次。
--- @param last number 结束名次。
--- @return table? 真实榜单与个人成绩；榜单不存在时返回 nil。
function Ranking:GetRankingData(playerId, scope, kind, first, last)
    local isStudio = FX.IsDebugMode()
    local queryFirst = isStudio and first or 1
    local queryLast = isStudio and last or 100
    local data = Ranking.Super.GetRankingData(self, playerId, scope, kind, queryFirst, queryLast)
    if data then
        local config = self:GetRankingType(kind)
        data.myScore = FS.RankingManager:GetPlayerScore(playerId, config) or data.myScore or config.DefaultValue
        if isStudio then
            return data
        end
        local items = data.itemData
        data.itemData = {}
        data.myNo = nil
        local rankNo = 0
        for index, item in ipairs(items) do
            if not FX.IsDeveloper(item.playerId) then
                rankNo += 1
                if item.playerId == playerId then
                    data.myNo = rankNo
                end
                if rankNo >= first and rankNo <= last then
                    table.insert(data.itemData, {
                        rankNo = rankNo,
                        rankScore = item.rankScore,
                        playerId = item.playerId,
                        playerName = item.playerName,
                    })
                end
            end
        end
    end
    return data
end

return Ranking
