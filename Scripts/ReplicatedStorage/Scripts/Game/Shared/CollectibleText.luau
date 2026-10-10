local Text = {}

--- 使用展示模型的稳定编号获取显示文案，兼容旧模型名和存档模板名。
--- @param templateName string Studio 模型名或 GameConfig 展示模型路径。
--- @return string 英文源表和云端翻译共用的文案 Key。
function Text.GetNameKey(templateName)
    local number = string.match(templateName, "Y1_(%d+)") or string.match(templateName, "^(%d+)")
    return number and "Collectible." .. number or "Common.Unknown"
end

return Text
