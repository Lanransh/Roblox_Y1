local FX, FS = _G.FX, _G.FS
local FXLoader = FX.Loader
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Fields = _G.PlayerDataConfig
local Storage = FS.PlayerKVDataManager
local TrainingFields = FXLoader:RequireFromParent(script, "TrainingFields")

--- 训练挂机重进：仅使用公开存档接口，重进数据不携带奖励或客户端坐标。
local Component = FX.Class("STrainingRejoinCompClass", "FSPlayerCompClass")

--- 提供玩家内训练重进业务入口。
--- @return string 组件协作名称。
function Component:GetCompName()
    return "STrainingRejoinComp"
end

--- 构造时准备恢复记录，避免其他组件登录时让出执行后训练计时器先恢复角色。
--- @param owner table 已读档的玩家对象。
function Component:Ctor(owner)
    Component.Super.Ctor(self, owner)
    self._player = self:GetPlayerNode()
    self._session = Storage:GetSessionToken(self:GetPlayerId())
    self._nextRequest = 0
    local context = self:GetTable(Fields.TrainingRejoinContext)
    local join = self._player:GetJoinData()
    local data = join.TeleportData
    if self:GetFlag(Fields.TrainingRejoinEnabled) and join.SourcePlaceId == game.PlaceId
        and type(data) == "table" and type(context.id) == "string"
        and data.TrainingRejoinId == context.id then
        self._resume = context
    end
    self:SetTable(Fields.TrainingRejoinContext, {})
    self:SetStatus("Idle")
    self:TrackConnection(TeleportService.TeleportInitFailed:Connect(function(player, result, message, placeId, options)
        local attempt = self._attempt
        local teleportData = options and options:GetTeleportData()
        if player == self._player and placeId == game.PlaceId and attempt and attempt.status == "Teleporting"
            and type(teleportData) == "table" and teleportData.TrainingRejoinId == attempt.id then
            warn("[TrainingRejoin] Teleport failed", player.UserId, result, message)
            self:FailAttempt(attempt, "TeleportFailed")
        end
    end))
end

--- 只给仍属于原对象和存档会话的玩家更新同步状态。
--- @return boolean 当前组件是否仍可读写。
function Component:IsSessionActive()
    return self._player ~= nil and Players:GetPlayerByUserId(self:GetPlayerId()) == self._player
        and FS.PlayerManager:GetPlayerObject(self:GetPlayerId()) == self:GetPlayerObject()
        and Storage:IsSessionActive(self:GetPlayerId(), self._session)
end

--- 状态只作 UI 展示，不参与训练奖励计算。
--- @param status string Idle / Saving / Teleporting / Retrying / SaveFailed / TeleportFailed / Studio。
function Component:SetStatus(status)
    self._player:SetAttribute("TrainingRejoinStatus", status)
end

--- 以实时角色、场地和解锁条件判定资格，不相信客户端空闲秒数或训练场索引。
--- @return table? 当前合法场地配置。
--- @return BasePart? 本次角色根节点。
function Component:GetTrainingField()
    if not self:GetFlag(Fields.TrainingRejoinEnabled) then
        return nil
    end
    local character = self:GetPlayerCharacter()
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local field = root and TrainingFields.GetAtPosition(root.Position)
    if not humanoid or humanoid.Health <= 0 or not field
        or self:GetNumber(Fields.RebirthCount) < field.NeedRebirhLevel
        or self:GetNumber(Fields.TrainingFieldIndex) ~= field.Index then
        return nil
    end
    return field, root
end

--- 取消尚未发起的重进；进行中的存档协程自行返回，不能强行取消并破坏存档锁。
function Component:CancelPending()
    -- 平台传送已发起后无法撤回，保留恢复记录；若传送失败则不再自动重试。
    if self._attempt and self._attempt.status == "Teleporting" then
        self._attempt.cancelled = true
        return
    end
    self._attempt = nil
    self._resume = nil
    self:SetTable(Fields.TrainingRejoinContext, {})
    self:SetStatus("Idle")
end

--- 接受本人开关、取消或重进请求；每轮最多三次，并限制客户端反复创建流程。
--- @param action any SetEnabled / Cancel / Request。
--- @param enabled any SetEnabled 时必须为 boolean。
function Component:Request(action, enabled)
    if not self:IsSessionActive() then
        return
    end
    if action == "SetEnabled" and type(enabled) == "boolean" then
        self:SetFlag(Fields.TrainingRejoinEnabled, enabled)
        if not enabled then
            self:CancelPending()
        end
    elseif action == "Cancel" then
        self:CancelPending()
    elseif action == "Request" and not self._attempt and not self._working and os.clock() >= self._nextRequest
        and self:GetTrainingField() then
        self._nextRequest = os.clock() + 60
        if RunService:IsStudio() then
            self:SetStatus("Studio")
            return
        end
        self._attempt = {count = 0, status = "Retrying", nextAt = os.clock()}
    end
