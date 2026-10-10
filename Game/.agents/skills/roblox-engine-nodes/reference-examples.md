# 原生节点片段

template 为已经确认可克隆的 Model，targetCFrame 是服务端计算的 CFrame：

```lua
local model = template:Clone()
model.Name = "SpawnedModel"
model:SetAttribute("OwnerId", playerId)
model:PivotTo(targetCFrame)
model.Parent = workspace
```

组件中的接触检测只识别玩家，不把接触本身当领奖授权：

```lua
local Players = game:GetService("Players")
self:TrackConnection(triggerPart.Touched:Connect(function(hit)
    local character = hit:FindFirstAncestorOfClass("Model")
    local player = character and Players:GetPlayerFromCharacter(character)
    if not player then
        return
    end
    -- 按本次需求检查归属、位置、状态和冷却，再执行权威业务。
end))
```

triggerPart 为已确认的 BasePart；复杂角色层级按当前模型结构定位。
