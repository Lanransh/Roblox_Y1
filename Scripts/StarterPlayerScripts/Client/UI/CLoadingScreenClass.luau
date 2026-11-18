-- 入场加载只准备前期资源；展示交给 UIEditor View，数据就绪沿用现有握手。
local FX, FC = _G.FX, _G.FC
local FXLoader = FX.Loader
FXLoader:RequireFromParent(script, "Generated/CUIView")
FXLoader:RequireFromParent(script, "Generated/CRockTreasureLoadingConceptView")
local InstancePath = FXLoader:RequireShared("Scripts/Game/Shared/InstancePath")
local Weapon = FXLoader:RequireShared("Scripts/Game/Shared/Weapon")
local ContentProvider = game:GetService("ContentProvider")
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local Loading = FX.Class("CLoadingScreenClass", "CRockTreasureLoadingConceptView")
local ACTION = "RockTreasureLoading"

--- 主入口临时持有加载 View，不挂入尚未创建的玩家对象，避免等待握手才显示。
--- @param owner table? 启动时为 nil；本类不访问玩家组件接口。
function Loading:Ctor(owner)
    Loading.Super.Ctor(self, owner)
    self.State = {current = 0, target = 0, status = "Loading"}
end

--- 更新完整展示状态，实际文案与进度条属性由生成 View 处理。
--- @param status string View 契约中的状态 ID。
function Loading:SetStatus(status)
    self.State.status = status
    self:RefreshUI()
end

--- 跳过仅收起加载页；资源等待、握手及入场检查继续按原流程执行。
--- @param action string View 发出的 Skip 动作。
--- @param payload table Skip 无业务参数。
function Loading:OnUIAction(action, payload)
    assert(action == "Skip", "Unsupported loading action: " .. action)
    if self._failed or self._finished or self.State.skipRequested then
        return
    end
    self.State.skipRequested = true
    self:ClosePage()
end

--- 收起页面并释放其输入占用，后台加载对象保留到初始化实际完成。
function Loading:ClosePage()
    if self._pageClosed then
        return
    end
    self._pageClosed = true
    self:Hide()
    ContextActionService:UnbindAction(ACTION)
    if self._backpackTask and coroutine.status(self._backpackTask) ~= "dead" then
        task.cancel(self._backpackTask)
    end
    if self._backpackEnabled ~= nil then
        local success, message = pcall(function()
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, self._backpackEnabled)
        end)
        if not success then
            warn("[Loading] Restore backpack:", message)
        end
    end
end

--- 有限等待真实复制或初始化条件，超时保留加载页，不冒充准备成功。
--- @param predicate function 返回已准备对象或真值。
--- @param description string 仅用于开发日志的条件说明。
--- @return any 已准备对象或真值。
function Loading:WaitFor(predicate, description)
    while not self._failed do
        local result = predicate()
        if result then
            return result
        end
        assert(os.clock() < self._deadline, "Loading timed out: " .. description)
        task.wait(0.1)
    end
    error("Loading stopped: " .. description)
end

--- 加载失败记录具体原因；页面尚未关闭时保留失败提示，已关闭时不重新弹出。
--- @param message string 异步初始化或复制失败原因。
function Loading:Fail(message)
    if self._failed or self._finished then
        return
    end
    self._failed = true
    self:SetStatus("Failed")
    warn("[Loading]", message)
end

