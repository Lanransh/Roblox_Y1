local FX, FS, FC = _G.FX, _G.FS, _G.FC
local passed = 0

local function Check(name, body)
    body()
    passed += 1
    print("PASS", name)
end

local Player = FX.Class("AddonTestPlayer", "FXObjectBaseClass")

function Player:Ctor()
    Player.Super.Ctor(self)
    self.data = { Coins = 20, Bag = {} }
end

function Player:GetPlayerId()
    return 1
end

function Player:GetNumber(field)
    return self.data[field.Key]
end

function Player:SetNumber(field, value)
    self.data[field.Key] = value
    return true
end

function Player:GetTable(field)
    return FX.Table:DeepCopy(self.data[field.Key])
end

function Player:SetTable(field, value)
    self.data[field.Key] = FX.Table:DeepCopy(value)
    return true
end

local Inventory = FX.Class("AddonTestInventory", "FSInventoryCompClass")

function Inventory:GetConfig()
    return { storeTableVarEnum = { Key = "Bag" }, shortcutCapacity = 1, inventoryCapacity = 1 }
end

local function RewardPlayer()
    local player = Player.New()
    player:AddComponent("AddonTestInventory")
    local reward = player:AddComponent("FSRewardCompClass")
    return player, reward, player:GetComponent("FSInventoryComp")
end

Check("reward stacks split and mixed add/consume succeed", function()
    local player, reward, bag = RewardPlayer()
    local batch = { { Type = "Item", ItemId = 100, Count = 15 }, { Type = "Money", Count = 7 } }
    assert(reward:CanAddRewards(batch) and next(player.data.Bag) == nil and player.data.Coins == 20)
    assert(reward:AddRewards(batch))
    assert(bag:GetItemCountById(100) == 15 and player.data.Coins == 27)
    assert(reward:ConsumeRewards(batch))
    assert(bag:GetItemCountById(100) == 0 and player.data.Coins == 20)
    player:Dtor()
end)

Check("aggregate currency aliases and duplicate item costs before writes", function()
    local player, reward, bag = RewardPlayer()
    assert(reward:AddRewards({ { Type = "Item", ItemId = 100, Count = 10 } }))
    assert(not reward:ConsumeRewards({
        { Type = "Money", Count = 12 },
        { Type = "Money", Currency = "Gold", Count = 12 },
        { Type = "Item", ItemId = 100, Count = 1 },
    }))
    assert(player.data.Coins == 20 and bag:GetItemCountById(100) == 10)
    assert(not reward:ConsumeRewards({
        { Type = "Item", ItemId = 100, Count = 6 },
        { Type = "Item", ItemId = 100, Count = 6 },
        { Type = "Money", Count = 1 },
    }))
    assert(player.data.Coins == 20 and bag:GetItemCountById(100) == 10)
    player:Dtor()
end)

Check("full inventory and malformed rewards never partly grant money", function()
    local player, reward, bag = RewardPlayer()
    assert(reward:AddRewards({ { Type = "Item", ItemId = 100, Count = 20 } }))
    assert(not reward:AddRewards({ { Type = "Money", Count = 5 }, { Type = "Item", ItemId = 100, Count = 1 } }))
    for _, count in ipairs({ -1, 0, 0.5, math.huge, 0 / 0 }) do
        assert(not reward:AddRewards({ { Type = "Money", Count = count } }))
    end

    assert(not reward:AddRewards({ [2] = { Type = "Money", Count = 5 } }))
    assert(not reward:AddRewards({ { Type = "Money", Count = 5 }, { Type = "Unknown", Count = 1 } }))
    assert(not reward:AddRewards({ { Type = "Money", Currency = "Unregistered", Count = 1 } }))
    assert(player.data.Coins == 20 and bag:GetItemCountById(100) == 20)
    player.data.Coins = 9007199254740991
    assert(not reward:AddRewards({ { Type = "Money", Count = 1 } }))
    player:Dtor()
end)

Check("independent item data copied and consumption by extra data rejected", function()
    local player, reward, bag = RewardPlayer()
    local extra = { Power = 7 }
    assert(reward:AddRewards({ { Type = "Item", ItemId = 100, Count = 2, ExtraData = extra } }))
    extra.Power = 9
    assert(bag:GetGridData(1).extraData.Power == 7 and bag:GetGridData(2).extraData.Power == 7)
    assert(not reward:ConsumeRewards({ { Type = "Item", ItemId = 100, Count = 1, ExtraData = extra } }))
    assert(bag:GetItemCountById(100) == 2)
    player:Dtor()
end)

local friends = FS.FriendService
local p1, p2, p3 = { UserId = 1 }, { UserId = 2 }, { UserId = 3 }
local queryCount, failPage, yieldQuery = 0, false, false

function players:GetFriendsAsync(id)
    queryCount += 1
    if yieldQuery then
        coroutine.yield()
    end

    local page = { IsFinished = false, index = 1 }

    function page:GetCurrentPage()
        if id == 1 then
            return self.index == 1 and { { Id = 2 } } or { { Id = 3 }, { Id = 999 } }
        end

        return { { Id = 1 } }
    end

    function page:AdvanceToNextPageAsync()
        if failPage then
            error("platform page failed")
        end

        self.index, self.IsFinished = 2, true
    end

    return page
