local FX, FS = _G.FX, _G.FS
local Config = require(script.Parent.Parent.Parent.Config.StorageConfig)
local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local memory = game:GetService("RunService"):IsStudio() and Config.StudioMemory
local store = not memory and DataStoreService:GetDataStore(Config.DataStoreName)
local memoryRecords = {}
local DB = FX.Class("FSPlayerKVDBClass")
FS.PlayerKVDBClass = DB

--- 所有 KV 域同属一个玩家记录，购买回执和奖励可在一次更新中落盘。
--- @param playerId number Roblox UserId。
function DB:Ctor(playerId)
    self._playerId = playerId
    self._key = "Player_" .. tostring(playerId)
    self._session = HttpService:GenerateGUID(false)
    self._data, self._database = {}, {}
    self._loaded, self._saving, self._released = false, false, false
    self._revision = 0
end

--- 加载失败绝不创建空档继续游戏。
function DB:LoadAsync()
    task.spawn(function()
        local success, record = pcall(function()
            return self:_Update(function(old)
                if old ~= nil then
                    assert(type(old) == "table" and type(old.Data) == "table", "Invalid saved profile")
                end

                old = old or { Data = {} }
                local lock = old.Session
                if lock and lock.Id ~= self._session and os.time() - lock.Time < Config.SessionLeaseSeconds then
                    return nil
                end

                old.Session = { Id = self._session, Time = os.time() }
                return old
            end)
        end)

        if not success or not record then
            warn("[Storage] Load failed or session locked", self._playerId, record)
            FS.Events.OnPlayerDataLoadFailed:Fire(self._playerId)
            return
        end

        self._data = record.Data
        for _, name in ipairs(_G.Provider:GetPlayerKVEnum()) do
            local data = self._data[name]
            if data ~= nil and type(data) ~= "table" then
                warn("[Storage] Invalid KV domain", name)
                FS.Events.OnPlayerDataLoadFailed:Fire(self._playerId)
                return
            end

            self._data[name] = data or {}
            self._database[name] = FS.PlayerKVTableClass.New(self, name)
        end

        self._loaded = true
        if self._leaving then
            self:Save(true)
            return
        end

        FS.Events.OnPlayerDataLoadFinished:Fire(self._playerId)
    end)
end

--- Studio 内存模式使用相同的会话锁逻辑，只是不调用云服务。
--- @param transform function 无 yield 的原子转换。
--- @return table 更新后的记录，取消时返回 nil。
function DB:_Update(transform)
    if not memory then
        return store:UpdateAsync(self._key, transform)
    end

    local nextRecord = transform(FX.Table:DeepCopy(memoryRecords[self._key]))
    if nextRecord then
        memoryRecords[self._key] = FX.Table:DeepCopy(nextRecord)
    end

    return nextRecord
end

--- @param release boolean 离服时保存并释放会话锁。
--- @return boolean 是否成功持久化本次快照。
function DB:Save(release)
    while self._saving do
        task.wait()
    end

    if not self._loaded or self._released then
        return false
    end

    self._saving = true
    local snapshot = FX.Table:DeepCopy(self._data)
    local success, result = pcall(function()
        return self:_Update(function(old)
            if not old or not old.Session or old.Session.Id ~= self._session then
                return nil
            end

            local record = { Data = snapshot }
            if not release then
                record.Session = { Id = self._session, Time = os.time() }
            end

            return record
        end)
    end)

    self._saving = false
    if not success or not result then
        warn("[Storage] Save failed", self._playerId, result)
        return false
    end

    self._released = release == true
    return true
end

--- @return boolean 当前保存结果；保留原框架接口。
function DB:SaveAsync()
    return self:Save(false)
end

--- @param name string 已声明的 KV 域。
--- @return table KV 视图。
function DB:GetKVTable(name)
    return self._database[name]
end

--- @return boolean 是否成功加载且仍拥有会话。
function DB:IsLoadFinished()
    return self._loaded and not self._released
end

return DB
