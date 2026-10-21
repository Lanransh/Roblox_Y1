local FX = _G.FX
local FXLoader = FX.Loader
local Text = FXLoader:RequireShared("Scripts/Game/Shared/Text")
local TranslationTexts = Text.Define("PlayerRequests", {
    Unknown = "Something went wrong. Please try again.",
    NotReady = "This reward is not available yet.",
})
local CurrencyShop = FX.Loader:Require(script.Parent.Parent, "Handlers/CurrencyShop")
local GMRecovery = FX.Loader:Require(script.Parent.Parent, "Handlers/GMRecovery")
local Manager = FX.Class("SPlayerObjectManagerClass", "FSPlayerObjectManagerClass")
_G.SPlayerObjectManagerClass = Manager

--- 使用项目玩家类构建服务端管理器，并统一注册玩家业务协议。
function Manager:Ctor()
    Manager.Super.Ctor(self, "SPlayerObjectClass")
    self:RegForwardFrameworkClientMsg()
    self:RegMiscMsg()
    self:RegRockDropMsg()
    self:RegLootSellMsg()
    self:RegAuraMsg()
    self:RegWeaponMsg()
    self:RegGMMsg()
    self:RegActivityMsg()
    self:RegCurrencyShopMsg()
    self:RegSettingsMsg()
end

--- 设置只保存到认证请求者的现有存档，不允许客户端提交其他玩家或字段。
function Manager:RegSettingsMsg()
    --- 校验完整快照后一次写入；拒绝 NaN、无穷数和越界音量。
    --- @param userId number 网络层认证的玩家 ID。
    --- @param settings any 客户端提交的偏好快照。
    FX.Network:RegClientMsgCallback("C2S_SaveSettings", function(userId, settings)
        local player = self:GetPlayerObject(userId)
        if not player or type(settings) ~= "table" or type(settings.showAura) ~= "boolean"
            or type(settings.giantPickaxe) ~= "boolean" then
            return
        end
        for index, key in ipairs({"musicVolume", "soundEffectsVolume"}) do
            local value = settings[key]
            if type(value) ~= "number" or value ~= value or value < 0 or value > 100 or value % 1 ~= 0 then
                return
            end
        end
        player:SetTable(_G.PlayerDataConfig.Settings, {
            musicVolume = settings.musicVolume,
            soundEffectsVolume = settings.soundEffectsVolume,
            showAura = settings.showAura,
            giantPickaxe = settings.giantPickaxe,
        })
    end)
end

--- 商店协议只注册一次；玩家身份始终取网络层认证结果。
function Manager:RegCurrencyShopMsg()
    --- 客户端仅报告界面动作；统计错误不影响购买或其他协议。
    --- @param userId number 引擎认证玩家 ID。
    --- @param action any 固定商店动作。
    --- @param productId any 平台商品 ID，不接受客户端余额。
    --- @param attemptId any 本次点击标识，由分析组件校验并匹配。
    FX.Network:RegClientMsgCallback("C2S_RobuxPurchaseAnalytics", function(userId, action, productId, attemptId)
        local player = self:GetPlayerObject(userId)
        local analytics = player and player:GetComponent("SAnalyticsComp")
        if analytics then
            pcall(analytics.RecordShopAction, analytics, action, productId, attemptId)
        end
    end)
    --- 未建立有效会话时拒绝扣款。
    --- @param userId number 引擎认证玩家 ID。
    --- @param goodsId any 客户端商品 ID。
    --- @return table 商店权威结果。
    FX.Network:RegClientMsgCallback("C2S_BuyCurrencyShopGoods", function(userId, goodsId)
        local player = self:GetPlayerObject(userId)
        if not player then
            return {success = false, key = TranslationTexts.Unknown}
        end
        return CurrencyShop.Buy(player, goodsId)
    end)
end

--- 福利协议只注册一次，按引擎认证身份取得本人的活动组件。
function Manager:RegActivityMsg()
    --- 会话未就绪时拒绝，类别与稳定 ID 由活动组件校验。
    --- @param userId number 引擎认证的请求者。
    --- @param kind any 客户端奖励类别。
    --- @param rewardId any 客户端配置 ID。
    --- @param multiplier any 离线领取方式，由服务端验证。
    --- @return table 领取结果与权威状态。
    FX.Network:RegClientMsgCallback("C2S_ClaimWelfareReward", function(userId, kind, rewardId, multiplier)
        local player = self:GetPlayerObject(userId)
        local activity = player and player:GetComponent("SActivityComp")
        if not activity then
            return {success = false, key = TranslationTexts.NotReady}
        end
        return activity:Claim(kind, rewardId, multiplier)
    end)
