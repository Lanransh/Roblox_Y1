local FX, FC, MS = _G.FX, _G.FC, _G.MS
local FXNetwork = FX.Network
local FXTable = FX.Table
local UserInputService = game:GetService("UserInputService")

local FCInventoryCompClass = FX.Class("FCInventoryCompClass", "FCUICompClass")

--- 构建客户端背包 UI 通用能力，统一承接筛选、排序、拖拽和使用道具主流程。
---@param owner table 玩家对象，供组件注册网络消息与组件协作使用。
---@return nil
function FCInventoryCompClass:Ctor(owner)
    FCInventoryCompClass.Super.Ctor(self, owner)
    self._inventoryData = {}
    self._backpackRows, self._rowConnections, self._shortcutRows = {}, {}, {}
    self._backpackData = {}
    self._virtualIndexToGridIndex = {}
    self._tabNodeMap = {}
    self._selectedShortcutNode = nil
    self._selectedShortcutIndex = nil
    self._selectedBackpackGridNode = nil
    self._selectedBackpackGridIndex = nil
    self._inputConnection = nil
    self._filterType = nil
    self._listNodeMap = self:GetInventoryListNodeMap()
    self._dragObject = FC.DragObjectClass.New(self:GetDragParentNode())
    self._touchObject = FC.TouchObjectClass.New()
    self._dragObject:SetDragOffset(3, 3)
    self._dragObject:SetEnabled(false)
    self._dragObject:SetDragFinished(function(dragNode, destNode, dragGridIndex, destDragIndex)
        self:OnSwapGrid(dragNode, destNode, dragGridIndex, destDragIndex)
    end)
    self:_InitTouchCallbacks()
    self:_InitShortcutList()
    self:_InitBackpackList()
    self:_InitFilterTabList()
    self:_InitKeyboardInput()
    self:_InitNetworkCallbacks()
end

--- 释放输入监听与拖拽对象，避免组件销毁后继续响应全局输入。
---@return nil
function FCInventoryCompClass:Dtor()
    if self._inputConnection then
        self._inputConnection:Disconnect()
        self._inputConnection = nil
    end
    if self._touchObject then
        self._touchObject:Dtor()
        self._touchObject = nil
    end
    if self._dragObject then
        self._dragObject:Dtor()
        self._dragObject = nil
    end
    for _, connection in pairs(self._rowConnections) do
        connection:Disconnect()
    end
    for _, node in ipairs(self._backpackRows) do
        node:Destroy()
    end
    for _, node in ipairs(self._shortcutRows) do
        node:Destroy()
    end
    for _, node in pairs(self._tabNodeMap) do
        node:Destroy()
    end
    FCInventoryCompClass.Super.Dtor(self)
end

--- 返回组件名，保持对外协作入口稳定。
---@return string
function FCInventoryCompClass:GetCompName()
    return "InventoryUI"
end

--- 返回快捷栏容量；延迟到运行时读取，避免框架初始化阶段 `GameEnum` 尚未注册。
---@return number
function FCInventoryCompClass:GetShortcutCapacity()
    return require(game.ReplicatedStorage.Shared.Config.FrameworkConfig).ShortcutCapacity
end

--- 返回背包容量；延迟到运行时读取，避免框架初始化阶段 `GameEnum` 尚未注册。
---@return number
function FCInventoryCompClass:GetInventoryCapacity()
    return require(game.ReplicatedStorage.Shared.Config.FrameworkConfig).InventoryCapacity
end

--- 返回总容量，统一复用快捷栏与背包容量计算。
---@return number
function FCInventoryCompClass:GetTotalCapacity()
    return self:GetShortcutCapacity() + self:GetInventoryCapacity()
end

