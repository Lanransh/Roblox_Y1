-- 作为正常 LocalScript 注入 PlayerScripts；MCP 命令环境的 _G 与游戏脚本隔离。
local FX, FC = _G.FX, _G.FC
local owner = assert(FC.PlayerObject)
local results = {}

--- @param name string 检查名称。
--- @param body function 检查过程。
local function Check(name, body)
    local ok, err = pcall(body)
    table.insert(results, { name = name, passed = ok, error = not ok and tostring(err) or nil })
end

Check("task-delay-cancel-and-finite-interval", function()
    local calls = 0
    local cancelled = FX.Task:Delay(0.05, function()
        calls += 100
    end)

    FX.Task:Cancel(cancelled)
    FX.Task:Runtimes(0.02, 3, function()
        calls += 1
    end)

    task.wait(0.3)
    assert(calls == 3, tostring(calls))
end)

Check("shop-pages-items-switch-deferred-refresh-cleanup", function()
    local root = Instance.new("Frame")
    local Item = FX.Class("MigrationShopItem", "ShopItemBaseClass")

    --- @return TextButton 商品节点。
    function Item:CreateRootNode()
        return Instance.new("TextButton")
    end

    --- 更新测试商品标题。
    function Item:Refresh()
        self._rootNode.Text = self._itemConfig.title
    end

    local Page = FX.Class("MigrationShopPage", "ShopPageBaseClass")

    --- @return Frame 商品列表。
    function Page:CreateListNode()
        return Instance.new("Frame", root)
    end

    --- @return table 测试商品配置。
    function Page:GetItemConfigList()
        return { { title = "A" }, { title = "B" } }
    end

    local Shop = FX.Class("MigrationShop", "FCShopUICompClass")

    --- @return table 测试页签。
    function Shop:GetTabConfigList()
        return {
            { PageName = "A", ClassName = "MigrationShopPage", PageItemClassName = "MigrationShopItem" },
            { PageName = "B", ClassName = "MigrationShopPage", PageItemClassName = "MigrationShopItem" },
        }
    end

    --- @param config table 页签配置。
    --- @param page table 页面。
    --- @return TextButton 页签按钮。
    function Shop:CreateTabButton(config, page)
        return Instance.new("TextButton", root)
    end

    --- @param button TextButton 页签按钮。
    --- @param selected boolean 选中状态。
    function Shop:RefreshTabButton(button, selected)
        button:SetAttribute("Selected", selected)
    end

    local shop = Shop.New(owner)
    shop:CreatePages()
    shop:CreateTabs()
    shop:SwitchDefaultPage()
    local a, b = shop._pageMap.A, shop._pageMap.B
    assert(#a._itemList == 2 and #b._itemList == 0)
    local old = a._itemList[1]:GetRootNode()
    a:RefreshNextFrame()
    shop:SwitchPage("B")
    task.wait(0.1)
    assert(old.Parent == nil and #a._itemList == 0 and #b._itemList == 2)
    assert(shop._tabBtnMap.B:GetAttribute("Selected"))
    local node = b._itemList[1]:GetRootNode()
    b:RefreshNextFrame()
    shop:Dtor()
    task.wait(0.1)
    assert(node.Parent == nil and b._refreshTask == nil)
    root:Destroy()
end)

Check("ranking-ui-rpc-empty-list-normalization-and-cleanup", function()
    local root = Instance.new("Frame")
    local tabs, rows = Instance.new("Frame", root), Instance.new("Frame", root)
    local button = Instance.new("TextButton", tabs)
    button.Name = "All"
    local layout = Instance.new("UIListLayout", rows)
    local template = Instance.new("TextLabel", root)
    local Rank = FX.Class("MigrationRankingUI", "FCRankingUICompClass")

    --- @return table 原生节点映射。
    function Rank:GetRankingNodeMap()
        return { rankingTypeListNode = tabs, rankListNode = rows }
    end

    --- @return table 页签配置。
    function Rank:GetRankingTabConfigList()
        return { { tabType = 1, buttonName = "All", tabTitle = "All" } }
    end

    --- @param number number 名次。
    --- @return TextLabel 行模板。
    function Rank:GetRankRowTemplate(number)
        return template
    end

    --- @param tab number 页签。
    function Rank:RefreshHeaderText(tab)
        self.header = tab
    end

    --- @param node TextLabel 行节点。
    --- @param data table 排名。
    function Rank:RefreshRankRowNode(node, data)
        node.Text = tostring(data.rankScore)
    end

    --- 更新自己的排名显示。
    function Rank:RefreshMyRankData()
        self.displayedScore = self._myScore
    end

    local rank = Rank.New(owner)
    rank:OnShow()
    assert(#rank._rankRows == 0 and rank.header == 1)
    rank._rankRows = rank:NormalizeRankingRows({ { rankNo = "2", playerId = "123", rankScore = "50" } })
    rank:RefreshRankList()
    assert(#rank._rowNodes == 1 and rank._rowNodes[1].Text == "50")
    rank:Dtor()
    assert(#rows:GetChildren() == 1 and layout.Parent == rows)
    root:Destroy()
end)

Check("guide-enter-exit-arrow-and-model-tween-cleanup", function()
    local Guide = FX.Class("MigrationClientGuide", "FCTutorialGuideCompClass")

    --- @param target table 引导目标。
    function Guide:OnEnterGuide(target)
        self.entered = target.type
    end

    --- @param target table 引导目标。
    function Guide:OnExitGuide(target)
        self.exited = target.type
    end

    local guide = Guide.New(owner)
    guide:OnGuideDataChanged({ target = { type = "Test" } })
    guide:OnGuideDataChanged({ target = { type = "None" } })
    assert(guide.entered == "Test" and guide.exited == "Test")
    guide:ShowGuideArrowToPosition(Vector3.new(20, 10, 20))
    task.wait(0.1)
    local arrow, connection = guide._arrowTrans, guide._renderSteppedConn
    assert(arrow.Parent == workspace and not arrow.CanCollide)
    guide:Dtor()
    assert(arrow.Parent == nil and not connection.Connected)
    local part = Instance.new("Part", workspace)
    part.Anchored = true
    local anim = FX.ModelAnimationCompClass.New(owner)
    anim:MoveToTransform(part, Vector3.new(10, 50, 10), Vector3.zero, 0.02)
    task.wait(0.15)
    assert((part.Position - Vector3.new(10, 50, 10)).Magnitude < 0.01)
    anim:PlayFloat(part, 2, 0.05)
    task.wait(0.03)
    anim:Dtor()
    assert((part.Position - Vector3.new(10, 50, 10)).Magnitude < 0.01)
    part:Destroy()
end)

-- 保留输入夹具直到 MCP 发出 Cleanup 属性；通过真实鼠标和键盘事件检验。
local gui = Instance.new("ScreenGui")
gui.Name = "FrameworkInputMCP"
gui.IgnoreGuiInset = true
gui.DisplayOrder = 1000
gui.ResetOnSpawn = false
gui.Parent = game.Players.LocalPlayer.PlayerGui
local source, destination, button =
    Instance.new("TextButton", gui), Instance.new("TextButton", gui), Instance.new("TextButton", gui)
source.Name, destination.Name, button.Name = "Source", "Destination", "Hold"
source.Text, destination.Text, button.Text = "Drag source", "Drop target", "Hold"
for i, node in ipairs({ source, destination, button }) do
    node.Size = UDim2.fromOffset(120, 70)
    local viewport = workspace.CurrentCamera.ViewportSize
    node.Position = UDim2.fromOffset(viewport.X / 2 - 220 + (i - 1) * 150, viewport.Y - 150)
end

local drag = FC.DragObjectClass.New(gui)
drag:SetDraggable(source, 9)
drag:SetDestination(destination, 10)
drag:SetDragFinished(function(from, to, data, targetData)
    gui:SetAttribute("DragPassed", from == source and to == destination and data == 9 and targetData == 10)
end)

local hold = FC.HoldUIObjectClass.New(button)
hold:SetHoldDuration(0.3)
hold:SetHoldCompleteCallback(function()
    gui:SetAttribute("HoldPassed", true)
end)

hold:SetHoldCancelCallback(function()
    gui:SetAttribute("HoldCancelPassed", true)
end)

local key = FC.KeyObjectClass.New(Enum.KeyCode.F)
key:SetHoldDuration(0.3)
key:SetHoldCompleteCallback(function()
    gui:SetAttribute("KeyPassed", true)
end)

key:SetHoldCancelCallback(function()
    gui:SetAttribute("KeyCancelPassed", true)
end)

gui:GetAttributeChangedSignal("Cleanup"):Connect(function()
    drag:Dtor()
    hold:Dtor()
    key:Dtor()
    gui:Destroy()
end)

return results
