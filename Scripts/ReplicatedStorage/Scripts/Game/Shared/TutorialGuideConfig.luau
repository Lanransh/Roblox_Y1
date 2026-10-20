-- 前五步由服务端业务结果推进，最后三步由服务端计时展示提醒。
return {
    FirstLootGuide = {
        startEvent = "Tutorial.Login",
        steps = {
            {finishEvent = "Tutorial.Collected", target = {type = "NearestItem", textId = "Tutorial.Collect"}},
            {finishEvent = "Tutorial.Deposited", target = {type = "Base", textId = "Tutorial.Deposit"}},
            {finishEvent = "Tutorial.Sold", target = {type = "Sell", textId = "Tutorial.Sell"}},
            {finishEvent = "Tutorial.Rate", target = {type = "Text", textId = "Tutorial.Rate"}},
            {finishEvent = "Tutorial.Weapon", target = {type = "Weapon", textId = "Tutorial.Weapon"}},
            {finishEvent = "Tutorial.Training", duration = 3, target = {type = "Text", textId = "Tutorial.AutomaticTraining"}},
            {finishEvent = "Tutorial.Done", duration = 3, target = {type = "Text", textId = "Tutorial.Done"}},
            {finishEvent = "Tutorial.Rewards", duration = 3, target = {type = "Rewards", textId = "Tutorial.Rewards"}},
        },
    },
    FirstAuraGuide = {
        startEvent = "Tutorial.AuraAffordable",
        steps = {
            {finishEvent = "Tutorial.AuraEntered", target = {type = "Aura", textId = "Tutorial.Aura"}},
        },
    },
}