end

players.list, players.LocalPlayer = { p1, p2 }, p1
Check("friend pagination, late snapshot and copy isolation", function()
    friends:Init()
    assert(friends:GetFriendCountInRoom(1) == nil)
    Flush()
    assert(friends:IsFriend(1, 999) and friends:GetFriendCountInRoom(1) == 1)
    assert(not friends:IsFriend(1, 77))
    local ids = friends:GetFriendIds(1)
    assert(#ids == 3)
    ids[1] = 123
    assert(friends:GetFriendIds(1)[1] == 2)
    local before = queryCount
    serverCallbacks.C2S_GetFriendState(1, 999, { 77 })
    assert(queryCount == before and sent[#sent].id == 1 and #sent[#sent].state.ids == 1)
end)

Check("join and leave update same-room counts", function()
    players.PlayerAdded:Fire(p3)
    assert(friends:GetFriendCountInRoom(1) == 2)
    Flush()
    players.PlayerRemoving:Fire(p2)
    assert(friends:GetFriendCountInRoom(1) == 1 and friends:GetState(1).ids[1] == 3)
end)

Check("partial platform failure preserves last snapshot but marks unavailable", function()
    failPage = true
    friends:Refresh(p1)
    assert(friends:GetState(1).status == "Unavailable" and #friends:GetState(1).ids == 1)
    assert(friends:IsFriend(1, 3) == nil and friends:GetFriendIds(1) == nil)
    assert(friends:GetFriendCountInRoom(1) == nil)
    failPage = false
    friends:Refresh(p1)
    assert(friends:GetState(1).status == "Ready" and friends:IsFriend(1, 3))
end)

Check("pending query cannot overwrite a rejoined player's session", function()
    yieldQuery = true
    local pending = coroutine.create(function()
        friends:Refresh(p1)
    end)

    assert(coroutine.resume(pending))
    local before = queryCount
    friends:Refresh(p1)
    assert(queryCount == before)
    players.PlayerRemoving:Fire(p1)
    local replacement = { UserId = 1 }
    players.PlayerAdded:Fire(replacement)
    yieldQuery = false
    assert(coroutine.resume(pending))
    assert(friends:GetState(1).status == "Loading")
    Flush()
    assert(friends:GetState(1).status == "Ready")
end)

Check("client rejects old snapshots and cleans network subscription", function()
    local player = Player.New()
    local friend = player:AddComponent("FCFriendCompClass")
    friend:OnReady()
    clientCallbacks.S2C_FriendState(sent[#sent].state)
    local revision = friend:GetState().revision
    assert(friend:GetFriendCountInRoom() == 1)
    clientCallbacks.S2C_FriendState({ ids = {}, status = "Ready", revision = revision - 1 })
    assert(friend:GetFriendCountInRoom() == 1)
    local copy = friend:GetState()
    copy.ids[1] = 777
    assert(friend:GetState().ids[1] == 3)
    player:Dtor()
    assert(clientCallbacks.S2C_FriendState == nil)
    friends:Dtor()
    assert(serverCallbacks.C2S_GetFriendState == nil and next(intervals) == nil)
    players.PlayerAdded:Fire({ UserId = 55 })
    assert(friends:GetFriendIds(55) == nil)
end)

-- UI 逻辑测试使用节点替身；原生实例布局另由 FrameworkAddonsClient.spec.lua 验证。
local function CommonUI()
    return setmetatable({
        Modal = { Visible = false },
        Description = {},
        Confirm = {},
        Cancel = {},
        Tips = {},
    }, FC.CommonUICompClass)
end

Check("confirm/cancel at most once and nil confirm never invokes cancel", function()
    local ui, confirmed, cancelled = CommonUI(), 0, 0
    ui:ShowConfirm({
        Desc = "Test",
        ConfirmCB = function()
            confirmed += 1
        end,
        CancelCB = function()
            cancelled += 1
        end,
    })

    ui:_Finish(true)
    ui:_Finish(true)
    assert(confirmed == 1 and cancelled == 0 and not ui.Modal.Visible)
    ui:ShowConfirm({
        CancelCB = function()
            cancelled += 1
        end,
    })

    ui:_Finish(true)
    assert(cancelled == 0)
    ui:ShowConfirm({
        CancelCB = function()
            cancelled += 1
        end,
    })

    ui:_Finish(false)
    assert(cancelled == 1)
end)

Check("callback can open next dialog; replacement never calls old callback", function()
    local ui = CommonUI()
    ui:ShowTooltips({
        ConfirmCB = function()
            error("old callback")
        end,
    })

    ui:ShowConfirm({
        ConfirmCB = function()
            ui:ShowTooltips({ Desc = "Next" })
        end,
    })

    ui:_Finish(true)
    assert(ui.Modal.Visible and ui.Description.Text == "Next" and not ui.Cancel.Visible)
end)

Check("new toast cancels previous timer", function()
    local ui = CommonUI()
    ui:ShowTips("Old", 1)
    ui:ShowTips("New", 2)
    assert(#scheduled == 1 and ui.Tips.Text == "New" and ui.Tips.Visible)
    Flush()
    assert(not ui.Tips.Visible)
end)

print(string.format("%d addon logic tests passed (service doubles; no live Roblox API)", passed))
