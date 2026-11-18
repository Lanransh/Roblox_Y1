local FX = _G.FX
local CRockTreasureLoadingConceptPreview = FX.Class("CRockTreasureLoadingConceptPreview", "CRockTreasureLoadingConceptView")

-- 准备编辑器展示数据；不加载真实游戏资源。
-- @param owner table，编辑器组件宿主
function CRockTreasureLoadingConceptPreview:Ctor(owner)
    CRockTreasureLoadingConceptPreview.Super.Ctor(self, owner)
    self.Config = {}
    self.State = {
        current = 68,
        target = 100,
    }
end

-- 父方法先绑定节点，再显示英文回退与示例进度。
function CRockTreasureLoadingConceptPreview:OnReady()
    CRockTreasureLoadingConceptPreview.Super.OnReady(self)
    self:Show()
end

-- 模拟跳过后等待必要进入条件。
-- @param action string 页面发送的 Skip 动作。
-- @param payload table 空表，无业务参数。
function CRockTreasureLoadingConceptPreview:OnUIAction(action, payload)
    assert(action == "Skip", "Unsupported action")
    self.State.skipRequested = true
    self.State.status = "Waiting"
    self:RefreshUI()
end
return CRockTreasureLoadingConceptPreview

