-- 项目协议在框架初始化之前加载；每个方向填写有序的协议名列表。
-- 框架已有的 Ready、玩家数据和服务器数据同步协议继续由 FrameworkInit 声明。
return {
    ClientMsgID = {
        -- 无参数，服务端校验请求者当前等级与重生次数，单向请求。
        "C2S_Rebirth",
        -- entryIds: string[]，正式库存的稳定实例 ID；multiplier: 1|2，暂时允许免费双倍。
        -- RPC 返回 {success: boolean, key: string, amount: number?, count: number?, entries: table?}。
        -- 价格、幸运与重生倍率均由服务端决定，不接受客户端金额。
        "C2S_SellLoot",
        -- key: string、round: number，击破格号与轮次；服务器按有效命中记录揭露预生成结果一次。
        -- 单向请求，不接受客户端提供道具、价格、位置或玩家身份。
        "C2S_RequestRockDrop",
        -- key: string、round: number，本地预测命中；服务器校验近身目标、装备与攻击频率，不接受伤害值。
        "C2S_RockHit",
        -- 无参数，客户端就绪或角色变化后请求当前轮次和个人已击破格号快照。
        "C2S_RequestRockRound",
    },
    ServerMsgID = {
        -- key: string、arguments: table?、duration: number?，项目提示在客户端翻译，单向消息。
        "S2C_ShowLocalizedTips",
        -- gain: number，服务端实际走路及击打总收益；点击图标由客户端立即播放，无需回包。
        "S2C_TrainingEffect",
        -- round: number、brokenCells: string[]?；新轮重置，或同轮恢复个人已击破格号。
        "S2C_RockReset",
        -- key: string、round: number、accepted: boolean，确认命中或要求撤销该次本地扣血预测。
        "S2C_RockHitResult",
    },
}
