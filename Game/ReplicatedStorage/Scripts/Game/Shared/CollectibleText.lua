local Text = {}

Text.RarityKeys = {
    ["便宜货"] = "Rarity.Junk",
    ["普通物品"] = "Rarity.Common",
    ["水晶宝石"] = "Rarity.Crystal",
    ["枪械"] = "Rarity.Weapon",
    ["稀有珍品"] = "Rarity.Rare",
}

--- 使用模板的稳定编号获取显示文案，保留模型路径和旧存档标识。
--- @param templateName string Studio 中已有的收藏品模板名。
--- @return string 英文源表和云端翻译共用的文案 Key。
function Text.GetNameKey(templateName)
    return "Collectible." .. string.match(templateName, "^%d+")
end

return Text