--- 返回背包组件依赖的全部节点映射。
--- 约定结构如下：
--- {
---     backpack = {
---         listNode = UIList,        -- 背包虚拟列表
---         templateNode = UIComponent, -- 背包格子模板
---     },
---     shortcut = {
---         listNode = UIComponent,   -- 快捷栏列表父节点
---         templateNode = UIComponent, -- 快捷栏格子模板
---     },
---     filter = {
---         listNode = UIComponent,   -- 筛选按钮列表父节点；没有筛选区时可传 nil
---         templateNode = UIComponent, -- 筛选按钮模板；没有筛选区时可传 nil
---     },
---     dragParentNode = UIComponent, -- 拖拽克隆体挂载父节点；不传时默认使用 shortcut.listNode.Parent
--- }
--- 约束：
--- 1. `backpack.listNode/templateNode` 必填。
--- 2. `shortcut.listNode/templateNode` 必填。
--- 3. `GetFilterTabConfigList()` 返回非空时，`filter.listNode/templateNode` 必填，且 `templateNode` 必须是按钮类型。
--- 4. `dragParentNode` 推荐显式传入，避免拖拽克隆体挂载层级错误。
---@return table
function FCInventoryCompClass:GetInventoryListNodeMap()
    error("FCInventoryCompClass:GetInventoryListNodeMap() is not implemented")
end

--- 刷新背包格子节点显示。
---@param backpackIndex number 背包可见列表下标。
---@param gridIndex number 真实格子下标。
---@param node UIComponent 背包格子节点。
---@return nil
function FCInventoryCompClass:RefreshBackpackGridNode(backpackIndex, gridIndex, node)
    error("FCInventoryCompClass:RefreshBackpackGridNode() is not implemented")
end

--- 响应背包格子被选中，由子类刷新详情区或附加表现。
---@param selectContext table 包含 oldNode/oldIndex/newNode/newIndex 的选中上下文。
---@return nil
function FCInventoryCompClass:OnSelectBackpackGrid(selectContext)
    error("FCInventoryCompClass:OnSelectBackpackGrid() is not implemented")
end

--- 刷新快捷栏格子节点显示。
---@param shortcutIndex number 快捷栏下标。
---@param node UIComponent 快捷栏格子节点。
---@return nil
function FCInventoryCompClass:RefreshShortcutGridNode(shortcutIndex, node)
    error("FCInventoryCompClass:RefreshShortcutGridNode() is not implemented")
end

--- 返回筛选 Tab 配置列表；空表表示该背包没有筛选区。
---@return table
function FCInventoryCompClass:GetFilterTabConfigList()
    return {}
end

--- 判断格子是否命中当前筛选规则。
---@param gridData table 格子数据。
---@param gridIndex number 真实格子下标。
---@param filterType string 当前筛选类型。
---@return boolean
function FCInventoryCompClass:IsGridDataMatchFilter(gridData, gridIndex, filterType)
    if gridData == nil or gridData.itemId == nil then
        return false
    end
    return true
end

--- 比较两个背包显示条目的排序先后；默认按 itemId 升序、再按 gridIndex 升序。
---@param lhs table 左侧背包显示条目。
---@param rhs table 右侧背包显示条目。
---@return boolean
function FCInventoryCompClass:CompareBackpackGridForSort(lhs, rhs)
    local lhsItemId = lhs.itemId or -1
    local rhsItemId = rhs.itemId or -1
    if lhsItemId ~= rhsItemId then
        return lhsItemId < rhsItemId
    end
    return (lhs.gridIndex or 0) < (rhs.gridIndex or 0)
end

--- 当背包选中态被基类清空时通知子类同步清空详情区。
---@return nil
function FCInventoryCompClass:OnBackpackSelectionCleared() end

--- 返回项目级使用道具扩展处理表。
---@return table
function FCInventoryCompClass:GetItemUseHandlers()
    return {}
end

--- 返回拖拽克隆体的父节点，默认沿用当前列表映射里的快捷栏父节点。
---@return UIComponent
function FCInventoryCompClass:GetDragParentNode()
    if self._listNodeMap ~= nil and self._listNodeMap.dragParentNode ~= nil then
        return self._listNodeMap.dragParentNode
    end
    local shortcutNodeInfo = self._listNodeMap and self._listNodeMap.shortcut
    if shortcutNodeInfo ~= nil and shortcutNodeInfo.listNode ~= nil then
        return shortcutNodeInfo.listNode.Parent
    end
    error("FCInventoryCompClass:GetDragParentNode() failed, shortcut list node is missing")
end

