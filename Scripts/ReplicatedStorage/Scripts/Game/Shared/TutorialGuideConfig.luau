-- 前五步由服务端业务结果推进，最后三步由服务端计时展示提醒。
return {
    FirstLootGuide = {
        startEvent = "Tutorial.Login",
        steps = {
            {finishEvent = "Tutorial.Collected", target = {type = "NearestItem", key = "Tutorial.Collect"}},
            {finishEvent = "Tutorial.Deposited", target = {type = "Base", key = "Tutorial.Deposit"}},
            {finishEvent = "Tutorial.Sold", target = {type = "Sell", key = "Tutorial.Sell"}},
            {finishEvent = "Tutorial.Rate", target = {type = "Text", key = "Tutorial.Rate"}},
            {finishEvent = "Tutorial.Weapon", target = {type = "Weapon", key = "Tutorial.Weapon"}},
            {finishEvent = "Tutorial.Training", duration = 3, target = {type = "Text", key = "Tutorial.Training"}},
            {finishEvent = "Tutorial.Done", duration = 3, target = {type = "Text", key = "Tutorial.Done"}},
            {finishEvent = "Tutorial.Rewards", duration = 3, target = {type = "Rewards", key = "Tutorial.Rewards"}},
        },
    },
    FirstAuraGuide = {
        startEvent = "Tutorial.AuraAffordable",
        steps = {
            {finishEvent = "Tutorial.AuraEntered", target = {type = "Aura", key = "Tutorial.Aura"}},
        },
    },
}