--- 先在启动期限内等待加载页复制，再绑定 View；避免默认十秒等待提前中断客户端入口。
function Loading:Start()
    self._deadline = os.clock() + 120
    local playerGui = FXLoader:Player("PlayerGui")
    self:WaitFor(function()
        return FXLoader:Find(playerGui, self.ScreenGuiName)
    end, "loading interface replication")
    -- CoreGui 可能尚未初始化；独立重试，避免阻塞加载页显示。
    self._backpackTask = task.spawn(function()
        while not self._pageClosed do
            local success = pcall(function()
                if self._backpackEnabled == nil then
                    self._backpackEnabled = StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Backpack)
                end
                StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
            end)
            if success then
                return
            end
            task.wait(0.1)
        end
    end)
    Loading.Super.OnReady(self)
    self:Show()
    -- 高优先级覆盖移动、跳跃和快捷栏；View 的全屏遮罩拦截世界点击。
    ContextActionService:BindActionAtPriority(ACTION, function()
        return Enum.ContextActionResult.Sink
    end, false, 10000, Enum.UserInputType.Keyboard, table.unpack(Enum.PlayerActions:GetEnumItems()))
    -- 原生 UI 继续接收鼠标、触摸和手柄按钮；世界操作由现有输入入口的处理标记拦截。
    self:TrackConnection(FC.Localization.Changed:Connect(function()
        self:RefreshUI()
    end))
    self._watchdog = task.spawn(function()
        while not self._finished and not self._failed do
            if os.clock() >= self._deadline then
                self:Fail("Client startup exceeded 120 seconds")
                return
            end
            task.wait(0.5)
        end
    end)
    self._resourceTask = task.spawn(function()
        local success, message = xpcall(function()
            self:PrepareResources()
        end, debug.traceback)
        if not success then
            warn("[Loading] Optional startup resources:", message)
            if not self._finished and not self._failed then
                self._resourcesReady = true
                self:SetStatus("Waiting")
            end
        end
    end)
end

--- 流式加载按实际位置请求；请求返回仍须单独核对地面，不能视为整个场景已到达。
--- @param position Vector3 基地或角色的实际准备位置。
function Loading:RequestRegion(position)
    if workspace.StreamingEnabled then
        local success, message = pcall(function()
            Players.LocalPlayer:RequestStreamAroundAsync(position, 15)
        end)
        if not success then
            warn("[Loading] Streaming request:", message)
        end
    end
end

--- 先发布资源总量，再独立解析与下载；收起页面不改变等待流程，超时下载仍继续。
function Loading:PrepareResources()
    self:WaitFor(function()
        return game:IsLoaded()
    end, "initial replication")
    local config = _G.GameConfig
    local resources = {self:GetRootNode()}
    -- LevelConfig 为字典；第一世界关卡数量按稳定的 World1 前缀统计。
    local stages = 0
    for key in pairs(config.LevelConfig) do
        if string.match(key, "^World1%.Level_%d+$") then
            stages += 1
        end
    end
    local count = math.min(config.CommonConfig.ToyCandidateCount, stages * config.CommonConfig.ToyItemsPerStage)
    for index = 1, count do
        local item = config.ItemData[index]
        table.insert(resources, item.DisplayModelId)
        table.insert(resources, "rbxassetid://" .. item.IconId)
    end
    for index = 1, 3 do
        local tool = config.ToolConfig[index]
        table.insert(resources, tool.ModelId)
        table.insert(resources, "rbxassetid://" .. tool.Img)
    end
    table.insert(resources, config.AuraConfig[1].ModelId)
    table.insert(resources, "rbxassetid://" .. config.AuraConfig[1].Img)
    table.insert(resources, "game.Workspace.BlockMeshs.World1Root.Base")
    table.insert(resources, "game.Workspace.BlockMeshs.World1Root.TrainingCenter")
    table.insert(resources, "game.Workspace.BlockMeshs.World1Root.GuanQia.Ground1")
    for index, name in ipairs({"Shop", "PurpleHut", "BlueHut", "ShopBackGarden", "GroupRewardChest"}) do
        table.insert(resources, "game.Workspace.Decorations.World1Decorations." .. name)
    end
    table.insert(resources, "game.ReplicatedStorage.Assets.Models.SyntyRocks")
    table.insert(resources, "game.ReplicatedStorage.Assets.Effects.ROCK")
    table.insert(resources, "game.ReplicatedStorage.Assets.Sounds.Time To Relax")
    table.insert(resources, "game.ReplicatedStorage.Assets.Sounds.Waltzing Flutes")
    self.State.target = #resources + 3 -- 数据握手、当前装备、角色及脚下地面。
    self:RefreshUI()
    -- 请求区域也可能等待网络；与下载并行，不把进度停在零。
    self._regionTask = task.spawn(function()
        self:RequestRegion(_G.GameEnum.WorldTransferConfig[1].Position)
        local level = FXLoader:Find(workspace, "GameLevelList/World1/Level_1")
        if level then
            self:RequestRegion(level.Position)
        end
    end)
    -- 下载任务只持有资源与完成计数；页面销毁只结束前台等待，不取消后台下载。
    local completed = 0
    for index, resource in ipairs(resources) do
        task.spawn(function()
            local success, message = pcall(function()
                local asset = resource
                if type(resource) == "string" and string.sub(resource, 1, 5) == "game." then
                    if string.sub(resource, 1, 15) == "game.Workspace." then
                        asset = InstancePath.Find(resource)
                        if not asset then
                            warn("[Loading] Optional scene resource not streamed:", resource)
                            return
                        end
                    else
                        asset = InstancePath.Wait(resource)
                    end
                end
                ContentProvider:PreloadAsync({asset}, function(assetId, status)
                    if status ~= Enum.AssetFetchStatus.Success then
                        warn("[Loading] Asset unavailable:", assetId, status)
                    end
                end)
            end)
            if not success then
                warn("[Loading] Preload failed:", message)
            end
            completed += 1
        end)
    end
    local preloadDeadline = os.clock() + 45
    while completed < #resources and not self._failed and os.clock() < preloadDeadline do
        self.State.current = completed
        self:RefreshUI()
        task.wait(0.05)
    end
    if completed < #resources and not self._failed then
        warn("[Loading] Asset download exceeded the foreground time limit; continuing in background")
    end
    if not self._failed then
        self.State.current = completed
        self._resourcesReady = true
        self:SetStatus("Waiting")
    end