--- 初始化统一触摸结束回调，保留当前从右半屏松手触发快捷栏使用的行为。
---@return nil
function FCInventoryCompClass:_InitTouchCallbacks()
    self._touchObject:SetTouchEndedCallback(function(x, y, touchId)
        if x < workspace.CurrentCamera.ViewportSize.X / 2 then
            return
        end
        self:OnUseItem(self._selectedShortcutIndex)
    end)
end

--- 初始化快捷栏固定格子，注册点击与拖拽目标。
---@return nil
function FCInventoryCompClass:_InitShortcutList()
    local shortcutListNode = self:_GetShortcutListNode()
    local shortcutTemplateNode = self:_GetShortcutTemplateNode()
    shortcutTemplateNode.Visible = false
    for shortcutIndex = 1, self:GetShortcutCapacity() do
        local gridNode = shortcutTemplateNode:Clone()
        gridNode.Name = string.format("ShortcutGrid_%d", shortcutIndex)
        gridNode.Visible = true
        gridNode.Parent = shortcutListNode
        self:TrackConnection(gridNode.Activated:Connect(function()
            self:OnShortcutGridClicked(shortcutIndex)
        end))
        gridNode.LayoutOrder = shortcutIndex
        self._shortcutRows[shortcutIndex] = gridNode
        self._dragObject:SetDestination(gridNode, shortcutIndex)
    end
end

--- 初始化背包虚拟列表，统一管理点击和拖拽重绑。
---@return nil
function FCInventoryCompClass:_InitBackpackList()
    self:_GetBackpackTemplateNode().Visible = false
    self._dragObject:SetDestination(self:_GetBackpackListNode(), nil)
end

--- 初始化过滤列表；若派生类未提供配置则跳过。
---@return nil
function FCInventoryCompClass:_InitFilterTabList()
    local filterTabConfigList = self:GetFilterTabConfigList()
    if #filterTabConfigList <= 0 then
        return
    end
    self._filterType = filterTabConfigList[1].filterType
    local filterNodeInfo = self:_GetFilterNodeInfo()
    local tabListNode = filterNodeInfo.listNode
    local tabTemplateNode = filterNodeInfo.templateNode
    tabTemplateNode.Visible = false
    self._tabNodeMap = {}
    for tabIndex = 1, #filterTabConfigList do
        local tabConfig = filterTabConfigList[tabIndex]
        local tabNode = tabTemplateNode:Clone()
        tabNode.Name = string.format("FilterTab_%s", tostring(tabConfig.filterType))
        tabNode.Parent = tabListNode
        tabNode.Visible = true
        tabNode.Text = tabConfig.title
        self:TrackConnection(tabNode.Activated:Connect(function()
            self:OnFilterTabClicked(tabConfig.filterType)
        end))
        self._tabNodeMap[tabConfig.filterType] = tabNode
    end
    self:RefreshFilterTabState()
end

--- 初始化全局键盘监听，保持数字键切换快捷栏行为不变。
---@return nil
function FCInventoryCompClass:_InitKeyboardInput()
    if self._inputConnection then
        self._inputConnection:Disconnect()
        self._inputConnection = nil
    end
    self._inputConnection = UserInputService.InputBegan:Connect(function(inputObj, gameProcessed)
        if gameProcessed or inputObj.UserInputType ~= Enum.UserInputType.Keyboard then
            return
        end
        local shortcutIndex = inputObj.KeyCode.Value - Enum.KeyCode.One.Value + 1
        if shortcutIndex < 1 or shortcutIndex > self:GetShortcutCapacity() then
            return
        end
        self:OnShortcutGridClicked(shortcutIndex)
    end)
end

--- 初始化背包网络消息监听。
---@return nil
function FCInventoryCompClass:_InitNetworkCallbacks()
    self:SubscribeEvent("InventorySnapshot", self.OnInventoryData)
    self:OnInventoryData(self:GetPlayerObject()._inventoryData)
end

--- 获取背包列表节点。
---@return UIList
function FCInventoryCompClass:_GetBackpackListNode()
    local backpackNodeInfo = self._listNodeMap.backpack
    if backpackNodeInfo == nil or backpackNodeInfo.listNode == nil then
        error("FCInventoryCompClass:_GetBackpackListNode() failed, backpack list node is missing")
    end
    return backpackNodeInfo.listNode
