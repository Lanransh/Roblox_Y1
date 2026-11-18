-- 手写教学配置：首轮保留原步骤，后续固定路线由服务端真实等级、库存和装备推进。
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
            {finishEvent = "Tutorial.Done", analyticsStepName = "CompletionReminderShown", duration = 3,
                target = {type = "Text", textId = "Tutorial.Done"}},
            {finishEvent = "Tutorial.Rewards", analyticsStepName = "GuideFinished", duration = 3,
                target = {type = "Rewards", textId = "Tutorial.Rewards"}},
        },
    },
    -- 首轮结束后接到第二次重生；价格、装备倍率和背包容量仍读取各自正式配置。
    -- lootCount 是每趟收集目标；提前够买目标装备或背包已满时即可回家。
    -- target.progress 选择黄色数字进度：Level 等级、Rebirth 次数、Loot 随身件数、Money 已到账金币；省略则不显示。
    SecondRebirthGuide = {
        startEvent = "Tutorial.StartRebirthRoute",
        completionRebirthCount = 2,
        weaponId = 103,
        worldIndex = 1,
        stageIndex = 2,
        lootCount = 3,
        collectStepIndex = 3, -- 出售后仍买不起目标装备时回到此步骤。
        steps = {
            {finishEvent = "Tutorial.RouteProgress", skipAtRebirthCount = 1,
                target = {type = "Training", level = 15, progress = "Level", titleTextId = "Quest.Training", textId = "Route.Training"}},
            {finishEvent = "Tutorial.RouteProgress", skipAtRebirthCount = 1,
                target = {type = "Rebirth", count = 1, progress = "Rebirth", titleTextId = "Quest.Rebirth", textId = "Route.Rebirth"}},
            {finishEvent = "Tutorial.RouteProgress", skipAtRebirthCount = 2,
                target = {type = "Mining", progress = "Loot", titleTextId = "Quest.Collect", textId = "Route.Collect"}},
            {finishEvent = "Tutorial.RouteProgress", skipAtRebirthCount = 2,
                target = {type = "Base", titleTextId = "Quest.Deposit", textId = "Tutorial.Deposit"}},
            {finishEvent = "Tutorial.RouteProgress", skipAtRebirthCount = 2,
                target = {type = "Sell", progress = "Money", titleTextId = "Quest.Sell", textId = "Tutorial.Sell"}},
            {finishEvent = "Tutorial.RouteProgress", skipAtRebirthCount = 2,
                target = {type = "Weapon", progress = "Money", titleTextId = "Quest.Weapon", textId = "Route.Weapon"}},
            {finishEvent = "Tutorial.RouteProgress", skipAtRebirthCount = 2,
                target = {type = "Training", level = 30, progress = "Level", titleTextId = "Quest.Training", textId = "Route.Training"}},
            {finishEvent = "Tutorial.RouteProgress", skipAtRebirthCount = 2,
                target = {type = "Rebirth", count = 2, progress = "Rebirth", titleTextId = "Quest.Rebirth", textId = "Route.Rebirth"}},
        },
    },
}
