# 模块落位与启动

目录职责见工作区 AGENTS.md。配置接入由 `ReplicatedStorage/Scripts/SetupProvider.luau` 提供；公共配置放 `ReplicatedStorage/Scripts/Game/Configs/` 或 `ReplicatedStorage/Scripts/Game/Shared/`，私有配置放 `ServerScriptService/Server/Config`。

1. Main 加载 GameInit，SetupProvider 在 FrameworkInit 前加载；FrameworkInit 自动加载当前端 FServer/FClient。
2. 框架基类注册后 require 业务类，再实例化或 AddComponent；业务类不会被自动遍历加载。
3. FServer 初始化存档、排行榜、支付和好友服务。服务端 Main 先创建业务服务，再创建玩家管理器；管理器登记到 FS.PlayerManager 并开放 Ready。
4. 客户端创建玩家对象后调用 FC.WaitServerReady()，等待服务注册和初始数据同步。服务端握手会核对存档加载状态。

FClient 自动启动 FC.NativeBackpack，具体配置行为见 [背包参考](../game-examples/references/reference-inventory-component.md)。
