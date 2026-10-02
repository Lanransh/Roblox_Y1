-- Luau CLI 用的边界替身；被测奖励、背包、好友、弹窗方法均加载原文件。
local function Signal()
    local listeners = {}
    return {
        Connect = function(_, callback)
            listeners[callback] = true
            return {
                Disconnect = function()
                    listeners[callback] = nil
                end,
            }
        end,
        Fire = function(_, ...)
            for callback in pairs(listeners) do
                callback(...)
            end
        end,
    }
end

local scheduled = {}
local task = {}

function task.spawn(callback)
    table.insert(scheduled, callback)
    return callback
end

function task.delay(_, callback)
    return task.spawn(callback)
end

local function Flush()
    while #scheduled > 0 do
        table.remove(scheduled, 1)()
    end
end

local players = { PlayerAdded = Signal(), PlayerRemoving = Signal(), list = {} }

function players:GetPlayers()
    return self.list
end

local selection = {}
local input = { GamepadEnabled = false }
local Config = {
    Items = { [100] = { Id = 100, MaxStack = 10, Type = "Test" } },
    ItemSchemas = { Test = { Power = 1 } },
    PlayerData = { Coins = { Type = "number", Key = "Coins", DefVal = 0 } },
    RewardCurrencies = { Money = "Coins", Gold = "Coins" },
}

local game = { ReplicatedStorage = { Shared = { Config = { FrameworkConfig = Config } } } }

function game:GetService(name)
    return ({ Players = players, GuiService = selection, UserInputService = input })[name]
end

local function require(module)
    return module
end

local function warn(...) end
local serverCallbacks, clientCallbacks, sent = {}, {}, {}
local network = {}

function network:RegClientMsgCallback(name, callback)
    serverCallbacks[name] = callback
end

function network:UnRegClientMsgCallback(name)
    serverCallbacks[name] = nil
end

function network:RegServerMsgCallback(name, callback)
    clientCallbacks[name] = callback
end

function network:UnRegServerMsgCallback(name)
    clientCallbacks[name] = nil
end

function network:SendMsgToClient(id, name, state)
    table.insert(sent, { id = id, name = name, state = state })
end

function network:SendMsgToServer(name)
    serverCallbacks[name](players.LocalPlayer.UserId)
end

local intervals = {}
local nextId = 0
local _G = {
    FX = {
        Network = network,
        GenObjectID = function()
            nextId += 1
            return nextId
        end,
        IsDebugMode = function()
            return true
        end,
        DebugAssert = assert,
        ErrorWithTraceback = error,
        Log = { ErrorFmt = function() end },
        Task = {
            Interval = function(_, _, callback)
                intervals[callback] = true
                return callback
            end,
            Cancel = function(_, callback)
                if not callback then
                    return
                end

                intervals[callback] = nil
                for i = #scheduled, 1, -1 do
                    if scheduled[i] == callback then
                        table.remove(scheduled, i)
                    end
                end
            end,
        },
    },

    FS = {},
    FC = {},
    MS = { Players = players },
}

_G.Provider = {
    GetItemDataConfig = function(_, id)
        return Config.Items[id]
    end,
    GetItemExtraDataSchema = function(_, kind)
        return Config.ItemSchemas[kind]
    end,
}