end

--- 保存失败终止；传送失败间隔二十秒重试，最多三次，保留当前游戏会话。
--- @param attempt table 当前流程身份。
--- @param reason string SaveFailed / TeleportFailed。
function Component:FailAttempt(attempt, reason)
    if not self:IsSessionActive() or self._attempt ~= attempt then
        return
    end
    self:SetTable(Fields.TrainingRejoinContext, {})
    if attempt.cancelled then
        self._attempt = nil
        self:SetStatus("Idle")
    elseif reason == "TeleportFailed" and attempt.count < 3 then
        attempt.status = "Retrying"
        attempt.nextAt = os.clock() + 20
        self:SetStatus("Retrying")
    else
        self._attempt = nil
        self:SetStatus(reason)
    end
end

--- 每次重试都保存最新进度与服务端位置；保存完成后再次检查原会话、取消状态及场地。
--- @param attempt table 当前流程，客户端不能构造此对象。
function Component:RunAttempt(attempt)
    if not self:IsSessionActive() or self._attempt ~= attempt then
        return
    end
    local field, root = self:GetTrainingField()
    if not field then
        self:CancelPending()
        return
    end
    self._working = true
    attempt.count += 1
    attempt.status = "Saving"
    attempt.id = HttpService:GenerateGUID(false)
    self:SetStatus("Saving")
    local position = root.Position
    local context = {id = attempt.id, fieldIndex = field.Index, expiresAt = os.time() + 300,
        position = {position.X, position.Y, position.Z}}
    self:SetTable(Fields.TrainingRejoinContext, context)
    self:RequireComponent("SAnalyticsComp"):AccountTime()
    local ok, saved = pcall(Storage.Save, Storage, self:GetPlayerId(), self._session)
    if not self:IsSessionActive() or self._attempt ~= attempt then
        self._working = false
        return
    end
    if not ok or not saved then
        self._working = false
        self:FailAttempt(attempt, "SaveFailed")
        return
    end
    local currentField, currentRoot = self:GetTrainingField()
    if currentField ~= field or currentRoot ~= root or (currentRoot.Position - position).Magnitude > 3 then
        self._working = false
        self:CancelPending()
        return
    end
    attempt.status = "Teleporting"
    attempt.deadline = os.clock() + 45
    self:SetStatus("Teleporting")
    local options = Instance.new("TeleportOptions")
    options:SetTeleportData({TrainingRejoinId = attempt.id})
    local teleported, message = pcall(TeleportService.TeleportAsync, TeleportService, game.PlaceId, {self._player}, options)
    self._working = false
    if not teleported and self._attempt == attempt and attempt.status == "Teleporting" then
        warn("[TrainingRejoin] Teleport call failed", self:GetPlayerId(), message)
        self:FailAttempt(attempt, "TeleportFailed")
    end
end

--- 框架每秒驱动重试与超时；客户端停止操作只作触发，不产生任何奖励。
--- @param serverTime number 框架更新时间，此处使用单调时钟。
function Component:OnUpdate(serverTime)
    local attempt = self._attempt
    if not attempt or self._working then
        return
    end
    if attempt.status == "Teleporting" then
        if not self:GetTrainingField() then
            attempt.cancelled = true
        end
        if os.clock() >= attempt.deadline then
            self:FailAttempt(attempt, "TeleportFailed")
        end
    elseif not self:GetTrainingField() then
        self:CancelPending()
    elseif attempt.status == "Retrying" and os.clock() >= attempt.nextAt then
        self._task = FX.Task:Spawn(function()
            self:RunAttempt(attempt)
        end)
    end
end

--- 正常世界恢复之后只恢复一次；校验服务器存档中的坐标、有效期与当前场地资格。
--- @param character Model 已完成正常世界恢复的本次角色。
function Component:RestoreTraining(character)
    local context = self._resume
    self._resume = nil
    if not context or type(context.expiresAt) ~= "number" or os.time() > context.expiresAt
        or type(context.position) ~= "table" or not self:GetFlag(Fields.TrainingRejoinEnabled) then
        return
    end
    for index = 1, 3 do
        local value = context.position[index]
        if type(value) ~= "number" or value ~= value or math.abs(value) == math.huge then
            return
        end
    end
    local position = Vector3.new(context.position[1], context.position[2], context.position[3])
    local field = TrainingFields.GetAtPosition(position)
    if field and field.Index == context.fieldIndex
        and self:GetNumber(Fields.RebirthCount) >= field.NeedRebirhLevel then
        character:PivotTo(CFrame.new(position))
    end
end

--- 离服只使异步结果失效；存档的保存、释放与会话交接继续由框架完成。
function Component:OnPlayerLogout()
    self._attempt = nil
    self._resume = nil
    self._player = nil
end

return Component
