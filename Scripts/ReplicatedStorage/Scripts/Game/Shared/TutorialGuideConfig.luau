-- 手写教学配置：基础教学后依次衔接重生一至重生四，后续路线只提供文字和箭头提示。
return {
    FirstLootGuide = {
        startEvent = "Tutorial.Login",
        steps = {
            {finishEvent = "Tutorial.Collected", analyticsStepName = "OneItemCollected",
                target = {type = "NearestItem", textId = "Tutorial.Collect"}},
            {finishEvent = "Tutorial.Deposited", analyticsStepName = "LootDeposited",
                target = {type = "Base", textId = "Tutorial.Deposit"}},
            {finishEvent = "Tutorial.Sold", analyticsStepName = "LootSold",
                target = {type = "Sell", textId = "Tutorial.Sell"}},
            {finishEvent = "Tutorial.Rate", analyticsStepName = "TrainingRatePurchased",
                target = {type = "Text", textId = "Tutorial.Rate"}},
            {finishEvent = "Tutorial.Weapon", analyticsStepName = "StrongerWeaponEquipped",
                target = {type = "Weapon", textId = "Tutorial.Weapon"}},
            {finishEvent = "Tutorial.Aura", analyticsStepName = "AuraOwned",
                target = {type = "Aura", textId = "Tutorial.Aura"}},
            {finishEvent = "Tutorial.Training", analyticsStepName = "AutomaticTrainingReminderShown", duration = 5,
                target = {type = "Training", textId = "Tutorial.AutomaticTraining"}},
        },
    },
    -- 重生一：基础教学结束后，训练并完成第一次重生。
    FirstRebirthGuide = {
        startEvent = "Tutorial.StartFirstRebirth",
        previousGuideId = "FirstLootGuide",
        completionRebirthCount = 1,
        steps = {
            {finishEvent = "Tutorial.RouteProgress", skipAtRebirthCount = 1,
                target = {type = "Training", level = 15, progress = "Level", titleTextId = "Quest.Training", textId = "Route.Training"}},
            {finishEvent = "Tutorial.RouteProgress", skipAtRebirthCount = 1,
                target = {type = "Rebirth", count = 1, progress = "Rebirth", titleTextId = "Quest.Rebirth", textId = "Route.Rebirth"}},
        },
    },
    -- 重生二：重生后先恢复到第二关推荐的 15 级，再采矿、出售、换镐并完成第二次重生。
    -- 价格、装备倍率和背包容量仍读取各自正式配置。
    -- lootCount 是每趟收集目标；提前够买目标装备或背包已满时即可回家。
    -- shopType、itemId 选取实际商品；攒钱金额、购买价格与已有装备资格两端共用计算。
    -- target.progress 选择进度：Level 等级、Rebirth 次数、Money 已到账金币；省略则不显示。
    SecondRebirthGuide = {
        startEvent = "Tutorial.StartSecondRebirth",
        previousGuideId = "FirstRebirthGuide",
        completionRebirthCount = 2,
        shopType = "Weapon",
        itemId = 103,
        worldIndex = 1,
        stageIndex = 2,
        lootCount = 3,
        collectStepIndex = 2, -- 出售后仍买不起目标装备时回到采矿步骤，不重复回练。
        steps = {
            {finishEvent = "Tutorial.RouteProgress", skipAtRebirthCount = 2,
                target = {type = "Training", level = 15, progress = "Level", titleTextId = "Quest.Training", textId = "Route.Training"}},
            {finishEvent = "Tutorial.RouteProgress", skipAtRebirthCount = 2,
                target = {type = "Mining", progress = "Money", titleTextId = "Quest.Collect", textId = "Route.EarnMoney"}},
            {finishEvent = "Tutorial.RouteProgress", skipAtRebirthCount = 2,
                target = {type = "Base", titleTextId = "Quest.Deposit", textId = "Tutorial.Deposit"}},
            {finishEvent = "Tutorial.RouteProgress", skipAtRebirthCount = 2,
                target = {type = "Sell", progress = "Money", titleTextId = "Quest.Sell", textId = "Tutorial.Sell"}},
            {finishEvent = "Tutorial.RouteProgress", skipAtRebirthCount = 2,
                target = {type = "Money", progress = "Money", titleTextId = "Quest.Collect", textId = "Route.SaveMoney"}},
            {finishEvent = "Tutorial.RouteProgress", skipAtRebirthCount = 2,
                target = {type = "Weapon", progress = "Money", titleTextId = "Quest.Weapon", textId = "Route.Weapon"}},
            {finishEvent = "Tutorial.RouteProgress", skipAtRebirthCount = 2,
                target = {type = "Training", level = 30, progress = "Level", titleTextId = "Quest.Training", textId = "Route.Training"}},
            {finishEvent = "Tutorial.RouteProgress", skipAtRebirthCount = 2,
                target = {type = "Rebirth", count = 2, progress = "Rebirth", titleTextId = "Quest.Rebirth", textId = "Route.Rebirth"}},
        },
    },
    -- 重生三：先回练到第三关推荐等级，再攒够目标光环的实际价格并购买装备。
    ThirdRebirthGuide = {
        startEvent = "Tutorial.StartThirdRebirth",
        previousGuideId = "SecondRebirthGuide",
        completionRebirthCount = 3,
        shopType = "Aura",
        itemId = 102,
        worldIndex = 1,
        stageIndex = 3,
        lootCount = 3,
        collectStepIndex = 2,
        steps = {
            {finishEvent = "Tutorial.RouteProgress", skipAtRebirthCount = 3,
                target = {type = "Training", level = 30, progress = "Level", titleTextId = "Quest.Training", textId = "Route.Training"}},
            {finishEvent = "Tutorial.RouteProgress", skipAtRebirthCount = 3,
                target = {type = "Mining", progress = "Money", titleTextId = "Quest.Collect", textId = "Route.EarnMoney"}},
            {finishEvent = "Tutorial.RouteProgress", skipAtRebirthCount = 3,
                target = {type = "Base", titleTextId = "Quest.Deposit", textId = "Tutorial.Deposit"}},
            {finishEvent = "Tutorial.RouteProgress", skipAtRebirthCount = 3,
                target = {type = "Sell", progress = "Money", titleTextId = "Quest.Sell", textId = "Tutorial.Sell"}},
            {finishEvent = "Tutorial.RouteProgress", skipAtRebirthCount = 3,
                target = {type = "Money", progress = "Money", titleTextId = "Quest.Collect", textId = "Route.SaveMoney"}},
            {finishEvent = "Tutorial.RouteProgress", skipAtRebirthCount = 3,
                target = {type = "Aura", titleTextId = "Quest.Training", textId = "Route.Aura"}},
            {finishEvent = "Tutorial.RouteProgress", skipAtRebirthCount = 3,
                target = {type = "Training", level = 45, progress = "Level", titleTextId = "Quest.Training", textId = "Route.Training"}},
            {finishEvent = "Tutorial.RouteProgress", skipAtRebirthCount = 3,
                target = {type = "Rebirth", count = 3, progress = "Rebirth", titleTextId = "Quest.Rebirth", textId = "Route.Rebirth"}},
        },
    },
    -- 重生四：三次重生解锁第二训练场；到场或提醒结束后继续指向已解锁的最佳训练场。
    FourthRebirthGuide = {
        startEvent = "Tutorial.StartFourthRebirth",
        previousGuideId = "ThirdRebirthGuide",
        completionRebirthCount = 4,
        steps = {
            {finishEvent = "Tutorial.RouteProgress", skipAtRebirthCount = 4, duration = 8,
                target = {type = "TrainingField", fieldIndex = 2, titleTextId = "Quest.Training", textId = "Route.TrainingField"}},
            {finishEvent = "Tutorial.RouteProgress", skipAtRebirthCount = 4,
                target = {type = "Training", level = 60, progress = "Level", titleTextId = "Quest.Training", textId = "Route.Training"}},
            {finishEvent = "Tutorial.RouteProgress", skipAtRebirthCount = 4,
                target = {type = "Rebirth", count = 4, progress = "Rebirth", titleTextId = "Quest.Rebirth", textId = "Route.Rebirth"}},
        },
    },
}
