local FX = _G.FX
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local RockLevel = require(ReplicatedStorage.Scripts.Game.Shared.RockLevel)
local Fields = _G.PlayerDataConfig
local Component = FX.Class("CRockLevelCompClass", "FCPlayerCompClass")
local RockNames = {"Rock_01", "Rock_02", "Rock_03", "Rock_04", "Rock_Small_01"}
local RockColors = {
    Color3.fromRGB(217, 220, 224), Color3.fromRGB(228, 225, 215),
    Color3.fromRGB(224, 228, 226), Color3.fromRGB(235, 233, 223),
    Color3.fromRGB(219, 224, 218),
}

--- 只拥有本客户端生成的石头；不会修改公共 SyntyRocks 模板。
--- @param owner FCPlayerObjectClass 客户端玩家对象。
function Component:Ctor(owner)
    Component.Super.Ctor(self, owner)
    self._chunks = {}
    self._pool = {}
    self._templates = {}
    self._health = {}
    self._fragments = {}
end

--- 返回项目关卡组件协作名称。
--- @return string 组件名称。
function Component:GetCompName()
    return "CRockLevelComp"
end

--- 同步握手后加载无脚本受击资源、构造 6×6 块索引，并订阅服务端权威血量。
function Component:OnReady()
    local assets = ReplicatedStorage:WaitForChild("Assets")
    local effects = assets:WaitForChild("Effects"):WaitForChild("ROCK")
    self._fragmentTemplate = effects:WaitForChild("Fragment"):Clone()
    self._smokeTemplate = effects:WaitForChild("Smoke")
    self._breakSound = assets:WaitForChild("Sounds"):WaitForChild("RockBreak")
    -- 本地模型同步后补齐网格数据，保证碎石缩放使用原网格尺寸。
    if self._fragmentTemplate.MeshSize.Magnitude == 0 then
        local size = self._fragmentTemplate.Size
        local mesh = game:GetService("AssetService"):CreateMeshPartAsync(self._fragmentTemplate.MeshContent)
        self._fragmentTemplate:ApplyMesh(mesh)
        self._fragmentTemplate.Size = size
        mesh:Destroy()
    end
    local sources = assets:WaitForChild("Models"):WaitForChild("SyntyRocks")
    for index, name in ipairs(RockNames) do
        local source = sources:WaitForChild(name)
        local part = source:Clone()
        -- JSON 同步可能丢失原始网格尺寸；恢复后保留已验看的尺寸和贴图。
        if part.MeshSize.Magnitude == 0 then
            local size = part.Size
            local mesh = game:GetService("AssetService"):CreateMeshPartAsync(part.MeshContent)
            part:ApplyMesh(mesh)
            part.Size = size
            part.TextureID = source.TextureID
            mesh:Destroy()
        end
        local template = Instance.new("Model")
        template.Name = name
        part.Name = "Root"
        part.CFrame = CFrame.new()
        part.Parent = template
        template.PrimaryPart = part
        template:SetAttribute("Variant", index)
        template:SetAttribute("FullHeight", part.Size.Y)
        self._templates[index] = template
        self._pool[index] = {}
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

--- 为实际扣血播放特效；观察到击破后请求服务器弹出该石头的道具。
function Component:RefreshHealth()
    local health = self:GetTable(Fields.RockHealth)
    for key, value in pairs(health) do
        if value == 0 and self._health[key] ~= 0 then
            FX.Network:SendMsgToServer("C2S_RequestRockDrop", key)
        end
    end
    for key, oldValue in pairs(self._health) do
        if health[key] == nil or health[key] > oldValue then
            self:ResetVisuals()
            break
        end
    end
    for index = 1, #self._chunks do
        local chunk = self._chunks[index]
        if chunk.Rocks then
            for key, rock in pairs(chunk.Rocks) do
                local oldValue = self._health[key] or RockLevel.HP[chunk.Area.Index]
                local value = health[key] or RockLevel.HP[chunk.Area.Index]
                if value < oldValue then
                    self:PlayHitEffect(rock, value <= 0)
                end
            end
        end
    end
    self._health = health
end

