-- 个人礼盒资格与固定金币结算；场景模型和圣光仍由接收者客户端生成。
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local FX, FS = _G.FX, _G.FS
local Service = {}
local drops = {}
local startupTasks = {}
local REWARD = 100
-- 开局个人礼盒参数；落点取玩家出生位置附近的实际地面。
local STARTUP_HEIGHT = 60
local STARTUP_DURATION = 5
local STARTUP_OFFSET = Vector3.new(6, 0, 0)

--- 注册一次领取协议；只认可服务端签发给当前玩家且已经落地的礼盒。
function Service.Init()
    --- 玩家存档与客户端握手就绪后，等待首个角色出现；重生不再次触发就绪事件。
    --- @param userId number 框架已完成登录的玩家 ID。
    FS.Events.OnPlayerReady.Event:Connect(function(userId)
        local player = Players:GetPlayerByUserId(userId)
        local playerObject = _G.SPlayerObjectManager:GetPlayerObject(userId)
        startupTasks[userId] = task.defer(function()
            while player and player.Parent == Players
                and _G.SPlayerObjectManager:GetPlayerObject(userId) == playerObject do
                local character = player.Character
                local root = character and character:FindFirstChild("HumanoidRootPart")
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                if root and humanoid and humanoid.Health > 0 then
                    local params = RaycastParams.new()
                    params.FilterType = Enum.RaycastFilterType.Exclude
                    params.FilterDescendantsInstances = {character}
                    local origin = root.Position + STARTUP_OFFSET + Vector3.new(0, 8, 0)
                    local hit = workspace:Raycast(origin, Vector3.new(0, -64, 0), params)
                    if hit then
                        Service.Spawn(player, {
                            Position = hit.Position,
                            Height = STARTUP_HEIGHT,
                            Duration = STARTUP_DURATION,
                        })
                    else
                        warn("Startup gift has no ground near player " .. userId)
                    end
                    break
                end
                task.wait(0.1)
            end
            startupTasks[userId] = nil
        end)
    end)
    --- 校验身份、资格、落地时间及近身位置，先注销礼盒再加钱，阻止重复结算。
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
        owned[dropId] = nil
        if not playerObject:RequireComponent("FSRewardComp"):AddRewards({
            {Type = "Money", Currency = "Money", Count = REWARD},
        }) then
            owned[dropId] = drop
            return false
        end
        FX.Network:SendMsgToClient(userId, "S2C_GiftDropOpened", REWARD)
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
    end)
end

--- 由其他服务端功能签发个人礼盒；不提供客户端申请生成奖励的接口。
--- @param player Player 接收礼盒的在线玩家。
--- @param options table Position 地面位置、Height 降落高度、Duration 降落秒数。
--- @return string 礼盒唯一 ID。
function Service.Spawn(player, options)
    assert(player.Parent == Players and _G.SPlayerObjectManager:GetPlayerObject(player.UserId),
        "Gift recipient must have an active player object")
    assert(typeof(options.Position) == "Vector3", "Position must be a Vector3")
    assert(type(options.Height) == "number" and options.Height > 0 and options.Height < math.huge,
        "Height must be finite and positive")
    assert(type(options.Duration) == "number" and options.Duration > 0 and options.Duration < math.huge,
        "Duration must be finite and positive")
    local dropId = HttpService:GenerateGUID(false)
    local owned = drops[player.UserId] or {}
    drops[player.UserId] = owned
    owned[dropId] = {Position = options.Position, LandsAt = workspace:GetServerTimeNow() + options.Duration}
    FX.Network:SendMsgToClient(player.UserId, "S2C_SpawnGiftDrop", dropId, options)
    return dropId
end

return Service
