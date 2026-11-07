-- 通行证礼包：平台核实所有权，钻石和领取次数在同一玩家档案保存。
local FX, FS = _G.FX, _G.FS
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local Fields = _G.PlayerDataConfig
local Service = {}
local pendingReconciliations = {}

--- 只接受配置中的一次性钻石通行证，不把通行证伪造成开发者商品收据。
--- @param goodsId any 业务商品 ID。
--- @return table? 可处理的通行证礼包。
local function GetGoods(goodsId)
    if type(goodsId) ~= "number" then
        return nil
    end
    local goods = _G.GoodsConfig.GoodsData[goodsId]
    if goods and goods.ProductType == "GamePass" and goods.BuyHandler == "AddGem"
        and goods.BuyLimit == 1 and type(goods.RobloxProductId) == "number" and goods.RobloxProductId > 0 then
        return goods
    end
    return nil
end

--- 所有权请求和保存均会等待，返回后必须仍为原玩家档案。
--- @param player table 已认证的玩家对象。
--- @param session string 本次加载的会话标识，不持有 DB 引用。
--- @return boolean 原会话是否仍可写入。
local function IsActive(player, session)
    local id = player:GetPlayerId()
    return FS.PlayerManager:GetPlayerObject(id) == player
        and FS.PlayerKVDataManager:IsSessionActive(id, session)
end

--- 发奖与领取标记不可让出执行；通过公开事务同时回滚存档与待同步数据。
--- @param player table 当前会话的玩家对象。
--- @param goods table 一次性钻石礼包配置。
--- @return boolean 钻石和领取次数是否已共同写入内存。
local function Grant(player, goods)
    return player:RunDataTransaction(function()
        return _G.Provider:GetBuyHandler("AddGem"):Buy({playerObject = player, goodsConfig = goods, num = 1})
    end)
end

--- 平台核验后复用钻石处理器；保存失败保留奖励与次数，重试只保存、不重复发放。
--- @param player table 服务端认证的玩家对象。
--- @param goods table 已验证的一次性钻石通行证配置。
--- @return string|boolean Prompt 表示尚未拥有，Owned 表示已核验并保存，false 表示稍后重试。
function Service.Check(player, goods)
    local id = player:GetPlayerId()
    local session = FS.PlayerKVDataManager:GetSessionToken(id)
    local shop = FS.ShopService
    if not session or not IsActive(player, session) or shop._busy[id] then
        return false
    end
    -- 与开发者商品共用购买锁，避免保存期间交叉结算。
    shop._busy[id] = true
    local ok, result = pcall(function()
        local owns = MarketplaceService:UserOwnsGamePassAsync(id, goods.RobloxProductId)
        if not IsActive(player, session) then
            return false
        end
        if not owns then
            return "Prompt"
        end
        local data = player:GetTableView(Fields.CurrencyShopData)
        if (data.robuxBought[tostring(goods.DevGoodsId)] or 0) < 1 then
            if not Grant(player, goods) then
                return false
            end
        end
        if not FS.PlayerKVDataManager:Save(id, session) or not IsActive(player, session) then
            return false
        end
        return "Owned"
    end)
    shop._busy[id] = nil
    if not ok then
        warn("[GamePass] ownership or reward save failed", id, result)
        return false
    end
    return result
end

--- 登录和平台完成事件共用补发流程，失败时在玩家会话内持续重试。
--- @param player table 此次会话的玩家对象。
--- @param passId number? 平台事件中的通行证 ID；登录时检查全部礼包。
function Service.Reconcile(player, passId)
    for goodsId in pairs(_G.GoodsConfig.GoodsData) do
        local goods = GetGoods(goodsId)
        if goods and (passId == nil or goods.RobloxProductId == passId) then
            local pending = pendingReconciliations[player]
            if not pending then
                pending = {}
                pendingReconciliations[player] = pending
            end
            local state = pending[goodsId]
            if state then
                if passId then
                    state.expectOwned = true
                end
            else
                state = {expectOwned = passId ~= nil}
                pending[goodsId] = state
                task.spawn(function()
                    local delaySeconds = 2
                    while FS.PlayerManager:GetPlayerObject(player:GetPlayerId()) == player do
                        local result = Service.Check(player, goods)
                        if result == "Owned" or (result == "Prompt" and not state.expectOwned) then
                            break
                        end
                        task.wait(delaySeconds)
                        delaySeconds = math.min(delaySeconds * 2, 30)
                    end
                    pending[goodsId] = nil
                    if not next(pending) then
                        pendingReconciliations[player] = nil
                    end
                end)
            end
        end
    end
end

--- 协议只接受本人商品 ID；平台完成事件仍重新核验所有权。
function Service.Init()
    --- 客户端只能触发本人已配置通行证的核验，不能声明已支付或提交奖励。
    --- @param userId number 网络层认证的玩家 ID。
    --- @param goodsId any 客户端选择的业务商品 ID。
    --- @return string|boolean 已保存、允许弹窗或稍后重试。
    FX.Network:RegClientMsgCallback("C2S_CheckGamePassPurchase", function(userId, goodsId)
        local player = FS.PlayerManager:GetPlayerObject(userId)
        local goods = GetGoods(goodsId)
        if not player or not goods then
            return false
        end
        return Service.Check(player, goods)
    end)
    --- Ready 后才检查档案，避免在原生 PlayerAdded 时过早发奖。
    --- @param userId number 框架完成握手的玩家 ID。
    FS.Events.OnPlayerReady.Event:Connect(function(userId)
        local player = FS.PlayerManager:GetPlayerObject(userId)
        if player then
            task.spawn(Service.Reconcile, player)
        end
    end)
    --- 事件仅触发平台核验，purchased 不能直接作为发奖依据。
    --- @param playerNode Player 平台回调中的玩家实例。
    --- @param passId number 平台回调中的通行证 ID。
    --- @param purchased boolean 平台是否报告购买成功。
    MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(playerNode, passId, purchased)
        local player = FS.PlayerManager:GetPlayerObject(playerNode.UserId)
        if player and player:GetPlayerNode() == playerNode then
            FX.Network:SendMsgToClient(playerNode.UserId, "S2C_GamePassPromptFinished", passId, purchased)
            if purchased then
                task.spawn(Service.Reconcile, player, passId)
            end
        end
    end)
    for index, playerNode in ipairs(Players:GetPlayers()) do
        local player = FS.PlayerManager:GetPlayerObject(playerNode.UserId)
        if player then
            task.spawn(Service.Reconcile, player)
        end
    end
end

return Service
