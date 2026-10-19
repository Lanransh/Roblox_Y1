local RunService = game:GetService("RunService")
local Text = {}

--- 在原文定义处标记待收集文本；两端均只返回原文，不翻译或格式化。
--- @param source string 英文原文或原生参数模板。
--- @return string 未修改的英文原文。
function Text.Mark(source)
    return source
end

--- 客户端显示时复用入口创建的翻译对象；服务端必须发送原文和参数。
--- @param source string 英文原文、原生参数模板或兼容的旧 Key。
--- @param arguments table? 原生模板参数；旧 Key 保留 itemKey 扩展。
--- @return string 当前玩家语言的文案，缺少译文时使用英文。
function Text.Tr(source, arguments)
    assert(RunService:IsClient(), "Text.Tr is client-only; use Text.Mark on the server")
    local FC = _G.FC
    return FC.Localization:Tr(source, arguments)
end

return Text
