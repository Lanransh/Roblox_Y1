local FX = _G.FX
local FXLoader = FX.Loader
local Fields = _G.PlayerDataConfig
local Aura = FXLoader:RequireShared("Scripts/Game/Shared/Aura")
local Component = FX.Class("SAuraCompClass", "FSPlayerCompClass")

-- 资源按 R6 身体部位分组；R15 使用对应的躯干或上肢、上腿承载粒子。
local R15_PARTS = {
    Torso = "UpperTorso",
    ["Left Arm"] = "LeftUpperArm",
    ["Right Arm"] = "RightUpperArm",
    ["Left Leg"] = "LeftUpperLeg",
    ["Right Leg"] = "RightUpperLeg",
}

--- 光环的购买、装备和复制给其他玩家的实例均由服务端负责。
--- @return string 玩家内协作名称。
function Component:GetCompName()
    return "SAuraComp"
end

--- 先缓存可信模板，后续扣款和装备提交过程不等待资源复制。
function Component:OnPlayerLogin()
    self._effects = {}
    self._templates = {}
    for index, config in ipairs(_G.GameConfig.AuraConfig) do
        self._templates[config.AuraId] = FXLoader:Shared("Assets/Effects/Aura/" .. Aura.GetModelName(config))
    end
    local player = self:GetPlayerNode()
    self:TrackConnection(player.CharacterAdded:Connect(function(character)
        self:BindCharacter(character)
    end))
    self:TrackConnection(player.CharacterRemoving:Connect(function(character)
        if character == self._character then
            self:BindCharacter(nil)
        end
    end))
    self:BindCharacter(player.Character)
    self:WatchDataChanged(Fields.AuraData, self.RefreshEffects, self)
    self._ready = true
end

--- 重生期间角色部位逐步到达，监听新增部位而不是持有旧角色引用。
--- @param character Model? 当前角色；nil 表示角色移除。
function Component:BindCharacter(character)
    if self._characterConnection then
        self._characterConnection:Disconnect()
        self._characterConnection = nil
    end
    self._character = character
    if character then
        self._characterConnection = character.ChildAdded:Connect(function(child)
            if child:IsA("BasePart") then
                self:RefreshEffects()
            end
        end)
    end
    self:RefreshEffects()
end

--- 仅销毁本组件克隆的粒子，不按名称删除角色其他特效。
function Component:ClearEffects()
    for index, effect in ipairs(self._effects) do
        effect:Destroy()
    end
    table.clear(self._effects)
end

--- ParticleEmitter 直接挂在身体 Part 下，不能放进 Folder 导致粒子失去发射位置。
function Component:RefreshEffects()
    self:ClearEffects()
    local player = self:GetPlayerNode()
    local character = self._character
    if not character or not player or player.Character ~= character then
        return
    end
    local data = self:GetTable(Fields.AuraData)
    local config = Aura.GetConfig(data.equippedId)
    if not config or data.owned[tostring(config.AuraId)] ~= true then
        return
    end
    for index, group in ipairs(self._templates[config.AuraId]:GetChildren()) do
        local part = character:FindFirstChild(group.Name)
            or character:FindFirstChild(R15_PARTS[group.Name] or group.Name)
        if part and part:IsA("BasePart") then
            for childIndex, template in ipairs(group:GetChildren()) do
                if template:IsA("ParticleEmitter") then
                    local effect = template:Clone()
                    effect.Name = "EquippedAura"
                    effect.Enabled = true
                    effect.Parent = part
                    table.insert(self._effects, effect)
                end
            end
        end
    end
end

--- 权威结算不让出执行；重复购买不扣款，未拥有的光环不能装备。
--- @param action string 仅允许 Buy 或 Equip，Equip 再次点击当前光环时卸下。
--- @param auraId number 客户端只能提供稳定 ID。
--- @return table 操作结果、失败文案 Key 或最新权威状态与余额。
function Component:RequestAura(action, auraId)
    local config = Aura.GetConfig(auraId)
    if not self._ready or not config or (action ~= "Buy" and action ~= "Equip") then
        return {success = false, key = "Common.Unknown"}
    end
    local data = self:GetTable(Fields.AuraData)
    local id = tostring(config.AuraId)
    if action == "Buy" then
        if data.owned[id] == true then
            return {success = false, key = "Aura.AlreadyOwned"}
        end
        if self:GetNumber(Fields.Coins) < config.Price
            or (config.Price > 0 and not self:SubNumber(Fields.Coins, config.Price)) then
            return {success = false, key = "Aura.NotEnoughCoins"}
        end
        data.owned[id] = true
    else
        if data.owned[id] ~= true then
            return {success = false, key = "Aura.NotOwned"}
        end
        data.equippedId = data.equippedId == auraId and 0 or auraId
    end
    self:SetTable(Fields.AuraData, data)
    return {success = true, data = data, coins = self:GetNumber(Fields.Coins)}
end

--- 离服释放角色监听与复制实例，不改变持久装备状态。
function Component:OnPlayerLogout()
    self._ready = false
    self:BindCharacter(nil)
end

--- 父类负责其余玩家和数据连接；重复离服清理保持幂等。
function Component:Dtor()
    self:OnPlayerLogout()
    Component.Super.Dtor(self)
end

return Component
