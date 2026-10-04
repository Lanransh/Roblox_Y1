-- 项目协议在框架初始化之前加载；每个方向填写有序的协议名列表。
-- 框架已有的 Ready、玩家数据和服务器数据同步协议继续由 FrameworkInit 声明。
return {
    ClientMsgID = {
        -- key: string，当前玩家已击破的石头格号；服务器校验血量并只弹出一次。
        -- 单向请求，不接受客户端提供道具、价格、位置或玩家身份。
        "C2S_RequestRockDrop",
    },
    ServerMsgID = {
        -- gain: number，服务端实际走路及击打总收益；点击图标由客户端立即播放，无需回包。
        "S2C_TrainingEffect",
    },
}
