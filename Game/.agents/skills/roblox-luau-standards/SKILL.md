---
name: roblox-luau-standards
description: Roblox_Y1 的 Luau 编码与普通审查规范，包含函数注释、命名、配置读取和输入边界。编写、重构、修复 Lua/Luau 或审查可读性时使用；仅做安全审查时由 server-code-critical-review 控制结论范围。
---

# Roblox Luau 规范

编码或普通审查先读 [reference-rules.md](reference-rules.md)，完成后用 [reference-checklist.md](reference-checklist.md) 自检。
需要具体注释或改写范例时再读 [reference-examples.md](reference-examples.md)。

- 使用 Luau，匹配目标文件现有风格；不为迁移提示词而改动游戏代码。
- 新增或修改函数必须补充与实际签名一致的中文标签注释；有形参逐一写 `@param`，有返回值写 `@return`，不虚构标签。
- 配置先用 `rg` 定位，再读相关片段；不全量读取 `ReplicatedStorage/Shared/Config/`。
- 可信内部调用不加重复容错；客户端请求、平台回调、旧存档和动态实例需在实际边界验证。
- 固定配置存在不意味着客户端实例已复制到达。必需的复制节点按生命周期使用 `WaitForChild`；可选或动态节点使用 `FindFirstChild` 并处理缺失。
- 参数类型保持明确，不用隐式 string/number 混用掩盖约定错误。
- 按 `Game/AGENTS.md` 的验证授权执行；编译成功不等于运行验证通过。
