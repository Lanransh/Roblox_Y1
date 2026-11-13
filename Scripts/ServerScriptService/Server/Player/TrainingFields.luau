local FX = _G.FX
local FXLoader = FX.Loader
local InstancePath = FXLoader:RequireShared("Scripts/Game/Shared/InstancePath")
local TrainingFields = {}
local fields

--- 按完整配置路径缓存三个世界的训练台引用，不执行路径文本。
--- @return table 配置及对应训练台。
function TrainingFields.GetFields()
    if fields then
        return fields
    end
    fields = {}
    for index, config in ipairs(_G.GameConfig.TrainingFieldData) do
        local model = InstancePath.Wait(config.Node)
        local platform = model:FindFirstChild("彩色训练台", true)
        assert(platform and platform:IsA("BasePart"), "Missing training platform: " .. model:GetFullName())
        fields[index] = {Config = config, Platform = platform}
    end
    return fields
end

--- 按训练台局部坐标检测角色根节点；四周留出余量，高度覆盖石顶站立与跳跃，仍限制场外收益。
--- @param position Vector3 服务端观察到的角色位置。
--- @return table? 当前所在场地的配置，场外为 nil。
function TrainingFields.GetAtPosition(position)
    for index, field in ipairs(TrainingFields.GetFields()) do
        local platform = field.Platform
        local localPosition = platform.CFrame:PointToObjectSpace(position)
        local top = platform.Size.Y / 2
        if math.abs(localPosition.X) <= platform.Size.X / 2 + 2
            and math.abs(localPosition.Z) <= platform.Size.Z / 2 + 2
            and localPosition.Y >= top - 1 and localPosition.Y <= top + 24 then
            return field.Config
        end
    end
    return nil
end

return TrainingFields
