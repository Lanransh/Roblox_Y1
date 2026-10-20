---
name: roblox-luau-standards
description: Roblox_Y1 的 Luau 编码与普通审查规范。编写、重构、修复代码或审查可读性时使用。
---

# Roblox Luau 规范

编码或普通审查读取 [项目编码规则与 FXLoader](reference-rules.md)。配置读取、文案和验证要求遵循 AGENTS.md。纯服务端安全审查使用 `server-code-critical-review`，不额外触发风格审查。

涉及游戏动态文本或语言刷新时，使用 [Roblox 项目本地化 skill](../roblox-localization/SKILL.md)。不改 Generated；仅为其尚未正确处理的动态文本在接入脚本补翻译，已处理的不重复补。无 Generated 对应的业务动态消息由所属脚本处理；各文件独立定义且 Key 唯一，配置引用与静态节点不补翻译定义。