end

--- 获取背包格子模板节点，并校验节点映射完整。
---@return UIComponent
function FCInventoryCompClass:_GetBackpackTemplateNode()
    local backpackNodeInfo = self._listNodeMap.backpack
    if backpackNodeInfo == nil or backpackNodeInfo.templateNode == nil then
        error("FCInventoryCompClass:_GetBackpackTemplateNode() failed, backpack template node is missing")
    end
    return backpackNodeInfo.templateNode
end

--- 获取快捷栏列表节点。
---@return UIComponent
function FCInventoryCompClass:_GetShortcutListNode()
    local shortcutNodeInfo = self._listNodeMap.shortcut
    if shortcutNodeInfo == nil or shortcutNodeInfo.listNode == nil then
        error("FCInventoryCompClass:_GetShortcutListNode() failed, shortcut list node is missing")
    end
    return shortcutNodeInfo.listNode
end

--- 获取快捷栏格子模板节点，并校验节点映射完整。
---@return UIComponent
function FCInventoryCompClass:_GetShortcutTemplateNode()
    local shortcutNodeInfo = self._listNodeMap.shortcut
    if shortcutNodeInfo == nil or shortcutNodeInfo.templateNode == nil then
        error("FCInventoryCompClass:_GetShortcutTemplateNode() failed, shortcut template node is missing")
    end
    return shortcutNodeInfo.templateNode
end

--- 获取筛选列表节点信息。
---@return table
function FCInventoryCompClass:_GetFilterNodeInfo()
    local filterNodeInfo = self._listNodeMap.filter
    if filterNodeInfo == nil or filterNodeInfo.listNode == nil or filterNodeInfo.templateNode == nil then
        error("FCInventoryCompClass:_GetFilterNodeInfo() failed, filter node info is missing")
    end
    return filterNodeInfo
end

--- 获取默认筛选类型；没有筛选配置时返回 nil。
---@return string|nil
function FCInventoryCompClass:_GetDefaultFilterType()
    local filterTabConfigList = self:GetFilterTabConfigList()
    if #filterTabConfigList <= 0 then
        return nil
    end
    return filterTabConfigList[1].filterType
end

--- 刷新筛选 Tab 选中态；没有筛选区时直接跳过。
---@return nil
function FCInventoryCompClass:RefreshFilterTabState()
    if next(self._tabNodeMap) == nil then
        return
    end
    for filterType, tabNode in pairs(self._tabNodeMap) do
        local isSelected = self._filterType == filterType
        tabNode:SetAttribute("Selected", isSelected)
        self:RefreshFilterTabNodeState(tabNode, isSelected)
    end
end

--- 提供筛选 Tab 的默认选中样式；子类可覆写增强视觉表现。
---@param tabNode UIComponent 过滤按钮节点。
---@param isSelected boolean 当前是否选中。
---@return nil
function FCInventoryCompClass:RefreshFilterTabNodeState(tabNode, isSelected)
    tabNode:SetAttribute("Selected", isSelected)
end

--- 点击筛选项后重建显示列表并刷新容量与选中态。
---@param filterType string 点击的筛选类型。
---@return nil
function FCInventoryCompClass:OnFilterTabClicked(filterType)
    if self._filterType == filterType then
        return
    end
    self._filterType = filterType
    self:RebuildBackpackData()
    self:RefreshCapacityText()
    self:RefreshBackpackListView()
    self:RefreshSelectedBackpackStateAfterDataChanged()
    self:RefreshFilterTabState()
end

--- 全量同步背包数据后统一刷新显示与对外事件。
---@param allGridData table 服务端下发的全量格子数据。
---@return nil
function FCInventoryCompClass:OnInventoryData(allGridData)
    local normalized = {}
    for key, value in pairs(allGridData) do
        normalized[tonumber(key)] = value
    end
    self._inventoryData = normalized
    self:RebuildBackpackData()
    self:RefreshCapacityText()
    self._selectedBackpackGridNode = nil
    self:RefreshSelectedBackpackStateAfterDataChanged()
    self:RefreshBackpackListView()
    self:RefreshShortcutListView()
    self:PublishEvent("InventoryDataChanged", self._inventoryData)