--- 每次命中播放一次声音及 ROCK 烟尘与碎石，碎石从当前模型顶部飘出并沿用关卡色。
--- @param rock Model 当前受击且仍在场景中的石头。
--- @param broken boolean 本次扣血是否击破石头。
function Component:PlayHitEffect(rock, broken)
    local character = self:GetPlayerCharacter()
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then
        return
    end
    local center = rock:GetPivot().Position
    local direction = center - root.Position
    if direction.Magnitude < 0.01 then
        return
    end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Include
    params.FilterDescendantsInstances = {rock}
    local hit = workspace:Raycast(root.Position, direction.Unit * (direction.Magnitude + RockLevel.CellSize), params)
    local normal = hit and hit.Normal or -direction.Unit
    local position = hit and hit.Position or center
    local effect = Instance.new("Part")
    effect.Name = "RockHitEffect"
    effect.Size = Vector3.new(0.1, 0.1, 0.1)
    effect.Transparency = 1
    effect.Anchored = true
    effect.CanCollide = false
    effect.CanTouch = false
    effect.CanQuery = false
    effect.CFrame = CFrame.lookAt(position + normal * 0.1, position + normal)
    local dust = self._smokeTemplate:Clone()
    dust.Parent = effect
    local sound = self._breakSound:Clone()
    sound.Parent = effect
    effect.Parent = self._folder
    dust:Emit(broken and 10 or 5)
    sound:Play()
    local away = Vector3.new(direction.X, 0, direction.Z)
    if away.Magnitude < 0.01 then
        away = Vector3.new(0, 0, 1)
    end
    away = away.Unit
    local fragmentPosition = position + away * 0.5
    fragmentPosition = Vector3.new(fragmentPosition.X,
        math.max(fragmentPosition.Y, center.Y + rock.Root.Size.Y / 2 + 0.4), fragmentPosition.Z)
    self:SpawnFragments(CFrame.lookAt(fragmentPosition, fragmentPosition + away),
        rock:GetAttribute("GroundColor"), broken)
    Debris:AddItem(effect, math.max(3, dust.Lifetime.Max + 0.1, sound.TimeLength + 0.1))
end

--- 小碎石按环形方向向上喷起并四散；灰色材质仅叠加 20% 关卡色，不参与碰撞。
--- @param origin CFrame 石头上方的生成位置及远离玩家的水平朝向。
--- @param color Color3 对应地板的原始颜色，以 20% 强度叠加到碎石底色。
--- @param broken boolean 击破时增加碎石数量和尺寸。
function Component:SpawnFragments(origin, color, broken)
    local source = self._fragmentTemplate
    local tint = Color3.new(1, 1, 1):Lerp(color, 0.2)
    local fragmentColor = Color3.new(source.Color.R * tint.R, source.Color.G * tint.G, source.Color.B * tint.B)
    local count = broken and 9 or 5
    local phase = math.random() * math.pi * 2
    for index = 1, count do
        local fragment = source:Clone()
        fragment.Name = "RockFragment"
        fragment.Anchored = true
        fragment.CanCollide = false
        fragment.CanTouch = false
        fragment.CanQuery = false
        fragment.CastShadow = false
        fragment.Color = fragmentColor
        local size = (0.5 + math.random() * 0.4) * (broken and 1.3 or 1)
        fragment.Size = source.Size * (size / math.max(source.Size.X, source.Size.Y, source.Size.Z))
        local rotation = CFrame.Angles(math.random() * math.pi, math.random() * math.pi, math.random() * math.pi)
        fragment.CFrame = CFrame.new(origin.Position) * rotation
        fragment.Parent = self._folder
        local angle = phase + (index - 1 + math.random() * 0.4) / count * math.pi * 2
        local spread = 4 + math.random() * 3
        table.insert(self._fragments, {
            Part = fragment, Size = fragment.Size, Position = origin.Position, Rotation = rotation,
            Started = os.clock(), Lifetime = 1 + math.random() * 0.2,
            Velocity = Vector3.new(math.cos(angle) * spread, 10 + math.random() * 3, math.sin(angle) * spread),
            Spin = Vector3.new(math.random() * 10 - 5, math.random() * 10 - 5, math.random() * 10 - 5),
        })
    end
end

--- 碎石先完整展示弹起与翻滚，只在最后三成寿命缩小淡出；角色缺失时也继续清理。
function Component:UpdateFragments()
    local now = os.clock()
    for index = #self._fragments, 1, -1 do
        local fragment = self._fragments[index]
        local elapsed = now - fragment.Started
        if elapsed >= fragment.Lifetime then
            fragment.Part:Destroy()
            table.remove(self._fragments, index)
        else
            local fade = math.clamp((elapsed / fragment.Lifetime - 0.7) / 0.3, 0, 1)
            local position = fragment.Position + fragment.Velocity * elapsed + Vector3.new(0, -14 * elapsed * elapsed, 0)
            local spin = fragment.Spin * elapsed
            fragment.Part.CFrame = CFrame.new(position) * fragment.Rotation * CFrame.Angles(spin.X, spin.Y, spin.Z)
            fragment.Part.Size = fragment.Size * math.max(0.05, 1 - fade)
            fragment.Part.Transparency = fade
        end
    end
