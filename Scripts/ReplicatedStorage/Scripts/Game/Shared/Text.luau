local RunService = game:GetService("RunService")
local Text = {}

--- 校验按 Key 查询的脚本文案或网络定义；不把字符串隐式当作 Key。
--- @param definition table 含非空字符串 Key、Source 的文案定义。
--- @return table 校验后的定义。
function Text.ValidateDefinition(definition)
    assert(type(definition) == "table", "Text: expected a Key/Source definition")
    assert(type(definition.Key) == "string" and string.find(definition.Key, "%S"),
        "Text: definition.Key must be a non-empty string")
    assert(type(definition.Source) == "string" and string.find(definition.Source, "%S"),
        "Text: definition.Source must be a non-empty string")
    return definition
end

--- 仅客户端可翻译；服务端只传定义和参数，不接受旧原文或字符串 Key。
--- @param definition table 静态脚本文案或显式配置文案定义。
--- @param arguments table? 原生模板参数；itemDefinition 或配置原文 itemSource 在客户端求值为 item。
--- @return string 当前语言文案，缺译时使用定义中的英文兜底。
function Text.Tr(definition, arguments)
    assert(RunService:IsClient(), "Text.Tr is client-only; send the definition and arguments from the server")
    Text.ValidateDefinition(definition)
    local FC = _G.FC
    return FC.Localization:Tr(definition, arguments)
end

--- 仅客户端按原文查询已有译文；不需要 Key，不登记原文或格式化模板参数。
--- @param source string 待查找的完整原文。
--- @return string 当前语言译文，未加载或查询失败时返回原文。
function Text.TrSource(source)
    assert(RunService:IsClient(), "Text.TrSource is client-only")
    local FC = _G.FC
    return FC.Localization:TrSource(source)
end

return Text
