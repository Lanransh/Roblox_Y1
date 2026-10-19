-- 项目协议在框架初始化之前加载；每个方向填写有序的协议名列表。
-- 框架已有的 Ready、玩家数据和服务器数据同步协议继续由 FrameworkInit 声明。
return {
    ClientMsgID = {
        -- dropId: string，RPC 返回 boolean；校验今日个人档位、落地与距离，按 GiftData 发钻石并去重。
        "C2S_OpenGiftDrop",
        -- goodsId: number，服务端校验钻石余额与下一档；返回 success、key、data。
        "C2S_BuyCurrencyShopGoods",
        -- kind: "online"|"signin"|"diamonds"，rewardId: string 稳定配置 ID；身份来自引擎。
        -- RPC 返回 {success: boolean, key: string, state: table?}；服务端决定日期、资格及奖励。
        "C2S_ClaimWelfareReward",
        -- action: "SetLevel"|"SetRebirth"|"SetMoney"|"SetDiamonds"|"ResetData"|"SaveNow"|"AddItem"。
        -- value: number?，非负安全整数；等级为 1 到当前阶段上限，重生为 0 到配置上限。
        -- AddItem 使用 value 为道具配置 ID、count 为添加数量，两者均为正安全整数；其他动作不使用 count。
        -- 仅引擎认证 UserId 对应开发者可操作本人；RPC 返回 {success: boolean, key: string, arguments: table?}。
        "C2S_GMCommand",
        -- 无参数，服务端校验请求者当前等级与重生次数；RPC 返回 {success: boolean}。
        "C2S_Rebirth",
        -- entryIds: string[]，正式库存的稳定实例 ID；multiplier: 1|2，暂时允许免费双倍。
        -- RPC 返回 {success: boolean, key: string, amount: number?, count: number?, entries: table?}。
        -- 价格、幸运与重生倍率均由服务端决定，不接受客户端金额。
        "C2S_SellLoot",
        -- action: "Buy"|"Equip"、auraId: number；身份来自引擎认证 UserId。
        -- RPC 返回 {success: boolean, key: string?, data: table?, coins: number?}。
        -- 服务端按 AuraConfig 校验、扣款和切换装备，忽略客户端价格与模型路径。
        "C2S_AuraAction",
        -- action: "Buy"|"Equip"、weaponId: number ToolId；身份来自引擎认证 UserId。
        -- RPC 返回 {success: boolean, key: string?, data: table?, coins: number?}。
        -- 服务端校验解锁与余额，购买更高训练倍率的武器时自动装备，当前武器不能卸下。
        "C2S_WeaponAction",
        -- key: string、round: number，击破格号与轮次；服务器按有效命中记录揭露预生成结果一次。
        -- 单向请求，不接受客户端提供道具、价格、位置或玩家身份。
        "C2S_RequestRockDrop",
        -- dropId: string，仅提交服务端签发给本人的掉落 ID；身份来自引擎认证。
        -- RPC 返回 boolean；服务端校验归属、到期、距离和容量后发奖并通知客户端移除本地表现。
        "C2S_PickupRockDrop",
        -- key: string、round: number，本地预测命中；服务器校验近身目标、装备与攻击频率，不接受伤害值。
        "C2S_RockHit",
        -- 无参数，客户端就绪或角色变化后请求当前轮次和个人已击破格号快照。
        "C2S_RequestRockRound",
        -- 无参数，单向请求；服务端仅允许存活且位于关卡内的本人返回基地出生点。
        "C2S_ReturnHome",
        -- index: number，世界传送列表序号，从 1 开始；接受过哪些世界的重生门槛与落点由服务端配置决定。
        -- RPC 返回 {success: boolean, key: string?, arguments: table?, index: number?}，不接受客户端坐标。
        "C2S_TransferWorld",
        -- position: Vector2，仅用于飘字起点；服务端限速并按真实配置结算，不接受收益参数。
        "C2S_TrainingClick",
        -- settings: {musicVolume: integer 0..100, soundEffectsVolume: integer 0..100, showAura: boolean}。
        -- 单向保存本人偏好；身份来自网络层，服务端仅接收这三个字段。
        "C2S_SaveSettings",
    },
    ServerMsgID = {
        -- 无参数，UTC 跨日清理上一日的客户端礼盒。
        "S2C_ClearGiftDrops",
        -- dropId: string、options: {Position: Vector3, Height: number, Duration: number}，个人客户端生成礼盒表现。
        "S2C_SpawnGiftDrop",
        -- amount: number、currency: string，实际到账奖励；客户端复用拾取奖励 UI。
        "S2C_GiftDropOpened",
        -- 无参数；服务端确认公共小狗拾取成功后，仅通知拾取者播放现有拾取音效。
        "S2C_DogPickedUp",
        -- key: string、arguments: table?、duration: number?，项目提示在客户端翻译，单向消息。
        "S2C_ShowLocalizedTips",
        -- gain: number，服务端实际训练收益；rewardRain: boolean?，力量卡结算为 true，播放力量图标雨。
        -- position: Vector2?，点击结算返回飘字起点；走路及击打不传，力量卡不传位置。
        "S2C_TrainingEffect",
        -- round: number、brokenCells: string[]?；新轮重置，或同轮恢复个人已击破格号。
        "S2C_RockReset",
        -- key: string、round: number、accepted: boolean，确认命中或要求撤销该次本地扣血预测。
        "S2C_RockHitResult",
        -- data: {DropId, DisplayModelId, NameKey, Quality, Price, IsLucky, LuckRate, GroundPosition, ExpiresAt}。
        -- 仅发送给掉落拥有者，由客户端本地创建模型、HUD 和拾取提示。
        "S2C_SpawnRockDrop",
        -- dropId: string；拾取成功、到期或轮次重置时通知拥有者移除本地掉落表现。
        "S2C_RemoveRockDrop",
        -- 无参数；卡片使用成功且进入激活阶段后，仅通知使用者播放通用激活音。
        "S2C_CardActivated",
        -- seconds: number，下一档剩余在线秒数，-1 为今日全部到期；hasDrops: boolean，是否有待领取礼盒。
        "S2C_GiftDropCountdown",
    },
}
