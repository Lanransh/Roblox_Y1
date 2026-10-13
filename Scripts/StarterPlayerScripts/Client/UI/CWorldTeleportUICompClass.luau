local FX = _G.FX
local FXLoader = FX.Loader
local RunService = game:GetService("RunService")
FXLoader:RequireFromParent(script, "Generated/CWorldTeleportView")
local GameEnum = _G.GameEnum
local Fields = _G.PlayerDataConfig
local Component = FX.Class("CWorldTeleportUICompClass", "CWorldTeleportView")

--- 世界条目配色沿用编辑器示例，按配置顺序循环取用，避免多个世界共用同一底色。
local WorldColors = {
    {Color = "#45a85a", EdgeColor = "#1d542a"},
    {Color = "#d9ab27", EdgeColor = "#7d5b0b"},
    {Color = "#8a4dc2", EdgeColor = "#48246b"},
    {Color = "#249cb5", EdgeColor = "#105464"},
    {Color = "#397bc7", EdgeColor = "#193e73"},
}

--- 返回世界传送界面组件名，供主界面等入口打开。
--- @return string 玩家内协作名称。
function Component:GetCompName()
    return "CWorldTeleportUIComp"
end

--- 复用导出的列表与动作，接入服务端同步的历史最高等级和当前世界。
function Component:OnReady()
    Component.Super.OnReady(self)
    local root = self:GetRootNode()
    root.ResetOnSpawn = false
    root.DisplayOrder = 10
    self._commonUI = self:GetPlayerObject():RequireComponent("FCCommonUIComp")
    self._commonUI:RegisterTrainingClickModal(root)
    self._localization = self._commonUI.Localization
    -- 展示契约按等级判断解锁；使用历史最高等级，重生后保留传送资格。
    self.Config = {worlds = {}}
    for index, world in ipairs(GameEnum.WorldTransferConfig) do
        local palette = WorldColors[(index - 1) % #WorldColors + 1]
        table.insert(self.Config.worlds, {
            id = world.Id, name = world.Name, requiredLevel = world.NeedTrainingLevel,
            color = palette.Color, edgeColor = palette.EdgeColor,
        })
    end
    self.State = {level = 0, currentWorldId = nil}
    self:Hide()
    self:BindUIData()
    self:BindPortalArea()
end

--- 历史最高等级与当前世界都由服务端同步，本地不推断传送资格。
function Component:BindUIData()
    self:WatchDataChanged(Fields.MaxTrainingLevel, self.RefreshWorlds, self)
    self:WatchDataChanged(Fields.WorldIndex, self.RefreshWorlds, self)
end

--- 按世界配置绑定金色传送门；场景入口缺失时保留其他世界的入口。
function Component:BindPortalArea()
    self._portals = {}
    for index, world in ipairs(GameEnum.WorldTransferConfig) do
        local portal = FXLoader:Find(workspace, world.PortalPath)
        if portal then
            local center, size = portal:GetBoundingBox()
            table.insert(self._portals, {Node = portal, Center = center, Size = size})
        else
            FX.Log:Warn("CWorldTeleportUICompClass: portal not found: " .. world.PortalPath)
        end
    end
    if #self._portals == 0 then
        return
    end
    -- 门体固定不动，进场检测只缓存一次包围盒，避免每次遍历门体装饰。
    self._inPortalArea = false
    self._portalCharacter = nil
    self._nextPortalCheck = 0
    --- 只检测本地角色位置，每 0.1 秒检查一次；显隐仅在进出边沿改变。
    self:TrackConnection(RunService.Heartbeat:Connect(function()
        local now = os.clock()
        if now < self._nextPortalCheck then
            return
        end
        self._nextPortalCheck = now + 0.1
        self:UpdatePortalArea()
    end))
    self:UpdatePortalArea()
end

--- 按传送门包围盒检测进出；手动关闭后留在门内不会反复弹出，离开时自动关闭。
function Component:UpdatePortalArea()
    local character = self:GetPlayerCharacter()
    if character ~= self._portalCharacter then
        self._portalCharacter = character
        self._inPortalArea = false
        self:Hide()
    end
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local inside = false
    if root and humanoid and humanoid.Health > 0 then
        for index, portal in ipairs(self._portals) do
            if portal.Node:IsDescendantOf(workspace) then
                local point = portal.Center:PointToObjectSpace(root.Position)
                local half = portal.Size * 0.5
                -- 金环装饰很高，只认贴近地面的高度，避免从门体上方经过时触发。
                local height = point.Y + half.Y
                if math.abs(point.X) <= half.X and math.abs(point.Z) <= half.Z
                    and height >= 0 and height <= 11
                then
                    inside = true
                    break
                end
            end
        end
    end
    if inside == self._inPortalArea then
        return
    end
    self._inPortalArea = inside
    if inside then
        self:Show()
    else
        self:Hide()
    end
end

--- 用服务端字段刷新列表：历史最高等级决定解锁，当前世界由服务端落点决定。
function Component:RefreshWorlds()
    local index = math.floor(self:GetNumber(Fields.WorldIndex))
    local world = GameEnum.WorldTransferConfig[index]
    self.State.level = self:GetNumber(Fields.MaxTrainingLevel)
    self.State.currentWorldId = world and world.Id or nil
    self:RefreshUI()
end

--- 每次打开清空上次失败提示，列表沿用数据订阅的最新状态。
function Component:OnShow()
    self.State.error = nil
    Component.Super.OnShow(self)
end

--- 关闭界面，或请求服务端传送；客户端只提交稳定世界 ID 对应的配置序号。
--- @param action string 展示类动作，Teleport 或 Close。
--- @param payload table Teleport 携带 worldId，Close 为空表。
function Component:OnUIAction(action, payload)
    if action == "Close" then
        self:Hide()
        return
    end
    assert(action == "Teleport", "Unsupported world teleport action: " .. tostring(action))
    if self.State.pendingWorldId then
        return
    end
    local index = self:_FindWorldIndex(payload.worldId)
    assert(index ~= nil, "Unknown world id: " .. tostring(payload.worldId))
    self.State.pendingWorldId = payload.worldId
    self.State.error = nil
    self:RefreshUI()
    self._transferTask = task.defer(function()
        --- 白名单 RPC 只传序号；历史等级门槛、落点和世界状态都由服务端决定。
        local ok, result = pcall(function()
            return FX.Network:InvokeServer("C2S_TransferWorld", index)
        end)
        self._transferTask = nil
        self.State.pendingWorldId = nil
        local failure
        if not ok or type(result) ~= "table" then
            failure = {key = "Common.Unknown"}
        elseif not result.success then
            failure = {key = result.key or "Common.Unknown", arguments = result.arguments}
        end
        self.State.error = failure and self._localization:FormatByKey(failure.key, failure.arguments) or nil
        -- 成功时由服务端同步的世界序号刷新当前世界，不在客户端改写。
        self:RefreshWorlds()
    end)
end

--- 按稳定世界 ID 找到配置序号，找不到时返回 nil。
--- @param worldId string 世界配置的稳定 ID。
--- @return number? 世界传送列表序号。
function Component:_FindWorldIndex(worldId)
    for index, world in ipairs(GameEnum.WorldTransferConfig) do
        if world.Id == worldId then
            return index
        end
    end
    return nil
end

--- 释放尚未返回的传送请求，父类清理列表克隆、按钮与数据监听。
function Component:Dtor()
    if self._transferTask then
        task.cancel(self._transferTask)
        self._transferTask = nil
    end
    Component.Super.Dtor(self)
end

return Component