end

--- 增量同步格子数据后，复用全量刷新流程统一收口。
---@param changedGridDataList table 增量格子数组。
---@return nil
function FCInventoryCompClass:OnInventoryGridsChanged(changedGridDataList)
    for dataIndex = 1, #(changedGridDataList or {}) do
        local changedGridData = changedGridDataList[dataIndex]
        self._inventoryData[changedGridData.gridIndex] = changedGridData.gridData
    end
    self:OnInventoryData(self._inventoryData)
end

--- 重建背包显示数据，并在筛选后按当前比较函数排序。
---@return nil
function FCInventoryCompClass:RebuildBackpackData()
    self._backpackData = {}
    for gridIndex = self:GetShortcutCapacity() + 1, self:GetTotalCapacity() do
        local gridData = self._inventoryData[gridIndex]
        if self:IsGridDataMatchFilter(gridData, gridIndex, self._filterType) then
            local gridDataCopy = FXTable:DeepCopy(gridData)
            gridDataCopy.gridIndex = gridIndex
            self._backpackData[#self._backpackData + 1] = gridDataCopy
        end
    end
    self:SortBackpackDataIfNeeded()
    self._virtualIndexToGridIndex = {}
    for backpackIndex = 1, #self._backpackData do
        self._virtualIndexToGridIndex[backpackIndex] = self._backpackData[backpackIndex].gridIndex
    end
end

--- 对背包显示列表做客户端排序，不改真实格子数据。
---@return nil
function FCInventoryCompClass:SortBackpackDataIfNeeded()
    table.sort(self._backpackData, function(lhs, rhs)
        return self:CompareBackpackGridForSort(lhs, rhs)
    end)
end

--- 刷新背包虚拟列表数量，驱动列表重绘。
---@return nil
function FCInventoryCompClass:RefreshBackpackListView()
    local count = #self._backpackData
    for index = #self._backpackRows, count + 1, -1 do
        local node = self._backpackRows[index]
        self._dragObject:ClearDraggable(node)
        self._dragObject:ClearDestination(node)
        self._rowConnections[index]:Disconnect()
        self._rowConnections[index] = nil
        node:Destroy()
        self._backpackRows[index] = nil
    end
    for index = 1, count do
        local gridIndex = self._virtualIndexToGridIndex[index]
        local node = self._backpackRows[index]
        if not node then
            node = self:_GetBackpackTemplateNode():Clone()
            node.Parent = self:_GetBackpackListNode()
            node.Visible = true
            node.LayoutOrder = index
            self._backpackRows[index] = node
        end
        if self._rowConnections[index] then
            self._rowConnections[index]:Disconnect()
        end
        self._rowConnections[index] = node.Activated:Connect(function()
            self:OnBackpackGridClicked(node, gridIndex)
        end)
        self:RefreshBackpackGridNode(index, gridIndex, node)
        self._dragObject:SetDestination(node, gridIndex)
        self._dragObject:SetDraggable(node, gridIndex)
        if self._selectedBackpackGridIndex == gridIndex then
            self._selectedBackpackGridNode = node
        end
    end
end

--- 刷新快捷栏所有格子的显示内容。
---@return nil
function FCInventoryCompClass:RefreshShortcutListView()
    local shortcutChildren = self._shortcutRows
    for shortcutIndex = 1, self:GetShortcutCapacity() do
        self:RefreshShortcutGridNode(shortcutIndex, shortcutChildren[shortcutIndex])
    end
end

--- 处理快捷栏点击，更新选中态并同步手持格索引。
---@param shortcutIndex number 快捷栏下标。
---@return nil
function FCInventoryCompClass:OnShortcutGridClicked(shortcutIndex)
    if shortcutIndex < 1 or shortcutIndex > self:GetShortcutCapacity() then
        return
    end
    local shortcutNode = self:_GetShortcutListNode():FindFirstChild(string.format("ShortcutGrid_%d", shortcutIndex))
    if shortcutNode == nil then
        return
    end
    self:OnSelectShortcutGrid({
        oldNode = self._selectedShortcutNode,
        oldIndex = self._selectedShortcutIndex,
        newNode = shortcutNode,
        newIndex = shortcutIndex,
    })
    self._selectedShortcutIndex = shortcutIndex
    self._selectedShortcutNode = shortcutNode
end

--- 切换快捷栏选中格并同步服务端手持格状态。
---@param selectContext table 包含 oldNode/oldIndex/newNode/newIndex 的选中上下文。
---@return nil
function FCInventoryCompClass:OnSelectShortcutGrid(selectContext)
    if selectContext.oldNode then
        selectContext.oldNode.SelectedIcon.Visible = false
    end
    if selectContext.newNode then
        selectContext.newNode.SelectedIcon.Visible = true
    end
    FXNetwork:SendMsgToServer("C2S_SetHeldGridIndex", selectContext.newIndex)
end

--- 统一处理背包格点击，刷新基类选中态后通知子类。
---@param node UIComponent 被点击的背包格节点。
---@param gridIndex number 被点击的真实格子下标。
---@return nil
function FCInventoryCompClass:OnBackpackGridClicked(node, gridIndex)
    local selectContext = {
        oldNode = self._selectedBackpackGridNode,
        oldIndex = self._selectedBackpackGridIndex,
        newNode = node,
        newIndex = gridIndex,
    }
    self._selectedBackpackGridNode = node
    self._selectedBackpackGridIndex = gridIndex
    self:OnSelectBackpackGrid(selectContext)
end

--- 数据刷新或筛选切换后修正当前选中格，避免详情面板残留旧数据。
---@return nil
function FCInventoryCompClass:RefreshSelectedBackpackStateAfterDataChanged()
    local selectedGridIndex = self._selectedBackpackGridIndex
    if selectedGridIndex == nil then
        self:OnBackpackSelectionCleared()
        return
    end
    local gridData = self._inventoryData[selectedGridIndex]
    if gridData == nil or gridData.itemId == nil or not self:IsBackpackGridVisible(selectedGridIndex) then
        self._selectedBackpackGridIndex = nil
        self._selectedBackpackGridNode = nil
        self:OnBackpackSelectionCleared()
        return
    end
    self:OnSelectBackpackGrid({
        oldNode = self._selectedBackpackGridNode,
        oldIndex = self._selectedBackpackGridIndex,
        newNode = self._selectedBackpackGridNode,
        newIndex = selectedGridIndex,
    })
end

--- 获取背包区首个空格子下标，拖拽到空白区时复用该逻辑结算。
---@return number|nil
function FCInventoryCompClass:GetEmptyBackpackGridIndex()
    for gridIndex = self:GetShortcutCapacity() + 1, self:GetTotalCapacity() do
        local gridData = self._inventoryData[gridIndex]
        if gridData == nil or gridData.itemId == nil or gridData.itemId <= 0 then
            return gridIndex
        end
    end
    return nil
end

--- 获取快捷栏首个空格子下标，供详情区“加入快捷栏”复用。
---@return number|nil
function FCInventoryCompClass:GetEmptyShortcutGridIndex()
    for gridIndex = 1, self:GetShortcutCapacity() do
        local gridData = self._inventoryData[gridIndex]
        if gridData == nil or gridData.itemId == nil or gridData.itemId <= 0 then
            return gridIndex
        end
    end
    return nil
end

--- 判断某个真实背包格子当前是否处于可见列表中。
---@param gridIndex number 真实格子下标。
---@return boolean
function FCInventoryCompClass:IsBackpackGridVisible(gridIndex)
    for backpackIndex = 1, #self._virtualIndexToGridIndex do
        if self._virtualIndexToGridIndex[backpackIndex] == gridIndex then
            return true
        end
    end
    return false
end

--- 点击“加入快捷栏”时优先填入首个空快捷栏格子。
---@return nil
function FCInventoryCompClass:OnAddToShortcutBtnClicked()
    local backpackGridIndex = self._selectedBackpackGridIndex
    if backpackGridIndex == nil then
        return
    end
    local emptyShortcutGridIndex = self:GetEmptyShortcutGridIndex()
    if emptyShortcutGridIndex == nil then
        self:OnNoShortcutSlotAvailable()
        return
    end
    FXNetwork:SendMsgToServer("C2S_SwapGrid", backpackGridIndex, emptyShortcutGridIndex)
end

--- 当没有可用快捷栏空位时留给子类刷新按钮态。
---@return nil
function FCInventoryCompClass:OnNoShortcutSlotAvailable() end

--- 拖拽交换格子；若拖到背包空白区则自动落到首个空背包格。
---@param dragNode UIComponent 拖拽源节点。
---@param destNode UIComponent 目标节点。
---@param dragGridIndex number 拖拽源真实格子下标。
---@param destDragIndex number|nil 目标真实格子下标。
---@return nil
function FCInventoryCompClass:OnSwapGrid(dragNode, destNode, dragGridIndex, destDragIndex)
    if dragGridIndex == destDragIndex then
        return
    end
    local nextDestGridIndex = destDragIndex
    if nextDestGridIndex == nil then
        nextDestGridIndex = self:GetEmptyBackpackGridIndex()
        if nextDestGridIndex == nil then
            return
        end
    end
    FXNetwork:SendMsgToServer("C2S_SwapGrid", dragGridIndex, nextDestGridIndex)
end

--- 使用当前快捷栏道具；优先走子类 handler，未命中时走默认协议。
---@param shortcutIndex number 快捷栏格子下标。
---@param skipConfirmDialog boolean|nil 是否跳过本地确认弹窗。
---@return nil
function FCInventoryCompClass:OnUseItem(shortcutIndex, skipConfirmDialog)
    if shortcutIndex == nil then
        return
    end
    local gridData = self._inventoryData[shortcutIndex]
    if gridData == nil then
        return
    end
    local itemId = gridData.itemId or -1
    local itemDataConfig = _G.Provider:GetItemDataConfig(itemId)
    if itemDataConfig == nil or itemDataConfig.UseHandler == nil then
        return
    end
    local itemHandlers = self:GetItemUseHandlers()
    local itemHandler = itemHandlers[itemDataConfig.UseHandler]
    if itemHandler ~= nil then
        itemHandler(self, {
            shortcutIndex = shortcutIndex,
            itemDataConfig = itemDataConfig,
            skipConfirmDialog = skipConfirmDialog == true,
        })
        return
    end
    FXNetwork:SendMsgToServer("C2S_UseItem", shortcutIndex, 1)
end

--- 返回指定格子的客户端缓存数据。
---@param gridIndex number 真实格子下标。
---@return table
function FCInventoryCompClass:GetGridDataByIndex(gridIndex)
    return self._inventoryData[gridIndex]
end

--- 返回客户端缓存的全部格子数据。
---@return table
function FCInventoryCompClass:GetAllGridData()
    return self._inventoryData
end

--- 统计客户端缓存中的指定道具总数量。
---@param itemId number 道具ID。
---@return number
function FCInventoryCompClass:GetItemCountById(itemId)
    local totalCount = 0
    for gridIndex = 1, self:GetTotalCapacity() do
        local gridData = self._inventoryData[gridIndex]
        if gridData ~= nil and gridData.itemId == itemId then
            totalCount = totalCount + (gridData.stackCount or 0)
        end
    end
    return totalCount
end

--- 刷新容量文案，默认留空由子类按项目 UI 布局实现。
---@return nil
function FCInventoryCompClass:RefreshCapacityText() end

--- 打开背包时重置筛选、刷新显示列表并启用拖拽。
---@return nil
function FCInventoryCompClass:ShowInvertory()
    local defaultFilterType = self:_GetDefaultFilterType()
    self._filterType = defaultFilterType
    self:RebuildBackpackData()
    self:RefreshCapacityText()
    self:RefreshSelectedBackpackStateAfterDataChanged()
    self:RefreshFilterTabState()
    self:RefreshBackpackListView()
    self._dragObject:SetEnabled(true)
end

--- 关闭背包时清空背包选中态并禁用拖拽。
---@return nil
function FCInventoryCompClass:HideInvertory()
    self._selectedBackpackGridNode = nil
    self._selectedBackpackGridIndex = nil
    self._dragObject:SetEnabled(false)
    self:OnBackpackSelectionCleared()
end

return FCInventoryCompClass
