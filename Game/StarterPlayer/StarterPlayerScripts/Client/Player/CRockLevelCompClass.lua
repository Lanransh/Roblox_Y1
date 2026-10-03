local FX = _G.FX
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local RockLevel = require(ReplicatedStorage.Scripts.Game.Shared.RockLevel)
local Fields = _G.PlayerDataConfig
local Component = FX.Class("CRockLevelCompClass", "FCPlayerCompClass")

--- 只拥有本客户端生成的石头；不会修改公共 Small Rock 模板。
--- @param owner FCPlayerObjectClass 客户端玩家对象。
function Component:Ctor(owner)
    Component.Super.Ctor(self, owner)
    self._chunks = {}
    self._pool = {}
    self._health = {}
    self._flashUntil = {}
end

--- 返回项目关卡组件协作名称。
--- @return string 组件名称。
function Component:GetCompName()
    return "CRockLevelComp"
end

--- 在同步握手完成后构造 6×6 块索引，并订阅服务端权威血量。
function Component:OnReady()
    self._template = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Models"):WaitForChild("Small Rock"):Clone()
    -- JSON 同步可能丢失网格的原始尺寸；补齐网格数据后，Size 才能正确控制显示与碰撞。
    if self._template.MeshSize.Magnitude == 0 then
        local size = self._template.Size
        local mesh = game:GetService("AssetService"):CreateMeshPartAsync(self._template.MeshContent)
        self._template:ApplyMesh(mesh)
        self._template.Size = size
        mesh:Destroy()
    end
    self._areas = RockLevel.GetAreas()
    self._folder = Instance.new("Folder")
    self._folder.Name = "RockLevelVisuals"
    self._folder.Parent = workspace
    for index = 1, #self._areas do
        local area = self._areas[index]
        for row = 0, area.Rows - 1, 6 do
            for column = 0, area.Columns - 1, 6 do
                table.insert(self._chunks, {
                    Area = area, Row = row, Column = column, Rocks = nil,
                    Center = Vector3.new(area.MinX + (column + 3) * RockLevel.CellSize,
                        area.FloorY, area.MinZ + (row + 3) * RockLevel.CellSize),
                })
            end
        end
    end
    self:WatchDataChanged(Fields.RockHealth, self.RefreshHealth, self)
    self:TrackConnection(RunService.Heartbeat:Connect(function()
        self:UpdateVisuals()
    end))
end

--- 对比血量变化安排短暂红闪，死亡节点立即回池。
function Component:RefreshHealth()
    local health = self:GetTable(Fields.RockHealth)
    for key, oldValue in pairs(self._health) do
        if health[key] == nil or health[key] > oldValue then
            self:ResetVisuals()
            self._flashUntil = {}
            break
        end
    end
    for key, value in pairs(health) do
        if value > 0 and value ~= self._health[key] then
            self._flashUntil[key] = os.clock() + 0.12
        end
    end
    self._health = health
end

--- 复用网格，按最大边缩放到格内，底面贴齐当前地面。
--- @param area table 所属关卡。
--- @param column number 从零开始的列号。
--- @param row number 从零开始的行号。
--- @return MeshPart 本客户端拥有的石头。
function Component:CreateRock(area, column, row)
    local rock = table.remove(self._pool)
    if not rock then
        rock = self._template:Clone()
        rock.Size = self._template.Size * (RockLevel.CellSize * 0.95
            / math.max(self._template.Size.X, self._template.Size.Y, self._template.Size.Z))
        rock.Anchored = true
        rock.CanTouch = false
        rock.CastShadow = false
    end
    rock.Name = "Rock_" .. area.Index .. "_" .. (row * area.Columns + column + 1)
    rock.CFrame = CFrame.new(area.MinX + (column + 0.5) * RockLevel.CellSize,
        area.FloorY + rock.Size.Y / 2, area.MinZ + (row + 0.5) * RockLevel.CellSize)
    rock.Color = self._template.Color
    rock.Parent = self._folder
    return rock
end

--- 隐藏时解除碰撞并移出场景，保留网格供附近关卡复用。
--- @param rock MeshPart 本组件创建的石头。
function Component:RecycleRock(rock)
    rock.CanCollide = false
    rock.Parent = nil
    table.insert(self._pool, rock)
end

--- 每帧最多载入最近的一块；64 studs 载入、72 studs 移除，避免边界反复重建。
function Component:UpdateVisuals()
    local character = self:GetPlayerCharacter()
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then
        return
    end
    local position = root.Position
    local candidate, nearest = nil, math.huge
    for index = 1, #self._chunks do
        local chunk = self._chunks[index]
        local distance = Vector3.new(position.X - chunk.Center.X, 0, position.Z - chunk.Center.Z).Magnitude
        if chunk.Rocks and distance > RockLevel.HideDistance then
            for key, rock in pairs(chunk.Rocks) do
                self:RecycleRock(rock)
            end
            chunk.Rocks = nil
        elseif not chunk.Rocks and distance <= RockLevel.LoadDistance and distance < nearest then
            candidate, nearest = chunk, distance
        end
    end
    if candidate then
        candidate.Rocks = {}
        for row = candidate.Row, math.min(candidate.Row + 5, candidate.Area.Rows - 1) do
            for column = candidate.Column, math.min(candidate.Column + 5, candidate.Area.Columns - 1) do
                local key = candidate.Area.Index .. ":" .. (row * candidate.Area.Columns + column + 1)
                if self._health[key] ~= 0 then
                    local rock = self:CreateRock(candidate.Area, column, row)
                    candidate.Rocks[key] = rock
                end
            end
        end
    end
    local level = self:GetNumber(Fields.RockTrainingLevel)
    for index = 1, #self._chunks do
        local chunk = self._chunks[index]
        if chunk.Rocks then
            local damage = RockLevel.GetDamage(level, chunk.Area.Index)
            for key, rock in pairs(chunk.Rocks) do
                local health = self._health[key] or RockLevel.HP[chunk.Area.Index]
                if health <= 0 then
                    self:RecycleRock(rock)
                    chunk.Rocks[key] = nil
                else
                    rock.CanCollide = health > damage
                    rock.Color = (self._flashUntil[key] or 0) > os.clock()
                        and Color3.fromRGB(255, 0, 0) or self._template.Color
                end
            end
        end
    end
end

--- 回到安全区后清空已显示的块索引，下一帧按新血量重建。
function Component:ResetVisuals()
    for index = 1, #self._chunks do
        local chunk = self._chunks[index]
        if chunk.Rocks then
            for key, rock in pairs(chunk.Rocks) do
                self:RecycleRock(rock)
            end
            chunk.Rocks = nil
        end
    end
end

--- 释放已显示和池内的网格，基类负责断开全部监听。
function Component:Dtor()
    if self._template then
        self._template:Destroy()
    end
    if self._folder then
        self._folder:Destroy()
    end
    for index = 1, #self._pool do
        self._pool[index]:Destroy()
    end
    Component.Super.Dtor(self)
end

return Component