end

--- 主入口握手完成后检查复制、资源、镐子及地面；页面关闭不影响真实完成判定。
function Loading:Finish()
    local success, message = xpcall(function()
        self:WaitFor(function()
            return game:IsLoaded()
        end, "initial replication")
        self:WaitFor(function()
            return self._resourcesReady
        end, "startup resources")
        self.State.current += 1
        self:RefreshUI()
        local player = Players.LocalPlayer
        local weapon = Weapon.GetEquippedConfig(FC.PlayerObject:GetTable(_G.PlayerDataConfig.WeaponData))
        local tool = self:WaitFor(function()
            local containers = {}
            local backpack = player:FindFirstChildOfClass("Backpack")
            if backpack then
                table.insert(containers, backpack)
            end
            if player.Character then
                table.insert(containers, player.Character)
            end
            for index, container in ipairs(containers) do
                for childIndex, node in ipairs(container:GetChildren()) do
                    if node:IsA("Tool") and node:GetAttribute("StarterPickaxe") == true
                        and node:GetAttribute("WeaponId") == weapon.ToolId then
                        return node
                    end
                end
            end
        end, "equipped pickaxe")
        -- 镐子贴图沿用十秒等待上限；收起页面不提前结束等待。
        local ready = false
        task.spawn(function()
            local ok, problem = pcall(function()
                ContentProvider:PreloadAsync({tool})
            end)
            if not ok then
                warn("[Loading] Equipped pickaxe preload:", problem)
            end
            ready = true
        end)
        local deadline = os.clock() + 10
        while not ready and not self._failed and os.clock() < deadline do
            task.wait(0.05)
        end
        self.State.current += 1
        self:RefreshUI()
        local root = self:WaitFor(function()
            local character = player.Character
            return character and character:FindFirstChild("HumanoidRootPart")
        end, "character")
        self:RequestRegion(root.Position)
        self:WaitFor(function()
            local character = player.Character
            local currentRoot = character and character:FindFirstChild("HumanoidRootPart")
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if not currentRoot or not humanoid or humanoid.Health <= 0 then
                return false
            end
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.FilterDescendantsInstances = {character}
            params.RespectCanCollide = true
            return workspace:Raycast(currentRoot.Position, Vector3.new(0, -12, 0), params)
        end, "collidable ground beneath character")
        self.State.current = self.State.target
        self:RefreshUI()
        RunService.RenderStepped:Wait()
        self._finished = true
        self:ClosePage()
        self:Dtor()
    end, debug.traceback)
    if not success then
        self:Fail(message)
    end
end

--- 释放页面持有的启动任务与输入限制；独立下载不持有 View，可在关闭后继续完成。
function Loading:Dtor()
    self._finished = true
    self:ClosePage()
    for index, worker in pairs({self._watchdog, self._resourceTask, self._regionTask}) do
        if coroutine.status(worker) ~= "dead" and worker ~= coroutine.running() then
            task.cancel(worker)
        end
    end
    Loading.Super.Dtor(self)
end

return Loading
