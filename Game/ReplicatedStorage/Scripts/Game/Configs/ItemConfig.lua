return {
    Data = {
        [1001] = {
            Id = 1001, Type = "DemoTool", MaxStack = 1, UseHandler = "DemoTool",
            Name = "测试方块", ToolShape = "Block", ToolColor = Color3.fromRGB(49, 160, 255),
        },
        [1002] = {
            Id = 1002, Type = "DemoTool", MaxStack = 10, UseHandler = "DemoTool",
            Name = "测试球", ToolShape = "Ball", ToolColor = Color3.fromRGB(255, 178, 55),
        },
        [1003] = {
            Id = 1003, Type = "RockCollectible", MaxStack = 1,
            Name = "石头收藏品",
        },
    },
    Display = {},
    ExtraDataSchema = {
        RockCollectible = { TemplateName = "", Price = 0 },
        Animal = {
            level = 1,
            mutationExp = 1,
            size = 1,
            sizeMutationPityCount = 0
        }
    }
}
