-- 前六步由服务端业务结果推进，最后三步由服务端计时展示提醒。
return {
    FirstLootGuide = {
        startEvent = "Tutorial.Login",
        steps = {
            {finishEvent = "Tutorial.Collected", analyticsStepName = "TwoItemsCollected",
                target = {type = "NearestItem", textId = "Tutorial.Collect"}},
            {finishEvent = "Tutorial.Deposited", analyticsStepName = "LootDeposited",
                target = {type = "Base", textId = "Tutorial.Deposit"}},
            {finishEvent = "Tutorial.Sold", analyticsStepName = "LootSold",
                target = {type = "Sell", textId = "Tutorial.Sell"}},
            {finishEvent = "Tutorial.Rate", analyticsStepName = "TrainingRatePurchased",
                target = {type = "Text", textId = "Tutorial.Rate"}},
            {finishEvent = "Tutorial.Weapon", analyticsStepName = "StrongerWeaponEquipped",
                target = {type = "Weapon", textId = "Tutorial.Weapon"}},
            {finishEvent = "Tutorial.Aura", analyticsStepName = "AuraEquipped",
                target = {type = "Aura", textId = "Tutorial.Aura"}},
            {finishEvent = "Tutorial.Training", analyticsStepName = "AutomaticTrainingReminderShown", duration = 5,
                target = {type = "Training", textId = "Tutorial.AutomaticTraining"}},
            {finishEvent = "Tutorial.Done", analyticsStepName = "CompletionReminderShown", duration = 3,
                target = {type = "Text", textId = "Tutorial.Done"}},
            {finishEvent = "Tutorial.Rewards", analyticsStepName = "GuideFinished", duration = 3,
                target = {type = "Rewards", textId = "Tutorial.Rewards"}},
        },
    },
}