end

--- GM 协议统一注册，按引擎认证身份转发到请求者本人的玩家组件。
function Manager:RegGMMsg()
    --- 已登录请求转发组件，加载失败时仅允许开发者恢复本人存档。
    --- @param userId number 引擎认证的请求者身份。
    --- @param action string 八种 GM 操作之一。
    --- @param value any 数值操作的目标值或道具配置 ID。
    --- @param count any 添加道具数量，其他动作不使用。
    --- @return table GM 组件的权威操作结果。
    FX.Network:RegClientMsgCallback("C2S_GMCommand", function(userId, action, value, count)
        local player = self:GetPlayerObject(userId)
        local gm = player and player:GetComponent("SGMComp")
        if not gm then
            return GMRecovery.Request(userId, action)
        end
        return gm:Request(action, value, count)
    end)
end

--- 光环协议只注册一次，再按引擎认证身份转发到本人组件。
function Manager:RegAuraMsg()
    --- 未完成登录或已离服时拒绝请求，组件负责权威价格与拥有权校验。
    --- @param userId number 引擎认证的请求者。
    --- @param action string 购买或切换装备动作。
    --- @param auraId number 客户端请求的稳定光环 ID。
    --- @return table 权威操作结果。
    FX.Network:RegClientMsgCallback("C2S_AuraAction", function(userId, action, auraId)
        local player = self:GetPlayerObject(userId)
        local aura = player and player:GetComponent("SAuraComp")
        if not aura then
            return {success = false, key = TranslationTexts.Unknown}
        end
        return aura:RequestAura(action, auraId)
    end)
end

--- 武器协议只注册一次，客户端不能指定其他玩家身份。
function Manager:RegWeaponMsg()
    --- 会话未就绪或已离服时拒绝请求，价格与拥有权由组件校验。
    --- @param userId number 引擎认证的请求者。
    --- @param action string 购买或装备动作。
    --- @param weaponId number 稳定 ToolId。
    --- @return table 权威操作结果。
    FX.Network:RegClientMsgCallback("C2S_WeaponAction", function(userId, action, weaponId)
        local player = self:GetPlayerObject(userId)
        local weapon = player and player:GetComponent("SWeaponComp")
        if not weapon then
            return {success = false, key = TranslationTexts.Unknown}
        end
        return weapon:RequestWeapon(action, weaponId)
    end)
end

--- 出售 RPC 只转发引擎认证玩家自身的请求，未就绪时不结算。
function Manager:RegLootSellMsg()
    --- 金额与库存由出售组件校验，不接受客户端指定玩家身份。
    --- @param userId number 引擎认证的请求者。
    --- @param entryIds table 客户端当前展示的收藏品实例 ID。
    --- @param multiplier number 客户端展示的出售倍率，由服务端重新核验。
    --- @param method string? Card / Gems / Vip；普通出售省略。
    --- @return table 出售结果与英文文案 Key。
    FX.Network:RegClientMsgCallback("C2S_SellLoot", function(userId, entryIds, multiplier, method)
        local player = self:GetPlayerObject(userId)
        local sell = player and player:GetComponent("SLootSellComp")
        if not sell then
            return {success = false, key = TranslationTexts.Unknown}
        end
        return sell:SellLoot(entryIds, multiplier, method)
    end)
end

