-- 当前项目多一步基地入库；所有步骤只接受服务端业务结果。
return {
    FirstLootGuide = {
        startEvent = "Tutorial.Login",
        steps = {
            {finishEvent = "Tutorial.Collected", target = {type = "NearestItem", key = "Tutorial.Collect"}},
            {finishEvent = "Tutorial.Deposited", target = {type = "Base", key = "Tutorial.Deposit"}},
            {finishEvent = "Tutorial.Sold", target = {type = "Sell", key = "Tutorial.Sell"}},
            {finishEvent = "Tutorial.Rate", target = {type = "Text", key = "Tutorial.Rate"}},
            {finishEvent = "Tutorial.Weapon", target = {type = "Weapon", key = "Tutorial.Weapon"}},
            {finishEvent = "Tutorial.Training", target = {type = "Training", key = "Tutorial.Training"}},
            {finishEvent = "Tutorial.Done", target = {type = "Text", key = "Tutorial.Done"}},
        },
    },
    FirstAuraGuide = {
        startEvent = "Tutorial.AuraAffordable",
        steps = {
            {finishEvent = "Tutorial.AuraEntered", target = {type = "Aura", key = "Tutorial.Aura"}},
        },
    },
}
