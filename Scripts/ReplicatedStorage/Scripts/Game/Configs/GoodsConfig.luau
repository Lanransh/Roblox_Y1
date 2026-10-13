return {
    -- DevGoodsId 为业务 ID；RobloxProductId 配置真实 Developer Product ID 后才开放购买。
    GoodsData = {
        [100] = {DevGoodsId = 100, RobloxProductId = 0, BuyHandler = "AddGem", Price = 3, BuyLimit = 1, NumberArray = {48}},
        [101] = {DevGoodsId = 101, RobloxProductId = 0, BuyHandler = "AddGem", Price = 19, NumberArray = {152}},
        [102] = {DevGoodsId = 102, RobloxProductId = 0, BuyHandler = "AddGem", Price = 69, NumberArray = {618}},
        [103] = {DevGoodsId = 103, RobloxProductId = 0, BuyHandler = "AddGem", Price = 169, NumberArray = {1698}},
        [111] = {DevGoodsId = 111, RobloxProductId = 0, BuyHandler = "AddItem", Price = 18, KVTable = {ItemId = 101, Count = 1}},
        [112] = {DevGoodsId = 112, RobloxProductId = 0, BuyHandler = "AddItem", Price = 68, KVTable = {ItemId = 102, Count = 1}},
    },
    -- 沿用 Studio_Y3 的价格；当前版本训练倍率最高第 9 档（512 倍）。
    MaxTrainingRateLevel = 9,
    GemGoodsData = {
        [150] = {GemGoodsId = 150, BuyHandler = "TrainingRateLevel", Price = 28},
        [151] = {GemGoodsId = 151, BuyHandler = "TrainingRateLevel", Price = 38},
        [152] = {GemGoodsId = 152, BuyHandler = "TrainingRateLevel", Price = 48},
        [153] = {GemGoodsId = 153, BuyHandler = "TrainingRateLevel", Price = 78},
        [154] = {GemGoodsId = 154, BuyHandler = "TrainingRateLevel", Price = 228},
        [155] = {GemGoodsId = 155, BuyHandler = "TrainingRateLevel", Price = 418},
        [156] = {GemGoodsId = 156, BuyHandler = "TrainingRateLevel", Price = 758},
        [157] = {GemGoodsId = 157, BuyHandler = "TrainingRateLevel", Price = 1498},
        [158] = {GemGoodsId = 158, BuyHandler = "TrainingRateLevel", Price = 2688},
        [159] = {GemGoodsId = 159, BuyHandler = "TrainingRateLevel", Price = 5688},
        [160] = {GemGoodsId = 160, BuyHandler = "TrainingRateLevel", Price = 10288},
        [201] = {GemGoodsId = 201, BuyHandler = "ExpandableBackpack", Price = 52, NumberArray = {1}},
        [202] = {GemGoodsId = 202, BuyHandler = "ExpandableBackpack", Price = 368, NumberArray = {1}},
        [203] = {GemGoodsId = 203, BuyHandler = "ExpandableBackpack", Price = 688, NumberArray = {1}},
    },
    GoodsItemData = {}
}