--- 简单玩家请求直接转发到杂项组件，不在管理器内执行结算。
function Manager:RegMiscMsg()
    --- 点击仅转发至请求者的训练组件，收益和频率由服务端决定。
    --- @param userId number 引擎认证的玩家身份。
    --- @param position Vector2 客户端飘字起点，不参与收益计算。
    local function trainingClick(userId, position)
        local player = self:GetPlayerObject(userId)
        local misc = player and player:GetComponent("SMiscComp")
        if misc then
            misc:HandleTrainingClick(position)
        end
    end
    FX.Network:RegClientMsgCallback("C2S_TrainingClick", trainingClick)
    --- 只操作引擎认证玩家自身的数据，忽略未加载或已离服的玩家。
    --- @param userId number 引擎认证的玩家身份。
    local function rebirth(userId)
        local player = self:GetPlayerObject(userId)
        local misc = player and player:GetComponent("SMiscComp")
        if misc then
            return misc:HandleRebirth()
        end
        return {success = false}
    end
    FX.Network:RegClientMsgCallback("C2S_Rebirth", rebirth)
    --- 世界传送只接受配置序号，重生门槛与落点由杂项组件按服务端数据校验。
    --- @param userId number 引擎认证的玩家身份。
    --- @param index any 客户端请求的世界传送序号。
    --- @return table 权威结果与失败提示 Key。
    local function transferWorld(userId, index)
        local player = self:GetPlayerObject(userId)
        local misc = player and player:GetComponent("SMiscComp")
        if not misc then
            return {success = false, key = TranslationTexts.Unknown}
        end
        return misc:HandleTransferWorld(index)
    end
    FX.Network:RegClientMsgCallback("C2S_TransferWorld", transferWorld)
end

--- 按引擎认证身份转发命中、开奖和轮次请求，未登录或已离服时忽略。
function Manager:RegRockDropMsg()
    --- 只查请求者自身组件，石头状态和请求参数由组件校验。
    --- @param userId number 引擎认证的玩家身份。
    --- @param key string 客户端观察到已击破的格号。
    --- @param round number 客户端当前关卡轮次。
    local function requestDrop(userId, key, round)
        local player = self:GetPlayerObject(userId)
        local rocks = player and player:GetComponent("SRockLevelComp")
        if rocks then
            rocks:RequestDrop(key, round)
        end
    end
    FX.Network:RegClientMsgCallback("C2S_RequestRockDrop", requestDrop)
    --- 只接受本人服务器掉落 ID，归属、距离、到期和容量均由组件校验。
    --- @param userId number 引擎认证的玩家身份。
    --- @param dropId string 服务端签发的掉落 ID。
    --- @return boolean 是否成功拾取并发奖。
    local function pickupDrop(userId, dropId)
        local player = self:GetPlayerObject(userId)
        local rocks = player and player:GetComponent("SRockLevelComp")
        if rocks then
            return rocks:PickupDrop(dropId)
        end
        return false
    end
    FX.Network:RegClientMsgCallback("C2S_PickupRockDrop", pickupDrop)
    --- 服务端只记录通过边界校验的命中，回包校正血量或撤销客户端无效预测。
    --- @param userId number 引擎认证的玩家身份。
    --- @param key string 客户端命中的格号。
    --- @param round number 客户端当前关卡轮次。
    local function rockHit(userId, key, round)
        local player = self:GetPlayerObject(userId)
        local rocks = player and player:GetComponent("SRockLevelComp")
        if rocks then
            local accepted, health = rocks:RecordHit(key, round)
            FX.Network:SendMsgToClient(userId, "S2C_RockHitResult", key, round, accepted, health)
        end
    end
    FX.Network:RegClientMsgCallback("C2S_RockHit", rockHit)
    --- 客户端加载与重生后主动获取轮次，避免依赖早于组件就绪的通知。
    --- @param userId number 引擎认证的玩家身份。
    local function requestRound(userId)
        local player = self:GetPlayerObject(userId)
        local rocks = player and player:GetComponent("SRockLevelComp")
        if rocks then
            rocks:SendRockRound()
        end
    end
    FX.Network:RegClientMsgCallback("C2S_RequestRockRound", requestRound)
    --- 回家目标由服务端决定，未登录或已离服时忽略请求。
    --- @param userId number 引擎认证的玩家身份。
    local function returnHome(userId)
        local player = self:GetPlayerObject(userId)
        local rocks = player and player:GetComponent("SRockLevelComp")
        if rocks then
            rocks:ReturnHome()
        end
    end
    FX.Network:RegClientMsgCallback("C2S_ReturnHome", returnHome)
end

function Manager:GetInventory(playerId)
    local player = self:GetPlayerObject(playerId)
    return player and player:GetComponent("FSInventoryComp")
end

--- 只接受原生 Tool 使用请求，物品归属由服务端背包组件校验。
function Manager:RegForwardFrameworkClientMsg()
    FX.Network:RegClientMsgCallback("C2S_ActivateTool", function(id, tool)
        local inv = self:GetInventory(id)
        if inv then
            return inv:ActivateTool(tool)
        end
        return false
    end)
end

return Manager
