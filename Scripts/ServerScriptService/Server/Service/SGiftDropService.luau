-- 每日个人礼盒在线计时与钻石结算；场景模型和圣光仍由接收者客户端生成。
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local FX, FS = _G.FX, _G.FS
local FXLoader = FX.Loader
local Service = {}
local drops = {}
local startupTasks = {}
local lastTimes = {}
local Fields = _G.PlayerDataConfig
local Config = _G.GameConfig.CommonConfig.GiftData
-- 最后六秒预先降落，到期落地；已经到期的未领取礼盒直接恢复到台面。
local STARTUP_HEIGHT = 60
local STARTUP_DURATION = 6

--- 累计在线时间并清理跨日礼盒，未领取档位在重进时重新生成。
--- @param playerObject table 当前登录会话的玩家对象。
--- @param now number 服务端 Unix 时间戳。
--- @return table 今日礼盒存档。
function Service.UpdateTime(playerObject, now)
    local userId = playerObject:GetPlayerId()
    local data = playerObject:GetTable(Fields.GiftData)
    local day = math.floor(now / 86400)
    local previous = lastTimes[userId] or now
    if data.day ~= day then
        data.day = day
        data.onlineSeconds = 0
        data.claimed = {}
        previous = math.max(previous, day * 86400)
        drops[userId] = {}
        FX.Network:SendMsgToClient(userId, "S2C_ClearGiftDrops")
    end
    data.onlineSeconds = math.min(Config.Time * Config.Count,
        data.onlineSeconds + math.max(0, now - previous))
    lastTimes[userId] = now
    playerObject:SetTable(Fields.GiftData, data)
    return data
end

--- 注册每日计时和一次领取协议；只认可服务端签发且已经落地的礼盒。
function Service.Init()
    local dropOrigins = {}
    for worldIndex = 1, 3 do
        dropOrigins[worldIndex] = FXLoader:Workspace(
            "Decorations/World" .. worldIndex .. "Decorations/MysteryGiftLanding/DropOrigin")
    end
    --- 玩家握手就绪后累计在线时间，提前降落即将到期的档位并恢复已到期礼盒。
    --- @param userId number 框架已完成登录的玩家 ID。
    FS.Events.OnPlayerReady.Event:Connect(function(userId)
        local player = Players:GetPlayerByUserId(userId)
        local playerObject = _G.SPlayerObjectManager:GetPlayerObject(userId)
        lastTimes[userId] = os.time()
        startupTasks[userId] = task.defer(function()
            while player and player.Parent == Players
                and _G.SPlayerObjectManager:GetPlayerObject(userId) == playerObject do
                local character = player.Character
                local root = character and character:FindFirstChild("HumanoidRootPart")
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                local data = Service.UpdateTime(playerObject, os.time())
                if root and humanoid and humanoid.Health > 0 then
                    local active = {}
                    for dropId, drop in pairs(drops[userId] or {}) do
                        if drop.Index then
                            active[drop.Index] = true
                        end
                    end
                    local approaching = math.min(Config.Count,
                        math.floor((data.onlineSeconds + STARTUP_DURATION) / Config.Time))
                    for index = 1, approaching do
                        if not data.claimed[tostring(index)] and not active[index] then
                            local dropId = Service.Spawn(player, {
                                Position = dropOrigins[playerObject:GetNumber(Fields.WorldIndex)].Position,
                                Height = STARTUP_HEIGHT,
                                Duration = math.max(0, index * Config.Time - data.onlineSeconds),
                            })
                            drops[userId][dropId].Index = index
                            drops[userId][dropId].Day = data.day
                        end
                    end
                end
                local due = math.min(Config.Count, math.floor(data.onlineSeconds / Config.Time))
                local seconds = due < Config.Count and (due + 1) * Config.Time - data.onlineSeconds or -1
                FX.Network:SendMsgToClient(userId, "S2C_GiftDropCountdown", seconds,
                    next(drops[userId] or {}) ~= nil)
                task.wait(1)
            end
            startupTasks[userId] = nil
        end)
    end)
    --- 校验身份、每日档位、落地及距离，先注销礼盒再发钻石，阻止重复结算。
    --- @param userId number 网络层认证的玩家 ID。
    --- @param dropId any 客户端请求的礼盒 ID，不接受金额或坐标。
    --- @return boolean 本次礼盒是否成功发奖。
    FX.Network:RegClientMsgCallback("C2S_OpenGiftDrop", function(userId, dropId)
        if type(dropId) ~= "string" then
            return false
        end
        local owned = drops[userId]
        local drop = owned and owned[dropId]
        local player = Players:GetPlayerByUserId(userId)
        local playerObject = _G.SPlayerObjectManager:GetPlayerObject(userId)
        local character = player and player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not drop or not playerObject or not root or not humanoid or humanoid.Health <= 0
            or workspace:GetServerTimeNow() < drop.LandsAt
            or (root.Position - drop.Position).Magnitude > 12 then
            return false
        end
        local data = Service.UpdateTime(playerObject, os.time())
        if drop.Day ~= data.day or not drop.Index or data.claimed[tostring(drop.Index)]
            or data.onlineSeconds < drop.Index * Config.Time then
            return false
        end
        owned[dropId] = nil
        if not playerObject:RequireComponent("FSRewardComp"):AddRewards({
            {Type = "Money", Currency = "Diamonds", Count = Config.Gem},
        }) then
            owned[dropId] = drop
            return false
        end
        data.claimed[tostring(drop.Index)] = true
        playerObject:SetTable(Fields.GiftData, data)
        FX.Network:SendMsgToClient(userId, "S2C_GiftDropOpened", Config.Gem, "Diamonds")
        return true
    end)
    --- 离服即释放该会话的全部未领取礼盒，不把旧资格带入新会话。
    --- @param player Player 正在离服的玩家。
    Players.PlayerRemoving:Connect(function(player)
        local startupTask = startupTasks[player.UserId]
        if startupTask then
            task.cancel(startupTask)
            startupTasks[player.UserId] = nil
        end
        drops[player.UserId] = nil
        lastTimes[player.UserId] = nil
    end)
end

--- 由其他服务端功能签发个人礼盒；不提供客户端申请生成奖励的接口。
--- @param player Player 接收礼盒的在线玩家。
--- @param options table Position 地面位置、Height 降落高度、Duration 降落秒数（0 为恢复到台面）；补入 LandsAt 服务端落地时间。
--- @return string 礼盒唯一 ID。
function Service.Spawn(player, options)
    assert(player.Parent == Players and _G.SPlayerObjectManager:GetPlayerObject(player.UserId),
        "Gift recipient must have an active player object")
    assert(typeof(options.Position) == "Vector3", "Position must be a Vector3")
    assert(type(options.Height) == "number" and options.Height > 0 and options.Height < math.huge,
        "Height must be finite and positive")
    assert(type(options.Duration) == "number" and options.Duration >= 0 and options.Duration < math.huge,
        "Duration must be finite and non-negative")
    local dropId = HttpService:GenerateGUID(false)
    local owned = drops[player.UserId] or {}
    drops[player.UserId] = owned
    options.LandsAt = workspace:GetServerTimeNow() + options.Duration
    owned[dropId] = {Position = options.Position, LandsAt = options.LandsAt}
    FX.Network:SendMsgToClient(player.UserId, "S2C_SpawnGiftDrop", dropId, options)
    return dropId
end

return Service
