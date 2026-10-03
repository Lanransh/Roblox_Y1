local FX = _G.FX
local Fields = _G.PlayerDataConfig
local RockLevel = require(game:GetService("ReplicatedStorage").Scripts.Game.Shared.RockLevel)
local Component = FX.Class("SRockLevelCompClass", "FSPlayerCompClass")

--- 玩家各自持有石头状态，沿用源关卡互不影响的规则。
--- @param owner FSPlayerObjectClass 已加载的玩家对象。
function Component:Ctor(owner)
    Component.Super.Ctor(self, owner)
    self._health = {}
    self._lastAttack = -1
    self._lastGrowth = os.clock()
    self._hit = false
end

--- 返回项目组件协作名称。
--- @return string 组件名称。
function Component:GetCompName()
    return "SRockLevelComp"
end

--- 读档后将地板颜色复制到常驻关卡标记并启动位置检查，客户端无需等待远处地板流入。
function Component:OnPlayerLogin()
    self._areas = RockLevel.GetAreas()
    local grounds = workspace:WaitForChild("BlockMeshs"):WaitForChild("世界1"):WaitForChild("GuanQia")
    for index, area in ipairs(self._areas) do
        local ground = grounds:WaitForChild("Ground" .. index)
        area.Node.Color = ground.Color
    end
    local player = self:GetPlayerNode()
    self._stats = player:FindFirstChild("leaderstats")
    self._ownsStats = self._stats == nil
    if self._ownsStats then
        self._stats = Instance.new("Folder")
        self._stats.Name = "leaderstats"
        self._stats.Parent = player
    end
    self._levelStat = Instance.new("IntValue")
    self._levelStat.Name = "训练等级"
    self._levelStat.Parent = self._stats
    self._strengthStat = Instance.new("NumberValue")
    self._strengthStat.Name = "力量"
    self._strengthStat.Parent = self._stats
    self:RefreshProgress()
    self._timer = FX.Task:Interval(0.1, function()
        self:Tick()
    end)
end

--- 将持久训练值派生为同步等级，并暴露原生玩家属性便于检查。
function Component:RefreshProgress()
    local level, strength = RockLevel.GetProgress(self:GetNumber(Fields.RockTrainingValue))
    self:SetNumber(Fields.RockTrainingLevel, level)
    local player = self:GetPlayerNode()
    player:SetAttribute("TrainingLevel", level)
    player:SetAttribute("Strength", strength)
    self._levelStat.Value = level
    self._strengthStat.Value = strength
end

--- 在出生或回到世界 1 起点安全区域时恢复本人的全部石头。
function Component:RestoreRocks()
    if next(self._health) ~= nil then
        self._health = {}
        self:SetTable(Fields.RockHealth, self._health)
    end
    self._hit = false
end

--- 每次只处理朝向上最近的未破坏石头；保留每秒常规攻击和间隔内一击击破的节奏。
function Component:Tick()
    local character = self:GetPlayerCharacter()
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0 then
        self._lastPosition = nil
        self._hit = false
        return
    end
    local now = os.clock()
    local position = root.Position
    if self._character ~= character then
        self._character = character
        self._lastPosition = position
        self._lastGrowth = now
        self:RestoreRocks()
    end
    local firstArea = self._areas[1]
    local inSafeArea = position.Z < firstArea.MinZ - 8
        and position.Z >= firstArea.MinZ - 100
        and math.abs(position.X) <= 72
        and math.abs(position.Y - firstArea.FloorY) < 16
    if inSafeArea then
        self:RestoreRocks()
    end
    local regularAttack = now - self._lastAttack >= 1
    local changed = false
    local targetFound = false
    local level = self:GetNumber(Fields.RockTrainingLevel)
    for index = 1, #self._areas do
        local area = self._areas[index]
        if math.abs(position.Y - area.FloorY) < 12
            and position.X >= area.MinX - 8 and position.X < area.MinX + area.Node.Size.X + 8
            and position.Z >= area.MinZ - 8 and position.Z < area.MinZ + area.Node.Size.Z + 8 then
            local damage = RockLevel.GetDamage(level, index)
            local cells = RockLevel.GetFrontCells(area, position, root.CFrame.LookVector)
            for cellIndex = 1, #cells do
                local key = cells[cellIndex]
                local health = self._health[key] or RockLevel.HP[index]
                if health > 0 then
                    targetFound = true
                    if damage > 0 and (regularAttack or health <= damage) then
                        self._health[key] = math.max(0, health - damage)
                        changed = true
                        self._hit = true
                    end
                    break
                end
            end
        end
        if targetFound then
            break
        end
    end
    if regularAttack then
        self._lastAttack = now
    end
    if changed then
        self:SetTable(Fields.RockHealth, self._health)
    end
    if now - self._lastGrowth >= 1 then
        local previous = self._lastPosition or position
        local distance = Vector3.new(position.X - previous.X, 0, position.Z - previous.Z).Magnitude
        local elapsed = now - self._lastGrowth
        -- 不按客户端声明的行走状态结算，排除原地和超出正常步速的瞬移。
        local moving = distance > 0.1 and distance <= humanoid.WalkSpeed * elapsed * 1.5
            and humanoid.FloorMaterial ~= Enum.Material.Air
        local gain = (moving and 2 or 0) + (self._hit and 2 or 0)
        if gain > 0 then
            self:AddNumber(Fields.RockTrainingValue, gain)
            self:RefreshProgress()
        end
        self._lastPosition = position
        self._lastGrowth = now
        self._hit = false
    end
end

--- 离服即停止结算，避免已释放玩家继续读写存档。
function Component:OnPlayerLogout()
    FX.Task:Cancel(self._timer)
    self._timer = nil
end

--- 析构也释放任务，覆盖初始化中断的生命周期。
function Component:Dtor()
    self:OnPlayerLogout()
    if self._ownsStats then
        self._stats:Destroy()
    else
        if self._levelStat then
            self._levelStat:Destroy()
        end
        if self._strengthStat then
            self._strengthStat:Destroy()
        end
    end
    Component.Super.Dtor(self)
end

return Component
