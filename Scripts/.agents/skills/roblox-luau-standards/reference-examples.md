# 注释与边界示例

标签格式延续原工作区习惯，源码使用 Luau；只给实际参数和返回值写标签。

```lua
local FX = _G.FX
local SExampleCompClass = FX.Class("SExampleCompClass", "FSPlayerCompClass")

--- 返回玩家组件的协作名，供 RequireComponent 使用。
--- @return string 组件名。
function SExampleCompClass:GetCompName()
    return "SExampleComp"
end

return SExampleCompClass
```

可信内部参数按约定使用。协议入口需要先验证类型、有限值、整数范围、所有权和业务状态；不能用 `tonumber` 或默认值把非法请求变成有效操作。
