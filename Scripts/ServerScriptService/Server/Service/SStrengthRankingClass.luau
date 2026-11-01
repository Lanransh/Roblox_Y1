-- 力量总榜沿用框架生命周期；仅云端排序分数采用大数编码，不改变玩家原始力量。
local FX = _G.FX
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local StorageConfig = FX.Loader:Require(script.Parent.Parent, "Config/StorageConfig")
local Memory = game:GetService("RunService"):IsStudio() and StorageConfig.StudioMemory
local Ranking = FX.Class("SStrengthRankingClass", "FSRankingClass")
local BucketSize = 1e12

--- 编码榜使用独立存储版本，避免把旧的未编码分数误解为指数与尾数。
--- @param timeStamp number 框架传入的服务器时间戳。
--- @return string 当前环境的编码榜存储名称。
function Ranking:BuildRankingName(timeStamp)
    return Ranking.Super.BuildRankingName(self, timeStamp) .. "_PackedV1"
end

--- 小分数原样保存，大分数使用十进制指数与十二位有效数字组成可排序整数。
--- @param score number 非负原始力量。
--- @return number 安全范围内的云端排序分数。
local function EncodeScore(score)
    score = math.floor(score)
    if score < BucketSize then
        return score
    end
    local exponent = math.floor(math.log10(score))
    local bucket = exponent - 11
    local mantissa = math.floor(score / 10 ^ bucket)
    -- 浮点对数在十次幂边界可能向相邻指数取整，修正后才打包，避免跨桶倒序。
    if mantissa < 1e11 then
        bucket -= 1
        mantissa = math.floor(score / 10 ^ bucket)
    elseif mantissa >= BucketSize then
        bucket += 1
        mantissa = math.floor(score / 10 ^ bucket)
    end
    return bucket * BucketSize + mantissa
end

--- 还原云端展示分数；大数保留十二位有效数字，业务计算不使用该展示值。
--- @param score number 云端排序分数。
--- @return number 原量级力量。
local function DecodeScore(score)
    if score < BucketSize then
        return score
    end
    local bucket = math.floor(score / BucketSize)
    return (score % BucketSize) * 10 ^ bucket
end

--- 解码后才发布全服缓存，使框架的历史最高分比较始终使用原始力量量级。
function Ranking:LoadRankingData()
    if Memory then
        Ranking.Super.LoadRankingData(self)
        return
    end
    local success, entries = pcall(function()
        return DataStoreService:GetOrderedDataStore(self._rankingName)
            :GetSortedAsync(self._rankingType.Ascending, self._rankingType.MaxCount)
            :GetCurrentPage()
    end)
    if not success then
        warn("[StrengthRanking] load failed", entries)
        return
    end
    local data = {}
    for rankNo, entry in ipairs(entries) do
        local playerId = tonumber(entry.key)
        local playerName = entry.key
        local nameSuccess, name = pcall(Players.GetNameFromUserIdAsync, Players, playerId)
        if nameSuccess then
            playerName = name
        end
        table.insert(data, {
            rankNo = rankNo,
            rankScore = DecodeScore(entry.value),
            playerId = playerId,
            playerName = playerName,
        })
    end
    self._rankingDataCache = data
    self._isDataLoaded = true
end

--- 仅在云端写入边界编码；待写队列和玩家 KV 均保留原始成绩，失败由框架定时重试。
--- @param playerId number 服务端确定的玩家 ID。
--- @param info table 框架队列中的原始分数与昵称。
--- @return boolean 云端写入是否成功。
function Ranking:SetRankValue(playerId, info)
    if Memory then
        return Ranking.Super.SetRankValue(self, playerId, info)
    end
    local success, err = pcall(function()
        DataStoreService:GetOrderedDataStore(self._rankingName):UpdateAsync(tostring(playerId), function(old)
            local score = EncodeScore(info.score)
            if old and old >= score then
                return old
            end
            return score
        end)
    end)
    if not success then
        warn("[StrengthRanking] save failed", err)
    end
    return success
end

return Ranking