end

--- 按格子固定随机模型、朝向和灰色，分模型复用，避免重新载入时外观跳变。
--- @param area table 所属关卡。
--- @param column number 从零开始的列号。
--- @param row number 从零开始的行号。
--- @return Model 本客户端拥有的石头。
function Component:CreateRock(area, column, row)
    local x = area.MinX + (column + 0.5) * RockLevel.CellSize
    local z = area.MinZ + (row + 0.5) * RockLevel.CellSize
    local seed = math.abs(math.floor(x * 73856093 + z * 19349663)) % 2147483647
    local random = Random.new(seed)
    local variant = random:NextInteger(1, #RockNames)
    local rotation = CFrame.Angles(0, random:NextInteger(0, 3) * math.pi / 2, 0)
    local rock = table.remove(self._pool[variant])
    if not rock then
        rock = self._templates[variant]:Clone()
    end
    rock.Name = "Rock_" .. area.Index .. "_" .. (row * area.Columns + column + 1)
    rock:ScaleTo(1)
    rock:SetAttribute("BaseColor", RockColors[Random.new(seed + 17):NextInteger(1, #RockColors)])
    rock:SetAttribute("HealthRatio", nil)
    rock:SetAttribute("GroundColor", nil)
    rock:PivotTo(CFrame.new(x, area.FloorY + rock:GetAttribute("FullHeight") / 2, z) * rotation)
    self:SetRockState(rock, true)
    rock.Parent = self._folder
    return rock
end

--- 保留模型朝向并按血量缩放贴地；关卡色仅以 20% 强度染色，保持灰色岩石主体。
--- @param rock Model 当前客户端石头。
--- @param area table 所属关卡及常驻颜色标记。
--- @param health number 大于零的当前血量。
function Component:UpdateRockAppearance(rock, area, health)
    local ratio = math.clamp(health / RockLevel.HP[area.Index], 0.3, 1)
    if rock:GetAttribute("HealthRatio") ~= ratio then
        local pivot = rock:GetPivot()
        rock:ScaleTo(ratio)
        rock:PivotTo(CFrame.new(pivot.Position.X,
            area.FloorY + rock:GetAttribute("FullHeight") * ratio / 2, pivot.Position.Z) * pivot.Rotation)
        rock:SetAttribute("HealthRatio", ratio)
    end
    local color = area.Node.Color
    if rock:GetAttribute("GroundColor") ~= color then
        local baseColor = rock:GetAttribute("BaseColor")
        local tint = Color3.new(1, 1, 1):Lerp(color, 0.2)
        rock.Root.SurfaceAppearance.Color = Color3.new(baseColor.R * tint.R, baseColor.G * tint.G, baseColor.B * tint.B)
        rock:SetAttribute("GroundColor", color)
    end
end

--- 隐藏时解除碰撞并移出场景，按模型种类回收，避免复用时改变选定的轮廓。
--- @param rock Model 本组件创建的石头。
function Component:RecycleRock(rock)
    self:SetRockState(rock, false)
    rock.Parent = nil
    table.insert(self._pool[rock:GetAttribute("Variant")], rock)
end

--- 每块石头只有一个根网格，碰撞仍由当前血量能否一击击破决定。
--- @param rock Model 本组件创建的石头。
--- @param canCollide boolean 是否阻挡玩家。
function Component:SetRockState(rock, canCollide)
    rock.Root.CanCollide = canCollide
end

--- 更新短时碎石表现，每帧最多载入最近的一块；64 studs 载入、72 studs 移除。
function Component:UpdateVisuals()
    self:UpdateFragments()
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
                    self:UpdateRockAppearance(rock, chunk.Area, health)
                    self:SetRockState(rock, health > damage)
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

--- 释放场景、五种本地模板及各自的复用池，基类负责断开全部监听。
function Component:Dtor()
    if self._fragmentTemplate then
        self._fragmentTemplate:Destroy()
    end
    for index, template in ipairs(self._templates) do
        template:Destroy()
    end
    if self._folder then
        self._folder:Destroy()
    end
    self._fragments = {}
    for index, pool in ipairs(self._pool) do
        for rockIndex, rock in ipairs(pool) do
            rock:Destroy()
        end
    end
    Component.Super.Dtor(self)
end

return Component
