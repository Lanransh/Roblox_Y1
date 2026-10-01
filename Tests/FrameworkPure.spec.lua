-- 由 Tools/run_framework_pure_tests.py 与原始模块一起装入局部命名空间；不模拟 Roblox 服务。
local FX = _G.FX
local count = 0
--- @param name string 测试行为。
--- @param callback function 纯逻辑断言。
local function Check(name, callback)
    callback()
    count += 1
    print("PASS", name)
end
Check("class inheritance and implicit base lifecycle", function()
    local Base = FX.Class("TestBase")
    function Base:Ctor(value)
        self.value = value
    end
    function Base:Dtor()
        self.destroyed = true
    end
    local Derived = FX.Class("TestDerived", "TestBase")
    local object = Derived.New(42)
    assert(object.value == 42 and object:IsA("TestBase") and object:IsA("TestDerived"))
    object:Dtor()
    assert(object.destroyed)
    assert(not pcall(FX.Class, "TestDerived"))
end)
Check("unpack preserves nil and explicit boundaries", function()
    local result = table.pack(FX.Table:Unpack({ [1] = false, [3] = 7, n = 4 }))
    assert(result.n == 4 and result[1] == false and result[2] == nil and result[3] == 7)
    local middle = table.pack(FX.Table:Unpack({ 1, 2, 3, 4 }, 2, 3))
    assert(middle.n == 2 and middle[1] == 2 and middle[2] == 3)
end)
Check("table copies keep sparse keys and false independent", function()
    local source = { ["58"] = { flag = false } }
    local clone = FX.Table:DeepCopy(source)
    clone["58"].flag = true
    assert(source["58"].flag == false)
    assert(FX.Table:DeepCopy(nil) == nil)
end)
Check("week boundary across month and year", function()
    local sunday = os.time({ year = 2023, month = 1, day = 1, hour = 13 })
    local monday = os.time({ year = 2022, month = 12, day = 26, hour = 0 })
    assert(FX.Time:GetWeekStartTimeStamp(sunday) == monday)
    assert(FX.Time:GetNextMondayMidnightTimeStamp(sunday) == monday + 7 * 86400)
    assert(not FX.Time:IsSameMonth(sunday, monday))
end)
print(string.format("%d pure framework tests passed", count))
