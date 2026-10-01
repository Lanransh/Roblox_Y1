local FX, FS = _G.FX, _G.FS
local Players = game:GetService("Players")
local Class = FX.Class("FSPlayerObjectManagerClass", "FSObjectManagerClass")
FS.PlayerMgrClass = Class
--- @param playerClassType string 项目玩家类名。
function Class:Ctor(playerClassType)
    Class.Super.Ctor(self, playerClassType)
    self._playerMap, self._clientReady, self._serverReady = {}, {}, {}
    self._connections = {}
    FX.Network:RegClientMsgCallback("C2S_ClientReady", function(id)
        self:SetPlayerReady(id, true)
    end)
    table.insert(
        self._connections,
        FS.Events.OnPlayerDataLoadFinished.Event:Connect(function(id)
            if not Players:GetPlayerByUserId(id) then
                local db = FS.PlayerKVDataManager._playerDBMap[id]
                if db then
                    db:Save(true)
                    FS.PlayerKVDataManager._playerDBMap[id] = nil
                end
                return
            end
            self:SetPlayerReady(id, false)
        end)
    )
    self._timer = FX.Task:Interval(1, function()
        for _, playerObject in pairs(self._playerMap) do
            local ok, err = pcall(playerObject.OnUpdate, playerObject, os.time())
            if not ok then
                warn(err)
            end
        end
    end)
end
--- 重复 Ready 请求不会重建对象或重复发奖。
--- @param id number 引擎认证的玩家 ID。
--- @param isClient boolean 是否为客户端就绪通知。
function Class:SetPlayerReady(id, isClient)
    if self._playerMap[id] then
        return
    end
    if isClient then
        self._clientReady[id] = true
    else
        self._serverReady[id] = true
    end
    if not self._clientReady[id] or not self._serverReady[id] or not Players:GetPlayerByUserId(id) then
        return
    end
    local object = self:CreateObject(id)
    self._playerMap[id] = object
    FX.SyncManager:OnPlayerLogin(id)
    object:OnPlayerLogin()
    FS.Events.OnPlayerReady:Fire(id)
    FX.Network:SendMsgToClient(id, "S2C_ServerReady")
end
--- @param id number 正在退出的玩家 ID。
function Class:OnPlayerLogout(id)
    self._clientReady[id], self._serverReady[id] = nil, nil
    local object = self._playerMap[id]
    if object then
        object:OnPlayerLogout()
        self:DestroyObject(object)
        self._playerMap[id] = nil
    end
end
--- @param id number Roblox UserId。
--- @return table 已完成握手的玩家对象。
function Class:GetPlayerObject(id)
    return self._playerMap[id]
end
--- 清理管理器自有连接与每秒任务。
function Class:Dtor()
    FX.Task:Cancel(self._timer)
    FX.Network:UnRegClientMsgCallback("C2S_ClientReady")
    for _, connection in ipairs(self._connections) do
        connection:Disconnect()
    end
    Class.Super.Dtor(self)
end
return Class
